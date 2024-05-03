///Moth wings! They can flutter in low-grav and burn off in heat
/obj/item/organ/external/wings/apid
	name = "apid wings"
	desc = "Spread your wings and FLOOOOAAAAAT!"

	preference = "feature_apid_wings"

	bodypart_overlay = /datum/bodypart_overlay/mutant/wings/apid


/obj/item/organ/external/wings/apid/on_insert(mob/living/carbon/receiver)
	. = ..()
	RegisterSignal(receiver, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(update_float_move))

/obj/item/organ/external/wings/apid/on_remove(mob/living/carbon/organ_owner)
	. = ..()
	UnregisterSignal(organ_owner, list(COMSIG_MOVABLE_PRE_MOVE))
	REMOVE_TRAIT(organ_owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))

/obj/item/organ/external/wings/apid/can_soften_fall()
	return TRUE

///Check if we can flutter around
/obj/item/organ/external/wings/apid/proc/update_float_move()
	SIGNAL_HANDLER

	if(!isspaceturf(owner.loc))
		var/datum/gas_mixture/current = owner.loc.return_air()
		if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85)) //as long as there's reasonable pressure and no gravity, flight is possible
			ADD_TRAIT(owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))
			return

	REMOVE_TRAIT(owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))


///Moth wing bodypart overlay, including burn functionality!
/datum/bodypart_overlay/mutant/wings/apid
	feature_key = "apid_wings"
	layers = EXTERNAL_BEHIND | EXTERNAL_FRONT

/datum/bodypart_overlay/mutant/wings/apid/get_global_feature_list()
	return GLOB.apid_wings_list

/datum/bodypart_overlay/mutant/wings/apid/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.wear_suit?.flags_inv & HIDEMUTWINGS))
		return TRUE
	return FALSE

/datum/bodypart_overlay/mutant/wings/apid/get_base_icon_state()
	return sprite_datum.icon_state

/datum/sprite_accessory/apid_wings
	icon = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	color_src = null
	em_block = TRUE

/datum/sprite_accessory/apid_wings/normal
	name = "Normal"
	icon_state = "normal"

