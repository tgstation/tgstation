/obj/item/sledgehammer
	name = "sledgehammer"
	desc = "A licensed replica of the hammer from that one commercial. The weight is real, you feel it in your wrists the moment you pick it up. Get it spinning and something on the other end is going to break."
	icon = 'icons/obj/weapons/sledgehammer.dmi'
	icon_state = "sledgehammer0"
	base_icon_state = "sledgehammer"
	lefthand_file = 'icons/mob/inhands/weapons/sledgehammer_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/sledgehammer_righthand.dmi'
	worn_icon = 'icons/mob/clothing/back/sledgehammer.dmi'
	worn_icon_state = "sledgehammer"
	force = 8
	throwforce = 10
	demolition_mod = 1.5
	attack_speed = 1.2 SECONDS
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	obj_flags = CONDUCTS_ELECTRICITY
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/item_fireaxe
	hitsound = /datum/sound_effect/swing_hit
	attack_verb_continuous = list("smashes", "slams", "bashes", "pounds")
	attack_verb_simple = list("smash", "slam", "bash", "pound")
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5)
	action_slots = ITEM_SLOT_HANDS
	actions_types = list(/datum/action/cooldown/hammer_throw)
	var/force_wielded = 20
	var/structure_demolition_multiplier = 2 // yeah it's really for deconstruction works
	/// Quarter turns before the hammer is fast enough to let go
	var/spin_up_turns = 11 // ends a quarter short of the aim, follow through does the rest
	/// How long the first quarter turn takes
	var/first_turn_delay = 0.4 SECONDS
	/// How much faster each next quarter turn gets
	var/turn_delay_drop = 0.03 SECONDS
	/// Extra turns to line up the aim before the hammer just goes, one full circle
	var/max_lineup_turns = 4 // orbiting the mark can't spin forever
	/// Stamina and dizziness multiplier for turns made while walking
	var/walking_spin_penalty = 1.5
	/// How long after letting go momentum turns the thrower to face the throw
	var/follow_through_delay = 0.15 SECONDS
	/// Facing locked in for the current quarter turn, null when not spinning
	var/spin_facing
	/// Whether the current flight is a spun throw and hits with spun_throwforce
	var/spun_throw_in_flight = FALSE
	/// Throwforce to restore once the spun throw lands
	var/throwforce_before_spin
	var/spun_throwforce = 25
	var/spun_throw_range = 7
	var/spun_throw_knockdown = 2 SECONDS
	var/spin_dizziness = 4 SECONDS
	var/spin_stamina_cost = 30 // spreads over the whole spin
	var/static/list/smashable_screen_types = typecacheof(list(
		/obj/machinery/computer,
		/obj/machinery/status_display,
	))
	var/static/list/slam_verbs = list("slams", "smashes", "rams")
	var/static/list/slam_sounds = list('sound/effects/meteorimpact.ogg', 'sound/effects/bang.ogg')
	var/static/list/metal_hitsounds = list(
		'sound/items/weapons/sledgehammer/metal_hit.ogg',
		'sound/items/weapons/sledgehammer/metal_hit2.ogg',
	)

/obj/item/sledgehammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_unwielded = force, \
		force_wielded = force_wielded, \
		icon_wielded = "[base_icon_state]1", \
	)
	RegisterSignal(src, COMSIG_SEND_ITEM_ATTACK_MESSAGE_OBJECT, PROC_REF(on_attack_message))
	add_deep_lore()

/obj/item/sledgehammer/proc/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "In 2484 a small computer company bought a single ad slot during the Sol Football Final. \
		Rows of grey workers sat in front of a giant telescreen while a droning executive read out \
		the Information Purification Directives. A woman in red shorts ran in past the guards, \
		spun twice and threw a sledgehammer straight through the screen.<br>\
		<br>\
		The computer sold modestly. The hammer sold out in a week.<br>\
		<br>\
		Nanotrasen now issues a licensed reproduction with the original weight and balance. \
		It is cleared for demolition and deconstruction work. It is not cleared for the briefing room telescreen. \
		That clause was added after the first shipment.<br>\
		<br>\
		Why 2484 will not be like \"1984\" is still pending review by the Nanotrasen ethics board." \
	) // for those who still don't get it https://youtu.be/ErwS24cBZPc

/obj/item/sledgehammer/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/sledgehammer/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(.)
		return .
	if(spin_facing) // both hands are busy spinning
		return TRUE
	if(isliving(target))
		play_heavy_hitsound(target, user, attack_modifiers)
		return FALSE
	if(ismecha(target))
		playsound(target, pick(slam_sounds), 50)
	if(!iswallturf(target) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return FALSE
	slam_wall(target, user)
	return TRUE

/obj/item/sledgehammer/afterattack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!HAS_TRAIT(src, TRAIT_WIELDED) || QDELETED(target))
		return
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.body_position == STANDING_UP) // no shove stun chains
			user.disarm(living_target, src)
		return
	if(target.resistance_flags & INDESTRUCTIBLE)
		return
	if(istype(target, /obj/structure/window) || istype(target, /obj/structure/grille))
		target.atom_destruction(MELEE)

/obj/item/sledgehammer/get_demolition_modifier(obj/target)
	. = ..()
	if(!isstructure(target) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return .
	if(HAS_TRAIT(target, TRAIT_IGNORE_DEMOLITION) || HAS_TRAIT(target, TRAIT_INVERTED_DEMOLITION))
		return .
	return . * structure_demolition_multiplier

/obj/item/sledgehammer/proc/on_attack_message(obj/item/source, mob/living/victim, mob/living/attacker)
	SIGNAL_HANDLER

	if(victim == attacker || victim.body_position != LYING_DOWN)
		return NONE
	// downward strike, like a kick
	var/attacker_name = (attacker in viewers(victim, null)) ? "[attacker]" : "Something"
	victim.visible_message(
		span_danger("[attacker_name] brings [src] down on [victim]!"),
		span_userdanger("[attacker_name] brings [src] down on you!"),
		span_hear("You hear a heavy thud!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
		ignored_mobs = attacker,
	)
	to_chat(attacker, span_danger("You bring [src] down on [victim]!"))
	return SIGNAL_MESSAGE_MODIFIED

/obj/item/sledgehammer/proc/play_heavy_hitsound(mob/living/target_mob, mob/living/user, list/attack_modifiers)
	if(!HAS_TRAIT(src, TRAIT_WIELDED) || HAS_TRAIT(user, TRAIT_PACIFISM))
		return
	var/heavy_hitsound
	if(issilicon(target_mob)) // metal bonk
		heavy_hitsound = pick(metal_hitsounds)
	else if(iscarbon(target_mob))
		heavy_hitsound = 'sound/items/weapons/sledgehammer/heavy_hit.ogg'
	else
		return
	MUTE_ATTACK_HITSOUND(attack_modifiers)
	playsound(src, heavy_hitsound, get_clamped_volume(), TRUE, falloff_distance = 0)

/obj/item/sledgehammer/proc/slam_wall(turf/closed/wall/wall, mob/living/user)
	user.changeNext_move(attack_speed)
	user.do_attack_animation(wall, used_item = src)

	if(istype(wall, /turf/closed/wall/r_wall) || wall.hardness <= /turf/closed/wall/r_wall::hardness || isindestructiblewall(wall))
		playsound(wall, pick(slam_sounds), 50, TRUE)
		user.visible_message(
			span_warning("[user] [pick(slam_verbs)] [src] against [wall], but it holds firm!"),
			span_warning("You slam [src] against [wall], but it is too sturdy to smash!"),
		)
		return

	var/wall_name = wall.name
	wall.AddComponent(/datum/component/torn_wall)
	if(iswallturf(wall))
		user.visible_message(
			span_danger("[user] [pick(slam_verbs)] [src] against [wall]!"),
			span_danger("You slam [src] against [wall]!"),
			span_hear("You hear a booming smash!"),
		)
		return
	user.visible_message(
		span_danger("[user] smashes through [wall_name] with [src]!"),
		span_danger("You smash through [wall_name]!"),
		span_hear("You hear a wall come crashing down!"),
	)

/obj/item/sledgehammer/proc/wind_up_throw(mob/living/user, turf/aim_turf)
	var/spin_turn_angle = IS_RIGHT_INDEX(user.get_held_index_of_item(src)) ? -90 : 90 // hammer trails, body drags it around
	var/aim_facing = facing_toward(user, aim_turf, user.dir)
	spin_facing = aim_facing
	user.setDir(spin_facing)
	RegisterSignal(user, COMSIG_ATOM_PRE_DIR_CHANGE, PROC_REF(hold_spin_facing)) // no turning by hand mid spin
	user.visible_message(
		span_warning("[user] starts spinning around with [src]!"),
		span_notice("You start spinning with [src]. Keep it up and let it fly."),
	)
	var/turns_done = 0
	var/built_dizziness = 0
	var/turf/last_turn_turf = get_turf(user)
	var/aim_lined_up = FALSE
	var/datum/callback/still_wielded = CALLBACK(src, PROC_REF(is_wielded))
	while(turns_done < spin_up_turns || (!aim_lined_up && turns_done < spin_up_turns + max_lineup_turns))
		if(!do_after(user, turn_delay(turns_done + 1), user, timed_action_flags = IGNORE_SLOWDOWNS|IGNORE_USER_LOC_CHANGE, show_progress = FALSE, extra_checks = still_wielded))
			stop_spin(user)
			user.balloon_alert(user, "lost momentum!")
			return
		turns_done += 1
		var/turf/turn_turf = get_turf(user)
		var/turn_cost_multiplier = turn_turf == last_turn_turf ? 1 : walking_spin_penalty
		last_turn_turf = turn_turf
		spin_facing = turn(spin_facing, spin_turn_angle)
		user.setDir(spin_facing)
		user.adjust_stamina_loss(spin_stamina_cost / spin_up_turns * turn_cost_multiplier)
		built_dizziness += spin_dizziness / spin_up_turns * turn_cost_multiplier
		playsound(user, 'sound/items/weapons/thudswoosh.ogg', 20 + min(turns_done, spin_up_turns) * 3, TRUE)
		aim_facing = facing_toward(user, aim_turf, aim_facing)
		aim_lined_up = spin_facing == turn(aim_facing, -spin_turn_angle)
	stop_spin(user)
	release_throw(user, aim_turf, aim_facing, built_dizziness)

/// Quarter turns speed up linearly until the hammer is spun up, lineup turns keep top speed
/obj/item/sledgehammer/proc/turn_delay(turn_number)
	return first_turn_delay - (min(turn_number, spin_up_turns) - 1) * turn_delay_drop

/// Cardinal facing toward the aim, mob sprites have no diagonals
/obj/item/sledgehammer/proc/facing_toward(mob/living/user, turf/aim_turf, current_facing)
	if(standing_on_mark(user, aim_turf))
		return current_facing
	var/x_offset = aim_turf.x - user.x
	var/y_offset = aim_turf.y - user.y
	if(abs(x_offset) >= abs(y_offset))
		return x_offset > 0 ? EAST : WEST
	return y_offset > 0 ? NORTH : SOUTH

/// Same x and y as the aim, z ignored so stairs mid-spin don't fling it west
/obj/item/sledgehammer/proc/standing_on_mark(mob/living/user, turf/aim_turf)
	return user.x == aim_turf.x && user.y == aim_turf.y

/obj/item/sledgehammer/proc/stop_spin(mob/living/user)
	spin_facing = null
	UnregisterSignal(user, COMSIG_ATOM_PRE_DIR_CHANGE)

/obj/item/sledgehammer/proc/is_wielded()
	return HAS_TRAIT(src, TRAIT_WIELDED)

/obj/item/sledgehammer/proc/hold_spin_facing(mob/living/source, old_dir, new_dir)
	SIGNAL_HANDLER

	if(new_dir != spin_facing)
		return COMPONENT_ATOM_BLOCK_DIR_CHANGE
	return NONE

/obj/item/sledgehammer/proc/release_throw(mob/living/user, turf/aim_turf, aim_facing, built_dizziness)
	var/datum/component/two_handed/grip = GetComponent(/datum/component/two_handed)
	grip.unwield(user, show_message = FALSE)
	if(!user.dropItemToGround(src, silent = TRUE))
		return
	addtimer(CALLBACK(src, PROC_REF(follow_through), user, user.dir, aim_facing), follow_through_delay) // momentum spins the thrower
	user.visible_message(
		span_danger("[user] lets [src] fly!"),
		span_danger("You let [src] fly!"),
	)
	playsound(user, 'sound/items/weapons/throwhard.ogg', 50, TRUE)
	user.set_dizzy_if_lower(built_dizziness)
	user.log_message("spun up and threw [src] toward [AREACOORD(aim_turf)]", LOG_ATTACK)
	spun_throw_in_flight = TRUE
	throwforce_before_spin = throwforce
	throwforce = spun_throwforce
	var/turf/throw_target
	if(standing_on_mark(user, aim_turf))
		throw_target = get_ranged_target_turf(user, aim_facing, spun_throw_range)
	else
		throw_target = get_ranged_target_turf_direct(user, aim_turf, spun_throw_range) // full range along the aim, the click only sets the angle
	if(!throw_at(throw_target, spun_throw_range, throw_speed, user, spin = TRUE, callback = CALLBACK(src, PROC_REF(end_spun_throw))))
		end_spun_throw()

/obj/item/sledgehammer/proc/follow_through(mob/living/user, release_direction, throw_direction)
	if(user.dir == release_direction)
		user.setDir(throw_direction)

/obj/item/sledgehammer/proc/end_spun_throw()
	spun_throw_in_flight = FALSE
	throwforce = throwforce_before_spin

/obj/item/sledgehammer/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!spun_throw_in_flight || QDELETED(hit_atom))
		return
	if(isliving(hit_atom))
		if(loc == hit_atom)
			push_catcher(hit_atom, throwingdatum)
			return
		if(.)
			return
		var/mob/living/victim = hit_atom
		victim.Knockdown(spun_throw_knockdown)
		return
	if(is_type_in_typecache(hit_atom, smashable_screen_types))
		smash_screen(hit_atom)
		return
	var/turf/hit_turf = get_turf(hit_atom)
	for(var/obj/machinery/wall_screen as anything in typecache_filter_list(range(1, src), smashable_screen_types))
		if(get_turf_pixel(wall_screen) == hit_turf) // atom_mounted misses supply and brig displays, they're held up by pixel offsets
			smash_screen(wall_screen)
			wall_screen.hitby(src, hitpush = FALSE, throwingdatum = throwingdatum)

/obj/item/sledgehammer/proc/push_catcher(mob/living/catcher, datum/thrownthing/throwingdatum)
	var/turf/catcher_turf = get_turf(catcher)
	catcher.Move(get_step(catcher_turf, throwingdatum.init_dir), throwingdatum.init_dir)
	log_combat(throwingdatum.get_thrower(), catcher, "pushed back with a caught spun throw of", src)
	if(get_turf(catcher) != catcher_turf)
		return
	var/knocked_down = catcher.Knockdown(SHOVE_KNOCKDOWN_SOLID, daze_amount = 3 SECONDS) // it literally shoves you
	catcher.visible_message(
		span_danger("[catcher] catches [src] and gets slammed into what is behind [catcher.p_them()][knocked_down ? ", going down" : ""]!"),
		span_userdanger("You catch [src], but it slams you back[knocked_down ? " and off your feet" : ""]!"),
		span_hear("You hear a loud thud!"),
	)

/obj/item/sledgehammer/proc/smash_screen(obj/machinery/screen)
	if(screen.resistance_flags & INDESTRUCTIBLE)
		return
	if(screen.atom_break(MELEE)) // and you'll see why 2484 won't be like "1984"
		screen.visible_message(span_danger("[src] smashes straight through [screen]!"))

/obj/item/sledgehammer/throw_at(atom/target, range, speed, mob/thrower, spin = 1, diagonals_first = 0, datum/callback/callback, force, gentle = FALSE, quickstart = TRUE, throw_type_path = /datum/thrownthing)
	if(throwing && spun_throw_in_flight)
		end_spun_throw()
	return ..()

/datum/action/cooldown/hammer_throw
	name = "Hammer Throw"
	desc = "Pick a spot, spin up with both hands and let the hammer fly. Telescreens hate this one trick."
	check_flags = /datum/action/item_action::check_flags | AB_CHECK_IMMOBILE
	transparent_when_unavailable = TRUE
	button_icon_state = null
	click_to_activate = TRUE
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

/datum/action/cooldown/hammer_throw/New(Target, original = TRUE)
	. = ..()
	AddComponent(/datum/component/action_item_overlay, target)
	RegisterSignal(target, SIGNAL_ADDTRAIT(TRAIT_WIELDED), PROC_REF(update_status_on_signal))
	RegisterSignal(target, SIGNAL_REMOVETRAIT(TRAIT_WIELDED), PROC_REF(on_unwield))

/datum/action/cooldown/hammer_throw/proc/on_unwield(datum/source)
	SIGNAL_HANDLER
	if(owner && owner.click_intercept == src) // one hand off drops the aim too
		unset_click_ability(owner, refund_cooldown = FALSE)
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/cooldown/hammer_throw/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!HAS_TRAIT(target, TRAIT_WIELDED))
		if(feedback)
			owner.balloon_alert(owner, "not dual-wielded!")
		return FALSE
	var/obj/item/sledgehammer/hammer = target
	if(hammer.spin_facing)
		if(feedback)
			owner.balloon_alert(owner, "already spinning!")
		return FALSE
	return TRUE

/datum/action/cooldown/hammer_throw/Activate(atom/aimed_at)
	var/obj/item/sledgehammer/hammer = target
	if(HAS_TRAIT(owner, TRAIT_PACIFISM) || HAS_TRAIT(owner, TRAIT_NO_THROWING) || HAS_TRAIT(hammer, TRAIT_NODROP))
		owner.balloon_alert(owner, "can't throw!")
		return FALSE
	var/turf/aim_turf = get_turf(aimed_at)
	if(isnull(aim_turf) || aim_turf.z != owner.z || hammer.standing_on_mark(owner, aim_turf))
		return FALSE
	INVOKE_ASYNC(hammer, TYPE_PROC_REF(/obj/item/sledgehammer, wind_up_throw), owner, aim_turf)
	return TRUE
