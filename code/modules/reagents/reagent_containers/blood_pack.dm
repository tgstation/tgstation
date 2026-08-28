/obj/item/reagent_containers/blood
	name = "blood pack"
	desc = "Contains blood used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/medical/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 200
	fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
	obj_flags = UNIQUE_RENAME | RENAME_NO_DESC
	custom_materials = list(/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT)
	var/datum/blood_type/blood_type
	var/labeled = FALSE

/obj/item/reagent_containers/blood/Initialize(mapload, vol)
	. = ..()
	if (!blood_type)
		return
	var/datum/blood_type/bloodtype = get_blood_type(blood_type)
	var/list/blood_data = bloodtype.get_default_blood_data() | list(BLOOD_DATA_SYNTH_CONTENT = 1)

	reagents.add_reagent(bloodtype.reagent_type, volume, blood_data, creation_callback = CALLBACK(src, PROC_REF(on_blood_created)))

/obj/item/reagent_containers/blood/proc/on_blood_created(datum/reagent/new_blood)
	new_blood.AddElement(/datum/element/blood_reagent, null, get_blood_type(blood_type))
	update_appearance()

/obj/item/reagent_containers/blood/update_name(updates)
	. = ..()
	if(!labeled)
		name = "blood pack[blood_type ? " - [blood_type::name]" : ""]"

/obj/item/reagent_containers/blood/random
	icon_state = "random_bloodpack"

/obj/item/reagent_containers/blood/random/Initialize(mapload, vol)
	icon_state = "bloodpack"
	blood_type = pick(get_roundstart_blood_types())
	return ..()

/obj/item/reagent_containers/blood/a_plus
	blood_type = /datum/blood_type/human/a_plus

/obj/item/reagent_containers/blood/a_minus
	blood_type = /datum/blood_type/human/a_minus

/obj/item/reagent_containers/blood/b_plus
	blood_type = /datum/blood_type/human/b_plus

/obj/item/reagent_containers/blood/b_minus
	blood_type = /datum/blood_type/human/b_minus

/obj/item/reagent_containers/blood/o_plus
	blood_type = /datum/blood_type/human/o_plus

/obj/item/reagent_containers/blood/o_minus
	blood_type = /datum/blood_type/human/o_minus

/obj/item/reagent_containers/blood/lizard
	blood_type = /datum/blood_type/lizard

/obj/item/reagent_containers/blood/ethereal
	blood_type = /datum/blood_type/ethereal

/obj/item/reagent_containers/blood/snail
	blood_type = /datum/blood_type/snail

/obj/item/reagent_containers/blood/snail/examine()
	. = ..()
	. += span_notice("It's a bit slimy... The label indicates that this is meant for snails.")

/obj/item/reagent_containers/blood/podperson
	blood_type = /datum/blood_type/water

/obj/item/reagent_containers/blood/podperson/examine()
	. = ..()
	. += span_notice("This appears to be some very overpriced water.")

// for slimepeople
/obj/item/reagent_containers/blood/toxin
	blood_type = /datum/blood_type/slime

/obj/item/reagent_containers/blood/toxin/examine()
	. = ..()
	. += span_notice("There is a toxin warning on the label. This is for slimepeople.")

/obj/item/reagent_containers/blood/universal
	blood_type = /datum/blood_type/universal

/obj/item/reagent_containers/blood/nameformat(input, user)
	playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
	labeled = TRUE
	return "blood pack[input? " - [input]" : null]"
