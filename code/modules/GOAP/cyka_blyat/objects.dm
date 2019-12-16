/obj/structure/russian_command_post
	name = "Russian Command Post"
	desc = "Critical for proper communist support."
	icon_state = "command_post"

	obj_integrity = 200
	max_integrity = 200


/obj/structure/russian_command_post/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Slavic Signal")

/obj/structure/russian_command_post/Destroy()
	visible_message("<span class='userdanger'>The command post looks like it's about to explode! You have a feeling you should get off this floor and fast.</span>")
	addtimer(CALLBACK(GLOBAL_PROC, /proc/explosion, src, 5, 15, 15, 5, TRUE, FALSE, 15), 30 SECONDS, TIMER_STOPPABLE)
	. = ..()

/obj/item/russian_reload
	name = "Russian Ammunition"
	desc = "Resupplies any nearby soldiers."
	icon_state = "ammo_box"
