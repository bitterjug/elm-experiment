import StartApp.Simple as StartApp
import Input

main =
  StartApp.start 
    { model = Input.initModel "Objective" 
    , view = Input.view
    , update = Input.update 
    }

