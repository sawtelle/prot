# Prot
 
Prot shows how to easily write a documented maintainable command-line utility.

Prot's example mission: provide a tool for rotating credentials.

So far it works with heroku's postgresql and heroku's Redis Cloud
and has been tested only on OS X.

Prot uses the heroku CLI to handle postgresql; it drives web UI
to handle Redis Cloud.

## Installation

Prot is not published to any gem server. You can install it yourself
by cloning this repo, then from within the repo do:

    $ gem build prot.gemspec
    $ gem install prot-*.gem
    $ gem install gem-man

## Usage

To see available commands:

    $ prot help

To see detail on a particular command:

    $ prot help COMMAND

To read the man page:

    $ gem man prot

To peruse meta-thoughts: https://github.com/sawtelle/prot/wiki

## Testing

    $ brew install bats # OS X

For other OS, see https://github.com/sstephenson/bats.git

    $ bats bats/*.bat

## Contributing

1. Fork it ( https://github.com/sawtelle/prot/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

