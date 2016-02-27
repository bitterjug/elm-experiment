<!-- 
vim: ft=ghmarkdown  spell
-->
# Learning Elm

## The input widget

In `io.elm` is a text field with Enter (save) and Cancel (reset) actions,
inspired by what we used on Kashana.

Other stuff we had in Kashana include:

- Widgets with 2 text fields in: name and description
- lists of these widgets
- lists with a placeholder item 
- some of the placeholder details are inactive until it is created

Let's have a go at a 2 Input widget.

- [x] Make the input into a module
- [x] Follow [example 2](https://github.com/evancz/elm-architecture-tutorial/blob/master/examples/2/CounterPair.elm)


There needs to be some feedback that we have unsaved changes

- [x] Put a class on an input while its input value is different from its
  stored value.

So the list of results, with a placeholder is more subtle because what should
the ID of the placeholder be?  If `Maybe Int` then this forces a failure case
for the addressing to a list where we're assuming the invariant that items in
the list have a valid ID. The model doesn't enforce this. So a better model
would probably be 

  Result = {Name : String , Input : String}

  ResultList = { 
    placeholder : Result,
    results : List (id, Result)
  }

The reason I didn't go with that so far is that I am imagining a world
where we get back the id from the server on update, and it's all part of one
bundle of json. But who says I have to store it in one record like that?


