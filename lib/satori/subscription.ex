defmodule Satori.Subscription do
  use GenServer
  alias Satori.PDU
  require Logger

  def start_link(url, channel, id \\ nil) do
    GenServer.start_link(__MODULE__, {url, channel, id}, [])
  end

  def unsubscribe(client, subscription_id, id \\ nil) do
    GenServer.cast(client, {:unsubscribe, subscription_id, id})
  end

  def init({url, channel, id}) do
    {:ok, pid} = Satori.Client.start_link(url, self())
    {:ok, %{channel: channel, client: pid, id: id}}
  end

  def handle_cast({:unsubscribe, subscription_id, id}, state) do
    {:ok, sent} = Satori.Client.push(state.client, %PDU.Unsubscribe{subscription_id: subscription_id}, id)
    Satori.dispatch(%PDU.Unsubscribe{subscription_id: subscription_id}, sent)
    {:noreply, state}
  end

  def handle_info(:connected, state) do
    {:ok, sent} = Satori.Client.push(state.client, %PDU.Subscribe{channel: state.channel}, state.id)
    Satori.dispatch(%PDU{id: state.id, body: %PDU.Subscribe{channel: state.channel}}, sent)
    {:noreply, state}
  end

  def handle_info(:disconnected, state) do
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Satori.dispatch(%PDU.Result{id: msg.id, action: msg.action, channel: state.channel}, msg)
    {:noreply, state}
  end
end
