/obj/effect/spawner/xeno_egg_delivery
	name = "xeno egg delivery"
	icon = 'icons/mob/alien.dmi'
	icon_state = "egg_growing"
	var/announcement_time = 1200

/obj/effect/spawner/xeno_egg_delivery/Initialize(mapload)
	..()
	var/turf/T = get_turf(src)
	var/area/A = get_area(T)

	new /obj/structure/alien/egg(T)
	new /obj/effect/temp_visual/gravpush(T)
	playsound(T, 'sound/items/party_horn.ogg', 50, 1, -1)

	message_admins("An alien egg has been delivered to [A] at [ADMIN_COORDJMP(T)].")
	log_game("An alien egg has been delivered to [A] at [COORD(T)]")
	var/message = "Attention [station_name()], we have entrusted you with a research specimen in [A]. Remember to follow all safety precautions when dealing with the specimen."
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, /proc/addtimer, CALLBACK(GLOBAL_PROC, /.proc/print_command_report, message), announcement_time))
	qdel(src)
