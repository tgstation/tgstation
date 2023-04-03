/mob/living/silicon/spawn_gibs()
	new /obj/effect/gibspawner/robot(drop_location(), src)

/mob/living/silicon/spawn_dust()
	new /obj/effect/decal/remains/robot(loc)

/mob/living/silicon/death(gibbed)
	if(!gibbed)
		emote("deathgasp")
	diag_hud_set_status()
	diag_hud_set_health()
	update_health_hud()
	return ..()

/mob/living/silicon/get_visible_suicide_message()
	return "[src] is powering down. It looks like [p_theyre()] trying to commit suicide."

/mob/living/silicon/get_blind_suicide_message()
	return "You hear a long, hissing electronic whine."
