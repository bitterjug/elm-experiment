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


# Notes

So the missing link here is that the app gets a mailbox of Actions
with an `Address Action` and a `Signal Action`. This is the place to send
actions when fields get updated. (Remember it would actually be after
the update at the end of a server round-trip, executed asynchronously).

In [ToDo-Elm](https://github.com/evancz/elm-todomvc/blob/master/Todo.elm)
they have a simple field for their placeholder, and its enter event
handler does the creation.

Its more complex for me because I'm essentially simulating asynchronous code,
_I think_. So I wan to send the message while I'm executing the update for Enter
on a field. Which feels kinda odd.  And, assuming that it lets me get away with
that. I only want to do the add if I'm in the placeholder.  So I need a way to
parameterise the enter event for Inputs differently for normal ones and the
placeholder.

Now, confusingly, just as I got ready with my `Task err a`
head on I found the [Random Gif
example](https://github.com/evancz/elm-architecture-tutorial/blob/master/examples/5/RandomGif.elm)
uses
[Effects](http://package.elm-lang.org/packages/evancz/elm-effects/2.0.1/Effects)
instead of Tasks.
This appears to make it easier to work with actions that generate tasks
because execution of those tasks become side effects. So the recipe becomes:


- [x] Convert the whole app to StartApp (not StartApp.Simple)

- [ ] The `onEnter` handler for inputs should be parameterised to allow me to
  specify what  the side effect is, or more specifically, the side-effect
  should be: (fake) save the object, on success add to the list and create a
  new placeholder. On failure highlight as error.

- [ ] Make a fake http request to save the Result that
  [Sleeps](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Task#sleep)
  for a second.

The "save" step needs to be done at the level of the Result module, not the
field, because we should send of the whole record to be verified and saved by
the server. This means we can't actually do it at the input field level at all.
I'm suspecting:

- [x] Move knowledge of `(model, events)` down to the Result level with
  `Events.none`.

- [-] Add a new action to the Result module for saving the model.

- [ ] Add update option for saving the model that generates an effect with the
  task to send the JSON to the server. (or in our case, to pause for a
  second).

- [-] Pass an event handler (Signal.message???) to the field, to use on enter,
  that will send an Action to the address for the Result model to save itself.

  In the end didn't do this. All the work is done at Result level

Passing effects up from nested model handlers is ghastly. I must be missing something?

- So we intercept the update at Result level and ask the Input if it's action
  is one that should cause the data to be saved (i.e. is it a latch). Do this
  via a function to hide the details of the Action type (After discussing some
  options at Relevant records)

- [ ] Don't save the model if there's no difference -- i.e. if we just press
  Enter don't bother doing a save.

- [ ] How do we scale this to work with SartApp at list level?

- [ ] Instead of console log messages, we should style the components to show
  that the save is taking place. In Kashana this was done at the Input
  level with a different styling while the save was taking place. Would it
  make sense to do that at the whole of the Result level or should we only
  show he field as updating? 

At the moment we execute a NoOp when the (fake) server update returns. In
the future what I want to do is execute something more meaningful: 
- use styling to show that the Result is being updated and return to
  normal style when the (fake) server save request is complete.
- And in addition, when we do a save to the placeholder Result in the
  ResultsList app, that's when we should add it to the list and create
  a new empty placeholder.

Now I have separated adding new model to list from updating placeholder we have
the question of how to get the (placeholder) `Result`'s save Effect to trigger
`AddNewItem` at ResultList level (without breaking encapsulation).  Perhaps its
okay to break encapsulation first off so long as we can get it working?


Maybe this might work. 

What I want to do is package a "message-like" (possibly Message) in the
ResultList module and pass it to Result -- and maybe on to Input -- to "send"
when the relevant action takes place. The relevant action is pressing Enter and
I'm already using
[`Html.Events.On'](http://package.elm-lang.org/packages/evancz/elm-html/4.0.2/Html-Events#on)


        onKey : KeyMap -> Address Action -> Attribute
        onKey keymap address =
          on
            "keydown"
            (Json.customDecoder keyCode (keyMatch keymap))
            (\action -> Signal.message address action)

And creating the message in its entirety there and then. Maybe I can pass in
the `(a -> Message)` function from the higher level, and make it send a more interesting
message?



And, after thinking about this a lot, I currently think this isn't possible.
Because although I could change the Action that gets sent by the message, I
can't see a way to make it send two messages. And I still want to send the
`Input.Latch` action **as well as** cause a side effect on behalf of a higher
level module.

So the other option is to turn the side-effect into a `Task ()`  and somehow
get that to a `port`, but the only way to get it to a port seems to be at the
top level which puts us back in the realm of side effects and marshalling and
unpacking them on the way up.

# Elm 0.17 upgrade

        sudo npm install -g elm

Update elm-package.json thus:

    "dependencies": { },
    "elm-version": "0.17.0 <= v < 0.18.0"

Start to pull out syntax stuff.

    elm-make Main.elm
