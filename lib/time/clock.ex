defmodule Clock do
  use GenServer

  def bpm2ms(bpm, div \\ 1) do
    trunc(60 / bpm * 1000 / div)
  end

  def start_link(ms \\ 1000) do
    {:ok, event} = GenEvent.start_link
    GenServer.start_link(__MODULE__, [ms, event])
  end

  def start(pid) do
    GenServer.cast(pid, {:start_timer})
  end

  def stop(pid) do
    GenServer.cast(pid, {:stop_timer})
  end

  def set_bpm(pid, bpm, div \\ 1) do
    GenServer.cast(pid, {:set_ms, bpm2ms(bpm, div)})
  end

  def set_ms(pid, ms) do
    GenServer.cast(pid, {:set_ms, ms})
  end

  def add_tick_handler(pid, listener) do
    GenServer.cast(pid, {:add_tick_handler, listener})
  end

  def _timer_interval(event) do
    GenEvent.notify(event, {:tick})
  end

  def init([ms, event]) do
    {:ok, {ms, event}}
  end

  def handle_cast({:add_tick_handler, listener}, {ms, event}) do
    Task.start_link(fn ->
      for e <- GenEvent.stream(event) do
        GenServer.cast(listener, e)
      end
    end)
    {:noreply, {ms, event}}
  end

  def handle_cast({:start_timer}, {ms, event}) do
    :timer.apply_interval(ms, __MODULE__, :_timer_interval, [event])
    {:noreply, {ms, event}}
  end

  def handle_cast({:stop_timer}, {ms, event, timer}) do
    {:ok, :cancel} = :timer.cancel(timer)
    {:noreply, {ms, event}}
  end

  def handle_cast({:set_ms, ms}, {_, event, timer}) do
    :timer.apply_interval(ms, __MODULE__, :_timer_interval, [event])
    {:noreply, {ms, event, timer}}
  end
end

