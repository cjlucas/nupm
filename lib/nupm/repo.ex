defmodule NuPM.Repo do
  use Ecto.Repo, otp_app: :nupm

  alias NuPM.{Package, Version}
  import Ecto.Query, except: [preload: 2]

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  @doc """
  Create a package with the given parameters.
  """
  def create_package(params \\ %{}) do
    Package.changeset(%Package{}, params) |> insert
  end

  @doc """
  Create a package, or return an existing package if it already exists.
  """
  def create_or_get_package(package_name) do
    case get_by(Package, title: package_name) do
      nil ->
        create_package(%{title: package_name})
      package ->
        {:ok, package}
    end
  end

  @doc """
  Create a version with the given parameters.
  """
  def create_version(params \\ %{}) do
    Version.changeset(%Version{}, params) |> insert
  end

  @doc """
  Convience function for getting a specific version of a package.
  """
  @spec get_version(binary, binary) :: {:ok, Version.t} | {:error, term}
  def get_version(package_name, version_number) do
    case get_by(Package, title: package_name) do
      %Package{id: package_id} = package ->
        case get_by(Version, package_id: package_id, number: version_number) do
          nil ->
            {:error, :not_found}
          version ->
            {:ok, preload(version, :package)}
        end
      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Convience function for getting the latest version of a package.
  """
  @spec get_latest_version(binary) :: {:ok, Version.t} | {:error, term}
  def get_latest_version(package_name) do
    case get_by(Package, title: package_name) do
      %Package{id: package_id} = package ->
        query = from v in Version,
          select: v.number,
          where: v.package_id == ^package_id,
          order_by: [desc: v.inserted_at],
          limit: 1

        case all(query) do
          nil ->
            {:error, :not_found}
          [version_number] ->
            get_version(package_name, version_number)
        end
      nil ->
        {:error, :not_found}
    end
  end
end
