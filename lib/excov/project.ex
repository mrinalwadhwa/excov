defmodule ExCov.Project do
  @moduledoc """
  Gives information about and analyses a Mix Project for code coverage.
  """

  alias ExCov.Project,    as: Project
  alias ExCov.Module,     as: Module
  alias ExCov.Statistics, as: Statistics

  defstruct [
    compile_path: nil,
    cover_compiled?: false,
    cover_analysed?: false,
    modules: nil,
    statistics: nil
  ]

  @typedoc """
  Type that represents a `ExCov.Project` struct.

  ## Keys
  * `compile_path` the path to compile for code coverage analysis.
    defaults to the value of `Mix.Project.compile_path`.
  * `cover_compiled?` is this project compiled for code coverage analysis.
  * `cover_analysed?` has the project been analysed for code coverage.
  * `modules` the list of modules in this project.
  * `statistics` code coverage statistics for this project.
  """
  @type t :: %__MODULE__{
    compile_path: binary,
    cover_compiled?: boolean,
    cover_analysed?: boolean,
    modules: [Module.t],
    statistics: Statistics.t
  }

  @doc """
  Return a new `ExCov.Project` struct
  """
  @spec new(binary) :: Project.t
  def new(compile_path \\ Mix.Project.compile_path) do
    %Project{ compile_path: compile_path }
  end

  @doc """
  Compile this project for cover analysis using the Erlang
  [`cover`](http://erlang.org/doc/man/cover.html) module.
  """
  @spec compile_for_cover_analysis(Project.t) :: Project.t
  def compile_for_cover_analysis(p = %Project{ compile_path: compile_path }) do
    compile_path |> to_charlist |> :cover.compile_beam_directory

    %{p | cover_compiled?: true, modules: :cover.modules }
  end

  @doc """
  Return the absolute path of the current Mix project's root directory.
  """
  @spec root() :: binary
  def root() do
    # look for the path of the mix.exs file in the config_files of this project
    # extract its dirname to get the path of the project
    Enum.find(Mix.Project.config_files, &(&1 =~ ~r/mix.exs/)) |> Path.dirname
  end

  @doc """
  Analyse an `ExCov.Project` for code coverage.
  """
  @spec analyse(t) :: t
  def analyse(project = %Project{ cover_compiled?: true, modules: modules }) do
    analysed_modules = Enum.map(modules, &Module.analyse/1)
    %{project |
      cover_analysed?: true,
      modules: analysed_modules,
      statistics: collect_statistics(analysed_modules)
     }
  end

  @doc """
  Collect code coverage statistics.

  Given an array of analysed `ExCov.Module` structs, return aggregate
  code coverage statistics.
  """
  @spec collect_statistics([Module.t]) :: Statistics.t
  def collect_statistics(modules) do
    total = Enum.reduce(modules, 0, &(&1.statistics.count_of_lines + &2))
    relevant =
      Enum.reduce(modules, 0, &(&1.statistics.count_of_lines_relevant + &2))
    covered =
      Enum.reduce(modules, 0, &(&1.statistics.count_of_lines_covered + &2))
    %Statistics{
      count_of_lines: total,
      count_of_lines_relevant: relevant,
      count_of_lines_covered: covered,
      count_of_lines_missed: relevant - covered,
      percentage_of_relevant_lines_covered: covered/relevant * 100
     }
  end

end
