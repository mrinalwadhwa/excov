defmodule ExCov.Module.Test do
  use ExUnit.Case

  alias ExCov.Module,     as: Module
  alias ExCov.Project,    as: Project
  alias ExCov.Line,       as: Line
  alias ExCov.Statistics, as: Statistics

  doctest Module

  describe "Module.new/1" do
    test "returns a new Module struct" do
      assert %Module{} = Module.new(Module)
    end

    test "returned struct has name property" do
      module = Module.new(Module)
      assert Module == module.name
    end

    test "returned struct has source_path property" do
      module = Module.new(Module)
      path = Path.join([Project.root, "lib/excov/module.ex"])
      assert path == module.source_path
    end
  end

  describe "Module.analyse/1" do
    test "populates the lines property" do
      {:ok, Module} = :cover.compile_beam(Module)
      module = Module.new(Module)
      assert is_nil(module.lines)

      analysed = Module.analyse(module)
      assert !is_nil(analysed.lines)
    end

    test "populates the statistics property" do
      {:ok, Module} = :cover.compile_beam(Module)
      module = Module.new(Module)
      assert is_nil(module.statistics)

      analysed = Module.analyse(module)
      assert !is_nil(analysed.statistics)
    end
  end

  describe "Module.collect_statistics/1" do
    setup do
      statistics =
        Module.collect_statistics([
          %Line{ index: 1, relevant?: true,  covered?: true  },
          %Line{ index: 2, relevant?: false, covered?: false },
          %Line{ index: 3, relevant?: true,  covered?: false },
          %Line{ index: 4, relevant?: true,  covered?: false }
        ])
      {:ok, [statistics: statistics]}
    end

    test "returns Statistics struct", context do
      assert %Statistics{} = context[:statistics]
    end

    test "count_of_lines is populated", context do
      assert 4 == context[:statistics].count_of_lines
    end

    test "count_of_lines_relevant is populated", context do
      assert 3 == context[:statistics].count_of_lines_relevant
    end

    test "count_of_lines_covered is populated", context do
      assert 1 == context[:statistics].count_of_lines_covered
    end

    test "count_of_lines_missed is populated", context do
      assert 2 == context[:statistics].count_of_lines_missed
    end

    test "percentage_of_relevant_lines_covered is populated", context do
      coverage = context[:statistics].percentage_of_relevant_lines_covered
      assert 33.33333333333333 == coverage
    end
  end

  describe "Module.tag_lines/2" do
    setup do
      tagged = Module.tag_lines(
        [%Line{index: 1},
         %Line{index: 2},
         %Line{index: 3},
         %Line{index: 4},
         %Line{index: 5}],
      %{2 => 0, 3 => 0, 4 => 10})
      {:ok, [tagged: tagged]}
    end

    test """
    lines with no call_count are marked not relevant and not covered
    """, context do
      [one, _, _, _, five | _tail] = context[:tagged]
      assert false == one.relevant?
      assert false == one.covered?

      assert false == five.relevant?
      assert false == five.covered?
    end

    test """
    lines with a call_count 0 are marked relevent and not covered
    """, context do
      [_, two, three, _, _ | _tail] = context[:tagged]
      assert true == two.relevant?
      assert false == two.covered?

      assert true == three.relevant?
      assert false == three.covered?
    end

    test """
    lines with a call_count >0 are marked relevent and covered
    """, context do
      [_, _, _, four, _ | _tail] = context[:tagged]
      assert true == four.relevant?
      assert true == four.covered?
    end
  end

  describe "Module.lines/1" do
    test "returns list of Line structs" do
      assert [ %ExCov.Line{} | _tail] = Module.lines(Module.new(Module))
    end

    test "returns one Line struct for each line in source" do
      lines = Module.lines(Module.new(Module))
      source_line_count =
        Module.module_info(:compile)[:source]
        |> List.to_string
        |> File.read!
        |> String.split("\n")
        |> length

      assert (source_line_count - 1) == length(lines)
    end
  end

  describe "Module.call_counts/1" do
    test "returns map with line no. as key &  number of calls as value" do
      {:ok, Module} = :cover.compile_beam(Module)
      assert 0 == Map.get(Module.call_counts(Module), 0)

      # line zeros is
      Module.source_path Module.Test
      Module.source_path Module.Test
      Module.source_path Module.Test
      assert 5 == Map.get(Module.call_counts(Module), 0)
    end
  end

  describe "Module.source_path/1" do
    test "returns path of module" do
      path = Path.join([Project.root, "lib/excov/module.ex"])
      assert path == Module.source_path(Module)
      path = Path.join([Project.root, "test/excov/module_test.exs"])
      assert path == Module.source_path(Module.Test)
    end
  end

end
