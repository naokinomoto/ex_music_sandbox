defmodule Snare do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    {:ok, {}}
  end

  def play(pid) do
    GenServer.cast(pid, {:play})
  end

  def handle_cast({:play}, _) do
    SC3.Server.send_msg("s_new", ["snare01", SC3.Server.get_node_id, 0, 0])
    {:noreply, {}}
  end

  def handle_cast({:trigger, 1}, _) do
    SC3.Server.send_msg("s_new", ["snare01", SC3.Server.get_node_id, 0, 0])
    {:noreply, {}}
  end

  def handle_cast({:trigger, _}, _) do
    {:noreply, {}}
  end
end
