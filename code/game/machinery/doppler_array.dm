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
