#define MOOK_ATTACK_NEUTRAL 0
#define MOOK_ATTACK_WARMUP 1
#define MOOK_ATTACK_ACTIVE 2
#define MOOK_ATTACK_STRIKE 3

//Fragile but highly aggressive wanderers that pose a large threat in numbers.
//They'll attempt to leap at their target from afar using their hatchets.
/mob/living/basic/mining/mook
	name = "wanderer"
	desc = "This unhealthy looking primitive is wielding a rudimentary hatchet, swinging it with wild abandon. One isn't much of a threat, but in numbers they can quickly overwhelm a superior opponent."
	icon = 'icons/mob/simple/jungle/mook.dmi'
	icon_state = "mook"
	icon_living = "mook"
	icon_dead = "mook_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	gender = MALE
	maxHealth = 150
	faction = list(FACTION_MINING, FACTION_NEUTRAL)
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 15
	pass_flags_self = LETPASSTHROW
	attack_sound = 'sound/weapons/rapierhit.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	death_sound = 'sound/voice/mook_death.ogg'
	ai_controller = /datum/ai_controller/basic_controller/mook
	speed = 5
	///the state of combat we are in
	var/attack_state = MOOK_ATTACK_NEUTRAL
	///are we a healer?
	var/is_healer = FALSE
	///the ore we are holding if any
	var/obj/held_ore
	///overlay for neutral stance
	var/mutable_appearance/neutral_stance
	///overlay for attacking stance
	var/mutable_appearance/attack_stance
	///overlay when we hold an ore
	var/mutable_appearance/ore_overlay

/mob/living/basic/mining/mook/Initialize(mapload)
	. = ..()

	var/datum/action/cooldown/mob_cooldown/mook_ability/mook_jump/jump = new(src)
	jump.Grant(src)
	ai_controller.set_blackboard_key(BB_MOOK_JUMP_ABILITY, jump)

	ore_overlay = mutable_appearance(icon, "mook_ore_overlay")
	neutral_stance = mutable_appearance(icon, "mook_axe_overlay")
	attack_stance = mutable_appearance(icon, "axe_strike_overlay")
	update_appearance()

	AddComponent(/datum/component/ai_listen_to_weather)
	AddElement(/datum/element/wall_smasher)
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))
	RegisterSignal(src, COMSIG_KB_MOB_DROPITEM_DOWN, PROC_REF(drop_ore))

	if(is_healer)
		grant_healer_abilities()
		return //healers cant leap

	var/datum/action/cooldown/mob_cooldown/mook_ability/mook_leap/leap = new(src)
	leap.Grant(src)
	ai_controller.set_blackboard_key(BB_MOOK_LEAP_ABILITY, leap)

/mob/living/basic/mining/mook/proc/grant_healer_abilities()
	AddComponent(\
		/datum/component/healing_touch,\
		heal_brute = melee_damage_upper,\
		heal_burn = melee_damage_upper,\
		heal_time = 0,\
		valid_targets_typecache = typecacheof(list(/mob/living/basic/mining/mook)),\
	)

/mob/living/basic/mining/mook/Entered(atom/movable/mover)
	if(istype(mover, /obj/item/stack/ore))
		held_ore = mover
		update_appearance(UPDATE_OVERLAYS)

	return ..()

/mob/living/basic/mining/mook/Exited(atom/movable/mover)
	. = ..()
	if(held_ore != mover)
		return
	held_ore = null
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/mining/mook/proc/pre_attack(mob/living/attacker, atom/target)
	SIGNAL_HANDLER

	if(attack_state == MOOK_ATTACK_STRIKE)
		return COMPONENT_HOSTILE_NO_ATTACK

	if(istype(target, /obj/item/stack/ore) && isnull(held_ore))
		var/obj/item/ore_target = target
		ore_target.forceMove(src)
		return COMPONENT_HOSTILE_NO_ATTACK

	if(istype(target, /obj/structure/material_stand))
		if(held_ore)
			held_ore.forceMove(target)
		return COMPONENT_HOSTILE_NO_ATTACK

	if(is_healer) //healers dont have a weapon to swing!
		return

	change_combatant_state(state = MOOK_ATTACK_STRIKE)
	addtimer(CALLBACK(src, PROC_REF(change_combatant_state), MOOK_ATTACK_NEUTRAL), 0.3 SECONDS)

/mob/living/basic/mining/mook/proc/change_combatant_state(state)
	attack_state = state
	update_appearance()

/mob/living/basic/mining/mook/update_icon_state()
	. = ..()
	if(stat == DEAD)
		return
	switch(attack_state)
		if(MOOK_ATTACK_NEUTRAL)
			icon_state = "mook"
		if(MOOK_ATTACK_WARMUP)
			icon_state = "mook_warmup"
		if(MOOK_ATTACK_ACTIVE)
			icon_state = "mook_leap"
		if(MOOK_ATTACK_STRIKE)
			icon_state = "mook_strike"

/mob/living/basic/mining/mook/update_overlays()
	. = ..()
	if(stat == DEAD)
		return

	if(attack_state == MOOK_ATTACK_STRIKE && !is_healer)
		. += attack_stance
		return

	if(attack_state != MOOK_ATTACK_NEUTRAL)
		return

	if(held_ore)
		. +=  ore_overlay

	if(!is_healer)
		. += neutral_stance

/mob/living/basic/mining/mook/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, gentle = FALSE, quickstart = TRUE)
	change_combatant_state(state = MOOK_ATTACK_ACTIVE)
	return ..()

/mob/living/basic/mining/mook/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	change_combatant_state(state = MOOK_ATTACK_NEUTRAL)

/mob/living/basic/mining/mook/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()

	if(!istype(mover, /mob/living/basic/mining/mook))
		return FALSE

	var/mob/living/basic/mining/mook/mook_moover = mover
	if(mook_moover.attack_state == MOOK_ATTACK_ACTIVE)
		return TRUE

/mob/living/basic/mining/mook/proc/drop_ore(mob/living/user)
	SIGNAL_HANDLER

	if(isnull(held_ore))
		return
	dropItemToGround(held_ore)
	return COMSIG_KB_ACTIVATED

/mob/living/basic/mining/mook/death()
	desc = "A deceased primitive. Upon closer inspection, it was suffering from severe cellular degeneration and its garments are machine made..." //Can you guess the twist
	return ..()

/mob/living/basic/mining/mook/bard
	desc = "It's holding a guitar?"
	melee_damage_lower = 10
	melee_damage_upper = 10
	pass_flags_self = LETPASSTHROW
	gender = MALE
	attack_sound = 'sound/weapons/stringsmash.ogg'
	death_sound = 'sound/voice/mook_death.ogg'
	ai_controller = /datum/ai_controller/basic_controller/mook/bard
	///our guitar
	var/obj/item/instrument/guitar/held_guitar

/mob/living/basic/mining/mook/bard/Initialize(mapload)
	. = ..()
	neutral_stance = mutable_appearance(icon, "bard_overlay")
	attack_stance = mutable_appearance(icon, "bard_strike")
	held_guitar = new(src)
	ai_controller.set_blackboard_key(BB_SONG_INSTRUMENT, held_guitar)
	update_appearance()

/mob/living/basic/mining/mook/support
	name = "wanderer"
	desc = "This unhealthy looking primitive seems to be talented at administiring health care."
	gender = FEMALE
	melee_damage_lower = 8
	melee_damage_upper = 8
	ai_controller = /datum/ai_controller/basic_controller/mook/support
	speed = 5
	is_healer = TRUE
	///commands we follow
	var/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/point_targetting/attack,
		/datum/pet_command/point_targetting/fetch,
	)

/mob/living/basic/mining/mook/support/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/obeys_commands, pet_commands)

/mob/living/basic/mining/mook/tribal_chief
	name = "tribal chief"
	desc = "Acknowledge him!"
	gender = MALE
	melee_damage_lower = 20
	melee_damage_upper = 20
	ai_controller = /datum/ai_controller/basic_controller/mook/tribal_chief
	///overlay in our neutral state
	var/mutable_appearance/chief_neutral
	///overlay in our striking state
	var/mutable_appearance/chief_strike
	///overlay in our active state
	var/mutable_appearance/chief_active
	///overlay in our warmup state
	var/mutable_appearance/chief_warmup

/mob/living/basic/mining/mook/tribal_chief/Initialize(mapload)
	. = ..()
	chief_neutral = mutable_appearance(icon, "mook_chief")
	chief_strike = mutable_appearance(icon, "mook_chief_strike")
	chief_active = mutable_appearance(icon, "mook_chief_leap")
	chief_warmup = mutable_appearance(icon, "mook_chief_warmup")
	update_appearance()

/mob/living/basic/mining/mook/tribal_chief/update_overlays()
	. = ..()
	if(stat == DEAD)
		return
	switch(attack_state)
		if(MOOK_ATTACK_NEUTRAL)
			. += chief_neutral
		if(MOOK_ATTACK_WARMUP)
			. += chief_warmup
		if(MOOK_ATTACK_ACTIVE)
			. += chief_active
		if(MOOK_ATTACK_STRIKE)
			. += chief_strike

/datum/action/cooldown/mob_cooldown/mook_ability
	///are we a mook?
	var/is_mook = FALSE

/datum/action/cooldown/mob_cooldown/mook_ability/Grant(mob/grant_to)
	. = ..()
	if(isnull(owner))
		return
	is_mook = istype(owner, /mob/living/basic/mining/mook)

/datum/action/cooldown/mob_cooldown/mook_ability/IsAvailable(feedback)
	. = ..()

	if(!.)
		return FALSE

	if(!is_mook)
		return TRUE

	var/mob/living/basic/mining/mook/mook_owner = owner
	if(mook_owner.attack_state != MOOK_ATTACK_NEUTRAL)
		if(feedback)
			mook_owner.balloon_alert(mook_owner, "still recovering!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/mook_ability/mook_leap
	name = "Mook leap"
	desc = "Leap towards the enemy!"
	cooldown_time = 7 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	///telegraph time before jumping
	var/wind_up_time = 2 SECONDS
	///intervals between each of our attacks
	var/attack_interval = 0.4 SECONDS
	///how many times do we attack if we reach the target?
	var/times_to_attack = 4

/datum/action/cooldown/mob_cooldown/mook_ability/mook_leap/Activate(atom/target)
	if(owner.CanReach(target))
		attack_combo(target)
		StartCooldown()
		return TRUE

	if(is_mook)
		var/mob/living/basic/mining/mook/mook_owner = owner
		mook_owner.change_combatant_state(state = MOOK_ATTACK_WARMUP)

	addtimer(CALLBACK(src, PROC_REF(launch_towards_target), target), wind_up_time)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/mook_ability/mook_leap/proc/launch_towards_target(atom/target)
	new /obj/effect/temp_visual/mook_dust(get_turf(owner))
	playsound(get_turf(owner), 'sound/weapons/thudswoosh.ogg', 25, TRUE)
	playsound(owner, 'sound/voice/mook_leap_yell.ogg', 100, TRUE)
	var/turf/target_turf = get_turf(target)

	if(!target_turf.is_blocked_turf())
		owner.throw_at(target = target_turf, range = 7, speed = 1, spin = FALSE, callback = CALLBACK(src, PROC_REF(attack_combo), target))
		return

	var/list/open_turfs = list()

	for(var/turf/possible_turf in get_adjacent_open_turfs(target))
		if(possible_turf.is_blocked_turf())
			continue
		open_turfs += possible_turf

	if(!length(open_turfs))
		return

	var/turf/final_turf = get_closest_atom(/turf, open_turfs, owner)
	owner.throw_at(target = final_turf, range = 7, speed = 1, spin = FALSE, callback = CALLBACK(src, PROC_REF(attack_combo), target))

/datum/action/cooldown/mob_cooldown/mook_ability/mook_leap/proc/attack_combo(atom/target)
	if(!owner.CanReach(target))
		return FALSE

	for(var/i in 0 to (times_to_attack - 1))
		addtimer(CALLBACK(src, PROC_REF(attack_target), target), i * attack_interval)

/datum/action/cooldown/mob_cooldown/mook_ability/mook_leap/proc/attack_target(atom/target)
	if(!owner.CanReach(target) || owner.stat == DEAD)
		return
	var/mob/living/basic/basic_owner = owner
	basic_owner.melee_attack(target, ignore_cooldown = TRUE)

/datum/action/cooldown/mob_cooldown/mook_ability/mook_jump
	name = "Mook Jump"
	desc = "Soar high in the air!"
	cooldown_time = 14 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/mook_ability/mook_jump/Activate(atom/target)
	var/obj/effect/landmark/drop_zone = locate(/obj/effect/landmark/mook_village) in GLOB.landmarks_list
	if(drop_zone?.z == owner.z)
		var/turf/jump_destination = get_turf(drop_zone)
		jump_to_turf(jump_destination)
		StartCooldown()
		return TRUE
	var/list/potential_turfs = list()
	for(var/turf/open_turf in oview(9, owner))
		if(!open_turf.is_blocked_turf())
			potential_turfs += open_turf
	if(!length(potential_turfs))
		return FALSE
	jump_to_turf(pick(potential_turfs))
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/mook_ability/mook_jump/proc/jump_to_turf(turf/target)
	if(is_mook)
		var/mob/living/basic/mining/mook/mook_owner = owner
		mook_owner.change_combatant_state(state = MOOK_ATTACK_ACTIVE)
	new /obj/effect/temp_visual/mook_dust(get_turf(owner))
	playsound(get_turf(owner), 'sound/weapons/thudswoosh.ogg', 50, TRUE)
	animate(owner, pixel_y = owner.base_pixel_y + 146, time = 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(land_on_turf), target), 0.5 SECONDS)

/datum/action/cooldown/mob_cooldown/mook_ability/mook_jump/proc/land_on_turf(turf/target)
	do_teleport(owner, target, precision = 3,  no_effects = TRUE)
	animate(owner, pixel_y = owner.base_pixel_y, time = 0.5 SECONDS)
	new /obj/effect/temp_visual/mook_dust(get_turf(owner))
	if(is_mook)
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living/basic/mining/mook, change_combatant_state), MOOK_ATTACK_NEUTRAL), 0.5 SECONDS)

/obj/effect/temp_visual/mook_dust
	name = "dust"
	desc = "It's just a dust cloud!"
	icon = 'icons/mob/simple/jungle/mook.dmi'
	icon_state = "mook_leap_cloud"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	base_pixel_y = -16
	base_pixel_x = -16
	duration = 10


#undef MOOK_ATTACK_NEUTRAL
#undef MOOK_ATTACK_WARMUP
#undef MOOK_ATTACK_ACTIVE
#undef MOOK_ATTACK_STRIKE
