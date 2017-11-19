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
      field :after, :string
    end

    def changeset(params \\ %{}) do
      params =
        params
        |> Map.put_new("limit", 50)
        |> Map.put_new("order", "inserted_at")

      %__MODULE__{}
      |> cast(params, [:limit, :order, :after])
    end
  end

  def index(conn, params) do
    params = IndexParams.changeset(params).changes

    order = String.to_existing_atom(params[:order])

    query = from p in Package,
      preload: [:versions],
      limit: ^params[:limit],
      order_by: [desc: ^order]

    query =
      if Map.has_key?(params, :after) do
        case decode_cursor(params[:after]) do
          {:ok, {_, value}} ->
            query |> where([p], field(p, ^order) < ^value)
          {:error, _} ->
            send_resp(conn, 500, "")
        end
      else
        query
      end

    packages = Repo.all(query)

    next_url =
      unless Enum.empty?(packages) do
        cursor = encode_cursor(order, List.last(packages) |> Map.get(order))
        next_params =
          params
          |> Enum.into(%{})
          |> Map.put(:after, cursor)

        url_with_params(conn, next_params)
      end


    info = %{
      total_results: Repo.one(from p in Package, select: count(p.id)),
      next_url: next_url,
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

  defp url_with_params(conn, params) do
    uri = %URI{
      scheme: Atom.to_string(conn.scheme),
      host: conn.host,
      port: conn.port,
      path: conn.request_path,
      query: URI.encode_query(params)
    }

    URI.to_string(uri)
  end
end
