<!-- 
vim: ft=ghmarkdown  spell
-->
# Learning Elm

## The input widget

In `io.elm` is a text field with Enter (save) and Cancel (reset) actions,
inspired by what we used on Kashana.

Other stuff we had in Kashana include:

- Widgets with 2 text fiels in: name and description
- lists of these widgets
- lists with a placeholder item 
- some of the placeholder details are inactive until it is created

Let's have a go at a 2 Input widget.

- [x] Make the input into a module
- [x] Follow [example 2](https://github.com/evancz/elm-architecture-tutorial/blob/master/examples/2/CounterPair.elm)


There needs to be some feedback that we have unsaved changes

- [ ] Put a class on an input while its input value is different from its
  stored value.
