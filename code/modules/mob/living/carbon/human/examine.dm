/mob/living/carbon/human/examine(mob/user)
//this is very slightly better than it was because you can use it more places. still can't do \his[src] though.
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()
	var/obscure_name
	var/obscure_examine

	if(isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_PROSOPAGNOSIA) || HAS_TRAIT(L, TRAIT_INVISIBLE_MAN))
			obscure_name = TRUE
		if(HAS_TRAIT(src, TRAIT_UNKNOWN))
			obscure_name = TRUE
			obscure_examine = TRUE

	. = list("<span class='info'>This is <EM>[!obscure_name ? name : "Unknown"]</EM>!")

	if(obscure_examine)
		return list("<span class='warning'>You're struggling to make out any details...")

	var/obscured = check_obscured_slots()

	//uniform
	if(w_uniform && !(obscured & ITEM_SLOT_ICLOTHING) && !(w_uniform.item_flags & EXAMINE_SKIP))
		//accessory
		var/accessory_msg
		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(U.attached_accessory)
				accessory_msg += " with [icon2html(U.attached_accessory, user)] \a [U.attached_accessory]"

		. += "[t_He] [t_is] wearing [w_uniform.get_examine_string(user)][accessory_msg]."
	//head
	if(head && !(obscured & ITEM_SLOT_HEAD) && !(head.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [head.get_examine_string(user)] on [t_his] head."
	//suit/armor
	if(wear_suit && !(wear_suit.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [wear_suit.get_examine_string(user)]."
		//suit/armor storage
		if(s_store && !(obscured & ITEM_SLOT_SUITSTORE) && !(s_store.item_flags & EXAMINE_SKIP))
			. += "[t_He] [t_is] carrying [s_store.get_examine_string(user)] on [t_his] [wear_suit.name]."
	//back
	if(back && !(back.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_has] [back.get_examine_string(user)] on [t_his] back."

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT) && !(I.item_flags & EXAMINE_SKIP))
			. += "[t_He] [t_is] holding [I.get_examine_string(user)] in [t_his] [get_held_index_name(get_held_index_of_item(I))]."

	//gloves
	if(gloves && !(obscured & ITEM_SLOT_GLOVES) && !(gloves.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_has] [gloves.get_examine_string(user)] on [t_his] hands."
	else if(GET_ATOM_BLOOD_DNA_LENGTH(src))
		if(num_hands)
			. += span_warning("[t_He] [t_has] [num_hands > 1 ? "" : "a"] blood-stained hand[num_hands > 1 ? "s" : ""]!")

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			. += span_warning("[t_He] [t_is] [icon2html(handcuffed, user)] restrained with cable!")
		else
			. += span_warning("[t_He] [t_is] [icon2html(handcuffed, user)] handcuffed!")

	//belt
	if(belt && !(belt.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_has] [belt.get_examine_string(user)] about [t_his] waist."

	//shoes
	if(shoes && !(obscured & ITEM_SLOT_FEET)  && !(shoes.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [shoes.get_examine_string(user)] on [t_his] feet."

	//mask
	if(wear_mask && !(obscured & ITEM_SLOT_MASK)  && !(wear_mask.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_has] [wear_mask.get_examine_string(user)] on [t_his] face."

	if(wear_neck && !(obscured & ITEM_SLOT_NECK)  && !(wear_neck.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [wear_neck.get_examine_string(user)] around [t_his] neck."

	//eyes
	if(!(obscured & ITEM_SLOT_EYES) )
		if(glasses  && !(glasses.item_flags & EXAMINE_SKIP))
			. += "[t_He] [t_has] [glasses.get_examine_string(user)] covering [t_his] eyes."
		else if(HAS_TRAIT(src, TRAIT_UNNATURAL_RED_GLOWY_EYES))
			. += "<span class='warning'><B>[t_His] eyes are glowing with an unnatural red aura!</B></span>"
		else if(HAS_TRAIT(src, TRAIT_BLOODSHOT_EYES))
			. += "<span class='warning'><B>[t_His] eyes are bloodshot!</B></span>"

	//ears
	if(ears && !(obscured & ITEM_SLOT_EARS) && !(ears.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_has] [ears.get_examine_string(user)] on [t_his] ears."

	//ID
	if(wear_id && !(wear_id.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [wear_id.get_examine_string(user)]."

		. += wear_id.get_id_examine_strings(user)

	//Status effects
	var/list/status_examines = get_status_effect_examinations()
	if (length(status_examines))
		. += status_examines

	var/appears_dead = FALSE
	var/just_sleeping = FALSE

	if(stat == DEAD || (HAS_TRAIT(src, TRAIT_FAKEDEATH)))
		appears_dead = TRUE

		var/obj/item/clothing/glasses/G = get_item_by_slot(ITEM_SLOT_EYES)
		var/are_we_in_weekend_at_bernies = G?.tint && buckled && istype(buckled, /obj/vehicle/ridden/wheelchair)

		if(isliving(user) && (HAS_TRAIT(user, TRAIT_NAIVE) || are_we_in_weekend_at_bernies))
			just_sleeping = TRUE

		if(!just_sleeping)
			if(suiciding)
				. += span_warning("[t_He] appear[p_s()] to have committed suicide... there is no hope of recovery.")

			. += generate_death_examine_text()

	if(get_bodypart(BODY_ZONE_HEAD) && !getorgan(/obj/item/organ/internal/brain))
		. += span_deadsay("It appears that [t_his] brain is missing...")

	var/list/msg = list()

	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/list/disabled = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/body_part = X
		if(body_part.bodypart_disabled)
			disabled += body_part
		missing -= body_part.body_zone
		for(var/obj/item/I in body_part.embedded_objects)
			if(I.isEmbedHarmless())
				msg += "<B>[t_He] [t_has] [icon2html(I, user)] \a [I] stuck to [t_his] [body_part.name]!</B>\n"
			else
				msg += "<B>[t_He] [t_has] [icon2html(I, user)] \a [I] embedded in [t_his] [body_part.name]!</B>\n"

		for(var/i in body_part.wounds)
			var/datum/wound/iter_wound = i
			msg += "[iter_wound.get_examine_description(user)]\n"

	for(var/X in disabled)
		var/obj/item/bodypart/body_part = X
		var/damage_text
		if(HAS_TRAIT(body_part, TRAIT_DISABLED_BY_WOUND))
			continue // skip if it's disabled by a wound (cuz we'll be able to see the bone sticking out!)
		if(!(body_part.get_damage() >= body_part.max_damage)) //we don't care if it's stamcritted
			damage_text = "limp and lifeless"
		else
			damage_text = (body_part.brute_dam >= body_part.burn_dam) ? body_part.heavy_brute_msg : body_part.heavy_burn_msg
		msg += "<B>[capitalize(t_his)] [body_part.name] is [damage_text]!</B>\n"

	//stores missing limbs
	var/l_limbs_missing = 0
	var/r_limbs_missing = 0
	for(var/t in missing)
		if(t == BODY_ZONE_HEAD)
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

	if(!(user == src && has_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy))) //fake healthy
		var/temp
		if(user == src && has_status_effect(/datum/status_effect/grouped/screwy_hud/fake_crit))//fake damage
			temp = 50
		else
			temp = getBruteLoss()
		var/list/damage_desc = get_majority_bodypart_damage_desc()
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor [damage_desc[BRUTE]].\n"
			else if(temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> [damage_desc[BRUTE]]!\n"
			else
				msg += "<B>[t_He] [t_has] severe [damage_desc[BRUTE]]!</B>\n"

		temp = getFireLoss()
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor [damage_desc[BURN]].\n"
			else if (temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> [damage_desc[BURN]]!\n"
			else
				msg += "<B>[t_He] [t_has] severe [damage_desc[BURN]]!</B>\n"

		temp = getCloneLoss()
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor [damage_desc[CLONE]].\n"
			else if(temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> [damage_desc[CLONE]]!\n"
			else
				msg += "<b>[t_He] [t_has] severe [damage_desc[CLONE]]!</b>\n"


	if(has_status_effect(/datum/status_effect/fire_handler/fire_stacks))
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(has_status_effect(/datum/status_effect/fire_handler/wet_stacks))
		msg += "[t_He] look[p_s()] a little soaked.\n"


	if(pulledby?.grab_state)
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

	var/apparent_blood_volume = blood_volume
	if(dna.species.use_skintones && skin_tone == "albino")
		apparent_blood_volume -= 150 // enough to knock you down one tier
	switch(apparent_blood_volume)
		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
			msg += "[t_He] [t_has] pale skin.\n"
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			msg += "<b>[t_He] look[p_s()] like pale death.</b>\n"
		if(-INFINITY to BLOOD_VOLUME_BAD)
			msg += "[span_deadsay("<b>[t_He] resemble[p_s()] a crushed, empty juice pouch.</b>")]\n"

	if(is_bleeding())
		var/list/obj/item/bodypart/bleeding_limbs = list()
		var/list/obj/item/bodypart/grasped_limbs = list()

		for(var/obj/item/bodypart/body_part as anything in bodyparts)
			if(body_part.get_modified_bleed_rate())
				bleeding_limbs += body_part
			if(body_part.grasped_by)
				grasped_limbs += body_part

		var/num_bleeds = LAZYLEN(bleeding_limbs)

		var/list/bleed_text
		if(appears_dead)
			bleed_text = list("<span class='deadsay'><B>Blood is visible in [t_his] open")
		else
			bleed_text = list("<B>[t_He] [t_is] bleeding from [t_his]")

		switch(num_bleeds)
			if(1 to 2)
				bleed_text += " [bleeding_limbs[1].name][num_bleeds == 2 ? " and [bleeding_limbs[2].name]" : ""]"
			if(3 to INFINITY)
				for(var/i in 1 to (num_bleeds - 1))
					var/obj/item/bodypart/body_part = bleeding_limbs[i]
					bleed_text += " [body_part.name],"
				bleed_text += " and [bleeding_limbs[num_bleeds].name]"

		if(appears_dead)
			bleed_text += ", but it has pooled and is not flowing.</span></B>\n"
		else
			if(reagents.has_reagent(/datum/reagent/toxin/heparin, needs_metabolizing = TRUE))
				bleed_text += " incredibly quickly"

			bleed_text += "!</B>\n"

		for(var/i in grasped_limbs)
			var/obj/item/bodypart/grasped_part = i
			bleed_text += "[t_He] [t_is] holding [t_his] [grasped_part.name] to slow the bleeding!\n"

		msg += bleed_text.Join()

	if(reagents.has_reagent(/datum/reagent/teslium, needs_metabolizing = TRUE))
		msg += "[t_He] [t_is] emitting a gentle blue glow!\n"

	if(islist(stun_absorption))
		for(var/i in stun_absorption)
			if(stun_absorption[i]["end_time"] > world.time && stun_absorption[i]["examine_message"])
				msg += "[t_He] [t_is][stun_absorption[i]["examine_message"]]\n"

	if(just_sleeping)
		msg += "[t_He] [t_is]n't responding to anything around [t_him] and seem[p_s()] to be asleep.\n"

	if(!appears_dead)
		var/mob/living/living_user = user
		if(src != user)
			if(HAS_TRAIT(user, TRAIT_EMPATH))
				if (combat_mode)
					msg += "[t_He] seem[p_s()] to be on guard.\n"
				if (getOxyLoss() >= 10)
					msg += "[t_He] seem[p_s()] winded.\n"
				if (getToxLoss() >= 10)
					msg += "[t_He] seem[p_s()] sickly.\n"
				if(mob_mood.sanity <= SANITY_DISTURBED)
					msg += "[t_He] seem[p_s()] distressed.\n"
					living_user.add_mood_event("empath", /datum/mood_event/sad_empath, src)
				if(is_blind())
					msg += "[t_He] appear[p_s()] to be staring off into space.\n"
				if (HAS_TRAIT(src, TRAIT_DEAF))
					msg += "[t_He] appear[p_s()] to not be responding to noises.\n"
				if (bodytemperature > dna.species.bodytemp_heat_damage_limit)
					msg += "[t_He] [t_is] flushed and wheezing.\n"
				if (bodytemperature < dna.species.bodytemp_cold_damage_limit)
					msg += "[t_He] [t_is] shivering.\n"

			msg += "</span>"

			if(HAS_TRAIT(user, TRAIT_SPIRITUAL) && mind?.holy_role)
				msg += "[t_He] [t_has] a holy aura about [t_him].\n"
				living_user.add_mood_event("religious_comfort", /datum/mood_event/religiously_comforted)

		switch(stat)
			if(UNCONSCIOUS, HARD_CRIT)
				msg += "[t_He] [t_is]n't responding to anything around [t_him] and seem[p_s()] to be asleep.\n"
			if(SOFT_CRIT)
				msg += "[t_He] [t_is] barely conscious.\n"
			if(CONSCIOUS)
				if(HAS_TRAIT(src, TRAIT_DUMB))
					msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"
		if(getorgan(/obj/item/organ/internal/brain))
			if(ai_controller?.ai_status == AI_STATUS_ON)
				if(!dna.species.ai_controlled_species)
					msg += "[ai_controller.get_human_examine_text()]\n"
			else if(!key)
				msg += "[span_deadsay("[t_He] [t_is] totally catatonic. The stresses of life in deep-space must have been too much for [t_him]. Any recovery is unlikely.")]\n"
			else if(!client)
				msg += "[t_He] [t_has] a blank, absent-minded stare and appears completely unresponsive to anything. [t_He] may snap out of it soon.\n"

	var/scar_severity = 0
	for(var/i in all_scars)
		var/datum/scar/S = i
		if(S.is_visible(user))
			scar_severity += S.severity

	switch(scar_severity)
		if(1 to 4)
			msg += "[span_tinynoticeital("[t_He] [t_has] visible scarring, you can look again to take a closer look...")]\n"
		if(5 to 8)
			msg += "[span_smallnoticeital("[t_He] [t_has] several bad scars, you can look again to take a closer look...")]\n"
		if(9 to 11)
			msg += "[span_notice("<i>[t_He] [t_has] significantly disfiguring scarring, you can look again to take a closer look...</i>")]\n"
		if(12 to INFINITY)
			msg += "[span_notice("<b><i>[t_He] [t_is] just absolutely fucked up, you can look again to take a closer look...</i></b>")]\n"
	msg += "</span>" // closes info class

	if (length(msg))
		. += span_warning("[msg.Join("")]")

	var/trait_exam = common_trait_examine()
	if (!isnull(trait_exam))
		. += trait_exam

	var/perpname = get_face_name(get_id_name(""))
	if(perpname && (HAS_TRAIT(user, TRAIT_SECURITY_HUD) || HAS_TRAIT(user, TRAIT_MEDICAL_HUD)))
		var/datum/record/crew/target_record = find_record(perpname)
		if(target_record)
			. += "<span class='deptradio'>Rank:</span> [target_record.rank]\n<a href='?src=[REF(src)];hud=1;photo_front=1;examine_time=[world.time]'>\[Front photo\]</a><a href='?src=[REF(src)];hud=1;photo_side=1;examine_time=[world.time]'>\[Side photo\]</a>"
		if(HAS_TRAIT(user, TRAIT_MEDICAL_HUD))
			var/cyberimp_detect
			for(var/obj/item/organ/internal/cyberimp/CI in internal_organs)
				if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
					cyberimp_detect += "[!cyberimp_detect ? "[CI.get_examine_string(user)]" : ", [CI.get_examine_string(user)]"]"
			if(cyberimp_detect)
				. += "<span class='notice ml-1'>Detected cybernetic modifications:</span>"
				. += "<span class='notice ml-2'>[cyberimp_detect]</span>"
			target_record = find_record(perpname)
			if(target_record)
				. += "<a href='?src=[REF(src)];hud=m;evaluation=1;examine_time=[world.time]'>\[Medical evaluation\]</a><br>"
			. += "<a href='?src=[REF(src)];hud=m;quirk=1;examine_time=[world.time]'>\[See quirks\]</a>"

		if(HAS_TRAIT(user, TRAIT_SECURITY_HUD))
			if(!user.stat && user != src)
			//|| !user.canmove || user.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
				var/wanted_status = WANTED_NONE

				target_record = find_record(perpname)
				if(target_record)
					wanted_status = target_record.wanted_status

				. += "<span class='deptradio'>Criminal status:</span> <a href='?src=[REF(src)];hud=s;status=1;examine_time=[world.time]'>\[[wanted_status]\]</a>"
				. += jointext(list("<span class='deptradio'>Security record:</span> <a href='?src=[REF(src)];hud=s;view=1;examine_time=[world.time]'>\[View\]</a>",
					"<a href='?src=[REF(src)];hud=s;add_citation=1;examine_time=[world.time]'>\[Add citation\]</a>",
					"<a href='?src=[REF(src)];hud=s;add_crime=1;examine_time=[world.time]'>\[Add crime\]</a>",
					"<a href='?src=[REF(src)];hud=s;add_note=1;examine_time=[world.time]'>\[Add note\]</a>"), "")
	else if(isobserver(user))
		. += span_info("<b>Traits:</b> [get_quirk_string(FALSE, CAT_QUIRK_ALL)]")
	. += "</span>"

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)

/**
 * Shows any and all examine text related to any status effects the user has.
 */
/mob/living/proc/get_status_effect_examinations()
	var/list/examine_list = list()

	for(var/datum/status_effect/effect as anything in status_effects)
		var/effect_text = effect.get_examine_text()
		if(!effect_text)
			continue

		examine_list += effect_text

	if(!length(examine_list))
		return

	return examine_list.Join("\n")

/mob/living/carbon/human/examine_more(mob/user)
	. = ..()
	if ((wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE)))
		return
	var/age_text
	switch(age)
		if(-INFINITY to 25)
			age_text = "very young"
		if(26 to 35)
			age_text = "of adult age"
		if(36 to 55)
			age_text = "middle-aged"
		if(56 to 75)
			age_text = "rather old"
		if(76 to 100)
			age_text = "very old"
		if(101 to INFINITY)
			age_text = "withering away"
	. += list(span_notice("[p_they(TRUE)] appear[p_s()] to be [age_text]."))
