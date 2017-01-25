defmodule Mix.Tasks.Cov.Detail do
  use Mix.Task

  @shortdoc "Show code coverage report with details"
  def run(_) do
    ExCov.run(show_detail?: true, console_printer: &Mix.shell.info/1)
  end
end
