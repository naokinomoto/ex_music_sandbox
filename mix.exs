defmodule ExMusicSandbox.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_music_sandbox,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:exsc3, git: "https://github.com/naokinomoto/exsc3.git"}]
  end
end
