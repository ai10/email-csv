convert comma separated value to an array
===


     csvToArray = @csvToArray = ( strData, strDelimiter) ->
         console.log 'strdata', strData
         strDelimiter = strDelimiter or ","

         objPattern = new RegExp(
             (
                 "(\\" + strDelimiter + "|\\r?\\n|\\r|^)"+
                 "(?:\"([^\"]*(?:\"\"[^\"]*)*)\"|"+
                 "([^\"\\"+ strDelimiter + "\\r\\n]*))"
             ),
             "gi"
         )

         arrData = [[]]

         arrMatches = null

         while ( arrMatches = objPattern.exec( strData))
             strMatchedDelimiter = arrMatches[1]

             if (
                 strMatchedDelimiter.length &&
                 (strMatchedDelimiter != strDelimiter)
             ) then arrData.push([])

             if (arrMatches[2])
                 strMatchedValue = arrMatches[2].replace(
                     new RegExp("\"\"", "g"),
                     "\""
                 )
             else
                 strMatchedValue = arrMatches[3]

             arrData[arrData.length - 1].push( strMatchedValue)
   
         arrData


