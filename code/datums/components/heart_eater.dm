/datum/component/heart_eater
	/// Check if we fully ate whole heart and reset when we start eat new one.
	var/bites_taken = 0
	/// Remember the number of species damage_modifier.
	var/remember_modifier = 0
	/// Remember last heart we ate and reset bites_taken counter if we start eat new one
	var/datum/weakref/last_heart_we_ate
	/// List of all mutations allowed to get.
	var/static/list/datum/mutation/mutations_list = list(
		/datum/mutation/adaptation/cold,
		/datum/mutation/adaptation/heat,
		/datum/mutation/adaptation/pressure,
		/datum/mutation/adaptation/thermal,
		/datum/mutation/chameleon,
		/datum/mutation/cryokinesis,
		/datum/mutation/pyrokinesis,
		/datum/mutation/dwarfism,
		/datum/mutation/cindikinesis,
		/datum/mutation/insulated,
		/datum/mutation/telekinesis,
		/datum/mutation/telepathy,
		/datum/mutation/thermal,
		/datum/mutation/tongue_spike,
		/datum/mutation/webbing,
		/datum/mutation/xray,
	)

/datum/component/heart_eater/Initialize(...)
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	prepare_species(parent)

/datum/component/heart_eater/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_SPECIES_GAIN, PROC_REF(on_species_change))
	RegisterSignal(parent, COMSIG_LIVING_FINISH_EAT, PROC_REF(eat_eat_eat))
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(try_rip_heart))

/datum/component/heart_eater/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_LIVING_FINISH_EAT)
	UnregisterSignal(parent, COMSIG_SPECIES_GAIN)
	UnregisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK)

/datum/component/heart_eater/proc/prepare_species(mob/living/carbon/human/eater)
	if(eater.get_liked_foodtypes() & GORE)
		return
	var/obj/item/organ/tongue/eater_tongue = eater.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!eater_tongue)
		return
	eater_tongue.disliked_foodtypes &= ~GORE
	eater_tongue.liked_foodtypes |= GORE

/datum/component/heart_eater/proc/on_species_change(mob/living/carbon/human/eater, datum/species/new_species, datum/species/old_species, pref_load, regenerate_icons)
	SIGNAL_HANDLER

	eater.dna?.species?.damage_modifier += remember_modifier
	prepare_species(eater)

/// Proc called when we finish eat somthing.
/datum/component/heart_eater/proc/eat_eat_eat(mob/living/carbon/human/eater, datum/what_we_ate)
	SIGNAL_HANDLER

	if(get_area(eater) == GLOB.areas_by_type[/area/centcom/wizard_station])
		return
	if(!istype(what_we_ate, /obj/item/organ/heart))
		return
	var/obj/item/organ/heart/we_ate_heart = what_we_ate
	var/obj/item/organ/heart/previous_heart = last_heart_we_ate?.resolve()
	if(we_ate_heart == previous_heart)
		return
	if (!HAS_TRAIT(we_ate_heart, TRAIT_USED_ORGAN))
		to_chat(eater, span_warning("This heart is utterly lifeless, you won't receive any boons from consuming it!"))
		return
	bites_taken = 0

	last_heart_we_ate = WEAKREF(we_ate_heart)
	bites_taken++
	if(bites_taken < (we_ate_heart.reagents.total_volume/2))
		return
	if(prob(50))
		perfect_heart(eater)
		return
	not_perfect_heart(eater)

///Perfect heart give our +10 damage modifier(Max. 80).
/datum/component/heart_eater/proc/perfect_heart(mob/living/carbon/human/eater)
	if(eater.dna?.species?.damage_modifier >= 80)
		healing_heart(eater)
		return
	eater.dna?.species?.damage_modifier += 10
	remember_modifier += 10
	healing_heart(eater)
	to_chat(eater, span_warning("This heart is perfect. You feel a surge of vital energy."))

///Not Perfect heart give random mutation.
/datum/component/heart_eater/proc/not_perfect_heart(mob/living/carbon/human/eater)
	var/datum/mutation/new_mutation
	var/list/datum/mutation/shuffle_mutation_list = shuffle(mutations_list)
	for(var/mutation_in_list in shuffle_mutation_list)
		if(is_type_in_list(mutation_in_list, eater.dna.mutations))
			continue
		new_mutation = mutation_in_list
		break
	if(isnull(new_mutation))
		healing_heart(eater)
		return
	eater.dna.add_mutation(new_mutation, MUTATION_SOURCE_HEART_EATER)
	healing_heart(eater)
	to_chat(eater, span_warning("This heart is not right for you. You now have [new_mutation.name] mutation."))

///Heart eater give also strong healing from hearts.
/datum/component/heart_eater/proc/healing_heart(mob/living/carbon/human/eater)
	for(var/heal_organ in eater.organs)
		eater.adjust_organ_loss(heal_organ, -50)
	for(var/datum/wound/heal_wound in eater.all_wounds)
		heal_wound.remove_wound()
	eater.adjust_brute_loss(-50)
	eater.adjust_fire_loss(-50)
	eater.adjust_tox_loss(-50)
	eater.adjust_oxy_loss(-50)
	eater.adjust_stamina_loss(-50)

/datum/component/heart_eater/proc/try_rip_heart(mob/living/source, mob/living/carbon/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(!istype(target))
		return
	if(!IS_DEAD_OR_INCAP(target))
		return
	if(!source.combat_mode)
		return
	if(source.zone_selected != BODY_ZONE_CHEST)
		return
	var/obj/item/bodypart/chest = target.get_bodypart(BODY_ZONE_CHEST)
	if(chest.get_wound_type(/datum/wound/blunt/bone/critical) && !target.get_organ_slot(ORGAN_SLOT_HEART)) //Don't bother trying to rip a heart out of someone we can see doesn't have one.
		target.balloon_alert(source, "no heart!")
		return
	INVOKE_ASYNC(src, PROC_REF(do_rip_heart), source, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/heart_eater/proc/can_rip_heart(mob/living/user, mob/living/carbon/target, hand_index)
	if(!IS_DEAD_OR_INCAP(target))
		return FALSE
	if(!user.has_hand_for_held_index(hand_index))
		return FALSE
	if(user.get_item_for_held_index(hand_index))
		return FALSE
	return TRUE

/datum/component/heart_eater/proc/do_rip_heart(mob/living/user, mob/living/carbon/target)
	playsound(target, 'sound/items/weapons/slice.ogg', 50, TRUE)
	var/hand_index = user.active_hand_index
	if(!do_after(
		user,
		3 SECONDS,
		target,
		timed_action_flags = IGNORE_HELD_ITEM,
		extra_checks = CALLBACK(src, PROC_REF(can_rip_heart), user, target, hand_index),
		interaction_key = "[DOAFTER_SOURCE_RIP_HEART]_[hand_index]",
		max_interact_count = 1,
		))
		user.balloon_alert(user, "interrupted!")
		return
	var/obj/item/bodypart/chest = target.get_bodypart(BODY_ZONE_CHEST)
	chest.force_wound_upwards(/datum/wound/blunt/bone/critical, wound_source = "heart ripped")
	var/obj/item/organ/heart = target.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart)
		target.balloon_alert(user, "no heart!?")
		return
	heart.Remove(target)
	to_chat(user, span_warning("You rip [target]'s [heart.name] out of [target.p_their()] chest!"))
	target.visible_message(
		span_warning("[user] rips [target]'s [heart.name] out of [target.p_their()] chest!"),
		span_userdanger("[user] rips your [heart.name] out of your chest!"),
		span_userdanger("You feel something being torn out of your chest!"),
		ignored_mobs = list(user),
		)
	if(!user.put_in_hand(heart, hand_index))
		heart.forceMove(user.drop_location())
