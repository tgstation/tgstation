/**********************Mineral processing unit console**************************/

/obj/machinery/mineral/processing_unit_console
	name = "production machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/processing_unit/machine = null
	var/machinedir = EAST

/obj/machinery/mineral/processing_unit_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/mineral/processing_unit, get_step(src, machinedir))
		if (machine)
			machine.CONSOLE = src
		else
			del(src)

/obj/machinery/mineral/processing_unit_console/process()
	updateDialog()

/obj/machinery/mineral/processing_unit_console/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/mineral/processing_unit_console/interact(mob/user)
	user.set_machine(src)

	var/dat = {"
	<html>
		<head>
			<title>MinerX Ore Processing</title>
			<style type="text/css">
				<style type="text/css">
* {
	font-family:sans-serif,verdana;
	font-size:smaller;
	color:#666;
}
h1 {
	border-bottom:1px solid maroon;
}
table {
	border-spacing: 0;
	border-collapse: collapse;
}
td, th {
	margin: 0;
	font-size: small;
	border-bottom: 1px solid #ccc;
	padding: 3px;
}

tr:nth-child(even) {
	background: #efefef;
}

span.smelting {
	color:green;
	font-weight:bold;
}

				</style>
			</style>
		</head>
		<body>
			<h1>Smelter Control</h1>
			<table>
				<tr>
					<th>Mineral</th>
					<th>Amount</th>
					<th>Controls</th>
				</tr>"}
	//iron
	if(machine.selected.len>0)
		for(var/ore_id in machine.selected)
			if(machine.ore[ore_id])
				dat += "<tr><td class=\"clmName\">[machine.ore_names[ore_id]]:</td><td>[machine.ore[ore_id]]</td><td><A href='?src=\ref[src];toggle_select=[ore_id]'>"
				if (machine.selected[ore_id]==1)
					dat += "<span class=\"smelting\">Smelting</span>"
				else
					dat += "<span class=\"notsmelting\">Not smelting</span>"
				dat += "</A></td></tr>"
			else
				machine.selected[ore_id] = 0

		dat += {"
			</table>
			<p>Machine is currently "}
		//On or off
		if (machine.on==1)
			dat += text("<A href='?src=\ref[src];set_on=off'>On</A></p>")
		else
			dat += text("<A href='?src=\ref[src];set_on=on'>Off</A></p>")
	else
		dat+="<em>No Materials Loaded</em>"
	dat+={"
		</body>
	</html>"}


	user << browse(dat, "window=console_processing_unit")
	onclose(user, "console_processing_unit")


/obj/machinery/mineral/processing_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["toggle_select"])
		if (!(href_list["toggle_select"] in machine.selected))
			error("Unknown ore ID [href_list["toggle_select"]]!")
		machine.selected[href_list["toggle_select"]] = !machine.selected[href_list["toggle_select"]]
	if(href_list["set_on"])
		if (href_list["set_on"] == "on")
			machine.on = 1
		else
			machine.on = 0
	src.updateUsrDialog()
	return

/**********************Mineral processing unit**************************/




/obj/machinery/mineral/processing_unit
	name = "furnace"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/obj/machinery/mineral/CONSOLE = null

	// Can probably combine all 4 of these into a single datum store, but hindsight is 20/20. - N3X
	var/list/ore=list(
		"gold" = 0,
		"silver" = 0,
		"diamond" = 0,
		"glass" = 0,
		"plasma" = 0,
		"uranium" = 0,
		"iron" = 0,
		"clown" = 0,
		//"adamantine" = 0,
		"phazon" = 0,
	)

	var/list/selected=list(
		"gold" = 0,
		"silver" = 0,
		"diamond" = 0,
		"glass" = 0,
		"plasma" = 0,
		"uranium" = 0,
		"iron" = 0,
		"clown" = 0,
		//"adamantine" = 0,
		"phazon" = 0,
	)

	var/list/ore_names=list(
		"gold" = "Gold",
		"silver" = "Silver",
		"diamond" = "Diamond",
		"glass" = "Sand",
		"plasma" = "Plasma",
		"uranium" = "Uranium",
		"iron" = "Iron",
		"clown" = "Bananium",
		//"adamantine" = "Adamantine",
		"phazon" = "Phazon",
	)

	var/list/ore_types=list(
		"iron" = /obj/item/weapon/ore/iron,
		"glass" = /obj/item/weapon/ore/glass,
		"diamond" = /obj/item/weapon/ore/diamond,
		"plasma" = /obj/item/weapon/ore/plasma,
		"gold" = /obj/item/weapon/ore/gold,
		"silver" = /obj/item/weapon/ore/silver,
		"uranium" = /obj/item/weapon/ore/uranium,
		"clown" = /obj/item/weapon/ore/clown,
		"phazon" = /obj/item/weapon/ore/phazon,
		//"adamantine" = /obj/item/weapon/ore/adamantine
	)
	var/list/recipes=list()
	var/on = 0 //0 = off, 1 =... oh you know!

/obj/machinery/mineral/processing_unit/New()
	..()
	spawn( 5 )
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
		processing_objects.Add(src)

		for(var/recipetype in typesof(/datum/smelting_recipe) - /datum/smelting_recipe)
			recipes += new recipetype
		return
	return

/obj/machinery/mineral/processing_unit/process()
	if (src.output && src.input)
		var/i
		if(on)
			for (i = 0; i < 10; i++)
				var/located=0
				var/insufficient_ore=0
				// For every recipe
				for(var/datum/smelting_recipe/recipe in recipes)
					// Check if it's selected and we have the ingredients
					var/signal=recipe.checkIngredients(src)

					// If we have a matching recipe but we're out of ore,
					// Shut off but DO NOT spawn slag.
					if(signal==-1)
						insufficient_ore=1
						break

					// Otherwise, if we've matched
					else if(signal==1)
						// Take ingredients
						for(var/ore_id in recipe.ingredients)
							ore[ore_id]--

						// Spawn yield
						new recipe.yieldtype(output.loc)

						located=1
						break
				if(insufficient_ore)
					on=0
					break

				// If we haven't found a matching recipe,
				if(!located)
					// Turn off
					on=0

					// Take one of every ore selected
					for(var/ore_id in selected)
						if(ore[ore_id]>0)
							ore[ore_id]--
					// Spawn slag
					new /obj/item/weapon/ore/slag(output.loc)
					break

		// Collect ore even if not on.
		for (i = 0; i < 10; i++)
			var/obj/item/O
			O = locate(/obj/item, input.loc)
			if (O)
				for(var/ore_id in ore)
					if (istype(O,ore_types[ore_id]))
						ore[ore_id]++;
						O.loc = null
						del(O)
						break
				if(O)
					O.loc = src.output.loc
			else
				break
	return

/////////////////////////////////////////////////
// Recycling Furnace
/obj/machinery/mineral/processing_unit/recycle
	name = "recycling furnace"
	var/gold = 0;
	var/silver = 0;
	var/diamond = 0;
	var/glass = 0;
	var/plasma = 0;
	var/uranium = 0;
	var/iron = 0;
	var/clown = 0;
	var/adamantine = 0;
	var/phazon = 0;
	var/list/ALLOWED_TYPES=list(
		/obj/item,
		/obj/machinery/portable_atmospherics/canister,
	)


/obj/machinery/mineral/processing_unit/recycle/process()
	if (src.output && src.input)
		var/i
		//if(!(stat & (BROKEN|UNPOWERED)))
		for (i = 0; i < 10; i++)
			if (glass >= 1)
				glass--;
				new /obj/item/stack/sheet/glass(output.loc)

			if (gold >= 1)
				gold--;
				new /obj/item/stack/sheet/mineral/gold(output.loc)

			if (silver >= 1)
				silver--;
				new /obj/item/stack/sheet/mineral/silver(output.loc)

			if (diamond >= 1)
				diamond--;
				new /obj/item/stack/sheet/mineral/diamond(output.loc)

			if (plasma >= 1)
				plasma--;
				new /obj/item/stack/sheet/mineral/plasma(output.loc)

			if (uranium >= 1)
				uranium--;
				new /obj/item/stack/sheet/mineral/uranium(output.loc)

			if (iron >= 1)
				iron--;
				new /obj/item/stack/sheet/metal(output.loc)

			if (clown >= 1)
				clown--;
				new /obj/item/stack/sheet/mineral/clown(output.loc)

			if (phazon >= 1)
				clown--;
				new /obj/item/stack/sheet/mineral/phazon(output.loc)

		for (i = 0; i < 10; i++)
			var/obj/O
			for(O in input.loc.contents)
				var/allowed=0
				for(var/T in ALLOWED_TYPES)
					if(istype(O,T))
						allowed=1
						break
				if(O && allowed)
					if (O.recycle(src))
						del(O)
					else
						O.loc = src.output.loc


/obj/machinery/mineral/processing_unit/recycle/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/mineral/processing_unit/recycle/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/mineral/processing_unit/recycle/attack_hand(var/mob/user as mob)
	return src.interact(user)

/obj/machinery/mineral/processing_unit/recycle/interact(var/mob/user as mob)

	user.set_machine(src)
	var/found=0
	var/html = {"<html>
	<head>
		<title>Recyk Processor</title>
	</head>
	<body>
		<h1>Recyk PRO-1000</h1>
		<p><b>Current Status:</b> (<a href='?src=\ref[user];mach_close=recyk_furnace'>Close</a>)</p>
		<ul>
	"}
	if(adamantine > 0.0)
		html += "<li><b>Adamantine:</b> [adamantine]</li>"
		found=1
	if(clown > 0.0)
		html += "<li><b>Bananaium:</b> [clown]</li>"
		found=1
	if(diamond > 0.0)
		html += "<li><b>Diamond:</b> [diamond]</li>"
		found=1
	if(glass > 0.0)
		html += "<li><b>Glass:</b> [glass]</li>"
		found=1
	if(gold > 0.0)
		html += "<li><b>Gold:</b> [gold]</li>"
		found=1
	if(iron > 0.0)
		html += "<li><b>Iron:</b> [iron]</li>"
		found=1
	if(plasma > 0.0)
		html += "<li><b>Plasma:</b> [plasma]</li>"
		found=1
	if(silver > 0.0)
		html += "<li><b>Silver:</b> [silver]</li>"
		found=1
	if(uranium > 0.0)
		html += "<li><b>Uranium:</b> [uranium]</li>"
		found=1
	if(phazon > 0.0)
		html += "<li><b>Phazon:</b> [phazon]</li>"
		found=1
	if(!found)
		html += "<li><i>(Nothing loaded yet!)</i></li>"
	html +={"
		</ul>
		<p><i>(Units are sheets)</i></p>
	</body>
</html>
	"}

	//"<A href='?src=\ref[src];toggle=1'>[valve_open?("Open"):("Closed")]</A><BR>

	user << browse(html, "window=recyk_furnace;size=600x300")
	onclose(user, "canister")
	return

/obj/machinery/mineral/processing_unit/recycle/Topic(href, href_list)

	//Do not use "if(..()) return" here, canisters will stop working in unpowered areas like space or on the derelict.
	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=recyk_furnace")
		onclose(usr, "recyk_furnace")
		return