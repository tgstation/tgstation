/obj/effect/fire_blast
	name = "fire blast"
	desc = "That looks hot."
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	density = 0
	unacidable = 1
	anchored = 1.0
	w_type=NOT_RECYCLABLE
	var/fire_damage = 0
	var/process_count = 0


/obj/effect/fire_blast/New(turf/T, var/damage = 0)
	..(T)
	if(prob(33))
		icon_state = "2"
	else if(prob(33))
		icon_state = "3"

	if(damage)
		fire_damage = damage
	set_light(3)

	to_chat(world, "CREATING FIRE BLAST THAT DEALS [fire_damage] BURN DAMAGE EVERY 2/10ths OF A SECOND")

	for(var/turf/TU in range(1))
		if(src.Adjacent(TU))
			var/tilehasfire = 0
			for(var/obj/effect/E in TU)
				if(istype(E, /obj/effect/fire_blast))
					tilehasfire = 1
			if(prob(20) && !tilehasfire)
				new /obj/effect/fire_blast(TU, fire_damage)

	spawn()
		for(var/i = 1; i <= 5; i++)
			for(var/mob/living/L in get_turf(src))
				L.adjustFireLoss(fire_damage)
				if(!L.on_fire)
					to_chat(world, "SETTING [L] ON FIRE NOW")
					L.adjust_fire_stacks(0.5)
					L.IgniteMob()
				else
					to_chat(world, "[L] IS ALREADY ON FIRE")
			sleep(2)

		qdel(src)