# Visuals in /tg/station 13

Welcome to a breakdown of visuals and visual effects in our codebase, and in BYOND.

I will be describing all of the existing systems we use, alongside explaining and providing references to BYOND's ref for each tool.

Note, I will not be covering things that are trivial to understand, and which we don't mess with much.
For a complete list of byond ref stuff relevant to this topic, see [here](https://www.byond.com/docs/ref/#/atom/var/appearance).

This is to some extent a collation of the BYOND ref, alongside a description of how we actually use these tools.
My hope is after reading this you'll be able to understand and implement different visual effects in our codebase.

Also please see the ref entry on the [renderer](https://www.byond.com/docs/ref/#/{notes}/renderer).

We do a LOT, so this document might run on for a bit. Forgive me.

You'll find links to the relevant reference entries at the heading of each entry, alongside a hook back to the head of this document.

### Table of Contents

- [Appearances](#appearances-in-byond)
- [Overlays](#overlays)
- [Visual contents](#visual-contents)
- [Images](#images)
- [Client images](#client-images)
- [View](#view)
- [Eye](#eye)
- [Client screen](#client-screen)
- [Blend mode](#client-screen)
- [Appearance flags](#appearance-flags)
- [Gliding](#gliding)
- [Sight](#sight)
- [BYOND lighting](#byond-lighting)
  - [Luminosity](#luminosity)
  - [See in dark](#see-in-dark)
  - [Infrared](#infrared)
- [Invisibility](#invisibility)
- [Layers](#layers)
- [Planes](#planes)
- [Render target/source](#render-targetsource)
- [Multiz](#multiz)
- [Mouse opacity](#mouse-opacity)
- [Filters](#filters)
- [Particles](#particles)
- [Pixel offsets](#pixel-offsets)
- [Map formats](#map-formats)
- [Color](#color)
- [Transform](#transform)
- [Lighting](#lighting)
- [Animate()](<#animate()>)
- [GAGS](#gags)

## Appearances in BYOND

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/appearance)

Everything that is displayed on the map has an appearance variable that describes exactly how it should be rendered.
To be clear, it doesn't contain EVERYTHING, [plane masters](#planes) exist separately and so do many other factors.
But it sets out a sort of recipe of everything that could effect rendering.

Appearances have a few quirks that can be helpful or frustrating depending on what you're trying to do.

To start off with, appearances are static. You can't directly edit an appearance "datum", it will throw a runtime or just yell at you.

The way to edit them most of the time is to just modify the corresponding variable on the thing the appearance represents.

This doesn't mean it's impossible to modify them directly however. While appearances are static,
their cousins mutable appearances [(Ref Entry)](https://www.byond.com/docs/ref/info.html#/mutable_appearance) **are**.

What we can do is create a new mutable appearance, set its appearance to be a copy of the static one (remember all appearance variables are static),
edit it, and then set the desired thing's appearance var to the appearance var of the mutable.

Somewhat like this

```byond
// NOTE: we do not actually have access to a raw appearance type, so we will often
// Lie to the compiler, and pretend we are using a mutable appearance
// This lets us access vars as expected. Be careful with it tho
/proc/mutate_icon_state(mutable_appearance/thing)
	var/mutable_appearance/temporary_lad = new()
	temporary_lad.appearance = thing
	temporary_lad.icon_state += "haha_owned"
	return temporary_lad.appearance
```

> **Note:** More then being static, appearances are unique. Only one copy of each set of appearance vars exists, and when you modify any of those vars, the corrosponding appearance variable changes its value to whatever matches the new hash. That's why appearance vars can induce inconsistent cost on modification.

> **Warning:** BYOND has been observed to have issues with appearance corruption, it's something to be weary of when "realizing" appearances in this manner.

## Overlays

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/overlays) (Also see [rendering](https://www.byond.com/docs/ref/#/{notes}/renderer))

Overlays are a list of static [appearances](#appearances-in-byond) that we render on top of ourselves.
Said appearances can be edited via the realizing method mentioned above.

Their rendering order is determined by [layer](#layers) and [plane](#planes), but conflicts are resolved based off order of appearance inside the list.

While overlays are stored as static appearances they can be created using icon states to draw from the overlay'd thing icon, or using `/icon` objects.

Also of note: overlays have a cost on addition, which is why as we will discuss we cache modifications to the list.

It's not significant, but it is there, and something to be aware of.

### Our Implementation

We use overlays as our primary method of overlaying visuals.
However, since overlays are COPIES of a thing's appearance, ensuring that they can be cleared is semi troublesome.

To solve this problem, we manage most overlays using `update_overlays()`.

This proc is called whenever an atom's appearance is updated with `update_appearance()`
(essentially just a way to tell an object to rerender anything static about it, like icon state or name),
which will often call `update_icon()`.

`update_icon()` handles querying the object for its desired icon, and also manages its overlays, by calling `update_overlays()`.

Said proc returns a list of things to turn into static appearances, which are then passed into `add_overlay()`,
which makes them static with `build_appearance_list()` before queuing an overlay compile.

This list of static appearances is then queued inside a list called `managed_overlays` on `/atom`.
This is so we can clear old overlays out before running an update.

We actually compile queued overlay builds once every tick using a dedicated subsystem.
This is done to avoid adding/removing/adding again to the overlays list in cases like humans where it's mutated a lot.

You can bypass this managed overlays system if you'd like, using `add_overlay()` and `cut_overlay()`,
but this is semi dangerous because you don't by default have a way to "clear" the overlay.
Be careful of this.

## Visual Contents

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/vis_contents)

The `vis_contents` list allows you to essentially say "Hey, render this thing ON me".

The definition of "ON" varies significantly with the `vis_flags` value of the _thing_ being relayed.
See the ref [here](https://www.byond.com/docs/ref/#/atom/var/vis_flags).

Some flags of interest:

- `VIS_INHERIT_ID`: This allows you to link the object DIRECTLY to the thing it's drawn on,
  so clicking on the `vis_contents`'d object is just like clicking on the thing
- `VIS_INHERIT_PLANE`: We will discuss [planes](#planes) more in future, but we use them to both effect rendering order and apply effects as a group.
  This flag changes the plane of any `vis_contents`'d object (while displayed on the source object) to the source's.
  This is occasionally useful, but should be used with care as it breaks any effects that rely on plane.

Anything inside a `vis_contents` list will have its loc stored in its `vis_locs` variable.
We very rarely use this, primarily just for clearing references from `vis_contents`.

`vis_contents`, unlike `overlays` is a reference, not a copy. So you can update a `vis_contents`'d thing and have it mirror properly.
This is how we do multiz by the by, with uh, some more hell discussed under [multiz](#multiz).

To pay for this additional behavior however, vis_contents has additional cost in maptick.
Because it's not a copy, we need to constantly check if it's changed at all, which leads to cost scaling with player count.
Careful how much you use it.

## Images

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/image)

Images are technically parents of [mutable appearances](#appearances-in-byond).
We don't often use them, mostly because we can accomplish their behavior with just MAs.

Images exist both to be used in overlays, and to display things to only select clients on the map.
See [/client/var/images](#client-images)

> Note: the inheritance between the two is essentially for engine convenience. Don't rely on it.

## Client Images

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/client/var/images)

`/client/var/images` is a list of image objects to display to JUST that particular client.

The image objects are displayed at their loc variable, and can be shown to more then one user at once.

### Our Implementation

We use client images in a few ways. Often they will be used just as intended, to modify the view of just one user.
Think tray scanner or technically ai static.

However, we often want to show a set of images to the same GROUP of people, but in a limited manner.
For this, we use the `/datum/atom_hud` (hereafter hud) system.

This is different from `/datum/hud`, which I will discuss later.

HUDs are datums that represent categories of images to display to users.
They are most often global, but can be created on an atom to atom bases in rare cases.

They store a list of images to display (sorted by source z level to reduce lag) and a list of clients to display to.

We then mirror this group of images into/out of the client's images list, based on what HUDs they're able to see.
This is the pattern we use for things like the medihud, or robot trails.

## View

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/client/var/view)

`/client/var/view` is actually a pretty simple topic,
but I'm gonna take this chance to discuss the other things we do to manage pixel sizing and such since there isn't a better place for it,
and they're handled in the same place by us.

Alright then, view. This is pretty simple, but it basically just lets us define the tile bound we want to show to our client.

This can either be a number for an X by X square, or a string in the form "XxY" for more control.

We use `/datum/view_data` to manage and track view changes, so zoom effects can work without canceling or being canceled by anything else.

### Client Rendering Modes

- [Zoom Ref](https://www.byond.com/docs/ref/#/{skin}/param/zoom) / [Zoom Mode Ref](https://www.byond.com/docs/ref/#/{skin}/param/zoom-mode)

Clients get some choice in literally how they want the game to be rendered to them.

The two I'm gonna discuss here are `zoom`, and `zoom-mode` mode, both of which are skin params (basically just variables that live on the client)

`zoom` decides how the client wants to display the turfs shown to it.
It can have two types of values.
If it's equal to 0 it will stretch the tiles sent to the client to fix the size of the map-window.
Otherwise, any other numbers will lead to pixels being scaled by some multiple.
This effect can only really result in nice clean edges if you pass in whole numbers which is why most of the constant scaling we give players are whole numbers.

`zoom-mode` controls how a pixel will be up-scaled, if it needs to be.
See the ref for more details, but `normal` is fairly sharp, with a little blur, `distort` uses nearest neighbor, which is the sharpest option, but introduces heavier distortion some might find distracting, and `blur` uses bilinear sampling, which causes a LOT of blur.

If you are using integer scaling, `distort` provides a perfect image, while the other two are not recommended to be used.

## Eye

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/client/var/eye)

`/client/var/eye` is the atom or mob at which our view should be centered.
Any screen objects we display will show "off" this, as will our actual well eye position.

It is by default `/client/var/mob` but it can be modified.
This is how we accomplish ai eyes and ventcrawling, alongside most other effects that involve a player getting "into" something.

## Client Screen

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/{notes}/HUD)

Similar to client images but not _quite_ the same, we can also insert objects onto our client's literal screen

This is done by giving it an appropriate `screen_loc` value, and inserting it into the client's `screen` list.

Note: we use screen for other things too, I'll get to that eventually.

`screen` is actually rather uninteresting, but `screen_loc` has a LOT more nuance.

To start with, the format.
The classic `screen_loc` format looks something like this (keeping in mind it counts from the top left):
`x:px,y:py`

The pixel offsets can be discarded as optional, but crucially the x and y values do not NEED to be absolute.

We can use cardinal keywords like `NORTH` to anchor screen objects to the view size of the client (a topic that will be discussed soon).
You can also use directional keywords like `TOP` to anchor to the actual visible map-window, which prevents any accidental out of bounds.
Oh yeah you can use absolute offsets to position screen objects out of the view range, which will cause the map-window to forcefully expand,
exposing the parts of the map byond uses to ahead of time render border things so moving is smooth.

### Secondary Maps

While we're here, this is a bit of a side topic but you can have more then one map-window on a client's screen at once.

This gets into dmf fuckery but you can use [window ids](https://www.byond.com/docs/ref/#/{skin}/param/id) to tell a screen object to render to a secondary map.
Useful for creating popup windows and such.

## Blend Mode

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/blend_mode)

`/atom/var/blend_mode` defines how an atom well, renders onto the map.

There's a whole bunch of options but really the only one you need to know offhand is `BLEND_MULTIPLY`, which multiplies the thing being drawn "on" by us.

This is how we do lighting effects, since the lighting [plane](#planes) can be used to multiply just normal coloring. If it's all black, the full screen goes black.

## Appearance Flags

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/appearance_flags)

`/atom/var/appearance_flags` is a catch all for toggles that apply to visual elements of an atom.
I won't go over all of them, but I will discuss a few.

Flags of interest:

- `LONG_GLIDE`: without this, diagonal movements will automatically take sqrt(2) more time, to account for the greater distance. We do this calculus automatically, and so want this flipped to disable the behavior.
- `KEEP_TOGETHER`: this allows us to force overlays to render in the same manner as the thing they're overlaid on. Most useful for humans to make alpha changes effect all overlays.
- `PLANE_MASTER`: I will get into this later, but this allows us to use the [plane](#planes) var to relay renders onto screen objects, so we can apply visual effects and masks and such.
- `TILE_BOUND`: By default if something is part in one tile and part in another it will display if either is visible. With this set it'll go off its loc value only.

## Gliding

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/{notes}/gliding)

You may have noticed that moving between tiles is smooth, or at least as close as we can get it.
Moving at 0.2 or 10 tiles per second will be smooth. This is because we have control over the speed at which atoms animate between moves.

This is done using two patterns. One is how we handle input, the other is BYOND's gliding.

We can edit `/atom/movable/var/glide_size` to set the amount of pixels our mob should move per SERVER tick (Our server tick rate is 20 times a second, or 0.5 deciseconds).
This is done using `/atom/movable/proc/set_glide_size`, which will inform anything we are "carrying" to match our rate.

Glide size is often set in the context of some rate of movement. Either the movement delay of a mob, set in `/client/Move()`, or the delay of a movement subsystem.

We use defines to turn delays into pixels per tick.
Client moves will be limited by `DELAY_TO_GLIDE_SIZE` which will allow at most 32 pixels a tick.
Subsystems and other niche uses use `MOVEMENT_ADJUSTED_GLIDE_SIZE`.
We will also occasionally use glide size as a way to force a transition between different movement types, like space-drift into normal walking.
There's extra cruft here.

> Something you should know: Our gliding system attempts to account for time dilation when setting move rates.
> This is done in a very simplistic way however, so a spike in td will lead to jumping around as glide rate is outpaced by mob movement rate.

On that note, it is VERY important that glide rate is the same or near the same as actual move rate.
Otherwise you will get strange jumping and jitter.
This can also lead to stupid shit where people somehow manage to intentionally shorten a movement delay to jump around. Dumb.

Related to the above, we are not always able to maintain sync between glide rate and mob move rate.
This is because mob move rate is a function of the initial move delay and a bunch of slowdown/speedup modifiers.
In order to maintain sync we would need to issue a move command the MOMENT a delay is up, and if delays are not cleanly divisible by our tick rate (0.5 deciseconds) this is impossible.
This is why you'll sometime see a stutter in your step when slowed

Just so you know, client movement works off `/client/var/move_delay` which sets the next time an input will be accepted. It's typically glide rate, but is in some cases just 1 tick.

## Sight

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/mob/var/sight)

`/mob/var/sight` is a set of bitflags that _mostly_ set what HAS to render on your screen. Be that mobs, turfs, etc.
That said, there is some nuance here so I'ma get into that.

- `SEE_INFRA`: I'll get into this later, but infrared is essentially a copy of BYOND darkness, it's not something we currently use.
- `SEE_BLACKNESS`: This relates heavily to [planes](#planes), essentially typically the "blackness" (that darkness that masks things that you can't see)
  is rendered separately, out of our control as "users".
  However, if the `SEE_BLACKNESS` flag is set, it will instead render on plane 0, the default BYOND plane.
  This allows us to capture it, and say, blur it, or redraw it elsewhere. This is in theory very powerful, but not possible with the 'side_map' [map format](https://www.byond.com/docs/ref/#/world/var/map_format)

## BYOND Lighting

- [Table of Contents](#table-of-contents)

Alongside OUR lighting implementation, which is discussed in with color matrixes, BYOND has its own lighting system.

It's very basic. Essentially, a tile is either "lit" or it's not.

If a tile is not lit, and it matches some other preconditions, it and all its contents will be hidden from the user,
sort of like if there was a wall between them. This hiding uses BYOND darkness, and is thus controllable.

I'll use this section to discuss all the little bits that contribute to this behavior

### Luminosity

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/luminosity)

`/atom/var/luminosity` is a variable that lets us inject light into BYOND's lighting system.
It's real simple, just a range of tiles that will be lit, respecting sight-lines and such of course.

> This "light" is how `/proc/view()` knows if something is in view or not. Oh by the by `view()` respects lighting.
> You can actually force it to use a particular mob's sight to avoid aspects of this, this is what `dview()` is

### See in Dark

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/mob/var/see_in_dark)

`/mob/var/see_in_dark` sets the radius of a square around the mob that cuts out BYOND darkness.

This is why when you stand in darkness you can see yourself, and why you can see a line of objects appear when you use mesons (horrible effect btw).
It's quite simple, but worth describing.

### Infrared

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/mob/var/see_infrared)

Infrared vision can be thought of as a hidden copy of standard BYOND darkness.
It's not something we actually use, but I think you should know about it, because the whole thing is real confusing without context.

## Invisibility

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/invisibility)

`/atom/var/invisibility` is a rudimentary way of hiding things from select groups of users. Think of it like [planes](#planes), or [client images](#client-images) but more limited.
We use this to hide ghosts, ghost visible things, and in the past we used it to hide/show backdrops for the lighting plane, which is semi redundant now.

It's also used to hide some more then ghost invisible things, like some timers and countdowns. It scales from 0 to 101.

`/mob/var/see_invisible` is the catcher of invisibility. If a mob's see_invisible is higher then a target/s invisibility, it'll be shown. Really basic stuff.

## Layers

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/layer)

`/atom/var/layer` is the first bit of logic that decides the order in which things on the map render.
Rendering order depends a LOT on the [map format](https://www.byond.com/docs/ref/#/world/var/map_format),
which I will not get into in this document because it is not yet relevant.
All you really need to know is for our current format,
the objects that appear first in something's contents will draw first, and render lowest.
Think of it like stacking little paper cutouts.

Layer has a bit more nuance then just being lowest to highest, tho it's not a lot.
There are a few snowflake layers that can be used to accomplish niche goals, alongside floating layers, which are essentially just any layer that is negative.

Floating layers will float "up" the chain of things they're being drawn onto, until they find a real layer. They'll then offset off of that.

Adding `TOPDOWN_LAYER` (actual value `10000`) to another layer forces the appearance into topdown rendering, locally disabling [side map](#side_map-check-the-main-page-too).
We can think of this as applying to planes, since we don't want it interlaying with other non topdown objects.

This allows us to keep relative layer differences while not needing to make all sources static. Often very useful.

## Planes

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/plane)

Allllright `/atom/var/plane`s. Let's talk about em.

They serve two purposes. The first is really simple, and basically just a copy of [layers](#layers).
Higher planes will (**normally**) render over lower ones. Very clearcut.

Similarly to [layers](#layers), planes also support "floating" with `FLOAT_PLANE`. See above for an explanation of that.

However, they can be used for more complex and... fun things too!
If a client has an atom with the `PLANE_MASTER` [appearance flag](#appearance-flags) in their [screen](#client-screen),
then rather then being all rendered normally, anything in the client's view is instead first rendered onto the plane master.

This is VERY powerful, because it lets us [hide](https://www.byond.com/docs/ref/#/atom/var/alpha), [color](#color),
and [distort](#filters) whole classes of objects, among other things.
I cannot emphasize enough how useful this is. It does have some downsides however.

Because planes are tied to both grouping and rendering order, there are some effects that require splitting a plane into bits.
It's also possible for some effects, especially things relating to [map format](https://www.byond.com/docs/ref/#/world/var/map_format),
to just be straight up impossible, or conflict with each other.
It's dumb, but it's what we've got brother so we're gonna use it like it's a free ticket to the bahamas.

We have a system that allows for arbitrary grouping of plane masters for the purposes of [filter effects](#filters)
called `/atom/movable/plane_master_controller`.
This is somewhat outmoded by our use of [render relays](#render-targetsource), but it's still valid and occasionally useful.

> Something you should know: Plane masters effect ONLY the map their screen_loc is on.
> For this reason, we are forced to generate whole copies of the set of plane masters with the proper screen_loc to make subviews look right

> Warning: Planes have some restrictions on valid values. They NEED to be whole integers, and they NEED to have an absolute value of `10000`.
> This is to support `FLOAT_PLANE`, which lives out at the very edge of the 32 bit int range.

## Render Target/Source

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/render_target)

Render targets are a way of rendering one thing onto another. Not like vis_contents but in a literal sense ONTO.
The target object is given a `/atom/var/render_target` value, and anything that wishes to "take" it sets its `/atom/var/render_source` var to match.

When I say render onto, I mean it literally. It is like adding a second step in the rendering process.

You can even prepend \* to the render target value to disable the initial render, and JUST render via the render source.

### Our Implementation

We use render targets to create "render relays" which can be used to link [plane masters](#planes) together and accomplish more advanced effects.
See [the renderer documentation](../../code/_onclick/hud/rendering/_render_readme.md) for visualizations for this.

> Of note: this linking behavior is accomplished by adding a screen object to link onto with a plane value of the desired PM we want to relay onto.
> Layer is VERY important here, and will be set based off the layer of the last plane master.
> This means plane order is not always the absolute order in which different plane masters render. Be careful of this.

> To edit and display planes and plane connections in game, run the `Edit/Debug Planes` command.
> It will open a ui that allows you to view relay connections, plane master descriptions, and edit their values and effects.

## Multiz

- [Table of Contents](#table-of-contents)
- Reference: Hell of our own creation

I'm gonna explain how our multiz system works. But first I need to explain how it used to work.

What we used to do was take an openspace turf above, insert the turf below into its [vis_contents](#visual-contents), and call it a day.
This worked because everything on the map had the `VIS_INHERIT_PLANE` flag, and openspace had a plane master below most everything.

This meant the turf below looked as if it was offset, and everything was good.

Except not, for 2 reasons. One more annoying then the other.

- 1: It looked like dog doo-doo. This pattern destroyed the old planes of everything vis_contents'd, so effects/lighting/dropshadows broke bad.
- 2: I alluded to this earlier, but it totally breaks the `side_map` [map format](https://www.byond.com/docs/ref/#/world/var/map_format)
  which I need for a massive resprite I'm helping with. This is because `side_map` changes how rendering order works,
  going off "distance" from the front of the frame.
  The issue here is it of course needs a way to group things that are even allowed to overlap, so it uses plane.
  So when you squish everything down onto one plane, this of course breaks horribly and fucks you.

Ok then, old way's not workable. What will we do instead?

There's two problems here. The first is that all our plane masters come pre-ordered. We need a way to have lower and upper plane masters.

This is well... not trivial but not hard either. We essentially duplicate all our plane masters out like a tree, and link the head of the master rendering plate
to the openspace plane master one level up. More then doable.

SECOND problem. How do we get everything below to "land" on the right plane?

The answer to this is depressing but still true. We manually offset every single object on the map's plane based off its "z layer".
This includes any `overlays` or `vis_contents` with a unique plane value.

Mostly we require anything that sets the plane var to pass in a source of context, like a turf or something that can be used to derive a turf.
There are a few edge cases where we need to work in explicitly offsets, but those are much rarer.

This is stupid, but it's makable, and what we do.

## Mouse Opacity

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/mouse_opacity)

`/atom/var/mouse_opacity` tells clients how to treat mousing over the atom in question.

A value of 0 means it is completely ignored, no matter what.
A value of 1 means it is transparent/opaque based off the alpha of the icon at any particular part.
A value of 2 means it will count as opaque across ALL of the icon-state. All 32x32 (or whatever) of it.

We will on occasion use mouse opacity to expand hitboxes, but more often this is done with [vis_contents](#visual-contents),
or just low alpha pixels on the sprite.

> Note: Mouse opacity will only matter if the atom is being rendered on its own. [Overlays](#overlays)(and [images](#images))
> will NOT work as expected with this.
> However, you can still have totally transparent overlays. If you render them onto a [plane master](#planes) with the desired mouse opacity value
> it will work as expected. This is because as a step of the rendering pipeline the overlay is rendered ONTO the plane master, and then the plane
> master's effects are applied.

## Filters

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/{notes}/filters)

Filters are a general purpose system for applying a limited set of shaders to a render.
These shaders run on the client's machine. This has upsides and downsides.
Upside: Very cheap for the server. Downside: Potentially quite laggy for the client.
Take care with these

Like I said, they're quite general purpose. There's a LOT of different effects, and many things you can do with them.

There's two things I want you to know about them, partly to put across their usefulness, and partially so you know their limitations.

On Usefulness. There are filters for alpha masking. They accept render sources as params, which means we can use say, one plane master
to mask out another. This + some fucking bullshit is how emissive lighting works.

Similarly there are filters for distortions. This is how we accomplish the grav anomaly effect, as it too accepts a render source as a param.

On limitations: Filters, like many things in BYOND, are stored in a snowflake list on `/atom`. This means if we want to manage them,
we will need our own management system. This is why we, unlike byond, use a wrapper around filters to set priorities and manage addition/removal.
This system has the potential to break animations and other such things. Take care.

> We have a debug tool for filters, called filterrific. You can access it in-game by vving an atom, going to the dropdown, and hitting `Edit Filters`
> It'll let you add and tweak _most_ of the filters in BYOND.

## Particles

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/{notes}/particles)

Particles are a system that allows you to attach "generators" to atoms on the world, and have them spit out little visual effects.
This is done by creating a subtype of the `/particles` type, and giving it the values you want.

At base BYOND only allows you to attach one particle emitter to any one `/atom`. We get around this using an atom inserted into the loc of some parent atom to follow.
The type is `/obj/effect/abstract/particle_holder`. Interacting with it's real simple, you just pass in the location to mirror, and the type to use.
It'll do the rest.

> We have a debug tool for particles. You can access it in-game by vving an atom, going to the dropdown, and hitting `Edit Particles`
> It'll let you add and tweak the particles attached to that atom.

## Pixel Offsets

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/pixel_x)

This is a real simple idea and I normally wouldn't mention it, but I have something else I wanna discuss related to it, so I'ma take this chance.

`/atom/var/pixel_x/y/w/z` are variables that allow us to offset the DISPLAY position of an atom. This doesn't effect its position on the map mind,
just where it APPEARS to be. This is useful for many little effects, and some larger ones.

Anyway, onto why I'm mentioning this.

There are two "types" of each direction offset. There's the "real" offset (x/y) and the "fake" offset (w,z).
Real offsets will change both the visual position (IE: where it renders) and also the positional position (IE: where the renderer thinks they are).
Fake offsets only effect visual position.

This doesn't really matter for our current map format, but for anything that takes position into account when layering, like `side_map` or `isometric_map`
it matters a whole ton. It's kinda a hard idea to get across, but I hope you have at least some idea.

## Map Formats

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/world/var/map_format)

`/world/var/map_format` tells byond how to render things well, in the world.
You can get away with thinking of it as rendering rules really.

There are 4 types currently. Only 2 that are interesting to us, and one that's neat for historical purposes.
Most of them involve changing how layering works, from the standard [layers](#layers) and [planes](#planes) method.
There's a bit more detail here, not gonna go into it, stuff like [underlays](https://www.byond.com/docs/ref/#/atom/var/underlays) drawing under things. See [Understanding The Renderer](https://www.byond.com/docs/ref/#/{notes}/renderer)

> There is very technically more nuance here.
> In default rendering modes, byond will conflict break by using the thing that is highest in the contents list of its location. Or lowest. Don't remember.

### [`TOPDOWN_MAP`](https://www.byond.com/docs/ref/#/{notes}/topdown)

This is the default rendering format. What we used to use. It tells byond to render going off [plane](#planes) first, then [layer](#layers). There's a few edgecases involving big icons, but it's small peanuts.

### [`SIDE_MAP`](https://www.byond.com/docs/ref/#/{notes}/side) (Check [the main page](https://www.byond.com/docs/ref/#/world/var/map_format) too!)

Our current rendering format, used in preparation for moving more things to 3/4ths.

This is essentially [isometric mode](#isometric_map), but it only works up and down.
This does mean we get some very nice upsides, like being able to be both in front and behind an object without needing to do cursed splitting or modifying layers.
It does come with some downsides, Mostly the flickering and debugging issues described above.

The idea is the closer to the front of the screen something is, the higher its layering precedence is.

`pixel_y` + `y` tell the engine where something "is".
`/atom/var/bound_width`, `/atom/var/bound_height` and `/atom/var/bound_x/y` describe how big it is, which lets us in theory control what it tries to layer "against".
I'm not bothering with reference links because they are entirely unrelated.

An issue that will crop up with this map format is needing to manage the "visual" (how/where it renders) and physical (where it is in game) aspects of position and size.
Physical position tells the renderer how to layer things. Visual position and a combination of physical bounds (manually set) and visual bounds (inferred from other aspects of it. Sprite width/height, physical bounds, transforms, filters, etc) tell it what the sprite might be rendering OVER.

Here's where things get really annoying for us. We cannot change physical bound outside of increments of 32.
That's because we use [`LEGACY_MOVEMENT_MODE`](https://www.byond.com/docs/ref/#/world/var/movement_mode).
This means we're almost always doomed to getting weird layering, cascading out from the source of the issue in a way that is quite hard to debug.

Oh right I forgot to mention. Sorta touched on it with [Pixel offsets](#pixel-offsets).

- `pixel_x/y` change something's position in physical space. So if you shoot this real high it'll layer as if it is where it appears to be,
- `pixel_w/z` change something's VISUAL position. So you can LAYER as if you're at the bottom of the screen, but actually sit at the top.

You can use the two of these in combination to shift something physically, but not visually. Often useful for making things layer right.
Any change in position (`pixel_x/y`) will only come into effect after crossing `/world/var/icon_size` / 2 and will round to the nearest tile.

What follows is a description, from lummox, of how physical conflicts are handled.

From [this post](https://www.byond.com/forum/post/2656961#comment26050050)

For the physical position, Y increases upward relative to the screen; view position has Y going downward. The topological order between two icons goes like this, in order:

- 1. If the icons don't visually overlap, they don't care which goes first.
- 2. If the icons do not overlap on the physical Y axis, whichever one is further back is drawn first.
- 3. If one has a lower layer, it's drawn first.
- 4. If one's "near" edge (physical Y) is closer to the top of the screen than the other, it gets drawn first.
- 5. If one's center is left of the other, it's drawn first.
- 6. If the two physical bounds are identical, whichever icon came first in the original array order is drawn first.
- 7. All tiebreakers failed so the icons give up and don't care which goes first.

It is worth stating clearly. Things will only "visually overlap" if they sit on the same [plane](#planes).
This is NOT counting [relays](#render-targetsource)/[plane masters](#planes) (when a plane master is relayed onto something else, you can think of it like drawing the WHOLE PLANE MASTER)
It's not like drawing everything on the plane master with effects applied. It's like drawing to a sheet, and then drawing with that sheet again.

This also leads to issues, and means there are some effects that are entirely impossible to accomplish while using sidemap, without using horrible [image](#images) tricks.
This is frustrating.

One more thing. Big icons are fucked

From the byond reference

> If you use an icon wider than one tile, the "footprint" of the isometric icon (the actual map tiles it takes up) will always be a square. That is, if your normal tile size is 64 and you want to show a 128x128 icon, the icon is two tiles wide and so it will take up a 2×2-tile area on the map. The height of a big icon is irrelevant--any excess height beyond width/2 is used to show vertical features. To draw this icon properly, other tiles on that same ground will be moved behind it in the drawing order.
> One important warning about using big icons in isometric mode is that you should only do this with dense atoms. If part of a big mob icon covers the same tile as a tall building for instance, the tall building is moved back and it could be partially covered by other turfs that are actually behind it. A mob walking onto a very large non-dense turf icon would experience similar irregularities.

These can cause very annoying flickering. In fact, MUCH of how rendering works causes flickering. This is because we don't decide on a pixel by pixel case, the engine groups sprites up into a sort of rendering stack, unable to split them up.

This combined with us being unable to modify bounds means that if one bit of the view is conflicting.
If A wants to be above B and below C, but B wants to be below A and above C, we'll be unable to resolve the rendering properly, leading to flickering depending on other aspects of the layering.
This can just sort of spread. Very hard to debug.

### [`ISOMETRIC_MAP`](https://www.byond.com/docs/ref/#/{notes}/isometric)

Isometric mode, renders everything well, isometrically, biased to the north east. This gives the possibility for fake 3d, assuming you get things drawn properly.
It will render things in the foreground "last", after things in the background. This is the right way of thinking about it, it's not rendering things above or below, but in a layering order.

This is interesting mostly in the context of understanding [side map](#side_map-check-the-main-page-too), but we did actually run an isometric station for april fools once.
It was really cursed and flickered like crazy (which causes client lag). Fun as hell though.

The mode essentially overrides the layer/plane layering discussed before, and inserts new rules.
I wish I knew what those rules EXACTLY are, but I'm betting they're similar to [side map's](#side_map-check-the-main-page-too), and lummy's actually told me those.
Yes this is all rather poorly documented.

Similar to sidemap, we take physical position into account when deciding layering. In addition to its height positioning, we also account for width.
So both `pixel_y` and `pixel_x` can effect layering. `pixel_z` handles strictly visual y, and `pixel_w` handles x.

This has similar big icon problems to [sidemap](#side_map-check-the-main-page-too).

### [`TILED_ICON_MAP`](https://www.byond.com/docs/ref/#/{notes}/tiled-icons)

Legacy support for how byond rendering used to work. It essentially locked icon sizes to `/world/var/icon_size`, so if you tried to add an icon state larger then that,
it would be automatically broken down into smaller icon states, which you would need to manually display. Not something we need to care about

## Color

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/color)

`/atom/var/color` is another one like [pixel offsets](#pixel-offsets) where its most common use is really uninteresting, but it has an interesting
edge case I think is fun to discuss/important to know.

So let's get the base case out of the way shall we?

At base, you can set an atom's color to some `rrggbbaa` string (see [here](https://www.byond.com/docs/ref/#/{{appendix}}/html-colors)). This will shade every pixel on that atom to said color, and override its [`/atom/var/alpha`](https://www.byond.com/docs/ref/#/atom/var/alpha) value.
See [appearance flags](#appearance-flags) for how this effect can carry into overlays and such.

That's the boring stuff, now the fun shit.

> Before we get into this. `rr` is read as "red to red". `ag` is read as "alpha to green", etc. `c` is read as constant, and always has a value of 255

You can use the color variable to not just shade, but shift the colors of the atom.
It accepts a list (functionally a matrix if you know those) in the format `list(rr,br,gr,ar, rb,bb,gb,ab, rg,bg,gg,ag, ra,ba,ga,aa, cr,cb,cg,ca)`
This allows us to essentially multiply the color of each pixel by some other other. The values inserted in each multiple are not really bounded.

You can accomplish some really fun effects with this trick, it gives you a LOT of control over the color of a sprite or say, a [plane master](#planes)
and leads to some fun vfx.

> We have a debug tool for color matrixes. Just VV an atom, go to the VV dropdown and look for the `Edit Color as Matrix` entry.
> It'll help visualize this process quite well. Play around with it, it's fun.

## Transform

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/atom/var/transform)

`/atom/var/transform` allows you to shift, contort, rotate and scale atoms visually.
This is done using a matrix, similarly to color matrixes. You will likely never need to use it manually however, since there are
helper procs for pretty much everything it can do.

> Note: the transform var is COPIED whenever you read it. So if you want to modify it, you will need to reset the atom var back to your changes.

It's not totally without explanation, and I figured you might wanna know about it. Not a whole lot more to say tho. Neat tool.

## Lighting

- [Table of Contents](#table-of-contents)
- Reference: Hell of our own creation

I wanted to take this chance to briefly explain the essentials of how our lighting system works.
Essentially, each tile has a lighting [overlay](#overlays) (technically an [underlay](https://www.byond.com/docs/ref/#/atom/var/underlays)
which is just overlays but drawn under).
Anyway, each underlay is a color gradient, with red green and blue and alpha in each corner.
Every "corner" (we call them lighting corners) on the map impacts the 4 colors that touch it.
This is done with color matrixes. This allows us to apply color and lighting in a smooth way, while only needing 1 overlay per tile.

There's a lot of nuance here, like how color is calculated and stored, and our overlay lighting system which is a whole other beast.
But it covers the core idea, the rest should be derivable, and you're more qualified to do so then me, assuming some bastard will come along to change it
and forget to update this file.

## Animate()

- [Table of Contents](#table-of-contents)
- [Reference Entry](https://www.byond.com/docs/ref/#/proc/animate)

The animate proc allows us to VISUALLY transition between different values on an appearance on clients, while in actuality
setting the values instantly on the servers.

This is quite powerful, and lets us do many things, like slow fades, shakes, hell even parallax using matrixes.

It doesn't support everything, and it can be quite temperamental especially if you use things like the flag that makes it work in
parallel. It's got a lot of nuance to it, but it's real useful. Works on filters and their variables too, which is AGGRESSIVELY useful.

Lets you give radiation glow a warm pulse, that sort of thing.

## GAGS

- [Table of Contents](#table-of-contents)
- Reference: Hell of our own creation

GAGS is a system of our own design built to support runtime creation of icons from split components.

This means recoloring is trivial, and bits of sprites can be combined and split easily. Very useful.

I won't go into much detail here, check out the [starter guide](https://hackmd.io/@tgstation/GAGS-Walkthrough) for more info if you're interested.
