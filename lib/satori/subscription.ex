defmodule Satori.Subscription do
  use GenServer
  alias Satori.PDU
  require Logger

  def start_link(url, channel) do
    GenServer.start_link(__MODULE__, {url, channel}, [])
  end

  def init({url, channel}) do
    {:ok, pid} = Satori.Client.start_link(url, self())
    {:ok, %{channel: channel, client: pid}}
  end

  def handle_info(:connected, state) do
    Satori.Client.push(state.client, %PDU.Subscribe{channel: state.channel})
    {:noreply, state}
  end

  def handle_info(:disconnected, state) do
    {:noreply, state}
  end

  def handle_info(%PDU{body: %PDU.Data{}} = msg, state) do
    Satori.dispatch(%PDU.Data{channel: state.channel}, msg.body)
    {:noreply, state}
  end
end
