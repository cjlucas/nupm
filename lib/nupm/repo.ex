defmodule NuPM.Repo do
  use Ecto.Repo, otp_app: :nupm

  alias NuPM.{Package, Version}

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  def create_package(params \\ %{}) do
    Package.changeset(%Package{}, params) |> insert
  end
end
