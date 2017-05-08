defmodule Satori.PDU do
  use Satori.PDU.Types
  @derive [Poison.Encoder]
  defstruct action: nil,
    id: nil,
    body: %{}

  defmodule Result do
    @derive [Poison.Encoder]
    defstruct id: nil, action: nil, channel: nil
  end

  #Auth Sub-types

  defmodule Role do
    @derive [Poison.Encoder]
    defstruct role: nil
  end

  defmodule Credentials do
    @derive [Poison.Encoder]
    defstruct hash: nil
  end

  defmodule Nonce do
    @derive [Poison.Encoder]
    defstruct nonce: nil
  end

  #RTM Types
  defmodule Publish do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @publish
    defstruct channel: nil,
      message: nil
  end

  defmodule Subscribe do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @subscribe
    defstruct filter: nil,
      subscription_id: nil,
      channel: nil,
      force: nil,
      fast_forward: nil,
      period: nil,
      position: nil,
      history: nil
  end

  defmodule Unsubscribe do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @unsubscribe
    defstruct subscription_id: nil
  end

  defmodule Read do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @read
    defstruct channel: nil,
      position: nil
  end

  defmodule Write do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @write
    defstruct channel: nil,
      message: nil
  end

  defmodule Delete do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @delete
    defstruct channel: nil,
      purge: nil
  end

  #Auth types

  defmodule Handshake do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @handshake
    defstruct method: "role_secret",
      data: %Role{}
  end

  defmodule Authenticate do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @authenticate
    defstruct method: "role_secret",
      credentials: %Credentials{}

    def hash(data, key) do
      :crypto.hmac(:md5, key, data) |> Base.encode64
    end
  end

  #RTM Results

  defmodule PublishOK do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @publish_ok
    defstruct position: nil,
      next: nil
  end

  defmodule SubscribeOK do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @subscribe_ok
    defstruct position: nil,
      subscription_id: nil
  end

  defmodule UnsubscribeOK do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @unsubscribe_ok
    defstruct position: nil,
      subscription_id: nil
  end

  defmodule ReadOK do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @read_ok
    defstruct position: nil,
      message: nil
  end

  defmodule WriteOK do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @write_ok
    defstruct position: nil
  end

  defmodule DeleteOK do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @delete_ok
    defstruct position: nil
  end

  defmodule PublishError do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @publish_error
    defstruct error: nil,
      error_text: nil,
      reason: nil,
      subscription_id: nil,
      missed_message_count: nil,
      position: nil
  end

  defmodule SubscribeError do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @subscribe_error
    defstruct error: nil,
      error_text: nil,
      reason: nil,
      subscription_id: nil,
      missed_message_count: nil,
      position: nil
  end

  defmodule UnsubscribeError do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @unsubscribe_error
    defstruct error: nil,
      error_text: nil,
      reason: nil,
      subscription_id: nil,
      missed_message_count: nil,
      position: nil
  end

  defmodule ReadError do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @read_error
    defstruct error: nil,
      error_text: nil,
      reason: nil,
      subscription_id: nil,
      missed_message_count: nil,
      position: nil
  end

  defmodule WriteError do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @write_error
    defstruct error: nil,
      error_text: nil,
      reason: nil,
      subscription_id: nil,
      missed_message_count: nil,
      position: nil
  end

  defmodule DeleteError do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @delete_error
    defstruct error: nil,
      error_text: nil,
      reason: nil,
      subscription_id: nil,
      missed_message_count: nil,
      position: nil
  end

  defmodule SubscriptionInfo do
    @derive [Poison.Encoder]
    def action, do: @subscription_info
    defstruct info: nil,
      reason: nil,
      position: nil,
      subscription_id: nil,
      missed_message_count: nil
  end

  defmodule Data do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @data
    defstruct position: nil,
      next: nil,
      channel: nil,
      messages: [],
      message: nil,
      subscription_id: nil
  end

  #Auth Results
  defmodule AuthenticateOK do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @authenticate_ok
    defstruct other: nil
  end

  defmodule HandshakeOK do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @handshake_ok
    defstruct data: %Nonce{}
  end

  defmodule AuthenticateError do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @authenticate_error
    defstruct error: nil,
      error_text: nil,
      reason: nil,
      subscription_id: nil,
      missed_message_count: nil,
      position: nil
  end

  defmodule HandshakeError do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @handshake_error
    defstruct error: nil,
      error_text: nil,
      reason: nil,
      subscription_id: nil,
      missed_message_count: nil,
      position: nil
  end
end
