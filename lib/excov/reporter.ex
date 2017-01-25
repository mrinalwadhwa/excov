defmodule ExCov.Reporter do
  @moduledoc """
  Specification of the behavior of an ExCov Reporter.

  A Reporter is a module that exports a `report!/2` function.
  """

  @typedoc """
  Type that represents an `ExCov.Reporter`.
  """
  @type t :: atom

  @doc """
  Given an analysed `ExCov.Project` and a `Keyword` list of options, prints a
  code coverage report.

  Most reporters support the following options:
  * `:show_summary?` a boolean indicating if a summary should be reported.
  * `:show_detail?` a boolean indicating if a details should be reported.
  * `:console_printer` a function that should be called if the reporter
    wishes to print something to console.

  None of the above options are required and reporter may chose to ignore
  any and all of them.
  """
  @callback report!(ExCov.Project.t, Keyword.t) :: :ok
end
