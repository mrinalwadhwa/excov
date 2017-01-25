defmodule ExCov.Statistics do
  @moduledoc """
  Defines `ExCov.Statistics` struct for storing code coverage statistics.
  """

  defstruct [
    count_of_lines: 0,
    count_of_lines_relevant: 0,
    count_of_lines_covered: 0,
    count_of_lines_missed: 0,
    percentage_of_relevant_lines_covered: 0.0
  ]

  @typedoc """
  Type that represents `ExCov.Statistics`struct.

  ## Key
  * `count_of_lines` the total number of lines of code.
  * `count_of_lines_relevant` the number of lines that are relevant to code
    coverage.
  * `count_of_lines_covered` the number of lines that are covered by tests.
  * `count_of_lines_missed` the number of lines that are not covered by tests.
  * `percentage_of_relevant_lines_covered` percentage of lines that relevant
    to code coverage and covered by tests.
  """
  @type t :: %__MODULE__{
    count_of_lines: non_neg_integer,
    count_of_lines_relevant: non_neg_integer,
    count_of_lines_covered: non_neg_integer,
    count_of_lines_missed: non_neg_integer,
    percentage_of_relevant_lines_covered: float
  }
end
