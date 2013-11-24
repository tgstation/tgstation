
client/proc/Zone_Info(turf/T as null|turf)
	set category = "Debug"
	if(T)
		if(T.zone)
			T.zone.DebugDisplay(src)
		else
			mob << "No zone here."
	else
		if(zone_debug_images)
			for(var/zone in  zone_debug_images)
				images -= zone_debug_images[zone]
			zone_debug_images = null

client/var/list/zone_debug_images

client/proc/Test_ZAS_Connection(var/turf/simulated/T as turf)
	set category = "Debug"
	if(!istype(T))
		return

	var/direction_list = list(\
	"North" = NORTH,\
	"South" = SOUTH,\
	"East" = EAST,\
	"West" = WEST,\
	"N/A" = null)
	var/direction = input("What direction do you wish to test?","Set direction") as null|anything in direction_list
	if(!direction)
		return

	if(direction == "N/A")
		if(T.CanPass(null, T, 0,0))
			mob << "The turf can pass air! :D"
		else
			mob << "No air passage :x"
		return

	var/turf/simulated/other_turf = get_step(T, direction_list[direction])
	if(!istype(other_turf))
		return

	var/pass_directions = T.CanPass(null, other_turf, 0, 0) + 2 * other_turf.CanPass(null, T, 0, 0)

	switch(pass_directions)
		if(0)
			mob << "Neither turf can connect. :("

		if(1)
			mob << "The initial turf only can connect. :\\"

		if(2)
			mob << "The other turf can connect, but not the initial turf. :/"

		if(3)
			mob << "Both turfs can connect! :)"


zone/proc/DebugDisplay(client/client)
	if(!istype(client))
		return

	if(!dbg_output)
		dbg_output = 1 //Don't want to be spammed when someone investigates a zone...

		if(!client.zone_debug_images)
			client.zone_debug_images = list()

		var/list/current_zone_images = list()

		for(var/turf/T in contents)
			current_zone_images += image('icons/misc/debug_group.dmi', T, null, TURF_LAYER)

		for(var/turf/space/S in unsimulated_tiles)
			current_zone_images += image('icons/misc/debug_space.dmi', S, null, TURF_LAYER)

		client << "<u>Zone Air Contents</u>"
		client << "Oxygen: [air.oxygen]"
		client << "Nitrogen: [air.nitrogen]"
		client << "Plasma: [air.toxins]"
		client << "Carbon Dioxide: [air.carbon_dioxide]"
		client << "Temperature: [air.temperature] K"
		client << "Heat Energy: [air.temperature * air.heat_capacity()] J"
		client << "Pressure: [air.return_pressure()] KPa"
		client << ""
		client << "Space Tiles: [length(unsimulated_tiles)]"
		client << "Movable Objects: [length(movables())]"
		client << "<u>Connections: [length(connections)]</u>"

		for(var/connection/C in connections)
			client << "\ref[C] [C.A] --> [C.B] [(C.indirect?"Open":"Closed")]"
			current_zone_images += image('icons/misc/debug_connect.dmi', C.A, null, TURF_LAYER)
			current_zone_images += image('icons/misc/debug_connect.dmi', C.B, null, TURF_LAYER)

		client << "Connected Zones:"
		for(var/zone/zone in connected_zones)
			client << "\ref[zone] [zone] - [connected_zones[zone]] (Connected)"

		for(var/zone/zone in closed_connection_zones)
			client << "\ref[zone] [zone] - [closed_connection_zones[zone]] (Unconnected)"

		for(var/C in connections)
			if(!istype(C,/connection))
				client << "[C] (Not Connection!)"

		if(!client.zone_debug_images)
			client.zone_debug_images = list()
		client.zone_debug_images[src] = current_zone_images

		client.images += client.zone_debug_images[src]

	else
		dbg_output = 0

		client.images -= client.zone_debug_images[src]
		client.zone_debug_images.Remove(src)

	for(var/zone/Z in zones)
		if(Z.air == air && Z != src)
			var/turf/zloc = pick(Z.contents)
			client << "\red Illegal air datum shared by: [zloc.loc.name]"

