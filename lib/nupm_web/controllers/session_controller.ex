defmodule NuPMWeb.SessionController do
  use NuPMWeb, :controller

  alias NuPM.{Repo, User}

  def create(conn, _params) do
    with ["Basic " <> data] <- get_req_header(conn, "authorization"),
         {:ok, decoded} <- Base.decode64(data),
         [email, pass] <- String.split(decoded, ":", parts: 2) do
      case Repo.get_by(User, email: email) do
        nil ->
          send_resp(conn, 404, "")
        user ->
          case NuPM.Auth.Server.login(user, pass) do
          {:ok, token} ->
            render(conn, "show.json", user: user, token: token)
          {:error, _} ->
            send_resp(conn, 403, "")
          end
      end
    else
      _ ->
        send_resp(conn, 500, "")
    end
  end
end
