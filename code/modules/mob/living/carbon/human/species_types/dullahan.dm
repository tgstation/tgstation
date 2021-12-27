/datum/species/dullahan
	name = "Dullahan"
	id = SPECIES_DULLAHAN
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS, HAS_FLESH, HAS_BONE)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_NOHUNGER,
		TRAIT_NOBREATH,
	)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutant_bodyparts = list("wings" = "None")
	use_skintones = TRUE
	mutantbrain = /obj/item/organ/brain/dullahan
	mutanteyes = /obj/item/organ/eyes/dullahan
	mutanttongue = /obj/item/organ/tongue/dullahan
	mutantears = /obj/item/organ/ears/dullahan
	limbs_id = "human"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN

	var/obj/item/dullahan_relay/my_head


/datum/species/dullahan/check_roundstart_eligible()
	return TRUE // DEBUG-ONLY!
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/dullahan/on_species_gain(mob/living/carbon/human/human, datum/species/old_species)
	. = ..()
	human.lose_hearing_sensitivity(TRAIT_GENERIC)
	var/obj/item/bodypart/head/head = human.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.no_update = TRUE
		head.drop_limb()
		if(!QDELETED(head)) //drop_limb() deletes the limb if no drop location exists and character setup dummies are located in nullspace.
			head.throwforce = 25
			my_head = new /obj/item/dullahan_relay(head, human)
			human.put_in_hands(head)
			// We already know that we're a dullahan at this point.
			var/datum/species/dullahan/head_species = human.dna.species
			head_species.update_vision_perspective(human)
			// var/obj/item/organ/eyes/E = human.getorganslot(ORGAN_SLOT_EYES)
			// var/datum/action/item_action/organ_action/dullahan/D = locate() in E?.actions
			// D?.Trigger()
	human.set_safe_hunger_level()

/datum/species/dullahan/on_species_loss(mob/living/carbon/human/human)
	human.become_hearing_sensitive()
	human.reset_perspective(human)
	if(my_head)
		QDEL_NULL(my_head)
	human.regenerate_limb(BODY_ZONE_HEAD,FALSE)
	..()

/datum/species/dullahan/spec_life(mob/living/carbon/human/human, delta_time, times_fired)
	if(QDELETED(my_head))
		my_head = null
		human.gib()

	if(istype(my_head.loc, /obj/item/bodypart/head) && my_head.loc.name != human.real_name)
		my_head.loc.name = human.real_name

	var/obj/item/bodypart/head/head2 = human.get_bodypart(BODY_ZONE_HEAD)
	if(head2)
		my_head = null
		human.gib()

/datum/species/dullahan/proc/update_vision_perspective(mob/living/carbon/human/human)
	var/obj/item/organ/eyes/eyes = human.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		human.update_tint()
		if(eyes.tint)
			human.reset_perspective(human)
		else
			human.reset_perspective(my_head)

/obj/item/organ/brain/dullahan
	decoy_override = TRUE
	organ_flags = 0

/obj/item/organ/tongue/dullahan
	zone = "abstract"
	modifies_speech = TRUE

/obj/item/organ/tongue/dullahan/handle_speech(datum/source, list/speech_args)
	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
		if(isdullahan(human))
			var/datum/species/dullahan/dullahan_species = human.dna.species
			if(isobj(dullahan_species.my_head.loc))
				var/obj/head = dullahan_species.my_head.loc
				head.say(speech_args[SPEECH_MESSAGE])
	speech_args[SPEECH_MESSAGE] = ""

/obj/item/organ/ears/dullahan
	zone = "abstract"

/obj/item/organ/eyes/dullahan
	name = "head vision"
	desc = "An abstraction."
	actions_types = list(/datum/action/item_action/organ_action/dullahan)
	zone = "abstract"
	tint = INFINITY // to switch the vision perspective to the head on species_gain() without issue.

/datum/action/item_action/organ_action/dullahan
	name = "Toggle Perspective"
	desc = "Switch between seeing normally from your head, or blindly from your body."

/datum/action/item_action/organ_action/dullahan/Trigger()
	. = ..()
	var/obj/item/organ/eyes/dullahan/dullahan_eyes = target
	dullahan_eyes.tint = dullahan_eyes.tint ? NONE : INFINITY

	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
		if(isdullahan(human))
			var/datum/species/dullahan/dullahan_species = human.dna.species
			dullahan_species.update_vision_perspective(human)

/obj/item/dullahan_relay
	name = "dullahan relay"
	var/mob/living/owner

/obj/item/dullahan_relay/Initialize(mapload, mob/living/carbon/human/new_owner)
	. = ..()
	if(!new_owner)
		return INITIALIZE_HINT_QDEL
	owner = new_owner
	START_PROCESSING(SSobj, src)
	RegisterSignal(owner, COMSIG_CLICK_SHIFT, .proc/examinate_check)
	RegisterSignal(owner, COMSIG_LIVING_REGENERATE_LIMBS, .proc/unlist_head)
	RegisterSignal(owner, COMSIG_LIVING_REVIVE, .proc/retrieve_head)
	become_hearing_sensitive(ROUNDSTART_TRAIT)

/obj/item/dullahan_relay/Destroy()
	owner = null
	return ..()


/obj/item/dullahan_relay/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	owner.Hear(arglist(args))

/obj/item/dullahan_relay/process()
	if(!istype(loc, /obj/item/bodypart/head) || QDELETED(owner))
		. = PROCESS_KILL
		qdel(src)

/obj/item/dullahan_relay/proc/examinate_check(atom/source, mob/user)
	SIGNAL_HANDLER
	if(user.client.eye == src)
		return COMPONENT_ALLOW_EXAMINATE

/obj/item/dullahan_relay/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods)
	. = ..()
	if(owner)
		owner.Hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mods)

///Adds the owner to the list of hearers in hearers_in_view(), for visible/hearable on top of say messages
/obj/item/dullahan_relay/proc/include_owner(datum/source, list/hearers)
	SIGNAL_HANDLER
	if(!QDELETED(owner))
		hearers += owner

///Stops dullahans from gibbing when regenerating limbs
/obj/item/dullahan_relay/proc/unlist_head(datum/source, noheal = FALSE, list/excluded_zones)
	SIGNAL_HANDLER
	excluded_zones |= BODY_ZONE_HEAD

///Retrieving the owner's head for better ahealing.
/obj/item/dullahan_relay/proc/retrieve_head(datum/source, full_heal, admin_revive)
	SIGNAL_HANDLER
	if(admin_revive)
		var/obj/item/bodypart/head/head = loc
		var/turf/body_turf = get_turf(owner)
		if(head && istype(head) && body_turf && !(head in owner.get_all_contents()))
			head.forceMove(body_turf)

/obj/item/dullahan_relay/Destroy()
	if(!QDELETED(owner))
		var/mob/living/carbon/human/human = owner
		if(isdullahan(human))
			var/datum/species/dullahan/dullahan_species = human.dna.species
			dullahan_species.my_head = null
			owner.gib()
	owner = null
	return ..()
