///Moth wings! They can flutter in low-grav and burn off in heat
/obj/item/organ/external/wings/moth
	name = "moth wings"
	desc = "Spread your wings and FLOOOOAAAAAT!"

	preference = "feature_moth_wings"

	dna_block = DNA_MOTH_WINGS_BLOCK

	bodypart_overlay = /datum/bodypart_overlay/mutant/wings/moth

	///Are we burned?
	var/burnt = FALSE
	///Store our old datum here for if our burned wings are healed
	var/original_sprite_datum

/obj/item/organ/external/wings/moth/on_mob_insert(mob/living/carbon/receiver)
	. = ..()
	RegisterSignal(receiver, COMSIG_HUMAN_BURNING, PROC_REF(try_burn_wings))
	RegisterSignal(receiver, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(heal_wings))
	RegisterSignal(receiver, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(update_float_move))

/obj/item/organ/external/wings/moth/on_mob_remove(mob/living/carbon/organ_owner)
	. = ..()
	UnregisterSignal(organ_owner, list(COMSIG_HUMAN_BURNING, COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_MOVABLE_PRE_MOVE))
	REMOVE_TRAIT(organ_owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))

/obj/item/organ/external/wings/moth/make_flap_sound(mob/living/carbon/wing_owner)
	playsound(wing_owner, 'sound/voice/moth/moth_flutter.ogg', 50, TRUE)

/obj/item/organ/external/wings/moth/can_soften_fall()
	return !burnt

///Check if we can flutter around
/obj/item/organ/external/wings/moth/proc/update_float_move()
	SIGNAL_HANDLER

	if(!isspaceturf(owner.loc) && !burnt)
		var/datum/gas_mixture/current = owner.loc.return_air()
		if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85)) //as long as there's reasonable pressure and no gravity, flight is possible
			ADD_TRAIT(owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))
			return

	REMOVE_TRAIT(owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))

///check if our wings can burn off ;_;
/obj/item/organ/external/wings/moth/proc/try_burn_wings(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(!burnt && human.bodytemperature >= 800 && human.fire_stacks > 0) //do not go into the extremely hot light. you will not survive
		to_chat(human, span_danger("Your precious wings burn to a crisp!"))
		human.add_mood_event("burnt_wings", /datum/mood_event/burnt_wings)

		burn_wings()
		human.update_body_parts()

///burn the wings off
/obj/item/organ/external/wings/moth/proc/burn_wings()
	var/datum/bodypart_overlay/mutant/wings/moth/wings = bodypart_overlay
	wings.burnt = TRUE
	burnt = TRUE

///heal our wings back up!!
/obj/item/organ/external/wings/moth/proc/heal_wings(datum/source, heal_flags)
	SIGNAL_HANDLER

	if(!burnt)
		return

	if(heal_flags & (HEAL_LIMBS|HEAL_ORGANS))
		var/datum/bodypart_overlay/mutant/wings/moth/wings = bodypart_overlay
		wings.burnt = FALSE
		burnt = FALSE

///Moth wing bodypart overlay, including burn functionality!
/datum/bodypart_overlay/mutant/wings/moth
	feature_key = "moth_wings"
	layers = EXTERNAL_BEHIND | EXTERNAL_FRONT
	///Accessory datum of the burn sprite
	var/datum/sprite_accessory/burn_datum = /datum/sprite_accessory/moth_wings/burnt_off
	///Are we burned? If so we draw differently
	var/burnt

/datum/bodypart_overlay/mutant/wings/moth/New()
	. = ..()

	burn_datum = fetch_sprite_datum(burn_datum)

/datum/bodypart_overlay/mutant/wings/moth/get_global_feature_list()
	return SSaccessories.moth_wings_list

/datum/bodypart_overlay/mutant/wings/moth/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.wear_suit?.flags_inv & HIDEMUTWINGS))
		return TRUE
	return FALSE

/datum/bodypart_overlay/mutant/wings/moth/get_base_icon_state()
	return burnt ? burn_datum.icon_state : sprite_datum.icon_state
