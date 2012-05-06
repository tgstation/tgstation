/mob/living/carbon/human/tajaran
	name = "tajaran"
	real_name = "tajaran"
	voice_name = "tajaran"
	icon = 'tajaran.dmi'
	icon_state = "m-none"
	var/list/tajspeak_letters
	//
	universal_speak = 1 //hacky fix until someone can figure out how to make them only understand humans
	taj_talk_understand = 1
	voice_message = "mrowls"
	examine_text = "one of the cat-like Tajarans."

/mob/living/carbon/human/tajaran/New()
	tajspeak_letters = new/list("~","*","-")

	var/g = "m"
	if (gender == FEMALE)
		g = "f"

	spawn (1)
		if(!stand_icon)
			stand_icon = new /icon('tajaran.dmi', "body_[g]_s")
		if(!lying_icon)
			lying_icon = new /icon('tajaran.dmi', "body_[g]_l")
		icon = stand_icon
		update_clothing()
		src << "\blue Your icons have been generated!"

	..()

/mob/living/carbon/human/tajaran/update_clothing()
	..()

	if (monkeyizing)
		return

	overlays = null

	// lol
	var/fat = ""
	/*if (mutations & FAT)
		fat = "fat"*/
/*
	if (mutations & HULK)
		overlays += image("icon" = 'genetics.dmi', "icon_state" = "hulk[fat][!lying ? "_s" : "_l"]")
*/
	if (mutations & COLD_RESISTANCE)
		overlays += image("icon" = 'genetics.dmi', "icon_state" = "fire[fat][!lying ? "_s" : "_l"]")

	if (mutations & TK)
		overlays += image("icon" = 'genetics.dmi', "icon_state" = "telekinesishead[fat][!lying ? "_s" : "_l"]")

	if (mutations & LASER)
		overlays += image("icon" = 'genetics.dmi', "icon_state" = "lasereyes[!lying ? "_s" : "_l"]")

	if (mutantrace)
		switch(mutantrace)
			if("golem","metroid")
				overlays += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace][fat][!lying ? "_s" : "_l"]")
				if(face_standing)
					del(face_standing)
				if(face_lying)
					del(face_lying)
				if(stand_icon)
					del(stand_icon)
				if(lying_icon)
					del(lying_icon)
			if("lizard")
				overlays += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace][fat]_[gender][!lying ? "_s" : "_l"]")
				if(face_standing)
					del(face_standing)
				if(face_lying)
					del(face_lying)
				if(stand_icon)
					del(stand_icon)
				if(lying_icon)
					del(lying_icon)
			if("plant")
				if(stat != 2) //if not dead, that is
					overlays += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace][fat]_[gender][!lying ? "_s" : "_l"]")
				else
					overlays += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace]_d")
				if(face_standing)
					del(face_standing)
				if(face_lying)
					del(face_lying)
				if(stand_icon)
					del(stand_icon)
				if(lying_icon)
					del(lying_icon)
	else
		if(!face_standing || !face_lying)
			update_face()
		if(!stand_icon || !lying_icon)
			update_body()

	if(buckled)
		if(istype(buckled, /obj/structure/stool/bed))
			lying = 1
		else
			lying = 0

	// Automatically drop anything in store / id / belt if you're not wearing a uniform.
	if (!w_uniform)
		for (var/obj/item/thing in list(r_store, l_store, wear_id, belt))
			if (thing)
				u_equip(thing)
				if (client)
					client.screen -= thing

				if (thing)
					thing.loc = loc
					thing.dropped(src)
					thing.layer = initial(thing.layer)


	//if (zone_sel)
	//	zone_sel.overlays = null
	//	zone_sel.overlays += body_standing
	//	zone_sel.overlays += image("icon" = 'zone_sel.dmi', "icon_state" = text("[]", zone_sel.selecting))

	if (lying)
		icon = lying_icon

		overlays += body_lying

		if (face_lying)
			overlays += face_lying
	else
		icon = stand_icon

		overlays += body_standing

		if (face_standing)
			overlays += face_standing

	// Uniform
	if(w_uniform)
		/*if (mutations & FAT && !(w_uniform.flags & ONESIZEFITSALL))
			src << "\red You burst out of the [w_uniform.name]!"
			var/obj/item/clothing/c = w_uniform
			u_equip(c)
			if(client)
				client.screen -= c
			if(c)
				c:loc = loc
				c:dropped(src)
				c:layer = initial(c:layer)*/
		if(w_uniform)//I should really not need these
			w_uniform.screen_loc = ui_iclothing
		if(istype(w_uniform, /obj/item/clothing/under))
			var/t1 = w_uniform.color
			if (!t1)
				t1 = icon_state
			/*if (mutations & FAT)
				overlays += image("icon" = 'uniform_fat.dmi', "icon_state" = "[t1][!lying ? "_s" : "_l"]", "layer" = MOB_LAYER)
			else*/
			overlays += image("icon" = 'uniform.dmi', "icon_state" = text("[][]",t1, (!(lying) ? "_s" : "_l")), "layer" = MOB_LAYER)
			if (w_uniform.blood_DNA)
				var/icon/stain_icon = icon('blood.dmi', "uniformblood[!lying ? "" : "2"]")
				overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)

	if (wear_id)
		if(wear_id.over_jumpsuit)
			overlays += image("icon" = 'mob.dmi', "icon_state" = "id[!lying ? null : "2"]", "layer" = MOB_LAYER)

	if (client)
		client.screen -= hud_used.intents
		client.screen -= hud_used.mov_int


	//Screenlocs for these slots are handled by the huds other_update()
	//because theyre located on the 'other' inventory bar.

	// Gloves
	var/datum/organ/external/lo = organs["l_hand"]
	var/datum/organ/external/ro = organs["r_hand"]
	if (!lo.destroyed || !ro.destroyed)
		if (gloves)
			var/t1 = gloves.item_state
			if (!t1)
				t1 = gloves.icon_state
			var/icon/gloves_icon = new /icon("icon" = 'hands.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")))
			if(lo.destroyed)
				gloves_icon.Blend(new /icon('limb_mask.dmi', "right_[lying?"l":"s"]"), ICON_MULTIPLY)
			else if(ro.destroyed)
				gloves_icon.Blend(new /icon('limb_mask.dmi', "left_[lying?"l":"s"]"), ICON_MULTIPLY)
			overlays += image(gloves_icon, "layer" = MOB_LAYER)
			if (gloves.blood_DNA)
				var/icon/stain_icon = icon('blood.dmi', "bloodyhands[!lying ? "" : "2"]")
				if(lo.destroyed)
					stain_icon.Blend(new /icon('limb_mask.dmi', "right_[lying?"l":"s"]"), ICON_MULTIPLY)
				else if(ro.destroyed)
					stain_icon.Blend(new /icon('limb_mask.dmi', "left_[lying?"l":"s"]"), ICON_MULTIPLY)
				overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
		else if (blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "bloodyhands[!lying ? "" : "2"]")
			if(lo.destroyed)
				stain_icon.Blend(new /icon('limb_mask.dmi', "right_[lying?"l":"s"]"), ICON_MULTIPLY)
			else if(ro.destroyed)
				stain_icon.Blend(new /icon('limb_mask.dmi', "left_[lying?"l":"s"]"), ICON_MULTIPLY)
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
	// Glasses
	if (glasses)
		var/t1 = glasses.icon_state
		overlays += image("icon" = 'eyes.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
	// Ears
	if (l_ear)
		var/t1 = l_ear.icon_state
		overlays += image("icon" = 'ears.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
	if (r_ear)
		var/t1 = r_ear.icon_state
		overlays += image("icon" = 'ears.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
	// Shoes
	lo = organs["l_foot"]
	ro = organs["r_foot"]
	if ((!lo.destroyed || !ro.destroyed) && shoes)
		var/t1 = shoes.icon_state
		var/icon/shoes_icon = new /icon("icon" = 'feet.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")))
		if(lo.destroyed && !lying)
			shoes_icon.Blend(new /icon('limb_mask.dmi', "right[lying?"_l":""]"), ICON_MULTIPLY)
		else if(ro.destroyed && !lying)
			shoes_icon.Blend(new /icon('limb_mask.dmi', "left[lying?"_l":""]"), ICON_MULTIPLY)
		overlays += image(shoes_icon, "layer" = MOB_LAYER)
		if (shoes.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "shoesblood[!lying ? "" : "2"]")
			if(lo.destroyed)
				stain_icon.Blend(new /icon('limb_mask.dmi', "right_[lying?"l":"s"]"), ICON_MULTIPLY)
			else if(ro.destroyed)
				stain_icon.Blend(new /icon('limb_mask.dmi', "left_[lying?"l":"s"]"), ICON_MULTIPLY)
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)	// Radio
/*	if (w_radio)
		overlays += image("icon" = 'ears.dmi', "icon_state" = "headset[!lying ? "" : "2"]", "layer" = MOB_LAYER) */

	if (s_store)
		var/t1 = s_store.item_state
		if (!t1)
			t1 = s_store.icon_state
		if(!istype(wear_suit, /obj/item/clothing/suit/storage/armoredundersuit))
			overlays += image("icon" = 'belt_mirror.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		s_store.screen_loc = ui_sstore1

	if (h_store)
		h_store.screen_loc = ui_hstore1

	if(client) hud_used.other_update() //Update the screenloc of the items on the 'other' inventory bar
											   //to hide / show them.
	if (client)
		if (i_select)
			if (intent)
				client.screen += hud_used.intents

				var/list/L = dd_text2list(intent, ",")
				L[1] += ":-11"
				i_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				i_select.screen_loc = null
		if (m_select)
			if (m_int)
				client.screen += hud_used.mov_int

				var/list/L = dd_text2list(m_int, ",")
				L[1] += ":-11"
				m_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				m_select.screen_loc = null

	var/tail_shown = 1
	if (wear_suit)
		/*if (mutations & FAT && !(wear_suit.flags & ONESIZEFITSALL))
			src << "\red You burst out of the [wear_suit.name]!"
			var/obj/item/clothing/c = wear_suit
			u_equip(c)
			if(client)
				client.screen -= c
			if(c)
				c:loc = loc
				c:dropped(src)
				c:layer = initial(c:layer)*/
		if (istype(wear_suit, /obj/item/clothing/suit))
			var/t1 = wear_suit.icon_state
			overlays += image("icon" = 'suit.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (wear_suit)
			if (wear_suit.blood_DNA)
				var/icon/stain_icon = null
				if (istype(wear_suit, /obj/item/clothing/suit/armor/vest || /obj/item/clothing/suit/storage/wcoat))
					stain_icon = icon('blood.dmi', "armorblood[!lying ? "" : "2"]")
				else if (istype(wear_suit, /obj/item/clothing/suit/storage/det_suit || /obj/item/clothing/suit/storage/labcoat))
					stain_icon = icon('blood.dmi', "coatblood[!lying ? "" : "2"]")
				else
					stain_icon = icon('blood.dmi', "suitblood[!lying ? "" : "2"]")
				overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
			wear_suit.screen_loc = ui_oclothing
		if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			if (handcuffed)
				handcuffed.loc = loc
				handcuffed.layer = initial(handcuffed.layer)
				handcuffed = null
			if ((l_hand || r_hand))
				var/h = hand
				hand = 1
				drop_item()
				hand = 0
				drop_item()
				hand = h
		//if wearing some suits, hide the tail
		if ( istype(wear_suit, /obj/item/clothing/suit/bio_suit) || istype(wear_suit, /obj/item/clothing/suit/bomb_suit) || istype(wear_suit, /obj/item/clothing/suit/space) )
			tail_shown = 0
	if(tail_shown)
		overlays += image("icon" = icon('tajaran.dmi', "tail_[gender==FEMALE ? "f" : "m"]_[lying ? "l" : "s"]"), "layer" = MOB_LAYER)

	if (lying)
		if (face_lying)
			overlays += face_lying
	else
		if (face_standing)
			overlays += face_standing

	if (wear_mask)
		if (istype(wear_mask, /obj/item/clothing/mask))
			var/t1 = wear_mask.icon_state
			overlays += image("icon" = 'mask.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
			if (!istype(wear_mask, /obj/item/clothing/mask/cigarette))
				if (wear_mask.blood_DNA)
					var/icon/stain_icon = icon('blood.dmi', "maskblood[!lying ? "" : "2"]")
					overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
			wear_mask.screen_loc = ui_mask

	// Head
	if (head)
		var/t1 = head.icon_state
		var/icon/head_icon = icon('head.dmi', text("[][]", t1, (!( lying ) ? null : "2")))
		if(istype(head,/obj/item/clothing/head/kitty))
			head_icon = (( lying ) ? head:mob2 : head:mob)
		overlays += image("icon" = head_icon, "layer" = MOB_LAYER)
		if(gimmick_hat)
			overlays += image("icon" = icon('gimmick_head.dmi', "[gimmick_hat][!lying ? "" : "2"]"), "layer" = MOB_LAYER)
		if (head.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "helmetblood[!lying ? "" : "2"]")
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
		head.screen_loc = ui_head
	else
		var/datum/organ/external/head = organs["head"]
		if(!head.destroyed)
		//if not wearing anything on the head, show the ears
			overlays += image("icon" = icon('tajaran.dmi', "ears_[gender==FEMALE ? "f" : "m"]_[lying ? "l" : "s"]"), "layer" = MOB_LAYER)

	// Belt
	if (belt)
		var/t1 = belt.item_state
		if (!t1)
			t1 = belt.icon_state
		overlays += image("icon" = 'belt.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		belt.screen_loc = ui_belt

	if ((wear_mask && !(wear_mask.see_face)) || (head && !(head.see_face))) // can't see the face
		if (wear_id)
			if (istype(wear_id, /obj/item/weapon/card/id))
				var/obj/item/weapon/card/id/id = wear_id
				if (id.registered_name)
					name = id.registered_name
				else
					name = "Unknown"
			else if (istype(wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = wear_id
				if (pda.owner)
					name = pda.owner
				else
					name = "Unknown"
		else
			name = "Unknown"
	else
		if (wear_id)
			if (istype(wear_id, /obj/item/weapon/card/id))
				var/obj/item/weapon/card/id/id = wear_id
				if (id.registered_name != real_name)
					name = "[real_name] (as [id.registered_name])"


			else if (istype(wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = wear_id
				if (pda.owner)
					if (pda.owner != real_name)
						name = "[real_name] (as [pda.owner])"
		else
			name = real_name

	if (wear_id)
		wear_id.screen_loc = ui_id

	if (l_store)
		l_store.screen_loc = ui_storage1

	if (r_store)
		r_store.screen_loc = ui_storage2

	if (back)
		var/t1 = back.icon_state
		overlays += image("icon" = 'back.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		back.screen_loc = ui_back

	if (handcuffed)
		pulling = null
		if (!lying)
			overlays += image("icon" = 'mob.dmi', "icon_state" = "handcuff1", "layer" = MOB_LAYER)
		else
			overlays += image("icon" = 'mob.dmi', "icon_state" = "handcuff2", "layer" = MOB_LAYER)

	if (client)
		client.screen -= contents
		client.screen += contents

	if (r_hand)
		overlays += image("icon" = 'items_righthand.dmi', "icon_state" = r_hand.item_state ? r_hand.item_state : r_hand.icon_state, "layer" = MOB_LAYER+1)

		r_hand.screen_loc = ui_rhand

	if (l_hand)
		overlays += image("icon" = 'items_lefthand.dmi', "icon_state" = l_hand.item_state ? l_hand.item_state : l_hand.icon_state, "layer" = MOB_LAYER+1)

		l_hand.screen_loc = ui_lhand

	var/shielded = 0
	for (var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 2
			break

	if(istype(wear_suit, /obj/item/clothing/suit/space/space_ninja)&&wear_suit:s_active)
		shielded = 3

	switch(shielded)
		if(1)
			overlays += image("icon" = 'effects.dmi', "icon_state" = "shield", "layer" = MOB_LAYER+1)
		if(2)
			invisibility = 2
			//New stealth. Hopefully doesn't lag too much. /N
			if(istype(loc, /turf))//If they are standing on a turf.
				AddCamoOverlay(loc)//Overlay camo.
		if(3)
			if(istype(loc, /turf))
			//Ninjas may flick into view once in a while if they are stealthed.
				if(prob(90))
					NinjaStealthActive(loc)
				else
					NinjaStealthMalf()
		else
			invisibility = 0

	if(client && client.admin_invis)
		invisibility = 100
	else if (shielded == 2)
		invisibility = 2
	else
		invisibility = 0
		if(targeted_by && target_locked)
			overlays += target_locked
		else if(targeted_by)
			target_locked = new /obj/effect/target_locked(src)
			overlays += target_locked
		else if(!targeted_by && target_locked)
			del(target_locked)

/*
	for (var/mob/M in viewers(1, src))//For the love of god DO NOT REFRESH EVERY SECOND - Mport
		if ((M.client && M.machine == src))
			spawn (0)
				show_inv(M)
				return
*/
	last_b_state = stat

/mob/living/carbon/human/tajaran/update_body()
	if(stand_icon)
		del(stand_icon)
	if(lying_icon)
		del(lying_icon)

	if (mutantrace)
		return

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"

	stand_icon = new /icon('tajaran.dmi', "torso_[g]_s")
	lying_icon = new /icon('tajaran.dmi', "torso_[g]_l")



	var/husk = (mutations & HUSK)
	//var/obese = (mutations & FAT)

	stand_icon.Blend(new /icon('tajaran.dmi', "chest_[g]_s"), ICON_OVERLAY)
	lying_icon.Blend(new /icon('tajaran.dmi', "chest_[g]_l"), ICON_OVERLAY)

	var/datum/organ/external/head = organs["head"]
	if(!head.destroyed)
		stand_icon.Blend(new /icon('tajaran.dmi', "head_[g]_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('tajaran.dmi', "head_[g]_l"), ICON_OVERLAY)

	for(var/name in organs)
		var/datum/organ/external/part = organs[name]
		if(!istype(part, /datum/organ/external/groin) \
			&& !istype(part, /datum/organ/external/chest) \
			&& !istype(part, /datum/organ/external/head) \
			&& !part.destroyed)
			var/icon/temp = new /icon('tajaran.dmi', "[part.icon_name]_s")
			if(part.robot) temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
			stand_icon.Blend(temp, ICON_OVERLAY)
			temp = new /icon('tajaran.dmi', "[part.icon_name]_l")
			if(part.robot) temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
			lying_icon.Blend(temp , ICON_OVERLAY)

	stand_icon.Blend(new /icon('tajaran.dmi', "groin_[g]_s"), ICON_OVERLAY)
	lying_icon.Blend(new /icon('tajaran.dmi', "groin_[g]_l"), ICON_OVERLAY)

	if (husk)
		var/icon/husk_s = new /icon('tajaran.dmi', "husk_s")
		var/icon/husk_l = new /icon('tajaran.dmi', "husk_l")

		for(var/name in organs)
			var/datum/organ/external/part = organs[name]
			if(!istype(part, /datum/organ/external/groin) \
				&& !istype(part, /datum/organ/external/chest) \
				&& !istype(part, /datum/organ/external/head) \
				&& part.destroyed)
				husk_s.Blend(new /icon('dam_mask.dmi', "[part.icon_name]"), ICON_SUBTRACT)
				husk_l.Blend(new /icon('dam_mask.dmi', "[part.icon_name]2"), ICON_SUBTRACT)

		stand_icon.Blend(husk_s, ICON_OVERLAY)
		lying_icon.Blend(husk_l, ICON_OVERLAY)
	/*else if(obese)
		stand_icon.Blend(new /icon('human.dmi', "fatbody_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('human.dmi', "fatbody_l"), ICON_OVERLAY)*/

	// Skin tone
	if (s_tone >= 0)
		stand_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		lying_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
	else
		stand_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)
		lying_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

	if (underwear > 0)
		//if(!obese)
		stand_icon.Blend(new /icon('tajaran.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('tajaran.dmi', "underwear[underwear]_[g]_l"), ICON_OVERLAY)


/mob/living/carbon/human/tajaran/update_face()
	if(organs)
		var/datum/organ/external/head = organs["head"]
		if(head)
			if(head.destroyed)
				del(face_standing)
				del(face_lying)
				return

	//if(!facial_hair_style || !hair_style)	return//Seems people like to lose their icons, this should stop the runtimes for now
	del(face_standing)
	del(face_lying)

	if (mutantrace)
		return

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"

	var/icon/eyes_s = new/icon("icon" = 'tajaran_face.dmi', "icon_state" = "eyes_s")
	var/icon/eyes_l = new/icon("icon" = 'tajaran_face.dmi', "icon_state" = "eyes_l")
	eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
	eyes_l.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)

	//var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
	//var/icon/hair_l = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_l")
	//hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
	//hair_l.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)

	//var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
	//var/icon/facial_l = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_l")
	//facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
	//facial_l.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)

	var/icon/mouth_s = new/icon("icon" = 'tajaran_face.dmi', "icon_state" = "mouth_[g]_s")
	var/icon/mouth_l = new/icon("icon" = 'tajaran_face.dmi', "icon_state" = "mouth_[g]_l")

	// if the head or mask has the flag BLOCKHAIR (equal to 5), then do not apply hair
	//if((!(head && (head.flags & BLOCKHAIR))) && !(wear_mask && (wear_mask.flags & BLOCKHAIR)))
		//eyes_s.Blend(hair_s, ICON_OVERLAY)
		//eyes_l.Blend(hair_l, ICON_OVERLAY)

	eyes_s.Blend(mouth_s, ICON_OVERLAY)
	eyes_l.Blend(mouth_l, ICON_OVERLAY)

	// if BLOCKHAIR, do not apply facial hair
	//if((!(head && (head.flags & BLOCKHAIR))) && !(wear_mask && (wear_mask.flags & BLOCKHAIR)))
		//eyes_s.Blend(facial_s, ICON_OVERLAY)
		//eyes_l.Blend(facial_l, ICON_OVERLAY)


	face_standing = new /image()
	face_lying = new /image()
	face_standing.icon = eyes_s
	face_standing.layer = MOB_LAYER
	face_lying.icon = eyes_l
	face_lying.layer = MOB_LAYER

	del(mouth_l)
	del(mouth_s)
	//del(facial_l)
	//del(facial_s)
	//del(hair_l)
	//del(hair_s)
	del(eyes_l)
	del(eyes_s)

/mob/living/carbon/human/tajaran/co2overloadtime = null
/mob/living/carbon/human/tajaran/temperature_resistance = T0C+70

//I just need this for some vars, please don't hurt me. -- Erthilo

/mob/living/carbon/human/tajaran/Emissary/
	unacidable = 1
	var/aegis = 1

/mob/living/carbon/human/tajaran/Emissary/New()

	..()

	reagents.add_reagent("hyperzine", 5000)		//From the dark, to the light, it's a supersonic flight!
													// Gotta keep it going!
	if (!(mutations & HULK))
		mutations |= HULK

	if (!(mutations & LASER))
		mutations |= LASER

	if (!(mutations & XRAY))
		mutations |= XRAY
		sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
		see_in_dark = 8
		see_invisible = 2

	if (!(mutations & COLD_RESISTANCE))
		mutations |= COLD_RESISTANCE

	if (!(mutations & TK))
		mutations |= TK

	if(!(mutations & HEAL))
		mutations |= HEAL

	spawn(0)
		while(src)
			adjustBruteLoss(-10)
			adjustToxLoss(-10)
			adjustOxyLoss(-10)
			adjustFireLoss(-10)
			sleep(10)


/mob/living/carbon/human/tajaran/Emissary/ex_act()
	return

/mob/living/carbon/human/tajaran/Emissary/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	if(istype(target , /obj/machinery/door/airlock))
		if(target:locked)
			target:locked = 0
		if(!target:density)
			return 1
		if(target:operating > 0)
			return
		if(!ticker)
			return 0
		if(!target:operating)
			target:operating = 1

		target:animate("opening")
		target:sd_SetOpacity(0)
		sleep(10)
		target:layer = 2.7
		target:density = 0
		target:update_icon()
		target:sd_SetOpacity(0)
		target:update_nearby_tiles()

		target:operating = -1

		user << "You force the door open, shearing the bolts and burning out the motor."

		if(target:operating)
			target:operating = -1
	else if(istype(target , /obj/machinery/door/firedoor))
		target:open()

/mob/living/carbon/human/tajaran/Emissary/Life()

	..()

	if (!(mutations & HULK))
		mutations |= HULK


	if((stat == 2) && aegis)
		src.show_message("\red [src]'s eyes open suddenlly.", 3, "\red \"I gave a solemn vow to never die for long.\"", 2)
		src.heal_overall_damage(9001,9001)
		src.stat = 0
		aegis = 0