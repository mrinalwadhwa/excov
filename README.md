# ExCov

Code Coverage Reports for Elixir code.

`ExCov` is a lightweight, dependency-free, drop-in replacement for the code
coverage tool that is invoked by Mix when `mix test --cover` is invoked.

`ExCov` supports [Pluggable Reporters](#pluggable_reporters) for integration
with external services and customized reporting.

## Pluggable Reporters

ExCov uses pluggable reporters to print code coverage reports.

`ExCov` is intentionally minimal and free of any runtime dependencies, by
default the library includes no reporters.

To be useful, you must include at least one reporter as a dependency to your
project along with ExCov.

[`ExCov.Console`](https://github.com/mrinalwadhwa/excov_reporter_console) is a
good one to start with.

## Configuration

### mix.exs

Add the following to your project’s `mix.exs`:

````
def project do
  [
    ...
    test_coverage: [tool: ExCov],
    preferred_cli_env: [
      ...
      "cov": :test,
      "cov.detail": :test,
      ...
    ],
    ...
  ]
end

defp deps do
  [
    ...
    {:excov, "~> 0.1", only: :test},
    {:excov_reporter_console, "~> 0.1", only: :test}
    ...
  ]
end
````

### config/test.exs

````
config :excov,
  :reporters, [
    ExCov.Reporter.Console
  ]

config :excov, ExCov.Reporter.Console,
  show_summary: true,
  show_detail: false

````

## Run

To run the cover tool via the `mix` command:

````
mix test --cover
````

````
mix cov
````

````
mix cov.detail
````

## Credits

ExCov drew some initial ideas from
[ExCoveralls](https://github.com/parroty/excoveralls),
thanks [parroty](https://github.com/parroty).

## License

ExCov is licensed under the [MIT License](LICENSE).
