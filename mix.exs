defmodule ExCov.Mixfile do
  use Mix.Project

  def project do
    [app: :excov,
     version: "0.0.0",
     test_coverage: [tool: ExCov],
     description: description(),
     deps: deps(),
     package: package()]
  end

  defp description do
    """
    Simple Test Coverage Reports for Elixir Code
    """
  end

  defp deps do
    [{:ex_doc, "~> 0.14.5", only: :dev},
     {:cmark, "~> 0.6.10", only: :dev}]
  end

  defp package do
    [name: :excov,
     maintainers: ["Mrinal Wadhwa"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mrinalwadhwa/excov"}]
  end
end
