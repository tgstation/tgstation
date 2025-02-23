
// Normal Mirrors

#define CHANGE_HAIR "Change Hair"
#define CHANGE_BEARD "Change Beard"

// Magic Mirrors!

#define CHANGE_RACE "Change Race"
#define CHANGE_SEX  "Change Sex"
#define CHANGE_NAME "Change Name"
#define CHANGE_EYES "Change Eyes"

#define INERT_MIRROR_OPTIONS list(CHANGE_HAIR, CHANGE_BEARD)
#define PRIDE_MIRROR_OPTIONS list(CHANGE_HAIR, CHANGE_BEARD, CHANGE_RACE, CHANGE_SEX, CHANGE_EYES)
#define MAGIC_MIRROR_OPTIONS list(CHANGE_HAIR, CHANGE_BEARD, CHANGE_RACE, CHANGE_SEX, CHANGE_EYES, CHANGE_NAME)

/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	movement_type = FLOATING
	density = FALSE
	anchored = TRUE
	integrity_failure = 0.5
	max_integrity = 200
	var/list/mirror_options = INERT_MIRROR_OPTIONS

	///Flags this race must have to be selectable with this type of mirror.
	var/race_flags = MIRROR_MAGIC
	///List of all Races that can be chosen, decided by its Initialize.
	var/list/selectable_races = list()

/obj/structure/mirror/Initialize(mapload)
	. = ..()
	update_choices()

/obj/structure/mirror/Destroy()
	mirror_options = null
	selectable_races = null
	return ..()

/obj/structure/mirror/proc/update_choices()
	for(var/i in mirror_options)
		mirror_options[i] = icon('icons/hud/radial.dmi', i)

/obj/structure/mirror/Initialize(mapload)
	. = ..()
	var/static/list/reflection_filter = alpha_mask_filter(icon = icon('icons/obj/watercloset.dmi', "mirror_mask"))
	var/static/matrix/reflection_matrix = matrix(0.75, 0, 0, 0, 0.75, 0)
	AddComponent(/datum/component/reflection, \
		reflection_filter = reflection_filter, \
		reflection_matrix = reflection_matrix, \
		can_reflect = CALLBACK(src, PROC_REF(can_reflect)), \
		update_signals = list(COMSIG_ATOM_BREAK), \
		check_reflect_signals = list(SIGNAL_ADDTRAIT(TRAIT_NO_MIRROR_REFLECTION), SIGNAL_REMOVETRAIT(TRAIT_NO_MIRROR_REFLECTION)), \
	)

/obj/structure/mirror/proc/can_reflect(atom/movable/target)
	///I'm doing it this way too, because the signal is sent before the broken variable is set to TRUE.
	if(atom_integrity <= integrity_failure * max_integrity)
		return FALSE
	if(broken || !isliving(target) || HAS_TRAIT(target, TRAIT_NO_MIRROR_REFLECTION))
		return FALSE
	return TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mirror, 28)

/obj/structure/mirror/Initialize(mapload)
	. = ..()
	find_and_hang_on_wall()

/obj/structure/mirror/broken
	icon_state = "mirror_broke"

/obj/structure/mirror/broken/Initialize(mapload)
	. = ..()
	atom_break(null, mapload)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mirror/broken, 28)

/obj/structure/mirror/attack_hand(mob/living/carbon/human/user)
	. = ..()

	if(. || !ishuman(user) || broken)
		return TRUE

	if(!istype(src, /obj/structure/mirror/magic) && !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return TRUE //no tele-grooming (if nonmagical)

	return display_radial_menu(user)

/obj/structure/mirror/proc/display_radial_menu(mob/living/carbon/human/user)
	var/pick = show_radial_menu(user, src, mirror_options, user, radius = 36, require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return TRUE //get out

	switch(pick)
		if(CHANGE_HAIR)
			change_hair(user)
		if(CHANGE_BEARD)
			change_beard(user)
		if(CHANGE_RACE)
			change_race(user)
		if(CHANGE_SEX) // sex: yes
			change_sex(user)
		if(CHANGE_NAME)
			change_name(user)
		if(CHANGE_EYES)
			change_eyes(user)

	return display_radial_menu(user)

/obj/structure/mirror/proc/change_beard(mob/living/carbon/human/beard_dresser)
	if(beard_dresser.physique == FEMALE)
		if(beard_dresser.facial_hairstyle == "Shaved")
			balloon_alert(beard_dresser, "nothing to shave!")
			return TRUE
		var/shave_beard = tgui_alert(beard_dresser, "Shave your beard?", "Grooming", list("Yes", "No"))
		if(shave_beard == "Yes")
			beard_dresser.set_facial_hairstyle("Shaved", update = TRUE)
		return TRUE

	var/new_style = tgui_input_list(beard_dresser, "Select a facial hairstyle", "Grooming", SSaccessories.facial_hairstyles_list)

	if(isnull(new_style))
		return TRUE

	if(HAS_TRAIT(beard_dresser, TRAIT_SHAVED))
		to_chat(beard_dresser, span_notice("If only growing back facial hair were that easy for you... The reminder makes you feel terrible."))
		beard_dresser.add_mood_event("bald_hair_day", /datum/mood_event/bald_reminder)
		return TRUE

	beard_dresser.set_facial_hairstyle(new_style, update = TRUE)

/obj/structure/mirror/proc/change_hair(mob/living/carbon/human/hairdresser)
	var/new_style = tgui_input_list(hairdresser, "Select a hairstyle", "Grooming", SSaccessories.hairstyles_list)
	if(isnull(new_style))
		return TRUE
	if(HAS_TRAIT(hairdresser, TRAIT_BALD))
		to_chat(hairdresser, span_notice("If only growing back hair were that easy for you... The reminder makes you feel terrible."))
		hairdresser.add_mood_event("bald_hair_day", /datum/mood_event/bald_reminder)
		return TRUE

	hairdresser.set_hairstyle(new_style, update = TRUE)

/obj/structure/mirror/proc/change_name(mob/living/carbon/human/user)
	var/newname = sanitize_name(tgui_input_text(user, "Who are we again?", "Name change", user.name, MAX_NAME_LEN), allow_numbers = TRUE) //It's magic so whatever.
	if(!newname)
		return TRUE
	user.real_name = newname
	user.name = newname
	if(user.dna)
		user.dna.real_name = newname
	if(user.mind)
		user.mind.name = newname

// Erm ackshually the proper term is species. Get it right??
/obj/structure/mirror/proc/change_race(mob/living/carbon/human/race_changer)
	var/racechoice = tgui_input_list(race_changer, "What are we again?", "Race change", selectable_races)
	if(isnull(racechoice))
		return TRUE

	var/new_race_path = selectable_races[racechoice]
	if(!ispath(new_race_path, /datum/species))
		return TRUE

	var/datum/species/newrace = new new_race_path()
	var/attributes_desc = newrace.get_physical_attributes()

	var/answer = tgui_alert(race_changer, attributes_desc, "Become a [newrace]?", list("Yes", "No"))
	if(answer != "Yes")
		qdel(newrace)
		change_race(race_changer) // try again
		return

	race_changer.set_species(newrace, icon_update = FALSE)
	if(HAS_TRAIT(race_changer, TRAIT_USES_SKINTONES))
		var/new_s_tone = tgui_input_list(race_changer, "Choose your skin tone", "Race change", GLOB.skin_tones)
		if(new_s_tone)
			race_changer.skin_tone = new_s_tone
			race_changer.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)
	else if(HAS_TRAIT(race_changer, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(race_changer, TRAIT_FIXED_MUTANT_COLORS))
		var/new_mutantcolor = input(race_changer, "Choose your skin color:", "Race change", race_changer.dna.features["mcolor"]) as color|null
		if(new_mutantcolor)
			var/list/mutant_hsv = rgb2hsv(new_mutantcolor)

			if(mutant_hsv[3] >= 50) // mutantcolors must be bright
				race_changer.dna.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)
				race_changer.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)
			else
				to_chat(race_changer, span_notice("Invalid color. Your color is not bright enough."))
				return TRUE

	race_changer.update_body(is_creating = TRUE)
	race_changer.update_mutations_overlay() // no hulk lizard

// possible Genders: MALE, FEMALE, PLURAL, NEUTER
// possible Physique: MALE, FEMALE
// saved you a click (many)
/obj/structure/mirror/proc/change_sex(mob/living/carbon/human/sexy)

	var/chosen_sex = tgui_input_list(sexy, "Become a..", "Confirmation", list("Warlock", "Witch", "Wizard", "Itzard")) // YOU try coming up with the 'it' version of wizard

	switch(chosen_sex)
		if("Warlock")
			sexy.gender = MALE
			to_chat(sexy, span_notice("Man, you feel like a man!"))
		if("Witch")
			sexy.gender = FEMALE
			to_chat(sexy, span_notice("Man, you feel like a woman!"))
		if("Wizard")
			sexy.gender = PLURAL
			to_chat(sexy, span_notice("Woah dude, you feel like a dude!"))
		if("Itzard")
			sexy.gender = NEUTER
			to_chat(sexy, span_notice("Woah dude, you feel like something else!"))

	var/chosen_physique = tgui_input_list(sexy, "Alter your physique as well?", "Confirmation", list("Warlock Physique", "Witch Physique", "Wizards Don't Need Gender"))

	if(chosen_physique && chosen_physique != "Wizards Don't Need Gender")
		sexy.physique = (chosen_physique == "Warlock Physique") ? MALE : FEMALE

	sexy.dna.update_ui_block(DNA_GENDER_BLOCK)
	sexy.update_body(is_creating = TRUE) // or else physique won't change properly
	sexy.update_mutations_overlay() //(hulk male/female)
	sexy.update_clothing(ITEM_SLOT_ICLOTHING) // update gender shaped clothing

/obj/structure/mirror/proc/change_eyes(mob/living/carbon/human/user)
	var/new_eye_color = input(user, "Choose your eye color", "Eye Color", user.eye_color_left) as color|null
	if(isnull(new_eye_color))
		return TRUE
	user.eye_color_left = sanitize_hexcolor(new_eye_color)
	user.eye_color_right = sanitize_hexcolor(new_eye_color)
	user.dna.update_ui_block(DNA_EYE_COLOR_LEFT_BLOCK)
	user.dna.update_ui_block(DNA_EYE_COLOR_RIGHT_BLOCK)
	user.update_body()
	to_chat(user, span_notice("You gaze at your new eyes with your new eyes. Perfect!"))

/obj/structure/mirror/examine_status(mob/living/carbon/human/user)
	if(broken)
		return list()// no message spam
	return ..()

/obj/structure/mirror/attacked_by(obj/item/I, mob/living/user)
	if(broken || !istype(user) || !I.force)
		return ..()

	. = ..()
	if(broken) // breaking a mirror truly gets you bad luck!
		to_chat(user, span_warning("A chill runs down your spine as [src] shatters..."))
		user.AddComponent(/datum/component/omen, incidents_left = 7)

/obj/structure/mirror/bullet_act(obj/projectile/proj)
	if(broken || !isliving(proj.firer) || !proj.damage)
		return ..()

	. = ..()
	if(broken) // breaking a mirror truly gets you bad luck!
		var/mob/living/unlucky_dude = proj.firer
		to_chat(unlucky_dude, span_warning("A chill runs down your spine as [src] shatters..."))
		unlucky_dude.AddComponent(/datum/component/omen, incidents_left = 7)

/obj/structure/mirror/atom_break(damage_flag, mapload)
	. = ..()
	if(broken)
		return
	icon_state = "mirror_broke"
	if(!mapload)
		playsound(src, SFX_SHATTER, 70, TRUE)
	if(desc == initial(desc))
		desc = "Oh no, seven years of bad luck!"
	broken = TRUE

/obj/structure/mirror/atom_deconstruct(disassembled = TRUE)
	if(!disassembled)
		new /obj/item/shard(loc)
	else
		new /obj/item/wallframe/mirror(loc)

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
	mirror_options = MAGIC_MIRROR_OPTIONS

/obj/structure/mirror/magic/Initialize(mapload)
	. = ..()

	if(length(selectable_races))
		return
	for(var/datum/species/species_type as anything in subtypesof(/datum/species))
		if(initial(species_type.changesource_flags) & race_flags)
			selectable_races[initial(species_type.name)] = species_type
	selectable_races = sort_list(selectable_races)

/obj/structure/mirror/magic/change_beard(mob/living/carbon/human/beard_dresser) // magical mirrors do nothing but give you the damn beard
	var/new_style = tgui_input_list(beard_dresser, "Select a facial hairstyle", "Grooming", SSaccessories.facial_hairstyles_list)
	if(isnull(new_style))
		return TRUE
	beard_dresser.set_facial_hairstyle(new_style, update = TRUE)
	return TRUE

//Magic mirrors can change hair color as well
/obj/structure/mirror/magic/change_hair(mob/living/carbon/human/user)
	var/hairchoice = tgui_alert(user, "Hairstyle or hair color?", "Change Hair", list("Style", "Color"))
	if(hairchoice == "Style") //So you just want to use a mirror then?
		return ..()

	var/new_hair_color = input(user, "Choose your hair color", "Hair Color", user.hair_color) as color|null

	if(new_hair_color)
		user.set_haircolor(sanitize_hexcolor(new_hair_color))
		user.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
	if(user.physique == MALE)
		var/new_face_color = input(user, "Choose your facial hair color", "Hair Color", user.facial_hair_color) as color|null
		if(new_face_color)
			user.set_facial_haircolor(sanitize_hexcolor(new_face_color))
			user.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)

/obj/structure/mirror/magic/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(.)
		return TRUE

	if(HAS_TRAIT(user, TRAIT_ADVANCEDTOOLUSER) && HAS_TRAIT(user, TRAIT_LITERATE))
		return TRUE

	to_chat(user, span_alert("You feel quite intelligent."))
	// Prevents wizards from being soft locked out of everything
	// If this stays after the species was changed once more, well, the magic mirror did it. It's magic i aint gotta explain shit
	user.add_traits(list(TRAIT_LITERATE, TRAIT_ADVANCEDTOOLUSER), SPECIES_TRAIT)
	return TRUE

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
	mirror_options = PRIDE_MIRROR_OPTIONS
	/// If the last user has altered anything about themselves
	var/changed = FALSE

/obj/structure/mirror/magic/pride/display_radial_menu(mob/living/carbon/human/user)
	var/pick = show_radial_menu(user, src, mirror_options, user, radius = 36, require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return TRUE //get out

	changed = TRUE
	switch(pick)
		if(CHANGE_HAIR)
			change_hair(user)
		if(CHANGE_BEARD)
			change_beard(user)
		if(CHANGE_RACE)
			change_race(user)
		if(CHANGE_SEX) // sex: yes
			change_sex(user)
		if(CHANGE_NAME)
			change_name(user)
		if(CHANGE_EYES)
			change_eyes(user)

	return display_radial_menu(user)

/obj/structure/mirror/magic/pride/attack_hand(mob/living/carbon/human/user)
	changed = FALSE
	. = ..()
	if (!changed)
		return
	user.visible_message(
		span_bolddanger("The ground splits beneath [user] as [user.p_their()] hand leaves the mirror!"),
		span_notice("Perfect. Much better! Now <i>nobody</i> will be able to resist yo-"),
	)

	var/turf/user_turf = get_turf(user)
	var/list/levels = SSmapping.levels_by_trait(ZTRAIT_SPACE_RUINS)
	var/turf/dest
	if(length(levels))
		dest = locate(user_turf.x, user_turf.y, pick(levels))

	user_turf.ChangeTurf(/turf/open/chasm, flags = CHANGETURF_INHERIT_AIR)
	var/turf/open/chasm/new_chasm = user_turf
	new_chasm.set_target(dest)
	new_chasm.drop(user)

#undef CHANGE_HAIR
#undef CHANGE_BEARD

#undef CHANGE_RACE
#undef CHANGE_SEX
#undef CHANGE_NAME
#undef CHANGE_EYES

#undef INERT_MIRROR_OPTIONS
#undef PRIDE_MIRROR_OPTIONS
#undef MAGIC_MIRROR_OPTIONS
