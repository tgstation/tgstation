/datum/event/gravitationalanomaly

	Announce()

		command_alert("Gravitational anomalies detected on the station. There is no additional data.", "Anomaly Alert")
		world << sound('granomalies.ogg')
		var/turf/T = pick(blobstart)
		var/obj/effect/bhole/bh = new /obj/effect/bhole( T.loc, 30 )
		spawn(rand(50, 300))
			del(bh)
