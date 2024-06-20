/datum/mutation/human/tongue_spike
	name = "Tongue Spike"
	desc = "Allows a creature to voluntary shoot their tongue out as a deadly weapon."
	quality = POSITIVE
	text_gain_indication = span_notice("Your feel like you can throw your voice.")
	instability = POSITIVE_INSTABILITY_MINI // worthless. also serves as a bit of a hint that it's not good
	power_path = /datum/action/cooldown/spell/tongue_spike

	energy_coeff = 1
	synchronizer_coeff = 1

/datum/action/cooldown/spell/tongue_spike
	name = "Launch spike"
	desc = "Shoot your tongue out in the direction you're facing, embedding it and dealing damage until they remove it."
	button_icon = 'icons/mob/actions/actions_genetic.dmi'
	button_icon_state = "spike"

	cooldown_time = 1 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN

	/// The type-path to what projectile we spawn to throw at someone.
	var/spike_path = /obj/item/hardened_spike

/datum/action/cooldown/spell/tongue_spike/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/cooldown/spell/tongue_spike/cast(mob/living/carbon/cast_on)
	. = ..()
	if(HAS_TRAIT(cast_on, TRAIT_NODISMEMBER))
		to_chat(cast_on, span_notice("You concentrate really hard, but nothing happens."))
		return

	var/obj/item/organ/internal/tongue/to_fire = locate() in cast_on.organs
	if(!to_fire)
		to_chat(cast_on, span_notice("You don't have a tongue to shoot!"))
		return

	to_fire.Remove(cast_on, special = TRUE)
	var/obj/item/hardened_spike/spike = new spike_path(get_turf(cast_on), cast_on)
	to_fire.forceMove(spike)
	spike.throw_at(get_edge_target_turf(cast_on, cast_on.dir), 14, 4, cast_on)

/obj/item/hardened_spike
	name = "biomass spike"
	desc = "Hardened biomass, shaped into a spike. Very pointy!"
	icon = 'icons/obj/weapons/thrown.dmi'
	icon_state = "tonguespike"
	force = 2
	throwforce = 25
	throw_speed = 4
	embedding = list(
		"impact_pain_mult" = 0,
		"embedded_pain_multiplier" = 15,
		"embed_chance" = 100,
		"embedded_fall_chance" = 0,
		"embedded_ignore_throwspeed_threshold" = TRUE,
	)
	w_class = WEIGHT_CLASS_SMALL
	sharpness = SHARP_POINTY
	custom_materials = list(/datum/material/biomass = SMALL_MATERIAL_AMOUNT * 5)
	/// What mob "fired" our tongue
	var/datum/weakref/fired_by_ref
	/// if we missed our target
	var/missed = TRUE

/obj/item/hardened_spike/Initialize(mapload, mob/living/carbon/source)
	. = ..()
	src.fired_by_ref = WEAKREF(source)
	addtimer(CALLBACK(src, PROC_REF(check_embedded)), 5 SECONDS)

/obj/item/hardened_spike/proc/check_embedded()
	if(missed)
		unembedded()

/obj/item/hardened_spike/embedded(atom/target)
	. = ..()
	if(isbodypart(target))
		missed = FALSE

/obj/item/hardened_spike/unembedded()
	visible_message(span_warning("[src] cracks and twists, changing shape!"))
	for(var/obj/tongue as anything in contents)
		tongue.forceMove(get_turf(src))

	qdel(src)

/datum/mutation/human/tongue_spike/chem
	name = "Chem Spike"
	desc = "Allows a creature to voluntary shoot their tongue out as biomass, allowing a long range transfer of chemicals."
	quality = POSITIVE
	text_gain_indication = span_notice("Your feel like you can really connect with people by throwing your voice.")
	instability = POSITIVE_INSTABILITY_MINOR // slightly less worthless. slightly.
	locked = TRUE
	power_path = /datum/action/cooldown/spell/tongue_spike/chem
	energy_coeff = 1
	synchronizer_coeff = 1

/datum/action/cooldown/spell/tongue_spike/chem
	name = "Launch chem spike"
	desc = "Shoot your tongue out in the direction you're facing, \
		embedding it for a very small amount of damage. \
		While the other person has the spike embedded, \
		you can transfer your chemicals to them."
	button_icon_state = "spikechem"

	spike_path = /obj/item/hardened_spike/chem

/obj/item/hardened_spike/chem
	name = "chem spike"
	desc = "Hardened biomass, shaped into... something."
	icon_state = "tonguespikechem"
	throwforce = 2
	embedding = list(
		"impact_pain_mult" = 0,
		"embedded_pain_multiplier" = 0,
		"embed_chance" = 100,
		"embedded_fall_chance" = 0,
		"embedded_pain_chance" = 0,
		"embedded_ignore_throwspeed_threshold" = TRUE,  //never hurts once it's in you
	)
	/// Whether the tongue's already embedded in a target once before
	var/embedded_once_alread = FALSE

/obj/item/hardened_spike/chem/embedded(mob/living/carbon/human/embedded_mob)
	. = ..()
	if(embedded_once_alread)
		return
	embedded_once_alread = TRUE

	var/mob/living/carbon/fired_by = fired_by_ref?.resolve()
	if(!fired_by)
		return

	var/datum/action/send_chems/chem_action = new(src)
	chem_action.transferred_ref = WEAKREF(embedded_mob)
	chem_action.Grant(fired_by)

	to_chat(fired_by, span_notice("Link established! Use the \"Transfer Chemicals\" ability \
		to send your chemicals to the linked target!"))

/obj/item/hardened_spike/chem/unembedded()
	var/mob/living/carbon/fired_by = fired_by_ref?.resolve()
	if(fired_by)
		to_chat(fired_by, span_warning("Link lost!"))
		var/datum/action/send_chems/chem_action = locate() in fired_by.actions
		QDEL_NULL(chem_action)

	return ..()

/datum/action/send_chems
	name = "Transfer Chemicals"
	desc = "Send all of your reagents into whomever the chem spike is embedded in. One use."
	background_icon_state = "bg_spell"
	button_icon = 'icons/mob/actions/actions_genetic.dmi'
	button_icon_state = "spikechemswap"
	check_flags = AB_CHECK_CONSCIOUS

	/// Weakref to the mob target that we transfer chemicals to on activation
	var/datum/weakref/transferred_ref

/datum/action/send_chems/New(Target)
	. = ..()
	if(!istype(target, /obj/item/hardened_spike/chem))
		qdel(src)

/datum/action/send_chems/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(owner) || !owner.reagents)
		return FALSE
	var/mob/living/carbon/human/transferer = owner
	var/mob/living/carbon/human/transferred = transferred_ref?.resolve()
	if(!ishuman(transferred))
		return FALSE

	to_chat(transferred, span_warning("You feel a tiny prick!"))
	transferer.reagents.trans_to(transferred, transferer.reagents.total_volume, transferred_by = transferer)

	var/obj/item/hardened_spike/chem/chem_spike = target
	var/obj/item/bodypart/spike_location = chem_spike.check_embedded()

	//this is where it would deal damage, if it transfers chems it removes itself so no damage
	chem_spike.forceMove(get_turf(spike_location))
	chem_spike.visible_message(span_notice("[chem_spike] falls out of [spike_location]!"))
	return TRUE
