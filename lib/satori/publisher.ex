defmodule Satori.Publisher do
  require Logger
  alias Satori.PDU
  @behaviour :gen_fsm
  @states [:closed, :connecting, :connected, :handshake, :authenticating, :open]

  def start_link(url, role, secret) do
    :gen_fsm.start_link(__MODULE__, {url, role, secret}, [])
  end

  def publish(pid, msg, id \\ nil) do
    :gen_fsm.send_event(pid, {:publish, {msg, id}})
  end

  def read(pid, position, id \\ nil) do
    :gen_fsm.send_event(pid, {:read, {position, id}})
  end

  def delete(pid, id \\ nil) do
    :gen_fsm.send_event(pid, {:delete, id})
  end

  def init({url, role, secret}) do
    {:ok, client} = Satori.Client.start_link(url, self())
    {:ok, :connecting, %{messages: [], role: role, secret: secret, client: client}}
  end

  def closed(data, state) do
    {:next_state, :closed, %{state | messages: [data | state.messages]}}
  end

  def connecting(data, state) do
    {:next_state, :connecting, %{state | messages: [data | state.messages]}}
  end

  def connecting(:disconnected, state) do
    {:next_state, :disconnected, state}
  end

  def connecting(:connected, state) do
    {:next_state, :connected, state}
  end

  def disconnected(data, state) do
    {:next_state, :disconnected, %{state | messages: [data | state.messages]}}
  end

  def connected(data, state) do
    {:next_state, :connected, %{state | messages: [data | state.messages]}}
  end

  def handshake(data, state) do
    {:next_state, :handshake, %{state | messages: [data | state.messages]}}
  end

  def authenticating(data, state) do
    {:next_state, :authenticating, %{state | messages: [data | state.messages]}}
  end

  def open(data, state) do
    state.client |> handle_msg(state.role, data)
    {:next_state, :open, state}
  end

  def error({:publish, data}, state) do
    {:next_state, :closed, state}
  end

  def handle_info(:connected, :connecting, state) do
    Satori.Client.push(state.client, %PDU.Handshake{data: %{role: state.role}}, "handshake")
    {:next_state, :handshake, state}
  end

  def handle_info(:disconnected, _any, state) do
    {:next_state, :closed, state}
  end

  def handle_info(%PDU{body: %PDU.HandshakeOK{}} = result, :handshake, state) do
    hash =
      result
      |> Map.get(:body)
      |> Map.get(:data)
      |> Map.get(:nonce)
      |> PDU.Authenticate.hash(state.secret)
    authenticate = %PDU.Authenticate{credentials: %{hash: hash}}
    Satori.Client.push(state.client, authenticate, "authenticate")
    {:next_state, :authenticating, state}
  end

  def handle_info(%PDU{body: %PDU.AuthenticateOK{}}, :authenticating, state) do
    state.messages |> Enum.each(fn m -> state.client |> handle_msg(state.role, m) end)
    {:next_state, :open, %{state | messages: []}}
  end

  def handle_info(other, current_state, state) do
    Satori.dispatch(%PDU.Result{id: other.id, action: other.action, channel: state.role}, other)
    {:next_state, current_state, state}
  end

  defp handle_msg(client, role, {:publish, {msg, id}}) do
    Logger.debug "Publish: #{inspect msg}"
    data = %PDU.Publish{channel: role, message: msg}
    {:ok, sent} = client |> Satori.Client.push(data, id)
    Satori.dispatch(%PDU.Publish{channel: role}, data)
  end

  defp handle_msg(client, role, {:read, {position, id}}) do
    Logger.debug "Read: #{position}"
    data = %PDU.Read{channel: role, position: position}
    {:ok, sent} = client |> Satori.Client.push(data, id)
    Satori.dispatch(%PDU.Read{channel: role}, data)
  end

  defp handle_msg(client, role, {:delete, id}) do
    Logger.debug("Delete: #{role}")
    data = %PDU.Delete{channel: role}
    {:ok, sent} = client |> Satori.Client.push(data, id)
    Satori.dispatch(%PDU.Delete{channel: role}, data)
  end
end
