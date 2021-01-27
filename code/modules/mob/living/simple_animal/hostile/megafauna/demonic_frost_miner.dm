/*

Difficulty: Extremely Hard

*/

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner
	name = "demonic-frost miner"
	desc = "An extremely well-geared miner, driven crazy or possessed by the demonic forces here, either way a terrifying enemy."
	health = 1500
	maxHealth = 1500
	icon_state = "demonic_miner"
	icon_living = "demonic_miner"
	icon = 'icons/mob/icemoon/icemoon_monsters.dmi'
	attack_verb_continuous = "pummels"
	attack_verb_simple = "pummels"
	attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	light_color = COLOR_LIGHT_GRAYISH_RED
	movement_type = GROUND
	weather_immunities = list("snow")
	speak_emote = list("roars")
	armour_penetration = 100
	melee_damage_lower = 10
	melee_damage_upper = 10
	aggro_vision_range = 18 // large vision range so combat doesn't abruptly end when someone runs a bit away
	rapid_melee = 4
	speed = 20
	move_to_delay = 20
	ranged = TRUE
	crusher_loot = list(/obj/effect/decal/remains/plasma, /obj/item/crusher_trophy/ice_block_talisman)
	loot = list(/obj/effect/decal/remains/plasma)
	wander = FALSE
	del_on_death = TRUE
	blood_volume = BLOOD_VOLUME_NORMAL
	achievement_type = /datum/award/achievement/boss/demonic_miner_kill
	crusher_achievement_type = /datum/award/achievement/boss/demonic_miner_crusher
	score_achievement_type = /datum/award/score/demonic_miner_score
	deathmessage = "falls to the ground, decaying into plasma particles."
	deathsound = "bodyfall"
	footstep_type = FOOTSTEP_MOB_HEAVY
	attack_action_types = list(/datum/action/innate/megafauna_attack/frost_orbs,
							   /datum/action/innate/megafauna_attack/snowball_machine_gun,
							   /datum/action/innate/megafauna_attack/ice_shotgun)
	/// Modifies the speed of the projectiles the demonic frost miner shoots out
	var/projectile_speed_multiplier = 1
	/// If the demonic frost miner is in its enraged state
	var/enraged = FALSE
	/// If the demonic frost miner is currently transforming to its enraged state
	var/enraging = FALSE

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/Initialize()
	. = ..()
	AddComponent(/datum/component/knockback, 7, FALSE, TRUE)
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
	icon_icon = 'icons/obj/guns/projectile.dmi'
	button_icon_state = "shotgun"
	chosen_message = "<span class='colossus'>You are now firing shotgun ice blasts.</span>"
	chosen_attack_num = 3

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/OpenFire()
	check_enraged()
	projectile_speed_multiplier = 1 - enraged * 0.25
	SetRecoveryTime(100, 100)

	if(client)
		switch(chosen_attack)
			if(1)
				frost_orbs()
			if(2)
				snowball_machine_gun()
			if(3)
				ice_shotgun()
		return

	var/easy_attack = prob(80 - enraged * 40)
	chosen_attack = rand(1, 3)
	switch(chosen_attack)
		if(1)
			if(easy_attack)
				frost_orbs(10, 8)
			else
				frost_orbs(5, 16)
		if(2)
			if(easy_attack)
				snowball_machine_gun()
			else
				INVOKE_ASYNC(src, .proc/ice_shotgun, 5, list(list(-180, -140, -100, -60, -20, 20, 60, 100, 140), list(-160, -120, -80, -40, 0, 40, 80, 120, 160)))
				snowball_machine_gun(5 * 8, 5)
		if(3)
			if(easy_attack)
				ice_shotgun()
			else
				ice_shotgun(5, list(list(0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330), list(-30, -15, 0, 15, 30)))

/obj/projectile/frost_orb
	name = "frost orb"
	icon_state = "ice_1"
	damage = 20
	armour_penetration = 100
	speed = 10
	homing_turn_speed = 30
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

/obj/projectile/ice_blast
	name = "ice blast"
	icon_state = "ice_2"
	damage = 15
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

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/Goto(target, delay, minimum_distance)
	if(enraging)
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/MoveToTarget(list/possible_targets)
	if(enraging)
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/Move()
	if(enraging)
		return
	return ..()

/// Shoots out homing frost orbs that explode into ice blast projectiles after a couple seconds
/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/proc/frost_orbs(added_delay = 10, shoot_times = 8)
	for(var/i in 1 to shoot_times)
		var/turf/startloc = get_turf(src)
		var/turf/endloc = get_turf(target)
		if(!endloc)
			break
		var/obj/projectile/frost_orb/P = new(startloc)
		P.preparePixelProjectile(endloc, startloc)
		P.firer = src
		if(target)
			P.original = target
		P.set_homing_target(target)
		P.fire(rand(0, 360))
		addtimer(CALLBACK(P, /obj/projectile/frost_orb/proc/orb_explosion, projectile_speed_multiplier), 20) // make the orbs home in after a second
		SLEEP_CHECK_DEATH(added_delay)
	SetRecoveryTime(40, 60)

/// Called when the orb is exploding, shoots out projectiles
/obj/projectile/frost_orb/proc/orb_explosion(projectile_speed_multiplier)
	for(var/i in 0 to 5)
		var/angle = i * 60
		var/turf/startloc = get_turf(src)
		var/turf/endloc = get_turf(original)
		if(!startloc || !endloc)
			break
		var/obj/projectile/ice_blast/P = new(startloc)
		P.speed *= projectile_speed_multiplier
		P.preparePixelProjectile(endloc, startloc, null, angle + rand(-10, 10))
		P.firer = firer
		if(original)
			P.original = original
		P.fire()
	qdel(src)

/// Shoots out snowballs with a random spread
/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/proc/snowball_machine_gun(shots = 60, spread = 45)
	for(var/i in 1 to shots)
		var/turf/startloc = get_turf(src)
		var/turf/endloc = get_turf(target)
		if(!endloc)
			break
		var/obj/projectile/P = new /obj/projectile/snowball(startloc)
		P.speed *= projectile_speed_multiplier
		P.preparePixelProjectile(endloc, startloc, null, rand(-spread, spread))
		P.firer = src
		if(target)
			P.original = target
		P.fire()
		SLEEP_CHECK_DEATH(1)
	SetRecoveryTime(15, 15)

/// Shoots out ice blasts in a shotgun like pattern
/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/proc/ice_shotgun(shots = 5, list/patterns = list(list(-40, -20, 0, 20, 40), list(-30, -10, 10, 30)))
	for(var/i in 1 to shots)
		var/list/pattern = patterns[i % length(patterns) + 1] // alternating patterns
		for(var/spread in pattern)
			var/turf/startloc = get_turf(src)
			var/turf/endloc = get_turf(target)
			if(!endloc)
				break
			var/obj/projectile/P = new /obj/projectile/ice_blast(startloc)
			P.speed *= projectile_speed_multiplier
			P.preparePixelProjectile(endloc, startloc, null, spread)
			P.firer = src
			if(target)
				P.original = target
			P.fire()
		SLEEP_CHECK_DEATH(8)
	SetRecoveryTime(15, 20)

/// Checks if the demonic frost miner is ready to be enraged
/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/proc/check_enraged()
	if(enraged)
		return
	if(health > maxHealth*0.25)
		return
	SetRecoveryTime(80, 80)
	adjustHealth(-maxHealth)
	enraged = TRUE
	enraging = TRUE
	animate(src, pixel_y = pixel_y + 96, time = 100, easing = ELASTIC_EASING)
	spin(100, 10)
	SLEEP_CHECK_DEATH(60)
	playsound(src, 'sound/effects/explosion3.ogg', 100, TRUE)
	icon_state = "demonic_miner_phase2"
	animate(src, pixel_y = pixel_y - 96, time = 8, flags = ANIMATION_END_NOW)
	spin(8, 2)
	SLEEP_CHECK_DEATH(8)
	for(var/mob/living/L in viewers(src))
		shake_camera(L, 3, 2)
	playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	ADD_TRAIT(src, TRAIT_MOVE_FLYING, FROSTMINER_ENRAGE_TRAIT)
	enraging = FALSE
	adjustHealth(-maxHealth)

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/death(gibbed, list/force_grant)
	if(health > 0)
		return
	var/turf/T = get_turf(src)
	var/loot = rand(1, 3)
	switch(loot)
		if(1)
			new /obj/item/resurrection_crystal(T)
		if(2)
			new /obj/item/clothing/shoes/winterboots/ice_boots/ice_trail(T)
		if(3)
			new /obj/item/pickaxe/drill/jackhammer/demonic(T)
	return ..()

/obj/item/resurrection_crystal
	name = "resurrection crystal"
	desc = "When used by anything holding it, this crystal gives them a second chance at life if they die."
	icon = 'icons/obj/objects.dmi'
	icon_state = "demonic_crystal"

/obj/item/resurrection_crystal/attack_self(mob/living/user)
	if(!iscarbon(user))
		to_chat(user, "<span class='notice'>A dark presence stops you from absorbing the crystal.</span>")
		return
	forceMove(user)
	to_chat(user, "<span class='notice'>You feel a bit safer... but a demonic presence lurks in the back of your head...</span>")
	RegisterSignal(user, COMSIG_LIVING_DEATH, .proc/resurrect)

/// Resurrects the target when they die by moving them and dusting a clone in their place, one life for another
/obj/item/resurrection_crystal/proc/resurrect(mob/living/carbon/user, gibbed)
	if(gibbed)
		to_chat(user, "<span class='notice'>This power cannot be used if your entire mortal body is disintegrated...</span>")
		return
	user.visible_message("<span class='notice'>You see [user]'s soul dragged out of their body!</span>", "<span class='notice'>You feel your soul dragged away to a fresh body!</span>")
	var/typepath = user.type
	var/mob/living/carbon/clone = new typepath(user.loc)
	clone.real_name = user.real_name
	user.dna.transfer_identity(clone)
	clone.updateappearance(mutcolor_update=1)
	var/turf/T = find_safe_turf()
	user.forceMove(T)
	user.revive(full_heal = TRUE, admin_revive = TRUE)
	user.set_species(/datum/species/shadow)
	to_chat(user, "<span class='notice'>You blink and find yourself in [get_area_name(T)]... feeling a bit darker.</span>")
	clone.dust()
	qdel(src)

/obj/item/clothing/shoes/winterboots/ice_boots/ice_trail
	name = "cursed ice hiking boots"
	desc = "A pair of winter boots contractually made by a devil, they cannot be taken off once put on."
	actions_types = list(/datum/action/item_action/toggle)
	var/on = FALSE
	var/change_turf = /turf/open/floor/plating/ice/icemoon
	var/duration = 6 SECONDS

/obj/item/clothing/shoes/winterboots/ice_boots/ice_trail/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, .proc/on_step)

/obj/item/clothing/shoes/winterboots/ice_boots/ice_trail/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_FEET)
		ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/shoes/winterboots/ice_boots/ice_trail/dropped(mob/user)
	. = ..()
	// Could have been blown off in an explosion from the previous owner
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/shoes/winterboots/ice_boots/ice_trail/ui_action_click(mob/user)
	on = !on
	to_chat(user, "<span class='notice'>You [on ? "activate" : "deactivate"] [src].</span>")

/obj/item/clothing/shoes/winterboots/ice_boots/ice_trail/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The shoes are [on ? "enabled" : "disabled"].</span>"

/obj/item/clothing/shoes/winterboots/ice_boots/ice_trail/proc/on_step()
	SIGNAL_HANDLER

	var/turf/T = get_turf(loc)
	if(!on || istype(T, /turf/closed) || istype(T, change_turf))
		return
	var/reset_turf = T.type
	T.ChangeTurf(change_turf, flags = CHANGETURF_INHERIT_AIR)
	addtimer(CALLBACK(T, /turf.proc/ChangeTurf, reset_turf, null, CHANGETURF_INHERIT_AIR), duration, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/item/pickaxe/drill/jackhammer/demonic
	name = "demonic jackhammer"
	desc = "Cracks rocks at an inhuman speed, as well as being enhanced for combat purposes."
	toolspeed = 0

/obj/item/pickaxe/drill/jackhammer/demonic/Initialize()
	. = ..()
	AddComponent(/datum/component/knockback, 4, TRUE, FALSE)
	AddComponent(/datum/component/lifesteal, 5)

/obj/item/pickaxe/drill/jackhammer/demonic/use_tool(atom/target, mob/living/user, delay, amount=0, volume=0, datum/callback/extra_checks)
	var/turf/T = get_turf(target)
	mineral_scan_pulse(T, world.view + 1)
	. = ..()

/obj/item/crusher_trophy/ice_block_talisman
	name = "ice block talisman"
	desc = "A glowing trinket that a demonic miner had on him, it seems he couldn't utilize it for whatever reason."
	icon_state = "ice_trap_talisman"
	denied_type = /obj/item/crusher_trophy/ice_block_talisman

/obj/item/crusher_trophy/ice_block_talisman/effect_desc()
	return "mark detonation to freeze a creature in a block of ice for a period, preventing them from moving"

/obj/item/crusher_trophy/ice_block_talisman/on_mark_detonation(mob/living/target, mob/living/user)
	target.apply_status_effect(/datum/status_effect/ice_block_talisman)

/datum/status_effect/ice_block_talisman
	id = "ice_block_talisman"
	duration = 40
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/ice_block_talisman
	/// Stored icon overlay for the hit mob, removed when effect is removed
	var/icon/cube

/atom/movable/screen/alert/status_effect/ice_block_talisman
	name = "Frozen Solid"
	desc = "You're frozen inside an ice cube, and cannot move!"
	icon_state = "frozen"

/datum/status_effect/ice_block_talisman/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, .proc/owner_moved)
	if(!owner.stat)
		to_chat(owner, "<span class='userdanger'>You become frozen in a cube!</span>")
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	var/icon/size_check = icon(owner.icon, owner.icon_state)
	cube.Scale(size_check.Width(), size_check.Height())
	owner.add_overlay(cube)
	return ..()

/// Blocks movement from the status effect owner
/datum/status_effect/ice_block_talisman/proc/owner_moved()
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/status_effect/ice_block_talisman/on_remove()
	if(!owner.stat)
		to_chat(owner, "<span class='notice'>The cube melts!</span>")
	owner.cut_overlay(cube)
	UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)
