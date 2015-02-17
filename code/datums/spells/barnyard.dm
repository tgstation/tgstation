/obj/effect/proc_holder/spell/targeted/barnyardcurse
	name = "Curse of the Barnyard"
	desc = "This spell dooms the fate of any unlucky soul to the speech and facial attributes of a barnyard animal"
	school = "transmutation"
	charge_type = "recharge"
	charge_max	= 150
	charge_counter = 0
	clothes_req = 0
	stat_allowed = 0
	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = "shout"
	range = 7
	cooldown_min = 30
	selection_type = "range"
	var/list/compatible_mobs = list(/mob/living/carbon/human,/mob/living/carbon/monkey)

/obj/effect/proc_holder/spell/targeted/barnyardcurse/cast(list/targets, mob/user = usr)
	if(!targets.len)
		user << "<span class='notice'>No target found in range.</span>"
		return

	var/mob/living/carbon/target = targets[1]

	if(!(target.type in compatible_mobs))
		user << "<span class='notice'>You are unable to curse [target]'s head!</span>"
		return

	if(!(target in oview(range)))
		user << "<span class='notice'>They are too far away!</span>"
		return

	if (prob(33))

		var/obj/item/clothing/mask/spig/magicpig = new /obj/item/clothing/mask/spig //needs to be different otherwise you could turn it off and on.
		magicpig.flags |=NODROP
		magicpig.flags_inv = null
		magicpig.voicechange = 1
		target.equip_to_slot_if_possible(magicpig, slot_wear_mask,1,1)
		target.visible_message("<span class='danger'>[target]'s face lights up in fire, and after the event a pig's head takes it's place!</span>", \
							   "<span class='danger'>Your face burns up, and shortly after the fire you realise you have the face of a pig!</span>")
		if(!target.unEquip(target.wear_mask))
			qdel(target.wear_mask)
		target.equip_to_slot_if_possible(magicpig,slot_wear_mask,1,1)

		flick("e_flash", target.flash)
		return

	if (prob(55))

		var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
		magichead.flags |=NODROP
		magichead.flags_inv = null
		magichead.voicechange = 1
		target.equip_to_slot_if_possible(magichead, slot_wear_mask,1,1)
		target.visible_message("<span class='danger'>[target]'s face lights up in fire, and after the event a horses head takes it's place!</span>", \
							   "<span class='danger'>Your face burns up, and shortly after the fire you realise you have the face of a horse!</span>")
		if(!target.unEquip(target.wear_mask))
			qdel(target.wear_mask)
		target.equip_to_slot_if_possible(magichead,slot_wear_mask,1,1)

		flick("e_flash", target.flash)
		return

	if (prob(100)) //If nothing else works then it will be a cow head.

		var/obj/item/clothing/mask/cowmask/magiccow = new /obj/item/clothing/mask/cowmask
		magiccow.flags |=NODROP
		magiccow.flags_inv = null
		target.equip_to_slot_if_possible(magiccow, slot_wear_mask,1,1)
		target.visible_message("<span class='danger'>[target]'s face lights up in fire, and after the event a cow's head takes it's place!</span>", \
							   "<span class='danger'>Your face burns up. and shortly after the fire you realise you have the face of a cow!</span>")
		if(!target.unEquip(target.wear_mask))
			qdel(target.wear_mask)
		target.equip_to_slot_if_possible(magiccow,slot_wear_mask,1,1)

		flick("e_flash", target.flash)
		return
