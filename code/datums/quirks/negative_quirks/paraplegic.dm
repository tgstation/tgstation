/datum/quirk/paraplegic
	name = "Paraplegic"
	desc = "Your legs do not function. Nothing will ever fix this. But hey, free wheelchair!"
	icon = FA_ICON_WHEELCHAIR
	value = -12
	gain_text = null // Handled by trauma.
	lose_text = null
	medical_record_text = "Patient has an untreatable impairment in motor function in the lower extremities."
	hardcore_value = 15
	mail_goodies = list(/obj/vehicle/ridden/wheelchair/motorized) //yes a fullsized unfolded motorized wheelchair does fit

/datum/quirk_constant_data/paraplegic
	associated_typepath = /datum/quirk/paraplegic
	customization_options = list(/datum/preference/choiced/paraplegic)

/datum/quirk/paraplegic/add_unique(client/client_source)
	quirk_holder.put_in_wheelchair()
	// During the spawning process, they may have dropped what they were holding, due to the paralysis
	// So put the things back in their hands.
	for(var/obj/item/dropped_item in get_turf(quirk_holder))
		if(dropped_item.fingerprintslast == quirk_holder.ckey)
			quirk_holder.put_in_hands(dropped_item)

	// Finally, removes their legs if they have opted as such, deleting the shoes
	var/amputee = GLOB.paraplegic_choice[client_source?.prefs?.read_preference(/datum/preference/choiced/paraplegic)]
	if(amputee)
		delete_legs(quirk_holder)

/datum/quirk/paraplegic/proc/delete_legs(mob/living/carbon/human/human_holder)
	qdel(human_holder.get_item_by_slot(ITEM_SLOT_FEET))
	qdel(human_holder.get_bodypart(BODY_ZONE_L_LEG))
	qdel(human_holder.get_bodypart(BODY_ZONE_R_LEG))

/datum/quirk/paraplegic/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/paraplegic/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/paralysis/paraplegic, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/paraplegic/is_species_appropriate(datum/species/mob_species)
	if(istype(mob_species, /datum/species/human/cerulean)) //prevent weird interactions
		return FALSE
	return ..()

/// Put a mob in a wheelchair, simple as
/mob/living/proc/put_in_wheelchair()
	// more than 5k score? you unlock the gamer wheelchair.
	var/gold = FALSE
	if(client?.get_award_status(/datum/award/score/hardcore_random) >= 5000)
		gold = TRUE

	// early return for if we spawn inside a closet. its more likely than you think
	if(istype(loc, /obj/structure/closet))
		if(gold)
			new /obj/item/wheelchair/gold(loc)
		else
			new /obj/item/wheelchair(loc)
		return

	var/turf/turf = get_turf(src)
	var/obj/structure/chair/chair_in_turf = locate() in turf
	var/obj/vehicle/ridden/wheelchair/wheelchair
	if(gold)
		wheelchair = new /obj/vehicle/ridden/wheelchair/gold(turf)
	else
		wheelchair = new (turf)

	// align with a chair already in the turf (if there is one)
	if(chair_in_turf  && chair_in_turf != wheelchair)
		wheelchair.setDir(chair_in_turf.dir)
		// unbuckle from the chair that already exists
		if(length(chair_in_turf.buckled_mobs) && locate(src) in chair_in_turf.buckled_mobs)
			chair_in_turf.unbuckle_mob(src)

	// buckle to the wheelchair!
	wheelchair.buckle_mob(src)
