defmodule Twatch.Actions.Category do
  require Logger
  alias Hound.Helpers.Element
  import Twatch.Helpers

  def pick_first_stream do
    xpath("//div[@data-a-target='card-0']")
    |> Element.click()

    :halt
  end
end
