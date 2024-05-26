/obj/item/organ/internal/cyberimp/leg/table_glider
	name = "table-glider implant"
	desc = "Implant that allows you quickly glide tables. You need to implant this in both of your legs to make it work."
	encode_info = AUGMENT_NT_LOWLEVEL
	double_legged = TRUE

/obj/item/organ/internal/cyberimp/leg/table_glider/update_implants()
	if(!check_compatibility())
		REMOVE_TRAIT(owner,TRAIT_FAST_CLIMBER,type)
		return
	ADD_TRAIT(owner,TRAIT_FAST_CLIMBER,type)

/obj/item/organ/internal/cyberimp/leg/table_glider/on_full_insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	if(!check_compatibility())
		return
	ADD_TRAIT(owner,TRAIT_FAST_CLIMBER,type)

/obj/item/organ/internal/cyberimp/leg/table_glider/Remove(mob/living/carbon/M, special)
	REMOVE_TRAIT(owner,TRAIT_FAST_CLIMBER,type)
	return ..()

/obj/item/organ/internal/cyberimp/leg/shove_resist
	name = "BU-TAM resistor implant"
	desc = "Implant that allows you to resist shoves, instead shoves deal pure stamina damage. You need to implant this in both of your legs to make it work."
	encode_info = AUGMENT_NT_HIGHLEVEL
	double_legged = TRUE

/obj/item/organ/internal/cyberimp/leg/shove_resist/update_implants()
	if(!check_compatibility())
		REMOVE_TRAIT(owner,TRAIT_SHOVE_RESIST,type)
		return
	ADD_TRAIT(owner,TRAIT_SHOVE_RESIST,type)

/obj/item/organ/internal/cyberimp/leg/shove_resist/on_full_insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	if(!check_compatibility())
		return
	ADD_TRAIT(owner,TRAIT_SHOVE_RESIST,type)

/obj/item/organ/internal/cyberimp/leg/shove_resist/Remove(mob/living/carbon/M, special)
	REMOVE_TRAIT(owner,TRAIT_SHOVE_RESIST,type)
	return ..()

/obj/item/organ/internal/cyberimp/leg/accelerator
	name = "P.R.Y.Z.H.O.K. accelerator system"
	desc = "Russian implant that allows you to tackle people. You need to implant this in both of your legs to make it work."
	encode_info = AUGMENT_NT_HIGHLEVEL
	double_legged = TRUE
	var/datum/component/tackler

/obj/item/organ/internal/cyberimp/leg/accelerator/on_full_insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	tackler = M.AddComponent(/datum/component/tackler, stamina_cost=30, base_knockdown = 1.5, range = 5, speed = 2, skill_mod = 1.5, min_distance = 3)

/obj/item/organ/internal/cyberimp/leg/accelerator/Remove(mob/living/carbon/M, special)
	if(tackler)
		qdel(tackler)
	return ..()
