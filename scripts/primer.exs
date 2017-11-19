defmodule Primer do
  alias NuPM.{Repo, Package, Version, Archive}

  @root_packages [
    "express",
    "request",
    "react",
    "chalk",
    "async",
    "bluebird",
    "socket.io",
    "glob",
    "gulp",
    "babel",
    "yarn"
  ]

  @package_path Application.get_env(:nupm, :package_path)

  def prime(npm_cache_dir) do
    Enum.each(@root_packages, &prime_with_package(npm_cache_dir, MapSet.new, &1))
  end

  def prime_with_package(npm_cache_dir, primed_packages, package_name) do
    Path.join([npm_cache_dir, package_name, "*", "package.tgz"])
    |> Path.wildcard
    |> Enum.each(fn fpath ->
      with {:ok, package_path}      <- Archive.extract(fpath),
           {:ok, package_json_path} <- Archive.find_file(package_path, "package.json"),
           {:ok, package_json}      <- File.read(package_json_path),
           {:ok, metadata}          <- Poison.decode(package_json),
           {:ok, package}           <- create_or_get_package(package_name) do

        readme =
          case Archive.find_file(package_path, "[Rr][Ee][Aa][Dd][Mm][Ee].[Mm][Dd]") do
            {:ok, readme_path} ->
              case File.read(readme_path) do
                {:ok, data} -> data
                {:error, _} -> nil
              end
            :error ->
              nil
          end

        params =
          Version.from_package_json(metadata)
          |> Map.put(:package_id, package.id)
          |> Map.put(:readme, readme)

        upload_path = Path.join(package.title, params[:number] <> ".tar.gz")

        Version.changeset(%Version{}, Map.put(params, :upload_path, upload_path))
        |> Repo.insert

        outpath = Path.join(@package_path, upload_path)
        Path.dirname(outpath) |> File.mkdir_p!

        File.cp!(fpath, outpath)

        File.rm_rf!(package_path)

        deps =
          Map.get(metadata, "dependencies", %{})
          |> Map.keys
          |> MapSet.new

        MapSet.difference(deps, primed_packages)
        |> Enum.each(&prime_with_package(npm_cache_dir, MapSet.put(primed_packages, package_name), &1))
      end
    end)
  end

  def create_or_get_package(package_name) do
    case Repo.get_by(Package, title: package_name) do
      nil ->
        cs = Package.changeset(%Package{}, %{title: package_name})
        Repo.insert(cs)
      package ->
        {:ok, package}
    end
  end

  @doc """
  Find a file matching the given pattern somewhere in the given package_path.
  """
  defp find_package_file(package_path, pattern) do
    case Path.join([package_path, "**", pattern]) |> Path.wildcard do
      [] ->
        :error
      files ->
        {:ok, List.first(files)}
    end
  end
end

System.user_home |> Path.join(".npm") |> Primer.prime
