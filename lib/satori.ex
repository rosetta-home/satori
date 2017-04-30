defmodule Satori do
  require Logger

  def register(type), do: Satori.Registrar.register(type)

  def dispatch(type, event) do
    Logger.debug "Dispatching: #{inspect type} - #{inspect event}"
    case Registry.lookup(Satori.Registry, type) do
      [] -> Logger.debug "No Registrations for #{inspect type}"
      _ ->
        Registry.dispatch(Satori.Registry, type, fn entries ->
          for {_module, pid} <- entries, do: send(pid, event)
        end)
    end
    Logger.debug "Dispatched: #{inspect event}"
    event
  end
end
