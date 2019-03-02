defmodule Twatch.Actions.Stream do
  require Logger
  alias Hound.Helpers.{Page, Element}
  import Twatch.Helpers

  def ensure_category(name) do
    if is_category(name) do
      :cont
    else
      Logger.info("Channel has wrong / no category; selecting a new one.")
      navigate_to("data:,")
      :halt
    end
  end

  def ensure_not_hosting do
    if is_hosting() do
      Logger.info("Channel is hosting; selecting a new one.")
      navigate_to("data:,")
      :halt
    else
      :cont
    end
  end

  def ensure_mature_accepted do
    case xpath_all("//button[@id='mature-link']") do
      [elem] ->
        Logger.info("Clicking mature accept link.")
        Element.click(elem)
        :halt

      [] ->
        :cont
    end
  end

  def prevent_idle do
    move_mouse_randomly()
    type_in_chat()
    :cont
  end

  defp move_mouse_randomly do
    body = Page.find_element(:tag, "body")
    {size_x, size_y} = Element.element_size(body)
    {off_x, off_y} = Element.element_location(body)

    x = Enum.random(0..size_x) + off_x
    y = Enum.random(0..size_y) + off_y
    Element.move_to(body, x, y)
  end

  defp type_in_chat do
    xpath("//textarea[@data-a-target='chat-input']") |> Element.click()
    Page.send_text("   ")
    Process.sleep(100)
    Page.send_keys([:backspace, :backspace, :backspace])
  end

  defp is_category(want) do
    xpath_all("//a[@data-a-target='stream-game-link']")
    |> Enum.any?(fn elem ->
      text = Element.visible_text(elem)
      Logger.debug("Current category is #{inspect(text)}, want #{inspect(want)}.")
      text == want
    end)
  end

  defp is_hosting do
    xpath_all("//a[@data-a-target='hosting-ui-link']")
    |> Enum.any?(fn _ -> true end)
  end
end
