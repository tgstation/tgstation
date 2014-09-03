client/proc/ZoneTick()
	set category = "Debug"
	set name = "Process Atmos"

	var/result = air_master.Tick()
	if(result)
		src << "Sucessfully Processed."

	else
		src << "Failed to process! ([air_master.tick_progress])"


client/proc/Zone_Info(turf/T as null|turf)
	set category = "Debug"
	if(T)
		if(istype(T,/turf/simulated) && T:zone)
			T:zone:dbg_data(src)
		else
			mob << "No zone here."
			var/datum/gas_mixture/mix = T.return_air()
			mob << "[mix.return_pressure()] kPa [mix.temperature]C"
			mob << "O2: [mix.oxygen] N2: [mix.nitrogen] CO2: [mix.carbon_dioxide] TX: [mix.toxins]"
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
		if(!(T.c_airblock(T) & AIR_BLOCKED))
			mob << "The turf can pass air! :D"
		else
			mob << "No air passage :x"
		return

	var/turf/simulated/other_turf = get_step(T, direction_list[direction])
	if(!istype(other_turf))
		return

	var/t_block = T.c_airblock(other_turf)
	var/o_block = other_turf.c_airblock(T)

	if(o_block & AIR_BLOCKED)
		if(t_block & AIR_BLOCKED)
			mob << "Neither turf can connect. :("

		else
			mob << "The initial turf only can connect. :\\"
	else
		if(t_block & AIR_BLOCKED)
			mob << "The other turf can connect, but not the initial turf. :/"

		else
			mob << "Both turfs can connect! :)"

	mob << "Additionally, \..."

	if(o_block & ZONE_BLOCKED)
		if(t_block & ZONE_BLOCKED)
			mob << "neither turf can merge."
		else
			mob << "the other turf cannot merge."
	else
		if(t_block & ZONE_BLOCKED)
			mob << "the initial turf cannot merge."
		else
			mob << "both turfs can merge."


/*zone/proc/DebugDisplay(client/client)
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

	if(air_master)
		for(var/zone/Z in air_master.zones)
			if(Z.air == air && Z != src)
				var/turf/zloc = pick(Z.contents)
				client << "\red Illegal air datum shared by: [zloc.loc.name]"*/


/*client/proc/TestZASRebuild()
	set category = "Debug"
//	var/turf/turf = get_turf(mob)
	var/zone/current_zone = mob.loc:zone
	if(!current_zone)
		src << "There is no zone there!"
		return

	var/list/current_adjacents = list()
	var/list/overlays = list()
	var/adjacent_id
	var/lowest_id

	var/list/identical_ids = list()
	var/list/turfs = current_zone.contents.Copy()
	var/current_identifier = 1

	for(var/turf/simulated/current in turfs)
		lowest_id = null
		current_adjacents = list()

		for(var/direction in cardinal)
			var/turf/simulated/adjacent = get_step(current, direction)
			if(!current.ZCanPass(adjacent))
				continue
			if(turfs.Find(adjacent))
				current_adjacents += adjacent
				adjacent_id = turfs[adjacent]

				if(adjacent_id && (!lowest_id || adjacent_id < lowest_id))
					lowest_id = adjacent_id

		if(!lowest_id)
			lowest_id = current_identifier++
			identical_ids += lowest_id
			overlays += image('icons/misc/debug_rebuild.dmi',, "[lowest_id]")

		for(var/turf/simulated/adjacent in current_adjacents)
			adjacent_id = turfs[adjacent]
			if(adjacent_id != lowest_id)
				if(adjacent_id)
					adjacent.overlays -= overlays[adjacent_id]
					identical_ids[adjacent_id] = lowest_id

				turfs[adjacent] = lowest_id
				adjacent.overlays += overlays[lowest_id]

				sleep(5)

		if(turfs[current])
			current.overlays -= overlays[turfs[current]]
		turfs[current] = lowest_id
		current.overlays += overlays[lowest_id]
		sleep(5)

	var/list/final_arrangement = list()

	for(var/turf/simulated/current in turfs)
		current_identifier = identical_ids[turfs[current]]
		current.overlays -= overlays[turfs[current]]
		current.overlays += overlays[current_identifier]
		sleep(5)

		if( current_identifier > final_arrangement.len )
			final_arrangement.len = current_identifier
			final_arrangement[current_identifier] = list(current)

		else
			final_arrangement[current_identifier] += current

	//lazy but fast
	final_arrangement.Remove(null)

	src << "There are [final_arrangement.len] unique segments."

	for(var/turf/current in turfs)
		current.overlays -= overlays

	return final_arrangement*/

/* VG - We rolled our own.
client/proc/ZASSettings()
	set category = "Debug"

	vsc.SetDefault(mob)
*/