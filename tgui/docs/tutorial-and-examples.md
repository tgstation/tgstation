# Tutorial and Examples

## Main concepts

Basic tgui backend code consists of the following vars and procs:

```
ui_interact(mob/user, datum/tgui/ui)
ui_data(mob/user)
ui_act(action, params)
ui_state()
```

- `src_object` - The atom, which UI corresponds to in the game world.
- `ui_interact` - The proc where you will handle a request to open an
  interface. Typically, you would update an existing UI (if it exists),
  or set up a new instance of UI by calling the `SStgui` subsystem.
- `ui_data` - In this proc you munges whatever complex data your `src_object`
  has into an associative list, which will then be sent to UI as a JSON string.
- `ui_act` - This proc receives user actions and reacts to them by changing
  the state of the game.
- `ui_state` - This proc dictates under what conditions a UI may be interacted
  with. This may be the standard checks that check if you are in range and
  conscious, or more.

Once backend is complete, you create an new interface component on the
frontend, which will receive this JSON data and render it on screen.

States are easy to write and extend, and what make tgui interactions so
powerful. Because states can be overridden from other procs, you can build
powerful interactions for embedded objects or remote access.

## Using It

### Backend

Let's start with a very basic hello world.

```dm
/obj/machinery/my_machine/ui_interact(mob/user, datum/tgui/ui)
  ui = SStgui.try_update_ui(user, src, ui)
  if(!ui)
    ui = new(user, src, "MyMachine")
    ui.open()
```

This is the proc that defines our interface. There's a bit going on here, so
let's break it down. First, we override the ui_interact proc on our object. This
will be called by `interact` for you, which is in turn called by `attack_hand`
(or `attack_self` for items). `ui_interact` is also called to update a UI (hence
the `try_update_ui`), so we accept an existing UI to update.

Inside the `if(!ui)` block (which means we are creating a new UI), we choose our
template, title, and size; we can also set various options like `style` (for
themes), or autoupdate. These options will be elaborated on later (as will
`ui_state`s).

After `ui_interact`, we need to define `ui_data`. This just returns a list of
data for our object to use. Let's imagine our object has a few vars:

```dm
/obj/machinery/my_machine/ui_data(mob/user)
  var/list/data = list()
  data["health"] = health
  data["color"] = color

  return data
```

The `ui_data` proc is what people often find the hardest about tgui, but its
really quite simple! You just need to represent your object as numbers, strings,
and lists, instead of atoms and datums.

Finally, the `ui_act` proc is called by the interface whenever the user used an
input. The input's `action` and `params` are passed to the proc.

```dm
/obj/machinery/my_machine/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
  . = ..()
  if(.)
    return
  if(action == "change_color")
    var/new_color = params["color"]
    if(!(color in allowed_coors))
      return FALSE
    color = new_color
    . = TRUE
  update_icon()
```

The `..()` (parent call) is very important here, as it is how we check that the
user is allowed to use this interface (to avoid so-called href exploits). When
any event has been handled `..()` will return `TRUE`. It is important to clamp
and sanitize all input here. Always assume the user is attempting to exploit the
game.

When `..()` has returned `TRUE` your interface can safely assume that the user's
action has been handled already by some parent proc and you should not continue
to handle this, instead preserving and returning the parent proc's return value.

Also note the use of `. = TRUE` (or `FALSE`), which is used to notify the UI
that this input has been handled. When `ui_act` eventually returns, a value of
`TRUE` indicates that the input has been handled and that the UI should update.
This is important for UIs that do not auto-update, as otherwise the user will
not be able to see the interface update based on thier actions.

### Frontend

Finally, let's make a React Component for your interface. This is also
a source of confusion for new developers. If you got some basic javascript
and HTML knowledge, that should ease the learning process, although we
recommend getting yourself introduced to
[React and JSX](https://reactjs.org/docs/introducing-jsx.html).

A React component is not a regular HTML template. A component is a
javascript function, which accepts a `props` object (that contains
properties passed to a component) and a `context` object (which is
necessary to access UI data) as arguments, and outputs an HTML-like
structure.

So let's create our first React Component. Create a file with a name
`SampleInterface.js` (or any other name you want), and copy this code
snippet (make sure component name matches the file name):

```jsx
import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const SampleInterface = (props, context) => {
	const { act, data } = useBackend(context);
	// Extract `health` and `color` variables from the `data` object.
	const { health, color } = data;
	return (
		<Window resizable>
			<Window.Content scrollable>
				<Section title="Health status">
					<LabeledList>
						<LabeledList.Item label="Health">{health}</LabeledList.Item>
						<LabeledList.Item label="Color">{color}</LabeledList.Item>
						<LabeledList.Item label="Button">
							<Button
								content="Dispatch a 'test' action"
								onClick={() => act('test')}
							/>
						</LabeledList.Item>
					</LabeledList>
				</Section>
			</Window.Content>
		</Window>
	);
};
```

Here are the key variables you get from a `useBackend(context)` function:

- `config` is part of core tgui. It contains meta-information about the
  interface and who uses it, BYOND refs to various objects, and so forth.
  You are rarely going to use it, but sometimes it can be used to your
  advantage when doing complex UIs.
- `data` is the data returned from `ui_data` and `ui_static_data` procs in
  your DM code. Pretty straight forward.
  - Note, that javascript doesn't have associative arrays, so when you
    return an associative list from DM, it will be available in `data` as a
    javascript object instead of an array. You can use it normally
    like so: `object.key`, so it's not a problem if it's representing a
    data structure, but common `Array` methods, such as `array.map(item => ...)`,
    are not available on it. Always prefer returning clean arrays from your
    code, since arrays are easier to work with in javascript!
- `act(name, params)` is a function, which you can call to dispatch an action
  to your DM code. It will be processed in `ui_act` proc. Action name will be
  available in `params["action"]`, mixed together with the rest of parameters
  you have passed in `params` object.

**Let's talk about the syntax.**

The syntax you're seeing here is called JSX - a very simple extension of the
core javascript language. It's basically a pre-processor, that takes
expressions that look like html, and turns them into function calls.

Take a look at this example:

```jsx
<div className={'color-' + status}>You are in {status} condition!</div>
```

After compiling the code above, this is what it becomes:

```js
createElement(
	'div',
	{ className: 'color-' + status },
	'You are in ',
	status,
	' condition!',
);
```

It is very important to remember, that JSX is just a javascript expression
made out of `createElement` function calls. Naturally, this allows doing
all sorts of stuff on these expressions, just like you would with anything
else in javascript.

Take a look at these examples:

**Render an element inside of another element if `showProgress` is true.**

This example uses the `&&` operator (the logical AND). It returns
the first operand if it evaluates to `false`, and returns the second operand
if it evaluates to `true`.

If `showProgress` is `true`, the whole expression evaluates
to a `<ProgressBar />` element. If `showProgress` is `false`, the whole
expression evaluates to `false`, and `false` is not rendered by React.

```jsx
<Box>{showProgress && <ProgressBar value={progress} />}</Box>
```

You can also use the `||` operator (the logical OR), which works the same way,
except it will return the second operand on `false` instead of `true`.

**Loop over the array to map every item to a corresponding React element.**

`Array.map()` is a method, that calls a function on every item in the array,
and builds a new array based on what was returned by that function.

```jsx
<LabeledList>
	{items.map((item) => (
		<LabeledList.Item key={item.id} label={item.label}>
			{item.content}
		</LabeledList.Item>
	))}
</LabeledList>
```

If you need more examples of what you can do with React, see the
[interface conversion guide](docs/converting-old-tgui-interfaces.md).

#### Splitting UIs into smaller, modular components

You interface will eventually get really, really big. The easiest thing
you can do in this situation, is divide and conquer. Grab a chunk of your
JSX code, and wrap it into a second, smaller React component:

```jsx
import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const SampleInterface = (props, context) => {
	return (
		<Window resizable>
			<Window.Content scrollable>
				<HealthStatus user="Jerry" />
			</Window.Content>
		</Window>
	);
};

const HealthStatus = (props, context) => {
	const { act, data } = useBackend(context);
	const { user } = props;
	const { health, color } = data;
	return (
		<Section title={'Health status of: ' + user}>
			<LabeledList>
				<LabeledList.Item label="Health">{health}</LabeledList.Item>
				<LabeledList.Item label="Color">{color}</LabeledList.Item>
			</LabeledList>
		</Section>
	);
};
```

## Copypasta

We all do it, even the best of us. If you just want to make a tgui **fast**,
here's what you need (note that you'll probably be forced to clean your shit up
upon code review):

```dm
/obj/copypasta/ui_interact(mob/user, datum/tgui/ui)
  ui = SStgui.try_update_ui(user, src, ui)
  if(!ui)
    ui = new(user, src, "copypasta")
    ui.open()

/obj/copypasta/ui_data(mob/user)
  var/list/data = list()
  data["var"] = var
  return data

/obj/copypasta/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
  if(..())
    return
  switch(action)
    if("copypasta")
      var/newvar = params["var"]
      // A demo of proper input sanitation.
      var = CLAMP(newvar, min_val, max_val)
      . = TRUE
  update_icon() // Not applicable to all objects.
```

And the template:

```jsx
import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const SampleInterface = (props, context) => {
	const { act, data } = useBackend(context);
	// Extract `health` and `color` variables from the `data` object.
	const { health, color } = data;
	return (
		<Window resizable>
			<Window.Content scrollable>
				<Section title="Health status">
					<LabeledList>
						<LabeledList.Item label="Health">{health}</LabeledList.Item>
						<LabeledList.Item label="Color">{color}</LabeledList.Item>
						<LabeledList.Item label="Button">
							<Button
								content="Dispatch a 'test' action"
								onClick={() => act('test')}
							/>
						</LabeledList.Item>
					</LabeledList>
				</Section>
			</Window.Content>
		</Window>
	);
};
```
