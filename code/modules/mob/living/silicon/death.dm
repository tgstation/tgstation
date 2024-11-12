/mob/living/silicon/spawn_gibs()
	new /obj/effect/gibspawner/robot(drop_location(), src)

/mob/living/silicon/spawn_dust(just_ash)
	if(just_ash)
		return ..()

	var/obj/effect/decal/remains/robot/robones = new(loc)
	robones.pixel_z = -6
	robones.pixel_w = rand(-1, 1)

/mob/living/silicon/death(gibbed)
	diag_hud_set_status()
	diag_hud_set_health()
	update_health_hud()
	return ..()

/mob/living/silicon/get_visible_suicide_message()
	return "[src] is powering down. It looks like [p_theyre()] trying to commit suicide."

/mob/living/silicon/get_blind_suicide_message()
	return "You hear a long, hissing electronic whine."
