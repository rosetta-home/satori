defmodule SatoriChallenge.Publish do
  require Logger
  @behaviour :gen_fsm
  @role_secret System.get_env("SATORI_ROLE_SECRET")
  @states [:closed, :connecting, :connected, :handshake, :authenticating, :open]

  def start_link(role) do
    :gen_fsm.start_link(__MODULE__, role, [])
  end

  def publish(pid, data) do
    Logger.info "Publish: #{inspect data}"
    :gen_fsm.send_event(pid, {:publish, data})
  end

  def init(role) do
    Logger.info "Websocket opening"
    {:ok, client} = SatoriChallenge.PublishClient.start_link(self())
    {:ok, :connecting, %{messages: [], role: role, client: client}}
  end

  def closed({:publish, data}, state) do
    {:next_state, :closed, %{state | messages: [data | state.messages]}}
  end

  def connecting({:publish, data}, state) do
    {:next_state, :connecting, %{state | messages: [data | state.messages]}}
  end

  def connecting(:connected, state) do
    {:next_state, :connected, state}
  end

  def connected({:publish, data}, state) do
    {:next_state, :connected, %{state | messages: [data | state.messages]}}
  end

  def handshake({:publish, data}, state) do
    Logger.info "Handshake"
    {:next_state, :handshake, %{state | messages: [data | state.messages]}}
  end

  def authenticating({:publish, data}, state) do
    Logger.info "Authenticating"
    {:next_state, :authenticating, %{state | messages: [data | state.messages]}}
  end

  def open({:publish, data}, state) do
    Logger.info "Open: publishing"
    publish_message(state.role, data, state.client)
    {:next_state, :open, state}
  end

  def error({:publish, data}, state) do
    Logger.info("Error")
    {:next_state, :closed, state}
  end

  def handle_info(:connected, :connecting, state) do
    Logger.info "Connected: Sending Handshake: #{state.role} #{inspect state.client}"
    :websocket_client.cast(state.client, {:text, "{\"action\": \"auth/handshake\", \"id\": \"handshake\", \"body\":{\"method\":\"role_secret\", \"data\": {\"role\": \"#{state.role}\"}}}"})
    {:next_state, :connected, state}
  end

  def handle_info({:ws, msg}, current_state, state) do
    case msg |> Poison.decode! do
      %{"action" => "auth/handshake/ok"} = result ->
        Logger.info "Handshake Successful: #{inspect result}"
        hash =
          result
          |> get_in(["body", "data", "nonce"])
          |> md5_hash(@role_secret)
        :websocket_client.cast(state.client, {:text, "{\"action\": \"auth/authenticate\", \"id\":\"authenticate\", \"body\":{\"method\":\"role_secret\", \"credentials\": {\"hash\": \"#{hash}\"}}}"})
        {:next_state, :authenticating, state}
      %{"action" => "auth/authenticate/ok"} = result ->
        Logger.info "Authentication successful"
        state.messages |> Enum.each(fn m -> publish_message(state.role, m, state.client) end)
        {:next_state, :open, %{state | messages: []}}
      result ->
        {:next_state, current_state, state}
    end
  end

  def md5_hash(nonce, secret) do
    :crypto.hmac(:md5, secret, nonce)
  end

  def publish_message(channel, message, client) do
    :websocket_client.cast(client, {:text, "{\"action\": \"rtm/publish\", \"body\":{\"channel\":\"#{channel}\", \"message\": #{Poison.encode(message)}}}"})
  end
end
