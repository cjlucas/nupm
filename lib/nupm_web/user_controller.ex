defmodule NuPMWeb.UserController do
  use NuPMWeb, :controller

  alias NuPM.{Repo, User}

  def create(conn, params) do
    case User.changeset(%User{}, params) |> Repo.insert do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, _} ->
        send_resp(conn, 500, "")
    end
  end
end
