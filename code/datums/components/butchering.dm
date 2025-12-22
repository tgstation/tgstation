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
	if (isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_item_attack))

/datum/component/butchering/Destroy(force)
	butcher_callback = null
	return ..()

/datum/component/butchering/proc/on_item_attack(obj/item/source, atom/target, mob/living/user)
	SIGNAL_HANDLER

	if (!source.get_sharpness() && !can_be_blunt)
		return

	if (isbodypart(target))
		INVOKE_ASYNC(src, PROC_REF(butcher_limb), source, target, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (!isliving(target) || !user.combat_mode)
		return

	var/mob/living/victim = target
	// Can we butcher it?
	if (victim.stat == DEAD && (victim.butcher_results || victim.guaranteed_butcher_results))
		if (butchering_enabled)
			INVOKE_ASYNC(src, PROC_REF(start_butcher), source, victim, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

	if (!ishuman(victim) || !source.force)
		return

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

/datum/component/butchering/proc/butcher_limb(obj/item/source, obj/item/bodypart/target, mob/living/user)
	target.add_fingerprint(user)

	if (LIMB_HAS_SKIN(target) && !HAS_SURGERY_STATE(target.surgery_state, SURGERY_SKIN_CUT))
		to_chat(user, span_warning("[src]'s skin is still intact!"))
		return

	if (LIMB_HAS_BONES(target) && !HAS_SURGERY_STATE(target.surgery_state, SURGERY_BONE_DRILLED | SURGERY_BONE_SAWED))
		// We need to gut the limb before turning it into meat, otherwise just cut around the bone I guess
		if (length(target.contents))
			to_chat(user, span_warning("[src]'s bones are still intact!"))
			return

	if (length(target.contents))
		user.visible_message(span_warning("[user] begins to gut [target]."), span_notice("You begin to gut [target]..."))
		playsound(target.loc, butcher_sound, 50, TRUE, -1)
		if (!do_after(user, speed * 0.5, target))
			return
		target.drop_organs(user, TRUE)
		return

	if (!length(target.butcher_drops))
		to_chat(user, span_warning("There is nothing left inside [target]!"))
		return

	user.visible_message(span_warning("[user] begins to cut [target] apart."), span_notice("You begin to cut [target] apart..."))
	playsound(target.loc, butcher_sound, 50, TRUE, -1)
	if (!do_after(user, speed * 0.5, target))
		return

	var/list/results = list()
	var/turf/drop_loc = target.drop_location()
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
			var/obj/item/stack/butcher_result = new drop_type(drop_loc, amount)
			if (target.blood_dna_info)
				butcher_result.add_blood_DNA(target.blood_dna_info.Copy())
			results += butcher_result

	if (target.reagents)
		var/meat_produced = 0
		for (var/obj/item/food/target_meat in results)
			meat_produced += 1
		for (var/obj/item/food/target_meat in results)
			target.reagents.trans_to(target_meat, target.reagents.total_volume / meat_produced, remove_blacklisted = TRUE)

	user.visible_message(span_notice("[user] butchers [target]."), span_notice("You butcher [target]."))
	qdel(target)

/datum/component/butchering/proc/start_butcher(obj/item/source, mob/living/target, mob/living/user)
	to_chat(user, span_notice("You begin to butcher [target]..."))
	playsound(target.loc, butcher_sound, 50, TRUE, -1)
	if (do_after(user, speed, target) && target.Adjacent(source))
		on_butchering(user, target)

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

	target.butcher_results.Cut()

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

	target.guaranteed_butcher_results.Cut()

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
