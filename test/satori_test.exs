defmodule SatoriTest do
  use ExUnit.Case
  alias Satori.PDU
  require Logger

  doctest Satori

  @role "rosetta-home"
  @channel "transportation"
  @publish_id "publish-id"
  @sub_id "sub-id"

  test "publisher" do
    url = "#{Application.get_env(:satori, :url)}?appkey=#{Application.get_env(:satori, :app_key)}"
    Satori.register(%PDU.Result{id: @publish_id, action: PDU.PublishOK.action(), channel: @role})
    {:ok, pub} = Satori.Publisher.start_link(url, @role, Application.get_env(:satori, :role_secret))
    data = %{measurement: "ieq.co2", val: 501.3433, tag: :ok}
    Satori.Publisher.publish(pub, data, @publish_id)
    assert_receive %PDU{body: %PDU.PublishOK{}}, 5_000
  end

  test "publisher no ack" do
    url = "#{Application.get_env(:satori, :url)}?appkey=#{Application.get_env(:satori, :app_key)}"
    Satori.register(%PDU.Publish{channel: @role}) #this doesn't actually get an ack from Satori, just that the library sent the message.
    {:ok, pub} = Satori.Publisher.start_link(url, @role, Application.get_env(:satori, :role_secret))
    data = %{measurement: "ieq.co2", val: 501.3433, tag: :ok}
    Satori.Publisher.publish(pub, data)
    #this doesn't actually get an ack from Satori, just that the library sent the message.
    assert_receive %PDU.Publish{channel: @role}, 10_000
  end

  test "subscription" do
    url = "#{Application.get_env(:satori, :url)}?appkey=#{Application.get_env(:satori, :app_key)}"
    Satori.register(%PDU.Result{id: @sub_id, action: PDU.SubscribeOK.action(), channel: @channel})
    Satori.register(%PDU.Result{action: PDU.Data.action(), channel: @channel})

    {:ok, sub} = Satori.Subscription.start_link(url, @channel, @sub_id)
    assert_receive %PDU{id: @sub_id, body: %PDU.SubscribeOK{}}, 5_000
    assert_receive %PDU{body: %PDU.Data{}}, 5_000
  end

  test "authentication error" do
    url = "#{Application.get_env(:satori, :url)}?appkey=#{Application.get_env(:satori, :app_key)}"
    Satori.register(%PDU.Result{id: "authenticate", action: PDU.AuthenticateError.action(), channel: @channel})
    {:ok, pub} = Satori.Publisher.start_link(url, @channel, Application.get_env(:satori, :role_secret))
    data = %{measurement: "ieq.co2", val: 501.3433, tag: :ok}
    Satori.Publisher.publish(pub, data, @publish_id)
    assert_receive %PDU{body: %PDU.AuthenticateError{}}, 5_000
  end
end
