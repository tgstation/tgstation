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
	if(quirk_holder.buckled) // Handle late joins being buckled to arrival shuttle chairs.
		quirk_holder.buckled.unbuckle_mob(quirk_holder)

	var/turf/holder_turf = get_turf(quirk_holder)
	var/obj/structure/chair/spawn_chair = locate() in holder_turf

	var/obj/vehicle/ridden/wheelchair/wheels
	if(client_source?.get_award_status(/datum/award/score/hardcore_random) >= 5000) //More than 5k score? you unlock the gamer wheelchair.
		wheels = new /obj/vehicle/ridden/wheelchair/gold(holder_turf)
	else
		wheels = new(holder_turf)
	if(spawn_chair) // Makes spawning on the arrivals shuttle more consistent looking
		wheels.setDir(spawn_chair.dir)

	wheels.buckle_mob(quirk_holder)

	// During the spawning process, they may have dropped what they were holding, due to the paralysis
	// So put the things back in their hands.
	for(var/obj/item/dropped_item in holder_turf)
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
