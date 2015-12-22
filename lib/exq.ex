defmodule Exq do
  require Logger
  alias Exq.Support.Config
  use Application

  # OTP Application
  def start(_type, _args) do
    Application.get_all_env(:exq)
    |> Config.build
    |> Exq.Supervisor.start_link
  end

  # Exq methods

  def start(config, opts \\ []) do
    start_link(config, opts)
  end

  def start_link(config, opts \\ []) do
    config
    |> Config.build
    |> Exq.Supervisor.start_link(opts)
  end

  def enqueue(pid, queue, worker, args) do
    GenServer.call(pid, {:enqueue, queue, worker, args}, Config.get(:genserver_timeout, 5000))
  end

  def enqueue_at(pid, queue, time, worker, args) do
    GenServer.call(pid, {:enqueue_at, queue, time, worker, args}, Config.get(:genserver_timeout, 5000))
  end

  def enqueue_in(pid, queue, offset, worker, args) do
    GenServer.call(pid, {:enqueue_in, queue, offset, worker, args}, Config.get(:genserver_timeout, 5000))
  end

  def subscribe(pid, queue) do
    GenServer.call(pid, {:subscribe, queue})
  end

  def subscribe(pid, queue, concurrency) do
    GenServer.call(pid, {:subscribe, queue, concurrency})
  end

  def unsubscribe(pid, queue) do
    GenServer.call(pid, {:unsubscribe, queue})
  end

end
