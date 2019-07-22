/obj/item/clothing/head
	name = BODY_ZONE_HEAD
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "top_hat"
	item_state = "that"
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	var/blockTracking = 0 //For AI tracking
	var/can_toggle = null
	///Check if a hat is capable of being knocked off via hat-throwing. TRUE means hat cannot be knocked off.
	var/snug_fit = FALSE
	///Some hats have negative properties once equipped, having this set to TRUE means the hat will never successfully replace a hat or equip itself via hat-throwing.
	var/anti_tinfoil_maneuver = FALSE
	dynamic_hair_suffix = "+generic"

/obj/item/clothing/head/Initialize()
	. = ..()
	if(ishuman(loc) && dynamic_hair_suffix)
		var/mob/living/carbon/human/H = loc
		H.update_hair()

///Special throw_impact for hats to frisbee hats at people to place them on their heads/attempt to de-hat them.
/obj/item/clothing/head/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	. = ..()
	///if the thrown object exists, has a target_zone from whatever threw it, isn't the thrower and the target zone isn't the head	
	if(thrownthing && thrownthing.target_zone && thrownthing.thrower != hit_atom && thrownthing.target_zone != BODY_ZONE_HEAD)
		return
	if(iscarbon(hit_atom))
		var/mob/living/carbon/H = hit_atom
		if(istype(H.head, /obj/item/clothing/head))
			var/obj/item/clothing/head/WH = H.head
			///if H's head slot has something equipped, has snug_fit set to FALSE, and the thrown hat has anti_tinfoil_maneuver set to FALSE
			if(istype(WH) && !WH.snug_fit && !anti_tinfoil_maneuver)
				///attempt to drop the equipped item to the ground and attempt to equip the thrown hat
				if(H.dropItemToGround(WH) && H.equip_to_slot_if_possible(src, SLOT_HEAD, 0, 1, 1))
					H.visible_message("<span class='warning'>[src] knocks [WH] off [H]'s head!</span>", "<span class='warning'>[WH] is suddenly knocked off your head, replaced by [src]!</span>")
			else
				H.visible_message("<span class='warning'>[src] bounces off [H]'s [WH.name]!", "<span class='warning'>[src] bounces off your [WH.name], falling to the floor.</span>")
				return
		///H has nothing equipped in the head slot, so the thrown hat will attempt to equip itself if anti_tinfoil_maneuver is set to FALSE		
		if(!H.head && !anti_tinfoil_maneuver && H.equip_to_slot_if_possible(src, SLOT_HEAD, 0, 1, 1))
			H.visible_message("<span class='notice'>[src] lands neatly on [H]'s head!", "<span class='notice'>[src] lands perfectly onto your head!</span>")
	if(iscyborg(hit_atom))
		var/mob/living/silicon/robot/R = hit_atom
		R.place_on_head(src)


/obj/item/clothing/head/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damagedhelmet")
		if(HAS_BLOOD_DNA(src))
			. += mutable_appearance('icons/effects/blood.dmi', "helmetblood")

/obj/item/clothing/head/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_head()
