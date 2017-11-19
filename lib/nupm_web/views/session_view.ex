defmodule NuPMWeb.SessionView do
  use NuPMWeb, :view

  def render("show.json", %{user: user, token: token}) do
    user
    |> Map.take([:email])
    |> Map.put(:token, token)
  end
end
