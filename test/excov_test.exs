defmodule ExCov.Test do
  use ExUnit.Case
  doctest ExCov

  alias ExCov.Project, as: Project

  defmodule R1 do
    def report!(_project, _options) do
      send self(), {:ok, R1}
    end
  end

  defmodule R2 do
    def report!(_project, _options) do
      send self(), {:ok, R2}
    end
  end

  defmodule R3 do
    def report!(_project, _options) do
      send self(), {:ok, R3}
    end
  end

  describe "ExCov.report!/2" do
    test "calls reporters" do
      ExCov.report!(Project.new, [{R1, []}, {R2, []}, {R3, []}])

      assert_receive {:ok, R1}
      assert_receive {:ok, R2}
      assert_receive {:ok, R3}
    end
  end

  describe "ExCov.reporters_with_options/2" do
    test "returns Keyword with reporter as key & reporter options as value" do
      r = ExCov.reporters_with_options([:a,:b], [
        {:a, [{:x, 100},{:y, 200}]},
        {:b, [{:p, 100},{:q, 200}]},
        {:c, []}
      ])
      assert [{:x, 100},{:y, 200}] == Keyword.get(r, :a)
      assert [{:p, 100},{:q, 200}] == Keyword.get(r, :b)
      assert false == Keyword.has_key?(r, :c)
    end
  end

end
