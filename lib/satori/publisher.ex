defmodule Satori.Publisher do
  require Logger
  alias Satori.PDU
  @behaviour :gen_fsm
  @states [:closed, :connecting, :connected, :handshake, :authenticating, :open]

  def start_link(url, role, secret) do
    :gen_fsm.start_link(__MODULE__, {url, role, secret}, [])
  end

  def publish(pid, data) do
    :gen_fsm.send_event(pid, {:publish, data})
  end

  def init({url, role, secret}) do
    {:ok, client} = Satori.Client.start_link(url, self())
    {:ok, :connecting, %{messages: [], role: role, secret: secret, client: client}}
  end

  def closed({:publish, data}, state) do
    {:next_state, :closed, %{state | messages: [data | state.messages]}}
  end

  def connecting({:publish, data}, state) do
    {:next_state, :connecting, %{state | messages: [data | state.messages]}}
  end

  def connecting(:disconnected, state) do
    {:next_state, :disconnected, state}
  end

  def connecting(:connected, state) do
    {:next_state, :connected, state}
  end

  def disconnected({:publish, data}, state) do
    {:next_state, :disconnected, %{state | messages: [data | state.messages]}}
  end

  def connected({:publish, data}, state) do
    {:next_state, :connected, %{state | messages: [data | state.messages]}}
  end

  def handshake({:publish, data}, state) do
    {:next_state, :handshake, %{state | messages: [data | state.messages]}}
  end

  def authenticating({:publish, data}, state) do
    {:next_state, :authenticating, %{state | messages: [data | state.messages]}}
  end

  def open({:publish, data}, state) do
    state.client |> publish_msg(state.role, data)
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

  def handle_info(%PDU{body: %PDU.HandshakeResult{}} = result, :handshake, state) do
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

  def handle_info(%PDU{body: %PDU.AuthenticateResult{}}, :authenticating, state) do
    state.messages |> Enum.each(fn m -> state.client |> publish_msg(state.role, m) end)
    {:next_state, :open, %{state | messages: []}}
  end

  def handle_info(other, current_state, state) do
    Logger.debug "Other: #{inspect other}"
    {:next_state, current_state, state}
  end

  defp publish_msg(client, role, msg) do
    Logger.debug "Publish: #{inspect msg}"
    data = %PDU.Publish{channel: role, message: msg}
    client |> Satori.Client.push(data)
    Satori.dispatch(Publisher, data)
  end
end
