/datum/species/jelly/slime
	name = "Xenobiological Slimeperson"

//##########SLIMEPEOPLE##########

/datum/species/jelly/roundstartslime
	name = "Slimeperson"
	id = "slimeperson"
	default_color = "00FFFF"
	species_traits = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR,NOBLOOD)
	inherent_traits = list(TRAIT_TOXINLOVER)
	mutant_bodyparts = list("mam_tail", "mam_ears", "taur")
	default_features = list("mcolor" = "FFF", "mam_tail" = "None", "mam_ears" = "None")
	say_mod = "says"
	hair_color = "mutcolor"
	hair_alpha = 180
	liked_food = MEAT
	coldmod = 3
	heatmod = 1
	burnmod = 1

/datum/species/jelly/roundstartslime/on_species_gain(mob/living/carbon/human/C)
	C.draw_citadel_parts()
	. = ..()

/datum/species/jelly/roundstartslime/on_species_loss(mob/living/carbon/human/C)
	C.draw_citadel_parts(TRUE)
	. = ..()

/datum/action/innate/slime_change
	name = "Alter Form"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "alter_form" //placeholder
	icon_icon = 'modular_citadel/icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/slime_change/Activate()
	var/mob/living/carbon/human/H = owner
	if(!isjellyperson(H))
		return
	else
		H.visible_message("<span class='notice'>[owner] gains a look of \
		concentration while standing perfectly still.\
		 Their body seems to shift and starts getting more goo-like.</span>",
		"<span class='notice'>You focus intently on altering your body while \
		standing perfectly still...</span>")
		change_form()

/datum/action/innate/slime_change/proc/change_form()
	var/mob/living/carbon/human/H = owner
	var/select_alteration = input(owner, "Select what part of your form to alter", "Form Alteration", "cancel") in list("Hair Style", "Genitals", "Tail", "Ears", "Taur body", "Cancel")
	if(select_alteration == "Hair Style")
		if(H.gender == MALE)
			var/new_style = input(owner, "Select a facial hair style", "Hair Alterations")  as null|anything in GLOB.facial_hair_styles_list
			if(new_style)
				H.facial_hair_style = new_style
		else
			H.facial_hair_style = "Shaved"
		//handle normal hair
		var/new_style = input(owner, "Select a hair style", "Hair Alterations")  as null|anything in GLOB.hair_styles_list
		if(new_style)
			H.hair_style = new_style
			H.update_hair()
	else if (select_alteration == "Genitals")
		var/list/organs = list()
		var/operation = input("Select organ operation.", "Organ Manipulation", "cancel") in list("add sexual organ", "remove sexual organ", "cancel")
		switch(operation)
			if("add sexual organ")
				var/new_organ = input("Select sexual organ:", "Organ Manipulation") in list("Penis", "Testicles", "Breasts", "Vagina", "Womb", "Cancel")
				if(new_organ == "Penis")
					H.give_penis()
				else if(new_organ == "Testicles")
					H.give_balls()
				else if(new_organ == "Breasts")
					H.give_breasts()
				else if(new_organ == "Vagina")
					H.give_vagina()
				else if(new_organ == "Womb")
					H.give_womb()
				else
					return
			if("remove sexual organ")
				for(var/obj/item/organ/genital/X in H.internal_organs)
					var/obj/item/organ/I = X
					organs["[I.name] ([I.type])"] = I
				var/obj/item/organ = input("Select sexual organ:", "Organ Manipulation", null) in organs
				organ = organs[organ]
				if(!organ)
					return
				var/obj/item/organ/genital/O
				if(isorgan(organ))
					O = organ
					O.Remove(H)
				organ.forceMove(get_turf(H))
				qdel(organ)
				H.update_body()
				
	else if (select_alteration == "Ears")
		var/list/snowflake_ears_list = list("Normal" = null)
		for(var/path in GLOB.mam_ears_list)
			var/datum/sprite_accessory/mam_ears/instance = GLOB.mam_ears_list[path]
			if(istype(instance, /datum/sprite_accessory))
				var/datum/sprite_accessory/S = instance
				if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(H.client.ckey)))
					snowflake_ears_list[S.name] = path
		var/new_ears
		new_ears = input(owner, "Choose your character's ears:", "Ear Alteration") as null|anything in snowflake_ears_list
		if(new_ears)
			H.dna.features["mam_ears"] = new_ears
		H.update_body()
		
	else if (select_alteration == "Tail")
		var/list/snowflake_tails_list = list("Normal" = null)
		for(var/path in GLOB.mam_tails_list)
			var/datum/sprite_accessory/mam_tails/instance = GLOB.mam_tails_list[path]
			if(istype(instance, /datum/sprite_accessory))
				var/datum/sprite_accessory/S = instance
				if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(H.client.ckey)))
					snowflake_tails_list[S.name] = path
		var/new_tail
		new_tail = input(owner, "Choose your character's Tail(s):", "Tail Alteration") as null|anything in snowflake_tails_list
		if(new_tail)
			H.dna.features["mam_tails"] = new_tail
			if(new_tail != "None")
				H.dna.features["taur"] = "None"
		H.update_body()
		
	else if (select_alteration == "Taur body")
		var/list/snowflake_taur_list = list("Normal" = null)
		for(var/path in GLOB.taur_list)
			var/datum/sprite_accessory/taur/instance = GLOB.taur_list[path]
			if(istype(instance, /datum/sprite_accessory))
				var/datum/sprite_accessory/S = instance
				if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(H.client.ckey)))
					snowflake_taur_list[S.name] = path
		var/new_taur
		new_taur = input(owner, "Choose your character's tauric body:", "Tauric Alteration") as null|anything in snowflake_taur_list
		if(new_taur)
			H.dna.features["taur"] = new_taur
			if(new_taur != "None")
				H.dna.features["mam_tail"] = "None"
				H.dna.features["xenotail"] = "None"
		H.update_body()
	else
		return
