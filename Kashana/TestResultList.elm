import StartApp.Simple as StartApp
import Kashana.ResultList as ResultList


main =
  StartApp.start 
    { model = ResultList.initModel
    , view = ResultList.view
    , update = ResultList.update 
    }

