/mob/living/carbon/alien/spawn_gibs(drop_bitflags=NONE)
	if(drop_bitflags & DROP_BODYPARTS)
		new /obj/effect/gibspawner/xeno(drop_location(), src)
	else
		new /obj/effect/gibspawner/xeno/bodypartless(drop_location(), src)

/mob/living/carbon/alien/gib_animation()
	new /obj/effect/temp_visual/gib_animation(loc, "gibbed-a")

/mob/living/carbon/alien/spawn_dust(just_ash)
	if(just_ash)
		return ..()

	var/obj/effect/decal/remains/xeno/bones = new(loc)
	bones.pixel_z = -6
	bones.pixel_w = rand(-1, 1)
