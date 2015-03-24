/spell/targeted/frenchcurse
	name = "French Curse"
	desc = "This curse will silence your target for a very long time."

	school = "evocation"
	charge_max = 300
	spell_flags = 0
	invocation = "FU'K Y'U D'NY"
	invocation_type = SpI_SHOUT
	range = 1
	cooldown_min = 50

	sparks_spread = 1
	sparks_amt = 4

	compatible_mobs = list(/mob/living/carbon/human)

	hud_state = "wiz_mime"

/spell/targeted/frenchcurse/cast(list/targets, mob/user = usr)
	..()
	for(var/mob/living/carbon/human/target in targets)
		if(!ishuman(target)) continue
		var/obj/item/clothing/mask/gas/mime/magicmimemask = new /obj/item/clothing/mask/gas/mime(target)
		var/obj/item/clothing/under/mime/magicmimeunder = new /obj/item/clothing/under/mime(target)
		magicmimemask.canremove = 0		//curses!
		magicmimeunder.canremove = 0
		magicmimemask.unacidable = 1	//cannot be acided
		magicmimeunder.unacidable = 1
		magicmimemask.muted = 1 	//silence
		magicmimemask.can_flip = 0   //no pushing the mask up off your face
		var/obj/old_mask = target.wear_mask
		var/obj/old_uniform = target.w_uniform
		target.equip_to_slot(magicmimemask, slot_wear_mask)
		target.equip_to_slot(magicmimeunder, slot_w_uniform)
		del(old_mask)
		del(old_uniform)
		flick("e_flash", target.flash)
