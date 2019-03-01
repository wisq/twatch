defmodule Twatch.TestConfig do
  alias Twatch.{Config, Credentials, PageHandler, Actions}

  def config do
    {username, password} =
      System.get_env()
      |> Map.fetch!("TWATCH_LOGIN")
      |> String.split(":")
      |> List.to_tuple()

    login = %Credentials{username: username, password: password}

    %Config{
      start_url: "https://www.twitch.tv/directory/game/World of Warships",
      page_handlers: [
        # Category page (start):
        %PageHandler{
          match: "https://www.twitch.tv/directory/game/World of Warships",
          actions: [
            Actions.ensure_logged_in(login),
            Actions.pick_first_stream()
          ]
        },
        # Individual stream page:
        %PageHandler{
          match: ~r{^https://www.twitch.tv/[^/]+$},
          actions: [
            Actions.ensure_logged_in(login),
            Actions.ensure_category("World of Warships"),
            Actions.ensure_not_hosting()
          ]
        }
      ]
    }
  end
end
