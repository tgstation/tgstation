/datum/surgery/plastic_surgery
	name = "plastic surgery"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/reshape_face, /datum/surgery_step/close)
	possible_locs = list("head")

//reshape_face
/datum/surgery_step/reshape_face
	name = "reshape face"
	implements = list(/obj/item/scalpel = 100, /obj/item/kitchen/knife = 50, TOOL_WIRECUTTER = 35)
	time = 64
	var/chosen_name

/datum/surgery_step/reshape_face/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	chosen_name = stripped_input(user, "Enter the name that [target] will have, post-surgery.", "Input a name", target.real_name, MAX_NAME_LEN)

	if(QDELETED(tool) || QDELETED(target) || QDELETED(user) || !chosen_name)
		return -1 // FAILURE

	user.visible_message("[user] begins to alter [target]'s appearance.", "<span class='notice'>You begin to alter [target]'s appearance...</span>")

/datum/surgery_step/reshape_face/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/oldname = target.real_name
	user.visible_message("[user] alters [oldname]'s appearance completely, [target.p_they()] is now [chosen_name]!", "<span class='notice'>You alter [oldname]'s appearance completely, [target.p_they()] is now [chosen_name].</span>")

	target.fully_replace_character_name(null, chosen_name)

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.sec_hud_set_ID()
	return 1

/datum/surgery_step/reshape_face/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	..()
	// Screw up, and they get a random name instead.
	chosen_name = target.dna.species.random_name(target.gender,1)
	. = success(user, target, target_zone, tool, surgery)
