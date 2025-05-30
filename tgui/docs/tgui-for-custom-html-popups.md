# Using TGUI and Byond API for custom HTML popups

TGUI in its current form would not exist without a very robust underlying layer that interfaces TGUI code with the BYOND browser component. This very layer can also be used to write simple and robust HTML popups, with access to many convenient APIs. In this article, you'll learn how to make a TGUI powered HTML popup and leverage all APIs that it provides.

## How to create a window

TGUI in order to create a window (popup) uses the `/datum/tgui_window` class. Feel free to take a look at its [source code](../../code/modules/tgui/tgui_window.dm), as all of its procs are very well documented. This class takes care of spawning the BYOND's browser element, normalizes the browser environment (because users might have IE8 on their system, or in future, it might be Microsoft Edge) and specifies a very rigid communication protocol between DM and JS.

> **Notice:** Because `/datum/tgui_window` includes a lot of boilerplate in the final html that it displays in the browser, it is somewhat more expensive to render than a traditional, dumb popup using a `browse()` proc call. Therefore, its best to use it with static popups or very custom pieces of client-side code, e.g. stat panel, chat or a background music player.

Create a window that prints hello world.

```dm
var/datum/tgui_window/window = new(usr.client, "custom_popup")
window.initialize(
  inline_html = "<h1>Hello world!</h1>",
)
```

Here, `custom_popup` is a unique id for the BYOND skin element that this window uses, and it can be anything you want. If you want to reference a specific element from `interface/skin.dmf`, you can use that id instead, and UI will initialize inside of that element. This is how for example chat initializes itself, by using a `browseroutput` id, which is also specified in `interface/skin.dmf`.

In case you want to re-initialize it with different content, you can do that as well by calling `initialize` again with different arguments.

```dm
window.initialize(
  inline_html = "<h2>Hello world, but smaller!</h2>",
)
```

You can close the window as easily as you've opened it.

```dm
window.close()
```

## Sending assets

TGUI in /tg/station codebase has `/datum/asset`, that packs scripts and stylesheets for delivery via CDN for efficiency. TGUI internally uses this asset system to render TGUI interfaces _proper_ and TGUI chat. This is a snippet from internal TGUI code:

```dm
window.initialize(
  fancy = user.client.prefs.read_preference(
    /datum/preference/toggle/tgui_fancy
  ),
  assets = list(
    get_asset_datum(/datum/asset/simple/tgui),
  ))
```

You can see two new arguments:

- `fancy` - See [Fancy mode](#fancy-mode)
- `assets` - This is a list of asset datums, and all JS and CSS in the assets will be loaded in the page.

Using asset datums has a big benefit over including `<script>` and `<link>` in normal html popups; If your asset is not available for any reason at the moment (e.g. network is down or packet loss), tgui window will retry loading those assets multiple times.

You can also send assets dynamically on a running instance of the window, and they will be included automatically without refreshing the page.

```dm
window.send_asset(asset)
```

Finally, you can use the `Byond` API object to load JS and CSS files directly via URLs.

```html
<script>
	Byond.loadJs('https://example.com/bundle.js');
	Byond.loadCss('https://example.com/bundle.css');
</script>
```

## Inlined HTML, CSS and JS

You can also make a popup that doesn't rely on network requests to get JS and CSS. In the following case, the entirety of the page will be contained in a single HTML file.

```dm
window.initialize(
  inline_html = "<h1>Hello world!</h1>",
  inline_js = "window.alert('Warning!')",
  inline_css = "h1 { color: red }",
)
```

You can also do the same by splitting your code into separate files, and then leveraging tgui window to serve it all as one big HTML file.

```dm
window.initialize(
  inline_html = file("code/modules/thing/thing.html"),
  inline_js = file("code/modules/thing/thing.js"),
  inline_css = file("code/modules/thing/thing.css"),
)
```

If you need to inline multiple JS or CSS files, you can concatenate them for now, and separate contents of each file with an `\n` symbol. _This can be a point of improvement (add support for file lists)_.

## Fancy mode

You may have noticed the fancy mode in previous snippets:

```dm
window.initialize(fancy = TRUE)
```

This removes the native window titlebar and border, which effectively turns window into a floating panel. TGUI heavily uses this option to draw completely custom, fancy windows. You can use it too, but not having the default titlebar limits usability of the browser window, since you can't even close it or drag around without implementing that functionality yourself. This mode might be useful for creating popups and tooltips.

## Communication

It is very often necessary to exchange data between DM and JS, and in vanilla BYOND programming it is a huge pain in the butt, because the `browse()` API is very convoluted, out of box it can send only strings, and sending data back to DM requires using hrefs.

```
location.href = '?src=12345&param=1'
```

If you're familiar with the href syntax of BYOND topic calls, then perhaps this doesn't surprise you, but this API artificially limits you to sending 2048 characters of string-typed data; you need to reinvent the wheel if you want to send something more complex than strings. It differs from the way you send messages from DM. And it's very hard to read as well.

Thankfully, TGUI implements a very robust protocol that makes this slightly less of an eye sore and very convenient to use in the long run.

### Message structure

```ts
{
  type: string;
  payload?: any;
  // ...
}
```

Each message always has a **type**, which is usually (but not always) the first argument on all message sending functions. The next property is the **payload**, which contains all the data sent in the message.

You can think of it in these terms:

- **type** - function name
- **payload** - function arguments

Of course we're not working with functions here, but hopefully this analogy makes the concept easier to understand.

Finally, message can contain custom properties, and how you use them is _completely up to you_. They have an important limitation - all additional properties are string-typed, and require you to use a slightly more verbose API for sending them (more about it in the next section).

```js
Byond.sendMessage({
	type: 'click',
	payload: { buttonId: 1 },
	popup_section: 'left',
});
```

### DM ➡ JS

To send a message from DM, you can use the `window.send_message()` proc.

```dm
window.send_message("alert", list(
  text = "Hello, world!",
))
```

To receive it in JS, you have two different syntaxes. First one is the most verbose one, but allows receiving all types of messages, and deciding what to do via `if` conditions.

> NOTE: We're using ECMAScript 5 syntax here, because this is the version that is supported by IE 11 natively without any additional compilation. If you're coding in a compiled environment (TGUI/Webpack), then feel free to use arrow functions and other fancy syntaxes.

```js
Byond.subscribe(function (type, payload) {
	if (type === 'alert') {
		window.alert(payload.text);
		return;
	}
	if (type === 'other') {
		// ...
		return;
	}
	// ...
});
```

Second one is more compact, because it already filters messages by type and passes the payload directly to the callback.

```js
Byond.subscribeTo('alert', function (payload) {
	window.alert(payload.text);
});
```

### JS ➡ DM

To send a message from JS, you can use the `Byond.sendMessage()` function.

```js
Byond.sendMessage('click', {
	button: 'explode-mech',
});
```

To receive it in DM, you must register a delegate proc (callback) that will receive the messages (usually called `on_message`), and handle the message in that proc.

```dm
/datum/my_object/proc/initialize()
  // ...
  window.subscribe(src, PROC_REF(on_message))

/datum/my_object/proc/on_message(type, payload)
  if (type == "click")
    process_button_click(payload["button"])
    return
```

**Advanced variant**

You can send messages with custom fields in case if you want to bypass JSON serialization of the **payload**. Not sending the **payload** is a little bit faster if you send a lot of messages (because BYOND is slow in general with proc calls, especially `json_decode`). All raw message fields are available in the third argument `href_list`.

```js
Byond.sendMessage({
	type: 'something',
	ref: '[0x12345678]',
});
```

```dm
/datum/my_object/proc/on_message(type, payload, href_list)
  if (type == "something")
    process_something(locate(href_list["ref"]))
    return
```

## BYOND Skin API

There is a full assortment of BYOND client-side features that you can access via the `Byond` API object.

Full reference of the `Byond` API object is here: [global.d.ts](../global.d.ts). It's a global type definition file, which provides auto-completion in VSCode when coding TGUI interfaces. When writing custom popups outside of TGUI, autocompletion doesn't work, so you might need to peek into this file sometimes.

Here's the summary of what it has.

- `Byond.winget()` - Returns a property of a skin element. This is an async function call, more on that later.
- `Byond.winset()` - Sets a property of a skin element.
- `Byond.topic()` - Makes a Topic call to the server. Similar to `sendMessage`, but all topic calls are native to BYOND, string typed and processed in `/client/Topic()` proc.
- `Byond.command()` - Runs a command on the client, as if you typed it into the command bar yourself. Can be any verb, or a special client-side command, such as `.output`.

> As of now, `Byond.winget()` requires a Promise polyfill, which is only available in compiled TGUI, but not in plain popups, and if you try using it, you'll get a bluescreen error. If you'd like to have winget in non-compiled contexts, then ping maintainers on Discord to request this feature.

When working with `winset` and `winget`, it can be very useful to consult [BYOND 5.0 controls and parameters guide](https://secure.byond.com/docs/ref/skinparams.html) to figure out what you can control in the BYOND client. Via these controls and parameters, you can do many interesting things, such as dynamically define BYOND macros, or show/hide and reposition various skin elements.

Another source of information is the official [BYOND Reference](https://secure.byond.com/docs/ref/info.html#/{skin}), which is a much larger, but a more comprehensive doc.

Id of the current tgui window can be accessed via `Byond.windowId`, and below in an example of changing its `size`.

```js
Byond.winset(Byond.windowId, {
	size: '1280x640',
});
```

Id of the main SS13 window is `'mainwindow'`, as defined in [skin.dmf](../../interface/skin.dmf).

Little known feature, but you can also get non-UI parameters on the client by using a `null` id.

```js
// Fetch URL of a server client is currently connected to
Byond.winget(null, 'url').then((serverUrl) => {
	// Connect to this server
	Byond.call(serverUrl);
	// Close our client because it is now connecting in background
	Byond.command('.quit');
});
```

## Strict Mode

Strict mode is a flag that you can set on tgui window.

```dm
window.initialize(strict_mode = TRUE)
```

If `TRUE`, unhandled errors and common mistakes result in a blue screen of death with a stack trace of the error, which you can use to debug it. Bluescreened window stops handling incoming messages and closes the active instance of tgui datum if there was one, to avoid a massive spam of errors and help to deal with them one by one.

It can be defined in `window.initialize()` in DM, as shown above, or changed in runtime at runtime via `Byond.strictMode` to `true` or `false`.

```js
Byond.strictMode = true;
```

It is recommended that you keep this **ON** to detect hard to find bugs.
