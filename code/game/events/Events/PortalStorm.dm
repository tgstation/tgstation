/datum/event/portalstorm

	Announce()
		command_alert("Subspace disruption detected around the vessel", "Anomaly Alert")
		LongTerm()

		var/list/turfs = list(	)
		var/turf/picked

		for(var/turf/T in world)
			if(T.z < 5 && istype(T,/turf/simulated/floor))
				turfs += T

		for(var/turf/T in world)
			if(prob(10) && T.z < 5 && istype(T,/turf/simulated/floor))
				spawn(50+rand(0,3000))
					picked = pick(turfs)
					var/obj/portal/P = new /obj/portal( T )
					P.target = picked
					P.creator = null
					P.icon = 'objects.dmi'
					P.failchance = 0
					P.icon_state = "anom"
					P.name = "wormhole"
					spawn(rand(100,150))
						del(P)