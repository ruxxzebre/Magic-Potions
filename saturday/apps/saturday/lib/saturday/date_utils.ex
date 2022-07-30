defmodule Saturday.DateUtils do
  def get_day_of_year(%DateTime{} = date) do
    Date.day_of_year(date)
  end

  def get_day_of_year(%Date{} = date) do
    Date.day_of_year(date)
  end

  def date_spec_map(%DateTime{} = date) do
    %{
      hour: date.hour,
      minute: date.minute,
      day_of_year: get_day_of_year(date),
      day: date.day,
      month: date.month,
      year: date.year
    }
  end
end
