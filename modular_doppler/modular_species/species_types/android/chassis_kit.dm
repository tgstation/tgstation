// genetics can use humonkeys, and robotics can use these. we're inventing all new types of guys in r&d
/obj/item/chassis_kit
	name = "chassis assembly kit"
	desc = "2,486 parts, all required to build the core systems of a union-spec integrated positronic chassis. \
			Design courtesy of Supreme Electronics; electron sorter components included free of charge."
	// placeholder icon
	icon = 'modular_doppler/epic_loot/icons/epic_loot.dmi'
	icon_state = "shuttle_gyro"
	w_class = WEIGHT_CLASS_HUGE

	// name starts set in case initialize the generation fails for whatever reason
	var/stored_name = "Exeter"

	// they're making the box of spare parts woke
	var/stored_gender = NEUTER

	// no issues if these four are null on application
	var/stored_flavor_short_desc
	var/stored_flavor_extended_desc
	var/stored_custom_species_name
	var/stored_custom_species_desc

	// androids generate with antennae so they get some defaults, even if they're overwritten weirdly with ear insertion
	var/stored_antenna_design = "Angled"
	var/stored_antenna_color = "#AAAAAA"

	// remember cloning? everyone loved cloning. good times
	var/datum/preferences/stored_prefs

/obj/item/chassis_kit/Initialize(mapload)
	. = ..()
	stored_name = generate_random_name(stored_gender, TRUE, list(/datum/language/machine = 1))

/obj/item/chassis_kit/examine(mob/user)
	. = ..()
	// slightly different mechanics are used in the two "modes" so different controls are shown
	if(stored_prefs)
		. += span_info("The chassis currently has a complete self-image paradigm loaded.")
		. += span_blue("<b>Left-click</b> with a multitool to clear this data.")
	else
		. += span_info("The chassis currently reports its name as [stored_name], and gender as [stored_gender].")
		. += stored_flavor_short_desc ? span_info("A personal appearance paradigm has been created.") : span_warning("No personal appearance paradigm available.")
		. += stored_custom_species_name ? span_info("A chassis design paradigm has been created.") : span_warning("No chassis construction paradigm available.")
		. += span_blue("<b>Left-click</b> with a multitool to adjust the hardware identification strings.")
		. += span_blue("<b>Right-click</b> with a multitool to implement custom visuals for the completed chassis.")
		. += span_blue("Use a <b>cybernetic brain</b> on the kit to scan self-image standards from its subconscious.")

/obj/item/chassis_kit/attackby(obj/item/used_item, mob/user)

	// this particular function, scanning in preferences from an extant brain, is the most cloning-y aspect of this whole deal.
	// if this is determined to be either too "handwave" (as per self-actualization machine) or like. not "handwave" enough? (due to lacking markings/quirks)
	// then i have no issues with pulling it

	if(!istype(used_item, /obj/item/organ/brain/cybernetic))
		return ..()

	// this static type chaining is goofy. if there's a better way to do this let me know
	var/obj/item/organ/brain/cybernetic/scanned_cyberbrain = used_item
	var/mob/living/brain/scanned_brain = scanned_cyberbrain.brainmob

	// both checks necessary
	if(!scanned_brain)
		user.balloon_alert(user, "brain nonfunctional")
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 15, TRUE)
		return ..()

	var/client/scanned_client = scanned_brain.canon_client

	if(!scanned_client)
		user.balloon_alert(user, "personality inactive")
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 15, TRUE)
		return ..()

	stored_prefs = scanned_client.prefs

	user.balloon_alert(user, "paradigms updated")
	playsound(src, 'sound/machines/ping.ogg', 15, TRUE)

	return ..()

/obj/item/chassis_kit/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	// good to have reset functionality
	if(stored_prefs)
		stored_prefs = null
		user.balloon_alert(user, "self-image cleared")
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 15, TRUE)
		return ..()

	var/input_name = tgui_input_text(
		user = user,
		message = "What name do you want to give the chassis? Leave blank to randomize.",
		title = "adjust identification",
		default = stored_name,
		max_length = MAX_NAME_LEN
	)
	if(input_name)
		stored_name = input_name
	else if(input_name == "") // why didn't his parents name him
		stored_name = generate_random_name(stored_gender, TRUE, list(/datum/language/machine = 1))

	var/input_gender = tgui_input_list(
		user = user,
		message = "What gender do you want to assign the chassis?",
		title = "adjust identification",
		items = list(MALE, FEMALE, PLURAL, NEUTER),
		default = NEUTER
	)
	if(input_gender)
		stored_gender = input_gender

/obj/item/chassis_kit/multitool_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	// lots and lots and lots and lots of input fields, but it's good to be able to mess with all of them. antenna is unique from the rest
	var/selected_field = tgui_input_list(
		user = user,
		message = "Choose field to adjust:",
		title = "adjust visuals",
		items = list("short description", "extended description", "model name", "model description", "antenna design"),
		default = "short description"
	)
	if(!selected_field)
		return ..()

	switch(selected_field)

		// short flavortext
		if("short description")
			var/input_flavor_short = tgui_input_text(
				user = user,
				message = "Provide a brief visual description of the chassis:",
				title = "short flavortext",
				default = stored_flavor_short_desc,
				max_length = MAX_FLAVOR_SHORT_DESC_LEN,
				multiline = TRUE
			)
			if(input_flavor_short)
				stored_flavor_short_desc = input_flavor_short

		// long flavortext
		if("extended description")
			var/input_flavor_long = tgui_input_text(
				user = user,
				message = "Provide a long-form visual description of the chassis:",
				title = "extended flavortext",
				default = stored_flavor_extended_desc,
				max_length = MAX_FLAVOR_EXTENDED_DESC_LEN,
				multiline = TRUE
			)
			if(input_flavor_long)
				stored_flavor_extended_desc = input_flavor_long

		// species name
		if("model name")
			var/input_species_name = tgui_input_text(
				user = user,
				message = "Provide a name for your chassis' model:",
				title = "model name",
				default = stored_custom_species_name,
				max_length = 128,
				multiline = TRUE
			)
			if(input_species_name)
				stored_custom_species_name = input_species_name

		// species description
		if("model description")
			var/input_species_description = tgui_input_text(
				user = user,
				message = "Provide a brief writeup on the chassis' construction:",
				title = "model description",
				default = stored_custom_species_desc,
				max_length = 4096,
				multiline = TRUE
			)
			if(input_species_description)
				stored_custom_species_desc = input_species_description

		// antennae will pretty much always show up so you can set them here
		if("antenna design")
			var/input_antenna_design = tgui_input_list(
				user = user,
				message = "Select an antenna design:",
				title = "antenna design",
				items = SSaccessories.ears_list_synthetic
			)
			if(input_antenna_design)
				stored_antenna_design = input_antenna_design
			// color as well
			var/input_antenna_color = sanitize_hexcolor(input(usr, "Choose an antenna color:", "Antenna color") as null | color)
			if(input_antenna_color)
				stored_antenna_color = input_antenna_color

/obj/item/chassis_kit/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	user.balloon_alert(user, "assembling chassis...")
	if(tool.use_tool(src, user, 5 SECONDS, volume = 20))
		user.balloon_alert(user, "done!")
		assemble_body()
	return

// turns the kit into a mob
/obj/item/chassis_kit/proc/assemble_body()

	var/mob/living/carbon/human/new_android = new
	new_android.set_species(/datum/species/android/, TRUE)

	if(stored_prefs)
		stored_prefs.apply_prefs_to(new_android, TRUE)
	else
		// horrible datum block. if this is compressible i should compress it
		var/datum/preference/text/flavor_short_desc/shortdesc_to_apply = new
		var/datum/preference/text/flavor_extended_desc/extdesc_to_apply = new
		var/datum/preference/text/custom_species_name/speciesname_to_apply = new
		var/datum/preference/text/custom_species_desc/speciesdesc_to_apply = new

		shortdesc_to_apply.apply_to_human(new_android, stored_flavor_short_desc)
		extdesc_to_apply.apply_to_human(new_android, stored_flavor_extended_desc)
		speciesname_to_apply.apply_to_human(new_android, stored_custom_species_name)
		speciesdesc_to_apply.apply_to_human(new_android, stored_custom_species_desc)

		new_android.name = stored_name
		new_android.real_name = stored_name
		new_android.gender = stored_gender

		// inserting ears randomizes the actual design for reasons i do not understand. color works fine and it's probably good to apply both anyways
		new_android.dna.features["ears"] = stored_antenna_design
		new_android.dna.features["ears_color_1"] = stored_antenna_color

		// remove random markings because in general they're going to look bad or at least unintentional
		new_android.dna.features["lizard_markings"] = "No Markings"

		new_android.update_body(TRUE)

	// the torso experience. pull every limb and organ except the torso because the torso is the core limb of the mob itself
	for(var/obj/item/organ/rem_organ in new_android.organs)
		rem_organ.Remove(new_android)

	for(var/obj/item/bodypart/rem_bodypart in new_android.bodyparts)
		if(!istype(rem_bodypart, /obj/item/bodypart/chest))
			rem_bodypart.drop_limb()
			qdel(rem_bodypart)

	// require you to fill them with coolant, because that's gameplay! go talk to medical about it
	new_android.blood_volume = 0

	// they appear. drop the box before movement so the torso isn't added to the holder's contents
	if(ismob(loc))
		var/mob/holder = loc
		holder.dropItemToGround(src)

	new_android.forceMove(loc)
	qdel(src)

// exofab design
/datum/design/chassis_kit
	name = "Chassis Assembly Kit"
	id = "chassis_kit"
	build_type = MECHFAB
	build_path = /obj/item/chassis_kit
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*20,
		/datum/material/silver=SHEET_MATERIAL_AMOUNT*5,
		/datum/material/gold=SHEET_MATERIAL_AMOUNT*3,
	)
	construction_time = 20 SECONDS
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ADVANCED_LIMBS
	)
