defmodule ExCov do
  @moduledoc """
  Provides Code Coverage Reports for Elixir code.

  ExCov is a lightweight, dependency-free, drop-in replacement for the code
  coverage tool that is invoked by Mix when `mix test --cover` is invoked.

  ExCov supports **Pluggable Reporters** for integration with external services and customized reporting.
  """

  alias ExCov.Project, as: Project

  @doc """
  Configures ExCov and prepares this project for coverage analysis, returns
  an anonymous function that can be later called to generate code coverage
  reports.

  This function is called by Mix to start a cover analysis when
  `mix test --cover` is invoked. Mix also calls the returned anonymous function
  after it's done executing tests.

  Application Configuration is overwridden by invocation options.
  """
  @spec start(binary, Keyword.t) :: fun
  def start(compile_path, options \\ []) do
    options = Keyword.put(options, :compile_path, compile_path)
    options = Keyword.merge(Application.get_all_env(:excov), options)

    # compile the project for cover analysis
    project = Project.new(options) |> Project.compile_for_cover_analysis

    # return a function that mix will call later when tests are done running
    fn ->
      # analyse the project
      analysed = Project.analyse(project)

      # get list of configured reporters
      reporters = Keyword.get(options, :reporters, [])

      # genrate reports with each reporter
      report!(analysed, reporters_with_options(reporters, options))

      :ok
    end
  end

  @doc """
  Configures ExCov, prepares this project for coverage analysis, run tests
  and then generate code coverage reports.

  Application Configuration is overwridden by invocation options.
  """
  @spec run(Keyword.t) :: :ok
  def run(options \\ []) do
    options = Keyword.merge(Application.get_all_env(:excov), options)

    # compile the project for cover analysis
    project = Project.new(options) |> Project.compile_for_cover_analysis

    # run test task
    Mix.Task.run "test"

    # analyse the project
    analysed = Project.analyse(project)

    # get list of configured reporters
    reporters = Keyword.get(options, :reporters, [])

    # genrate reports with each reporter
    report!(analysed, reporters_with_options(reporters, options))

    :ok
  end

  @doc """
  Given a Project and a list of tuples, where each tuple is a Reporter and its
  corresponding options, this function invokes each reporter, passing in the
  project and that reporters options.
  """
  @spec report!(Project.t, [{Reporter.t, Keyword.t}]) :: :ok
  def report!(project, reporters_with_options \\ []) do
    Enum.each reporters_with_options, fn({reporter, reporter_options}) ->
      reporter.report!(project, reporter_options)
    end
  end

  @doc """
  Given a list of reporters and ExCov options as Keyword list, returns a list
  of tuples with each Reporter as first element and that reporter's
  corresponding options as the second element.
  """
  @spec reporters_with_options([Reporter.t], Keyword.t) ::
    [{Reporter.t, Keyword.t}]
  def reporters_with_options(reporters, options) do
    Enum.map reporters, fn(reporter) ->
      reporter_options = Keyword.get(options, reporter, [])
      {reporter, reporter_options}
    end
  end

end
