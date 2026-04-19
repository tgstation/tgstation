/// A slightly nerfed saw as the normal one is much too murdery.
/obj/item/melee/cleaving_saw/miner
	force = 6
	open_force = 10

/obj/item/melee/cleaving_saw/miner/attack(mob/living/target, mob/living/carbon/human/user)
	target.add_stun_absorption(source = "miner", duration = 1 SECONDS, priority = INFINITY)
	return ..()

/obj/projectile/kinetic/miner
	damage = 20
	speed = 1.1
	icon_state = "ka_tracer"
	range = 4

/obj/effect/temp_visual/dir_setting/miner_death
	icon_state = "miner_death"
	duration = 15

/obj/effect/temp_visual/dir_setting/miner_death/Initialize(mapload, set_dir)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(fade_out))

/obj/effect/temp_visual/dir_setting/miner_death/proc/fade_out()
	var/matrix/our_matrix = new
	our_matrix.Turn(pick(90, 270))
	var/final_dir = dir
	if(dir & (EAST|WEST)) //Facing east or west
		final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

	animate(src, transform = our_matrix, pixel_y = -6, dir = final_dir, time = 2, easing = QUAD_EASING)
	sleep(0.5 SECONDS)
	animate(src, color = list("#A7A19E", "#A7A19E", "#A7A19E", list(0, 0, 0)), time = 10, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	sleep(0.4 SECONDS)
	animate(src, alpha = 0, time = 6, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
