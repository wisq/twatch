defmodule Twatch.Watcher do
  use GenServer
  require Logger

  alias Twatch.PageHandler
  import Twatch.Helpers

  defmodule State do
    @enforce_keys [:config]
    defstruct(
      config: nil,
      timer: nil
    )
  end

  def start_link(opts) do
    config = Keyword.fetch!(opts, :config)
    GenServer.start_link(__MODULE__, config, opts)
  end

  @impl true
  def init(config) do
    start_web_session()

    state = %State{config: config}
    Logger.info("Watcher started.")
    send(self(), :check)
    {:ok, state}
  end

  # How often to loop if we're currently undergoing
  # some sort of navigation or other operation.
  @processing_interval 5_000
  # How often to loop if we're just chilling and
  # watching a stream.
  @health_check_interval 60_000

  defp schedule_processing(state), do: schedule_next_check(state, @processing_interval)
  defp schedule_health_check(state), do: schedule_next_check(state, @health_check_interval)

  defp schedule_next_check(%State{timer: nil} = state, interval) do
    timer = Process.send_after(self(), :check, interval)
    Logger.debug("Next check scheduled for #{interval}ms.")
    %State{state | timer: timer}
  end

  defp schedule_next_check(state, interval) do
    case Process.read_timer(state.timer) do
      ms when is_integer(ms) ->
        if ms > interval do
          # Timer is too slow.  Kill it and do it again.
          Process.cancel_timer(state.timer)
          Logger.debug("Shortening next check.")

          %State{state | timer: nil}
          |> schedule_next_check(interval)
        else
          # Timer is still active and soon enough, so leave it alone.
          Logger.debug("Next check already scheduled in #{ms}ms.")
          state
        end

      false ->
        # Timer has expired, so schedule a new one.
        %State{state | timer: nil}
        |> schedule_next_check(interval)
    end
  end

  @impl true
  def handle_info(:check, state) do
    Logger.debug("Watcher check")

    url = current_url()

    case PageHandler.find(state.config.page_handlers, url) do
      nil ->
        Logger.info("No page handler for URL: #{url}")
        navigate_to(state.config.start_url)
        {:noreply, schedule_processing(state)}

      %PageHandler{} = handler ->
        state =
          PageHandler.execute(handler)
          |> determine_schedule(state)

        {:noreply, state}
    end
  end

  defp determine_schedule(:halt, state), do: schedule_processing(state)
  defp determine_schedule(:cont, state), do: schedule_health_check(state)

  defp start_web_session do
    destroy_active_sessions()
    Hound.start_session()
  end

  defp destroy_active_sessions do
    Hound.Session.active_sessions()
    |> Enum.map(&Map.fetch!(&1, "id"))
    |> Enum.each(&Hound.Session.destroy_session/1)
  end
end
