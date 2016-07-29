/spell/targeted/equip_item/horsemask
	name = "Curse of the Horseman"
	desc = "This spell triggers a curse on a target, causing them to wield an unremovable horse head mask. They will speak like a horse! Any masks they are wearing will be disintegrated. This spell does not require robes."
	school = "transmutation"
	charge_type = Sp_RECHARGE
	charge_max = 150
	charge_counter = 0
	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = SpI_SHOUT
	range = 7
	max_targets = 1
	cooldown_min = 30 //30 deciseconds reduction per rank
	selection_type = "range"

	compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

	hud_state = "wiz_horse"

/spell/targeted/equip_item/horsemask/New()
	..()
	equipped_summons = list("[slot_wear_mask]" = /obj/item/clothing/mask/horsehead)

/spell/targeted/equip_item/horsemask/cast(list/targets, mob/user = usr)
	..()
	for(var/mob/living/target in targets)
		target.visible_message(	"<span class='danger'>[target]'s face lights up in fire, and after the event a horse's head takes its place!</span>", \
								"<span class='danger'>Your face burns up, and shortly after the fire you realise you have the face of a horse!</span>")
		target.flash_eyes(visual = 1)

/spell/targeted/equip_item/horsemask/summon_item(var/new_type)
	var/obj/item/new_item = new new_type
	if(istype(new_item, /obj/item/clothing/mask/horsehead))
		var/obj/item/clothing/mask/horsehead/magichead = new_item
		magichead.canremove = 0		//curses!
		magichead.voicechange = 1	//NEEEEIIGHH
	return new_item
