defmodule Satori.Registrar do
  use GenServer
  require Logger

  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def register(type), do: GenServer.call(__MODULE__, {:register, type})

  def init(:ok), do: {:ok, %{}}

  def handle_call({:register, type}, {pid, _ref}, state) do
    Logger.debug "Satori Registering: #{inspect type} for #{inspect pid}"
    Satori.Registry |> Registry.register(type, pid)
    {:reply, :ok, state}
  end
end
