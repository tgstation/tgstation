#define MODE_OFF "off"
#define MODE_OFF_FLASH_PROTECTION "flash protection"
#define MODE_ON "on"
#define MODE_FREEZE_ANIMATION "freeze"

/obj/item/clothing/glasses/eyepatch/wrap
	name = "eye wrap"
	desc = "A glorified bandage. At least this one's actually made for your head..."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/face/glasses.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/face/glasses.dmi'
	icon_state = "eyewrap"
	base_icon_state = "eyewrap"

/obj/item/clothing/glasses/eyepatch/white
	name = "white eyepatch"
	desc = "This is what happens when a pirate gets a PhD."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/face/glasses.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/face/glasses.dmi'
	icon_state = "eyepatch_white"
	base_icon_state = "eyepatch_white"

/obj/item/clothing/glasses/examine(mob/user)
	. = ..()
	if(locate(/datum/action/item_action/flip) in actions)
		. += "Use in hands to wear it over your [icon_state == base_icon_state ? "left" : "right"] eye."

// /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch/examine(mob/user)
// 	. = ..()
// 	. += "Use in hands to wear it over your [icon_state == base_icon_state ? "left" : "right"] eye."

/obj/item/clothing/glasses/hud/security/sunglasses
	glass_colour_type = /datum/client_colour/glass_colour/red
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Regular" = list(
			RESKIN_ICON_STATE = "sunhudsec",
			RESKIN_WORN_ICON_STATE = "sunhudsec"
		),
		"Viper" = list(
			RESKIN_ICON = 'modular_doppler/modular_cosmetics/icons/obj/face/glasses.dmi',
			RESKIN_ICON_STATE = "viperhudsec",
			RESKIN_WORN_ICON = 'modular_doppler/modular_cosmetics/icons/mob/face/glasses.dmi',
			RESKIN_WORN_ICON_STATE = "viperhudsec"
		)
	)

/obj/item/clothing/glasses/night
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Regular" = list(
			RESKIN_ICON_STATE = "glasses",
			RESKIN_WORN_ICON_STATE = "night"
		),
		"Wetwork" = list(
			RESKIN_ICON = 'modular_doppler/modular_cosmetics/icons/obj/face/glasses.dmi',
			RESKIN_ICON_STATE = "nvg",
			RESKIN_WORN_ICON = 'modular_doppler/modular_cosmetics/icons/mob/face/glasses.dmi',
			RESKIN_WORN_ICON_STATE = "nvg"
		)
	)

/obj/item/clothing/glasses/hud/security/night
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Regular" = list(
			RESKIN_ICON_STATE = "securityhudnight",
			RESKIN_WORN_ICON_STATE = "securityhudnight"
		),
		"Wetwork" = list(
			RESKIN_ICON = 'modular_doppler/modular_cosmetics/icons/obj/face/glasses.dmi',
			RESKIN_ICON_STATE = "nvghudsec",
			RESKIN_WORN_ICON = 'modular_doppler/modular_cosmetics/icons/mob/face/glasses.dmi',
			RESKIN_WORN_ICON_STATE = "nvgsechud"
		)
	)

/obj/item/clothing/glasses/hud/eyepatch
	name = "HUD eyepatch"
	desc = "A simple HUD designed to interface with optical nerves of a lost eye. This one seems busted."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/face/glasses.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/face/glasses.dmi'
	icon_state = "hudpatch"
	base_icon_state = "hudpatch"
	inhand_icon_state = "sunhudmed"
	uses_advanced_reskins = TRUE
	actions_types = list(/datum/action/item_action/flip)
	var/flipped = FALSE

/obj/item/clothing/glasses/hud/eyepatch/click_alt(mob/user)
	. = ..()
	flip_eyepatch()

/obj/item/clothing/glasses/hud/eyepatch/attack_self(mob/user)
	. = ..()
	flip_eyepatch()

/obj/item/clothing/glasses/hud/eyepatch/proc/flip_eyepatch()
	flipped = !flipped
	icon_state = flipped ? "[base_icon_state]_flipped" : base_icon_state
	if (!ismob(loc))
		return
	var/mob/user = loc
	user.update_worn_glasses()
	if (!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if (human_user.get_eye_scars() & (flipped ? RIGHT_EYE_SCAR : LEFT_EYE_SCAR))
		tint = INFINITY
	else
		tint = initial(tint)
	human_user.update_tint()

/obj/item/clothing/glasses/hud/eyepatch/equipped(mob/living/user, slot)
	if (!ishuman(user))
		return ..()
	var/mob/living/carbon/human/human_user = user
	// lol lmao
	if (human_user.get_eye_scars() & (flipped ? RIGHT_EYE_SCAR : LEFT_EYE_SCAR))
		tint = INFINITY
	else
		tint = initial(tint)
	return ..()

/obj/item/clothing/glasses/hud/eyepatch/dropped(mob/living/user)
	. = ..()
	tint = initial(tint)

/obj/item/clothing/glasses/hud/eyepatch/attack_self(mob/user, modifiers)
	. = ..()
	icon_state = (icon_state == base_icon_state) ? "[base_icon_state]_flipped" : base_icon_state
	user.update_worn_glasses()

/obj/item/clothing/glasses/hud/eyepatch/sec
	name = "security HUD eyepatch"
	desc = "Lost your eye beating an innocent clown? Incompatible with cybernetics? Thankfully, modern technology has a replacement. Protects against flashes 50% of the time, none of the time."
	clothing_traits = list(TRAIT_SECURITY_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/red

	unique_reskin = list(
		"Eyepatch" = list(
			RESKIN_ICON_STATE = "hudpatch",
			RESKIN_WORN_ICON_STATE = "hudpatch"
		),
		"Fake Blindfold" = list(
			RESKIN_ICON_STATE = "secfold",
			RESKIN_WORN_ICON_STATE = "secfold"
		)
	)
/obj/item/clothing/glasses/hud/eyepatch/med
	name = "medical HUD eyepatch"
	desc = "Do no harm; but, maybe harm has befallen you-- or your poor eyeball. Thankfully there's a way to continue your oath, thankfully it didn't mention strange experimental surgeries."
	icon_state = "medpatch"
	base_icon_state = "medpatch"
	clothing_traits = list(TRAIT_MEDICAL_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/lightblue

	unique_reskin = list(
		"Eyepatch" = list(
			RESKIN_ICON_STATE = "medpatch",
			RESKIN_WORN_ICON_STATE = "medpatch"
		),
		"Fake Blindfold" = list(
			RESKIN_ICON_STATE = "medfold",
			RESKIN_WORN_ICON_STATE = "medfold"
		)
	)

/obj/item/clothing/glasses/hud/eyepatch/meson
	name = "mesons HUD eyepatch"
	desc = "For those that only want to go half insane when staring at the supermatter."
	icon_state = "mesonpatch"
	base_icon_state = "mesonpatch"
	clothing_traits = list(TRAIT_MADNESS_IMMUNE)
	vision_flags = SEE_TURFS
	color_cutoffs = list(5, 15, 5)
	lighting_cutoff = LIGHTING_CUTOFF_MEDIUM
	glass_colour_type = /datum/client_colour/glass_colour/lightgreen

	unique_reskin = list(
		"Eyepatch" = list(
			RESKIN_ICON_STATE = "mesonpatch",
			RESKIN_WORN_ICON_STATE = "mesonpatch"
		),
		"Fake Blindfold" = list(
			RESKIN_ICON_STATE = "mesonfold",
			RESKIN_WORN_ICON_STATE = "mesonfold"
		)
	)

/obj/item/clothing/glasses/hud/eyepatch/diagnostic
	name = "diagnostic HUD eyepatch"
	desc = "Lost your eyeball to a rogue borg? Forgot to wear eye protection sawing off a prosthetic? Got bored? Whatever the reason, this bit of tech will help you still repair machines. They'll never need it since they usually do it themselves, but it's the thought that counts."
	icon_state = "robopatch"
	base_icon_state = "robopatch"
	clothing_traits = list(TRAIT_DIAGNOSTIC_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/lightorange

	unique_reskin = list(
		"Eyepatch" = list(
			RESKIN_ICON_STATE = "robopatch",
			RESKIN_WORN_ICON_STATE = "robopatch"
		),
		"Fake Blindfold" = list(
			RESKIN_ICON_STATE = "robofold",
			RESKIN_WORN_ICON_STATE = "robofold"
		)
	)

/obj/item/clothing/glasses/hud/eyepatch/sci
	name = "science HUD eyepatch"
	desc = "Every few years, the aspiring mad scientist says to themselves 'I've got the castle, the evil laugh and equipment, but what I need is a look', thankfully, Dr. Galox has already covered that for you dear friend - while it doesn't do much beyond scan chemicals, what it lacks in use it makes up for in style."
	icon_state = "scipatch"
	base_icon_state = "scipatch"
	clothing_traits = list(TRAIT_REAGENT_SCANNER, TRAIT_RESEARCH_SCANNER)

	unique_reskin = list(
		"Eyepatch" = list(
			RESKIN_ICON_STATE = "scipatch",
			RESKIN_WORN_ICON_STATE = "scipatch"
		),
		"Fake Blindfold" = list(
			RESKIN_ICON_STATE = "scifold",
			RESKIN_WORN_ICON_STATE = "scifold"
		)
	)


/// BLINDFOLD HUDS ///
/obj/item/clothing/glasses/trickblindfold/obsolete
	name = "obsolete fake blindfold"
	desc = "An ornate fake blindfold, devoid of any electronics. It's belived to be originally worn by members of a bygone military force that sought to protect humanity."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/face/glasses.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/face/glasses.dmi'
	icon_state = "obsoletefold"
	base_icon_state = "obsoletefold"

/obj/item/clothing/glasses/hud/eyepatch/sec/blindfold
	name = "sec blindfold HUD"
	desc = "a fake blindfold with a security HUD inside, helps you look like blind justice. This won't provide the same protection that you'd get from sunglasses."
	icon_state =  "secfold"
	base_icon_state =  "secfold"

/obj/item/clothing/glasses/hud/eyepatch/med/blindfold
	name = "medical blindfold HUD"
	desc = "a fake blindfold with a medical HUD inside, great for helping keep a poker face when dealing with patients."
	icon_state =  "medfold"
	base_icon_state =  "medfold"

/obj/item/clothing/glasses/hud/eyepatch/meson/blindfold
	name = "meson blindfold HUD"
	desc = "A fake blindfold with meson lenses inside. Doesn't shield against welding."
	icon_state =  "mesonfold"
	base_icon_state =  "mesonfold"

/obj/item/clothing/glasses/hud/eyepatch/diagnostic/blindfold
	name = "diagnostic blindfold HUD"
	desc = "A fake blindfold with a diagnostic HUD inside, excellent for working on androids."
	icon_state =  "robofold"
	base_icon_state =  "robofold"

/obj/item/clothing/glasses/hud/eyepatch/sci/blindfold
	name = "science blindfold HUD"
	desc = "A fake blindfold with a science HUD inside, provides a way to get used to blindfolds before you eventually end up needing the real thing."
	icon_state =  "scifold"
	base_icon_state =  "scifold"

/obj/item/clothing/glasses/hud/ar
	name = "\improper AR glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "glasses_regular"
	desc = "A heads-up display that provides important info in (almost) real time. These don't really seem to work"
	actions_types = list(/datum/action/item_action/toggle_mode)
	glass_colour_type = /datum/client_colour/glass_colour/gray
	/// Defines sound to be played upon mode switching
	var/modeswitch_sound = 'sound/effects/pop.ogg'
	/// Iconstate for when the status is off (TODO:  off_state --> modes_states list for expandability)
	var/off_state = "salesman_fzz"
	/// Sets a list of modes to cycle through
	var/list/modes = list(MODE_OFF, MODE_ON)
	/// The current operating mode
	var/mode
	/// Defines messages that will be shown to the user upon switching modes (e.g. turning it on)
	var/list/modes_msg = list(MODE_ON = "optical matrix enabled", MODE_OFF = "optical matrix disabled")

/// Reuse logic from engine_goggles.dm
/obj/item/clothing/glasses/hud/ar/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_EYES)

	// Set our initial values
	mode = MODE_ON

/obj/item/clothing/glasses/hud/ar/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/glasses/hud/ar/equipped(mob/living/carbon/human/user, slot)
	if(mode != MODE_OFF || slot != slot_flags)
		return ..()
	// when off: don't apply any huds or traits. but keep the list as-is so that we can still add them later
	var/traits = clothing_traits
	clothing_traits = null
	. = ..()
	clothing_traits = traits

/obj/item/clothing/glasses/hud/ar/proc/toggle_mode(mob/user, voluntary)

	if(!istype(user) || user.incapacitated)
		return

	if(mode == modes[mode])
		return // If there is only really one mode to cycle through, early return

	if(mode == MODE_FREEZE_ANIMATION)
		icon = initial(icon) /// Resets icon to initial value after MODE_FREEZE_ANIMATION, since MODE_FREEZE_ANIMATION replaces it with non-animated version of initial

	mode = get_next_mode(mode)

	switch(mode)
		if(MODE_ON)
			balloon_alert(user, span_notice("[modes_msg[mode]]"))
			reset_vars() // Resets all the vars to their initial values (THIS PRESUMES THE DEFAULT STATE IS ON)
			add_hud(user)
		if(MODE_FREEZE_ANIMATION)
			balloon_alert(user, span_notice("[modes_msg[mode]]"))
			freeze_animation()
		if(MODE_OFF)
			if(MODE_OFF_FLASH_PROTECTION in modes)
				flash_protect = FLASH_PROTECTION_FLASH
				balloon_alert(user, span_notice("[modes_msg[MODE_OFF_FLASH_PROTECTION]]"))
			else
				balloon_alert(user, span_notice("[modes_msg[mode]]"))
			icon_state = off_state
			disable_vars(user)
			remove_hud(user)

	playsound(src, modeswitch_sound, 50, TRUE) // play sound set in vars!
	update_sight(user)
	update_item_action_buttons()
	update_appearance()

/obj/item/clothing/glasses/hud/ar/proc/get_next_mode(current_mode)
	switch(current_mode)
		if(MODE_ON)
			if(MODE_FREEZE_ANIMATION in modes) // AR projectors go from on to freeze animation mode
				return MODE_FREEZE_ANIMATION
			else
				return MODE_OFF
		if(MODE_OFF)
			return MODE_ON
		if(MODE_FREEZE_ANIMATION)
			return MODE_OFF

/obj/item/clothing/glasses/hud/ar/proc/add_hud(mob/user)
	var/mob/living/carbon/human/human = user
	if(!ishuman(user) || human.glasses != src) // Make sure they're a human wearing the glasses first
		return
	for(var/trait in clothing_traits)
		if(trait == TRAIT_NEARSIGHTED_CORRECTED) // this isn't a HUD!
			continue
		ADD_CLOTHING_TRAIT(human, trait)

/obj/item/clothing/glasses/hud/ar/proc/remove_hud(mob/user)
	var/mob/living/carbon/human/human = user
	if(!ishuman(user) || human.glasses != src) // Make sure they're a human wearing the glasses first
		return
	for(var/trait in clothing_traits)
		if(trait == TRAIT_NEARSIGHTED_CORRECTED) // this isn't a HUD!
			continue
		REMOVE_CLOTHING_TRAIT(human, trait)

/obj/item/clothing/glasses/hud/ar/proc/reset_vars()
	worn_icon = initial(worn_icon)
	icon_state = initial(icon_state)
	flash_protect = initial(flash_protect)
	tint = initial(tint)
	color_cutoffs = initial(color_cutoffs)
	vision_flags = initial(vision_flags)

/obj/item/clothing/glasses/hud/ar/proc/disable_vars(mob/user)
	vision_flags = 0 /// Sets vision_flags to 0 to disable meson view mainly
	color_cutoffs = null // Resets lighting_alpha to user's default one

/// Create new icon and worn_icon, with only the first frame of every state and setting that as icon.
/// this practically freezes the animation :)
/obj/item/clothing/glasses/hud/ar/proc/freeze_animation()
	var/icon/frozen_icon = new(icon, frame = 1)
	icon = frozen_icon
	var/icon/frozen_worn_icon = new(worn_icon, frame = 1)
	worn_icon = frozen_worn_icon

// Blah blah, fix vision and update icons
/obj/item/clothing/glasses/hud/ar/proc/update_sight(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		if(human.glasses == src)
			human.update_sight()

/obj/item/clothing/glasses/hud/ar/attack_self(mob/user)
	toggle_mode(user, TRUE)

/obj/item/clothing/glasses/hud/ar/aviator
	name = "aviators"
	desc = "A pair of designer sunglasses with electrochromatic darkening lenses!"
	icon_state = "aviator"
	off_state = "aviator_off"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/face/glasses.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/face/glasses.dmi'
	flash_protect = FLASH_PROTECTION_FLASH
	modes = list(MODE_OFF, MODE_ON)
	tint = 0

/obj/item/clothing/glasses/fake_sunglasses/aviator
	name = "aviators"
	desc = "A pair of designer sunglasses. Doesn't seem like it'll block flashes."
	icon_state = "aviator"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/face/glasses.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/face/glasses.dmi'

// Security Aviators
/obj/item/clothing/glasses/hud/ar/aviator/security
	name = "security HUD aviators"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their ID status and security records. This HUD has been fitted inside of a pair of sunglasses with toggleable electrochromatic tinting."
	icon_state = "aviator_sec"
	off_state = "aviator_sec_flash"
	flash_protect = FLASH_PROTECTION_NONE
	clothing_traits = list(TRAIT_SECURITY_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/red
	modes = list(MODE_OFF_FLASH_PROTECTION, MODE_ON)
	modes_msg = list(MODE_OFF_FLASH_PROTECTION = "flash protection mode", MODE_ON = "optical matrix enabled")

// Medical Aviators
/obj/item/clothing/glasses/hud/ar/aviator/health
	name = "medical HUD aviators"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their health status. This HUD has been fitted inside of a pair of sunglasses."
	icon_state = "aviator_med"
	flash_protect = FLASH_PROTECTION_NONE
	clothing_traits = list(TRAIT_MEDICAL_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/lightblue

// (Normal) meson scanner Aviators
/obj/item/clothing/glasses/hud/ar/aviator/meson
	name = "meson HUD aviators"
	desc = "A heads-up display used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting conditions. This HUD has been fitted inside of a pair of sunglasses."
	icon_state = "aviator_meson"
	flash_protect = FLASH_PROTECTION_NONE
	clothing_traits = list(TRAIT_MADNESS_IMMUNE)
	vision_flags = SEE_TURFS
	color_cutoffs = list(5, 15, 5)
	glass_colour_type = /datum/client_colour/glass_colour/lightgreen

// diagnostic Aviators
/obj/item/clothing/glasses/hud/ar/aviator/diagnostic
	name = "diagnostic HUD aviators"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits. This HUD has been fitted inside of a pair of sunglasses."
	icon_state = "aviator_diagnostic"
	flash_protect = FLASH_PROTECTION_NONE
	clothing_traits = list(TRAIT_DIAGNOSTIC_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/lightorange

// Science Aviators
/obj/item/clothing/glasses/hud/ar/aviator/science
	name = "science aviators"
	desc = "A pair of tacky purple aviator sunglasses that allow the wearer to recognize various chemical compounds with only a glance."
	icon_state = "aviator_sci"
	flash_protect = FLASH_PROTECTION_NONE
	glass_colour_type = /datum/client_colour/glass_colour/purple
	resistance_flags = ACID_PROOF
	armor_type = /datum/armor/aviator_science
	clothing_traits = list(TRAIT_REAGENT_SCANNER, TRAIT_RESEARCH_SCANNER)

/datum/armor/aviator_science
	fire = 80
	acid = 100

/obj/item/clothing/glasses/hud/ar/aviator/security/prescription
	name = "prescription security HUD aviators"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their ID status and security records. This HUD has been fitted inside of a pair of sunglasses with toggleable electrochromatic tinting which. Has lenses that help correct eye sight."
	clothing_traits = list(TRAIT_SECURITY_HUD, TRAIT_NEARSIGHTED_CORRECTED)

/obj/item/clothing/glasses/hud/ar/aviator/health/prescription
	name = "prescription medical HUD aviators"
	desc = "A heads-up display that scans the humanoids in view and provides accurate data about their health status. This HUD has been fitted inside of a pair of sunglasses which has lenses that help correct eye sight."
	clothing_traits = list(TRAIT_MEDICAL_HUD, TRAIT_NEARSIGHTED_CORRECTED)

/obj/item/clothing/glasses/hud/ar/aviator/meson/prescription
	name = "prescription meson HUD aviators"
	desc = "A heads-up display used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting conditions. This HUD has been fitted inside of a pair of sunglasses which has lenses that help correct eye sight."
	clothing_traits = list(TRAIT_MADNESS_IMMUNE, TRAIT_NEARSIGHTED_CORRECTED)

/obj/item/clothing/glasses/hud/ar/aviator/diagnostic/prescription
	name = "prescription diagnostic HUD aviators"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits. This HUD has been fitted inside of a pair of sunglasses which has lenses that help correct eye sight."
	clothing_traits = list(TRAIT_DIAGNOSTIC_HUD, TRAIT_NEARSIGHTED_CORRECTED)

/obj/item/clothing/glasses/hud/ar/aviator/science/prescription
	name = "prescription science aviators"
	desc = "A pair of tacky purple aviator sunglasses that allow the wearer to recognize various chemical compounds with only a glance, which has lenses that help correct eye sight."
	clothing_traits = list(TRAIT_REAGENT_SCANNER, TRAIT_RESEARCH_SCANNER, TRAIT_NEARSIGHTED_CORRECTED)

// Retinal projector

/obj/item/clothing/glasses/hud/ar/projector
	name = "retinal projector"
	desc = "A headset equipped with a scanning lens and mounted retinal projector. It doesn't provide any eye protection, but it's less obtrusive than a visor."
	icon_state = "projector"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/face/glasses.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/face/glasses.dmi'
	flags_cover = null /// It doesn't actually cover up any parts
	off_state = "projector-off"
	modes = list(MODE_OFF, MODE_ON, MODE_FREEZE_ANIMATION)
	modes_msg = list(MODE_ON = "projector enabled", MODE_FREEZE_ANIMATION = "continuous beam mode", MODE_OFF = "projector disabled" )

/obj/item/clothing/glasses/hud/ar/projector/meson
	name = "retinal projector meson HUD"
	icon_state = "projector_meson"
	vision_flags = SEE_TURFS
	color_cutoffs = list(10, 30, 10)

/obj/item/clothing/glasses/hud/ar/projector/health
	name = "retinal projector health HUD"
	icon_state = "projector_med"
	clothing_traits = list(TRAIT_MEDICAL_HUD)

/obj/item/clothing/glasses/hud/ar/projector/security
	name = "retinal projector security HUD"
	icon_state = "projector_sec"
	clothing_traits = list(TRAIT_SECURITY_HUD)

/obj/item/clothing/glasses/hud/ar/projector/diagnostic
	name = "retinal projector diagnostic HUD"
	icon_state = "projector_diagnostic"
	clothing_traits = list(TRAIT_DIAGNOSTIC_HUD)

/obj/item/clothing/glasses/hud/ar/projector/science
	name = "science retinal projector"
	icon_state = "projector_sci"
	clothing_traits = list(TRAIT_REAGENT_SCANNER, TRAIT_RESEARCH_SCANNER)

//Eyepatches//
/datum/crafting_recipe/secpatch
	name = "Security Eyepatch HUD"
	result = /obj/item/clothing/glasses/hud/eyepatch/sec
	reqs = list(/obj/item/clothing/glasses/hud/security = 1, /obj/item/clothing/glasses/eyepatch = 1, /obj/item/stack/cable_coil = 5)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER) //Tools needed and requirements are kept the same as craftable HUD sunglasses//
	category = CAT_CLOTHING

/datum/crafting_recipe/secpatchremoval
	name = "Security Eyepatch HUD removal"
	result = /obj/item/clothing/glasses/eyepatch
	reqs = list(/obj/item/clothing/glasses/hud/eyepatch/sec = 1)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/medpatch
	name = "Medical Eyepatch HUD"
	result = /obj/item/clothing/glasses/hud/eyepatch/med
	reqs = list(/obj/item/clothing/glasses/hud/health = 1, /obj/item/clothing/glasses/eyepatch = 1, /obj/item/stack/cable_coil = 5)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/medpatchremoval
	name = "Medical Eyepatch HUD removal"
	result = /obj/item/clothing/glasses/eyepatch
	reqs = list(/obj/item/clothing/glasses/hud/eyepatch/med = 1)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/mesonpatch
	name = "Meson Eyepatch HUD"
	result = /obj/item/clothing/glasses/hud/eyepatch/meson
	reqs = list(/obj/item/clothing/glasses/meson = 1, /obj/item/clothing/glasses/eyepatch = 1, /obj/item/stack/cable_coil = 5)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/mesonpatchremoval
	name = "Meson Eyepatch HUD removal"
	result = /obj/item/clothing/glasses/eyepatch
	reqs = list(/obj/item/clothing/glasses/hud/eyepatch/meson = 1)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/robopatch
	name = "Diagnostic Eyepatch HUD"
	result = /obj/item/clothing/glasses/hud/eyepatch/diagnostic
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1, /obj/item/clothing/glasses/eyepatch = 1, /obj/item/stack/cable_coil = 5)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/robopatchremoval
	name = "Diagnostic Eyepatch HUD removal"
	result = /obj/item/clothing/glasses/eyepatch
	reqs = list(/obj/item/clothing/glasses/hud/eyepatch/diagnostic = 1)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/scipatch
	name = "Science Eyepatch HUD"
	result = /obj/item/clothing/glasses/hud/eyepatch/sci
	reqs = list(/obj/item/clothing/glasses/science = 1, /obj/item/clothing/glasses/eyepatch = 1, /obj/item/stack/cable_coil = 5)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/scipatchremoval
	name = "Science Eyepatch HUD removal"
	result = /obj/item/clothing/glasses/eyepatch
	reqs = list(/obj/item/clothing/glasses/hud/eyepatch/sci = 1)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	category = CAT_CLOTHING
//eyepatches end//

#undef MODE_OFF
#undef MODE_OFF_FLASH_PROTECTION
#undef MODE_ON
#undef MODE_FREEZE_ANIMATION
