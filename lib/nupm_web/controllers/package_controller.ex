defmodule NuPMWeb.PackageController do
  use NuPMWeb, :controller

  alias NuPM.{Repo, Package, Version}
  import Ecto.Query

  defmodule IndexParams do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :limit, :integer
      field :order, :string
    end

    def changeset(params \\ %{}) do
      params =
        params
        |> Map.put_new("limit", 50)
        |> Map.put_new("order", "inserted_at")

      %__MODULE__{}
      |> cast(params, [:limit, :order])
    end
  end

  def index(conn, params) do
    params = IndexParams.changeset.changes

    order = String.to_existing_atom(params[:order])

    query = from p in Package,
      preload: [:versions],
      limit: ^params[:limit],
      order_by: [desc: ^order]

    packages = Repo.all(query)
    info = %{
      cursor: encode_cursor(order, List.last(packages) |> Map.get(order))
    }

    render conn, "page.json", packages: packages, page_info: info
  end

  def show(conn, %{"name" => name}) do
    case Repo.get_by(Package, title: name) |> Repo.preload(:versions) do
      nil ->
        send_resp conn, :not_found, ""
      package ->
        render conn, "show.json", package: package
    end
  end

  defp encode_cursor(key, value) do
    value =
      case value do
        %NaiveDateTime{} ->
          NaiveDateTime.to_iso8601(value)
        value when is_integer(value) ->
          Integer.to_string(value)
        value when is_float(value) ->
          Float.to_string(value)
        _ ->
          value
        end

    Base.encode64("#{key}:#{value}")
  end

  defp decode_cursor(cursor) do
    case Base.decode64(cursor) do
      {:ok, cursor} ->
        [key, value] = String.split(cursor, ":", parts: 2)
        case key do
          "inserted_at" ->
            {:ok, {:inserted_at, NaiveDateTime.from_iso8601!(value)}}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end
end
