#define OPERATION_NEW_NAME "chosen_name"

/datum/surgery_operation/limb/plastic_surgery
	name = "plastic surgery"
	desc = "Reshape or reconstruct a patient's face for cosmetic or functional purposes."
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/knife = 2,
		TOOL_WIRECUTTER = 2.85,
		/obj/item/pen = 5,
	)
	time = 6.4 SECONDS
	operation_flags = OPERATION_MORBID | OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN

/datum/surgery_operation/limb/plastic_surgery/all_required_strings()
	return list("operate on head (target head)") + ..()

/datum/surgery_operation/limb/plastic_surgery/get_default_radial_image()
	return image(/obj/item/scalpel)

/datum/surgery_operation/limb/plastic_surgery/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_HEAD

/datum/surgery_operation/limb/plastic_surgery/pre_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(HAS_TRAIT_FROM(limb.owner, TRAIT_DISFIGURED, TRAIT_GENERIC))
		return TRUE //skip name selection if fixing disfigurement

	var/list/names = list()
	if(isabductor(surgeon))
		for(var/j in 1 to 9)
			names += "Subject [limb.owner.gender == MALE ? "i" : "o"]-[pick("a", "b", "c", "d", "e")]-[rand(10000, 99999)]"
		names += limb.owner.generate_random_mob_name(TRUE) //give one normal name in case they want to do regular plastic surgery

	else
		var/advanced = LIMB_HAS_SURGERY_STATE(limb, SURGERY_PLASTIC_APPLIED)
		var/obj/item/offhand = surgeon.get_inactive_held_item()
		if(istype(offhand, /obj/item/photo) && advanced)
			var/obj/item/photo/disguises = offhand
			for(var/namelist in disguises.picture?.names_seen)
				names += namelist
		else
			if(advanced)
				to_chat(surgeon, span_warning("You have no picture to base the appearance on!"))
			for(var/i in 1 to 10)
				names += limb.owner.generate_random_mob_name(TRUE)

	operation_args[OPERATION_NEW_NAME] = tgui_input_list(surgeon, "New name to assign", "Plastic Surgery", names)
	return !!operation_args[OPERATION_NEW_NAME]

/datum/surgery_operation/limb/plastic_surgery/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to alter [limb.owner]'s appearance..."),
		span_notice("[surgeon] begins to alter [limb.owner]'s appearance."),
		span_notice("[surgeon] begins to make an incision in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a slicing pain across your face!")

/datum/surgery_operation/limb/plastic_surgery/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(HAS_TRAIT_FROM(limb.owner, TRAIT_DISFIGURED, TRAIT_GENERIC))
		REMOVE_TRAIT(limb.owner, TRAIT_DISFIGURED, TRAIT_GENERIC)
		display_results(
			surgeon,
			limb.owner,
			span_notice("You successfully restore [limb.owner]'s appearance."),
			span_notice("[surgeon] successfully restores [limb.owner]'s appearance!"),
			span_notice("[surgeon] finishes the operation on [limb.owner]'s face."),
		)
		display_pain(limb.owner, "The pain fades, your face feels normal again!")
		return

	var/oldname = limb.owner.real_name
	limb.owner.real_name = operation_args[OPERATION_NEW_NAME]
	var/newname = limb.owner.real_name //something about how the code handles names required that I use this instead of target.real_name
	display_results(
		surgeon,
		limb.owner,
		span_notice("You alter [oldname]'s appearance completely, [limb.owner.p_they()] is now [newname]."),
		span_notice("[surgeon] alters [oldname]'s appearance completely, [limb.owner.p_they()] is now [newname]!"),
		span_notice("[surgeon] finishes the operation on [limb.owner]'s face."),
	)
	display_pain(limb.owner, "The pain fades, your face feels new and unfamiliar!")
	if(ishuman(limb.owner))
		var/mob/living/carbon/human/human_target = limb.owner
		human_target.update_ID_card()
	if(HAS_MIND_TRAIT(surgeon, TRAIT_MORBID))
		surgeon.add_mood_event("morbid_abominable_surgery_success", /datum/mood_event/morbid_abominable_surgery_success)
	limb.remove_surgical_state(SURGERY_PLASTIC_APPLIED)

/datum/surgery_operation/limb/plastic_surgery/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("Your screw up, leaving [limb.owner]'s appearance disfigured!"),
		span_warning("[surgeon] screws up, disfiguring [limb.owner]'s appearance!"),
		span_notice("[surgeon] finishes the operation on [limb.owner]'s face."),
	)
	display_pain(limb.owner, "Your face feels horribly scarred and deformed!")
	ADD_TRAIT(limb.owner, TRAIT_DISFIGURED, TRAIT_GENERIC)

#undef OPERATION_NEW_NAME

/datum/surgery_operation/limb/add_plastic
	name = "apply plastic"
	desc = "Apply plastic to a patient's face to to allow for greater customization in following plastic surgery."
	implements = list(
		/obj/item/stack/sheet/plastic = 1,
	)
	time = 4.8 SECONDS
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED
	preop_sound = 'sound/effects/blob/blobattack.ogg'
	success_sound = 'sound/effects/blob/attackblob.ogg'
	failure_sound = 'sound/effects/blob/blobattack.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_PLASTIC_APPLIED

/datum/surgery_operation/limb/add_plastic/get_default_radial_image()
	return image(/obj/item/stack/sheet/plastic)

/datum/surgery_operation/limb/add_plastic/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_HEAD

/datum/surgery_operation/limb/add_plastic/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to apply plastic to [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to apply plastic to [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to perform surgery on [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a strange sensation as something is applied to your face!")

/datum/surgery_operation/limb/add_plastic/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_PLASTIC_APPLIED)
