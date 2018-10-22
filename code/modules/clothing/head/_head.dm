/obj/item/clothing/head
	name = BODY_ZONE_HEAD
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "top_hat"
	item_state = "that"
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	var/blockTracking = 0 //For AI tracking
	var/can_toggle = null
	var/snug_fit = FALSE //is the hat immune to being knocked off?
	var/anti_tinfoil_maneuver = FALSE //if the hat does something negative when worn, this should probably be set to TRUE
	dynamic_hair_suffix = "+generic"

/obj/item/clothing/head/Initialize()
	. = ..()
	if(ishuman(loc) && dynamic_hair_suffix)
		var/mob/living/carbon/human/H = loc
		H.update_hair()

/obj/item/clothing/head/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damagedhelmet")
		IF_HAS_BLOOD_DNA(src)
			. += mutable_appearance('icons/effects/blood.dmi', "helmetblood")

/obj/item/clothing/head/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_head()

/obj/item/clothing/head/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	. = ..()
	if(!.)
		return
	if(thrownthing && thrownthing.target_zone && thrownthing.target_zone != BODY_ZONE_HEAD)
		return
	if(iscarbon(hit_atom))
		var/mob/living/carbon/H = hit_atom
		if(H.head && istype(H.head, /obj/item/clothing/head))
			var/obj/item/clothing/head/WH = H.head
			if(istype(WH) && !WH.snug_fit && !anti_tinfoil_maneuver)
				if(H.dropItemToGround(WH))
					H.equip_to_slot_if_possible(src, SLOT_HEAD, 0, 1, 1)
					H.visible_message("<span class='warning'>[src] knocks [WH] off [H]'s head!</span>", "<span class='warning'>[WH] is suddenly knocked off your head, replaced by [src]!</span>")
			else
				H.visible_message("<span class='warning'>[src] bounces off [H]'s [WH.name]!", "<span class='warning'>[src] bounces off your [WH.name], falling to the floor.</span>")
				return
		if(!H.head)
			H.equip_to_slot_if_possible(src, SLOT_HEAD, 0, 1, 1)
			H.visible_message("<span class='notice'>[src] lands neatly on [H]'s head!", "<span class='notice'>[src] lands perfectly onto your head!</span>")
