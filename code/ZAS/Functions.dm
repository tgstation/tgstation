zone
	proc
		AddTurf(turf/T)
			if(T in contents) return
			contents += T
			air.group_multiplier++
			T.zone = src
		RemoveTurf(turf/T)
			if(!(T in contents)) return
			contents -= T
			air.group_multiplier--
			T.zone = null

		DivideAir(ratio)
			ratio = min(1,max(0,ratio))
			air.oxygen *= ratio
			air.oxygen = QUANTIZE(air.oxygen)
			air.nitrogen *= ratio
			air.nitrogen = QUANTIZE(air.nitrogen)
			air.toxins *= ratio
			air.toxins = QUANTIZE(air.toxins)
			air.carbon_dioxide *= ratio
			air.carbon_dioxide = QUANTIZE(air.carbon_dioxide)
			if(air.trace_gases.len)
				for(var/datum/gas/trace_gas in air.trace_gases)
					trace_gas.moles *= ratio
					trace_gas.moles = QUANTIZE(trace_gas.moles)
			air.temperature = air.temperature*ratio + TCMB*(1-ratio)
			air.temperature = QUANTIZE(air.temperature)

		AddSpace(turf/space/S)
			if(istype(S,/turf/space))
				if(!space_tiles) space_tiles = list()
				space_tiles += S
		RemoveSpace(turf/space/S)
			if(space_tiles)
				space_tiles -= S
				if(!space_tiles.len) space_tiles = null

turf/proc/HasDoor(turf/O)
	for(var/obj/machinery/door/D in src)
		if(isnum(O) && O)
			if(!D.density) continue
		if(istype(D,/obj/machinery/door/window))
			if(!O) continue
			if(D.dir == get_dir(D,O)) return 1
		else
			return 1

turf/proc/find_zone()
	for(var/d in cardinal)
		var/turf/T = get_step(src,d)
		if(!T || !T.zone) continue
		if(!zone)
			zone = T.zone
			zone.AddTurf(src)
		else if(T.zone != zone)
			ZConnect(src,T)

proc
	ZMerge(zone/A,zone/B)
		//world << "Merge occured."
		var
			a_size = A.air.group_multiplier
			b_size = B.air.group_multiplier
			c_size = a_size + b_size
			new_contents = A.contents + B.contents

		A.air.group_multiplier = 1
		B.air.group_multiplier = 1

		A.air.remove_ratio(a_size/c_size)
		B.air.remove_ratio(b_size/c_size)
		A.air.merge(B.air)
		A.air.group_multiplier = c_size

		for(var/connection/C in B.connections)
			if((C.A in new_contents) && (C.B in new_contents))
				del C
				continue
			A.connections += C
		A.space_tiles += B.space_tiles
		A.contents = new_contents
		for(var/turf/T in B.contents)
			T.zone = A
		del B

	ZConnect(turf/A,turf/B)
		if(istype(B,/turf/space))
			if(A.zone)
				A.zone.AddSpace(B)
				//world << "Space added."
			return
		if(istype(A,/turf/space))
			if(B.zone)
				B.zone.AddSpace(B)
				//world << "Space added."
			return
		if(!A.zone || !B.zone) return
		if(A.zone == B.zone) return
		if(!A.CanPass(0,B,0,0)) return
		for(var/connection/C in A.zone.connections)
			if((C.A == A && C.B == B) || (C.A == B && C.B == A))
				return
		var/connection/C = new(A,B)
		if(A.HasDoor(B) || B.HasDoor(A)) C.indirect = 1
		//world << "Connection Formed: [A] --> [B] [(C.indirect?"Indirect":"Direct")]"
		//A.overlays += 'zone_connection_A.dmi'
		//B.overlays += 'zone_connection_B.dmi'
		//spawn(10)
		//	A.overlays -= 'zone_connection_A.dmi'
		//	B.overlays -= 'zone_connection_B.dmi'


	ZDisconnect(turf/A,turf/B)
		if(A.zone && B.zone)
			if(A.zone != B.zone)
				for(var/connection/C in A.zone.connections)
					if((C.A == A && C.B == B) || (C.A == B && C.B == A))
						//world << "Connection Dissolved: [A] -/-> [B] [(C.indirect?"Indirect":"Direct")]"
						/*A.overlays += 'zone_connection_A.dmi'
						B.overlays += 'zone_connection_B.dmi'
						spawn(10)
							A.overlays -= 'zone_connection_A.dmi'
							B.overlays -= 'zone_connection_B.dmi'*/
						del C
			/*else
				if(A == B) return
				if(A.CanPass(0,B,0,0)) return
				if(A.HasDoor(B) || B.HasDoor(A)) return
				var/zone/oldzone = A.zone
				var/list/test = FloodFill(A)
				if(B in test) return
				else
					var/zone/Z = new(test,oldzone.air)
					for(var/connection/C in oldzone.connections)
						if((A in Z.contents) || (B in Z.contents))
							if(!Z.connections) Z.connections = list()
							Z.connections += C
					var/datum/gas_mixture/Y_Air = new
					Y_Air.copy_from(oldzone.air)
					var/zone/Y = new(B,Y_Air)
					for(var/connection/C in oldzone.connections)
						if((A in Y.contents) || (B in Y.contents))
							if(!Y.connections) Y.connections = list()
							Y.connections += C
					oldzone.air = null
					del oldzone
					world << "Zone Split: [A] / [B]"
					A.overlays += 'zone_connection_A.dmi'
					B.overlays += 'zone_connection_B.dmi'
					spawn(10)
						A.overlays -= 'zone_connection_A.dmi'
						B.overlays -= 'zone_connection_B.dmi'*/
		else
			if(istype(A,/turf/space) && B.zone)
				B.zone.RemoveSpace(A)
			else if(istype(B,/turf/space) && A.zone)
				A.zone.RemoveSpace(B)