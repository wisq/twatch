defmodule Twatch.Helpers do
  require Logger
  alias Hound.Helpers.Page

  def xpath(xp) do
    Page.find_element(:xpath, xp)
  end

  def xpath_all(xp) do
    elems = Page.find_all_elements(:xpath, xp)
    Logger.debug("Found #{Enum.count(elems)} elements matching #{xp}")
    elems
  end

  def current_url do
    Hound.Helpers.Navigation.current_url()
  end

  def navigate_to(url) do
    Logger.info("Navigating: #{url}")
    Hound.Helpers.Navigation.navigate_to(url)
  end
end
