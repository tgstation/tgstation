/obj/item/clothing/mask/cursed_rabbit
	name = "Damned Rabbit Mask"
	desc = "Slip into the wonderland."
	icon =  'monkestation/icons/bloodsuckers/weapons.dmi'
	icon_state = "rabbit_mask"
	worn_icon = 'monkestation/icons/bloodsuckers/worn_mask.dmi'
	worn_icon_state = "rabbit_mask"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS | GAS_FILTERING | SNUG_FIT
	flags_inv = HIDEFACE | HIDEFACIALHAIR | HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flash_protect = FLASH_PROTECTION_WELDER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///the paradox rabbit ability
	var/datum/action/cooldown/paradox/paradox
	///teleporting to the wonderland
	var/datum/action/cooldown/wonderland_drop/wonderland

/obj/item/clothing/mask/cursed_rabbit/Initialize(mapload)
	. = ..()
	paradox = new
	wonderland = new

/obj/item/clothing/mask/cursed_rabbit/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(!ishuman(user) || !(slot & ITEM_SLOT_MASK) || !IS_MONSTERHUNTER(user))
		return
	paradox?.Grant(user)
	wonderland?.Grant(user)
	user.apply_status_effect(/datum/status_effect/bnuuy_mask)

/obj/item/clothing/mask/cursed_rabbit/dropped(mob/living/user)
	. = ..()
	paradox?.Remove(user)
	wonderland?.Remove(user)
	user.remove_status_effect(/datum/status_effect/bnuuy_mask)

/datum/status_effect/bnuuy_mask
	id = "bnuuy_mask"
	alert_type = null
	tick_interval = -1
	var/datum/component/glitching_state/wondershift

/datum/status_effect/bnuuy_mask/on_apply()
	. = ..()
	if(!ishuman(owner) || !IS_MONSTERHUNTER(owner) || !istype(owner.get_item_by_slot(ITEM_SLOT_MASK), /obj/item/clothing/mask/cursed_rabbit))
		return FALSE
	wondershift = owner.AddComponent(/datum/component/glitching_state)

/datum/status_effect/bnuuy_mask/on_remove()
	. = ..()
	QDEL_NULL(wondershift)

/datum/status_effect/bnuuy_mask/get_examine_text()
	return span_warning("[owner.p_they(TRUE)] seem[owner.p_s()] out-of-place, as if [owner.p_they()] were partially detached from reality.")
