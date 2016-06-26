<!-- 
vim: ft=ghmarkdown  spell
-->
# Learning Elm

## The input widget

In `Components/Input.elm` is a text field with Enter (save) 
and Cancel (reset) actions, inspired by what we used on Kashana.

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

- [-] The `onEnter` handler for inputs should be parameterised to allow me to
  specify what  the side effect is, or more specifically, the side-effect
  should be: (fake) save the object, on success add to the list and create a
  new placeholder. On failure highlight as error.

  We don't do this. OnEnter just triggers plain old Latch, which updates the
  value as it should. And in the client, we can test whether the value has 
  changed.

- [x] Make a fake http request to save the Result that
  [Sleeps](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Task#sleep)
  for a second.

The "save" step needs to be done at the level of the Result module, not the
field, because we should send of the whole record to be verified and saved by
the server. This means we can't actually do it at the input field level at all.
I'm suspecting:

- [x] Move knowledge of `(model, events)` down to the Result level with
  `Events.none`.

- [-] Add a new action to the Result module for saving the model.

- [-] Add update option for saving the model that generates an effect with the
  task to send the JSON to the server. (or in our case, to pause for a
  second).

- [-] Pass an event handler (Signal.message???) to the field, to use on enter,
  that will send an Action to the address for the Result model to save itself.

  In the end didn't do this. All the work is done at Result level

Passing effects up from nested model handlers is ghastly. I must be missing something?

- [-] So we intercept the update at Result level and ask the Input if it's
  action is one that should cause the data to be saved (i.e. is it a latch). Do
  this via a function to hide the details of the Action type (After discussing
  some options at Relevant records)

  Did do this fora bit, then spotted a better solution on line and implemented
  during the 0.17 rewrite: pass the information back from update (or a special
  variant of update which for the moment I call `update'`). This started out
  as a boolean which tells the client whether the update is the kind that
  might save data. Then I refactored that to return the client-level `Cmd Msg`
  to trigger. This sounds like it would break modularity because Result has to
  know about it's client's `Msg` type. But, it doesn't. The special version of
  update has following type:

    update' : Cmd a -> Msg -> Model -> ( Model, Cmd a )
    update' saveCmd msg model =
        let
            cmd' =
                if msg == Latch then
                    saveCmd
                else
                    Cmd.none
        in
            ( update msg model, cmd' )

  And internally it invokes the normal update and then checks whether the
  state change ought to be followed by a save. The first parameter is the
  `saveCmd` to return if we ought to save. Its declared type is `Cmd a`; that
  type parameter a stands for the client's Msg type, so Input 
  knows precisely nothing about it. And if it's not time to save, it returns
  `Cmd.none` which also has type `Cmd a`. 

  This is still a bit specific: it only makes sense if the appropriate handling
  for for the client is to generate a particular Msg. A more general version
  might look like this:
  

    update' : a -> Msg -> Model -> ( Model,  Maybe a)
    update' saving msg model =
          ( update msg model, 
                if msg == Latch then
                    Just saving
                else
                    Nothing )


  Benefits: 
   - Removes the assumption that the returned value will be a command.
   - Moves specification of the default value to the client.

   - less confusing  because it doesn't resemble the classic Elm Architecture
     version of update which would return  `( model, Cmd Input.Msg)` -- 


  The client code has to be a little different, and specify the default using
  our new favourite Maybe pattern:

          UpdateName imsg ->
              let
                  ( name', cmd ) ) =
                      Input.update' saveResult imsg model.name
              in
                  ( { model | name = name' }, cmd ? Cmd.none )

  I was wary about using `Maybe.withDefault` for this, but with the `?`
  operator its quite terse and clear.

- [x] Don't save the model if there's no difference -- i.e. if we just press
  Enter don't bother doing a save.

  This was the charm. In the end there is no reason to be looking at the
  message type at Input level to decide whether to save. Its enough to look for
  a change in Input.Model.value which it is perfectly reasonable for the Result
  to do. So that's what we do. No more cross-module difficulty to deal with.
  The Result (client) contains all the logic about when to save a result and
  Input is purely an input again, and knows nothing about the need to treat
  some of its events differently. Hep Presto.


- [x] How do we scale this to work with SartApp at list level?

  Simples

- [x] Instead of console log messages, we should style the components to show
  that the save is taking place. In Kashana this was done at the Input
  level with a different styling while the save was taking place. Would it
  make sense to do that at the whole of the Result level or should we only
  show he field as updating? 

- [ ] As of today there is  a glitch in the colouring: we don't reset the
  colour when we press enter and there's no change to the value. There is still
  some logic in Input that refers to the concept of being saved. I think this
  is in the wrong place and we should pull it out. IT belongs in the Result
  object. When a result is being saved, actually all its fields are being
  updated. Perhaps we could make the change with a class at the level of the
  containing div. But it would be annoying if all the fields became
  inaccessible during a network round-trip. To make it behave like Kashana
  only the updated field should change. But we should only make that change
  when we do a save, not every time we press enter. So the appearance change 
  should be initiated by the containing Result, not by the Input itself 
  (as is currently the case, on Enter/Latch).


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


# Elm 0.17 upgrade

        sudo npm install -g elm

Update elm-package.json thus:

    "dependencies": { },
    "elm-version": "0.17.0 <= v < 0.18.0"

Start to pull out syntax stuff.

    elm-make Main.elm

## Focusing a given field

The todo mvc example uses a port to talk to javascript
to focus an element. Here's the js

``` javascript
todomvc.ports.focus.subscribe(function(selector) {
    setTimeout(function() {
        var nodes = document.querySelectorAll(selector);
        if (nodes.length === 1 && document.activeElement !== nodes[0]) {
            nodes[0].focus();
        }
    }, 50);
});
```

And here's the elm. The view sets the id attribute on the
input to "#todo-nn" to make this possible.

    port focus : String -> Cmd msg

    model ! [ focus ("#todo-" ++ toString id) ]

This feels unsatisfactory. 
And [others agree](https://github.com/evancz/elm-architecture-tutorial/issues/49).

[Stack overflow offers a different
solution](http://stackoverflow.com/questions/31901397/how-to-set-focus-on-an-element-in-elm)
with more, different, but less arbitrary javascript.

    var observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        handleAutofocus(mutation.addedNodes);
      });
    });
    var target = document.querySelector('body > div');
    var config = { childList: true, subtree: true };
    observer.observe(target, config);

    function handleAutofocus(nodeList) {
      for (var i = 0; i < nodeList.length; i++) {
        var node = nodeList[i];
        if (node instanceof Element && node.hasAttribute('data-autofocus')) {
          node.focus();
          break;
        } else {
          handleAutofocus(node.childNodes);
        }
      }
    }
