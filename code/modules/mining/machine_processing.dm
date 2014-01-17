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

	var/nloaded=0
	var/dat = {"
	<html>
		<head>
			<title>MinerX Ore Processing</title>
			<style type="text/css">
html,body {
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

a.smelting {
	color:white;
	font-weight:bold;
	text-decoration:none;
	background-color:green;
}

a.notsmelting {
	color:white;
	font-weight:bold;
	text-decoration:none;
	background-color:maroon;
}
			</style>
		</head>
		<body>
			<h1>Smelter Control</h1>
			<table>
				<tr>
					<th>Mineral</th>
					<th># Sheets</th>
					<th>Controls</th>
				</tr>"}
	for(var/ore_id in machine.ore)
		var/datum/material/ore_info=machine.ore[ore_id]
		if(ore_info.stored)
			// Can't do squat unless we have at least one.
			if(ore_info.stored<1)
				if(ore_info.selected)
					machine.on=0
				ore_info.selected=0
				machine.ore[ore_id]=ore_info
			dat += {"
			<tr>
				<td class="clmName">[ore_info.name]</td>
				<td>[ore_info.stored]</td>
				<td>
					<a href="?src=\ref[src];toggle_select=[ore_id]" "}
			if (ore_info.selected)
				dat += "class=\"smelting\">Smelting"
			else
				dat += "class=\"notsmelting\">Not smelting"
			dat += "</a></td></tr>"
			nloaded++
		else
			ore_info.selected=0
			machine.ore[ore_id]=ore_info
	if(nloaded)
		dat += {"
			</table>
			<p>Machine is currently "}
		//On or off
		if (machine.on==1)
			dat += "<A href='?src=\ref[src];set_on=off'>On</A></p>"
		else
			dat += "<A href='?src=\ref[src];set_on=on'>Off</A></p>"
	else
		dat+="<tr><td colspan=\"3\"><em>No Materials Loaded</em></td></tr></table>"
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
		var/ore_id=href_list["toggle_select"]
		if (!(ore_id in machine.ore))
			error("Unknown ore ID [ore_id]!")
		var/datum/material/ore_info=machine.ore[ore_id]
		ore_info.selected = !ore_info.selected
		machine.ore[ore_id]=ore_info
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

	var/list/ore=list()
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

		for(var/oredata in typesof(/datum/material) - /datum/material)
			var/datum/material/ore_datum = new oredata
			ore[ore_datum.id]=ore_datum

		for(var/recipetype in typesof(/datum/smelting_recipe) - /datum/smelting_recipe)
			var/datum/smelting_recipe/recipe= new recipetype
			// Sanity
			for(var/ingredient in recipe.ingredients)
				if(!(ingredient in ore))
					warning("Unknown ingredient [ingredient] in recipe [recipe.name]!")
			recipes += recipe

		return
	return

/obj/machinery/mineral/processing_unit/proc/addMaterial(var/ore_id,var/amount)
	if(!(ore_id in ore))
		warning("addMaterial(): Unknown material [ore_id]!")
		return
	var/datum/material/po=ore[ore_id]
	po.stored += amount
	ore[ore_id]=po


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
							// Oh how I wish ore[ore_id].stored-- worked.
							var/datum/material/po=ore[ore_id]
							po.stored--
							ore[ore_id]=po

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
					for(var/ore_id in ore)
						var/datum/material/po=ore[ore_id]
						if(po.stored>0 && po.selected)
							po.stored--
							ore[ore_id]=po
					// Spawn slag
					new /obj/item/weapon/ore/slag(output.loc)
					break

		// Collect ore even if not on.
		for (i = 0; i < 10; i++)
			var/obj/item/O
			O = locate(/obj/item, input.loc)
			if (O)
				for(var/ore_id in ore)
					var/datum/material/po=ore[ore_id]
					if (istype(O,po.oretype))
						po.stored++
						ore[ore_id]=po
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
	var/list/ALLOWED_TYPES=list(
		/obj/item,
		/obj/machinery/portable_atmospherics/canister,
		/obj/structure/closet
	)


/obj/machinery/mineral/processing_unit/recycle/process()
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
							// Oh how I wish ore[ore_id].stored-- worked.
							var/datum/material/po=ore[ore_id]
							po.stored--
							ore[ore_id]=po

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
					for(var/ore_id in ore)
						var/datum/material/po=ore[ore_id]
						if(po.stored>0 && po.selected)
							po.stored--
							ore[ore_id]=po
					// Spawn slag
					new /obj/item/weapon/ore/slag(output.loc)
					break

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
						//O.loc=null
						del(O)
						break
				if(O && istype(O,/obj/item))
					O.loc = src.output.loc
					break


/obj/machinery/mineral/processing_unit_console/recycle/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/mineral/processing_unit_console/recycle/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/mineral/processing_unit_console/recycle/attack_hand(var/mob/user as mob)
	return src.interact(user)

/obj/machinery/mineral/processing_unit_console/recycle/interact(var/mob/user as mob)

	user.set_machine(src)
	var/nloaded=0
	var/html = {"<html>
	<head>
		<title>Recyk Processor</title>
		<style type="text/css">
html,body {
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

a.smelting {
	color:white;
	font-weight:bold;
	text-decoration:none;
	background-color:green;
}

a.notsmelting {
	color:white;
	font-weight:bold;
	text-decoration:none;
	background-color:maroon;
}
		</style>
	</head>
	<body>
		<h1>Recyk PRO-1000</h1>
		<p><b>Current Status:</b> (<a href='?src=\ref[user];mach_close=recyk_furnace'>Close</a>)</p>
		<table>
			<tr>
				<th>Mineral</th>
				<th># Sheets</th>
				<th>Controls</th>
			</tr>"}
	for(var/ore_id in machine.ore)
		var/datum/material/ore_info=machine.ore[ore_id]
		if(ore_info.stored)
			// Can't do squat unless we have at least one.
			if(ore_info.stored<1)
				if(ore_info.selected)
					machine.on=0
				ore_info.selected=0
				machine.ore[ore_id]=ore_info
			html += {"
			<tr>
				<td class="clmName">[ore_info.name]</td>
				<td>[ore_info.stored]</td>
				<td>
					<a href="?src=\ref[src];toggle_select=[ore_id]" "}
			if (ore_info.selected)
				html += "class=\"smelting\">Smelting"
			else
				html += "class=\"notsmelting\">Not smelting"
			html += "</a></td></tr>"
			nloaded++
		else
			ore_info.selected=0
			machine.ore[ore_id]=ore_info
	if(nloaded)
		html += {"
			</table>
			<p>Machine is currently "}
		//On or off
		if (machine.on==1)
			html += "<A href='?src=\ref[src];set_on=off'>On</A></p>"
		else
			html += "<A href='?src=\ref[src];set_on=on'>Off</A></p>"
	else
		html+="<tr><td colspan=\"3\"><em>No Materials Loaded</em></td></tr></table>"
	html +={"
	</body>
</html>
	"}

	user << browse(html, "window=recyk_furnace;size=600x300")
	onclose(user, "recyk_furnace")
	return