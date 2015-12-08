defmodule MarkovChordSup do
  use Supervisor

  def play do
    start_link
  end

  def start_link do
    chord_chain = %{
      I:   [:ii, :iii, :IV, :V, :vi, :vii],
      ii:  [:V, :vii],
      iii: [:IV, :vi],
      IV:  [:ii, :V, :vii],
      V:   [:vi],
      vi:  [:ii, :IV, :V],
      vii: [:I]
    }

    {:ok, sup} = Supervisor.start_link(__MODULE__, [])

    {:ok, c} = Supervisor.start_child(sup, worker(Clock, [Clock.bpm2ms(80, 4)]))
    {:ok, m} = Supervisor.start_child(sup, worker(Markov, [chord_chain, :I]))
    {:ok, s} = Supervisor.start_child(sup, worker(
          StepSequencer, [
            fn () ->
              Markov.val(m)
              |> MidiUtil.atom2chord
              |> Enum.map(fn n ->
                case n do
                  n when n > 7 -> n - 12
                  _ -> n
                end
              end)
              |> Enum.map(&(&1 + 60))
          end, 3]
        ))

    {:ok, l} = Supervisor.start_child(sup, worker(LogisticMap, [3.89, 0.1]))
    {:ok, s2} = Supervisor.start_child(sup, worker(StepSequencer, [fn () -> Enum.at([0,2,4,5,7,9,11,12,14,16,17,19,21,23,24], trunc(LogisticMap.next_val(l) * 15)) + 60 end], id: :logistic_seq))

    {:ok, piano} = Supervisor.start_child(sup, worker(Piano, []))

    Clock.add_tick_handler(c, s)
    Clock.add_tick_handler(c, s2)
    StepSequencer.add_step_handler(s, piano, :trigger)
    StepSequencer.add_step_handler(s2, piano, :trigger)
    Clock.start(c)

    {:ok, sup}
  end

  def init(_) do
    supervise([worker(SC3.Server, [])], strategy: :one_for_one)
  end

  def stop(sup) do
    SC3.Server.stop
    Process.exit(sup, :normal)
  end
end
