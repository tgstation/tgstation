/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	slot_flags = ITEM_SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	limb_integrity = 0 // disabled for most exo-suits

/obj/item/clothing/suit/Initialize(mapload)
	. = ..()
	setup_shielding()

/obj/item/clothing/suit/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return

	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damaged[blood_overlay_type]")
	if(HAS_BLOOD_DNA(src))
		. += mutable_appearance('icons/effects/blood.dmi', "[blood_overlay_type]blood")

	var/mob/living/carbon/human/M = loc
	if(!ishuman(M) || !M.w_uniform)
		return
	var/obj/item/clothing/under/U = M.w_uniform
	if(istype(U) && U.attached_accessory)
		var/obj/item/clothing/accessory/A = U.attached_accessory
		if(A.above_suit)
			. += U.accessory_overlay

/obj/item/clothing/suit/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_suit()

/**
 * Wrapper proc to apply shielding through AddComponent().
 * Called in /obj/item/clothing/Initialize().
 * Override with an AddComponent(/datum/component/shielded, args) call containing the desired shield statistics.
 * See /datum/component/shielded documentation for a description of the arguments
 **/
/obj/item/clothing/suit/proc/setup_shielding()
	return
