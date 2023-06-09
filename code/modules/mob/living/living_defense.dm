
/mob/living/proc/run_armor_check(def_zone = null, attack_flag = MELEE, absorb_text = null, soften_text = null, armour_penetration, penetrated_text, silent=FALSE, weak_against_armour = FALSE)
	var/our_armor = getarmor(def_zone, attack_flag)

	if(our_armor <= 0)
		return our_armor
	if(weak_against_armour && our_armor >= 0)
		our_armor *= ARMOR_WEAKENED_MULTIPLIER
	if(silent)
		return max(0, our_armor - armour_penetration)

	//the if "armor" check is because this is used for everything on /living, including humans
	if(armour_penetration)
		our_armor = max(0, our_armor - armour_penetration)
		if(penetrated_text)
			to_chat(src, span_userdanger("[penetrated_text]"))
		else
			to_chat(src, span_userdanger("Your armor was penetrated!"))
	else if(our_armor >= 100)
		if(absorb_text)
			to_chat(src, span_notice("[absorb_text]"))
		else
			to_chat(src, span_notice("Your armor absorbs the blow!"))
	else
		if(soften_text)
			to_chat(src, span_warning("[soften_text]"))
		else
			to_chat(src, span_warning("Your armor softens the blow!"))
	return our_armor

/mob/living/proc/getarmor(def_zone, type)
	return 0

//this returns the mob's protection against eye damage (number between -1 and 2) from bright lights
/mob/living/proc/get_eye_protection()
	return 0

//this returns the mob's protection against ear damage (0:no protection; 1: some ear protection; 2: has no ears)
/mob/living/proc/get_ear_protection()
	var/turf/current_turf = get_turf(src)
	var/datum/gas_mixture/environment = current_turf.return_air()
	var/pressure = environment ? environment.return_pressure() : 0
	if(pressure < SOUND_MINIMUM_PRESSURE) //space is empty
		return 1
	return 0

/**
 * Checks if our mob has their mouth covered.
 *
 * Note that we only care about [ITEM_SLOT_HEAD] and [ITEM_SLOT_MASK].
 *  (so if you check all slots, it'll return head, then mask)
 *That is also the priority order
 * Arguments
 * * check_flags: What item slots should we check?
 *
 * Retuns a truthy value (a ref to what is covering mouth), or a falsy value (null)
 */
/mob/living/proc/is_mouth_covered(check_flags = ALL)
	return null

/**
 * Checks if our mob has their eyes covered.
 *
 * Note that we only care about [ITEM_SLOT_HEAD], [ITEM_SLOT_MASK], and [ITEM_SLOT_GLASSES].
 * That is also the priority order (so if you check all slots, it'll return head, then mask, then glasses)
 *
 * Arguments
 * * check_flags: What item slots should we check?
 *
 * Retuns a truthy value (a ref to what is covering eyes), or a falsy value (null)
 */
/mob/living/proc/is_eyes_covered(check_flags = ALL)
	return null

/**
 * Checks if our mob is protected from pepper spray.
 *
 * Note that we only care about [ITEM_SLOT_HEAD] and [ITEM_SLOT_MASK].
 * That is also the priority order (so if you check all slots, it'll return head, then mask)
 *
 * Arguments
 * * check_flags: What item slots should we check?
 *
 * Retuns a truthy value (a ref to what is protecting us), or a falsy value (null)
 */
/mob/living/proc/is_pepper_proof(check_flags = ALL)
	return null

/mob/living/proc/on_hit(obj/projectile/P)
	return BULLET_ACT_HIT

/mob/living/bullet_act(obj/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	if(P.is_hostile_projectile() && (. != BULLET_ACT_BLOCK))
		var/attack_direction = get_dir(P.starting, src)
		// we need a second, silent armor check to actually know how much to reduce damage taken, as opposed to
		// on [/atom/proc/bullet_act] where it's just to pass it to the projectile's on_hit().
		var/armor_check = check_projectile_armor(def_zone, P, is_silent = TRUE)
		armor_check = min(ARMOR_MAX_BLOCK, armor_check) //cap damage reduction at 90%
		apply_damage(P.damage, P.damage_type, def_zone, armor_check, wound_bonus=P.wound_bonus, bare_wound_bonus=P.bare_wound_bonus, sharpness = P.sharpness, attack_direction = attack_direction)
		apply_effects(P.stun, P.knockdown, P.unconscious, P.slur, P.stutter, P.eyeblur, P.drowsy, armor_check, P.stamina, P.jitter, P.paralyze, P.immobilize)
		if(P.dismemberment)
			check_projectile_dismemberment(P, def_zone)
	return . ? BULLET_ACT_HIT : BULLET_ACT_BLOCK

/mob/living/check_projectile_armor(def_zone, obj/projectile/impacting_projectile, is_silent)
	return run_armor_check(def_zone, impacting_projectile.armor_flag, "","",impacting_projectile.armour_penetration, "", is_silent, impacting_projectile.weak_against_armour)

/mob/living/proc/check_projectile_dismemberment(obj/projectile/P, def_zone)
	return 0

/obj/item/proc/get_volume_by_throwforce_and_or_w_class()
		if(throwforce && w_class)
				return clamp((throwforce + w_class) * 5, 30, 100)// Add the item's throwforce to its weight class and multiply by 5, then clamp the value between 30 and 100
		else if(w_class)
				return clamp(w_class * 8, 20, 100) // Multiply the item's weight class by 8, then clamp the value between 20 and 100
		else
				return 0

/mob/living/proc/set_combat_mode(new_mode, silent = TRUE)
	if(combat_mode == new_mode)
		return
	. = combat_mode
	combat_mode = new_mode
	if(hud_used?.action_intent)
		hud_used.action_intent.update_appearance()
	if(silent || !(client?.prefs.read_preference(/datum/preference/toggle/sound_combatmode)))
		return
	if(combat_mode)
		SEND_SOUND(src, sound('sound/misc/ui_togglecombat.ogg', volume = 25)) //Sound from interbay!
	else
		SEND_SOUND(src, sound('sound/misc/ui_toggleoffcombat.ogg', volume = 25)) //Slightly modified version of the above

/mob/living/proc/toggle_strafe_lock()
	set_dir_on_move = !set_dir_on_move
	if(set_dir_on_move)
		remove_movespeed_modifier(/datum/movespeed_modifier/strafing)
	else
		add_movespeed_modifier(/datum/movespeed_modifier/strafing)
	hud_used?.strafe_icon?.update_appearance(UPDATE_ICON_STATE)

/mob/living/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isitem(AM))
		var/obj/item/thrown_item = AM
		var/zone = get_random_valid_zone(BODY_ZONE_CHEST, 65)//Hits a random part of the body, geared towards the chest
		var/nosell_hit = SEND_SIGNAL(thrown_item, COMSIG_MOVABLE_IMPACT_ZONE, src, zone, blocked, throwingdatum) // TODO: find a better way to handle hitpush and skipcatch for humans
		if(nosell_hit)
			skipcatch = TRUE
			hitpush = FALSE

		if(blocked)
			return TRUE

		var/mob/thrown_by = thrown_item.thrownby?.resolve()
		if(thrown_by)
			log_combat(thrown_by, src, "threw and hit", thrown_item)
		if(nosell_hit)
			return ..()
		visible_message(span_danger("[src] is hit by [thrown_item]!"), \
						span_userdanger("You're hit by [thrown_item]!"))
		if(!thrown_item.throwforce)
			return
		var/armor = run_armor_check(zone, MELEE, "Your armor has protected your [parse_zone(zone)].", "Your armor has softened hit to your [parse_zone(zone)].", thrown_item.armour_penetration, "", FALSE, thrown_item.weak_against_armour)
		apply_damage(thrown_item.throwforce, thrown_item.damtype, zone, armor, sharpness = thrown_item.get_sharpness(), wound_bonus = (nosell_hit * CANT_WOUND))
		if(QDELETED(src)) //Damage can delete the mob.
			return
		if(body_position == LYING_DOWN) // physics says it's significantly harder to push someone by constantly chucking random furniture at them if they are down on the floor.
			hitpush = FALSE
		return ..()

	playsound(loc, 'sound/weapons/genhit.ogg', 50, TRUE, -1) //Item sounds are handled in the item itself
	return ..()

/mob/living/fire_act()
	adjust_fire_stacks(3)
	ignite_mob()

/mob/living/proc/grabbedby(mob/living/carbon/user, supress_message = FALSE)
	if(user == src || anchored || !isturf(user.loc))
		return FALSE
	if(!user.pulling || user.pulling != src)
		user.start_pulling(src, supress_message = supress_message)
		return

	if(!(status_flags & CANPUSH) || HAS_TRAIT(src, TRAIT_PUSHIMMUNE))
		to_chat(user, span_warning("[src] can't be grabbed more aggressively!"))
		return FALSE

	if(user.grab_state >= GRAB_AGGRESSIVE && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You don't want to risk hurting [src]!"))
		return FALSE
	grippedby(user)

//proc to upgrade a simple pull into a more aggressive grab.
/mob/living/proc/grippedby(mob/living/carbon/user, instant = FALSE)
	if(user.grab_state >= user.max_grab)
		return
	user.changeNext_move(CLICK_CD_GRABBING)
	var/sound_to_play = 'sound/weapons/thudswoosh.ogg'
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna.species.grab_sound)
			sound_to_play = H.dna.species.grab_sound
	playsound(src.loc, sound_to_play, 50, TRUE, -1)

	if(user.grab_state) //only the first upgrade is instantaneous
		var/old_grab_state = user.grab_state
		var/grab_upgrade_time = instant ? 0 : 30
		visible_message(span_danger("[user] starts to tighten [user.p_their()] grip on [src]!"), \
						span_userdanger("[user] starts to tighten [user.p_their()] grip on you!"), span_hear("You hear aggressive shuffling!"), null, user)
		to_chat(user, span_danger("You start to tighten your grip on [src]!"))
		switch(user.grab_state)
			if(GRAB_AGGRESSIVE)
				log_combat(user, src, "attempted to neck grab", addition="neck grab")
			if(GRAB_NECK)
				log_combat(user, src, "attempted to strangle", addition="kill grab")
		if(!do_after(user, grab_upgrade_time, src))
			return FALSE
		if(!user.pulling || user.pulling != src || user.grab_state != old_grab_state)
			return FALSE
	user.setGrabState(user.grab_state + 1)
	switch(user.grab_state)
		if(GRAB_AGGRESSIVE)
			var/add_log = ""
			if(HAS_TRAIT(user, TRAIT_PACIFISM))
				visible_message(span_danger("[user] firmly grips [src]!"),
								span_danger("[user] firmly grips you!"), span_hear("You hear aggressive shuffling!"), null, user)
				to_chat(user, span_danger("You firmly grip [src]!"))
				add_log = " (pacifist)"
			else
				visible_message(span_danger("[user] grabs [src] aggressively!"), \
								span_userdanger("[user] grabs you aggressively!"), span_hear("You hear aggressive shuffling!"), null, user)
				to_chat(user, span_danger("You grab [src] aggressively!"))
			stop_pulling()
			log_combat(user, src, "grabbed", addition="aggressive grab[add_log]")
		if(GRAB_NECK)
			log_combat(user, src, "grabbed", addition="neck grab")
			visible_message(span_danger("[user] grabs [src] by the neck!"),\
							span_userdanger("[user] grabs you by the neck!"), span_hear("You hear aggressive shuffling!"), null, user)
			to_chat(user, span_danger("You grab [src] by the neck!"))
			if(!buckled && !density)
				Move(user.loc)
		if(GRAB_KILL)
			log_combat(user, src, "strangled", addition="kill grab")
			visible_message(span_danger("[user] is strangling [src]!"), \
							span_userdanger("[user] is strangling you!"), span_hear("You hear aggressive shuffling!"), null, user)
			to_chat(user, span_danger("You're strangling [src]!"))
			if(!buckled && !density)
				Move(user.loc)
	user.set_pull_offsets(src, grab_state)
	return TRUE

/mob/living/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return FALSE
	return ..()

/mob/living/acid_act(acidpwr, acid_volume)
	take_bodypart_damage(acidpwr * min(1, acid_volume * 0.1))
	return TRUE

///As the name suggests, this should be called to apply electric shocks.
/mob/living/proc/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	SEND_SIGNAL(src, COMSIG_LIVING_ELECTROCUTE_ACT, shock_damage, source, siemens_coeff, flags)
	shock_damage *= siemens_coeff
	if((flags & SHOCK_TESLA) && HAS_TRAIT(src, TRAIT_TESLA_SHOCKIMMUNE))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
		return FALSE
	if(shock_damage < 1)
		return FALSE
	if(!(flags & SHOCK_ILLUSION))
		adjustFireLoss(shock_damage)
	else
		adjustStaminaLoss(shock_damage)
	if(!(flags & SHOCK_SUPPRESS_MESSAGE))
		visible_message(
			span_danger("[src] was shocked by \the [source]!"), \
			span_userdanger("You feel a powerful shock coursing through your body!"), \
			span_hear("You hear a heavy electrical crack.") \
		)
	return shock_damage

/mob/living/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/obj/O in contents)
		O.emp_act(severity)

///Logs, gibs and returns point values of whatever mob is unfortunate enough to get eaten.
/mob/living/singularity_act()
	investigate_log("has been consumed by the singularity.", INVESTIGATE_ENGINE) //Oh that's where the clown ended up!
	investigate_log("has been gibbed by the singularity.", INVESTIGATE_DEATHS)
	gib()
	return 20

/mob/living/narsie_act()
	if(status_flags & GODMODE || QDELETED(src))
		return

	if(GLOB.cult_narsie && GLOB.cult_narsie.souls_needed[src])
		GLOB.cult_narsie.souls_needed -= src
		GLOB.cult_narsie.souls += 1
		if((GLOB.cult_narsie.souls == GLOB.cult_narsie.soul_goal) && (GLOB.cult_narsie.resolved == FALSE))
			GLOB.cult_narsie.resolved = TRUE
			sound_to_playing_players('sound/machines/alarm.ogg')
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(cult_ending_helper), CULT_VICTORY_MASS_CONVERSION), 120)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(ending_helper)), 270)
	if(client)
		makeNewConstruct(/mob/living/simple_animal/hostile/construct/harvester, src, cultoverride = TRUE)
	else
		switch(rand(1, 4))
			if(1)
				new /mob/living/simple_animal/hostile/construct/juggernaut/hostile(get_turf(src))
			if(2)
				new /mob/living/simple_animal/hostile/construct/wraith/hostile(get_turf(src))
			if(3)
				new /mob/living/simple_animal/hostile/construct/artificer/hostile(get_turf(src))
			if(4)
				new /mob/living/simple_animal/hostile/construct/proteon/hostile(get_turf(src))
	spawn_dust()
	investigate_log("has been gibbed by Nar'Sie.", INVESTIGATE_DEATHS)
	gib()
	return TRUE

//called when the mob receives a bright flash
/mob/living/proc/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash, length = 2.5 SECONDS)
	if(HAS_TRAIT(src, TRAIT_NOFLASH))
		return FALSE
	if(get_eye_protection() >= intensity)
		return FALSE
	if(is_blind() && !(override_blindness_check || affect_silicon))
		return FALSE

	// this forces any kind of flash (namely normal and static) to use a black screen for photosensitive players
	// it absolutely isn't an ideal solution since sudden flashes to black can apparently still trigger epilepsy, but byond apparently doesn't let you freeze screens
	// and this is apparently at least less likely to trigger issues than a full white/static flash
	if(client?.prefs?.read_preference(/datum/preference/toggle/darkened_flash))
		type = /atom/movable/screen/fullscreen/flash/black

	overlay_fullscreen("flash", type)
	addtimer(CALLBACK(src, PROC_REF(clear_fullscreen), "flash", length), length)
	SEND_SIGNAL(src, COMSIG_MOB_FLASHED, intensity, override_blindness_check, affect_silicon, visual, type, length)
	return TRUE

//called when the mob receives a loud bang
/mob/living/proc/soundbang_act()
	return FALSE

//to damage the clothes worn by a mob
/mob/living/proc/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	return


/mob/living/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item)
		used_item = get_active_held_item()
	..()

/**
 * Does a slap animation on an atom
 *
 * Uses do_attack_animation to animate the attacker attacking
 * then draws a hand moving across the top half of the target(where a mobs head would usually be) to look like a slap
 * Arguments:
 * * atom/A - atom being slapped
 */
/mob/living/proc/do_slap_animation(atom/slapped)
	do_attack_animation(slapped, no_effect=TRUE)
	var/image/gloveimg = image('icons/effects/effects.dmi', slapped, "slapglove", slapped.layer + 0.1)
	gloveimg.pixel_y = 10 // should line up with head
	gloveimg.pixel_x = 10
	flick_overlay_global(gloveimg, GLOB.clients, 10)

	// And animate the attack!
	animate(gloveimg, alpha = 175, transform = matrix() * 0.75, pixel_x = 0, pixel_y = 10, pixel_z = 0, time = 3)
	animate(time = 1)
	animate(alpha = 0, time = 3, easing = CIRCULAR_EASING|EASE_OUT)

/** Handles exposing a mob to reagents.
 *
 * If the methods include INGEST the mob tastes the reagents.
 * If the methods include VAPOR it incorporates permiability protection.
 */
/mob/living/expose_reagents(list/reagents, datum/reagents/source, methods=TOUCH, volume_modifier=1, show_message=TRUE)
	. = ..()
	if(. & COMPONENT_NO_EXPOSE_REAGENTS)
		return

	if(methods & INGEST)
		taste(source)

	var/touch_protection = (methods & VAPOR) ? getarmor(null, BIO) * 0.01 : 0
	SEND_SIGNAL(source, COMSIG_REAGENTS_EXPOSE_MOB, src, reagents, methods, volume_modifier, show_message, touch_protection)
	for(var/reagent in reagents)
		var/datum/reagent/R = reagent
		. |= R.expose_mob(src, methods, reagents[R], show_message, touch_protection)


/**
 * Checks if this mob has some form of shield or blocking implement
 *
 * * hitby - the thing that is attacking us
 * * damage - how much it's doing
 * * attack_text - the text of the attack, usually like "the baton" (so you can format feedback messages as "blocks the baton with their shield")
 * * attack_type - what type of attack is incoming
 * * armour_penetration - how much, if any, armor penetration the attack has. compared agaiinst armor penetration of the item doing the blocking.
 * this means that items which have their own armor penetration are better at shielding
 */
/mob/living/proc/check_block(atom/hitby, damage = 0, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0, damage_type = BRUTE)
	SHOULD_CALL_PARENT(TRUE)
	if(SEND_SIGNAL(src, COMSIG_LIVING_CHECK_BLOCK, hitby, damage, attack_text, attack_type, armour_penetration, damage_type) & SUCCESSFUL_BLOCK)
		return TRUE

	return FALSE

/**
 * Checks if this mob cannot be knocked down from a shove
 */
/mob/living/proc/is_shove_knockdown_blocked()
	return !(status_flags & CANPUSH|CANKNOCKDOWN)

/mob/living/attack_hand(mob/living/user, list/modifiers)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

	help_shake_act(user)
	return FALSE

/// Called when this mob is help-intent clicked on by the helper mob
/mob/living/proc/help_shake_act(mob/living/helper)
	var/help_simple = response_help_simple || helper.friendly_verb_simple
	var/help_cont = response_help_continuous || helper.friendly_verb_continuous

	if(!help_simple || !help_cont)
		return

	visible_message(span_notice("[helper] [help_cont] [src]."), span_notice("[helper] [help_cont] you."), ignored_mobs = helper)
	to_chat(helper, span_notice("You [help_simple] [src]."))
	adjust_status_effects_on_shake_up()

/**
 * Used primarily for callbacks, clears the slowdown from being shoved
 */
/mob/living/proc/clear_shove_slowdown(obj/item/was_holding)
	remove_movespeed_modifier(/datum/movespeed_modifier/shove)
	var/obj/item/active_item = get_active_held_item()
	if(!QDELETED(was_holding) && active_item && active_item == was_holding)
		visible_message(
			span_warning("[name] regains their grip on \the [active_item]!"),
			span_warning("You regain your grip on \the [active_item]"),
			vision_distance = COMBAT_MESSAGE_RANGE,
		)

/mob/living/attack_hulk(mob/living/carbon/human/user)
	return FALSE

/// Simplified ricochet angle calculation for mobs (also the base version doesn't work on mobs)
/mob/living/handle_ricochet(obj/projectile/ricocheting_projectile)
	var/face_angle = get_angle_raw(ricocheting_projectile.x, ricocheting_projectile.pixel_x, ricocheting_projectile.pixel_y, ricocheting_projectile.p_y, x, y, pixel_x, pixel_y)
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + GET_ANGLE_OF_INCIDENCE(face_angle, (ricocheting_projectile.Angle + 180)))
	ricocheting_projectile.set_angle(new_angle_s)
	return TRUE

/mob/living/proc/begin_blocking()
	if(incapacitated(IGNORE_GRAB))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_STUNIMMUNE))
		return FALSE

	var/obj/item/blocker = get_inactive_held_item() || get_active_held_item()
	if(apply_status_effect(/datum/status_effect/blocking, blocker))
		return TRUE

	return FALSE
