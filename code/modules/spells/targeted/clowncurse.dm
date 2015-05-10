/spell/targeted/genetic/clowncurse
	name = "The Clown Curse"
	desc = "A curse that will turn its victim into a miserable clown."

	school = "evocation"
	charge_max = 300
	spell_flags = 0
	invocation = "L' C'MMEDIA E F'NITA!"
	invocation_type = SpI_SHOUT
	range = 1
	cooldown_min = 50

	sparks_spread = 1
	sparks_amt = 4

	compatible_mobs = list(/mob/living/carbon/human)

	hud_state = "wiz_clown"

/spell/targeted/genetic/clowncurse/cast(list/targets, mob/user = usr)
	..()
	for(var/mob/living/carbon/human/target in targets)
		if(!ishuman(target)) continue
		var/obj/item/clothing/mask/gas/clown_hat/magicclownmask = new /obj/item/clothing/mask/gas/clown_hat(target)
		var/obj/item/clothing/under/rank/clown/magicclownunder = new /obj/item/clothing/under/rank/clown(target)
		var/obj/item/clothing/shoes/clown_shoes/magicclownshoes = new /obj/item/clothing/shoes/clown_shoes(target)
		magicclownmask.canremove = 0		//curses!
		magicclownunder.canremove = 0
		magicclownshoes.canremove = 0
		magicclownmask.unacidable = 1	//cannot be acided
		magicclownunder.unacidable = 1
		magicclownshoes.unacidable = 1
		magicclownmask.can_flip = 0   //no pushing the mask up off your face
		var/obj/old_mask = target.wear_mask
		var/obj/old_uniform = target.w_uniform
		var /obj/old_shoes = target.shoes
		target.equip_to_slot(magicclownmask, slot_wear_mask)
		target.equip_to_slot(magicclownunder, slot_w_uniform)
		target.equip_to_slot(magicclownshoes, slot_shoes)
		qdel(old_mask)
		qdel(old_uniform)
		qdel(old_shoes)
		flick("e_flash", target.flash)
		target.mutations.Add(M_CLUMSY)
