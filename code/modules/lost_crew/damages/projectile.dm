/// Simulates being shot by a projectile
/datum/corpse_damage/cause_of_death/projectile
	/// The projectile to simulate shooting
	var/obj/projectile/projectile
	/// The minimal projectile hits
	var/min_hits = 6
	/// The maximum projectile hits
	var/max_hits = 12

/datum/corpse_damage/cause_of_death/projectile/apply_to_body(mob/living/carbon/human/body, severity, list/storage)
	projectile = new projectile()

	var/hits = ((max_hits - min_hits) * severity + min_hits)

	for(var/i in 1 to hits)
		body.projectile_hit(projectile, def_zone = pick(GLOB.all_body_zones), piercing_hit = TRUE)

/datum/corpse_damage/cause_of_death/projectile/laser
	projectile = /obj/projectile/beam/laser
	cause_of_death = "when I got shot with lasers!"

/datum/corpse_damage/cause_of_death/projectile/bullet
	projectile = /obj/projectile/bullet/c45
	cause_of_death = "when I got shot with bullets!"

