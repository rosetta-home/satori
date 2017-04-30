defmodule Satori.PDU do
  use Satori.PDU.Types
  @derive [Poison.Encoder]
  defstruct action: nil,
    id: nil,
    body: %{}

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

  defmodule AuthenticateResult do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @authenticate_result
    defstruct other: nil
  end

  defmodule HandshakeResult do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @handshake_result
    defstruct data: %Nonce{}
  end

  defmodule SubscribeResult do
    use Satori.PDU.Types
    @derive [Poison.Encoder]
    def action, do: @subscribe_result
    defstruct position: nil,
      subscription_id: nil
  end

  defmodule Error do
    @derive [Poison.Encoder]
    defstruct error: nil,
      reason: nil,
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

  defmodule Info do
    @derive [Poison.Encoder]
    defstruct info: nil,
      reason: nil,
      position: nil,
      subscription_id: nil,
      missed_message_count: nil
  end
end
