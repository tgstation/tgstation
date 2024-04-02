/obj/item/jukebox_beacon
	name = "jukebox beacon"
	desc = "N.T. jukebox beacon, toss it down and you will have a complementary jukebox delivered to you. It comes with a free wrench to move it after deployment."
	icon = 'monkestation/icons/obj/items_and_weapons.dmi'
	icon_state = "music_beacon"
	var/used = FALSE

/obj/item/jukebox_beacon/attack_self()
	if(used)
		return
	loc.visible_message(span_warning("\The [src] begins to beep loudly!"))
	used = TRUE
	addtimer(CALLBACK(src, PROC_REF(launch_payload)), 4 SECONDS)

/obj/item/jukebox_beacon/proc/launch_payload()
	if(QDELETED(src))
		return
	podspawn(list(
		"target" = get_turf(src),
		"spawn" = list(/obj/item/wrench, /obj/machinery/media/jukebox),
		"style" = STYLE_CENTCOM
	))
	qdel(src)
