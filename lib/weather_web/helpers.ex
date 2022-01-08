defmodule WeatherWeb.Helpers do

  def countdown_string({minutes_until,_}) when minutes_until > 0 do
    "approx. #{pluralize(minutes_until,'minute','minutes')}"
  end

  def countdown_string({_, seconds_until}) do
    pluralize(seconds_until,"second","seconds")
  end

  def friendly_timestamp(ts), do: Calendar.strftime(ts,"%x %X")

  def pluralize(amt, singular, _plural) when amt == 1, do: "#{amt} #{singular}"
  def pluralize(amt, _singular, plural), do: "#{amt} #{plural}"

end
