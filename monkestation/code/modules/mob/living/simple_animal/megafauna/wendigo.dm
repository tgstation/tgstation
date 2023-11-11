#define WENDIGO_ENRAGED (health <= maxHealth*0.5)
#define WENDIGO_CIRCLE_SHOTCOUNT 24
#define WENDIGO_CIRCLE_REPEATCOUNT 8
#define WENDIGO_SPIRAL_SHOTCOUNT 40

/*

Difficulty: Medium

This is a monkestation override for wendigo

*/

/mob/living/simple_animal/hostile/megafauna/wendigo/monkestation_override
	name = "malnurished wendigo"
	desc = "A mythological man-eating legendary creature, the sockets of it's eyes track you with an unsatiated hunger. \
			This one seems highly malnurished, it will probably be easier to fight"

	stomp_range = 0
	scream_cooldown_time = 5 SECONDS

// Overriding this proc so we can remove the "wave" attack without touching any original code
/mob/living/simple_animal/hostile/megafauna/wendigo/monkestation_override/spiral_attack()
	var/list/choices = list("Alternating Circle", "Spiral")
	var/spiral_type = pick(choices)
	switch(spiral_type)
		if("Alternating Circle")
			var/shots_per = WENDIGO_CIRCLE_SHOTCOUNT
			for(var/shoot_times in 1 to WENDIGO_CIRCLE_REPEATCOUNT)
				var/offset = shoot_times % 2
				for(var/shot in 1 to shots_per)
					var/angle = shot * 360 / shots_per + (offset * 360 / shots_per) * 0.5
					var/obj/projectile/colossus/wendigo_shockwave/shockwave = new /obj/projectile/colossus/wendigo_shockwave(loc)
					shockwave.firer = src
					shockwave.speed = 3 - WENDIGO_ENRAGED
					shockwave.fire(angle)
				SLEEP_CHECK_DEATH(6 - WENDIGO_ENRAGED * 2, src)
		if("Spiral")
			var/shots_spiral = WENDIGO_SPIRAL_SHOTCOUNT
			var/angle_to_target = get_angle(src, target)
			var/spiral_direction = pick(-1, 1)
			for(var/shot in 1 to shots_spiral)
				var/shots_per_tick = 5 - WENDIGO_ENRAGED * 3
				var/angle_change = (5 + WENDIGO_ENRAGED * shot / 6) * spiral_direction
				for(var/count in 1 to shots_per_tick)
					var/angle = angle_to_target + shot * angle_change + count * 360 / shots_per_tick
					var/obj/projectile/colossus/wendigo_shockwave/shockwave = new /obj/projectile/colossus/wendigo_shockwave(loc)
					shockwave.firer = src
					shockwave.damage = 15
					shockwave.fire(angle)
				SLEEP_CHECK_DEATH(1, src)

#undef WENDIGO_ENRAGED
#undef WENDIGO_CIRCLE_SHOTCOUNT
#undef WENDIGO_CIRCLE_REPEATCOUNT
#undef WENDIGO_SPIRAL_SHOTCOUNT
