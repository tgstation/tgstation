//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "It's you!"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = FALSE
	anchored = TRUE
	max_integrity = 200
	integrity_failure = 0.5
	var/creation_time
	///Should our description be able to be changed by the undertale easter egg? Make this false if the default description is not "It's you!". I'd check for a description of "It's you!" directly, but I've been directly told not to do that for some reason.
	var/ut_reference = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mirror, 28)

/obj/structure/mirror/Initialize(mapload)
	. = ..()
	if(icon_state == "mirror_broke" && !broken)
		atom_break(null, mapload)
	creation_time = world.time

/obj/structure/mirror/examine(mob/user)
	if(!ut_reference || desc != initial(desc)) //I'm really not a fan of hardcoding this, but I don't see another way to do this
		return ..()
	else if(user.mind && user.mind.has_antag_datum(/datum/antagonist, TRUE) && user.key)
		desc = "It's me, [user.key]." //uses the player's OOC name, not their IC one
	else if(SSshuttle.emergency && SSshuttle.emergency.mode == SHUTTLE_ENDGAME)
		desc = "Still just you, [user.real_name]."
	else if(world.time >= creation_time + 60 MINUTES)
		desc = "Despite everything, it's still you."
	. = ..()
	desc = initial(desc)

/obj/structure/mirror/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(broken || !Adjacent(user))
		return

	if(!ishuman(user))
		return

	mirror_stuff(user)

//Mirror man, mirror man, does whatever a mirror can.
/obj/structure/mirror/mirror_stuff(mob/living/carbon/human/stylist)
	//see code/modules/mob/dead/new_player/preferences.dm at approx line 545 for comments!
	//this is largely copypasted from there.

	//handle normal hair
	if(!HAS_TRAIT(stylist, TRAIT_BALD))
		var/new_style = input(stylist, "Select a hairstyle", "Grooming")  as null|anything in GLOB.hairstyles_list
		if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) && !HAS_TRAIT(stylist, TRAIT_BALD))
			return //no tele-grooming
		else if(new_style)
			stylist.hairstyle = new_style
			stylist.update_hair()
			if(curse(stylist))
				return

	//handle facial hair
	var/new_facial_hair_style = input(stylist, "Select a facial hairstyle", "Grooming")  as null|anything in GLOB.facial_hairstyles_list
	if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return //no tele-grooming
	if(new_style)
		stylist.facial_hairstyle = new_style
		stylist.update_hair()
		curse(stylist)

///Curses the user of the mirror. Return TRUE if you want this to kick the user out of the mirror's menus.
/obj/structure/mirror/proc/curse(mob/living/user)
	return

/obj/structure/mirror/examine_status(mob/user)
	if(broken)
		return list()// no message spam
	return ..()

/obj/structure/mirror/attacked_by(obj/item/I, mob/living/user)
	if(broken || !istype(user) || !I.force)
		return ..()

	. = ..()
	if(broken) // breaking a mirror truly gets you bad luck!
		to_chat(user, span_warning("A chill runs down your spine as [src] shatters..."))
		user.AddComponent(/datum/component/omen, silent=TRUE) // we have our own message

/obj/structure/mirror/bullet_act(obj/projectile/P)
	if(broken || !isliving(P.firer) || !P.damage)
		return ..()

	. = ..()
	if(broken) // breaking a mirror truly gets you bad luck!
		var/mob/living/unlucky_dude = P.firer
		to_chat(unlucky_dude, span_warning("A chill runs down your spine as [src] shatters..."))
		unlucky_dude.AddComponent(/datum/component/omen, silent=TRUE) // we have our own message

/obj/structure/mirror/atom_break(damage_flag, mapload)
	. = ..()
	if(broken || (flags_1 & NODECONSTRUCT_1))
		return
	icon_state = "mirror_broke"
	if(!mapload)
		playsound(src, "shatter", 70, TRUE)
	if(desc == initial(desc))
		desc = "Oh no, seven years of bad luck!"
	broken = TRUE

/obj/structure/mirror/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			new /obj/item/shard( src.loc )
	qdel(src)

/obj/structure/mirror/welder_act(mob/living/user, obj/item/I)
	..()
	if(user.combat_mode)
		return FALSE

	if(!broken)
		return TRUE

	if(!I.tool_start_check(user, amount=0))
		return TRUE

	to_chat(user, span_notice("You begin repairing [src]..."))
	if(I.use_tool(src, user, 10, volume=50))
		to_chat(user, span_notice("You repair [src]."))
		broken = 0
		icon_state = initial(icon_state)
		desc = initial(desc)

	return TRUE

/obj/structure/mirror/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
		if(BURN)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)


/obj/structure/mirror/magic
	name = "magic mirror"
	desc = "Turn and face the strange."
	icon_state = "magic_mirror"
	var/list/choosable_races = list()
	ut_reference = FALSE

/obj/structure/mirror/magic/Initialize(mapload)
	. = ..()
	if(!choosable_races.len)
		for(var/datum/species/species_type as anything in subtypesof(/datum/species))
			if(initial(species_type.changesource_flags) & MIRROR_MAGIC)
				choosable_races += initial(species_type.name)
		choosable_races = sort_list(choosable_races)

/obj/structure/mirror/magic/lesser/Initialize(mapload)
	choosable_races = get_selectable_species().Copy()
	return ..()

/obj/structure/mirror/magic/badmin/Initialize(mapload)
	for(var/datum/species/species_type as anything in subtypesof(/datum/species))
		if(initial(species_type.changesource_flags) & MIRROR_BADMIN)
			choosable_races += initial(species_type.name)
	return ..()

/obj/structure/mirror/magic/mirror_stuff(mob/living/carbon/human/stylist)
	var/choice = input(stylist, "Something to change?", "Magical Grooming") as null|anything in list("name", "species", "color", "gender", "sex", "hairstyle", "hair color", "eyes")

	if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	switch(choice)
		if("name")
			var/newname = sanitize_name(stripped_input(stylist, "Who are we again?", "Name change", stylist.name, MAX_NAME_LEN), allow_numbers = TRUE) //It's magic so whatever.
			if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || !newname)
				return
			stylist.real_name = newname
			stylist.name = newname
			if(stylist.dna)
				stylist.dna.real_name = newname
			if(stylist.mind)
				stylist.mind.name = newname
			curse(stylist)

		if("species")
			var/newspecies
			var/specieschoice = input(stylist, "What species are we again?", "Species change") as null|anything in choosable_races
			newspecies = GLOB.species_list[specieschoice]

			if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || !newspecies)
				return
			stylist.set_species(newspecies, icon_update=0)

			stylist.update_body() //not actually sure if these updates are needed, but eh, it can't hurt to update this stuff again, just in case
			stylist.update_hair()
			stylist.update_body_parts()
			stylist.update_mutations_overlay() // no hulk lizard
			curse(stylist)

		if("color")
			if(!stylist.dna.species.use_skintones && !(MUTCOLORS in stylist.dna.species.species_traits))
				to_chat(stylist, span_notice("Your species doesn't have variant colorings."))
				return

			if(stylist.dna.species.use_skintones)
				var/new_s_tone = input(stylist, "What is our skin tone again?", "Race change")  as null|anything in GLOB.skin_tones
				if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(new_s_tone && stylist.dna.species.use_skintones) //we need to repeat the use_skintones check because their species could have changed between the last check and now
					stylist.skin_tone = new_s_tone
					stylist.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)
					stylist.update_body()
					stylist.update_hair()
					stylist.update_body_parts()
					stylist.update_mutations_overlay()
					if(curse(stylist))
						return

			if(MUTCOLORS in stylist.dna.species.species_traits)
				var/new_mutantcolor = input(stylist, "What color are we again?", "Race change",stylist.dna.features["mcolor"]) as color|null
				if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || !new_mutantcolor || !(MUTCOLORS in stylist.dna.species.species_traits))
					return

				var/temp_hsv = RGBtoHSV(new_mutantcolor)

				if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright
					stylist.dna.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)
					stylist.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)
					stylist.update_body()
					stylist.update_hair()
					stylist.update_body_parts()
					stylist.update_mutations_overlay()
					curse(stylist)
				else
					to_chat(stylist, span_notice("Invalid color. Your color is not bright enough."))

		if("gender")
			var/attackhelicopter = input(stylist, "What do we identify as again?", "Gender change") as null|anything in list(MALE, FEMALE, PLURAL)
			if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || !attackhelicopter)
				return
			stylist.gender = attackhelicopter
			curse(stylist)

		if("sex")
			if(stylist.body_type == MALE)
				if(tgui_alert(stylist, "Become a Witch?", "Confirmation", list("Yes", "No")) == "Yes")
					if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
						return
					stylist.body_type = FEMALE
					if(stylist.gender != PLURAL)
						stylist.gender = FEMALE //we'll update their gender to match their body type- if they want their gender to not match their body type, they can change that using the gender-changing function of the mirror
				else
					return
			else
				if(tgui_alert(stylist, "Become a Warlock?", "Confirmation", list("Yes", "No")) == "Yes")
					if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
						return
					stylist.body_type = MALE
					if(stylist.gender != PLURAL)
						stylist.gender = MALE //we'll update their gender to match their body type- if they want their gender to not match their body type, they can change that using the gender-changing function of the mirror
				else
					return
			H.dna.update_ui_block(DNA_GENDER_BLOCK)
			H.update_body()
			H.update_mutations_overlay() //(hulk male/female)
			curse(stylist)

		if("hairstyle")
			..()
		
		if("hair color")
			var/new_hair_color = input(stylist, "What is the color of our hair again?", "Hair Color",H.hair_color) as color|null
			if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			

			if(new_hair_color)
				stylist.hair_color = sanitize_hexcolor(new_hair_color)
				stylist.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
				stylist.update_hair()
				if(curse(stylist))
					return

			var/new_face_color = input(stylist, "What is the color of our facial hair again?", "Hair Color",stylist.facial_hair_color) as color|null
			
			if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || !new_face_color)
				return

			stylist.facial_hair_color = sanitize_hexcolor(new_face_color)
			stylist.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
			stylist.update_hair()
			curse(stylist)



		if("eyes")
			var/new_eye_color = input(stylist, "What is the color of our eyes again?", "Eye Color",stylist.eye_color) as color|null
			if(!stylist.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || !new_eye_color)
				return
			stylist.eye_color = sanitize_hexcolor(new_eye_color)
			stylist.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
			stylist.update_body()
			curse(stylist)
