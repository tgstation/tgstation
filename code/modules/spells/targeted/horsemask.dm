/spell/targeted/horsemask
	name = "Curse of the Horseman"
	desc = "This spell triggers a curse on a target, causing them to wield an unremovable horse head mask. They will speak like a horse! Any masks they are wearing will be disintegrated. This spell does not require robes."
	school = "transmutation"
	charge_type = Sp_RECHARGE
	charge_max = 150
	charge_counter = 0
	spell_flags = 0
	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = SpI_SHOUT
	range = 7
	max_targets = 1
	cooldown_min = 30 //30 deciseconds reduction per rank
	selection_type = "range"

	compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

	hud_state = "wiz_horse"

/spell/targeted/horsemask/cast(list/targets, mob/user = usr)
	..()
	for(var/mob/living/target in targets)
		var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
		magichead.canremove = 0		//curses!
		magichead.flags_inv = null	//so you can still see their face
		magichead.voicechange = 1	//NEEEEIIGHH
		target.visible_message(	"<span class='danger'>[target]'s face  lights up in fire, and after the event a horse's head takes its place!</span>", \
								"<span class='danger'>Your face burns up, and shortly after the fire you realise you have the face of a horse!</span>")
		var/obj/old_mask = target.wear_mask
		if(old_mask)
			target.drop_from_inventory(old_mask)
			qdel(old_mask) //get rid of this shit
		target.equip_to_slot_if_possible(magichead, slot_wear_mask, 1, 1)

		flick("e_flash", target.flash)