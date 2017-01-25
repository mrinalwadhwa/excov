defmodule ExCov.Mixfile do
  use Mix.Project

  def project do
    [app: :excov,
     version: "0.1.1",
     description: description(),
     deps: deps(),
     package: package()]
  end

  defp description do
    """
    Code Coverage Reports for Elixir code.
    """
  end

  defp deps do
    [{:ex_doc, "~> 0.14.5", only: :dev}]
  end

  defp package do
    [name: :excov,
     maintainers: ["Mrinal Wadhwa"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mrinalwadhwa/excov"}]
  end
end
