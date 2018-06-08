/obj/mecha/working
	internal_damage_threshold = 60

/obj/mecha/working/Initialize()
	. = ..()
	trackers += new /obj/item/mecha_parts/mecha_tracking(src)
