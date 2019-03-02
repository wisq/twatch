defmodule Mix.Tasks.Twatch.Warships do
  use Mix.Task
  require Logger

  alias Twatch.{Config, Credentials, PageHandler, Actions, Watcher}
  alias Twatch.Actions.Category.Filters

  @shortdoc "Watch a World of Warships stream"

  defp credentials do
    {username, password} =
      get_env!("TWATCH_LOGIN")
      |> String.split(":")
      |> List.to_tuple()

    Logger.debug("Credentials loaded for #{inspect(username)}.")
    %Credentials{username: username, password: password}
  end

  defp get_env!(key) do
    System.get_env()
    |> Map.get_lazy(key, fn ->
      Mix.raise("You must set #{key} in your environment to run this.")
    end)
  end

  defp config do
    login = credentials()

    %Config{
      start_url: "https://www.twitch.tv/directory/game/World of Warships",
      page_handlers: [
        # Category page (start):
        %PageHandler{
          match: "https://www.twitch.tv/directory/game/World of Warships",
          actions: [
            Actions.ensure_logged_in(login),
            Actions.pick_stream(0..2, Filters.channel_name(~r{drop|container}i)),
            Actions.pick_stream(0..2)
          ]
        },
        # Individual stream page:
        %PageHandler{
          match: ~r{^https://www.twitch.tv/[^/]+$},
          actions: [
            Actions.ensure_logged_in(login),
            Actions.ensure_mature_accepted(),
            Actions.ensure_category("World of Warships"),
            Actions.ensure_not_hosting(),
            Actions.ensure_image_changing(),
            Actions.prevent_idle()
          ]
        }
      ]
    }
  end

  def run([]) do
    Mix.Task.run("app.start")

    {:ok, pid} = Watcher.start_link(config: config(), name: MyWatcher)
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, :process, ^pid, reason} ->
        Mix.raise("Watcher exited: #{inspect(reason)}")

      msg ->
        Mix.raise("Received unexpected message: #{inspect(msg)}")
    end
  end

  def run(_) do
    Mix.raise("Usage: mix twatch.warships")
  end
end
