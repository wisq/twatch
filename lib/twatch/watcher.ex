defmodule Twatch.Watcher do
  use GenServer
  require Logger

  alias Twatch.PageHandler
  import Twatch.Helpers

  defmodule State do
    @enforce_keys [:config]
    defstruct(
      config: nil,
      check_timer: nil
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

  @check_interval 10_000

  defp schedule_next_check(%State{check_timer: nil} = state) do
    timer = Process.send_after(self(), :check, @check_interval)
    %State{state | check_timer: timer}
  end

  defp schedule_next_check(state) do
    case Process.read_timer(state.check_timer) do
      ms when is_integer(ms) ->
        # Timer is still active, so leave it alone.
        state

      false ->
        # Timer has expired, so schedule a new one.
        %State{state | check_timer: nil}
        |> schedule_next_check()
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

      %PageHandler{} = handler ->
        PageHandler.execute(handler)
    end

    {:noreply, schedule_next_check(state)}
  end

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
