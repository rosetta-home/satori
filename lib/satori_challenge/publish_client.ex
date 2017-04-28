defmodule SatoriChallenge.PublishClient do
  require Logger

  @url "wss://open-data.api.satori.com"
  @appkey System.get_env("SATORI_APP_KEY")

  def start_link(parent) do
    url = "#{@url}?appkey=#{@appkey}"
    Logger.info "Opening URL: #{url}"
    :websocket_client.start_link(url, __MODULE__, parent)
  end

  def init(parent) do
    Logger.info "Init: #{inspect parent}"
    {:once, %{parent: parent}}
  end

  def onconnect(_req, state) do
    Logger.info "Connected"
    state.parent |> send(:connected)
    {:ok, state}
  end

  def ondisconnect(reason, state) do
    Logger.info "Connection Closed: #{inspect reason}"
    {:reconnect, state}
  end

  def websocket_handle({:pong, _msg}, conn, state) do
    Logger.info("Received pong")
    # This is how to access info about the connection/request
    proto = :websocket_req.protocol(conn)
    Logger.info("On protocol: #{inspect proto}")
    {:ok, state}
  end

  def websocket_handle({:text, msg}, _conn, state) do
    Logger.info "Got Message: #{msg}"
    state.parent |> send({:ws, msg})
    {:ok, state}
  end

  def websocket_info(:start, _conn, state) do
    {:ok, state}
  end

  def websocket_terminate(reason, _conn, _state) do
    Logger.info("Websocket closed: #{inspect reason}")
    :ok
  end
end
