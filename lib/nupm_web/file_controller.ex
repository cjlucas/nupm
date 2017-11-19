defmodule NuPMWeb.FileController do
  use NuPMWeb, :controller

  alias NuPM.{Repo, Package, Version, Archive}

  @package_path Application.get_env(:nupm, :package_path)

  def download(conn, %{"name" => name, "version" => version}) do
    case Repo.get_version(name, version) do
      {:ok, %{upload_path: path}} ->
        fpath = Path.join(@package_path, path)

        attachment_name = "#{name}-#{Path.basename(fpath)}"

        conn
        |> put_resp_header("Content-Disposition", "attachment; filename=\"#{attachment_name}\"")
        |> send_file(200, fpath)
      {:error, :not_found} ->
        send_resp(conn, :not_found, "")
    end
  end

  def upload(conn, %{"file" => file}) do
    case Archive.extract(file.path) do
      {:ok, path} ->
        with {:ok, package_json_path} <- Archive.find_file(path, "package.json"),
             {:ok, package_json}      <- File.read(package_json_path),
             {:ok, metadata}          <- Poison.decode(package_json) do

          readme =
            with {:ok, path} <- Archive.find_file(path, "[Rr][Ee][Aa][Dd][Mm][Ee].[Mm][Dd]"),
                 {:ok, data} <- File.read(path), do: data


          {:ok, package} = Repo.create_or_get_package(metadata["name"])

          params =
            Version.from_package_json(metadata)
            |> Map.put(:package_id, package.id)
            |> Map.put(:readme, readme)


          upload_path = Path.join(package.title, params[:number] <> ".tar.gz")

          Version.changeset(%Version{}, Map.put(params, :upload_path, upload_path))
          |> Repo.insert

          outpath = Path.join(@package_path, upload_path)
          Path.dirname(outpath) |> File.mkdir_p!

          File.cp!(file.path, outpath)
          File.rm_rf!(path)

          send_resp(conn, 200, "")
        else
          _ ->
            send_resp(conn, 500, "Something went wrong")
        end
      {:error, _} ->
        send_resp(conn, 500, "Failed to extract archive")
    end
  end
end
