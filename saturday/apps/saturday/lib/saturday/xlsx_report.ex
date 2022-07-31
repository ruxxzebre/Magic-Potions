defmodule Saturday.XLSX.Report do
  require Elixlsx
  alias Elixlsx.{Sheet, Workbook}

  def new_sheet() do
    sheet1 =
      Sheet.with_name("First")
      # Set cell B2 to the string "Hi". :)
      |> Sheet.set_cell("B2", "Hi")
      # Optionally, set font properties:
      |> Sheet.set_cell("B3", "Hello World", bold: true, underline: true, color: "#ffaa00")
      # Set background color
      |> Sheet.set_cell("B4", "Background color \\o/", bg_color: "#ffff00")
      # Number formatting can be applied like this:
      |> Sheet.set_cell("A1", 123.4, num_format: "0.00")
      # Two date formats are accepted, erlang's :calendar format and UNIX timestamps.
      # the datetime: true parameter automatically applies conversion to Excels internal format.
      |> Sheet.set_cell("A2", {{2015, 11, 30}, {21, 20, 38}}, datetime: true)
      |> Sheet.set_cell("A3", 1_448_882_362, datetime: true)
      # datetime: true outputs date and time, yyyymmdd limits the output to just the date
      |> Sheet.set_cell("A4", 1_448_882_362, yyyymmdd: true)
      # datetime: true ouputs date and time, yyyymmdd limits the output to just the date
      |> Sheet.set_cell("A5", 1_448_882_362, yyyymm: true)
      # make some room in the first column, otherwise the date will only show up as ###
      |> Sheet.set_col_width("A", 18.0)
      # Cell borders
      |> Sheet.set_cell("A6", "Double border",
        border: [bottom: [style: :double, color: "#cc3311"]]
      )
      # Formatting with empty content
      |> Sheet.set_cell("A7", :empty,
        bg_color: "#ffff00",
        border: [bottom: [style: :double, color: "#cc3311"]]
      )
      # Boolean value
      |> Sheet.set_cell("A7", true)
      # Formula
      |> Sheet.set_cell("E1", 1.2, num_format: "0.00")
      |> Sheet.set_cell("E2", 2, num_format: "0.00")
      |> Sheet.set_cell("E3", 3.5, num_format: "0.00")
      |> Sheet.set_cell("E4", 4, num_format: "0.00")
      |> Sheet.set_cell("E5", 5, num_format: "0.00")
      # Show `value` if there is no calculated value (example: Mac OS preview):
      |> Sheet.set_cell("E6", {:formula, "SUM(E1:E5)", value: 15.70},
        num_format: "0.00",
        bold: true
      )
      |> Sheet.set_cell("F1", {:formula, "NOW()"}, num_format: "yyyy-mm-dd hh:MM:ss")
      |> Sheet.set_col_width("F", 18.0)
      # Data validations
      |> Sheet.set_cell("A1", "dog")
      |> Sheet.set_cell("A2", "cat")
      |> Sheet.set_cell("A3", "cow")
      |> Sheet.add_data_validations("A1", "A10", ["dog", "cat", "cow"])

    sheet1
  end
end
