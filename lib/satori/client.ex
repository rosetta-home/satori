defmodule Satori.Client do
  use Satori.PDU.Types
  require Logger
  alias Satori.PDU


  def start_link(url, parent) do
    Logger.debug "Satori Client Opening URL: #{url}"
    :websocket_client.start_link(url, __MODULE__, parent)
  end

  def push(client, message, id \\ nil) do
    :websocket_client.cast(client, {:text, message |> encode(id)})
  end

  def encode(msg, id) do
    %PDU{action: msg.__struct__.action(), body: msg, id: id}
    |> Poison.encode!
  end

  def init(parent) do
    {:once, %{parent: parent}}
  end

  def onconnect(_req, state) do
    Logger.debug "Connected: #{inspect state}"
    state.parent |> send(:connected)
    {:ok, state}
  end

  def ondisconnect(reason, state) do
    Logger.debug "Disconnected: #{inspect state}"
    state.parent |> send(:disconnected)
    {:reconnect, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@handshake_result}\"", rest :: binary >> = msg}, _conn, state) do
    Logger.debug("Handshake Successful: #{msg}")
    state.parent |> send(msg |> Poison.decode!(as: %PDU{body: %PDU.HandshakeResult{}}))
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@authenticate_result}\"", rest::binary >> = msg}, _conn, state) do
    Logger.debug("Authentication Successful: #{msg}")
    state.parent |> send(msg |> Poison.decode!(as: %PDU{body: %PDU.AuthenticateResult{}}))
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@data}\"", rest::binary >> = msg}, _conn, state) do
    Logger.debug("Channel Data Received: #{inspect state}")
    state.parent |> send(msg |> Poison.decode!(as: %PDU{body: %PDU.Data{}}))
    {:ok, state}
  end

  def websocket_handle({:text, msg}, _conn, state) do
    Logger.debug "Got Other message: #{msg}"
    state.parent |> send(msg |> Poison.decode!)
    {:ok, state}
  end

  def websocket_handle({:pong, _msg}, conn, state) do
    {:ok, state}
  end

  def websocket_handle(other, _conn, state) do
    {:ok, state}
  end

  def websocket_terminate(reason, _conn, _state) do
    Logger.debug("Websocket closed: #{inspect reason}")
    :ok
  end
end
