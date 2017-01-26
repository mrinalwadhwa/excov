defmodule ExCov.Module do
  @moduledoc """
  Gives information about and analyses a source code Module for code coverage.

  Defines `ExCov.Module` struct for storing information about a module of code.
  """

  alias ExCov.Module,     as: Module
  alias ExCov.Line,       as: Line
  alias ExCov.Statistics, as: Statistics

  @enforce_keys [:name]
  defstruct [
    :name,
    :source_path,
    :lines,
    :statistics
  ]

  @typedoc """
  Type that represents `ExCov.Module` struct.

  ## Required Keys
  * The `name` key is required.

  ## Keys
  * `name` the name of this module.
  * `source_path` the absolute path of the source file of this module.
  * `lines` all source lines of this module as `ExCov.Line` structs.
  * `statistics` code coverage statistics for this module.
  """
  @type t :: %__MODULE__{
    name: atom,
    source_path: binary,
    lines: [Line.t],
    statistics: Statistics.t
  }

  @doc """
  Create a new `ExCov.Module`.

  Given the name of a module, returns a `ExCov.Module` struct.

  The `source_path` key is populated with the absolute path of the source
  code file of this module.
  """
  @spec new(name :: atom) :: t
  def new(name) when is_atom(name) do
    %Module{
      name: name,
      source_path: source_path(name)
    }
  end

  @doc """
  Analyse an `ExCov.Module` for code coverage.

  Given a `ExCov.Module` struct, analyse that module for code coverage, and
  populate the `lines` and `statistics` fields.
  """
  @spec analyse(t) :: t
  def analyse(module = %Module{ name: name }) do
    tagged_lines = tag_lines(lines(module), call_counts(name))
    statistics = collect_statistics(tagged_lines)
    %{module | lines: tagged_lines, statistics: statistics}
  end

  @doc """
  Collect code coverage statistics.

  Given an array of tagged `ExCov.Line` structs, return aggregate
  code coverage statistics.
  """
  @spec collect_statistics([%Line{}]) :: %Statistics{}
  def collect_statistics(lines) do
    relevant = Enum.count(lines, &(&1.relevant?))
    covered = Enum.count(lines, &(&1.covered?))

    percentage_of_relevant_lines_covered =
      if relevant == 0 do
        100.0
      else
        covered/relevant * 100
      end

    %Statistics{
      count_of_lines: length(lines),
      count_of_lines_relevant: relevant,
      count_of_lines_covered: covered,
      count_of_lines_missed: relevant - covered,
      percentage_of_relevant_lines_covered:
        percentage_of_relevant_lines_covered
    }
  end

  @doc """
  Tag list of `ExCov.Line` structs as `relevant?` or
  `covered?` & add `call_count`

  Given a list of Line structs and a map with line index as key and number
  of calls to that line as value, returns a tagged list of lines with
  `relevant?`, `covered?` and `call_count` keys populated.
  """
  @spec tag_lines([%Line{}], %{}) :: [%Line{}]
  def tag_lines(lines, call_counts) do
    Enum.map(lines, fn(line) ->
      case Map.get(call_counts, line.index) do
        nil -> %{line | relevant?: false}
          0 -> %{line | relevant?: true}
          c -> %{line | relevant?: true, covered?: true, call_count: c}
      end
     end)
  end

  @doc """
  Return lines of a module as list of `ExCov.Line` structs.

  Given the name of a module, reads the source of that modules and returns a
  list of Line structs, one for each line.
  """
  @spec lines(atom) :: [%Line{}]
  def lines(%Module{ source_path: source_path }) do
    source_path
     |> File.stream!
     |> Stream.with_index
     |> Enum.map(fn({c, i}) -> %Line{index: i, content: c} end)
  end

  @doc """
  Return the number of times lines were called.

  Given the name of a module, return a map with line number as key and the
  number of times that line is called as value.

  * Uses the Erlang [`cover`](http://erlang.org/doc/man/cover.html) module.
  * The module must have been compiled for cover analysis before calling this
    function.
  * The number of calls returned is the number of calls since compilation for
    cover analysis.
  """
  @spec call_counts(atom) :: %{}
  def call_counts(name) do
    case :cover.analyse(name, :calls, :line) do
      {:error, error} ->
        raise "cover.analyse for #{name} failed: #{error}"
      {:ok, lines} ->
        # :cover.analyse seems to return the same line multiple times,
        # reduce it to a map with line number as key and max count returned
        # for each line as value
        Enum.reduce(lines, %{}, fn({{_, line_no}, count}, acc) ->
          Map.update acc, line_no, [count], fn(counts) -> [count|counts] end
        end)
        |> Enum.reduce(%{}, fn({k,v}, a) -> Map.put(a, k, Enum.max(v)) end)
    end
  end

  @doc """
  Return the source path of a module.

  Given the name of a module, returns the absolute source path of that module.
  """
  @spec source_path(atom) :: binary
  def source_path(name) do
    name.module_info(:compile)[:source] |> List.to_string
  end

end
