# tgui Migration Guide to v4 from v3

## The Easy Part

- Copy and replace the following files in bulk:
  - `code/__DEFINES/tgui.dm`
  - `code/controllers/subsystem/tgui.dm`
  - `code/modules/tgui/**`
  - `tgui/**`
    - Except: `tgui/packages/tgui/interfaces`
    - Manually resolve conflicts for files that were touched outside the
      `interfaces` folder.
- Copy the updated `log_tgui` proc from:
  - `code/__HELPERS/_logging.dm`

If you have a dual nano/tgui setup, then make sure to rename all ui procs
on `/datum`, such as `ui_interact` to `tgui_interact`, to avoid namespace
clashing. Usual stuff.

## Update `ui_interact` proc signatures

First of all, tgui states need to move from `ui_interact` to `ui_state`.

One way of doing it, is to just cherry pick those procs from upstream.

If you want to search and replace manually, search for `state = GLOB`, and
extract those things into `ui_state` procs like so:

```dm
.../ui_state(mob/user)
	return GLOB.default_state
```

Then reduce `ui_interact` until you finish with something like this:

```dm
.../ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FooBar", "Foo Bar UI", 600, 400)
		ui.open()
```

## Update asset delivery code

Remove all asset code that injects stylesheets by modifying tgui's `basehtml`.
You no longer need to do that.

Find all occurences of `asset.send(user)` in `ui_interact`, and refactor those
snippets to the following proc:

```dm
.../ui_assets(mob/user)
	return list(
    get_asset_datum(/datum/asset/simple/foobar),
  )
```

## Check `ui_act` for new bugs

Code behind `ui_act` was recently refactored to use JSON-encoded payloads
instead of just strings. Since it can now carry numbers and other complex
types, you should check that the code is type agnostic and does not break
due to an assumption that every parameter is a string.

One of such offenders is the personal crafting interface, where it needlessly
compares parameters to `""` and `"0"`. You can now replace this code with
simple assignments, because an empty category will now be properly `null`
instead of an empty string.

## Backend data changes

Interfaces that relied on `config.window.id`, must now use
`window.__windowId__`, which is a global constant unique for the page
the script is running on (so you can be sure it never changes).

In case of `ByondUi`, this parameter can be completely omitted, because
parent will always default to the current window id.

Affected interfaces:

- `CameraConsole`
- Any interface that uses the `ByondUi` component

---

That's all folks!

There is a lot of stuff that was refactored under the hood, but normal UI
stuff wouldn't and shouldn't touch it, so you should be good with just
going through the checklist above.
