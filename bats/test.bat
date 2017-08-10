#!/usr/bin/env bats

@test "invoking prot without specifying --app prints an error" {
  run prot heroku-postgresql --quiet --yes
  [ "$status" -eq 1 ]
  [[ ${lines[0]} =~ "No app specified." ]]
}

@test "redirecting prot output without specifying --yes prints an error" {
  run bash -c "prot heroku-postgresql --app fencepost --quiet | cat"
  [[ ${lines[0]} =~ "STDOUT is not a tty" ]]
}

@test "using --app without an argument prints an error" {
  run prot heroku-postgresql --quiet --yes --app
  [ "$status" -eq 1 ]
  [[ ${lines[0]} =~ "ERROR: '--app NAME' requires NAME." ]]
}

@test "using --database without an argument prints an error" {
  run prot heroku-postgresql --quiet --yes --app fencepost --database
  [ "$status" -eq 1 ]
  [[ ${lines[0]} =~ "ERROR: '--database NAME' requires NAME." ]]
}

@test "rotating heroku app fencepost's postgresql password succeeds" {
  # skip "put these in a separate file"
  run prot heroku-postgresql --quiet --yes --app fencepost
  [ "$status" -eq 0 ]
}

@test "invoking heroku-rediscloud without --heroku-email prints an error" {
  run prot heroku-rediscloud --new-password 'D9YQnV7KNxyziLj' --quiet --yes --app fencepost --heroku-password 'something'
  [ "$status" -eq 1 ]
  [[ ${lines[0]} =~ "No value provided for required options '--heroku-email'" ]]
}

@test "invoking heroku-rediscloud without --heroku-password prints an error" {
  run prot heroku-rediscloud --new-password 'D9YQnV7KNxyziLj' --quiet --yes --app fencepost --heroku-email your.email@gmail.com
  [ "$status" -eq 1 ]
  [[ ${lines[0]} =~ "No value provided for required options '--heroku-password'" ]]
}

@test "invoking heroku-rediscloud without --new-password prints an error" {
  run prot heroku-rediscloud --new-password 'D9YQnV7KNxyziLj' --quiet --yes --app fencepost --heroku-email your.email@gmail.com
  [ "$status" -eq 1 ]
  [[ ${lines[0]} =~ "No value provided for required options '--heroku-password'" ]]
}

@test "rotating heroku app fencepost's rediscloud password succeeds" {
  # skip "put these in a separate file"
  run prot heroku-rediscloud --new-password 'D9YQnV7KNxyziLj' --quiet --yes --app fencepost --heroku-email your.email@gmail.com --heroku-password 'your.heroku.password'
  [ "$status" -eq 0 ]
}

