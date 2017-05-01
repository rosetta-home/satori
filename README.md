# Satori Websocket Client

[Satori](https://www.satori.com/) is an open data portal that provides real-time data over encrypted websocket channels.

This is a client for subscribing and publishing to open data channels.

To publish you will need to create a data channel at [https://developer.satori.com](https://developer.satori.com)

Once registered you will be provided with an `App Key` and a `Role Secret`

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
11:56:07.587 [debug] Satori Registering: #PID<0.516.0>

11:56:07.588 [info]  URL: wss://open-data.api.satori.com?appkey=123123123123123123123123

11:56:07.588 [debug] Satori Client Opening URL: wss://open-data.api.satori.com?appkey=123123123123123123123123

11:56:07.866 [debug] Connected: %{parent: #PID<0.517.0>}

11:56:07.917 [debug] Handshake Successful: {"action":"auth/handshake/ok","id":"handshake","body":{"data":{"nonce":"sdf3423esda=="}}}

11:56:08.005 [debug] Authentication Successful: {"action":"auth/authenticate/ok","id":"authenticate","body":{}}

11:56:08.005 [debug] Publish: %{measurement: "ieq.co2", tag: :ok, val: 501.3433}

11:56:08.005 [debug] Dispatching: %Satori.PDU.Publish{channel: "rosetta-home", message: nil} - %Satori.PDU.Publish{channel: "rosetta-home", message: %{measurement: "ieq.co2", tag: :ok, val: 501.3433}}

11:56:08.005 [debug] Dispatched: %Satori.PDU.Publish{channel: "rosetta-home", message: %{measurement: "ieq.co2", tag: :ok, val: 501.3433}}
.
11:56:08.005 [debug] Satori Registering: #PID<0.520.0>

11:56:08.005 [debug] Satori Client Opening URL: wss://open-data.api.satori.com?appkey=123123123123123123123123

11:56:08.246 [debug] Connected: %{parent: #PID<0.521.0>}

11:56:08.521 [debug] Channel Data Received: %{parent: #PID<0.521.0>}

11:56:08.522 [debug] Dispatching: %Satori.PDU.Data{channel: "transportation", message: nil, messages: [], next: nil, position: nil, subscription_id: nil} - %Satori.PDU.Data{channel: "transportation", message: nil, messages: [%{"entity" => [%{"id" => "1493657760_0_1101", "is_deleted" => false, "vehicle" => %{"congestion_level" => 0, "current_status" => 0, "current_stop_sequence" => 0, "position" => %{"bearing" => 75.0, "latitude" => 33.874126, "longitude" => -117.88695, "odometer" => 0.0, "speed" => 0.0}, "timestamp" => 1493657754, "trip" => %{"route_id" => "57", "schedule_relationship" => 0, "start_date" => "20170501", "trip_id" => "5679859"}, "vehicle" => %{"id" => "1101", "label" => "1101"}}}], "header" => %{"gtfs_realtime_version" => "1.0", "timestamp" => 1493657760, "user-data" => "octa"}}], next: "1490808172:996901491", position: nil, subscription_id: nil}
```

## Use

The client uses Elixir's [Registry](https://hexdocs.pm/elixir/Registry.html#content) for event publishing. You can use pattern matching to register for only the events you are interested in. See the [test/satori_test.exs](test/satori_test.exs) for examples and also [satori_example application](https://github.com/NationalAssociationOfRealtors/satori_example) for a real world app.
