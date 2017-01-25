defmodule ExCov.Project.Test do
  use ExUnit.Case

  alias ExCov.Project,    as: Project
  alias ExCov.Module,     as: Module
  alias ExCov.Statistics, as: Statistics

  doctest Project

  describe "Project.new/1" do
    test "returns a new Project struct" do
      assert %Project{} = Project.new
    end

    test """
    if no compile_path is provided, defaults to Mix.Project.compile_path
    """ do
      project = Project.new
      compile_path = Mix.Project.compile_path
      assert compile_path == project.compile_path
    end

    test "if compile_path option is provided, the provided value is used" do
      project = Project.new("hello")
      assert "hello" == project.compile_path
    end
  end

  describe "Project.compile_for_cover_analysis/1" do

    test "sets `cover_compiled?` to true " do
      project = Project.new
      assert false == project.cover_compiled?
      project = Project.compile_for_cover_analysis(project)
      assert true == project.cover_compiled?
    end

  end

  describe "root/0" do
    test "returns project root" do
      project_module_src_path_parts =
        ExCov.Project.module_info(:compile)[:source]
         |> List.to_string
         |> Path.split

      project_test_module_src_path_parts =
        ExCov.Project.Test.module_info(:compile)[:source]
         |> List.to_string
         |> Path.split

      # project root path is the path shared between
      # ExCov.Project and ExCov.Project.Test source files
      root_path =
        Enum.with_index(project_module_src_path_parts)
         |> Enum.split_while(fn({x, i}) ->
              x == Enum.at(project_test_module_src_path_parts, i)
            end)
         |> elem(0)
         |> Enum.map(fn({x,_}) -> x end)
         |> Path.join

      # assert if Project.root returns value as root_path
      assert Project.root == root_path
    end
  end

  describe "Project.collect_statistics/1" do
    setup do
      statistics =
        Project.collect_statistics([
          %Module{ name: Project, statistics: %{
            count_of_lines: 10,
            count_of_lines_relevant: 6,
            count_of_lines_covered: 3
          }},
          %Module{ name: Project, statistics: %{
            count_of_lines: 10,
            count_of_lines_relevant: 6,
            count_of_lines_covered: 3
          }},
          %Module{ name: Project, statistics: %{
            count_of_lines: 10,
            count_of_lines_relevant: 6,
            count_of_lines_covered: 3
          }},
        ])
      {:ok, [statistics: statistics]}
    end

    test "returns Statistics struct", context do
      assert %Statistics{} = context[:statistics]
    end

    test "count_of_lines is populated", context do
      assert 30 == context[:statistics].count_of_lines
    end

    test "count_of_lines_relevant is populated", context do
      assert 18 == context[:statistics].count_of_lines_relevant
    end

    test "count_of_lines_covered is populated", context do
      assert 9 == context[:statistics].count_of_lines_covered
    end

    test "count_of_lines_missed is populated", context do
      assert 9 == context[:statistics].count_of_lines_missed
    end

    test "percentage_of_relevant_lines_covered is populated", context do
      coverage = context[:statistics].percentage_of_relevant_lines_covered
      assert 50.0 == coverage
    end
  end

end
