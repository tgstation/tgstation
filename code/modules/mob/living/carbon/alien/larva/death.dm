/mob/living/carbon/alien/larva/death(gibbed)
	if(stat == DEAD)
		return

	. = ..()

	update_icons()

/mob/living/carbon/alien/larva/spawn_gibs(drop_bitflags=NONE)
	if(drop_bitflags & DROP_BODYPARTS)
		new /obj/effect/gibspawner/larva(drop_location(), src)
	else
		new /obj/effect/gibspawner/larva/bodypartless(drop_location(), src)

/mob/living/carbon/alien/larva/gib_animation()
	new /obj/effect/temp_visual/gib_animation(loc, "gibbed-l")

/mob/living/carbon/alien/larva/spawn_dust(just_ash)
	if(just_ash)
		return ..()

	var/obj/effect/decal/remains/xeno/bones = new(loc)
	bones.pixel_z = -6
	bones.pixel_w = rand(-1, 1)
