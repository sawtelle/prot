# TODO: Would a --dry-run switch be useful? Perhaps not.

require 'thor'

module Prot

  def cli
    ProtCLI.start
  end

  class ProtCLI < Thor
    include Thor::Actions
    @@prot_name = File.basename($0)

    # Thor's default returns false. Returning true to get correct ?* error codes in the shell.
    def self.exit_on_failure?
      true
    end

    # WARNING: Explicitly specifying :default => false for boolean switches will break
    # merging in values from config file.
    class_option :app, :type => :string, :desc => "Explicitly specify app rather than inferring from current directory"
    class_option :verbose, :type => :boolean, :desc => "Print raw output of all shell commands."
    class_option :yes, :type => :boolean, :desc => "Take action without asking for confirmation."
    class_option :quiet, :type => :boolean, :desc => "Print only the new password."

    check_unknown_options!

    desc "version, --version, -v", "Show version"
    map %w[--version -v] => :version
    def version
      require "prot/version"
      say "#{@@prot_name} version #{Prot::VERSION}", :blue
    end

    desc "heroku_rediscloud", "Rotate heroku app's rediscloud password"
    long_desc <<-LONGDESC
      `#{@@prot_name} heroku_rediscloud --new_password aA1bB2cC3dD4eE5 --heroku_password HPASS --heroku_email HEMAIL`
      rotates the default rediscloud password for the current directory's heroku app.

      #{@@prot_name} updates REDISCLOUD_URL in heroku's config with the changed password, thus causing heroku to restart the app.
      to restart the app.
    LONGDESC
    method_option :new_password, :type => :string, :desc => "new password for Redis Cloud", :required => true
    method_option :heroku_email, :type => :string, :desc => "email address for login to heroku", :required => true
    method_option :heroku_password, :type => :string, :desc => "password for login to heroku", :required => true
    def heroku_rediscloud
      require 'capybara'
      check_global_options

      say("heroku_config_redis_password=" + heroku_config_redis_password, :blue) unless options[:quiet]

      # TODO: Deal gracefully with errors if they occur

      app = heroku_app_name
      new_password = options[:new_password]
      heroku_email = options[:heroku_email]
      heroku_password = options[:heroku_password]

      if options[:verbose]
        session = Capybara::Session.new(:selenium)
      else
        require 'capybara/poltergeist'
        Capybara.configure do |config|
          config.run_server = false
          config.default_driver = :poltergeist
          config.default_max_wait_time = 30
        end

        session = Capybara::Session.new(:poltergeist)
      end

      session.visit "https://dashboard.heroku.com/apps/#{app}/resources"
      wait_for_ajax(session)
      session.fill_in 'email', :with => heroku_email
      session.fill_in 'password', :with => heroku_password
      session.click_button 'Log In'
      wait_for_ajax(session)
      session.visit(session.find_link('Redis Cloud')[:href]) # open in existing window

      # assumes we want the first redis (possibly only) instance in the table
      session.within('tbody') do
        session.all('tr').first.click
      end

      wait_for_ajax(session)
      session.click_button 'Edit'

      wait_for_ajax(session)
      session.fill_in 'redis_password', :with => new_password
      
      if options[:yes] || ask("Change password of Redis Cloud instance of heroku app #{app} from #{heroku_config_redis_password} to #{new_password}?", :blue, :limited_to => ["yes", "no"]) == "yes"
        session.click_button 'Update'
        set_heroku_config_redis_password(new_password)
        if options[:quiet]
          say heroku_config_redis_password
        else
          say "heroku_config_redis_password=" + heroku_config_redis_password, :blue
        end
        wait_for_ajax(session)
      end
    end

    desc "heroku_postgresql", "Rotate heroku app's postgresql credentials"
    long_desc <<-LONGDESC
      `#{@@prot_name} heroku_postgresql` rotates the default postgresql database
      credentials for the current directory's heroku app.

      heroku restarts the app automatically.
    LONGDESC
    method_option :database, :aliases => "-d", :desc => "Specify other than Heroku's primary DATABASE"#, :default => "DATABASE"
    def heroku_postgresql
      check_global_options

      app = options[:app]
      db = options[:database]
      # TODO: Different Thor use that avoids the need for this?
      raise Thor::Error, "ERROR: '--database NAME' requires NAME." if db == "database"
      db ||= "DATABASE_URL" # heroku config will require manually specifying the default

      app = heroku_app_name

      if options[:yes] || ask("Rotate credentials of postgresql #{db} of heroku app #{app}?", :blue, :limited_to => ["yes", "no"]) == "yes"
        say("heroku_config_postgres_password=" + heroku_config_postgres_password(db), :blue) unless options[:quiet]
        reset_heroku_config_postgres_password(db)
        if options[:quiet]
          say heroku_config_postgres_password(db)
        else
          say "heroku_config_postgres_password=" + heroku_config_postgres_password(db), :blue
        end
      end
    end

    no_commands {
    }

  private

    # foreman does this, but I'm finding there are Thor issues.
    # WARNING: This is called repeatedly.
    # WARNING: If boolean switches have :default => false explicitly
    # specified, that breaks merging in values from config file.
    #
    # Extend to load options from a file, which present command line options will override.
#   def options
#     require 'yaml'
#
#     original_options = super
#     filename = File.expand_path("~/.prot.rc.yaml")
#     return original_options unless File.exists?(filename)
#     config_file_options = ::YAML::load_file(filename) || {}
#     Thor::CoreExt::HashWithIndifferentAccess.new(config_file_options.merge(original_options))
#   end

    def check_global_options
      raise Thor::Error, "ERROR: '--app NAME' requires NAME." if options[:app] == "app"
      raise Thor::Error, "ERROR: STDOUT is not a tty; use --yes (be careful!)" unless STDOUT.tty? || options[:yes]
    end

    # TODO: Figure out DATABASE versus DATABASE_URL (both seem to work, but always DATABASE_URL in config). DATABASE deprecated?
    # TODO: Is it necessary to retain --database switch to specify other than this default?
    def heroku_config_postgres_password(database)
      heroku_config_hash[database].split(':')[2].split('@')[0]
      # heroku_success("heroku pg:credentials #{database} #{heroku_global_options}").split.find { |e| /password=/ =~e }
    end

    def reset_heroku_config_postgres_password(database)
      heroku_success("heroku pg:credentials #{heroku_global_options} #{database} --reset", true)
      invalidate_heroku_config_cache
    end

    def heroku_config_redis_password
      heroku_config_hash["REDISCLOUD_URL"].split(':')[2].split('@')[0]
    end

    def set_heroku_config_redis_password(new_password)
      rediscloud_url = heroku_config_hash["REDISCLOUD_URL"]
      rediscloud_url.sub! heroku_config_redis_password, new_password
      heroku_success("heroku config:set REDISCLOUD_URL=#{rediscloud_url} #{heroku_global_options}", true)
      invalidate_heroku_config_cache
    end
 
    # TODO: heroku config memoization/invalidation messy. Use better memoization/invalidation pattern or gem.

    def invalidate_heroku_config_cache
      heroku_config_hash(true)
    end

    def heroku_config_hash(invalidate_cache = false)
      return @@heroku_config_hash if !invalidate_cache && defined? @@heroku_config_hash

      raw_heroku_config = heroku_success("heroku config --shell #{heroku_global_options}")
      nested_array = raw_heroku_config.lines.map do |l|
        key, value = l.split('=')
        [key, value.chomp!]
      end
      @@heroku_config_hash = Hash[nested_array]
    end

    def heroku_global_options
      app = options[:app] != "app" ? options[:app] : nil # Avoid what seems a thor bug
      app ? "--app #{options[:app]}" : nil
    end

    def heroku_app_name
      return @@heroku_app_name if defined? @@heroku_app_name

      app = options[:app] != "app" ? options[:app] : nil # Avoid what seems a thor bug
      hc = heroku_success("heroku config #{heroku_global_options}").split
      heroku_app  = hc[0] == "===" ? hc[1] : nil
      @@heroku_app_name = app ||= heroku_app
    end

    def heroku_success(s, force_output = false)
      # chomp to prevent say from failing to append a newline
      say(s.chomp(' '), :green) unless options[:quiet]
      output = `#{s}`
      say output if (options[:verbose] || force_output) && !options[:quiet]
      raise Thor::Error, "ERROR: heroku command failed." if $?.exitstatus > 0

      output
    end
  end

  # https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
  def wait_for_ajax(session)
    sleep 5
    Timeout.timeout(30) do
      loop until finished_all_ajax_requests?(session)
    end
  end

  def finished_all_ajax_requests?(session)
    session.evaluate_script('jQuery.active').zero?
  end
end

