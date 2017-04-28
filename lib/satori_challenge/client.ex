defmodule SatoriChallenge.Client do
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, pub} = SatoriChallenge.Publish.start_link("rosetta-home")
    {:ok, sub} = {:ok, 1}#SatoriChallenge.Subscription.start_link("transportation")
    Process.send_after(self(), :publish, 0)
    {:ok, %{pub: pub, sub: sub}}
  end

  def handle_info(:publish, state) do
    SatoriChallenge.Publish.publish(state.pub, %{measurement: "ieq.co2", val: 501.3433, tag: :ok})
    Process.send_after(self(), :publish, 5000)
    {:noreply, state}
  end

end
