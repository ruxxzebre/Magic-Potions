defmodule Saturday.XLSX.Report do
  require Elixlsx
  alias Elixlsx.{Sheet, Workbook}
  alias Saturday.Entries

  @column_names ["ПІБ", "Телефон", "Пошта", "Зареєстровано на дату","Створено запис"]
  @columns ["A", "B", "C", "D", "E"]
  @map_entry_keys_to_column_names %{
    agent_name: "A",
    agent_phone: "B",
    email: "C",
    booking_date: "D",
    inserted_at: "E"
  }
  @column_widths %{
    agent_name: 16,
    agent_phone: 20,
    email: 25,
    booking_date: 25,
    inserted_at: 25
  }
  @max_column_widths %{
    "A" => @column_widths[:agent_name],
    "B" => @column_widths[:agent_phone],
    "C" => @column_widths[:email],
    "D" => @column_widths[:booking_date],
    "E" => @column_widths[:inserted_at],
  }

  def run() do
    Saturday.XLSX.Report.create_report()
  end

  def set_sheet_columns, do:
    set_sheet_columns(Sheet.with_name("Entries"))

  def set_sheet_columns(sheet) do
    @column_names
    |> Enum.with_index()
    |> Enum.reduce(sheet, fn {column_name, index}, sheet ->
      sheet
      |> Sheet.set_cell(
        "#{Enum.at(@columns, index)}1",
        column_name
      )
    end)
  end

  def set_sheet_rows(sheet) do
    sheet =
      Entries.list_entries(:format_fields)
      |> Enum.with_index()
      |> Enum.reduce(sheet, fn {entry, index}, sheet ->
        i = index + 2

        @map_entry_keys_to_column_names
        |> Enum.reduce(sheet, fn {key, name}, sheet ->
          sheet
          |> Sheet.set_cell("#{name}#{i}", Map.get(entry, key, ""))
        end)
      end)

    @max_column_widths
    |> Enum.reduce(sheet, fn {col, width}, sheet ->
      sheet
      |> Sheet.set_col_width(col, width)
    end)
  end

  def create_report do
    path = Application.app_dir(:saturday_web, "priv")

    %Workbook{sheets: [
      set_sheet_columns()
      |> set_sheet_rows()
    ]}
    |> Elixlsx.write_to("#{path}/report-#{Timex.now()}.xlsx")
  end
end
