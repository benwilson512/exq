defmodule Exq do
  require Logger
  alias Exq.Support.Config
  use Application

  # OTP Application
  def start(_type, _args) do
    Exq.Supervisor.start_link
  end

  # Exq methods

  def start(opts \\ []) do
    Exq.Supervisor.start_link(opts)
  end

  def start_link(opts \\ []) do
    Exq.Supervisor.start_link(opts)
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
