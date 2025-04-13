/datum/hud/soulscythe/New(mob/living/simple_animal/soulscythe/owner)
	. = ..()
	var/atom/movable/screen/using = new /atom/movable/screen/blood_level(null, src)
	static_inventory += using
