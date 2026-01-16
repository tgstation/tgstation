/datum/component/butchering
	/// Time in deciseconds taken to butcher something
	var/speed = 8 SECONDS
	/// Percentage effectiveness; numbers above 100 yield extra drops
	var/effectiveness = 100
	/// Percentage increase to bonus item chance
	var/bonus_modifier = 0
	/// Sound played when butchering
	var/butcher_sound = 'sound/effects/butcher.ogg'
	/// Whether or not this component can be used to butcher currently. Used to temporarily disable butchering
	var/butchering_enabled = TRUE
	/// Whether or not this component is compatible with blunt tools.
	var/can_be_blunt = FALSE
	/// Callback for butchering
	var/datum/callback/butcher_callback

/datum/component/butchering/Initialize(
	speed = 8 SECONDS,
	effectiveness = 100,
	bonus_modifier = 0,
	butcher_sound = 'sound/effects/butcher.ogg',
	disabled = FALSE,
	can_be_blunt = FALSE,
	butcher_callback,
)
	src.speed = speed
	src.effectiveness = effectiveness
	src.bonus_modifier = bonus_modifier
	src.butcher_sound = butcher_sound
	if (disabled)
		src.butchering_enabled = FALSE
	src.can_be_blunt = can_be_blunt
	src.butcher_callback = butcher_callback

/datum/component/butchering/Destroy(force)
	butcher_callback = null
	return ..()

/datum/component/butchering/RegisterWithParent()
	if (!isitem(parent))
		return
	var/obj/item/item_parent = parent
	item_parent.item_flags |= ITEM_HAS_CONTEXTUAL_SCREENTIPS
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_item_attack))
	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_item_interaction))
	RegisterSignal(parent, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, PROC_REF(add_item_context))

/datum/component/butchering/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK, COMSIG_ITEM_INTERACTING_WITH_ATOM))

/datum/component/butchering/proc/on_item_attack(obj/item/source, mob/living/victim, mob/living/user, list/modifiers)
	SIGNAL_HANDLER

	if (!source.get_sharpness() && !can_be_blunt)
		return

	if (!user.combat_mode)
		return

	// Can we butcher it?
	if (victim.stat == DEAD && (victim.butcher_results || victim.guaranteed_butcher_results) && butchering_enabled)
		INVOKE_ASYNC(src, PROC_REF(start_butcher), source, victim, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (!ishuman(victim) || !source.force)
		return

	if (LAZYACCESS(modifiers, RIGHT_CLICK) && butchering_enabled)
		INVOKE_ASYNC(src, PROC_REF(butcher_human), source, victim, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	// Neckslicing requires aggro grabs
	if (user.pulling != victim || user.grab_state < GRAB_AGGRESSIVE || user.zone_selected != BODY_ZONE_HEAD)
		return

	if (HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You don't want to harm other living beings!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (victim.has_status_effect(/datum/status_effect/neck_slice))
		return

	INVOKE_ASYNC(src, PROC_REF(start_neck_slice), source, victim, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/butchering/proc/on_item_interaction(obj/item/source, mob/living/user, atom/target)
	SIGNAL_HANDLER

	if (!source.get_sharpness() && !can_be_blunt)
		return

	if (!user.combat_mode || !butchering_enabled)
		return

	if (isbodypart(target))
		INVOKE_ASYNC(src, PROC_REF(butcher_limb), source, target, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/butchering/proc/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	SIGNAL_HANDLER

	if (!source.get_sharpness() && !can_be_blunt)
		return NONE

	if (!butchering_enabled)
		return NONE

	if (isbodypart(target))
		context[SCREENTIP_CONTEXT_LMB] = "(Combat Mode) Butcher limb"
		return CONTEXTUAL_SCREENTIP_SET

	if (!isliving(target))
		return NONE

	var/mob/living/victim = target
	if (victim.stat != DEAD && (victim.butcher_results || victim.guaranteed_butcher_results))
		context[SCREENTIP_CONTEXT_LMB] = "(Combat Mode) Butcher"
		return CONTEXTUAL_SCREENTIP_SET

	if (ishuman(victim))
		context[SCREENTIP_CONTEXT_RMB] = "(Combat Mode) Butcher"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/datum/component/butchering/proc/butcher_limb(obj/item/source, obj/item/bodypart/target, mob/living/user)
	target.add_fingerprint(user)
	if (LIMB_HAS_SKIN(target) && !HAS_ANY_SURGERY_STATE(target.surgery_state, SURGERY_SKIN_CUT | SURGERY_SKIN_OPEN))
		to_chat(user, span_warning("[target]'s skin is still intact!"))
		return

	if (LIMB_HAS_BONES(target) && !HAS_ANY_SURGERY_STATE(target.surgery_state, SURGERY_BONE_DRILLED | SURGERY_BONE_SAWED))
		// We need to gut the limb before turning it into meat, otherwise just cut around the bone I guess
		if (length(target.contents))
			to_chat(user, span_warning("[target]'s bones are still intact!"))
			return

	var/speed_modifier = 1
	if (!target.owner)
		speed_modifier = 0.5
	else if (target.owner.stat < UNCONSCIOUS)
		speed_modifier = 1.5 // yeowch

	var/limb_descriptor = (target.owner ? "[target.owner]'s [target.plaintext_zone]" : target)
	// Okay *hopefully* they're already dead at this point
	if (target.body_zone == BODY_ZONE_CHEST && target.owner)
		// Butchering the chest gibs the victim
		limb_descriptor = target.owner

	if (target.owner)
		log_combat(user, target.owner, "attempted to butcher", source)

	if (length(target.contents))
		user.visible_message(span_warning("[user] begins to gut [limb_descriptor]!"), span_notice("You begin to gut [limb_descriptor]..."), ignored_mobs = target.owner)
		if (target.owner)
			to_chat(target.owner, span_warning("[user] begins to gut your [target.plaintext_zone]!"))

		playsound(target.loc, butcher_sound, 50, TRUE, -1)
		if (!do_after(user, speed * speed_modifier, target.owner || target))
			return
		target.drop_organs(user, TRUE)
		return

	if (!length(target.butcher_drops))
		to_chat(user, span_warning("There is nothing left inside [limb_descriptor]!"))
		return

	if (target.body_zone == BODY_ZONE_CHEST && target.owner)
		// Cannot butcher the chest until we hack off all the other limbs
		for (var/obj/item/bodypart/limb as anything in target.owner.bodyparts)
			if (limb != target && limb.butcher_drops && limb.butcher_replacement)
				to_chat(user, span_warning("You need to butcher all other limbs first!"))
				return

	user.visible_message(span_warning("[user] begins to cut [limb_descriptor] apart!"), span_notice("You begin to cut [limb_descriptor] apart..."), ignored_mobs = target.owner)
	if (target.owner)
		to_chat(target.owner, span_warning("[user] begins to cut your [target.plaintext_zone] apart!"))

	playsound(target.loc, butcher_sound, 50, TRUE, -1)
	if (!do_after(user, speed * speed_modifier, target.owner || target))
		return

	var/list/results = list()
	var/turf/drop_loc = target.owner?.drop_location() || target.drop_location()
	var/bonus_chance = max(0, (effectiveness - 100) + bonus_modifier) //so 125 total effectiveness = 25% extra chance

	var/list/failures = list()
	var/list/bonuses = list()

	for (var/obj/item/drop_type as anything in target.butcher_drops)
		var/amount = target.butcher_drops[drop_type] || 1
		var/is_stack = ispath(drop_type, /obj/item/stack)

		for (var/i in 1 to amount)
			if (!prob(effectiveness))
				failures |= drop_type::name
				amount -= 1
				continue

			if (prob(bonus_chance))
				if (!is_stack)
					if (ispath(drop_type, /obj/item/food/meat))
						results += new drop_type(drop_loc, target.blood_dna_info?.Copy())
					else
						var/obj/item/butcher_result = new drop_type(drop_loc)
						if (target.blood_dna_info)
							butcher_result.add_blood_DNA(target.blood_dna_info.Copy())
						results += butcher_result
				amount += 1
				bonuses |= drop_type::name

			if (is_stack)
				continue

			if (ispath(drop_type, /obj/item/food/meat))
				results += new drop_type(drop_loc, target.blood_dna_info?.Copy())
				continue

			var/obj/item/butcher_result = new drop_type(drop_loc)
			butcher_result.add_blood_DNA(target.blood_dna_info.Copy())
			results += butcher_result

		if (is_stack && amount)
			var/obj/item/stack/butcher_result = null
			if (ispath(drop_type, /obj/item/stack/sheet/animalhide/carbon))
				butcher_result = new drop_type(drop_loc, amount, /*merge = */TRUE, /*mat_override = */null, /*mat_amount = */1, target.skin_tone || target.species_color)
			else
				butcher_result = new drop_type(drop_loc, amount)
			if (target.blood_dna_info)
				butcher_result.add_blood_DNA(target.blood_dna_info.Copy())
			results += butcher_result

	if (target.reagents)
		var/meat_produced = 0
		for (var/obj/item/food/target_meat in results)
			meat_produced += 1

		for (var/obj/item/food/target_meat in results)
			target.reagents.trans_to(target_meat, target.reagents.total_volume / meat_produced, remove_blacklisted = TRUE)

	if (target.owner)
		var/reagents_in_produced = 0
		for(var/obj/item/result as anything in results)
			if(result.reagents)
				reagents_in_produced += 1

		var/list/diseases = target.owner.get_static_viruses()

		for(var/obj/item/result as anything in results)
			if (reagents_in_produced)
				if (target.owner.reagents)
					target.owner.reagents.trans_to(result, target.owner.reagents.total_volume / reagents_in_produced / length(target.owner.bodyparts), remove_blacklisted = TRUE)
				result.reagents?.add_reagent(/datum/reagent/consumable/nutriment/fat, target.owner.nutrition / 15 / reagents_in_produced)

			if(LAZYLEN(diseases))
				var/list/datum/disease/diseases_to_add = list()
				for(var/datum/disease/disease as anything in diseases)
					// Admin or special viruses that should not be reproduced
					if(disease.spread_flags & (DISEASE_SPREAD_SPECIAL | DISEASE_SPREAD_NON_CONTAGIOUS))
						continue

					diseases_to_add += disease

				if(LAZYLEN(diseases_to_add))
					result.AddComponent(/datum/component/infective, diseases_to_add)

		for (var/obj/item/food/meat/meat in results)
			meat.name = "[target.owner.real_name]'s [meat.name]"
			meat.set_custom_materials(list(GET_MATERIAL_REF(/datum/material/meat/mob_meat, target.owner) = 4 * SHEET_MATERIAL_AMOUNT))
			meat.subjectname = target.owner.real_name
			meat.subjectjob = target.owner.job

	user.visible_message(span_warning("[user] butchers [limb_descriptor]!"), span_notice("You butcher [limb_descriptor]."), ignored_mobs = target.owner)
	if (!target.owner)
		target.drop_organs(violent_removal = TRUE) // Should not happen, but just in case
		create_replacement_limb(target, drop_loc)
		qdel(target)
		return

	var/wound_type = null
	if (source.damtype == BURN)
		wound_type = WOUND_BURN
	else
		switch (source.get_sharpness())
			if (SHARP_EDGED)
				wound_type = WOUND_SLASH
			if (SHARP_POINTY)
				wound_type = WOUND_PIERCE
			else
				wound_type = WOUND_BLUNT

	to_chat(target.owner, span_userdanger("[user] hacks the meat off your [target.plaintext_zone]!"))
	var/mob/living/carbon/victim = target.owner

	if (!target.butcher_replacement)
		target.dismember(source.damtype, wound_type)
		target.drop_organs(violent_removal = TRUE) // Should not happen, but just in case
		qdel(target)
		return

	var/obj/item/bodypart/replacement = create_replacement_limb(target, drop_loc)
	target.dismember(source.damtype, wound_type)
	target.drop_organs(violent_removal = TRUE)
	replacement.replace_limb(victim)
	replacement.update_limb(is_creating = TRUE)
	qdel(target)

/// Creates a replacement (usually skeleton) limb for the butchered one
/datum/component/butchering/proc/create_replacement_limb(obj/item/bodypart/target, drop_loc)
	var/drop_type = target.butcher_replacement
	var/obj/item/bodypart/replacement = new drop_type(drop_loc)
	replacement.bodyshape = target.bodyshape
	replacement.set_initial_damage(target.brute_dam, target.burn_dam)
	if (IS_ORGANIC_LIMB(replacement) && target.owner)
		replacement.blood_dna_info = target.owner.get_blood_dna_list()

	for (var/datum/wound/wound as anything in target.wounds)
		wound.remove_wound()
		wound.apply_wound(replacement, silent = TRUE)

	return replacement

/datum/component/butchering/proc/start_butcher(obj/item/source, mob/living/target, mob/living/user)
	to_chat(user, span_notice("You begin to butcher [target]..."))
	playsound(target.loc, butcher_sound, 50, TRUE, -1)
	if (do_after(user, speed, target) && target.Adjacent(source))
		on_butchering(user, target)

/datum/component/butchering/proc/butcher_human(obj/item/source, mob/living/carbon/human/victim, mob/living/user)
	if (DOING_INTERACTION_WITH_TARGET(user, victim))
		to_chat(user, span_warning("You're already interacting with [victim]!"))
		return

	var/static/list/butcher_spots = typecacheof(list(
		/obj/structure/table,
		/obj/structure/bed,
		/obj/machinery/stasis,
		/obj/structure/kitchenspike,
	))

	var/found_spot = FALSE
	for (var/obj/thing in victim.loc)
		if (is_type_in_typecache(thing, butcher_spots))
			found_spot = TRUE
			break

	if (!found_spot)
		to_chat(user, span_warning("You need a better spot to butcher [victim]!"))
		return

	var/obj/item/bodypart/limb = victim.get_bodypart(deprecise_zone(user.zone_selected))
	if (!limb)
		to_chat(user, span_warning("[victim] doesn't have a [parse_zone(deprecise_zone(user.zone_selected))]!"))
		return

	butcher_limb(source, limb, user)

/datum/component/butchering/proc/start_neck_slice(obj/item/source, mob/living/carbon/human/victim, mob/living/user)
	if (DOING_INTERACTION_WITH_TARGET(user, victim))
		to_chat(user, span_warning("You're already interacting with [victim]!"))
		return

	user.visible_message(span_danger("[user] is slitting [victim]'s throat!"), \
					span_danger("You start slicing [victim]'s throat!"), \
					span_hear("You hear a cutting noise!"), ignored_mobs = victim)
	victim.show_message(span_userdanger("Your throat is being slit by [user]!"), MSG_VISUAL, \
					span_userdanger("Something is cutting into your neck!"), NONE)
	log_combat(user, victim, "attempted throat slitting", source)

	playsound(victim.loc, butcher_sound, 50, TRUE, -1)
	if (!do_after(user, clamp(500 / source.force, 30, 100), victim) && victim.Adjacent(source))
		return

	if (victim.has_status_effect(/datum/status_effect/neck_slice))
		user.show_message(span_warning("[victim]'s neck has already been already cut, you can't make the bleeding any worse!"), MSG_VISUAL, \
						span_warning("Their neck has already been already cut, you can't make the bleeding any worse!"))
		return

	victim.visible_message(span_danger("[user] slits [victim]'s throat!"), \
				span_userdanger("[user] slits your throat..."))
	log_combat(user, victim, "wounded via throat slitting", source)
	victim.apply_damage(source.force, BRUTE, BODY_ZONE_HEAD, wound_bonus=CANT_WOUND) // easy tiger, we'll get to that in a sec
	var/obj/item/bodypart/slit_throat = victim.get_bodypart(BODY_ZONE_HEAD)
	if (victim.cause_wound_of_type_and_severity(WOUND_SLASH, slit_throat, WOUND_SEVERITY_CRITICAL))
		victim.apply_status_effect(/datum/status_effect/neck_slice)

/**
 * Handles a user butchering a target
 *
 * Arguments:
 * - [butcher][/mob/living]: The mob doing the butchering
 * - [target][/mob/living]: The mob being butchered
 */
/datum/component/butchering/proc/on_butchering(atom/butcher, mob/living/target)
	var/list/results = list()
	var/turf/location = target.drop_location()
	var/final_effectiveness = effectiveness - target.butcher_difficulty
	var/bonus_chance = max(0, (final_effectiveness - 100) + bonus_modifier) //so 125 total effectiveness = 25% extra chance

	if (target.flags_1 & HOLOGRAM_1)
		butcher.visible_message(span_notice("[butcher] tries to butcher [target], but it vanishes."), \
			span_notice("You try to butcher [target], but it vanishes."))
		qdel(target)
		return

	var/list/failures = list()
	var/list/bonuses = list()
	for (var/obj/remains as anything in target.butcher_results)
		var/amount = target.butcher_results[remains] || 1
		var/is_stack = ispath(remains, /obj/item/stack)

		for (var/i in 1 to amount)
			if (!prob(final_effectiveness))
				failures |= remains::name
				amount -= 1
				continue

			if (prob(bonus_chance))
				if (!is_stack)
					results += new remains(location)
				amount += 1
				bonuses |= remains::name

			if (!is_stack)
				results += new remains(location)

		if (is_stack && amount)
			results += new remains(location, amount)

	target.butcher_results?.Cut()

	if (butcher)
		if (length(failures))
			to_chat(butcher, span_warning("You fail to harvest some of the [english_list(failures)] from [target]."))
		if (length(bonuses))
			to_chat(butcher, span_info("You harvest some extra [english_list(bonuses)] from [target]!"))

	for (var/obj/guaranteed_remains as anything in target.guaranteed_butcher_results)
		var/amount = target.guaranteed_butcher_results[guaranteed_remains]
		if (ispath(guaranteed_remains, /obj/item/stack))
			results += new guaranteed_remains(location, amount)
			continue

		for (var/i in 1 to amount)
			results += new guaranteed_remains(location)

	target.guaranteed_butcher_results?.Cut()

	for (var/obj/item/carrion in results)
		var/list/meat_mats = carrion.has_material_type(/datum/material/meat)
		if (!length(meat_mats))
			continue
		carrion.set_custom_materials((carrion.custom_materials - meat_mats) + list(GET_MATERIAL_REF(/datum/material/meat/mob_meat, target) = counterlist_sum(meat_mats)))

	// Transfer delicious reagents to meat
	if (target.reagents)
		var/meat_produced = 0
		for (var/obj/item/food/target_meat in results)
			meat_produced += 1
		for (var/obj/item/food/target_meat in results)
			target.reagents.trans_to(target_meat, target.reagents.total_volume / meat_produced, remove_blacklisted = TRUE)

	// Don't forget yummy diseases either!
	if (iscarbon(target))
		var/mob/living/carbon/host_target = target
		var/list/diseases = host_target.get_static_viruses()
		if (LAZYLEN(diseases))
			var/list/datum/disease/diseases_to_add = list()
			for (var/datum/disease/disease as anything in diseases)
				// admin or special viruses that should not be reproduced
				if (!(disease.spread_flags & (DISEASE_SPREAD_SPECIAL | DISEASE_SPREAD_NON_CONTAGIOUS)))
					diseases_to_add += disease

			if (LAZYLEN(diseases_to_add))
				for (var/obj/diseased_remains in results)
					diseased_remains.AddComponent(/datum/component/infective, diseases_to_add)

	if (butcher)
		butcher.visible_message(span_notice("[butcher] butchers [target]."), \
			span_notice("You butcher [target]."))
	butcher_callback?.Invoke(butcher, target)
	target.harvest(butcher)
	target.log_message("has been butchered by [key_name(butcher)]", LOG_ATTACK)
	target.gib(DROP_BRAIN|DROP_ORGANS)

/// Special snowflake component only used for the recycler.
/datum/component/butchering/recycler

/datum/component/butchering/recycler/Initialize(
	speed,
	effectiveness,
	bonus_modifier,
	butcher_sound,
	disabled,
	can_be_blunt,
	butcher_callback,
)
	if (!istype(parent, /obj/machinery/recycler)) //EWWW
		return COMPONENT_INCOMPATIBLE
	. = ..()
	if (. == COMPONENT_INCOMPATIBLE)
		return

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)

/datum/component/butchering/recycler/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if (!isliving(arrived))
		return
	var/mob/living/victim = arrived
	var/obj/machinery/recycler/eater = parent
	if (eater.safety_mode || (eater.machine_stat & (BROKEN|NOPOWER))) //I'm so sorry.
		return
	if (victim.stat == DEAD && (victim.butcher_results || victim.guaranteed_butcher_results))
		on_butchering(parent, victim)

/datum/component/butchering/mecha

/datum/component/butchering/mecha/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MECHA_EQUIPMENT_ATTACHED, PROC_REF(enable_butchering))
	RegisterSignal(parent, COMSIG_MECHA_EQUIPMENT_DETACHED, PROC_REF(disable_butchering))
	RegisterSignal(parent, COMSIG_MECHA_DRILL_MOB, PROC_REF(on_drill))

/datum/component/butchering/mecha/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_MECHA_DRILL_MOB,
		COMSIG_MECHA_EQUIPMENT_ATTACHED,
		COMSIG_MECHA_EQUIPMENT_DETACHED,
	))

/// Enables the butchering mechanic for the mecha who has equipped us.
/datum/component/butchering/mecha/proc/enable_butchering(datum/source)
	SIGNAL_HANDLER
	butchering_enabled = TRUE

/// Disables the butchering mechanic for the mecha who has dropped us.
/datum/component/butchering/mecha/proc/disable_butchering(datum/source)
	SIGNAL_HANDLER
	butchering_enabled = FALSE

///When we are ready to drill through a mob
/datum/component/butchering/mecha/proc/on_drill(datum/source, obj/vehicle/sealed/mecha/chassis, mob/living/target)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(on_butchering), chassis, target)

/datum/component/butchering/wearable

/datum/component/butchering/wearable/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(worn_enable_butchering))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(worn_disable_butchering))

/datum/component/butchering/wearable/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
	))

/// Same as enable_butchering but for worn items
/datum/component/butchering/wearable/proc/worn_enable_butchering(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	//check if the item is being not worn
	if (!(slot & source.slot_flags))
		return
	butchering_enabled = TRUE
	RegisterSignal(user, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(butcher_target))

/// Same as disable_butchering but for worn items
/datum/component/butchering/wearable/proc/worn_disable_butchering(obj/item/source, mob/user)
	SIGNAL_HANDLER
	butchering_enabled = FALSE
	UnregisterSignal(user, COMSIG_LIVING_UNARMED_ATTACK)

/datum/component/butchering/wearable/proc/butcher_target(mob/user, atom/target, proximity)
	SIGNAL_HANDLER
	if (!isliving(target))
		return NONE
	return on_item_attack(parent, target, user)
