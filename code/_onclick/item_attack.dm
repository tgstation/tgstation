/**
 * This is the proc that handles the order of an item_attack.
 *
 * The order of procs called is:
 * * [/atom/proc/tool_act] on the target. If it returns ITEM_INTERACT_SUCCESS or ITEM_INTERACT_BLOCKING, the chain will be stopped.
 * * [/obj/item/proc/pre_attack] on src. If this returns TRUE, the chain will be stopped.
 * * [/atom/proc/attackby] on the target. If it returns TRUE, the chain will be stopped.
 * * [/obj/item/proc/afterattack]. The return value does not matter.
 */
/obj/item/proc/melee_attack_chain(mob/user, atom/target, list/modifiers)
	//Proxy replaces src cause it returns an atom that will attack the target on our behalf
	var/obj/item/source_atom = get_proxy_attacker_for(target, user)
	if(source_atom != src) //if we are someone else then call that attack chain else we can proceed with the usual stuff
		return source_atom.melee_attack_chain(user, target, modifiers)

	var/is_right_clicking = LAZYACCESS(modifiers, RIGHT_CLICK)

	var/item_interact_result = target.base_item_interaction(user, src, modifiers)
	if(item_interact_result & ITEM_INTERACT_SUCCESS)
		return TRUE
	if(item_interact_result & ITEM_INTERACT_BLOCKING)
		return FALSE

	// At this point it means we're not doing a non-combat interaction so let's just try to bash it

	var/pre_attack_result
	if (is_right_clicking)
		switch (pre_attack_secondary(target, user, modifiers))
			if (SECONDARY_ATTACK_CALL_NORMAL)
				pre_attack_result = pre_attack(target, user, modifiers)
			if (SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				return TRUE
			if (SECONDARY_ATTACK_CONTINUE_CHAIN)
				EMPTY_BLOCK_GUARD // Normal behavior
			else
				CRASH("pre_attack_secondary must return an SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")
	else
		pre_attack_result = pre_attack(target, user, modifiers)

	if(pre_attack_result)
		return TRUE

	// At this point the attack is really about to happen

	var/attackby_result
	if (is_right_clicking)
		switch (target.attackby_secondary(src, user, modifiers))
			if (SECONDARY_ATTACK_CALL_NORMAL)
				attackby_result = target.attackby(src, user, modifiers)
			if (SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				return TRUE
			if (SECONDARY_ATTACK_CONTINUE_CHAIN)
				EMPTY_BLOCK_GUARD // Normal behavior
			else
				CRASH("attackby_secondary must return an SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")
	else
		attackby_result = target.attackby(src, user, modifiers)

	if (attackby_result)
		// This means the attack failed or was handled for whatever reason
		return TRUE

	// At this point it means the attack was "successful", or at least unhandled, in some way
	// This can mean nothing happened, this can mean the target took damage, etc.

	if(user.client && isitem(target))
		if(isnull(user.get_inactive_held_item()))
			SStutorials.suggest_tutorial(user, /datum/tutorial/switch_hands, modifiers)
		else
			SStutorials.suggest_tutorial(user, /datum/tutorial/drop, modifiers)

	return TRUE

/// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user, modifiers)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	interact(user)

/// Called when the item is in the active hand, and right-clicked. Intended for alternate or opposite functions, such as lowering reagent transfer amount. At the moment, there is no verb or hotkey.
/obj/item/proc/attack_self_secondary(mob/user, modifiers)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF_SECONDARY, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

/**
 * Called on the item before it hits something
 *
 * Arguments:
 * * atom/target - The atom about to be hit
 * * mob/living/user - The mob doing the htting
 * * list/modifiers - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/obj/item/proc/pre_attack(atom/target, mob/living/user, list/modifiers) //do stuff before attackby!
	if(SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACK, target, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	return FALSE //return TRUE to avoid calling attackby after this proc does stuff

/**
 * Called on the item before it hits something, when right clicking.
 *
 * Arguments:
 * * atom/target - The atom about to be hit
 * * mob/living/user - The mob doing the htting
 * * list/modifiers - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/obj/item/proc/pre_attack_secondary(atom/target, mob/living/user, list/modifiers)
	var/signal_result = SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACK_SECONDARY, target, user, modifiers)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL

/**
 * Called on an object being hit by an item
 *
 * Arguments:
 * * obj/item/attacking_item - The item hitting this atom
 * * mob/user - The wielder of this item
 * * params - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/atom/proc/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACKBY, attacking_item, user, modifiers) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return FALSE

/**
 * Called on an object being right-clicked on by an item
 *
 * Arguments:
 * * obj/item/weapon - The item hitting this atom
 * * mob/user - The wielder of this item
 * * params - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/atom/proc/attackby_secondary(obj/item/weapon, mob/user, list/modifiers)
	var/signal_result = SEND_SIGNAL(src, COMSIG_ATOM_ATTACKBY_SECONDARY, weapon, user, modifiers)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL

/obj/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	if(..())
		return TRUE
	if(!(obj_flags & CAN_BE_HIT))
		return FALSE
	return attacking_item.attack_atom(src, user, modifiers)

/mob/living/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	for(var/datum/surgery/operation as anything in surgeries)
		if(IS_IN_INVALID_SURGICAL_POSITION(src, operation))
			continue
		if(!(operation.surgery_flags & SURGERY_SELF_OPERABLE) && (user == src))
			continue
		if(operation.next_step(user, modifiers))
			return ITEM_INTERACT_SUCCESS

	return NONE

/mob/living/attackby(obj/item/attacking_item, mob/living/user, list/modifiers)
	if(..())
		return TRUE
	user.changeNext_move(attacking_item.attack_speed)
	return attacking_item.attack(src, user, modifiers)

/mob/living/attackby_secondary(obj/item/weapon, mob/living/user, list/modifiers)
	var/result = weapon.attack_secondary(src, user, modifiers)

	// Normal attackby updates click cooldown, so we have to make up for it
	if (result != SECONDARY_ATTACK_CALL_NORMAL)
		if(weapon.secondary_attack_speed)
			user.changeNext_move(weapon.secondary_attack_speed)
		else
			user.changeNext_move(weapon.attack_speed)

	return result

/**
 * Called from [/mob/living/proc/attackby]
 *
 * Arguments:
 * * mob/living/target_mob - The mob being hit by this item
 * * mob/living/user - The mob hitting with this item
 * * params - Click params of this attack
 */
/obj/item/proc/attack(mob/living/target_mob, mob/living/user, list/modifiers)
	var/signal_return = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, target_mob, user, modifiers) || SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, target_mob, user, modifiers)
	if(signal_return & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	if(signal_return & COMPONENT_SKIP_ATTACK)
		return FALSE

	if(item_flags & NOBLUDGEON)
		return FALSE

	if(damtype != STAMINA && force && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You don't want to harm other living beings!"))
		return FALSE

	if(!force && !HAS_TRAIT(src, TRAIT_CUSTOM_TAP_SOUND))
		playsound(src, 'sound/items/weapons/tap.ogg', get_clamped_volume(), TRUE, -1)
	else if(hitsound)
		playsound(src, hitsound, get_clamped_volume(), TRUE, extrarange = stealthy_audio ? SILENCED_SOUND_EXTRARANGE : -1, falloff_distance = 0)

	target_mob.lastattacker = user.real_name
	target_mob.lastattackerckey = user.ckey

	if(force && target_mob == user && user.client)
		user.client.give_award(/datum/award/achievement/misc/selfouch, user)

	if(get(src, /mob/living) == user) // telekinesis.
		user.do_attack_animation(target_mob)
	if(!target_mob.attacked_by(src, user))
		return TRUE

	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target_mob, user, modifiers)
	SEND_SIGNAL(target_mob, COMSIG_ATOM_AFTER_ATTACKEDBY, src, user, modifiers)
	afterattack(target_mob, user, modifiers)

	log_combat(user, target_mob, "attacked", src.name, "(COMBAT MODE: [uppertext(user.combat_mode)]) (DAMTYPE: [uppertext(damtype)])")
	add_fingerprint(user)
	return FALSE // unhandled

/// The equivalent of [/obj/item/proc/attack] but for alternate attacks, AKA right clicking
/obj/item/proc/attack_secondary(mob/living/victim, mob/living/user, list/modifiers)
	var/signal_result = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SECONDARY, victim, user, modifiers)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL

/// The equivalent of the standard version of [/obj/item/proc/attack] but for non mob targets.
/obj/item/proc/attack_atom(atom/attacked_atom, mob/living/user, list/modifiers)
	var/signal_return = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_ATOM, attacked_atom, user) | SEND_SIGNAL(user, COMSIG_LIVING_ATTACK_ATOM, attacked_atom)
	if(signal_return & COMPONENT_SKIP_ATTACK)
		return TRUE
	if(signal_return & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FALSE
	if(item_flags & NOBLUDGEON)
		return FALSE
	user.changeNext_move(attack_speed)
	if(get(src, /mob/living) == user) // telekinesis.
		user.do_attack_animation(attacked_atom)
	attacked_atom.attacked_by(src, user)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, attacked_atom, user, modifiers)
	SEND_SIGNAL(attacked_atom, COMSIG_ATOM_AFTER_ATTACKEDBY, src, user, modifiers)
	afterattack(attacked_atom, user, modifiers)
	return FALSE // unhandled

/// Called from [/obj/item/proc/attack_atom] and [/obj/item/proc/attack] if the attack succeeds
/atom/proc/attacked_by(obj/item/attacking_item, mob/living/user)
	if(!uses_integrity)
		CRASH("attacked_by() was called on an object that doesn't use integrity!")

	if(!attacking_item.force)
		return

	var/damage = take_damage(attacking_item.force, attacking_item.damtype, MELEE, 1, get_dir(src, user))
	//only witnesses close by and the victim see a hit message.
	user.visible_message(span_danger("[user] hits [src] with [attacking_item][damage ? "." : ", without leaving a mark!"]"), \
		span_danger("You hit [src] with [attacking_item][damage ? "." : ", without leaving a mark!"]"), null, COMBAT_MESSAGE_RANGE)
	log_combat(user, src, "attacked", attacking_item)

/area/attacked_by(obj/item/attacking_item, mob/living/user)
	CRASH("areas are NOT supposed to have attacked_by() called on them!")

/mob/living/attacked_by(obj/item/attacking_item, mob/living/user)

	var/targeting = check_zone(user.zone_selected)
	if(user != src)
		var/zone_hit_chance = 80
		if(body_position == LYING_DOWN)
			zone_hit_chance += 10
		targeting = get_random_valid_zone(targeting, zone_hit_chance)
	var/targeting_human_readable = parse_zone_with_bodypart(targeting)

	send_item_attack_message(attacking_item, user, targeting_human_readable, targeting)

	var/armor_block = min(run_armor_check(
			def_zone = targeting,
			attack_flag = MELEE,
			absorb_text = span_notice("Your armor has protected your [targeting_human_readable]!"),
			soften_text = span_warning("Your armor has softened a hit to your [targeting_human_readable]!"),
			armour_penetration = attacking_item.armour_penetration,
			weak_against_armour = attacking_item.weak_against_armour,
		), ARMOR_MAX_BLOCK)

	var/damage = attacking_item.force
	if(mob_biotypes & MOB_ROBOTIC)
		damage *= attacking_item.get_demolition_modifier(src)

	var/wounding = attacking_item.wound_bonus
	if((attacking_item.item_flags & SURGICAL_TOOL) && !user.combat_mode && body_position == LYING_DOWN && (LAZYLEN(surgeries) > 0))
		wounding = CANT_WOUND

	if(user != src)
		// This doesn't factor in armor, or most damage modifiers (physiology). Your mileage may vary
		if(check_block(attacking_item, damage, "\the [attacking_item]", MELEE_ATTACK, attacking_item.armour_penetration, attacking_item.damtype))
			return FALSE

	SEND_SIGNAL(attacking_item, COMSIG_ITEM_ATTACK_ZONE, src, user, targeting)

	if(damage <= 0)
		return TRUE

	if(ishuman(src) || client) // istype(src) is kinda bad, but it's to avoid spamming the blackbox
		SSblackbox.record_feedback("nested tally", "item_used_for_combat", 1, list("[attacking_item.force]", "[attacking_item.type]"))
		SSblackbox.record_feedback("tally", "zone_targeted", 1, targeting_human_readable)

	var/damage_done = apply_damage(
		damage = damage,
		damagetype = attacking_item.damtype,
		def_zone = targeting,
		blocked = armor_block,
		wound_bonus = wounding,
		bare_wound_bonus = attacking_item.bare_wound_bonus,
		sharpness = attacking_item.get_sharpness(),
		attack_direction = get_dir(user, src),
		attacking_item = attacking_item,
	)

	attack_effects(damage_done, targeting, armor_block, attacking_item, user)

	return TRUE

/**
 * Called when we take damage, used to cause effects such as a blood splatter.
 *
 * Return TRUE if an effect was done, FALSE otherwise.
 */
/mob/living/proc/attack_effects(damage_done, hit_zone, armor_block, obj/item/attacking_item, mob/living/attacker)
	if(damage_done > 0 && attacking_item.damtype == BRUTE && prob(25 + damage_done * 2))
		attacking_item.add_mob_blood(src)
		add_splatter_floor(get_turf(src))
		if(get_dist(attacker, src) <= 1)
			if(ishuman(attacker))
				var/bloodied_things = ITEM_SLOT_GLOVES
				if(damage_done >= 20 || (damage_done >= 15 && prob(25)))
					bloodied_things |= ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING
					if(prob(33) && damage_done >= 10)
						bloodied_things |= ITEM_SLOT_FEET
					if(prob(33) && damage_done >= 24) // fireaxe damage, because heeeeere's johnny
						bloodied_things |= ITEM_SLOT_MASK
					if(prob(33) && damage_done >= 30) // esword damage
						bloodied_things |= ITEM_SLOT_HEAD

				var/mob/living/carbon/human/human_attacker = attacker
				human_attacker.add_blood_DNA_to_items(get_blood_dna_list(), bloodied_things)
			else
				attacker.add_mob_blood(src)
		return TRUE

	return FALSE

/mob/living/carbon/attack_effects(damage_done, hit_zone, armor_block, obj/item/attacking_item, mob/living/attacker)
	var/obj/item/bodypart/hit_bodypart = get_bodypart(hit_zone) || bodyparts[1]
	if(!hit_bodypart.can_bleed())
		return FALSE

	return ..()

/mob/living/carbon/human/attack_effects(damage_done, hit_zone, armor_block, obj/item/attacking_item, mob/living/attacker)
	. = ..()
	switch(hit_zone)
		if(BODY_ZONE_HEAD)
			if(.)
				var/bloodied_things = ITEM_SLOT_MASK|ITEM_SLOT_HEAD
				if(prob(33))
					bloodied_things |= ITEM_SLOT_EYES
				add_blood_DNA_to_items(get_blood_dna_list(), bloodied_things)

			if(!attacking_item.get_sharpness() && !HAS_TRAIT(src, TRAIT_HEAD_INJURY_BLOCKED) && attacking_item.damtype == BRUTE)
				if(prob(damage_done))
					adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
					if(stat == CONSCIOUS)
						visible_message(
							span_danger("[src] is knocked senseless!"),
							span_userdanger("You're knocked senseless!"),
						)
						set_confusion_if_lower(20 SECONDS)
						adjust_eye_blur(20 SECONDS)
					if(prob(10))
						gain_trauma(/datum/brain_trauma/mild/concussion)
				else
					adjustOrganLoss(ORGAN_SLOT_BRAIN, damage_done * 0.2)

				// rev deconversion through blunt trauma.
				// this can be signalized to the rev datum
				if(mind && stat == CONSCIOUS && src != attacker && prob(damage_done + ((100 - health) * 0.5)))
					var/datum/antagonist/rev/rev = mind.has_antag_datum(/datum/antagonist/rev)
					rev?.remove_revolutionary(attacker)

		if(BODY_ZONE_CHEST)
			if(.)
				add_blood_DNA_to_items(get_blood_dna_list(), ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING)

			if(stat == CONSCIOUS && !attacking_item.get_sharpness() && !HAS_TRAIT(src, TRAIT_BRAWLING_KNOCKDOWN_BLOCKED) && attacking_item.damtype == BRUTE)
				if(prob(damage_done))
					visible_message(
						span_danger("[src] is knocked down!"),
						span_userdanger("You're knocked down!"),
					)
					apply_effect(6 SECONDS, EFFECT_KNOCKDOWN, armor_block)

	// Triggers force say events
	if(damage_done > 10 || (damage_done >= 5 && prob(33)))
		force_say()

/**
 * Last proc in the [/obj/item/proc/melee_attack_chain].
 * Returns a bitfield containing AFTERATTACK_PROCESSED_ITEM if the user is likely intending to use this item on another item.
 * Some consumers currently return TRUE to mean "processed". These are not consistent and should be taken with a grain of salt.
 *
 * Arguments:
 * * atom/target - The thing that was hit
 * * mob/user - The mob doing the hitting
 * * proximity_flag - is 1 if this afterattack was called on something adjacent, in your square, or on your person.
 * * click_parameters - is the params string from byond [/atom/proc/Click] code, see that documentation.
 */
/obj/item/proc/afterattack(atom/target, mob/user, list/modifiers)
	PROTECTED_PROC(TRUE)
	return

/obj/item/proc/get_clamped_volume()
	if(w_class)
		if(force)
			return clamp((force + w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
		else
			return clamp(w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100

/mob/living/proc/send_item_attack_message(obj/item/weapon, mob/living/user, hit_area, def_zone)
	if(!weapon.force && !length(weapon.attack_verb_simple) && !length(weapon.attack_verb_continuous))
		return

	// Sanity in case one is null for some reason
	var/picked_index = rand(max(length(weapon.attack_verb_simple), length(weapon.attack_verb_continuous)))

	var/message_verb_continuous = "attacks"
	var/message_verb_simple = "attack"
	var/message_hit_area = get_hit_area_message(hit_area)
	// Sanity in case one is... longer than the other?
	if (picked_index && length(weapon.attack_verb_continuous) >= picked_index)
		message_verb_continuous = weapon.attack_verb_continuous[picked_index]
	if (picked_index && length(weapon.attack_verb_simple) >= picked_index)
		message_verb_simple = weapon.attack_verb_simple[picked_index]

	var/attack_message_spectator = "[src] [message_verb_continuous][message_hit_area] with [weapon]!"
	var/attack_message_victim = "Something [message_verb_continuous] you[message_hit_area] with [weapon]!"
	var/attack_message_attacker = "You [message_verb_simple] [src][message_hit_area] with [weapon]!"
	if(user in viewers(src, null))
		attack_message_spectator = "[user] [message_verb_continuous] [src][message_hit_area] with [weapon]!"
		attack_message_victim = "[user] [message_verb_continuous] you[message_hit_area] with [weapon]!"
	if(user == src)
		attack_message_victim = "You [message_verb_simple] yourself[message_hit_area] with [weapon]."
	visible_message(span_danger("[attack_message_spectator]"),\
		span_userdanger("[attack_message_victim]"), null, COMBAT_MESSAGE_RANGE, user)
	if(is_blind())
		to_chat(src, span_danger("Someone hits you[message_hit_area]!"))
	to_chat(user, span_danger("[attack_message_attacker]"))
	return 1

/// Overridable proc so subtypes can have unique targetted strike zone messages, return a string.
/mob/living/proc/get_hit_area_message(input_area)
	if(input_area)
		return " in the [input_area]"

	return ""
