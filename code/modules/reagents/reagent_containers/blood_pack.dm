/obj/item/reagent_containers/blood
	name = "blood pack"
	desc = "Contains blood used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/medical/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 200
	fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
	var/blood_type = null
	var/labelled = FALSE

/obj/item/reagent_containers/blood/Initialize(mapload, vol)
	. = ..()
	if (!blood_type)
		return
	var/datum/blood_type/bloodtype = get_blood_type(blood_type)
	reagents.add_reagent(bloodtype.reagent_type, volume, list("blood_type" = bloodtype, "blood_DNA" = bloodtype.dna_string), creation_callback = CALLBACK(src, PROC_REF(on_blood_created)))

/obj/item/reagent_containers/blood/proc/on_blood_created(datum/reagent/new_blood)
	new_blood.AddElement(/datum/element/blood_reagent, null, get_blood_type(blood_type))
	update_appearance()

/obj/item/reagent_containers/blood/update_name(updates)
	. = ..()
	if(!labelled)
		name = "blood pack[blood_type ? " - [blood_type]" : ""]"

/obj/item/reagent_containers/blood/random
	icon_state = "random_bloodpack"

/obj/item/reagent_containers/blood/random/Initialize(mapload, vol)
	icon_state = "bloodpack"
	blood_type = pick(BLOOD_TYPE_A_PLUS, BLOOD_TYPE_A_MINUS, BLOOD_TYPE_B_PLUS, BLOOD_TYPE_B_MINUS, BLOOD_TYPE_O_PLUS, BLOOD_TYPE_O_MINUS, BLOOD_TYPE_LIZARD)
	return ..()

/obj/item/reagent_containers/blood/a_plus
	blood_type = BLOOD_TYPE_A_PLUS

/obj/item/reagent_containers/blood/a_minus
	blood_type = BLOOD_TYPE_A_MINUS

/obj/item/reagent_containers/blood/b_plus
	blood_type = BLOOD_TYPE_B_PLUS

/obj/item/reagent_containers/blood/b_minus
	blood_type = BLOOD_TYPE_B_MINUS

/obj/item/reagent_containers/blood/o_plus
	blood_type = BLOOD_TYPE_O_PLUS

/obj/item/reagent_containers/blood/o_minus
	blood_type = BLOOD_TYPE_O_MINUS

/obj/item/reagent_containers/blood/lizard
	blood_type = BLOOD_TYPE_LIZARD

/obj/item/reagent_containers/blood/ethereal
	blood_type = BLOOD_TYPE_ETHEREAL

/obj/item/reagent_containers/blood/snail
	blood_type = BLOOD_TYPE_SNAIL

/obj/item/reagent_containers/blood/snail/examine()
	. = ..()
	. += span_notice("It's a bit slimy... The label indicates that this is meant for snails.")

/obj/item/reagent_containers/blood/podperson
	blood_type = BLOOD_TYPE_H2O

/obj/item/reagent_containers/blood/podperson/examine()
	. = ..()
	. += span_notice("This appears to be some very overpriced water.")

// for slimepeople
/obj/item/reagent_containers/blood/toxin
	blood_type = BLOOD_TYPE_TOX

/obj/item/reagent_containers/blood/toxin/examine()
	. = ..()
	. += span_notice("There is a toxin warning on the label. This is for slimepeople.")

/obj/item/reagent_containers/blood/universal
	blood_type = BLOOD_TYPE_UNIVERSAL

/obj/item/reagent_containers/blood/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!IS_WRITING_UTENSIL(tool))
		return NONE

	if(!user.can_write(tool))
		return ITEM_INTERACT_BLOCKING

	var/custom_label = tgui_input_text(user, "What would you like to label the blood pack?", "Blood Pack", name, max_length = MAX_NAME_LEN)
	if(!user.can_perform_action(src))
		return ITEM_INTERACT_BLOCKING

	if(user.get_active_held_item() != tool)
		return ITEM_INTERACT_BLOCKING

	if(!custom_label)
		labelled = FALSE
		update_name()
		return ITEM_INTERACT_SUCCESS

	labelled = TRUE
	name = "blood pack - [custom_label]"
	playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
	balloon_alert(user, "new label set")
	return ITEM_INTERACT_SUCCESS
