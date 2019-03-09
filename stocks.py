#Create a script that will loop through each year of stock data and grab the total amount of volume each stock had over the year.
Sub stock_volume()

#Create a variable to hold the counter
Dim i As Long

#Create a variable to hold totatl stock volume and set to zero
Dim stock_volume As Double
stock_volume = 0

#Create variable to hold ticker symbol(column I)
Dim total_ticker As String

#Create variable for column A
NumRows = Range("A1", Range("A1").End(xlDown)).Rows.Count

#Create variable for total volume
TotalVolume = Range("J1", Range("J1").End(xlDown)).Rows.Count
#Create index that moves with column j
j = 2

#Loop through column A
For i = 2 To NumRows


#Check if ticker symbol same. If true, grab value, add to stock_volume 
If Cells(i, 1) = Cells(i + 1, 1) Then
    stock_volume = stock_volume + Cells(i, 7).Value
       
#elseif ticker symbol not equal, add volume to total volume, grab ticker add to index, grab total volume add to index, reset stock_volume to zero
ElseIf Cells(i, 1).Value <> Cells(i + 1, 1) Then
    stock_volume = stock_volume + Cells(i, 7)
    Cells(j, 10).Value = stock_volume
    Cells(j, 9).Value = Cells(i, 1)
    stock_volume = 0
    j = j + 1
    
End If
    
Next i

End Sub