
client/proc/Zone_Info(turf/T as null|turf)
	set category = "Debug"
	if(T)
		if(T.zone)
			T.zone.DebugDisplay(mob)
		else
			mob << "No zone here."
	else
		for(T in world)
			T.overlays -= 'debug_space.dmi'
			T.overlays -= 'debug_group.dmi'
			T.overlays -= 'debug_connect.dmi'



client/verb/Test_ZAS_Connection(var/turf/simulated/T as turf)
	set category = "Debug"
	if(!istype(T))
		return

	var/direction_list = list(\
	"North" = NORTH,\
	"South" = SOUTH,\
	"East" = EAST,\
	"West" = WEST,\
	"None" = null)
	var/direction = input("What direction do you wish to test?","Set direction") as null|anything in direction_list
	if(!direction)
		return

	if(direction == "None")
		if(T.CanPass(null, T, 0,0))
			mob << "The turf can pass air! :D"
		else
			mob << "No air passage :x"
		return

	var/turf/simulated/other_turf = get_step(T, direction_list[direction])
	if(!istype(other_turf))
		return

	var/pass_directions = T.CanPass(null, other_turf, 0, 0) + 2*other_turf.CanPass(null, T, 0, 0)

	switch(pass_directions)
		if(0)
			mob << "Neither turf can connect. :("

		if(1)
			mob << "The initial turf only can connect. :\\"

		if(2)
			mob << "The other turf can connect, but not the initial turf. :/"

		if(3)
			mob << "Both turfs can connect! :)"


zone/proc
	DebugDisplay(mob/M)
		if(!dbg_output)
			dbg_output = 1 //Don't want to be spammed when someone investigates a zone...
			for(var/turf/T in contents)
				T.overlays += 'debug_group.dmi'

			for(var/turf/space/S in unsimulated_tiles)
				S.overlays += 'debug_space.dmi'

			M << "<u>Zone Air Contents</u>"
			M << "Oxygen: [air.oxygen]"
			M << "Nitrogen: [air.nitrogen]"
			M << "Plasma: [air.toxins]"
			M << "Carbon Dioxide: [air.carbon_dioxide]"
			M << "Temperature: [air.temperature]"
			M << "Heat Energy: [air.temperature * air.heat_capacity()]"
			M << "Pressure: [air.return_pressure()]"
			M << ""
			M << "Space Tiles: [length(unsimulated_tiles)]"
			M << "Movable Objects: [length(movables())]"
			M << "<u>Connections: [length(connections)]</u>"

			for(var/connection/C in connections)
				M << "[C.A] --> [C.B] [(C.indirect?"Indirect":"Direct")]"
				C.A.overlays += 'debug_connect.dmi'
				C.B.overlays += 'debug_connect.dmi'
				spawn(50)
					C.A.overlays -= 'debug_connect.dmi'
					C.B.overlays -= 'debug_connect.dmi'
			for(var/C in connections)
				if(!istype(C,/connection))
					M << "[C] (Not Connection!)"

		else
			dbg_output = 0

			for(var/turf/T in contents)
				T.overlays -= 'debug_group.dmi'

			for(var/turf/space/S in unsimulated_tiles)
				S.overlays -= 'debug_space.dmi'
		for(var/zone/Z in zones)
			if(Z.air == air && Z != src)
				var/turf/zloc = pick(Z.contents)
				M << "\red Illegal air datum shared by: [zloc.loc.name]"

