/*

Difficulty: Very Hard

*/

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner
	name = "demonic-frost miner"
	desc = "An extremely geared miner, driven crazy or possessed by the demonic forces here, either way a terrifying enemy."
	health = 2500
	maxHealth = 2500
	icon_state = "demonic_miner"
	icon_living = "demonic_miner"
	icon = 'icons/mob/icemoon/icemoon_monsters.dmi'
	attack_verb_continuous = "pummels"
	attack_verb_simple = "pummels"
	attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	light_color = "#E4C7C5"
	movement_type = GROUND
	weather_immunities = list("snow")
	speak_emote = list("roars")
	armour_penetration = 100
	melee_damage_lower = 10
	melee_damage_upper = 10
	rapid_melee = 4
	speed = 20
	move_to_delay = 20
	ranged = TRUE
	crusher_loot = list(/obj/effect/decal/remains/plasma, /obj/item/pickaxe/drill/jackhammer, /obj/item/crusher_trophy/miner_eye)
	loot = list(/obj/effect/decal/remains/plasma, /obj/item/pickaxe/drill/jackhammer)
	wander = FALSE
	del_on_death = TRUE
	blood_volume = BLOOD_VOLUME_NORMAL
	var/projectile_speed_multiplier = 1
	gps_name = "Demonic Signal"
	achievement_type = /datum/award/achievement/boss/demonic_miner_kill
	crusher_achievement_type = /datum/award/achievement/boss/demonic_miner_crusher
	score_achievement_type = /datum/award/score/demonic_miner_score
	deathmessage = "falls to the ground, decaying into plasma particles."
	deathsound = "bodyfall"
	footstep_type = FOOTSTEP_MOB_HEAVY
	attack_action_types = list(/datum/action/innate/megafauna_attack/frost_orbs,
							   /datum/action/innate/megafauna_attack/snowball_machine_gun,
							   /datum/action/innate/megafauna_attack/ice_shotgun)

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/Initialize()
	. = ..()
	AddComponent(/datum/component/knockback, 7, FALSE)
	AddComponent(/datum/component/lifesteal, 50)

/datum/action/innate/megafauna_attack/frost_orbs
	name = "Fire Frost Orbs"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now sending out frost orbs to track in on a target.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/snowball_machine_gun
	name = "Fire Snowball Machine Gun"
	icon_icon = 'icons/obj/guns/energy.dmi'
	button_icon_state = "kineticgun"
	chosen_message = "<span class='colossus'>You are now firing a snowball machine gun at a target.</span>"
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/ice_shotgun
	name = "Fire Ice Shotgun"
	icon_icon = 'icons/obj/lavaland/artefacts.dmi'
	button_icon_state = "cleaving_saw"
	chosen_message = "<span class='colossus'>You are now firing shotgun ice blasts.</span>"
	chosen_attack_num = 3

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/OpenFire()
	projectile_speed_multiplier = 1 + 1 * (maxHealth - health) / maxHealth // ranges from normal to double speed
	SetRecoveryTime(100)

	if(client)
		switch(chosen_attack)
			if(1)
				frost_orbs()
			if(2)
				snowball_machine_gun()
			if(3)
				ice_shotgun()
		return

	chosen_attack = rand(1, 3)
	if(health >= maxHealth * 0.5)
		switch(chosen_attack)
			if(1)
				frost_orbs()
			if(2)
				INVOKE_ASYNC(src, .proc/ice_shotgun, 5, list(list(-180, -140, -100, -60, -20, 20, 60, 100, 140), list(-160, -120, -80, -40, 0, 40, 80, 120, 160)))
				snowball_machine_gun(5 * 8, 5)
			if(3)
				ice_shotgun()
	else
		switch(chosen_attack)
			if(1)
				INVOKE_ASYNC(src, .proc/frost_orbs, GLOB.alldirs)
			if(2)
				snowball_machine_gun()
			if(3)
				ice_shotgun()

/obj/projectile/frost_orb
	name = "frost orb"
	icon_state = "ice_1"
	damage = 30
	armour_penetration = 100
	speed = 10
	damage_type = BURN

/obj/projectile/frost_orb/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isturf(target) || isobj(target))
		target.ex_act(EXPLODE_HEAVY)

/obj/projectile/snowball
	name = "machine-gun snowball"
	icon_state = "nuclear_particle"
	damage = 5
	armour_penetration = 100
	speed = 4
	damage_type = BRUTE

/obj/projectile/snowball/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isturf(target) || isobj(target))
		target.ex_act(EXPLODE_HEAVY)

/obj/projectile/ice_blast
	name = "ice blast"
	icon_state = "ice_2"
	damage = 20
	armour_penetration = 100
	speed = 4
	damage_type = BRUTE

/obj/projectile/ice_blast/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isturf(target) || isobj(target))
		target.ex_act(EXPLODE_HEAVY)

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/ex_act(severity, target)
	adjustBruteLoss(30 * severity - 120)
	visible_message("<span class='danger'>[src] absorbs the explosion!</span>", "<span class='userdanger'>You absorb the explosion!</span>")
	return

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/proc/frost_orbs(added_delay = 0, list/shoot_dirs = pick(GLOB.cardinals, GLOB.diagonals))
	var/extra_delay = 0
	for(var/dir in shoot_dirs)
		var/turf/startloc = get_turf(src)
		var/turf/endloc = get_turf(target)
		if(!endloc)
			break
		var/obj/projectile/P = new /obj/projectile/frost_orb(startloc)
		P.preparePixelProjectile(endloc, startloc)
		P.firer = src
		if(target)
			P.original = target
		P.fire(dir2angle(dir))
		addtimer(CALLBACK(src, .proc/set_orbs_homing, P), 10 + extra_delay) // make the orbs home in after a second
		extra_delay += added_delay
		SLEEP_CHECK_DEATH(added_delay)
	SetRecoveryTime(20)

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/proc/set_orbs_homing(obj/projectile/P)
	var/turf/endloc = get_turf(target)
	if(!endloc)
		return
	P.speed = 4 / projectile_speed_multiplier
	P.fire(Get_Angle(P, get_turf(endloc)))

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/proc/snowball_machine_gun(shots = 30, spread = 10)
	for(var/i in 1 to shots)
		var/turf/startloc = get_turf(src)
		var/turf/endloc = get_turf(target)
		if(!endloc)
			break
		var/obj/projectile/P = new /obj/projectile/snowball(startloc)
		P.speed /= projectile_speed_multiplier
		P.preparePixelProjectile(endloc, startloc, null, rand(-spread, spread))
		P.firer = src
		if(target)
			P.original = target
		P.fire()
		SLEEP_CHECK_DEATH(1)
	SetRecoveryTime(20)

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/proc/ice_shotgun(shots = 5, list/patterns = list(list(-40, -20, 0, 20, 40), list(-30, -10, 10, 30)))
	for(var/i in 1 to shots)
		var/list/pattern = patterns[i % length(patterns) + 1] // alternating patterns
		for(var/spread in pattern)
			var/turf/startloc = get_turf(src)
			var/turf/endloc = get_turf(target)
			if(!endloc)
				break
			var/obj/projectile/P = new /obj/projectile/ice_blast(startloc)
			P.speed /= projectile_speed_multiplier
			P.preparePixelProjectile(endloc, startloc, null, spread)
			P.firer = src
			if(target)
				P.original = target
			P.fire()
		SLEEP_CHECK_DEATH(8)
	SetRecoveryTime(40)