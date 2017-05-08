defmodule Satori do
  require Logger

  def register(type), do: Satori.Registrar.register(type)

  def dispatch(type, event) do
    case Registry.lookup(Satori.Registry, type) do
      [] -> Logger.debug "No Registrations for #{inspect type}"
      _ ->
        Logger.debug "Dispatching: #{inspect type} - #{inspect event}"
        Registry.dispatch(Satori.Registry, type, fn entries ->
          for {_module, pid} <- entries, do: send(pid, event)
        end)
        Logger.debug "Dispatched: #{inspect event}"
    end
    event
  end
end
