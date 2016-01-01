<!-- TOC depth:6 withLinks:1 updateOnSave:0 orderedList:0 -->

- [NanoUI](#nanoui)
	- [Introduction](#introduction)
	- [Components](#components)
		- [`ui_interact()`](#uiinteract)
		- [`get_ui_data()`](#getuidata)
		- [`Topic()`](#topic)
		- [Template (doT)](#template-dot)
			- [Helpers](#helpers)
				- [Link](#link)
				- [Bar](#bar)
			- [doT](#dot)
			- [Styling](#styling)
	- [Contributing](#contributing)

<!-- /TOC -->

# NanoUI

## Introduction

NanoUI is the user interface library of /tg/station. While more complex than
traditional `browse()`/stringbuilder based interfaces, it allows much more
control over display of data and gives you many features for free, such as
different `CanUseTopic()` checks (in range/is robot/in inventory/in hand/etc),
automatic refresh, attractive looks, and helpers that make writing interfaces
much easier.

NanoUI adds a `ui_interact()` proc to all atoms, which should be called from
`interact()`. The interact proc can be called from anywhere in the atom (usually
 `attack_self()` or `attack_hand()`), and is where all checks should be made.
 The `ui_interact()` proc should only include NanoUI code.

Baystation12's version of NanoUI, while slightly different in syntax, has a
good [reference](http://wiki.baystation12.net/NanoUI).

Here is a real example from
[tanks.dm](https://github.com/tgstation/-tg-station/blob/master/code/game/objects/items/weapons/tanks/tanks.dm).

    /obj/item/weapon/tank/attack_self(mob/user)
    	if (!user)
    		return
    	interact(user)

    /obj/item/weapon/tank/interact(mob/user)
    	add_fingerprint(user)
    	ui_interact(user)

    /obj/item/weapon/tank/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, force_open = 0)
    	ui = SSnano.try_update_ui(user, src, ui_key, ui, force_open = force_open)
    	if (!ui)
    		ui = new(user, src, ui_key, "tanks", name, 525, 175, state = inventory_state)
    		ui.open()




## Components

### `ui_interact()`

The`ui_interact()` proc is used to open a NanoUI (or update it if already open).
As NanoUI will call this proc to update your UI, you should not put any logic in
it, as NanoUI handles the logic for you.

The parameters for `try_update_ui` and `/datum/nanoui/new()` are documented in
the code [here](https://github.com/tgstation/-tg-station/tree/master/code/modules/nano).
The most interesting parameter is `state`, which allows the object to choose the
checks that allow the UI to be interacted with.

The default state (`default_state`) checks that the user is alive, conscious,
and within a few tiles. It allows universal access to silicons. Other states
exist, and may be more appropriate for different interfaces. For example,
`physical_state` requires the user to be nearby, even if they are a silicon.
`inventory_state` checks that the user has the object in their first-level
(not container) inventory, this is suitable for devices such as radios;
`notcontained_state` checks that the user is outside the object (great for cryo
and similar machines).

    /obj/item/the/thing/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, force_open = 0)
    	ui = SSnano.try_update_ui(user, src, ui_key, ui, force_open = force_open)
    	if (!ui)
    		ui = new(user, src, ui_key, "template", title, width, height)
    		ui.open()

### `get_ui_data()`

The `get_ui_data()` proc returns a list which is used to populate the `data`
variable in the UI. This is where you should pass variables from your atom to
the UI. Here's another example from tanks.dm.

    /obj/item/weapon/tank/get_ui_data()
    	var/mob/living/carbon/location = null

    	if(istype(loc, /mob/living/carbon))
    		location = loc
    	else if(istype(loc.loc, /mob/living/carbon))
		location = loc.loc

    	var/data = list()
    	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
    	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
    	data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
    	data["minReleasePressure"] = round(TANK_MIN_RELEASE_PRESSURE)
    	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)
    	data["valveOpen"] = 0
    	data["maskConnected"] = 0

    	if(istype(location))
    		var/mask_check = 0

    		if(location.internal == src)	// if tank is current internal
    			mask_check = 1
    			data["valveOpen"] = 1
    		else if(src in location)		// or if tank is in the mobs possession
    			if(!location.internal)		// and they do not have any active internals
    				mask_check = 1

    		if(mask_check)
    			if(location.wear_mask && (location.wear_mask.flags & MASKINTERNALS))
    				data["maskConnected"] = 1
    	return data

This data can be accessed inside the NanoUI. For example, to find out if the
mask is connected (as checked near the end of the proc), we simply use
`data.maskConnected` in our template.

### `Topic()`

`Topic()` handles input from the UI. Typically you will recieve some data from
a button press, or pop up a input dialog to take a numerical value from the
user. Sanity checking is useful here, as `Topic()` is trivial to spoof with
arbitrary data.

The `Topic()` interface is just the same as with more conventional,
stringbuilder-based UIs, and this needs little explanation.

    /obj/item/weapon/tank/Topic(href, href_list)
    	if (..())
    		return

    	if (href_list["dist_p"])
    		if (href_list["dist_p"] == "custom")
    			var/custom = input(usr, "What rate do you set the regulator to? The dial reads from 0 to [TANK_MAX_RELEASE_PRESSURE].") as null|num
    			if(isnum(custom))
    				href_list["dist_p"] = custom
    				.()
    		else if (href_list["dist_p"] == "reset")
    			distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
    		else if (href_list["dist_p"] == "min")
    			distribute_pressure = TANK_MIN_RELEASE_PRESSURE
    		else if (href_list["dist_p"] == "max")
    			distribute_pressure = TANK_MAX_RELEASE_PRESSURE
    		else
    			distribute_pressure = text2num(href_list["dist_p"])
    		distribute_pressure = min(max(round(distribute_pressure), TANK_MIN_RELEASE_PRESSURE), TANK_MAX_RELEASE_PRESSURE)
    	if (href_list["stat"])
    		if(istype(loc,/mob/living/carbon))
    			var/mob/living/carbon/location = loc
    			if(location.internal == src)
    				location.internal = null
    				location.internals.icon_state = "internal0"
    				usr << "<span class='notice'>You close the tank release valve.</span>"
    				if (location.internals)
    					location.internals.icon_state = "internal0"
    			else
    				if(location.wear_mask && (location.wear_mask.flags & MASKINTERNALS))
    					location.internal = src
    					usr << "<span class='notice'>You open \the [src] valve.</span>"
    					if (location.internals)
    						location.internals.icon_state = "internal1"
    				else
    					usr << "<span class='warning'>You need something to connect to \the [src]!</span>"

### Template (doT)

NanoUI templates are written in [doT](https://olado.github.io/doT/index.html),
a Javascript template engine. Data is accessed from the `data` object,
configuration (not used in pratice) from the `config` object, and template
helpers are accessed from the `helper` object.

#### Helpers

##### Link

    {{=helpers.link(text, icon, {'parameter': true}, status, class)}}

Used to create a link (button), which will pass its parameters to `Topic()`.

* Text: The text content of the link/button
* Icon: The icon shown to the left of the link (http://fontawesome.io/)
* Parameters: The values to be passed to `Topic()`'s `href_list`.
* Status: `null` for clickable, a class for selected/unclickable.
* Class: Styling to apply to the link.

Status and Class have almost the same effect. However, changing a link's status
from `null` to something else makes it unclickable, while setting a custom Class
does not.

Ternary operators are often used to avoid writing many `if` statements.
For example, depending on if a value in `data` is true or false we can set a
button to clickable or selected:

    {{=helper.link('Close', 'lock', {'stat': 1}, data.valveOpen ? null : 'selected')}}

Available classes/statuses are:

* null (normal)
* selected
* caution
* danger
* disabled

##### Bar

    {{=helpers.bar(value, min, max, class, text)}}

Used to create a bar, to display a numerical value visually. Min and Max default
to 0 and 100, but you can change them to avoid doing your own percent calculations.

* Value: Defaults to a percentage but can be a straight number if Min/Max are set
* Min: The minimum value (left hand side) of the bar
* Max: The maximum value (right hand side) of the bar
* Class: The color of the bar (null/normal, good, average, bad)
* Text: The text label for the data contained in the bar (often just number form)

As with buttons, ternary operators are quite useful:

    {{=helper.bar(data.tankPressure, 0, 1013, (data.tankPressure > 200) ? 'good' : ((data.tankPressure > 100) ? 'average' : 'bad'))}}

#### doT

doT is a simple template language, with control statements mixed in with
regular HTML and interpolation expressions.

Here is a simple example from tanks, checking if a variable is true:

    {{? data.maskConnected}}
    	<span>The regulator is connected to a mask.</span>
    {{??}}
    	<span>The regulator is not connected to a mask.</span>
    {{?}}

The doT tutorial is [here](https://olado.github.io/doT/tutorial.html).

Print:

    {{=expression }}

Print (with escape):

    {{!expression }}

If/Else If/Else

    {{? condition}}
    // if
    {{?? condition}}
    // else if
    {{??}}
    // else
    {{?}}

For

    {{~ object:key:index}}
    // key, value
    {{~}}

#### Styling

For the most part, a NanoUI is just normal HTML. However, to use the NanoUI
styles correctly, you have to be concious of a few elements.

A `<article class="display">` is the building block of most NanoUIs, and
represents the wells/blocks you see in most NanoUIs. Inside said article should
be a `<header>` labeling it, and many `<section>`s representing items inside
(such as a label/button pair). The styling is highly subjective, so ask a
regular contribuitor to NanoUI (@neersighted at time of writing) to take a look
at and help style your UI.

Here's an example of UI styling from Air Alarms:

    <article class="display">
    	<header><h2>Air Status</h2></header>
    	{{? data.environment_data}}
    		{{~ data.environment_data:info:i}}
    			<section class="text">
    				<span class="label">
    					{{=info.name}}:
    				</span>
    				<div class="content">
    					{{? info.danger_level == 2}}
    						<span class='bad'>
    					{{?? info.danger_level == 1}}
    						<span class='average'>
    					{{??}}
    						<span class='good'>
    					{{?}}
    					{{=helper.fixed(info.value, 2)}}{{=info.unit}}</span>
    				</div>
    			</section>
    		{{~}}
    		<section class="text">
    			<span class="label">
    				Local Status:
    			</span>
    			<div class="content">
    				{{? data.danger_level == 2}}
    					<span class='bad bold'>Danger (Internals Required)</span>
    				{{?? data.danger_level == 1}}
    					<span class='average bold'>Caution</span>
    				{{??}}
    					<span class='good'>Optimal</span>
    				{{?}}
    			</div>
    		</section>
    		<section class="text">
    			<span class="label">
    				Area Status:
    			</span>
    			<div class="content">
    				{{? data.atmos_alarm}}
    					<span class='bad bold'>Atmosphere Alarm</span>
    				{{?? data.fire_alarm}}
    					<span class='bad bold'>Fire Alarm</span>
    				{{??}}
    					<span class='good'>Nominal</span>
    				{{?}}
    			</div>
    		</section>
    	{{??}}
    		<section><span class='bad bold'>Warning: Cannot obtain air sample for analysis.</span></section>
    	{{?}}
    	{{? data.dangerous}}
    		<hr />
    		<section>
    			<span class='bad bold'>Warning: Safety measures offline. Device may exhibit abnormal behavior.</span>
    		</section>
    	{{?}}
    </article>

## Contributing

There are a few gotchas when it comes to writing for NanoUI. In order to
simplify server code and make the UI more responsive, we precompile all
templates to Javascript. In addition, Coffeescript and LESS are used to make
development easier, and also need to be precompiled. Precompiling CSS also
allows us to add fallbacks for old versions of Internet Explorer.

To compile NanoUI (which you will need to do after adding or updating a
template), first install [Node.js](https://nodejs.org).

Next, you will need to install packages used by NanoUI:

    cd nanoui/
    npm install -g gulp bower
    npm install
    bower install

Finally, to compile NanoUI, run Gulp:

    gulp

Every time you make an update, you will need to recompile. Before comitting,
make sure you minimize the files with Gulp:

    gulp --min

If you would like to view your changes without restarting, run Gulp reload:

    gulp reload

Finally, if you want to auto-compile and reload on save, run Gulp watch:

    gulp watch
