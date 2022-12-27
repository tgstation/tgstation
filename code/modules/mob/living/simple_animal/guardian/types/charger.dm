//Charger
/mob/living/simple_animal/hostile/guardian/charger
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = TRUE //technically
	ranged_message = "charges"
	ranged_cooldown_time = 4 SECONDS
	speed = -1
	damage_coeff = list(BRUTE = 0.6, BURN = 0.6, TOX = 0.6, CLONE = 0.6, STAMINA = 0, OXY = 0.6)
	playstyle_string = span_holoparasite("As a <b>charger</b> type you do medium damage, have medium damage resistance, move very fast, and can charge at a location, damaging any target hit and forcing them to drop any items they are holding.")
	magic_fluff_string = span_holoparasite("..And draw the Hunter, an alien master of rapid assault.")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Charge modules loaded. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! Caught one! It's a charger carp, that likes running at people. But it doesn't have any legs...")
	miner_fluff_string = span_holoparasite("You encounter... Titanium, a lightweight, agile fighter.")
	creator_name = "Charger"
	creator_desc = "Moves extremely fast, does medium damage on attack, and can charge at targets, damaging the first target hit and forcing them to drop any items they are holding."
	creator_icon = "charger"
	var/charging = FALSE
	var/atom/movable/screen/alert/chargealert

/mob/living/simple_animal/hostile/guardian/charger/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(!COOLDOWN_FINISHED(src, ranged_cooldown))
		if(!chargealert)
			chargealert = throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/cancharge)
	else
		clear_alert(ALERT_CHARGE)
		chargealert = null

/mob/living/simple_animal/hostile/guardian/charger/OpenFire(atom/target)
	if(charging)
		return
	visible_message(span_danger("<b>[src]</b> [ranged_message] at [target]!"))
	COOLDOWN_START(src, ranged_cooldown, ranged_cooldown_time)
	clear_alert(ALERT_CHARGE)
	chargealert = null
	Shoot(target)

/mob/living/simple_animal/hostile/guardian/charger/Shoot(atom/targeted_atom)
	charging = TRUE
	throw_at(targeted_atom, range, 1, src, FALSE, TRUE, callback = CALLBACK(src, PROC_REF(charging_end)))

/mob/living/simple_animal/hostile/guardian/charger/proc/charging_end()
	charging = FALSE

/mob/living/simple_animal/hostile/guardian/charger/Move()
	if(charging)
		new /obj/effect/temp_visual/decoy/fading(loc, src)
	return ..()

/mob/living/simple_animal/hostile/guardian/charger/check_distance()
	if(!charging)
		..()

/mob/living/simple_animal/hostile/guardian/charger/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!charging)
		return ..()
	if(!isliving(hit_atom) || hit_atom == summoner || hasmatchingsummoner(hit_atom))
		return
	var/mob/living/hit_mob = hit_atom
	if(ishuman(hit_mob))
		var/mob/living/carbon/human/hit_human = hit_mob
		if(hit_human.check_shields(src, 90, name, attack_type = THROWN_PROJECTILE_ATTACK))
			return
	hit_mob.drop_all_held_items()
	hit_mob.visible_message(span_danger("[src] slams into [hit_mob]!"), span_userdanger("[src] slams into you!"))
	hit_mob.apply_damage(20, BRUTE)
	playsound(hit_mob, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	shake_camera(hit_mob, 4, 3)
	shake_camera(src, 2, 3)

