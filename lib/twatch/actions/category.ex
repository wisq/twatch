defmodule Twatch.Actions.Category do
  require Logger
  alias Hound.Helpers.Element
  import Twatch.Helpers

  def pick_stream(indices, filter_fn \\ fn _ -> true end) do
    find_all_streams()
    |> Enum.filter(filter_fn)
    |> pick_from_range(indices)
    |> maybe_click()
  end

  defp maybe_click(nil) do
    Logger.warn("No stream selected.")
    :cont
  end

  defp maybe_click(elem) do
    Element.click(elem)
    :halt
  end

  defp find_all_streams do
    xpath_all("//a[@data-a-target='preview-card-title-link']")
  end

  defp pick_from_range(links, index) when is_integer(index) do
    pick_from_range(links, index..index)
  end

  defp pick_from_range(links, %Range{} = range) do
    case Enum.with_index(links) |> Enum.slice(range) do
      [] ->
        Logger.warn("No streams found in range #{inspect(range)}.")
        nil

      list ->
        {_, first} = List.first(list)
        {_, last} = List.last(list)
        actual_range = first..last
        Logger.info("Selected range #{inspect(range)}, got #{inspect(actual_range)}.")

        {elem, index} = Enum.random(list)
        title = Element.visible_text(elem)
        Logger.info("Choosing stream ##{index}: #{inspect(title)}")
        elem
    end
  end
end
