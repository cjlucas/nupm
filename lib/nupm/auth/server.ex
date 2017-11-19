defmodule NuPM.Auth.Server do
  use GenServer

  alias NuPM.User

  @moduledoc """
  A Server that maintains a list of active sessions for the REST API.
  """

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    tid = :ets.new(__MODULE__, [:set])
    {:ok, tid}
  end

  def login(%User{email: email, password_hash: hash}, password) do
    if Comeonin.Bcrypt.checkpw(password, hash) do
      GenServer.call(__MODULE__, {:add_token, email})
    else
      {:error, :bad_pass}
    end
  end

  @spec lookup(binary) :: boolean
  def lookup(token) do
    GenServer.call(__MODULE__, {:lookup_token, token})
  end

  def handle_call({:add_token, email}, _from, table) do
    token = UUID.uuid4()

    :ets.insert(table, {token, email})
    {:reply, {:ok, token}, table}
  end

  def handle_call({:lookup_token, token}, _from, table) do
    reply =
      case :ets.lookup(table, token) do
        {:error, _} ->
          false
        [] ->
          false
        _ ->
          true
      end

    {:reply, reply, table}
  end
end
