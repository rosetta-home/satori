defmodule Satori.Client do
  use Satori.PDU.Types
  require Logger
  alias Satori.PDU

  def start_link(url, parent) do
    Logger.debug "Satori Client Opening URL: #{url}"
    :websocket_client.start_link(url, __MODULE__, parent)
  end

  def push(client, message, id \\ nil) do
    data = message |> encode(id)
    :websocket_client.cast(client, {:text, data})
    {:ok, data}
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

  #RTM Results

  def websocket_info(info, conn, state) do
    Logger.info "INFO: #{inspect info} - #{inspect conn}"
    {:reply, {:text, "ok"}, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@publish_ok}\"", rest :: binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.PublishOK{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@subscribe_ok}\"", rest :: binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.SubscribeOK{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@unsubscribe_ok}\"", rest :: binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.UnsubscribeOK{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@read_ok}\"", rest :: binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.ReadOK{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@write_ok}\"", rest :: binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.WriteOK{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@delete_ok}\"", rest :: binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.DeleteOK{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@data}\"", rest::binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.Data{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@subscription_data}\"", rest::binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.Data{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@subscription_info}\"", rest::binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.SubscriptionInfo{}})
    {:ok, state}
  end

  #Auth Results

  def websocket_handle({:text, <<"{\"action\":\"#{@handshake_ok}\"", rest :: binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.HandshakeOK{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@authenticate_ok}\"", rest::binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.AuthenticateOK{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@subscribe_ok}\"", rest::binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.AuthenticateOK{}})
    {:ok, state}
  end

  #Errors

  def websocket_handle({:text, <<"{\"action\":\"#{@publish_error}\"", rest::binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.PublishError{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@subscribe_error}\"", rest::binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.SubscribeError{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@unsubscribe_error}\"", rest::binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.UnsubscribeError{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@read_error}\"", rest::binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.ReadError{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@write_error}\"", rest::binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.WriteError{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@authenticate_error}\"", rest::binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.AuthenticateError{}})
    {:ok, state}
  end

  def websocket_handle({:text, <<"{\"action\":\"#{@handshake_error}\"", rest::binary >> = msg}, _conn, state) do
    msg |> parent_send(state.parent, %PDU{body: %PDU.HandshakeError{}})
    {:ok, state}
  end

  def websocket_handle({:text, msg}, _conn, state) do
    Logger.error "Unknown Message type: #{msg}"
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

  defp parent_send(msg, parent,  type) do
    parent |> send(msg |> Poison.decode!(as: type))
  end
end
