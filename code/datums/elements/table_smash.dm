/// Component which allows mobs to be smashed onto this surface like a wrestling move
/datum/element/table_smash
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// If true, mobs will be placed gently on the table even if they're in an aggressive grab
	var/gentle_push
	/// Passed proc call path for what to do after smashing harmfully into our 'table'-like obj
	var/after_smash_proccall

/datum/element/table_smash/Attach(datum/target, gentle_push = FALSE, after_smash_proccall)
	. = ..()
	if (!isobj(target))
		return ELEMENT_INCOMPATIBLE

	src.gentle_push = gentle_push
	src.after_smash_proccall = after_smash_proccall

	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_interaction))
	RegisterSignal(target, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))

	var/static/list/loc_connections = list(
		COMSIG_LIVING_DISARM_COLLIDE = TYPE_PROC_REF(/obj/structure, on_disarm_shoved_into),
	)
	target.AddElement(/datum/element/connect_loc, loc_connections)

/datum/element/table_smash/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ITEM_INTERACTION))

/// Called when someone clicks on our surface
/datum/element/table_smash/proc/on_interaction(datum/source, mob/user)
	SIGNAL_HANDLER

	var/obj/source_obj = source
	if (!source_obj.Adjacent(user) || !user.pulling)
		return

	if (!isliving(user.pulling))
		if (!(user.pulling.pass_flags & PASSTABLE))
			return

		user.Move_Pulled(source_obj)

		if (user.pulling.loc == source_obj.loc)
			user.visible_message(span_notice("[user] places [user.pulling] onto [source_obj]."),
				span_notice("You place [user.pulling] onto [source_obj]."))
			user.stop_pulling()

		return COMPONENT_CANCEL_ATTACK_CHAIN

	var/mob/living/pushed_mob = user.pulling
	if (pushed_mob.buckled)
		if (pushed_mob.buckled == source_obj)
			//Already buckled to the object, you probably meant to unbuckle them
			return

		to_chat(user, span_warning("[pushed_mob] is buckled to [pushed_mob.buckled]!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, PROC_REF(perform_table_smash), source_obj, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// We have a mob being pressed onto the table, but how strongly?
/datum/element/table_smash/proc/perform_table_smash(obj/structure/table/table, mob/living/user)
	var/mob/living/pushed_mob = user.pulling
	if (user.combat_mode)
		switch(user.grab_state)
			if (GRAB_PASSIVE)
				to_chat(user, span_warning("You need a better grip to do that!"))
				return
			if (GRAB_AGGRESSIVE)
				if (gentle_push)
					tableplace(user, pushed_mob, table)
				else
					tablepush(user, pushed_mob, table)
			if (GRAB_NECK to GRAB_KILL)
				tablelimbsmash(user, pushed_mob, table)
	else
		pushed_mob.visible_message(span_notice("[user] begins to place [pushed_mob] onto [table]..."), \
							span_userdanger("[user] begins to place [pushed_mob] onto [table]..."))
		if (do_after(user, 3.5 SECONDS, target = pushed_mob))
			tableplace(user, pushed_mob, table)
		else
			return

	user.stop_pulling()

/// Called when someone clicks on our surface with an item
/datum/element/table_smash/proc/on_item_interaction(obj/structure/table/table, mob/living/user, obj/item/item, modifiers)
	SIGNAL_HANDLER
	if (!istype(item, /obj/item/riding_offhand))
		return NONE

	var/obj/item/riding_offhand/riding_item = item
	var/mob/living/carried_mob = riding_item.rider
	if (carried_mob == user) //Piggyback user.
		return NONE

	INVOKE_ASYNC(src, PROC_REF(riding_offhand_act), user, item)
	return ITEM_INTERACT_BLOCKING

/// Called when someone clicks on our surface using a fireman's carry
/datum/element/table_smash/proc/riding_offhand_act(mob/living/user, obj/item/riding_offhand/riding_item, obj/structure/table/table)
	var/mob/living/carried_mob = riding_item.rider
	if (user.combat_mode)
		user.unbuckle_mob(carried_mob)
		tablelimbsmash(user, carried_mob)
		return ITEM_INTERACT_SUCCESS

	var/tableplace_delay = 3.5 SECONDS
	var/skills_space = ""
	if (HAS_TRAIT(user, TRAIT_QUICKER_CARRY))
		tableplace_delay = 2 SECONDS
		skills_space = " expertly"
	else if (HAS_TRAIT(user, TRAIT_QUICK_CARRY))
		tableplace_delay = 2.75 SECONDS
		skills_space = " quickly"

	var/obj/item/organ/cyberimp/chest/spine/potential_spine = user.get_organ_slot(ORGAN_SLOT_SPINE)
	if (istype(potential_spine))
		tableplace_delay *= potential_spine.athletics_boost_multiplier

	carried_mob.visible_message(span_notice("[user] begins to[skills_space] place [carried_mob] onto [table]..."),
		span_userdanger("[user] begins to[skills_space] place [carried_mob] onto [table]..."))
	if (!do_after(user, tableplace_delay, target = carried_mob))
		return ITEM_INTERACT_BLOCKING
	user.unbuckle_mob(carried_mob)
	tableplace(user, carried_mob, table)
	return ITEM_INTERACT_SUCCESS

/// Gently place the mob onto the table
/datum/element/table_smash/proc/tableplace(mob/living/user, mob/living/pushed_mob, obj/structure/table/table)
	pushed_mob.forceMove(table.loc)
	pushed_mob.set_resting(TRUE, TRUE)
	pushed_mob.visible_message(span_notice("[user] places [pushed_mob] onto [table]."), \
		span_notice("[user] places [pushed_mob] onto [table]."))
	log_combat(user, pushed_mob, "placed", null, "onto [table]")

/// Aggressively smash the mob onto the table
/datum/element/table_smash/proc/tablepush(mob/living/user, mob/living/pushed_mob, obj/structure/table/table)
	if (HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_danger("Throwing [pushed_mob] onto the table might hurt them!"))
		return

	var/passtable_key = REF(user)
	passtable_on(pushed_mob, passtable_key)
	for (var/obj/obj in user.loc.contents)
		if (!obj.CanAllowThrough(pushed_mob))
			return

	pushed_mob.Move(table.loc)
	passtable_off(pushed_mob, passtable_key)
	if (pushed_mob.loc != table.loc) //Something prevented the tabling
		return

	pushed_mob.Knockdown(3 SECONDS)
	pushed_mob.apply_damage(10, BRUTE)
	pushed_mob.apply_damage(40, STAMINA)
	playsound(pushed_mob, 'sound/effects/tableslam.ogg', 90, TRUE)
	pushed_mob.visible_message(span_danger("[user] slams [pushed_mob] onto \the [table]!"), \
		span_userdanger("[user] slams you onto \the [table]!"))
	log_combat(user, pushed_mob, "tabled", null, "onto [table]")
	pushed_mob.add_mood_event("table", /datum/mood_event/table)
	SEND_SIGNAL(user, COMSIG_LIVING_TABLE_SLAMMING, pushed_mob, table)
	if(after_smash_proccall)
		call(table, after_smash_proccall)(pushed_mob)

/// Even more aggressively smash a single part of a mob onto the table
/datum/element/table_smash/proc/tablelimbsmash(mob/living/user, mob/living/pushed_mob, obj/structure/table/table)
	pushed_mob.Knockdown(3 SECONDS)
	var/obj/item/bodypart/banged_limb = pushed_mob.get_bodypart(user.zone_selected) || pushed_mob.get_bodypart(BODY_ZONE_HEAD)
	var/extra_wound = 0
	if (HAS_TRAIT(user, TRAIT_HULK))
		extra_wound = 20
	pushed_mob.apply_damage(30, BRUTE, banged_limb, wound_bonus = extra_wound)
	pushed_mob.apply_damage(60, STAMINA)
	playsound(pushed_mob, 'sound/effects/bang.ogg', 90, TRUE)
	pushed_mob.visible_message(span_danger("[user] smashes [pushed_mob]'s [banged_limb.plaintext_zone] against \the [table]!"),
		span_userdanger("[user] smashes your [banged_limb.plaintext_zone] against \the [table]"))
	log_combat(user, pushed_mob, "head slammed", null, "against [table]")
	pushed_mob.add_mood_event("table", /datum/mood_event/table_limbsmash, banged_limb)
	table.take_damage(50)
	SEND_SIGNAL(user, COMSIG_LIVING_TABLE_LIMB_SLAMMING, pushed_mob, table)
	if(after_smash_proccall)
		call(table, after_smash_proccall)(pushed_mob)

/// Called when someone is shoved into our tile
/obj/structure/proc/on_disarm_shoved_into(datum/source, mob/living/shover, mob/living/target, shove_flags, obj/item/weapon)
	SIGNAL_HANDLER
	if((shove_flags & SHOVE_KNOCKDOWN_BLOCKED) || !(shove_flags & SHOVE_BLOCKED))
		return
	target.Knockdown(SHOVE_KNOCKDOWN_TABLE, daze_amount = 3 SECONDS)
	target.visible_message(span_danger("[shover.name] shoves [target.name] onto \the [src]!"),
		span_userdanger("You're shoved onto \the [src] by [shover.name]!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), COMBAT_MESSAGE_RANGE, shover)
	to_chat(shover, span_danger("You shove [target.name] onto \the [src]!"))
	target.throw_at(src, 1, 1, null, FALSE) //1 speed throws with no spin are basically just forcemoves with a hard collision check
	log_combat(shover, target, "shoved", "onto [src] (table)[weapon ? " with [weapon]" : ""]")
	after_smash(target)
	return COMSIG_LIVING_SHOVE_HANDLED

/// Called after someone is harmfully smashed onto us
/obj/structure/proc/after_smash(mob/living/smashed_onto)
	return // This is mostly for our children
