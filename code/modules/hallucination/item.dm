/* Item Hallucinations
 *
 * Contains:
 * Putting items in other nearby peoples hands
 * Putting items in your hands
 */

/datum/hallucination/items_other

/datum/hallucination/items_other/New(mob/living/carbon/C, forced = TRUE, item_type)
	set waitfor = FALSE
	..()
	var/item
	if(!item_type)
		item = pick(list("esword","taser","ebow","baton","dual_esword","ttv","flash","armblade"))
	else
		item = item_type
	feedback_details += "Item: [item]"
	var/side
	var/image_file
	var/image/A = null
	var/list/mob_pool = list()

	for(var/mob/living/carbon/human/M in view(7,target))
		if(M != target)
			mob_pool += M
	if(!mob_pool.len)
		return

	var/mob/living/carbon/human/H = pick(mob_pool)
	feedback_details += " Mob: [H.real_name]"

	var/free_hand = H.get_empty_held_index_for_side(LEFT_HANDS)
	if(free_hand)
		side = "left"
	else
		free_hand = H.get_empty_held_index_for_side(RIGHT_HANDS)
		if(free_hand)
			side = "right"

	if(side)
		switch(item)
			if("esword")
				if(side == "right")
					image_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
				target.playsound_local(H, 'sound/weapons/saberon.ogg',35,1)
				A = image(image_file,H,"e_sword_on_red", layer=ABOVE_MOB_LAYER)
			if("dual_esword")
				if(side == "right")
					image_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
				target.playsound_local(H, 'sound/weapons/saberon.ogg',35,1)
				A = image(image_file,H,"dualsaberred1", layer=ABOVE_MOB_LAYER)
			if("taser")
				if(side == "right")
					image_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
				A = image(image_file,H,"advtaserstun4", layer=ABOVE_MOB_LAYER)
			if("ebow")
				if(side == "right")
					image_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
				A = image(image_file,H,"crossbow", layer=ABOVE_MOB_LAYER)
			if("baton")
				if(side == "right")
					image_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
				target.playsound_local(H, SFX_SPARKS,75,1,-1)
				A = image(image_file,H,"baton", layer=ABOVE_MOB_LAYER)
			if("ttv")
				if(side == "right")
					image_file = 'icons/mob/inhands/weapons/bombs_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/weapons/bombs_lefthand.dmi'
				A = image(image_file,H,"ttv", layer=ABOVE_MOB_LAYER)
			if("flash")
				if(side == "right")
					image_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
				A = image(image_file,H,"flashtool", layer=ABOVE_MOB_LAYER)
			if("armblade")
				if(side == "right")
					image_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
				target.playsound_local(H, 'sound/effects/blobattack.ogg',30,1)
				A = image(image_file,H,"arm_blade", layer=ABOVE_MOB_LAYER)
		if(target.client)
			target.client.images |= A
			addtimer(CALLBACK(src, .proc/cleanup, item, A, H), rand(15 SECONDS, 25 SECONDS))
			return
	qdel(src)

/datum/hallucination/items_other/proc/cleanup(item, atom/image_used, has_the_item)
	if (isnull(target))
		qdel(src)
		return
	if(item == "esword" || item == "dual_esword")
		target.playsound_local(has_the_item, 'sound/weapons/saberoff.ogg',35,1)
	if(item == "armblade")
		target.playsound_local(has_the_item, 'sound/effects/blobattack.ogg',30,1)
	target.client.images.Remove(image_used)
	qdel(src)

/datum/hallucination/items/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	//Strange items

	var/obj/halitem = new

	halitem = new
	var/obj/item/l_hand = target.get_item_for_held_index(1)
	var/obj/item/r_hand = target.get_item_for_held_index(2)
	var/l = ui_hand_position(target.get_held_index_of_item(l_hand))
	var/r = ui_hand_position(target.get_held_index_of_item(r_hand))
	var/list/slots_free = list(l,r)
	if(l_hand)
		slots_free -= l
	if(r_hand)
		slots_free -= r
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!H.belt)
			slots_free += ui_belt
		if(!H.l_store)
			slots_free += ui_storage1
		if(!H.r_store)
			slots_free += ui_storage2
	if(slots_free.len)
		halitem.screen_loc = pick(slots_free)
		halitem.plane = ABOVE_HUD_PLANE
		switch(rand(1,6))
			if(1) //revolver
				halitem.icon = 'icons/obj/guns/ballistic.dmi'
				halitem.icon_state = "revolver"
				halitem.name = "Revolver"
			if(2) //c4
				halitem.icon = 'icons/obj/grenade.dmi'
				halitem.icon_state = "plastic-explosive0"
				halitem.name = "C4"
				if(prob(25))
					halitem.icon_state = "plasticx40"
			if(3) //sword
				halitem.icon = 'icons/obj/transforming_energy.dmi'
				halitem.icon_state = "e_sword"
				halitem.name = "energy sword"
			if(4) //stun baton
				halitem.icon = 'icons/obj/items_and_weapons.dmi'
				halitem.icon_state = "stunbaton"
				halitem.name = "Stun Baton"
			if(5) //emag
				halitem.icon = 'icons/obj/card.dmi'
				halitem.icon_state = "emag"
				halitem.name = "Cryptographic Sequencer"
			if(6) //flashbang
				halitem.icon = 'icons/obj/grenade.dmi'
				halitem.icon_state = "flashbang1"
				halitem.name = "Flashbang"
		feedback_details += "Type: [halitem.name]"
		if(target.client)
			target.client.screen += halitem
		QDEL_IN(halitem, rand(150, 350))

	qdel(src)
