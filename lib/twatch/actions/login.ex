defmodule Twatch.Actions.Login do
  require Logger
  alias Hound.Helpers.Element
  import Twatch.Helpers

  def ensure_logged_in(creds) do
    if is_logged_in(creds.username) do
      :cont
    else
      log_in(creds)
      :halt
    end
  end

  defp is_logged_in(username) do
    xpath_all("//div[@data-a-target='user-display-name']")
    |> Enum.any?(fn elem ->
      text = Element.visible_text(elem)
      Logger.debug("Logged in as #{inspect(text)}, want #{inspect(username)}.")
      text == username
    end)
  end

  defp log_in(creds) do
    Logger.info("Logging in as #{inspect(creds.username)} ...")

    xpath("//button[@data-a-target='login-button']")
    |> Element.click()

    xpath("//div[@data-a-target='login-username-input']/input")
    |> Element.fill_field(creds.username)

    xpath("//div[@data-a-target='login-password-input']/input")
    |> Element.fill_field(creds.password)

    xpath("//button[@data-a-target='passport-login-button']")
    |> Element.click()

    Logger.info("Logged in.")
  end
end
