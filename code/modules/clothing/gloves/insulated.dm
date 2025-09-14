/obj/item/clothing/gloves/color
	abstract_type = /obj/item/clothing/gloves/color
	dying_key = DYE_REGISTRY_GLOVES
	greyscale_colors = null

/obj/item/clothing/gloves/color/yellow
	desc = "These gloves provide protection against electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	siemens_coefficient = 0
	armor_type = /datum/armor/color_yellow
	resistance_flags = NONE
	custom_price = PAYCHECK_CREW * 10
	custom_premium_price = PAYCHECK_COMMAND * 6
	cut_type = /obj/item/clothing/gloves/cut
	equip_sound = 'sound/items/equip/glove_equip.ogg'

/obj/item/clothing/gloves/color/yellow/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, 10)

/obj/item/clothing/gloves/color/yellow/apply_fantasy_bonuses(bonus)
	. = ..()
	if(bonus >= 10)
		qdel(GetComponent(/datum/component/adjust_fishing_difficulty))

/obj/item/clothing/gloves/color/yellow/remove_fantasy_bonuses(bonus)
	AddComponent(/datum/component/adjust_fishing_difficulty, 10)
	return ..()

/datum/armor/color_yellow
	bio = 50

/obj/item/clothing/gloves/color/yellow/heavy
	name = "ceramic-lined insulated gloves"
	desc = "A cheaper make of the standard insulated gloves, using internal ceramic lining to make up for the sub-par rubber material. The extra weight makes them more bulky to use."
	slowdown = 1
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/toy/sprayoncan
	name = "spray-on insulation applicator"
	desc = "What is the number one problem facing our station today?"
	icon = 'icons/obj/clothing/gloves.dmi'
	icon_state = "sprayoncan"

/obj/item/toy/sprayoncan/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!iscarbon(interacting_with))
		return NONE
	var/mob/living/carbon/C = interacting_with
	var/mob/living/carbon/U = user
	var/success = C.equip_to_slot_if_possible(new /obj/item/clothing/gloves/color/yellow/sprayon, ITEM_SLOT_GLOVES, qdel_on_fail = TRUE, disable_warning = TRUE)
	if(success)
		if(C == user)
			C.visible_message(span_notice("[U] sprays their hands with glittery rubber!"))
		else
			C.visible_message(span_warning("[U] sprays glittery rubber on the hands of [C]!"))
	else
		C.visible_message(span_warning("The rubber fails to stick to [C]'s hands!"))
	return ITEM_INTERACT_SUCCESS

/obj/item/clothing/gloves/color/yellow/sprayon
	desc = "How're you gonna get 'em off, nerd?"
	name = "spray-on insulated gloves"
	icon_state = "sprayon"
	inhand_icon_state = null
	item_flags = DROPDEL
	clothing_traits = list(TRAIT_CHUNKYFINGERS)
	armor_type = /datum/armor/none
	resistance_flags = ACID_PROOF
	var/charges_remaining = 10

/obj/item/clothing/gloves/color/yellow/sprayon/Initialize(mapload)
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/gloves/color/yellow/sprayon/equipped(mob/user, slot)
	. = ..()
	RegisterSignal(user, COMSIG_LIVING_SHOCK_PREVENTED, PROC_REF(use_charge))
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(use_charge))

/obj/item/clothing/gloves/color/yellow/sprayon/proc/use_charge()
	SIGNAL_HANDLER

	. = NONE

	charges_remaining--
	if(charges_remaining <= 0)
		var/turf/location = get_turf(src)
		location.visible_message(span_warning("[src] crumble[p_s()] away into nothing.")) // just like my dreams after working with .dm
		qdel(src)

	. |= COMPONENT_CLEANED

/obj/item/clothing/gloves/color/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap knockoffs of the coveted ones - no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	greyscale_colors = null
	siemens_coefficient = 1 //Set to a default of 1, gets overridden in Initialize()
	armor_type = /datum/armor/color_fyellow
	resistance_flags = NONE
	cut_type = /obj/item/clothing/gloves/cut

/datum/armor/color_fyellow
	bio = 25

/obj/item/clothing/gloves/color/fyellow/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)

/obj/item/clothing/gloves/color/fyellow/examine_tags(mob/user)
	. = ..()
	// Pretend we're always insulated
	if (.["partially insulated"])
		. -= "partially insulated"
	.["insulated"] = "It is made from a robust electrical insulator and will block any electricity passing through it!"

/obj/item/clothing/gloves/color/fyellow/old
	desc = "Old and worn out insulated gloves, hopefully they still work."
	name = "worn out insulated gloves"

/obj/item/clothing/gloves/color/fyellow/old/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0,0,0.5,0.5,0.5,0.75)

/obj/item/clothing/gloves/cut
	desc = "These gloves would protect the wearer from electric shock... if the fingers were covered."
	name = "fingerless insulated gloves"
	icon_state = "yellowcut"
	inhand_icon_state = "ygloves"
	greyscale_colors = null
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)

/obj/item/clothing/gloves/cut/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -5)

/obj/item/clothing/gloves/cut/heirloom
	desc = "The old gloves your great grandfather stole from Engineering, many moons ago. They've seen some tough times recently."

/obj/item/clothing/gloves/chief_engineer
	desc = "These gloves provide excellent heat and electric insulation."
	name = "advanced insulated gloves"
	icon_state = "ce_insuls"
	inhand_icon_state = null
	greyscale_colors = null
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/gloves/chief_engineer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -6)
