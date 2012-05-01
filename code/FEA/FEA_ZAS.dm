/*	AN EXPLANATION:
This file was added because I felt that the computations for movement
of air over large scales was not adequately done by FEA, and the attempt
to solve this problem, in the form of ZAS (Zone Atmos System),
simplified it too far, in my opinion, creating the effect of a single
opened air canister filling an entire room with a partial mix of that
gas with the pre-existing mix.  This was slightly silly, due to large
rooms "flash filling" when you opened a canister, and the fact that the
procedures to recalculate the boundaries of the zones was far from
foolproof, and, indeed, often let air flash though solid bulkheads to
space.

To solve this, I've both commented the hell out of the existing FEA code,
removed and/or replaced procs with more efficient procs, and added this
file, which contains some procedures for special cases, such as:
	1.) Moving large volumes of air into vacuum/lower pressure environs
		(triggers when pressure behind a tile moving air to a lower
		pressure exceeds an amount.)
		e.g. A room of full air gets opened to a depressurised room
	2.) Dealing with pressure equalization.
		(triggers when a large amount of gas is added to a room, it
		follows behind the "stormfront" of gas change (Managed by FEA)
		and triggers a rapid equalization of gas by utilizing a
		psuedo-zone.)
		e.g. Opening a tank of oxygen in a low pressure room, and after
		spreading by FEA, it equalizes the pressure in the room, instead
		instead of slowly flowing out like molasses.

These procedures trigger when a check is made against the pressure changes
and situations occuring to the airgroup (if it is venting at high pressure,
airgroups will rejoin even if broken to ZAS process) will call these
specialized procs to help properly deal with these situation.
--SkyMarshal, May 2012*/
/* WIP

		if(space_tiles)
			for(var/T in space_tiles)
				if(!istype(T,/turf/space)) space_tiles -= T
			total_space += length(space_tiles)
			if(length(space_tiles))
				space = space_tiles[1]

		if(total_space && space)
			var/old_pressure = air.return_pressure()
			air.temperature_mimic(space,OPEN_HEAT_TRANSFER_COEFFICIENT,total_space)
			air.remove(MOLES_CELLSTANDARD * (air.group_multiplier/40) * total_space)
			var/p_diff = old_pressure - air.return_pressure()
			if(p_diff > vsc.AF_TINY_MOVEMENT_THRESHOLD) AirflowSpace(src,p_diff)

		air.graphic_archived = air.graphic

		air.temperature = max(TCMB,air.temperature)

				var/p_diff = (air.return_pressure()-Z.air.return_pressure())*connected_zones[Z]*(vsc.zone_share_percent/100)
				if(p_diff > vsc.AF_TINY_MOVEMENT_THRESHOLD) Airflow(src,Z,p_diff)
				air.share_ratio(Z.air,connected_zones[Z]*(vsc.zone_share_percent/100))
				*/