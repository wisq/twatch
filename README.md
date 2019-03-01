# twatch

twatch is a browser automation tool that can watch [Twitch.tv](https://www.twitch.tv/) streams automatically for you.

Depending on the configuration you supply, it can ...

* Navigate the Twitch.tv website
* Log you in
* Pick a stream
* Click through the "mature content" warning
* Change streams if a raid/host occurs, or if the stream stops for any reason

## Installation

Twatch was designed to use [ChromeDriver](http://chromedriver.chromium.org/).  Other browsers and drivers might work — e.g. [Selenium](https://www.seleniumhq.org/) — but are untested and unsupported at this time.

1. Install [Google Chrome](https://www.google.com/chrome/) in a standard location.
2. Install [ChromeDriver](http://chromedriver.chromium.org/downloads).
    * Follow the directions to select the version based on your Chrome version.
3. Run `mix deps.get`.
4. Run `mix compile`.

## Setup

To run this, you'll need to have `chromedriver` running in the background, or in another window.

If you have problems, use the `--verbose` flag.  (On Unix, make sure `$DISPLAY` is set correctly.)

Remember that `chromedriver` opens up a port that can be used for privilege escalation, so consider running it as an unprivileged user.

## Running

Currently, there is one example task: `mix twatch.warships`.  This will ...

* Launch a browser window
* Navigate to the "World of Warships" category on Twitch
* Log you in
* Select one of the first five streams at random
* Click through any "mature content" warning

Once the stream is running, it will monitor the page and begin the process again if any of the following happens:

* The stream hosts another stream
* The stream raids a stream that is not in the "World of Warships" category
* The stream stalls or takes a break (no image change for 60 seconds)

## Legal stuff

Copyright © 2019, Adrian Irving-Beer.

twatch is released under the [Apache 2 License](../../blob/master/LICENSE) and is provided with **no warranty**.  There shouldn't be any security concerns about twatch itself, but `chromedriver` (and Chrome itself) have security concerns of their own, so be careful with how you set this up.
