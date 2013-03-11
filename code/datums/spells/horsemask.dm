/obj/effect/proc_holder/spell/targeted/horsemask
	name = "Curse of the Horseman"
	desc = "This spell triggers a curse on a target, causing them to wield an unremovable horse head mask. They will speak like a horse! Any masks they are wearing will be disintegrated. This spell does not require robes."
	school = "transmutation"
	charge_type = "recharge"
	charge_max = 150
	charge_counter = 0
	clothes_req = 0
	stat_allowed = 0
	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = "shout"
	range = 7
	selection_type = "range"
	var/list/compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

/obj/effect/proc_holder/spell/targeted/horsemask/cast(list/targets, mob/user = usr)
	if(!targets.len)
		user << "<span class='notice'>No target found in range.</span>"
		return

	var/mob/living/carbon/target = targets[1]

	if(!(target.type in compatible_mobs))
		user << "<span class='notice'>It'd be stupid to curse [target] with a horse's head!</span>"
		return

	if(!(target in oview(range)))//If they are not  in overview after selection.
		user << "<span class='notice'>They are too far away!</span>"
		return

	var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
	magichead.canremove = 0		//curses!
	magichead.flags_inv = null	//so you can still see their face
	magichead.voicechange = 1	//NEEEEIIGHH
	target.visible_message(	"<span class='danger'>[target]'s face  lights up in fire, and after the event a horse's head takes its place!</span>", \
							"<span class='danger'>Your face burns up, and shortly after the fire you realise you have the face of a horse!</span>")
	target.equip_to_slot(magichead, slot_wear_mask)

	flick("e_flash", target.flash)
