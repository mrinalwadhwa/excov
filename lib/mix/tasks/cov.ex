defmodule Mix.Tasks.Cov do
  use Mix.Task

  @shortdoc "Show code coverage report"
  def run(_) do
    ExCov.run(console_printer: &Mix.shell.info/1)
  end
end
