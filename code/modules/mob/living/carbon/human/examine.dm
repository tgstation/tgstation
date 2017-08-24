/mob/living/carbon/human/examine(mob/user)
//this is very slightly better than it was because you can use it more places. still can't do \his[src] though.
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()

	var/msg = "<span class='info'>*---------*\nThis is <EM>[src.name]</EM>!\n"

	var/list/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))

	//uniform
	if(w_uniform && !(slot_w_uniform in obscured))
		//accessory
		var/accessory_msg
		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(U.attached_accessory)
				accessory_msg += " with [icon2html(U.attached_accessory, user)] \a [U.attached_accessory]"

		if(LAZYLEN(w_uniform.forensics.blood))
			msg += "<span class='warning'>[t_He] [t_is] wearing [icon2html(w_uniform, user)] [w_uniform.gender==PLURAL?"some":"a"] blood-stained [w_uniform.name][accessory_msg]!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [icon2html(w_uniform, user)] \a [w_uniform][accessory_msg].\n"

	//head
	if(head)
		if(LAZYLEN(head.forensics.blood))
			msg += "<span class='warning'>[t_He] [t_is] wearing [icon2html(head, user)] [head.gender==PLURAL?"some":"a"] blood-stained [head.name] on [t_his] head!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [icon2html(head, user)] \a [head] on [t_his] head.\n"

	//suit/armor
	if(wear_suit)
		if(LAZYLEN(wear_suit.forensics.blood))
			msg += "<span class='warning'>[t_He] [t_is] wearing [icon2html(wear_suit, user)] [wear_suit.gender==PLURAL?"some":"a"] blood-stained [wear_suit.name]!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [icon2html(wear_suit, user)] \a [wear_suit].\n"

		//suit/armor storage
		if(s_store)
			if(LAZYLEN(s_store.forensics.blood))
				msg += "<span class='warning'>[t_He] [t_is] carrying [icon2html(s_store, user)] [s_store.gender==PLURAL?"some":"a"] blood-stained [s_store.name] on [t_his] [wear_suit.name]!</span>\n"
			else
				msg += "[t_He] [t_is] carrying [icon2html(s_store, user)] \a [s_store] on [t_his] [wear_suit.name].\n"

	//back
	if(back)
		if(LAZYLEN(back.forensics.blood))
			msg += "<span class='warning'>[t_He] [t_has] [icon2html(back, user)] [back.gender==PLURAL?"some":"a"] blood-stained [back] on [t_his] back.</span>\n"
		else
			msg += "[t_He] [t_has] [icon2html(back, user)] \a [back] on [t_his] back.\n"

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.flags_1 & ABSTRACT_1))
			if(LAZYLEN(I.forensics.blood))
				msg += "<span class='warning'>[t_He] [t_is] holding [icon2html(I, user)] [I.gender==PLURAL?"some":"a"] blood-stained [I.name] in [t_his] [get_held_index_name(get_held_index_of_item(I))]!</span>\n"
			else
				msg += "[t_He] [t_is] holding [icon2html(I, user)] \a [I] in [t_his] [get_held_index_name(get_held_index_of_item(I))].\n"

	//gloves
	if(gloves && !(slot_gloves in obscured))
		if(LAZYLEN(gloves.forensics.blood))
			msg += "<span class='warning'>[t_He] [t_has] [icon2html(gloves, user)] [gloves.gender==PLURAL?"some":"a"] blood-stained [gloves.name] on [t_his] hands!</span>\n"
		else
			msg += "[t_He] [t_has] [icon2html(gloves, user)] \a [gloves] on [t_his] hands.\n"
	else if(forensics.blood)
		var/hand_number = get_num_arms()
		if(hand_number)
			msg += "<span class='warning'>[t_He] [t_has] [hand_number > 1 ? "" : "a"] blood-stained hand[hand_number > 1 ? "s" : ""]!</span>\n"

	//handcuffed?

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			msg += "<span class='warning'>[t_He] [t_is] [icon2html(handcuffed, user)] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[t_He] [t_is] [icon2html(handcuffed, user)] handcuffed!</span>\n"

	//belt
	if(belt)
		if(LAZYLEN(belt.forensics.blood))
			msg += "<span class='warning'>[t_He] [t_has] [icon2html(belt, user)] [belt.gender==PLURAL?"some":"a"] blood-stained [belt.name] about [t_his] waist!</span>\n"
		else
			msg += "[t_He] [t_has] [icon2html(belt, user)] \a [belt] about [t_his] waist.\n"

	//shoes
	if(shoes && !(slot_shoes in obscured))
		if(LAZYLEN(shoes.forensics.blood))
			msg += "<span class='warning'>[t_He] [t_is] wearing [icon2html(shoes, user)] [shoes.gender==PLURAL?"some":"a"] blood-stained [shoes.name] on [t_his] feet!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [icon2html(shoes, user)] \a [shoes] on [t_his] feet.\n"

	//mask
	if(wear_mask && !(slot_wear_mask in obscured))
		if(LAZYLEN(wear_mask.forensics.blood))
			msg += "<span class='warning'>[t_He] [t_has] [icon2html(wear_mask, user)] [wear_mask.gender==PLURAL?"some":"a"] blood-stained [wear_mask.name] on [t_his] face!</span>\n"
		else
			msg += "[t_He] [t_has] [icon2html(wear_mask, user)] \a [wear_mask] on [t_his] face.\n"

	if (wear_neck && !(slot_neck in obscured))
		msg += "[t_He] [t_is] wearing [icon2html(wear_neck, user)] \a [src.wear_neck] around [t_his] neck.\n"

	//eyes
	if(glasses && !(slot_glasses in obscured))
		if(LAZYLEN(glasses.forensics.blood))
			msg += "<span class='warning'>[t_He] [t_has] [icon2html(glasses, user)] [glasses.gender==PLURAL?"some":"a"] blood-stained [glasses] covering [t_his] eyes!</span>\n"
		else
			msg += "[t_He] [t_has] [icon2html(glasses, user)] \a [glasses] covering [t_his] eyes.\n"

	//ears
	if(ears && !(slot_ears in obscured))
		msg += "[t_He] [t_has] [icon2html(ears, user)] \a [ears] on [t_his] ears.\n"

	//ID
	if(wear_id)
		msg += "[t_He] [t_is] wearing [icon2html(wear_id, user)] \a [wear_id].\n"

	//Jitters
	switch(jitteriness)
		if(300 to INFINITY)
			msg += "<span class='warning'><B>[t_He] [t_is] convulsing violently!</B></span>\n"
		if(200 to 300)
			msg += "<span class='warning'>[t_He] [t_is] extremely jittery.</span>\n"
		if(100 to 200)
			msg += "<span class='warning'>[t_He] [t_is] twitching ever so slightly.</span>\n"

	var/appears_dead = 0
	if(stat == DEAD || (status_flags & FAKEDEATH))
		appears_dead = 1
		if(suiciding)
			msg += "<span class='warning'>[t_He] appear[p_s()] to have committed suicide... there is no hope of recovery.</span>\n"
		if(hellbound)
			msg += "<span class='warning'>[t_His] soul seems to have been ripped out of [t_his] body.  Revival is impossible.</span>\n"
		msg += "<span class='deadsay'>[t_He] [t_is] limp and unresponsive; there are no signs of life"
		if(getorgan(/obj/item/organ/brain))
			if(!key)
				var/foundghost = 0
				if(mind)
					for(var/mob/dead/observer/G in GLOB.player_list)
						if(G.mind == mind)
							foundghost = 1
							if (G.can_reenter_corpse == 0)
								foundghost = 0
							break
				if(!foundghost)
					msg += " and [t_his] soul has departed"
		msg += "...</span>\n"

	if(get_bodypart("head") && !getorgan(/obj/item/organ/brain))
		msg += "<span class='deadsay'>It appears that [t_his] brain is missing...</span>\n"

	var/temp = getBruteLoss() //no need to calculate each of these twice

	msg += "<span class='warning'>"

	var/list/missing = list("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg")
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		missing -= BP.body_zone
		for(var/obj/item/I in BP.embedded_objects)
			msg += "<B>[t_He] [t_has] \a [icon2html(I, user)] [I] embedded in [t_his] [BP.name]!</B>\n"

	//stores missing limbs
	var/l_limbs_missing = 0
	var/r_limbs_missing = 0
	for(var/t in missing)
		if(t=="head")
			msg += "<span class='deadsay'><B>[t_His] [parse_zone(t)] is missing!</B><span class='warning'>\n"
			continue
		if(t == "l_arm" || t == "l_leg")
			l_limbs_missing++
		else if(t == "r_arm" || t == "r_leg")
			r_limbs_missing++

		msg += "<B>[capitalize(t_his)] [parse_zone(t)] is missing!</B>\n"

	if(l_limbs_missing >= 2 && r_limbs_missing == 0)
		msg += "[t_He] looks all right now.\n"
	else if(l_limbs_missing == 0 && r_limbs_missing >= 2)
		msg += "[t_He] really keeps to the left.\n"
	else if(l_limbs_missing >= 2 && r_limbs_missing >= 2)
		msg += "[t_He] doesn't seem all there.\n"

	if(temp)
		if(temp < 30)
			msg += "[t_He] [t_has] minor bruising.\n"
		else
			msg += "<B>[t_He] [t_has] severe bruising!</B>\n"

	temp = getFireLoss()
	if(temp)
		if(temp < 30)
			msg += "[t_He] [t_has] minor burns.\n"
		else
			msg += "<B>[t_He] [t_has] severe burns!</B>\n"

	temp = getCloneLoss()
	if(temp)
		if(temp < 30)
			msg += "[t_He] [t_has] minor cellular damage.\n"
		else
			msg += "<B>[t_He] [t_has] severe cellular damage.</B>\n"


	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] looks a little soaked.\n"


	if(pulledby && pulledby.grab_state)
		msg += "[t_He] [t_is] restrained by [pulledby]'s grip.\n"

	if(nutrition < NUTRITION_LEVEL_STARVING - 50)
		msg += "[t_He] [t_is] severely malnourished.\n"
	else if(nutrition >= NUTRITION_LEVEL_FAT)
		if(user.nutrition < NUTRITION_LEVEL_STARVING - 50)
			msg += "[t_He] [t_is] plump and delicious looking - Like a fat little piggy. A tasty piggy.\n"
		else
			msg += "[t_He] [t_is] quite chubby.\n"
	switch(disgust)
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			msg += "[t_He] look[p_s()] a bit grossed out.\n"
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			msg += "[t_He] look[p_s()] really grossed out.\n"
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			msg += "[t_He] look[p_s()] extremely disgusted.\n"

	if(blood_volume < BLOOD_VOLUME_SAFE)
		msg += "[t_He] [t_has] pale skin.\n"

	if(bleedsuppress)
		msg += "[t_He] [t_is] bandaged with something.\n"
	else if(bleed_rate)
		if(reagents.has_reagent("heparin"))
			msg += "<b>[t_He] [t_is] bleeding uncontrollably!</b>\n"
		else
			msg += "<B>[t_He] [t_is] bleeding!</B>\n"

	if(reagents.has_reagent("teslium"))
		msg += "[t_He] is emitting a gentle blue glow!\n"

	if(islist(stun_absorption))
		for(var/i in stun_absorption)
			if(stun_absorption[i]["end_time"] > world.time && stun_absorption[i]["examine_message"])
				msg += "[t_He] [t_is][stun_absorption[i]["examine_message"]]\n"

	if(drunkenness && !skipface && !appears_dead) //Drunkenness
		switch(drunkenness)
			if(11 to 21)
				msg += "[t_He] [t_is] slightly flushed.\n"
			if(21.01 to 41) //.01s are used in case drunkenness ends up to be a small decimal
				msg += "[t_He] [t_is] flushed.\n"
			if(41.01 to 51)
				msg += "[t_He] [t_is] quite flushed and [t_his] breath smells of alcohol.\n"
			if(51.01 to 61)
				msg += "[t_He] is very flushed and [t_his] movements jerky, with breath reeking of alcohol.\n"
			if(61.01 to 91)
				msg += "[t_He] looks like a drunken mess.\n"
			if(91.01 to INFINITY)
				msg += "[t_He] [t_is] a shitfaced, slobbering wreck.\n"

	msg += "</span>"

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			msg += "[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep.\n"
		else if(getBrainLoss() >= 60)
			msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"

		if(getorgan(/obj/item/organ/brain))
			if(istype(src, /mob/living/carbon/human/interactive))
				var/mob/living/carbon/human/interactive/auto = src
				if(auto.showexaminetext)
					msg += "<span class='deadsay'>[t_He] [t_is] appears to be some sort of sick automaton, [t_his] eyes are glazed over and [t_his] mouth is slightly agape.</span>\n"
				if(auto.debugexamine)
					var/dodebug = auto.doing2string(auto.doing)
					var/interestdebug = auto.interest2string(auto.interest)
					msg += "<span class='deadsay'>[t_He] [t_is] appears to be [interestdebug] and [dodebug].</span>\n"
			else if(!key)
				msg += "<span class='deadsay'>[t_He] [t_is] totally catatonic. The stresses of life in deep-space must have been too much for [t_him]. Any recovery is unlikely.</span>\n"
			else if(!client)
				msg += "[t_He] [t_has] a blank, absent-minded stare and appears completely unresponsive to anything. [t_He] may snap out of it soon.\n"

		if(digitalcamo)
			msg += "[t_He] [t_is] moving [t_his] body in an unnatural and blatantly inhuman manner.\n"

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/cyberimp/eyes/hud/CIH = H.getorgan(/obj/item/organ/cyberimp/eyes/hud)
		if(istype(H.glasses, /obj/item/clothing/glasses/hud) || CIH)
			var/perpname = get_face_name(get_id_name(""))
			if(perpname)
				var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.general)
				if(R)
					msg += "<span class='deptradio'>Rank:</span> [R.fields["rank"]]<br>"
					msg += "<a href='?src=\ref[src];hud=1;photo_front=1'>\[Front photo\]</a> "
					msg += "<a href='?src=\ref[src];hud=1;photo_side=1'>\[Side photo\]</a><br>"
				if(istype(H.glasses, /obj/item/clothing/glasses/hud/health) || istype(CIH, /obj/item/organ/cyberimp/eyes/hud/medical))
					var/cyberimp_detect
					for(var/obj/item/organ/cyberimp/CI in internal_organs)
						if(CI.status == ORGAN_ROBOTIC)
							cyberimp_detect += "[name] is modified with a [CI.name].<br>"
					if(cyberimp_detect)
						msg += "Detected cybernetic modifications:<br>"
						msg += cyberimp_detect
					if(R)
						var/health_r = R.fields["p_stat"]
						msg += "<a href='?src=\ref[src];hud=m;p_stat=1'>\[[health_r]\]</a>"
						health_r = R.fields["m_stat"]
						msg += "<a href='?src=\ref[src];hud=m;m_stat=1'>\[[health_r]\]</a><br>"
					R = find_record("name", perpname, GLOB.data_core.medical)
					if(R)
						msg += "<a href='?src=\ref[src];hud=m;evaluation=1'>\[Medical evaluation\]</a><br>"


				if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(CIH, /obj/item/organ/cyberimp/eyes/hud/security))
					if(!user.stat && user != src)
					//|| !user.canmove || user.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
						var/criminal = "None"

						R = find_record("name", perpname, GLOB.data_core.security)
						if(R)
							criminal = R.fields["criminal"]

						msg += "<span class='deptradio'>Criminal status:</span> <a href='?src=\ref[src];hud=s;status=1'>\[[criminal]\]</a>\n"
						msg += "<span class='deptradio'>Security record:</span> <a href='?src=\ref[src];hud=s;view=1'>\[View\]</a> "
						msg += "<a href='?src=\ref[src];hud=s;add_crime=1'>\[Add crime\]</a> "
						msg += "<a href='?src=\ref[src];hud=s;view_comment=1'>\[View comment log\]</a> "
						msg += "<a href='?src=\ref[src];hud=s;add_comment=1'>\[Add comment\]</a>\n"
	msg += "*---------*</span>"

	to_chat(user, msg)
