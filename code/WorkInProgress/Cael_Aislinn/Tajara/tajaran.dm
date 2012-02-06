/mob/living/carbon/human/tajaran
	name = "tajaran"
	real_name = "tajaran"
	voice_name = "tajaran"
	icon = 'tajaran.dmi'
	var/list/tajspeak_letters
	//
	universal_speak = 1
	taj_talk_understand = 1
	voice_message = "mrowls"

/mob/living/carbon/human/tajaran/New()
	tajspeak_letters = new/list("~","*","-")
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	if(!dna)	dna = new /datum/dna(null)

	new /datum/organ/external/chest(src)
	new /datum/organ/external/groin(src)
	new /datum/organ/external/head(src)
	new /datum/organ/external/l_arm(src)
	new /datum/organ/external/r_arm(src)
	new /datum/organ/external/r_leg(src)
	new /datum/organ/external/l_leg(src)

	var/datum/organ/external/part = new /datum/organ/external/l_hand(src)
	part.parent = organs["l_arm"]
	part = new /datum/organ/external/l_foot(src)
	part.parent = organs["l_leg"]
	part = new /datum/organ/external/r_hand(src)
	part.parent = organs["r_arm"]
	part = new /datum/organ/external/r_foot(src)
	part.parent = organs["r_leg"]

	debug_leftarm = organs["l_arm"]
	debug_lefthand = organs["l_hand"]

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"
	else
		gender = MALE
		g = "m"

	spawn (1)
		if(!stand_icon)
			stand_icon = new /icon('tajaran.dmi', "body_[g]_s")
		if(!lying_icon)
			lying_icon = new /icon('tajaran.dmi', "body_[g]_l")
		icon = stand_icon
		update_clothing()
		src << "\blue Your icons have been generated!"

	..()

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

	stand_icon = new /icon('tajaran.dmi', "torso_s")
	lying_icon = new /icon('tajaran.dmi', "torso_l")

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
			stand_icon.Blend(new /icon('tajaran.dmi', "[part.icon_name]_s"), ICON_OVERLAY)
			lying_icon.Blend(new /icon('tajaran.dmi', "[part.icon_name]_l"), ICON_OVERLAY)

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

	if(!facial_hair_style || !hair_style)	return//Seems people like to lose their icons, this should stop the runtimes for now
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

	var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
	var/icon/hair_l = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_l")
	hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
	hair_l.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)

	var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
	var/icon/facial_l = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_l")
	facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
	facial_l.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)

	var/icon/mouth_s = new/icon("icon" = 'tajaran_face.dmi', "icon_state" = "mouth_[g]_s")
	var/icon/mouth_l = new/icon("icon" = 'tajaran_face.dmi', "icon_state" = "mouth_[g]_l")

	// if the head or mask has the flag BLOCKHAIR (equal to 5), then do not apply hair
	if((!(head && (head.flags & BLOCKHAIR))) && !(wear_mask && (wear_mask.flags & BLOCKHAIR)))
		eyes_s.Blend(hair_s, ICON_OVERLAY)
		eyes_l.Blend(hair_l, ICON_OVERLAY)

	eyes_s.Blend(mouth_s, ICON_OVERLAY)
	eyes_l.Blend(mouth_l, ICON_OVERLAY)

	// if BLOCKHAIR, do not apply facial hair
	if((!(head && (head.flags & BLOCKHAIR))) && !(wear_mask && (wear_mask.flags & BLOCKHAIR)))
		eyes_s.Blend(facial_s, ICON_OVERLAY)
		eyes_l.Blend(facial_l, ICON_OVERLAY)


	face_standing = new /image()
	face_lying = new /image()
	face_standing.icon = eyes_s
	face_standing.layer = MOB_LAYER
	face_lying.icon = eyes_l
	face_lying.layer = MOB_LAYER

	del(mouth_l)
	del(mouth_s)
	del(facial_l)
	del(facial_s)
	del(hair_l)
	del(hair_s)
	del(eyes_l)
	del(eyes_s)

/mob/living/carbon/human/tajaran/co2overloadtime = null
/mob/living/carbon/human/tajaran/temperature_resistance = T0C+70
