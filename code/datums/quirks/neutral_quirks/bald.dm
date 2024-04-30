/datum/quirk/item_quirk/bald
	name = "Smooth-Headed"
	desc = "You have no hair and are quite insecure about it! Keep your wig on, or at least your head covered up."
	icon = FA_ICON_EGG
	value = 0
	mob_trait = TRAIT_BALD
	gain_text = span_notice("Your head is as smooth as can be, it's terrible.")
	lose_text = span_notice("Your head itches, could it be... growing hair?!")
	medical_record_text = "Patient starkly refused to take off headwear during examination."
	mail_goodies = list(/obj/item/clothing/head/wig/random)
	/// The user's starting hairstyle
	var/old_hair

/datum/quirk/item_quirk/bald/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	old_hair = human_holder.hairstyle
	human_holder.set_hairstyle("Bald", update = TRUE)
	RegisterSignal(human_holder, COMSIG_CARBON_EQUIP_HAT, PROC_REF(equip_hat))
	RegisterSignal(human_holder, COMSIG_CARBON_UNEQUIP_HAT, PROC_REF(unequip_hat))

/datum/quirk/item_quirk/bald/add_unique(client/client_source)
	var/obj/item/clothing/head/wig/natural/baldie_wig = new(get_turf(quirk_holder))
	if(old_hair == "Bald")
		baldie_wig.hairstyle = pick(SSaccessories.hairstyles_list - "Bald")
	else
		baldie_wig.hairstyle = old_hair

	baldie_wig.update_appearance()

	give_item_to_holder(baldie_wig, list(LOCATION_HEAD = ITEM_SLOT_HEAD, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/bald/remove()
	. = ..()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.hairstyle = old_hair
	human_holder.update_body_parts()
	UnregisterSignal(human_holder, list(COMSIG_CARBON_EQUIP_HAT, COMSIG_CARBON_UNEQUIP_HAT))
	human_holder.clear_mood_event("bad_hair_day")

///Checks if the headgear equipped is a wig and sets the mood event accordingly
/datum/quirk/item_quirk/bald/proc/equip_hat(mob/user, obj/item/hat)
	SIGNAL_HANDLER

	if(istype(hat, /obj/item/clothing/head/wig))
		quirk_holder.add_mood_event("bad_hair_day", /datum/mood_event/confident_mane) //Our head is covered, but also by a wig so we're happy.
	else
		quirk_holder.clear_mood_event("bad_hair_day") //Our head is covered

///Applies a bad moodlet for having an uncovered head
/datum/quirk/item_quirk/bald/proc/unequip_hat(mob/user, obj/item/clothing, force, newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER

	quirk_holder.add_mood_event("bad_hair_day", /datum/mood_event/bald)
