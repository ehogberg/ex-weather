defmodule WeatherWeb.Helpers do
  def countdown_string({minutes_until, _}) when minutes_until > 0 do
    "approx. #{pluralize(minutes_until, 'minute', 'minutes')}"
  end

  def countdown_string({_, seconds_until}) do
    pluralize(seconds_until, "second", "seconds")
  end

  def friendly_timestamp(ts), do: Calendar.strftime(ts, "%x %X")

  def pluralize(amt, singular, _plural) when amt == 1, do: "#{amt} #{singular}"
  def pluralize(amt, _singular, plural), do: "#{amt} #{plural}"

  def calc_countdown_timer(next_update_time) do
    seconds_diff = DateTime.diff(next_update_time, DateTime.utc_now())
    minutes_until = div(seconds_diff, 60)
    seconds_until = Integer.mod(seconds_diff, 60)
    {minutes_until, seconds_until}
  end
end
