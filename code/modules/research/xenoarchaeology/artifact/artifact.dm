
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Large finds - (Potentially) active alien machinery from the dawn of time

/datum/artifact_find
	var/artifact_id
	var/artifact_find_type
	var/artifact_detect_range

/datum/artifact_find/New()
	artifact_detect_range = rand(5,300)

	artifact_id = "[pick("kappa","sigma","antaeres","beta","omicron","iota","epsilon","omega","gamma","delta","tau","alpha")]-[rand(100,999)]"

	artifact_find_type = pick(\
	5;/obj/machinery/power/supermatter,\
	5;/obj/structure/constructshell,\
	5;/obj/machinery/syndicate_beacon,\
	25;/obj/machinery/power/supermatter/shard,\
	50;/obj/structure/cult/pylon,\
	100;/obj/machinery/auto_cloner,\
	100;/obj/machinery/giga_drill,\
	100;/obj/mecha/working/hoverpod,\
	100;/obj/machinery/replicator,\
	150;/obj/structure/crystal,\
	1000;/obj/machinery/artifact)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Boulders - sometimes turn up after excavating turf - excavate further to try and find large xenoarch finds

/obj/structure/boulder
	name = "rocky debris"
	desc = "Leftover rock from an excavation, it's been partially dug out already but there's still a lot to go."
	icon = 'icons/obj/mining.dmi'
	icon_state = "boulder1"
	density = 1
	opacity = 1
	anchored = 1
	var/excavation_level = 0
	var/datum/geosample/geological_data
	var/datum/artifact_find/artifact_find

/obj/structure/boulder/New()
	icon_state = "boulder[rand(1,4)]"
	excavation_level = rand(5,50)

/obj/structure/boulder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/device/core_sampler))
		src.geological_data.artifact_distance = rand(-100,100) / 100
		src.geological_data.artifact_id = artifact_find.artifact_id

		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
		return

	if (istype(W, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/C = W
		C.scan_atom(user, src)
		return

	if (istype(W, /obj/item/device/measuring_tape))
		var/obj/item/device/measuring_tape/P = W
		user.visible_message("\blue[user] extends [P] towards [src].","\blue You extend [P] towards [src].")
		if(do_after(user,40))
			user << "\blue \icon[P] [src] has been excavated to a depth of [2*src.excavation_level]cm."
		return

	if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/P = W

		user << "\red You start [P.drill_verb] [src]."

		if(!do_after(user,P.digspeed))
			return

		user << "\blue You finish [P.drill_verb] [src]."
		excavation_level += P.excavation_amount

		if(excavation_level > 100)
			//failure
			user.visible_message("<font color='red'><b>[src] suddenly crumbles away.</b></font>",\
			"\red [src] has disintegrated under your onslaught, any secrets it was holding are long gone.")
			del(src)
			return

		if(prob(excavation_level))
			//success
			if(artifact_find)
				var/spawn_type = artifact_find.artifact_find_type
				var/obj/O = new spawn_type(get_turf(src))
				if(istype(O,/obj/machinery/artifact))
					var/obj/machinery/artifact/X = O
					if(X.my_effect)
						X.my_effect.artifact_id = artifact_find.artifact_id
				src.visible_message("<font color='red'><b>[src] suddenly crumbles away.</b></font>")
			else
				user.visible_message("<font color='red'><b>[src] suddenly crumbles away.</b></font>",\
				"\blue [src] has been whittled away under your careful excavation, but there was nothing of interest inside.")
			del(src)
