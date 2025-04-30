/datum/quirk/evil
	name = "Fundamentally Evil"
	desc = "Where you would have a soul is but an ink-black void. While you are committed to maintaining your social standing, \
		anyone who stares too long into your cold, uncaring eyes will know the truth. You are truly evil. There is nothing \
		wrong with you. You chose to be evil, committed to it. Your ambitions come first above all."
	icon = FA_ICON_HAND_MIDDLE_FINGER
	value = 0
	mob_trait = TRAIT_EVIL
	gain_text = span_notice("You shed what little remains of your humanity. You have work to do.")
	lose_text = span_notice("You suddenly care more about others and their needs.")
	medical_record_text = "Patient has passed all our social fitness tests with flying colours, but had trouble on the empathy tests."
	mail_goodies = list(/obj/item/food/grown/citrus/lemon)

/datum/quirk/evil/post_add()
	var/evil_policy = get_policy("[type]") || "Please note that while you may be [LOWER_TEXT(name)], this does NOT give you any additional right to attack people or cause chaos."
	// We shouldn't need this, but it prevents people using it as a dumb excuse in ahelps.
	to_chat(quirk_holder, span_big(span_info(evil_policy)))
	RegisterSignal(quirk_holder, COMSIG_LIVING_CHANGED_BLOOD_TYPE, PROC_REF(make_blood_evil))

/datum/quirk/evil/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(!istype(human_holder))
		return
	make_blood_evil(human_quirk_holder = human_holder, new_blood_type = human_holder.dna.blood_type)

/datum/quirk/evil/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_LIVING_CHANGED_BLOOD_TYPE))

/// Get a dynamically generated blood type based off the mob's old blood type and make it 'evil'. Needs to happen whenever the blood type changes.
/datum/quirk/evil/proc/make_blood_evil(mob/living/carbon/human/human_quirk_holder, datum/blood_type/new_blood_type, update_cached_blood_dna_info)
	SIGNAL_HANDLER

	// Try to find a corresponding evil blood type for this
	var/datum/blood_type/evil_blood_type
	evil_blood_type = get_blood_type("[new_blood_type.id]_but_evil")
	if(isnull(evil_blood_type)) // this blood type doesn't exist yet in the global list, so make a new one
		evil_blood_type = new /datum/blood_type/evil(new_blood_type, new_blood_type.compatible_types)
		GLOB.blood_types[evil_blood_type.id] = evil_blood_type
	human_quirk_holder.set_blood_type(evil_blood_type)

	if(human_quirk_holder.dna.species.exotic_bloodtype)
		human_quirk_holder.dna.species.exotic_bloodtype = evil_blood_type
