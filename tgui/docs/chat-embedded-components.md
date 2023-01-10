# Chat Embedded Components

Have you ever embedded html into tgui chat? Maybe just css stuff like `<span class='alien'> </span>`?
Have you ever wanted to embed tgui components instead? For styling or ease of use of course.

Well we have a system for that! You can pass component information in via html attributes, and it'll be rendered in chat.
How? Let's get into it.

## How it works

Here's a sample span that embeds a tooltip around the wrapped text.

`<span data-component=\"Tooltip\" data-content=\"Hey it works!\">Does it work?</span>`

There's two components here, let's break them down.

### Targeting a component

Telling tgui chat what component you want to render is really simple. You just embed its name in the data-component attribute.

You saw it before, but for reference,
`<div data-component=\"Tooltip\"></div>`
this tells the div to render a tooltip.

There is a bit of nuance here however.

We can't embed components that haven't been prewhitelisted.

This isn't because of security concerns or anything, we just can't lookup components by their name without creating a lookup table.
You can find that in [tgui chat's renderer](../packages/tgui-panel/chat/renderer.js) under the name `TGUI_CHAT_COMPONENTS`

Adding a new component is simple, just add it's name to the dictionary, and import it into the file.

### Sending props

Ok, so we know how to render a component, but that's nearly useless unless we also know how to send extra info alongside it.

So how's that work?

The syntax is similar to sending a component, but has a bit more caveats.
We have two bits of info to contend with. The name of the prop, and it's value.
First then, how do you send the name of a prop?

#### Sending a prop's name

`<span {component setting} data-content={value}></span`

It's really simple, just another data attribute, with the name you want to refer to the property by.

Something important to note here, data attribute names cannot contain any upper case chars, or anything that isn't XML compatible.

Because of this, we need to do another map of sent name -> intended name. This can also be found in the [renderer file](../packages/tgui-panel/chat/renderer.js) with the name `TGUI_CHAT_ATTRIBUTES_TO_PROPS`

#### Sending a prop's value

Setting a prop's value is as simple as giving the data-content attribute a string value.

This does mean that we can only send strings to javascript. Because of this, we do some parsing js side to pull out other values you may want to send.

There's three supported datatypes.

##### **Booleans**

Booleans are send by sending a string in the form
`data-bool=\"$true\"` and "`data-bool=\"$false\"`
The $ char is included to allow you to send the string "true" without breaking anything.

Please keep this restriction in mind.

##### **Numbers**

Numbers are simpler then the above. If you send a string with no whitespace that can be parsed as an int or float, it will be.

So `data-int=\"-10\"` will be parsed as `-10`

`data-float=\"10.2\"` will also be correctly handled, treated as `10.2`

##### **Strings**

Strings are the most simple. If a value is passed to an html attribute, and it doesn't meet any of the above requirements, it will be

`data-string=\"hey man, it works!\"`
