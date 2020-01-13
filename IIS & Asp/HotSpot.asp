<!--METADATA NAME="TeeChart Pro v2019 ActiveX Control" TYPE="TypeLib" UUID="{DE7847A7-A266-4AA9-AA68-16676652C9DB}"-->
<%

  ' ************************************************************
  ' Script starting point via 2 entry points, one to create Chart
  ' and HTML page, the other to retrieve the image into the page
  ' ************************************************************
  if Request.QueryString("GetChartImage")=1 Then
    Response.BinaryWrite(RetrieveImage)
  else
    CreatePage
  end if

  Function RetrieveImage()
    RetrieveImage=Session("ExportImg")
  End function

  Function BuildChart(AChart)
    ' ************************************************************
    ' Setup some Chart appearance characteristics
    ' These and the Series could all be created externally and be
    ' saved/imported as a Chart template file. See the
    ' "Save time on serverside coding" example
    ' ************************************************************
    AChart.Aspect.Chart3DPercent=30
    AChart.Header.Text.Item(0)="TeeChart Hotspot map example"
    AChart.Header.Font.Height=12
    AChart.Header.Font.Color=vbBlack
    AChart.Header.Font.Bold=True
    AChart.Panel.Gradient.Visible=True
    AChart.Width=500
    AChart.Height=300

    ' Setup Series
    AChart.AddSeries(scBar)
    AChart.AddSeries(scLine)
    AChart.Series(0).ColorEachPoint=True
    AChart.Series(1).asLine.Pointer.Visible=True
    AChart.Series(1).asLine.Pointer.Brush.Color=vbGreen
    AChart.Series(0).FillSampleValues(8)
    AChart.Series(1).FillSampleValues(8)
  End Function

  Function GenerateChartHotSpot(AChart, AMapName)
   Const vbQuote = """"
   Dim t, tempWidth, tempHeight
   Dim Height3D, Width3D, StartHeightZ, StartWidthZ, ZCount
   Dim SeriesHeight3D, SeriesWidth3D
   Dim tmpText
   Dim result

    ' ************************************************************
    ' We use a session variable here to store the Chart image between calls
    ' to the script. The script is called twice. Once to create the Chart,
    ' export it, and create the html page with MAP and the second time to
    ' allow the created page to import the image via img src from the image
    ' variable (see Function RetrieveImage() above).
    ' ************************************************************

    Session("ExportImg") = AChart.Export.asPNG.SaveToStream

    Height3D = AChart.Aspect.Height3D 'Total Chart Z space Height displacement (pixels)
    Width3D = AChart.Aspect.Width3D 'Total Chart Z space Width displacement (pixels)
    ZCount = AChart.SeriesCount 'Series Count to subdivide Z space
    SeriesHeight3D = Height3D / ZCount 'Z space Height of each Series
    SeriesWidth3D = Width3D / ZCount 'Z space Width of each Series

    result = "<html>" + vbCrLf
    result = result + "<SCRIPT LANGUAGE=JAVASCRIPT>function RunCode(SeriesType,Value){alert(SeriesType + ' value: ' + Value);}</SCRIPT>" + vbCrLf

    result = result + "<HEAD><title>TeeChart Pro AX Control using Tee Template files serverside</title>"
    result = result + "<LINK REL=STYLESHEET TYPE=""text/css"" HREF=""Style.css""></HEAD><BODY>"
    result = result + "<img src=""TeeChartAX300x66.jpg"">"
    result = result + "<br><br>"
    result = result + "<a href=""ASPHome.htm"">Back to Contents page</a>"
    result = result + "<hr>"

    result = result + "<body>" + vbCrLf
    result = result + "<img USEMAP=" + vbQuote + "#" + AMapName + vbQuote + " src=" + vbQuote + "Hotspot.asp?GetChartImage=1" + vbQuote + " border=0>" + vbCrLf
    result = result + "<MAP name=" + vbQuote + AMapName + vbQuote + " > " + vbCrLf

    For TheSeries = (AChart.SeriesCount - 1) To 0 Step -1
    StartHeightZ = (ZCount - (TheSeries + 1)) * (Height3D / ZCount)
    StartWidthZ = (ZCount - (TheSeries + 1)) * (Width3D / ZCount)
    ' ****** Here using 'With', not supported in all ASP versions ******
    With AChart.Series(TheSeries)
      Select Case .SeriesType
         Case scLine, scPoint:
           if .SeriesType = scLine then
             tempWidth = .asLine.Pointer.HorizontalSize
             tempHeight = .asLine.Pointer.VerticalSize
           else
             tempWidth = .asPoint.Pointer.HorizontalSize
             tempHeight = .asPoint.Pointer.VerticalSize
           end if
           For t = 0 To .Count - 1
             X = .CalcXPos(t) + StartWidthZ
             Y = .CalcYPos(t) - StartHeightZ
             result = result + "<AREA shape=" + vbQuote + "poly" + vbQuote + " coords=" + _
                          vbQuote + CStr(X - tempWidth) + "," + CStr(Y - tempHeight) + "," + _
                          CStr(X - tempWidth + SeriesWidth3D) + "," + CStr(Y - tempHeight - SeriesHeight3D) + "," + _
                          CStr(X + tempWidth + SeriesWidth3D) + "," + CStr(Y - tempHeight - SeriesHeight3D) + "," + _
                          CStr(X + tempWidth + SeriesWidth3D) + "," + CStr(Y + tempHeight - SeriesHeight3D) + "," + _
                          CStr(X + tempWidth) + "," + CStr(Y + tempHeight) + "," + _
                          CStr(X - tempWidth) + "," + CStr(Y + tempHeight) + vbQuote + _
                          " HREF=" + vbQuote + "javascript:RunCode('Point'," + CStr(.YValues.Value(t)) + ");" + vbQuote + ">" + vbCrLf
           Next
        Case scBar:
          tempWidth = .asBar.BarWidth
          For t = 0 To .Count - 1
            tempStartY = .asBar.GetOriginPos(t) - StartHeightZ
            tempEndY = .CalcYPos(t) - StartHeightZ
            X = .CalcXPos(t) + StartWidthZ
            Select Case .asBar.BarStyle
              Case bsPyramid:
                 result = result + "<AREA shape=" + vbQuote + "poly" + vbQuote + " coords=" + _
                          vbQuote + CStr(X) + "," + CStr(tempStartY) + "," + _
                          CStr(X + tempWidth) + "," + CStr(tempStartY) + "," + _
                          CStr(X + tempWidth + SeriesWidth3D) + "," + CStr(tempStartY - SeriesHeight3D) + "," + _
                          CStr(X + (tempWidth \ 2)) + "," + CStr(tempEndY) + vbQuote + _
                          " HREF=" + vbQuote + "javascript:RunCode('Bar'," + CStr(.YValues.Value(t)) + ");" + vbQuote + ">" + vbCrLf
              Case bsInvPyramid:
                 result = result + "<AREA shape=" + vbQuote + "poly" + vbQuote + " coords=" + _
                          vbQuote + CStr(X) + "," + CStr(tempEndY) + "," + _
                          CStr(X + SeriesWidth3D) + "," + CStr(tempEndY - SeriesHeight3D) + "," + _
                          CStr(X + tempWidth + SeriesWidth3D) + "," + CStr(tempEndY - SeriesHeight3D) + "," + _
                          CStr(X + (tempWidth \ 2)) + "," + CStr(tempStartY) + vbQuote + _
                          " HREF=" + vbQuote + "javascript:RunCode('Bar'," + CStr(.YValues.Value(t)) + ");" + vbQuote + ">" + vbCrLf
              Case Else
                 result = result + "<AREA shape=" + vbQuote + "poly" + vbQuote + " coords=" + _
                          vbQuote + CStr(X) + "," + CStr(tempStartY) + "," + _
                          CStr(X + tempWidth) + "," + CStr(tempStartY) + "," + _
                          CStr(X + tempWidth + SeriesWidth3D) + "," + CStr(tempStartY - SeriesHeight3D) + "," + _
                          CStr(X + tempWidth + SeriesWidth3D) + "," + CStr(tempEndY - SeriesHeight3D) + "," + _
                          CStr(X + SeriesWidth3D) + "," + CStr(tempEndY - SeriesHeight3D) + "," + _
                          CStr(X) + "," + CStr(tempEndY) + vbQuote + _
                          " HREF=" + vbQuote + "javascript:RunCode('Bar'," + CStr(.YValues.Value(t)) + ");" + vbQuote + ">" + vbCrLf

            End Select
          Next
      End Select
    End With
    Next

    result = result + "<AREA shape=" + vbQuote + "default" + vbQuote + " nohref>" + vbCrLf + "</MAP>" + vbCrLf
    result = result + "<br><p>Click on the LineSeries' Points or anywhere on the BarSeries' Bars to interact "
    result = result + "with the Chart image.</p>"
    result = result + "<HR>Copyright &copy; 2019 Steema Software SL</BODY></HTML></body>" + vbCrLf
    result = result + "</html>"

    GenerateChartHotSpot = result
  End Function

  Function CreatePage
    Set TChart1 = CreateObject("TeeChart.TChart")
    BuildChart(TChart1)
    Response.Expires = 0
    Response.Write(GenerateChartHotSpot(TChart1, "ChartMap"))
  End Function
%>
