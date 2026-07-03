/datum/mutation/tongue_spike
	name = "Tongue Spike"
	desc = "Позволяет существу добровольно выстрелить своим языком, как смертельным оружием."
	quality = POSITIVE
	text_gain_indication = span_notice("Ты чувствуешь, что можешь выкинуть свой голос.")
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

	var/obj/item/organ/tongue/to_fire = locate() in cast_on.organs
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
	icon_angle = 45
	force = 2
	throwforce = 25
	throw_speed = 4
	embed_type = /datum/embedding/tongue_spike
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
	addtimer(CALLBACK(src, PROC_REF(check_morph)), 5 SECONDS)

/obj/item/hardened_spike/proc/check_morph()
	// Failed to embed, morph back
	if (!embed_data?.owner)
		morph_back()

/obj/item/hardened_spike/proc/morph_back()
	visible_message(span_warning("[src] cracks and twists, changing shape!"))
	for(var/obj/tongue as anything in contents)
		tongue.forceMove(get_turf(src))
	qdel(src)

/datum/embedding/tongue_spike
	impact_pain_mult = 0
	pain_mult = 15
	embed_chance = 100
	fall_chance = 0
	ignore_throwspeed_threshold = TRUE

/datum/embedding/tongue_spike/stop_embedding()
	. = ..()
	var/obj/item/hardened_spike/tongue_spike = parent
	if (!QDELETED(tongue_spike)) // This can cause a qdel loop
		tongue_spike.morph_back()

/datum/mutation/tongue_spike/chem
	name = "Chem Spike"
	desc = "Позволяет существу добровольно выстрелить своим языком из биомассы, позволяет передавать химические вещества на большое расстояние."
	quality = POSITIVE
	text_gain_indication = span_notice("Ты чувствуешь, что можешь соединиться с людьми бросив свой голос.")
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
	embed_type = /datum/embedding/tongue_spike/chem

/datum/embedding/tongue_spike/chem
	pain_mult = 0
	pain_chance = 0

/datum/embedding/tongue_spike/chem/on_successful_embed(mob/living/carbon/victim, obj/item/bodypart/target_limb)
	var/obj/item/hardened_spike/chem/tongue_spike = parent
	var/mob/living/carbon/fired_by = tongue_spike.fired_by_ref?.resolve()
	if(!istype(fired_by))
		return

	var/datum/action/send_chems/chem_action = new(tongue_spike)
	chem_action.transferred_ref = WEAKREF(victim)
	chem_action.Grant(fired_by)

	to_chat(fired_by, span_notice("Link established! Use the \"Transfer Chemicals\" ability \
		to send your chemicals to the linked target!"))

/datum/embedding/tongue_spike/chem/stop_embedding()
	. = ..()
	var/obj/item/hardened_spike/chem/tongue_spike = parent
	var/mob/living/carbon/fired_by = tongue_spike.fired_by_ref?.resolve()
	if(!istype(fired_by))
		return

	to_chat(fired_by, span_warning("Link lost!"))
	var/datum/action/send_chems/chem_action = locate() in fired_by.actions
	qdel(chem_action)

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

/datum/action/send_chems/Trigger(mob/clicker, trigger_flags)
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

	// This is where it would deal damage, if it transfers chems it removes itself so no damage
	var/mob/living/carbon/spike_owner = chem_spike.get_embed()?.owner
	// Message first because it'll shift back into a tongue right after moving
	if (istype(spike_owner))
		spike_owner.visible_message(span_notice("[chem_spike] falls out of [spike_owner]!"))
	chem_spike.forceMove(get_turf(chem_spike))
	return TRUE
