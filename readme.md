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


# Blog

I'm teaching myself [Elm](http://elm-lang.org/) and its awesome.  Although only
a few hours in, I've learned a lot about Elm and an important meta-lesson about
programming.  

As a project, I'm re-creating some UI components I made Javascript for
[Kashana](http://www.kashana.org/). _Results_ have a name and description, which 
are input fields:

``` elm
type alias Result =
  { id : Maybe Int
  , name : Input.Model
  , description : Input.Model
  }
```

I gave them an optional `id` because we display a placeholder at the bottom of a
list of _Results_ where you create new ones by entering either name or description.
In Kashana these get sent to the server which creates a new _Result_ in the database
and sends back the corresponding JSON, including the `id` (primary key). My Elm
project has no server (yet) so I'm storing `nextId` to fake object creation:

``` elm
type alias ResultList = 
  { results : List Result
  , placeholder : Result
  , nextId : Int
  }
```

Now, here's the problem: I use the `id` to route actions, as per the
[Elm Architecture](https://github.com/evancz/elm-architecture-tutorial):

``` elm
update action model =
  case action of
    ...
    Update id acttion ->
      let updateResult result = 
          if result.id == id
            then Res.update action result
            else result
      in { model | results = List.map updateResult model.results }
```

But, of course, this doesn't type check. Elm-make says:


```
Function `update` is expecting the 2nd argument to be:

    { ..., id : Maybe Int }

But it is:

    { ..., id : Int }
```

I don't want to deal with the `Nothing` case for `id` here because my design
includes an implicit invariant that _Results_ in the list always have an `id`;
only the placeholder has `Nothing`.  

But Elm doesn't know about that invariant.  And it checks my case statements at
compile time, and [complains if I haven't handled all the options as defined by
union types](https://github.com/avh4/elm-format). Which means I can't simply
ignore the `Nothing` case of `id: Maybe Int` when I know the invariant holds (I
don't remember Haskell being that strict).  Elm wants me to [banish the
null](http://elm-lang.org/guide/model-the-problem#banishing-null) `id` from my
code.  So how might this look if I model the problem in a way that makes my
invariant explicit? Remove `id` from the _Result_ record and include it only in
the list of _Results_:

``` elm
type alias Result =
  { name : Input.Model
  , description : Input.Model
  }

type alias ResultList = 
  { results : List (Int,  Result)
  , placeholder : Result
  , nextId : Int
  }
```

At first I felt this was a bit odd; I'm accustomed to having `id` fields as
part of my objects but this, I suspect, is mainly due to working with object
relational mappers which add Integer primary keys to object by default. 


----------

So the missing link here is that the app gets a mialbox of Actions
with an `Address Action` and a `Signal Action`. This is the place to send
actions when fields get updated. (Remember it would actually be after
the update at the end of a server round-trip, executed asynchronously).

In [ToDo-Elm](https://github.com/evancz/elm-todomvc/blob/master/Todo.elm)
they have a simple field for their placeholder, and its enter event
handler does the creation.

Its more complex for me because I'm essentially simulating asynchronous code,
_I think_. So I wan to send the message while Im executing the update for Enter
on a field. Which feels kinda odd.  And, assuming that it lets me get away with
that. I only want to do the add if Im in the placeholder.  So I need a way to
parameterise the enter event for Inputs differently for normal ones and the
placeholder.

