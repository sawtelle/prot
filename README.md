# Prot

Prot is a command-line tool for rotating credentials.

So far it works with heroku's postgresql and heroku's Redis Cloud.

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

