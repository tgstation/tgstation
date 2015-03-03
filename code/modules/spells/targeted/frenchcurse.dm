/spell/targeted/frenchcurse
	name = "French Curse"
	desc = "This curse will silence your target for a very long time."

	school = "evocation"
	charge_max = 300
	invocation = "FU'K Y'U D'NY"
	invocation_type = "shout"
	range = 1
	cooldown_min = 100 //100 deciseconds reduction per rank

	sparks_spread = 1
	sparks_amt = 4

	compatible_mobs = list(/mob/living/carbon/human)

/spell/targeted/frenchcurse/cast(list/targets, mob/user = usr)
	..()
	for(var/mob/living/carbon/human/target in targets)
		if(!ishuman(target)) continue
		var/obj/item/clothing/mask/gas/mime/magicmimemask = new /obj/item/clothing/mask/gas/mime
		var/obj/item/clothing/under/mime/magicmimeunder = new /obj/item/clothing/under/mime
		magicmimemask.canremove = 0		//curses!
		magicmimeunder.canremove = 0
		magicmimemask.unacidable = 1	//cannot be acided
		magicmimeunder.unacidable = 1
		magicmimemask.muted = 1 	//silence
		var/obj/old_mask = target.wear_mask
		var/obj/old_uniform = target.w_uniform
		if(old_mask)
			target.drop_from_inventory(old_mask)
			qdel(old_mask)
		target.equip_to_slot_if_possible(magicmimemask, slot_wear_mask, 1, 1)
		if(old_uniform)
			target.drop_from_inventory(old_uniform)
			qdel(old_uniform)
		target.equip_to_slot_if_possible(magicmimeunder, slot_w_uniform, 1,1)

		flick("e_flash", target.flash)
