/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	movement_type = FLOATING
	density = FALSE
	anchored = TRUE
	max_integrity = 200
	integrity_failure = 0.5

/obj/structure/mirror/Initialize(mapload)
	. = ..()
	var/static/list/reflection_filter = alpha_mask_filter(icon = icon('icons/obj/watercloset.dmi', "mirror_mask"))
	var/static/matrix/reflection_matrix = matrix(0.75, 0, 0, 0, 0.75, 0)
	var/datum/callback/can_reflect = CALLBACK(src, PROC_REF(can_reflect))
	var/list/update_signals = list(COMSIG_ATOM_BREAK)
	AddComponent(/datum/component/reflection, reflection_filter = reflection_filter, reflection_matrix = reflection_matrix, can_reflect = can_reflect, update_signals = update_signals)

/obj/structure/mirror/proc/can_reflect(atom/movable/target)
	///I'm doing it this way too, because the signal is sent before the broken variable is set to TRUE.
	if(atom_integrity <= integrity_failure * max_integrity)
		return FALSE
	if(broken || !isliving(target) || HAS_TRAIT(target, TRAIT_NO_MIRROR_REFLECTION))
		return FALSE
	return TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mirror, 28)

/obj/structure/mirror/broken
	icon_state = "mirror_broke"

/obj/structure/mirror/broken/Initialize(mapload)
	. = ..()
	atom_break(null, mapload)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mirror/broken, 28)

/obj/structure/mirror/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return TRUE
	if(broken || !Adjacent(user))
		return TRUE

	if(!ishuman(user))
		return TRUE
	var/mob/living/carbon/human/hairdresser = user

	//handle facial hair (if necessary)
	if(hairdresser.gender != FEMALE)
		var/new_style = tgui_input_list(user, "Select a facial hairstyle", "Grooming", GLOB.facial_hairstyles_list)
		if(isnull(new_style))
			return TRUE
		if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
			return TRUE //no tele-grooming
		if(HAS_TRAIT(hairdresser, TRAIT_SHAVED))
			to_chat(hairdresser, span_notice("If only growing back facial hair were that easy for you..."))
			return TRUE
		hairdresser.set_facial_hairstyle(new_style, update = TRUE)
	else
		hairdresser.set_facial_hairstyle("Shaved", update = TRUE)

	//handle normal hair
	var/new_style = tgui_input_list(user, "Select a hairstyle", "Grooming", GLOB.hairstyles_list)
	if(isnull(new_style))
		return TRUE
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return TRUE //no tele-grooming
	if(HAS_TRAIT(hairdresser, TRAIT_BALD))
		to_chat(hairdresser, span_notice("If only growing back hair were that easy for you..."))
		return TRUE

	hairdresser.set_hairstyle(new_style, update = TRUE)

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
		user.AddComponent(/datum/component/omen)

/obj/structure/mirror/bullet_act(obj/projectile/P)
	if(broken || !isliving(P.firer) || !P.damage)
		return ..()

	. = ..()
	if(broken) // breaking a mirror truly gets you bad luck!
		var/mob/living/unlucky_dude = P.firer
		to_chat(unlucky_dude, span_warning("A chill runs down your spine as [src] shatters..."))
		unlucky_dude.AddComponent(/datum/component/omen)

/obj/structure/mirror/atom_break(damage_flag, mapload)
	. = ..()
	if(broken || (flags_1 & NODECONSTRUCT_1))
		return
	icon_state = "mirror_broke"
	if(!mapload)
		playsound(src, SFX_SHATTER, 70, TRUE)
	if(desc == initial(desc))
		desc = "Oh no, seven years of bad luck!"
	broken = TRUE

/obj/structure/mirror/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			new /obj/item/shard(loc)
		else
			new /obj/item/wallframe/mirror(loc)
	qdel(src)

/obj/structure/mirror/welder_act(mob/living/user, obj/item/I)
	..()
	if(user.combat_mode)
		return FALSE

	if(!broken)
		return TRUE

	if(!I.tool_start_check(user, amount=1))
		return TRUE

	balloon_alert(user, "repairing...")
	if(I.use_tool(src, user, 10, volume = 50))
		balloon_alert(user, "repaired")
		broken = FALSE
		icon_state = initial(icon_state)
		desc = initial(desc)

	return TRUE

/obj/structure/mirror/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
		if(BURN)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)

/obj/item/wallframe/mirror
	name = "mirror"
	desc = "An unmounted mirror. Attach it to a wall to use."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	custom_materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
	)
	result_path = /obj/structure/mirror
	pixel_shift = 28

/obj/structure/mirror/magic
	name = "magic mirror"
	desc = "Turn and face the strange... face."
	icon_state = "magic_mirror"

	///Flags this race must have to be selectable with this type of mirror.
	var/race_flags = MIRROR_MAGIC
	///List of all Races that can be chosen, decided by its Initialize.
	var/list/selectable_races = list()

/obj/structure/mirror/magic/Initialize(mapload)
	. = ..()

	if(length(selectable_races))
		return
	for(var/datum/species/species_type as anything in subtypesof(/datum/species))
		if(initial(species_type.changesource_flags) & race_flags)
			selectable_races[initial(species_type.name)] = species_type
	selectable_races = sort_list(selectable_races)

/obj/structure/mirror/magic/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return TRUE
	if(!ishuman(user))
		return TRUE

	var/mob/living/carbon/human/amazed_human = user

	var/choice = tgui_input_list(user, "Something to change?", "Magical Grooming", list("name", "race", "gender", "hair", "eyes"))
	if(isnull(choice))
		return TRUE

	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return TRUE

	switch(choice)
		if("name")
			var/newname = sanitize_name(tgui_input_text(amazed_human, "Who are we again?", "Name change", amazed_human.name, MAX_NAME_LEN), allow_numbers = TRUE) //It's magic so whatever.
			if(!newname)
				return TRUE
			if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
				return TRUE
			amazed_human.real_name = newname
			amazed_human.name = newname
			if(amazed_human.dna)
				amazed_human.dna.real_name = newname
			if(amazed_human.mind)
				amazed_human.mind.name = newname

		if("race")
			var/racechoice = tgui_input_list(amazed_human, "What are we again?", "Race change", selectable_races)
			if(isnull(racechoice))
				return TRUE
			if(!selectable_races[racechoice])
				return TRUE
			if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
				return TRUE

			var/datum/species/newrace = selectable_races[racechoice]
			amazed_human.set_species(newrace, icon_update = FALSE)
			if(HAS_TRAIT(amazed_human, TRAIT_USES_SKINTONES))
				var/new_s_tone = tgui_input_list(user, "Choose your skin tone", "Race change", GLOB.skin_tones)
				if(new_s_tone)
					amazed_human.skin_tone = new_s_tone
					amazed_human.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)
			else if(HAS_TRAIT(amazed_human, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(amazed_human, TRAIT_FIXED_MUTANT_COLORS))
				var/new_mutantcolor = input(user, "Choose your skin color:", "Race change", amazed_human.dna.features["mcolor"]) as color|null
				if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
					return TRUE
				if(new_mutantcolor)
					var/temp_hsv = RGBtoHSV(new_mutantcolor)

					if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright
						amazed_human.dna.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)
						amazed_human.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)

					else
						to_chat(amazed_human, span_notice("Invalid color. Your color is not bright enough."))
						return TRUE

			amazed_human.update_body(is_creating = TRUE)
			amazed_human.update_mutations_overlay() // no hulk lizard

		if("gender")
			if(!(amazed_human.gender in list(MALE, FEMALE))) //blame the patriarchy
				return TRUE
			if(amazed_human.gender == MALE)
				if(tgui_alert(amazed_human, "Become a Witch?", "Confirmation", list("Yes", "No")) == "Yes")
					if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
						return TRUE
					amazed_human.gender = FEMALE
					amazed_human.physique = FEMALE
					to_chat(amazed_human, span_notice("Man, you feel like a woman!"))
				else
					return TRUE
			else
				if(tgui_alert(amazed_human, "Become a Warlock?", "Confirmation", list("Yes", "No")) == "Yes")
					if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
						return TRUE
					amazed_human.gender = MALE
					amazed_human.physique = MALE
					to_chat(amazed_human, span_notice("Whoa man, you feel like a man!"))
				else
					return TRUE
			amazed_human.dna.update_ui_block(DNA_GENDER_BLOCK)
			amazed_human.update_body()
			amazed_human.update_mutations_overlay() //(hulk male/female)

		if("hair")
			var/hairchoice = tgui_alert(amazed_human, "Hairstyle or hair color?", "Change Hair", list("Style", "Color"))
			if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
				return TRUE
			if(hairchoice == "Style") //So you just want to use a mirror then?
				return ..()
			else
				var/new_hair_color = input(amazed_human, "Choose your hair color", "Hair Color",amazed_human.hair_color) as color|null
				if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
					return TRUE
				if(new_hair_color)
					amazed_human.set_haircolor(sanitize_hexcolor(new_hair_color), update = FALSE)
					amazed_human.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
				if(amazed_human.gender == MALE)
					var/new_face_color = input(amazed_human, "Choose your facial hair color", "Hair Color", amazed_human.facial_hair_color) as color|null
					if(new_face_color)
						amazed_human.set_facial_haircolor(sanitize_hexcolor(new_face_color), update = FALSE)
						amazed_human.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
				amazed_human.update_body_parts()

		if(BODY_ZONE_PRECISE_EYES)
			var/new_eye_color = input(amazed_human, "Choose your eye color", "Eye Color", amazed_human.eye_color_left) as color|null
			if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
				return TRUE
			if(new_eye_color)
				amazed_human.eye_color_left = sanitize_hexcolor(new_eye_color)
				amazed_human.eye_color_right = sanitize_hexcolor(new_eye_color)
				amazed_human.dna.update_ui_block(DNA_EYE_COLOR_LEFT_BLOCK)
				amazed_human.dna.update_ui_block(DNA_EYE_COLOR_RIGHT_BLOCK)
				amazed_human.update_body()

/obj/structure/mirror/magic/lesser/Initialize(mapload)
	// Roundstart species don't have a flag, so it has to be set on Initialize.
	selectable_races = get_selectable_species().Copy()
	return ..()

/obj/structure/mirror/magic/badmin
	race_flags = MIRROR_BADMIN

/obj/structure/mirror/magic/pride
	name = "pride's mirror"
	desc = "Pride cometh before the..."
	race_flags = MIRROR_PRIDE

/obj/structure/mirror/magic/pride/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return TRUE

	user.visible_message(span_danger("<B>The ground splits beneath [user] as [user.p_their()] hand leaves the mirror!</B>"), \
	span_notice("Perfect. Much better! Now <i>nobody</i> will be able to resist yo-"))

	var/turf/user_turf = get_turf(user)
	var/list/levels = SSmapping.levels_by_trait(ZTRAIT_SPACE_RUINS)
	var/turf/dest
	if(length(levels))
		dest = locate(user_turf.x, user_turf.y, pick(levels))

	user_turf.ChangeTurf(/turf/open/chasm, flags = CHANGETURF_INHERIT_AIR)
	var/turf/open/chasm/new_chasm = user_turf
	new_chasm.set_target(dest)
	new_chasm.drop(user)
