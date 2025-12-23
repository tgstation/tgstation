GLOBAL_LIST_INIT(save_object_blacklist, typecacheof(list(
	/obj/effect, // most effects can be ignored
	/obj/projectile, // bullets shouldn't be stuck in mid-air
	/atom/movable/mirage_holder, // z-level boundaries
	/obj/machinery/gravity_generator/part, // grav gen only needs main part and these duplicate
	/obj/structure/fluff/airlock_filler, // multi-tile airlocks
	/obj/golfcart_rear, // multi-tile golfcards
	/obj/structure/closet/supplypod, // very spammy and runtimes during initialize
	/obj/item/paper/requisition, // spammed by cargo orders
	/obj/item/paper/fluff/jobs/cargo/manifest, // spammed by cargo orders
	/obj/item/paper/fluff, // spammed by cargo mail
	/obj/item/mail, // spammed by cargo mail
	/obj/item/relic/lavaland, // lots of relic spam
	/mob/living/carbon, // carbon mobs are very complex to save so skip
	/mob/dead, // no dead ghosts
	/mob/eye, // no eyes from cameras/blob/AI vision
)))
