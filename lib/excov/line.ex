defmodule ExCov.Line do
  @moduledoc """
  Defines `ExCov.Line` struct for storing information about a line of code.
  """

  @enforce_keys [:index]
  defstruct [
    index: nil,
    content: nil,
    relevant?: false,
    covered?: false,
    call_count: nil
  ]

  @typedoc """
  Type that represents `ExCov.Line`struct.

  ## Required Keys
  * The `index` key is required.

  ## Keys
  * `index` the line number of a line in a source file.
  * `content` the source code content of that line.
  * `relevant?` is this line relevant to code coverage analysis.
  * `covered?` was this line called atleast once.
  * `call_count` number of times this line was called.
  """
  @type t :: %__MODULE__{
    index: non_neg_integer,
    content: binary,
    relevant?: boolean,
    covered?: boolean,
    call_count: non_neg_integer
  }
end
