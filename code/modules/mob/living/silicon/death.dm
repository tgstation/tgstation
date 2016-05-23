/mob/living/silicon/spawn_gibs()
	robogibs(loc, viruses)

/mob/living/silicon/spawn_dust()
	new /obj/effect/decal/remains/robot(loc)

/mob/living/silicon/death(gibbed)
	diag_hud_set_status()
	diag_hud_set_health()
	update_health_hud()
	..()