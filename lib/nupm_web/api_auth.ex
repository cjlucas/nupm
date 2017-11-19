defmodule NuPMWeb.APIAuth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
          true                <- NuPM.Auth.Server.lookup(token) do
        put_private(conn, :authorized, true)
      else
        _ ->
          conn |> send_resp(403, "") |> halt
      end
  end
end
