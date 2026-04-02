/obj/effect/spawner/xeno_egg_delivery
	name = "xeno egg delivery"
	icon = 'icons/mob/nonhuman-player/alien.dmi'
	icon_state = "egg_growing"

/obj/effect/spawner/xeno_egg_delivery/Initialize(mapload)
	. = ..()
	var/turf/spawn_turf = get_turf(src)
	new /obj/structure/alien/egg/delivery(spawn_turf)
	new /obj/effect/temp_visual/gravpush(spawn_turf)
	playsound(spawn_turf, 'sound/items/party_horn.ogg', 50, TRUE, -1)
	if(SSticker.HasRoundStarted())
		return

	message_admins("An alien egg has been delivered to [ADMIN_VERBOSEJMP(spawn_turf)].")
	log_game("An alien egg has been delivered to [AREACOORD(spawn_turf)]")

	var/datum/command_footnote/footnote = new()
	footnote.message = "We have entrusted your crew with a research specimen in [get_area_name(spawn_turf, TRUE)]. \
		Remember to follow all safety precautions when dealing with the specimen."
	footnote.signature = "Central Command"

	GLOB.communications_controller.command_report_footnotes += footnote

/obj/structure/alien/egg/delivery
	name = "xenobiological specimen egg"
	desc = "A large mottled egg, sent as a part of a Xenobiological Research Initiative by the higher-ups. Handle with care!"
	max_integrity = 300

/obj/structure/alien/egg/delivery/Initialize(mapload)
	. = ..()

	GLOB.communications_controller.xenomorph_egg_delivered = TRUE
	GLOB.communications_controller.captivity_area = get_area(src)
