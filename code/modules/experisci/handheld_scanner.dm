/**
 * # Experi-Scanner
 *
 * Handheld scanning unit to perform scanning experiments
 */
/obj/item/experi_scanner
	name = "Experi-Scanner"
	desc = "A handheld scanner used for completing the many experiments of modern science."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/device.dmi'
	icon_state = "experiscanner"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'

/obj/item/experi_scanner/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

// Late initialize to allow for the rnd servers to initialize first
/obj/item/experi_scanner/LateInitialize()
	. = ..()
	AddComponent(/datum/component/experiment_handler, \
		allowed_experiments = list(/datum/experiment/scanning, /datum/experiment/physical),\
		disallowed_traits = EXPERIMENT_TRAIT_DESTRUCTIVE)

/obj/item/experi_scanner/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is giving in to the Great Toilet Beyond! It looks like [user.p_theyre()] trying to commit suicide!"))

	forceMove(drop_location())
	user.forceMove(src)
	user.AddComponent(/datum/component/itembound, src) //basically a bread smite but with a bloody finale
	icon_state = "experiscanner_closed"
	add_atom_colour("#FF0000", ADMIN_COLOUR_PRIORITY)

	playsound(src, 'sound/effects/pope_entry.ogg', 60, TRUE)
	playsound(src, 'sound/machines/destructive_scanner/ScanDangerous.ogg', 40)
	user.emote("scream")

	addtimer(CALLBACK(src, PROC_REF(make_meat_toilet), user), 5 SECONDS)
	return MANUAL_SUICIDE

/obj/item/experi_scanner/proc/make_meat_toilet(mob/living/carbon/user)
	///The suicide victim's brain that will be placed inside the toilet's cistern
	var/obj/item/organ/internal/brain/toilet_brain = user.getorganslot(ORGAN_SLOT_BRAIN)
	///The toilet we're about to unleash unto this cursed plane of existence
	var/obj/structure/toilet/greyscale/result_toilet = new (drop_location())

	result_toilet.set_custom_materials(list(GET_MATERIAL_REF(/datum/material/meat/mob_meat, user) = MINERAL_MATERIAL_AMOUNT))
	result_toilet.desc = "A horrendous mass of fused flesh resembling a standard-issue HT-451 model toilet. How it manages to function as one is beyond you. \
	This one seems to be made out of the flesh of a devoted employee of the RnD department."
	result_toilet.buildstacktype = /obj/effect/decal/remains/human //this also prevents the toilet from dropping meat sheets. if you want to cheese the meat exepriments, sacrifice more people

	icon_state = "experiscanner"
	remove_atom_colour(ADMIN_COLOUR_PRIORITY, "#FF0000")

	user.gib(FALSE, TRUE, TRUE) //we delete everything but the brain, as it's going to be moved to the cistern
	toilet_brain.forceMove(result_toilet)
	result_toilet.w_items += toilet_brain.w_class
