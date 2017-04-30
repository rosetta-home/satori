defmodule Satori.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      supervisor(Registry, [:duplicate, Satori.Registry, []]),
      worker(Satori.Registrar, [])
    ]

    opts = [strategy: :one_for_one, name: Satori.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
