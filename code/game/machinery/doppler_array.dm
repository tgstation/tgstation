<<<<<<< HEAD
var/list/doppler_arrays = list()

/obj/machinery/doppler_array
	name = "tachyon-doppler array"
	desc = "A highly precise directional sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array.\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = 1
	anchored = 1
	var/integrated = 0
	var/max_dist = 100
	verb_say = "states coldly"

/obj/machinery/doppler_array/New()
	..()
	doppler_arrays += src

/obj/machinery/doppler_array/Destroy()
	doppler_arrays -= src
	return ..()

/obj/machinery/doppler_array/process()
	return PROCESS_KILL

/obj/machinery/doppler_array/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/wrench))
		if(!anchored && !isinspace())
			anchored = 1
			power_change()
			user << "<span class='notice'>You fasten [src].</span>"
		else if(anchored)
			anchored = 0
			power_change()
			user << "<span class='notice'>You unfasten [src].</span>"
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
	else
		return ..()

/obj/machinery/doppler_array/verb/rotate()
	set name = "Rotate Tachyon-doppler Dish"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return
	if(usr.stat || usr.restrained() || !usr.canmove)
		return
	src.setDir(turn(src.dir, 90))
	return

/obj/machinery/doppler_array/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(!in_range(src, user))
		return
	else
		rotate()

/obj/machinery/doppler_array/proc/sense_explosion(turf/epicenter,devastation_range,heavy_impact_range,light_impact_range,
												  took,orig_dev_range,orig_heavy_range,orig_light_range)
	if(stat & NOPOWER)
		return
	var/turf/zone = get_turf(src)

	if(zone.z != epicenter.z)
		return

	var/distance = get_dist(epicenter, zone)
	var/direct = get_dir(zone, epicenter)

	if(distance > max_dist)
		return
	if(!(direct & dir) && !integrated)
		return


	var/list/messages = list("Explosive disturbance detected.", \
							 "Epicenter at: grid ([epicenter.x],[epicenter.y]). Temporal displacement of tachyons: [took] seconds.", \
							 "Factual: Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range].")

	// If the bomb was capped, say it's theoretical size.
	if(devastation_range < orig_dev_range || heavy_impact_range < orig_heavy_range || light_impact_range < orig_light_range)
		messages += "Theoretical: Epicenter radius: [orig_dev_range]. Outer radius: [orig_heavy_range]. Shockwave radius: [orig_light_range]."

	if(integrated)
		var/obj/item/clothing/head/helmet/space/hardsuit/helm = loc
		if(!helm || !istype(helm, /obj/item/clothing/head/helmet/space/hardsuit))
			return
		helm.display_visor_message("Explosion detected! Epicenter: [devastation_range], Outer: [heavy_impact_range], Shock: [light_impact_range]")
	else
		for(var/message in messages)
			say(message)

/obj/machinery/doppler_array/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if(powered() && anchored)
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			icon_state = "[initial(icon_state)]-off"
			stat |= NOPOWER

//Portable version, built into EOD equipment. It simply provides an explosion's three damage levels.
/obj/machinery/doppler_array/integrated
	name = "integrated tachyon-doppler module"
	integrated = 1
	max_dist = 21 //Should detect most explosions in hearing range.
	use_power = 0
=======
var/list/doppler_arrays = list()

/obj/machinery/computer/bhangmeter
	name = "bhangmeter"
	desc = "Ancient technology used to measure explosions of all shapes and sizes. Has been recently outfitted by meteor monitoring software by Space Weather Inc."
	icon = 'icons/obj/computer.dmi'
	icon_state = "forensic"
	circuit = "/obj/item/weapon/circuitboard/bhangmeter"
	var/list/bangs = list()

/obj/machinery/computer/bhangmeter/New()
	..()
	doppler_arrays += src

/obj/machinery/computer/bhangmeter/Destroy()
	doppler_arrays -= src
	..()

/obj/machinery/computer/bhangmeter/process()
	return PROCESS_KILL

/obj/machinery/computer/bhangmeter/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/bhangmeter/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/bhangmeter/attack_hand(mob/user as mob)
	//user.set_machine(src)
	ui_interact(user)

/obj/machinery/computer/bhangmeter/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(stat & (BROKEN|NOPOWER))
		return

	var/list/data[0]
	var/list/explosions = list()
	for(var/list/bangarangs in bangs) //Removing sortAtom because nano updates it just enough for the lag to happen
		var/list/bang_data = list()
		bang_data["x"] = bangarangs["x"]
		bang_data["y"] = bangarangs["y"]
		bang_data["z"] = bangarangs["z"]
		bang_data["area"] = bangarangs["area"]
		bang_data["time"] = bangarangs["time"]
		bang_data["cap"] = bangarangs["cap"]
		bang_data["dev"] = bangarangs["dev"]
		bang_data["heavy"] = bangarangs["heavy"]
		bang_data["light"] = bangarangs["light"]
		bang_data["took"] = bangarangs["took"]
		bang_data["xoffset"] = bang_data["x"]-WORLD_X_OFFSET[z]
		bang_data["yoffset"] = bang_data["y"]-WORLD_Y_OFFSET[z]
		explosions += list(bang_data)
	data["explosions"] = explosions
	data["explosion_cap"] = MAX_EXPLOSION_RANGE

	if(!ui) //No ui has been passed, so we'll search for one
		ui = nanomanager.get_open_ui(user, src, ui_key)

	if(!ui)
		//The ui does not exist, so we'll create a new one
		ui = new(user, src, ui_key, "bhangmeter.tmpl", name, 900, 800)
		//Adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "bhangmeter_map_content.tmpl")
		//Adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "bhangmeter_map_header.tmpl")
		//When the UI is first opened this is the data it will use
		//We want to show the map by default
		ui.set_show_map(1)

		ui.set_initial_data(data)

		ui.open()
		//Auto update every Master Controller tick
		ui.set_auto_update(1)
	else
		//The UI is already open so push the new data to it
		ui.push_data(data)
		return

/obj/machinery/computer/bhangmeter/interact(mob/user as mob)
	var/listing = {"
<html>
	<head>
		<title>Nanotrasen Bhangmeter Mk. V</title>
	</head>
	<body>
		<h1>Recent Explosions</h1>
		<table>
			<tr>
				<th>Grid</th>
				<th>Power</th>
				<th>Temporal Displacement</th>
			</tr>
"}
	for(var/item in bangs)
		listing += item
	listing += {"
		</table>
	</body>
</html>"}
	user << browse(listing, "window=bhangmeter")
	onclose(user, "bhangmeter")
	return
/obj/machinery/computer/bhangmeter/proc/sense_explosion(var/x0, var/y0, var/z0, var/devastation_range, var/heavy_impact_range, var/light_impact_range, var/took, cap = 0, var/verbose = 1)
	if(stat & NOPOWER)
		return
	if(z != z0)
		return

	/*
	var/dx = abs(x0-x)
	var/dy = abs(y0-y)
	var/distance
	var/direct

	if(dx > dy)
		distance = dx
		if(x0 > x)	direct = EAST
		else		direct = WEST
	else
		distance = dy
		if(y0 > y)	direct = NORTH
		else		direct = SOUTH

	if(distance > 100)		return
	if(!(direct & dir))	return
	*/

	var/message = "Explosive disturbance detected - Epicenter at: grid ([x0-WORLD_X_OFFSET[z0]],[y0-WORLD_Y_OFFSET[z0]], [z0]). [cap ? "\[Theoretical Results\] " : ""]Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range]. Temporal displacement of tachyons: [took] second\s.  Data logged."
	if(verbose)
		say(message)
	//var/list/bang = params2list("x=[x0]&y=[y0]&z=[z0]&text=<tr><td>([worldtime2text()]) - ([x0-WORLD_X_OFFSET(z0)],[y0-WORLD_Y_OFFSET(z0)], [z0])</td><td>([cap ? "\[Theoretical Results\] " : ""][devastation_range],[heavy_impact_range],[light_impact_range])</td><td>[took]s</td></tr>")
	var/list/bang = list()
	bang["x"] = x0
	bang["y"] = y0
	bang["z"] = z0
	bang["time"] = worldtime2text()
	bang["cap"] = cap
	bang["dev"] = devastation_range
	bang["heavy"] = heavy_impact_range
	bang["light"] = light_impact_range
	bang["took"] = took
	bang["area"] = get_area(locate(x0,y0,z0))
	bangs += list(bang)
	nanomanager.update_uis(src)

/obj/machinery/doppler_array/say_quote(text)
	return "coldly states, [text]"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
