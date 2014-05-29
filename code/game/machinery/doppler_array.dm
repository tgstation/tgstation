var/list/doppler_arrays = list()

/obj/machinery/computer/bhangmeter
	name = "bhangmeter"
	desc = "Ancient technology used to measure explosions of all shapes and sizes."
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
	user.set_machine(src)
	interact(user)

/obj/machinery/computer/bhangmeter/interact(mob/user as mob)
	var/listing={"
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
/obj/machinery/computer/bhangmeter/proc/sense_explosion(var/x0,var/y0,var/z0,var/devastation_range,var/heavy_impact_range,var/light_impact_range,var/took, cap = 0)
	if(stat & NOPOWER)	return
	if(z != z0)			return

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

	var/message = "Explosive disturbance detected - Epicenter at: grid ([x0-WORLD_X_OFFSET],[y0-WORLD_Y_OFFSET]). [cap ? "\[Theoretical Results\] " : ""]Epicenter radius: [devastation_range]. Outer radius: [heavy_impact_range]. Shockwave radius: [light_impact_range]. Temporal displacement of tachyons: [took]seconds.  Data logged."
	src.visible_message( \
		"<span class='game say'><span class='name'>[src]</span> states coldly, \"[message]\"</span>", \
		"You hear muffled speech." \
	)
	var/bang = "<tr><td>([x0-WORLD_X_OFFSET],[y0-WORLD_Y_OFFSET])</td><td>([cap ? "\[Theoretical Results\] " : ""][devastation_range],[heavy_impact_range],[light_impact_range])</td><td>[took]s</td></tr>"
	bangs+=bang