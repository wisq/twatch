defmodule Twatch.Actions.Category do
  require Logger
  alias Hound.Helpers.Element
  import Twatch.Helpers

  def pick_stream(indices) do
    index_streams_by_range()
    |> pick_from_range(indices)
    |> Element.click()

    :halt
  end

  defp index_streams_by_range do
    xpath_all("//a[@data-a-target='preview-card-title-link']")
  end

  defp pick_from_range(links, index) when is_integer(index) do
    pick_from_range(links, index..index)
  end

  defp pick_from_range(links, %Range{} = range) do
    Logger.info("Selecting stream from range #{inspect(range)} ...")
    pairs = Enum.with_index(links)

    case Enum.slice(pairs, range) do
      [] ->
        {elem, index} = Enum.random(pairs)
        Logger.warn("No streams found.  Choosing random stream ##{index} instead.")
        elem

      list ->
        {_, first} = List.first(list)
        {_, last} = List.last(list)
        actual_range = first..last
        Logger.info("Available streams are #{inspect(actual_range)}.")

        {elem, index} = Enum.random(list)
        Logger.info("Choosing stream ##{index}.")
        elem
    end
  end
end
