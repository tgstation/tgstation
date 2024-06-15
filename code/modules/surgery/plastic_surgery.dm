/// Disk containing info for doing advanced plastic surgery. Spawns in maint and available as a role-restricted item in traitor uplinks.
/obj/item/disk/surgery/advanced_plastic_surgery
	name = "Advanced Plastic Surgery Disk"
	desc = "The disk provides instructions on how to do an Advanced Plastic Surgery, this surgery allows one-self to completely remake someone's face with that of another. Provided they have a picture of them in their offhand when reshaping the face. With the surgery long becoming obsolete with the rise of genetics technology. This item became an antique to many collectors, With only the cheaper and easier basic form of plastic surgery remaining in use in most places."
	surgeries = list(/datum/surgery/plastic_surgery/advanced)

/datum/surgery/plastic_surgery
	name = "Plastic surgery"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB | SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/reshape_face,
		/datum/surgery_step/close,
	)

/datum/surgery/plastic_surgery/advanced
	name = "Advanced plastic surgery"
	desc =  "Surgery allows one-self to completely remake someone's face with that of another. Provided they have a picture of them in their offhand when reshaping the face."
	requires_tech = TRUE
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/insert_plastic,
		/datum/surgery_step/reshape_face,
		/datum/surgery_step/close,
	)

//Insert plastic step, It ain't called plastic surgery for nothing! :)
/datum/surgery_step/insert_plastic
	name = "insert plastic (plastic)"
	implements = list(
		/obj/item/stack/sheet/plastic = 100,
		/obj/item/stack/sheet/meat = 100)
	time = 3.2 SECONDS
	preop_sound = 'sound/effects/blobattack.ogg'
	success_sound = 'sound/effects/attackblob.ogg'
	failure_sound = 'sound/effects/blobattack.ogg'

/datum/surgery_step/insert_plastic/preop(mob/user, mob/living/target, target_zone, obj/item/stack/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to insert [tool] into the incision in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to insert [tool] into the incision in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to insert [tool] into the incision in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "You feel something inserting just below the skin in your [target.parse_zone_with_bodypart(target_zone)].")

/datum/surgery_step/insert_plastic/success(mob/user, mob/living/target, target_zone, obj/item/stack/tool, datum/surgery/surgery, default_display_results)
	. = ..()
	tool.use(1)

//reshape_face
/datum/surgery_step/reshape_face
	name = "reshape face (scalpel)"
	implements = list(
		TOOL_SCALPEL = 100,
		/obj/item/knife = 50,
		TOOL_WIRECUTTER = 35)
	time = 64
	surgery_effects_mood = TRUE

/datum/surgery_step/reshape_face/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(span_notice("[user] begins to alter [target]'s appearance."), span_notice("You begin to alter [target]'s appearance..."))
	display_results(
		user,
		target,
		span_notice("You begin to alter [target]'s appearance..."),
		span_notice("[user] begins to alter [target]'s appearance."),
		span_notice("[user] begins to make an incision in [target]'s face."),
	)
	display_pain(target, "You feel slicing pain across your face!")

/datum/surgery_step/reshape_face/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(HAS_TRAIT_FROM(target, TRAIT_DISFIGURED, TRAIT_GENERIC))
		REMOVE_TRAIT(target, TRAIT_DISFIGURED, TRAIT_GENERIC)
		display_results(
			user,
			target,
			span_notice("You successfully restore [target]'s appearance."),
			span_notice("[user] successfully restores [target]'s appearance!"),
			span_notice("[user] finishes the operation on [target]'s face."),
		)
		display_pain(target, "The pain fades, your face feels normal again!")
	else
		var/list/names = list()
		if(!isabductor(user))
			var/obj/item/offhand = user.get_inactive_held_item()
			if(istype(offhand, /obj/item/photo) && istype(surgery, /datum/surgery/plastic_surgery/advanced))
				var/obj/item/photo/disguises = offhand
				for(var/namelist as anything in disguises.picture?.names_seen)
					names += namelist
			else
				user.visible_message(span_warning("You have no picture to base the appearance on, reverting to random appearances."))
				for(var/i in 1 to 10)
					names += target.generate_random_mob_name(TRUE)
		else
			for(var/j in 1 to 9)
				names += "Subject [target.gender == MALE ? "i" : "o"]-[pick("a", "b", "c", "d", "e")]-[rand(10000, 99999)]"
			names += target.generate_random_mob_name(TRUE) //give one normal name in case they want to do regular plastic surgery
		var/chosen_name = tgui_input_list(user, "New name to assign", "Plastic Surgery", names)
		if(isnull(chosen_name))
			return
		var/oldname = target.real_name
		target.real_name = chosen_name
		var/newname = target.real_name //something about how the code handles names required that I use this instead of target.real_name
		display_results(
			user,
			target,
			span_notice("You alter [oldname]'s appearance completely, [target.p_they()] is now [newname]."),
			span_notice("[user] alters [oldname]'s appearance completely, [target.p_they()] is now [newname]!"),
			span_notice("[user] finishes the operation on [target]'s face."),
		)
		display_pain(target, "The pain fades, your face feels new and unfamiliar!")
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		human_target.sec_hud_set_ID()
	if(HAS_MIND_TRAIT(user, TRAIT_MORBID) && ishuman(user))
		var/mob/living/carbon/human/morbid_weirdo = user
		morbid_weirdo.add_mood_event("morbid_abominable_surgery_success", /datum/mood_event/morbid_abominable_surgery_success)
	return ..()

/datum/surgery_step/reshape_face/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_warning("You screw up, leaving [target]'s appearance disfigured!"),
		span_notice("[user] screws up, disfiguring [target]'s appearance!"),
		span_notice("[user] finishes the operation on [target]'s face."),
	)
	display_pain(target, "Your face feels horribly scarred and deformed!")
	ADD_TRAIT(target, TRAIT_DISFIGURED, TRAIT_GENERIC)
	return FALSE
