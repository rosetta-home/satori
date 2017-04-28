defmodule SatoriChallenge.Subscription do
  require Logger

  @url "wss://open-data.api.satori.com"
  @appkey System.get_env("SATORI_APP_KEY")

  def start_link(channel) do
    url = "#{@url}?appkey=#{@appkey}"
    Logger.info url
    :websocket_client.start_link(url, __MODULE__, channel)
  end

  def init(channel) do
    {:once, %{channel: channel}}
  end

  def onconnect(_req, state) do
    :websocket_client.cast(self(), {:text, "{\"action\":\"rtm/subscribe\",\"body\":{\"channel\":\"#{state.channel}\"}}"})
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
    Logger.info("Received msg: #{inspect msg}")
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
