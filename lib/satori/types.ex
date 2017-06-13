defmodule Satori.PDU.Types do
  defmacro __using__(_opts) do
    quote do
      #RTM Methods
      @publish "rtm/publish"
      @subscribe "rtm/subscribe"
      @unsubscribe "rtm/unsubscribe"
      @read "rtm/read"
      @write "rtm/write"
      @delete "rtm/delete"
      @subscription_info "rtm/subscription/info"
      @subscription_data "rtm/subscription/data"
      @data "rtm/channel/data"

      #RTM Success Results
      @publish_ok "rtm/publish/ok"
      @subscribe_ok "rtm/subscribe/ok"
      @unsubscribe_ok "rtm/unsubscribe/ok"
      @read_ok "rtm/read/ok"
      @delete_ok "rtm/delete/ok"
      @write_ok "rtm/write/ok"

      #RTM Error Results
      @publish_error "rtm/publish/error"
      @subscribe_error "rtm/subscribe/error"
      @unsubscribe_error "rtm/unsubscribe/error"
      @read_error "rtm/read/error"
      @write_error "rtm/write/error"
      @subscription_error "rtm/subscription/error"

      #Auth Methods
      @handshake "auth/handshake"
      @authenticate "auth/authenticate"

      #Auth Success Results
      @authenticate_ok "auth/authenticate/ok"
      @handshake_ok "auth/handshake/ok"

      #Auth Error Results
      @authenticate_error "auth/authenticate/error"
      @handshake_error "auth/handshake/error"
    end
  end
end
