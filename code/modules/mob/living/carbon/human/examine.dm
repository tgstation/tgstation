/mob/living/carbon/human/examine(mob/user)
//this is very slightly better than it was because you can use it more places. still can't do \his[src] though.
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()
	var/obscure_name

	if(isliving(user))
		var/mob/living/L = user
		if(L.has_trait(TRAIT_PROSOPAGNOSIA))
			obscure_name = TRUE

	var/msg = "<span class='info'>*---------*\nThis is <EM>[!obscure_name ? name : "Unknown"]</EM>!\n"

	var/list/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))

	//uniform
	if(w_uniform && !(SLOT_W_UNIFORM in obscured))
		//accessory
		var/accessory_msg
		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(U.attached_accessory)
				accessory_msg += " with [icon2html(U.attached_accessory, user)] \a [U.attached_accessory]"

		msg += "[t_He] [t_is] wearing [w_uniform.get_examine_string(user)][accessory_msg].\n"
	//head
	if(head)
		msg += "[t_He] [t_is] wearing [head.get_examine_string(user)] on [t_his] head.\n"
	//suit/armor
	if(wear_suit)
		msg += "[t_He] [t_is] wearing [wear_suit.get_examine_string(user)].\n"
		//suit/armor storage
		if(s_store)
			msg += "[t_He] [t_is] carrying [s_store.get_examine_string(user)] on [t_his] [wear_suit.name].\n"
	//back
	if(back)
		msg += "[t_He] [t_has] [back.get_examine_string(user)] on [t_his] back.\n"

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			msg += "[t_He] [t_is] holding [I.get_examine_string(user)] in [t_his] [get_held_index_name(get_held_index_of_item(I))].\n"

	GET_COMPONENT(FR, /datum/component/forensics)
	//gloves
	if(gloves && !(SLOT_GLOVES in obscured))
		msg += "[t_He] [t_has] [gloves.get_examine_string(user)] on [t_his] hands.\n"
	else if(FR && length(FR.blood_DNA))
		var/hand_number = get_num_arms(FALSE)
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
		msg += "[t_He] [t_has] [belt.get_examine_string(user)] about [t_his] waist.\n"

	//shoes
	if(shoes && !(SLOT_SHOES in obscured))
		msg += "[t_He] [t_is] wearing [shoes.get_examine_string(user)] on [t_his] feet.\n"

	//mask
	if(wear_mask && !(SLOT_WEAR_MASK in obscured))
		msg += "[t_He] [t_has] [wear_mask.get_examine_string(user)] on [t_his] face.\n"

	if (wear_neck && !(SLOT_NECK in obscured))
		msg += "[t_He] [t_is] wearing [wear_neck.get_examine_string(user)] around [t_his] neck.\n"

	//eyes
	if(glasses && !(SLOT_GLASSES in obscured))
		msg += "[t_He] [t_has] [glasses.get_examine_string(user)] covering [t_his] eyes.\n"

	//ears
	if(ears && !(SLOT_EARS in obscured))
		msg += "[t_He] [t_has] [ears.get_examine_string(user)] on [t_his] ears.\n"

	//ID
	if(wear_id)
		msg += "[t_He] [t_is] wearing [wear_id.get_examine_string(user)].\n"

	//Status effects
	msg += status_effect_examines()

	//Jitters
	switch(jitteriness)
		if(300 to INFINITY)
			msg += "<span class='warning'><B>[t_He] [t_is] convulsing violently!</B></span>\n"
		if(200 to 300)
			msg += "<span class='warning'>[t_He] [t_is] extremely jittery.</span>\n"
		if(100 to 200)
			msg += "<span class='warning'>[t_He] [t_is] twitching ever so slightly.</span>\n"

	var/appears_dead = 0
	if(stat == DEAD || (has_trait(TRAIT_FAKEDEATH)))
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

	if(get_bodypart(BODY_ZONE_HEAD) && !getorgan(/obj/item/organ/brain))
		msg += "<span class='deadsay'>It appears that [t_his] brain is missing...</span>\n"

	var/temp = getBruteLoss() //no need to calculate each of these twice

	msg += "<span class='warning'>"

	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/list/disabled = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.disabled)
			disabled += BP
		missing -= BP.body_zone
		for(var/obj/item/I in BP.embedded_objects)
			msg += "<B>[t_He] [t_has] \a [icon2html(I, user)] [I] embedded in [t_his] [BP.name]!</B>\n"

	for(var/X in disabled)
		var/obj/item/bodypart/BP = X
		var/more_brute = BP.brute_dam >= BP.burn_dam
		msg += "<B>[capitalize(t_his)] [BP.name] is [more_brute ? "broken and mangled" : "burnt and blistered"]!</B>\n"

	//stores missing limbs
	var/l_limbs_missing = 0
	var/r_limbs_missing = 0
	for(var/t in missing)
		if(t==BODY_ZONE_HEAD)
			msg += "<span class='deadsay'><B>[t_His] [parse_zone(t)] is missing!</B><span class='warning'>\n"
			continue
		if(t == BODY_ZONE_L_ARM || t == BODY_ZONE_L_LEG)
			l_limbs_missing++
		else if(t == BODY_ZONE_R_ARM || t == BODY_ZONE_R_LEG)
			r_limbs_missing++

		msg += "<B>[capitalize(t_his)] [parse_zone(t)] is missing!</B>\n"

	if(l_limbs_missing >= 2 && r_limbs_missing == 0)
		msg += "[t_He] look[p_s()] all right now.\n"
	else if(l_limbs_missing == 0 && r_limbs_missing >= 2)
		msg += "[t_He] really keeps to the left.\n"
	else if(l_limbs_missing >= 2 && r_limbs_missing >= 2)
		msg += "[t_He] [p_do()]n't seem all there.\n"

	if(!(user == src && src.hal_screwyhud == SCREWYHUD_HEALTHY)) //fake healthy
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor bruising.\n"
			else if(temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> bruising!\n"
			else
				msg += "<B>[t_He] [t_has] severe bruising!</B>\n"

		temp = getFireLoss()
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor burns.\n"
			else if (temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> burns!\n"
			else
				msg += "<B>[t_He] [t_has] severe burns!</B>\n"

		temp = getCloneLoss()
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor cellular damage.\n"
			else if(temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> cellular damage!\n"
			else
				msg += "<b>[t_He] [t_has] severe cellular damage!</b>\n"


	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] look[p_s()] a little soaked.\n"


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
		msg += "[t_He] [t_is] emitting a gentle blue glow!\n"

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
				msg += "[t_He] [t_is] very flushed and [t_his] movements jerky, with breath reeking of alcohol.\n"
			if(61.01 to 91)
				msg += "[t_He] look[p_s()] like a drunken mess.\n"
			if(91.01 to INFINITY)
				msg += "[t_He] [t_is] a shitfaced, slobbering wreck.\n"

	msg += "</span>"

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			msg += "[t_He] [t_is]n't responding to anything around [t_him] and seem[p_s()] to be asleep.\n"
		else
			if(has_trait(TRAIT_DUMB))
				msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"
			if(InCritical())
				msg += "[t_He] [t_is] barely conscious.\n"
		if(getorgan(/obj/item/organ/brain))
			if(!key)
				msg += "<span class='deadsay'>[t_He] [t_is] totally catatonic. The stresses of life in deep-space must have been too much for [t_him]. Any recovery is unlikely.</span>\n"
			else if(!client)
				msg += "[t_He] [t_has] a blank, absent-minded stare and appears completely unresponsive to anything. [t_He] may snap out of it soon.\n"

		if(digitalcamo)
			msg += "[t_He] [t_is] moving [t_his] body in an unnatural and blatantly inhuman manner.\n"

	var/traitstring = get_trait_string()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/cyberimp/eyes/hud/CIH = H.getorgan(/obj/item/organ/cyberimp/eyes/hud)
		if(istype(H.glasses, /obj/item/clothing/glasses/hud) || CIH)
			var/perpname = get_face_name(get_id_name(""))
			if(perpname)
				var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.general)
				if(R)
					msg += "<span class='deptradio'>Rank:</span> [R.fields["rank"]]<br>"
					msg += "<a href='?src=[REF(src)];hud=1;photo_front=1'>\[Front photo\]</a> "
					msg += "<a href='?src=[REF(src)];hud=1;photo_side=1'>\[Side photo\]</a><br>"
				if(istype(H.glasses, /obj/item/clothing/glasses/hud/health) || istype(CIH, /obj/item/organ/cyberimp/eyes/hud/medical))
					var/cyberimp_detect
					for(var/obj/item/organ/cyberimp/CI in internal_organs)
						if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
							cyberimp_detect += "[name] is modified with a [CI.name].<br>"
					if(cyberimp_detect)
						msg += "Detected cybernetic modifications:<br>"
						msg += cyberimp_detect
					if(R)
						var/health_r = R.fields["p_stat"]
						msg += "<a href='?src=[REF(src)];hud=m;p_stat=1'>\[[health_r]\]</a>"
						health_r = R.fields["m_stat"]
						msg += "<a href='?src=[REF(src)];hud=m;m_stat=1'>\[[health_r]\]</a><br>"
					R = find_record("name", perpname, GLOB.data_core.medical)
					if(R)
						msg += "<a href='?src=[REF(src)];hud=m;evaluation=1'>\[Medical evaluation\]</a><br>"
					if(traitstring)
						msg += "<span class='info'>Detected physiological traits:<br></span>"
						msg += "<span class='info'>[traitstring]</span><br>"



				if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(CIH, /obj/item/organ/cyberimp/eyes/hud/security))
					if(!user.stat && user != src)
					//|| !user.canmove || user.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
						var/criminal = "None"

						R = find_record("name", perpname, GLOB.data_core.security)
						if(R)
							criminal = R.fields["criminal"]

						msg += "<span class='deptradio'>Criminal status:</span> <a href='?src=[REF(src)];hud=s;status=1'>\[[criminal]\]</a>\n"
						msg += "<span class='deptradio'>Security record:</span> <a href='?src=[REF(src)];hud=s;view=1'>\[View\]</a> "
						msg += "<a href='?src=[REF(src)];hud=s;add_crime=1'>\[Add crime\]</a> "
						msg += "<a href='?src=[REF(src)];hud=s;view_comment=1'>\[View comment log\]</a> "
						msg += "<a href='?src=[REF(src)];hud=s;add_comment=1'>\[Add comment\]</a>\n"
	else if(isobserver(user) && traitstring)
		msg += "<span class='info'><b>Traits:</b> [traitstring]</span><br>"
	msg += "*---------*</span>"

	to_chat(user, msg)
	return msg

/mob/living/proc/status_effect_examines(pronoun_replacement) //You can include this in any mob's examine() to show the examine texts of status effects!
	var/list/dat = list()
	if(!pronoun_replacement)
		pronoun_replacement = p_they(TRUE)
	for(var/V in status_effects)
		var/datum/status_effect/E = V
		if(E.examine_text)
			var/new_text = replacetext(E.examine_text, "SUBJECTPRONOUN", pronoun_replacement)
			new_text = replacetext(new_text, "[pronoun_replacement] is", "[pronoun_replacement] [p_are()]") //To make sure something become "They are" or "She is", not "They are" and "She are"
			dat += "[new_text]\n" //dat.Join("\n") doesn't work here, for some reason
	if(dat.len)
		return dat.Join()
