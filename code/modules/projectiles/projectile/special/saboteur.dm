/obj/projectile/energy/fisher
	name = "attenuated kinetic force"
	alpha = 0
	damage = 0
	damage_type = BRUTE
	armor_flag = BOMB
	range = 21
	projectile_phasing = PASSTABLE | PASSMOB | PASSMACHINE | PASSSTRUCTURE
	hitscan = TRUE
	hit_threshhold = LOW_OBJ_LAYER // required to be able to hit floor lights
	var/disrupt_duration = 15 SECONDS

/obj/projectile/energy/fisher/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	var/list/things_to_disrupt = list(target)
	if(isliving(target))
		var/mob/living/live_target = target
		things_to_disrupt += live_target.get_all_gear()

	var/success = FALSE
	for(var/atom/disrupted as anything in things_to_disrupt)
		if(SEND_SIGNAL(disrupted, COMSIG_HIT_BY_SABOTEUR, disrupt_duration) & COMSIG_SABOTEUR_SUCCESS)
			success = TRUE

	if(success && ismob(firer))
		target.balloon_alert(firer, "disrupted")

/obj/projectile/energy/fisher/melee
	range = 1
	suppressed = SUPPRESSED_VERY
	disrupt_duration = 25 SECONDS
