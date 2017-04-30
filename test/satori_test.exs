defmodule SatoriTest do
  use ExUnit.Case
  alias Satori.PDU
  require Logger
  doctest Satori

  @role "rosetta-home"
  @channel "transportation"

  test "publisher" do
    #Register for events
    Satori.register(%PDU.Publish{channel: @role})
    data = %{measurement: "ieq.co2", val: 501.3433, tag: :ok}
    url = "#{Application.get_env(:satori, :url)}?appkey=#{Application.get_env(:satori, :app_key)}"
    Logger.info "URL: #{url}"
    {:ok, pub} = Satori.Publisher.start_link(url, @role, Application.get_env(:satori, :role_secret))
    Satori.Publisher.publish(pub, data)
    assert_receive %PDU.Publish{channel: @role, message: data}, 20_000
  end

  test "subscription" do
    url = "#{Application.get_env(:satori, :url)}?appkey=#{Application.get_env(:satori, :app_key)}"
    Satori.register(%PDU.Data{channel: @channel})
    {:ok, sub} = Satori.Subscription.start_link(url, "transportation")
    assert_receive %PDU.Data{channel: @channel}, 20_000
  end
end
