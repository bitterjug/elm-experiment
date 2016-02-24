import StartApp.Simple as StartApp
import Kashana.Result as Res

main =
  StartApp.start 
    { model = Res.initModel
    , view = Res.view
    , update = Res.update 
    }

