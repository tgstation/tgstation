/obj/item/disk/surgery/advanced_plastic_surgery
	name = "Advanced Plastic Surgery Disk"
	desc = "The disk provides instructions on how to do an Advanced Plastic Surgery, this surgery allows one-self to completely remake someone's face with that of another. Provided they have a picture of them in their offhand when reshaping the face. With the surgery long becoming obsolete with the rise of genetics technology. This item became an antique to many collectors, With only the cheaper and easier basic form of plastic surgery remaining in use in most places."
	// surgeries = list(/datum/surgery/plastic_surgery/advanced)

/datum/surgery_operation/plastic_surgery
	name = "plastic surgery"
	desc = "Reshape or reconstruct a patient's body part for cosmetic or functional purposes."
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/knife = 0.50,
		TOOL_WIRECUTTER = 0.35,
	)
	time = 6.4 SECONDS
	operation_flags = OPERATION_MORBID | OPERATION_AFFECTS_MOOD
	preop_sound = 'sound/effects/blob/blobattack.ogg'
	success_sound = 'sound/effects/blob/attackblob.ogg'
	failure_sound = 'sound/effects/blob/blobattack.ogg'

/datum/surgery_operation/plastic_surgery/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	return TRUE

/datum/surgery_operation/plastic_surgery/is_available(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_HEAD

/datum/surgery_operation/plastic_surgery/get_radial_options(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool)
	var/list/options = ..()

	if(surgeon.is_holding_item_of_type(/obj/item/stack/sheet/plastic)) // melbert todo : tech check
		var/datum/radial_menu_choice/advanced = new()
		advanced.image = get_default_radial_image(limb, surgeon, tool)
		advanced.name = "advanced [name]"
		advanced.info = desc + " By supplying plastic and a reference image, greater control over the results can be achieved."
		options[advanced] = list("action" = "default", "advanced" = TRUE)

	return options

/datum/surgery_operation/plastic_surgery/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to alter [limb.owner]'s appearance..."),
		span_notice("[surgeon] begins to alter [limb.owner]'s appearance."),
		span_notice("[surgeon] begins to make an incision in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a slicing pain across your face!")

/datum/surgery_operation/plastic_surgery/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
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

	var/list/names = list()
	if(isabductor(surgeon))
		for(var/j in 1 to 9)
			names += "Subject [limb.owner.gender == MALE ? "i" : "o"]-[pick("a", "b", "c", "d", "e")]-[rand(10000, 99999)]"
		names += limb.owner.generate_random_mob_name(TRUE) //give one normal name in case they want to do regular plastic surgery

	else
		var/obj/item/offhand = surgeon.get_inactive_held_item()
		if(istype(offhand, /obj/item/photo) && operation_args["advanced"])
			var/obj/item/photo/disguises = offhand
			for(var/namelist in disguises.picture?.names_seen)
				names += namelist
		else
			if(operation_args["advanced"])
				to_chat(surgeon, span_warning("You have no picture to base the appearance on!"))
			for(var/i in 1 to 10)
				names += limb.owner.generate_random_mob_name(TRUE)

	var/mob/changed = limb.owner
	var/chosen_name = tgui_input_list(surgeon, "New name to assign", "Plastic Surgery", names)
	if(isnull(chosen_name) || limb.owner != changed || !surgeon.Adjacent(changed))
		return

	var/oldname = limb.owner.real_name
	limb.owner.real_name = chosen_name
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

/datum/surgery_operation/plastic_surgery/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, total_penalty_modifier)
	display_results(
		surgeon,
		limb.owner,
		span_warning("Your screw up, leaving [limb.owner]'s appearance disfigured!"),
		span_warning("[surgeon] screws up, disfiguring [limb.owner]'s appearance!"),
		span_notice("[surgeon] finishes the operation on [limb.owner]'s face."),
	)
	display_pain(limb.owner, "Your face feels horribly scarred and deformed!")
	ADD_TRAIT(limb.owner, TRAIT_DISFIGURED, TRAIT_GENERIC)
