# Satori Websocket Client

[Satori](https://www.satori.com/) is an open data portal that provides real-time data over encrypted websocket channels.

This is a client for subscribing and publishing to open data channels.

To publish you will need to create a data channel at [https://developer.satori.com](https://developer.satori.com)

Once registered you will be provided with an `App Key` and a `Role Secret`

To check out a real-world example see [satori_example application](https://github.com/NationalAssociationOfRealtors/satori_example).

## Configuration

Start by setting your environment variables

$ `cp default.env .env`

add your key and secret to their respective variables in the `.env` file.

You can also override these variables in your `config.exs` file, by default, the config file looks for the environment variables.

$ `source .env`

$ `mix deps.get`

$ `mix test`

If everything is configured correctly, you should see something resembling the following.

```
15:02:20.841 [debug] Satori Registering Event Type: %Satori.PDU.Result{action: "rtm/subscribe/ok", channel: "transportation", id: "sub-id"} for #PID<0.186.0>

15:02:20.841 [debug] Satori Registering Event Type: %Satori.PDU.Result{action: "rtm/channel/data", channel: "transportation", id: nil} for #PID<0.186.0>

15:02:20.841 [debug] Satori Client Opening URL: wss://open-data.api.satori.com?appkey=103873948793874593745sdfsdf

15:02:21.106 [debug] Connected: %{parent: #PID<0.187.0>}

15:02:21.111 [debug] No Registrations for %Satori.PDU{action: nil, body: %Satori.PDU.Subscribe{channel: "transportation", fast_forward: nil, filter: nil, force: nil, history: nil, period: nil, position: nil, subscription_id: nil}, id: "sub-id"}

15:02:21.181 [debug] Dispatching: %Satori.PDU.Result{action: "rtm/subscribe/ok", channel: "transportation", id: "sub-id"} - %Satori.PDU{action: "rtm/subscribe/ok", body: %Satori.PDU.SubscribeOK{position: nil, subscription_id: nil}, id: "sub-id"}

15:02:21.181 [debug] Dispatched: %Satori.PDU{action: "rtm/subscribe/ok", body: %Satori.PDU.SubscribeOK{position: nil, subscription_id: nil}, id: "sub-id"}

15:02:21.304 [debug] Dispatching: %Satori.PDU.Result{action: "rtm/channel/data", channel: "transportation", id: nil} - %Satori.PDU{action: "rtm/channel/data", body: %Satori.PDU.Data{channel: "transportation", message: nil, messages: [%{"entity" => [%{"id" => "1494273733_0_2215", "is_deleted" => false, "vehicle" => %{"congestion_level" => 0, "current_status" => 0, "current_stop_sequence" => 0, "position" => %{"bearing" => 90.0, "latitude" => 33.738174, "longitude" => -117.91528, "odometer" => 0.0, "speed" => 0.0}, "timestamp" => 1494273703, "trip" => %{"route_id" => "66", "schedule_relationship" => 0, "start_date" => "20170508", "trip_id" => "5709151"}, "vehicle" => %{"id" => "2215", "label" => "2215"}}}], "header" => %{"gtfs_realtime_version" => "1.0", "timestamp" => 1494273733, "user-data" => "octa"}}], next: "1490808172:1229854301", position: nil, subscription_id: nil}, id: nil}
.
15:02:21.304 [debug] Satori Registering Event Type: %Satori.PDU.Result{action: "rtm/publish/ok", channel: "rosetta-home", id: "publish-id"} for #PID<0.190.0>

15:02:21.305 [debug] Satori Client Opening URL: wss://open-data.api.satori.com?appkey=103873948793874593745sdfsdf

15:02:21.617 [debug] Connected: %{parent: #PID<0.191.0>}

15:02:21.809 [debug] Publish: %{measurement: "ieq.co2", tag: :ok, val: 501.3433}

15:02:21.811 [debug] No Registrations for %Satori.PDU.Publish{channel: "rosetta-home", message: nil}

15:02:21.866 [debug] Dispatching: %Satori.PDU.Result{action: "rtm/publish/ok", channel: "rosetta-home", id: "publish-id"} - %Satori.PDU{action: "rtm/publish/ok", body: %Satori.PDU.PublishOK{next: "1494268255:29", position: nil}, id: "publish-id"}

15:02:21.866 [debug] Dispatched: %Satori.PDU{action: "rtm/publish/ok", body: %Satori.PDU.PublishOK{next: "1494268255:29", position: nil}, id: "publish-id"}
.
15:02:21.866 [debug] Satori Registering Event Type: %Satori.PDU.Result{action: "auth/authenticate/error", channel: "transportation", id: "authenticate"} for #PID<0.194.0>

15:02:21.867 [debug] Satori Client Opening URL: wss://open-data.api.satori.com?appkey=2a4857cBCc0ebcBeAbfAE9DdcA635De4

15:02:22.118 [debug] Connected: %{parent: #PID<0.195.0>}

15:02:22.255 [debug] Dispatching: %Satori.PDU.Result{action: "auth/authenticate/error", channel: "transportation", id: "authenticate"} - %Satori.PDU{action: "auth/authenticate/error", body: %Satori.PDU.AuthenticateError{error: "authentication_failed", error_text: "Unauthenticated", missed_message_count: nil, position: nil, reason: nil, subscription_id: nil}, id: "authenticate"}

15:02:22.256 [debug] Dispatched: %Satori.PDU{action: "auth/authenticate/error", body: %Satori.PDU.AuthenticateError{error: "authentication_failed", error_text: "Unauthenticated", missed_message_count: nil, position: nil, reason: nil, subscription_id: nil}, id: "authenticate"}
```

## Use

The client uses Elixir's [Registry](https://hexdocs.pm/elixir/Registry.html#content) for event publishing. You can use pattern matching to register for only the events you are interested in. See the [test/satori_test.exs](test/satori_test.exs) for examples and also [satori_example application](https://github.com/NationalAssociationOfRealtors/satori_example) for a real world app.

By default, Satori only responds/acks messages that include an id field. The authentication flow has to use id's in order to get results back. However, in general, unless you are very interested in the result of a publish, it's most likely not worth the overhead of requiring an ack. The library defaults to no-ack unless an id is specifically passed to the function.
