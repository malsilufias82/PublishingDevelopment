dim filesys, strOutput, strInput, fname
Set filesys = CreateObject("Scripting.FileSystemObject")

strInput=InputBox("Enter the html file name with path:")
fname = filesys.GetBaseName(strInput)
strOutput = Replace(strInput,"html","xls")

Set objExcel = CreateObject("Excel.Application")
objExcel.DisplayAlerts = FALSE
objExcel.Visible = FALSE
 
Set objWorkbook = objExcel.Workbooks.Open(strInput)

Set objWorksheet = objWorkbook.Worksheets(1)

objWorksheet.Rows(1).Insert
objWorksheet.Range("A2:A6").Font.Bold = True
objWorksheet.Range("A2:A6").Font.Size = 12
objWorksheet.Rows(5).RowHeight = 31.5

objWorksheet.Columns("A").ColumnWidth = 14
objWorksheet.Columns("B").ColumnWidth = 30
objWorksheet.Columns("C").ColumnWidth = 18
objWorksheet.Columns("D").ColumnWidth = 20
objWorksheet.Columns("E").ColumnWidth = 20
objWorksheet.Columns("F").ColumnWidth = 30
objWorksheet.Columns("G").ColumnWidth = 30
objWorksheet.Columns("H").ColumnWidth = 30
objWorksheet.Columns("I").ColumnWidth = 20
REM With objWorksheet.Columns("A") 
 REM .ColumnWidth = 14
REM End With

rowCount=objExcel.ActiveWorkbook.Sheets(1).UsedRange.Rows.count
colCount=objExcel.ActiveWorkbook.Sheets(1).UsedRange.Columns.count  


for intcol=1 to colCount  step 1
	objExcel.Cells(7, intcol).Interior.Color = RGB(204,255,255)
next
objWorksheet.Rows(7).RowHeight = 31.5
 
for intRow=8 to rowCount  step 1
	objExcel.Cells(intRow, 8).Value = ""
	objWorksheet.Rows(intRow).RowHeight = 130
next 

objExcel.ActiveWorkbook.SaveAs strOutput, 1
objExcel.ActiveWorkbook.Close
objExcel.Application.Quit
MsgBox fname & ".html to " & fname & ".xls has been converted !!!", 64, "html2xls"