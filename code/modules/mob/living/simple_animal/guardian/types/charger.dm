//Charger
/mob/living/simple_animal/hostile/guardian/charger
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = 1 //technically
	ranged_message = "charges"
	ranged_cooldown_time = 40
	speed = -1
	damage_coeff = list(BRUTE = 0.6, BURN = 0.6, TOX = 0.6, CLONE = 0.6, STAMINA = 0, OXY = 0.6)
	playstyle_string = span_holoparasite("As a <b>charger</b> type you do medium damage, have medium damage resistance, move very fast, and can charge at a location, damaging any target hit and forcing them to drop any items they are holding.")
	magic_fluff_string = span_holoparasite("..And draw the Hunter, an alien master of rapid assault.")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Charge modules loaded. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! Caught one! It's a charger carp, that likes running at people. But it doesn't have any legs...")
	miner_fluff_string = span_holoparasite("You encounter... Titanium, a lightweight, agile fighter.")
	/// boolean on whether we are currently charging or not
	var/charging = FALSE
	/// holds a screen alert thrown out when charging
	var/atom/movable/screen/alert/chargealert

/mob/living/simple_animal/hostile/guardian/charger/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(ranged_cooldown <= world.time)
		if(!chargealert)
			chargealert = throw_alert(ALERT_CHARGE, /atom/movable/screen/alert/cancharge)
	else
		clear_alert(ALERT_CHARGE)
		chargealert = null

/mob/living/simple_animal/hostile/guardian/charger/OpenFire(atom/A)
	if(!charging)
		visible_message(span_danger("<b>[src]</b> [ranged_message] at [A]!"))
		ranged_cooldown = world.time + ranged_cooldown_time
		clear_alert(ALERT_CHARGE)
		chargealert = null
		Shoot(A)

/mob/living/simple_animal/hostile/guardian/charger/Shoot(atom/targeted_atom)
	charging = TRUE
	throw_at(targeted_atom, range, 1, src, FALSE, TRUE, callback = CALLBACK(src, .proc/charging_end))

/mob/living/simple_animal/hostile/guardian/charger/proc/charging_end()
	charging = FALSE

/mob/living/simple_animal/hostile/guardian/charger/Move()
	if(charging)
		new /obj/effect/temp_visual/decoy/fading(loc,src)
	. = ..()

/mob/living/simple_animal/hostile/guardian/charger/snapback()
	if(!charging)
		..()

/mob/living/simple_animal/hostile/guardian/charger/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!charging)
		return ..()

	if(!hit_atom)
		return

	var/mob/living/summoner = weak_summoner?.resolve()
	if(!summoner)
		host_deleted()
		return

	if(isliving(hit_atom) && hit_atom != summoner)
		var/mob/living/hit_living = hit_atom
		var/blocked = FALSE
		if(hasmatchingsummoner(hit_atom)) //if the summoner matches don't hurt them
			blocked = TRUE
		if(ishuman(hit_atom))
			var/mob/living/carbon/human/hit_human = hit_atom
			if(hit_human.check_shields(src, 90, "[name]", attack_type = THROWN_PROJECTILE_ATTACK))
				blocked = TRUE
		if(!blocked)
			hit_living.drop_all_held_items()
			hit_living.visible_message(span_danger("[src] slams into [hit_living]!"), span_userdanger("[src] slams into you!"))
			hit_living.apply_damage(20, BRUTE)
			playsound(get_turf(hit_living), 'sound/effects/meteorimpact.ogg', 100, TRUE)
			shake_camera(hit_living, 4, 3)
			shake_camera(src, 2, 3)

	charging = FALSE

