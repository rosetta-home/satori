defmodule Satori.PDU.Types do
  defmacro __using__(_opts) do
    quote do
      @publish "rtm/publish"
      @subscribe "rtm/subscribe"
      @unsubscribe "rtm/unsubscribe"
      @read "rtm/read"
      @write "rtm/write"
      @delete "rtm/delete"
      @handshake "auth/handshake"
      @authenticate "auth/authenticate"
      @authenticate_result "auth/authenticate/ok"
      @handshake_result "auth/handshake/ok"
      @subscribe_result "rtm/subscribe/ok"
      @data "rtm/channel/data"
    end
  end
end
