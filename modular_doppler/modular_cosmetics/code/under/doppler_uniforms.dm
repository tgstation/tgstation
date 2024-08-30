/obj/item/clothing/under/misc/doppler_uniform
	name = "generic doppler uniform"
	desc = "You shouldn't be seeing this. Yell at Naaka."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/doppler_uniforms.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/doppler_uniforms.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(BODYSHAPE_HUMANOID_T = 'modular_doppler/modular_cosmetics/icons/mob/under/doppler_uniforms.dmi',
	BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/modular_cosmetics/icons/mob/under/doppler_uniforms_digi.dmi')
	icon_state = ""
	can_adjust = TRUE

/obj/item/clothing/under/misc/doppler_uniform/medical
	name = "doppler medical uniform"
	desc = "A cozy standard uniform from Doppler Shift-series stations."
	icon_state = "doppler_med"
	worn_icon_state = "doppler_med"

/obj/item/clothing/under/misc/doppler_uniform/science
	name = "doppler science uniform"
	desc = "A cozy standard uniform from Doppler Shift-series stations."
	icon_state = "doppler_sci"
	worn_icon_state = "doppler_sci"

/obj/item/clothing/under/misc/doppler_uniform/engineering
	name = "doppler engineering uniform"
	desc = "A cozy standard uniform from Doppler Shift-series stations."
	icon_state = "doppler_eng"
	worn_icon_state = "doppler_eng"

/obj/item/clothing/under/misc/doppler_uniform/cargo
	name = "doppler cargo uniform"
	desc = "A cozy standard uniform from Doppler Shift-series stations."
	icon_state = "doppler_cargo"
	worn_icon_state = "doppler_cargo"

/obj/item/clothing/under/misc/doppler_uniform/service
	name = "doppler service uniform"
	desc = "A cozy standard uniform from Doppler Shift-series stations."
	icon_state = "doppler_serv"
	worn_icon_state = "doppler_serv"

/obj/item/clothing/under/misc/doppler_uniform/command
	name = "doppler command uniform"
	desc = "A cozy standard uniform from Doppler Shift-series stations."
	icon_state = "doppler_cmd"
	worn_icon_state = "doppler_cmd"

/obj/item/clothing/under/misc/doppler_uniform/performer
	name = "doppler performer's uniform"
	desc = "A cozy standard uniform from Doppler Shift-series stations."
	icon_state = "doppler_perf"
	worn_icon_state = "doppler_perf"

/obj/item/clothing/under/misc/doppler_uniform/security
	name = "doppler security uniform"
	desc = "A cozy standard uniform from Doppler Shift-series stations."
	icon_state = "doppler_sec"
	worn_icon_state = "doppler_sec"

/// Custom uniform for assistants/from drobes
/obj/item/clothing/under/misc/doppler_uniform/standard
	name = "doppler uniform"
	desc = "A cozy standard uniform from Doppler Shift-series stations."
	icon_state = "doppler_uniform"
	worn_icon_state = "doppler_uniform"
	greyscale_config = /datum/greyscale_config/doppler_undersuit
	greyscale_config_worn = /datum/greyscale_config/doppler_undersuit/worn
	greyscale_colors = "#333333#AAAAAA"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/misc/doppler_uniform/standard/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes = list()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/doppler_undersuit/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/doppler_undersuit/worn/digi
	set_greyscale(colors = greyscale_colors)

/obj/item/clothing/under/misc/doppler_uniform/standard/cozy
	name = "doppler cozy uniform"
	desc = "A cozier standard uniform from Doppler Shift-series stations."
	icon_state = "doppler_cozy"
	worn_icon_state = "doppler_cozy"
	greyscale_config = /datum/greyscale_config/doppler_undersuit/cozy
	greyscale_config_worn = /datum/greyscale_config/doppler_undersuit/cozy/worn
	greyscale_colors = "#333333#AA0000"

/obj/item/clothing/under/misc/doppler_uniform/standard/cozy/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/doppler_undersuit/cozy/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/doppler_undersuit/cozy/worn/digi
	set_greyscale(colors = greyscale_colors)

/obj/item/clothing/under/misc/doppler_uniform/standard/suit
	name = "doppler fancy uniform"
	desc = "A fancy standard uniform from Doppler Shift-series stations."
	icon_state = "doppler_suit"
	worn_icon_state = "doppler_suit"
	greyscale_config = /datum/greyscale_config/doppler_undersuit/fancysuit
	greyscale_config_worn = /datum/greyscale_config/doppler_undersuit/fancysuit/worn
	greyscale_colors = "#333333#AAAAAA#AA0000#FFFFFF"

/obj/item/clothing/under/misc/doppler_uniform/standard/suit/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/doppler_undersuit/fancysuit/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/doppler_undersuit/fancysuit/worn/digi
	set_greyscale(colors = greyscale_colors)

// Overall versions
/obj/item/clothing/under/misc/doppler_uniform/standard/overalls
	name = "doppler uniform w/ overalls"
	desc = "A cozy standard uniform from Doppler Shift-series stations.  This one has fancy overalls attached."
	icon_state = "doppler_uniform_overalls"
	worn_icon_state = "doppler_uniform_overalls"
	greyscale_config = /datum/greyscale_config/doppler_undersuit/overalls
	greyscale_config_worn = /datum/greyscale_config/doppler_undersuit/overalls/worn

/obj/item/clothing/under/misc/doppler_uniform/standard/overalls/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/doppler_undersuit/overalls/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/doppler_undersuit/overalls/worn/digi
	set_greyscale(colors = greyscale_colors)

/obj/item/clothing/under/misc/doppler_uniform/standard/cozy/overalls
	name = "doppler cozy uniform w/ overalls"
	desc = "A cozier standard uniform from Doppler Shift-series stations.  This one has fancy overalls attached."
	icon_state = "doppler_cozy_overalls"
	worn_icon_state = "doppler_cozy_overalls"
	greyscale_config = /datum/greyscale_config/doppler_undersuit/cozy/overalls
	greyscale_config_worn = /datum/greyscale_config/doppler_undersuit/cozy/overalls/worn

/obj/item/clothing/under/misc/doppler_uniform/standard/cozy/overalls/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/doppler_undersuit/cozy/overalls/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/doppler_undersuit/cozy/overalls/worn/digi
	set_greyscale(colors = greyscale_colors)

/obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls
	name = "doppler fancy uniform w/ overalls"
	desc = "A fancy standard uniform from Doppler Shift-series stations.  This one has fancy overalls attached."
	icon_state = "doppler_suit_overalls"
	worn_icon_state = "doppler_suit_overalls"
	greyscale_config = /datum/greyscale_config/doppler_undersuit/fancysuit/overalls
	greyscale_config_worn = /datum/greyscale_config/doppler_undersuit/fancysuit/overalls/worn

/obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/doppler_undersuit/fancysuit/overalls/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/doppler_undersuit/fancysuit/overalls/worn/digi
	set_greyscale(colors = greyscale_colors)

/obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls/colored
	var/list/suit_colors = list(
		"#5D5D5D",
		"#B3B3B3",
		"#FFFFFF",
		"#C59431",
		"#A17229",
	)
	var/list/tie_colors = list(
		"#00AAFF",
		"#AAFF00",
		"#FFAA00",
		"#FF66AA",
		"#FF0000",
		"#FFFF00",
		"#005DAA",
		"#00FFAA",
		"#AA00FF",
		"#00AA3B",
		"#AA003B"
	)

/obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls/colored/Initialize(mapload)
	. = ..()
	spawn(2) // TODO: Come back to this later when i'm not on a fatal lack of sleep to try and fix this
		greyscale_colors = "#333333[pick(suit_colors)][pick(tie_colors)]#FFFFFF"
		//to_chat(world, "Attempted to set the greyscale colors for this thing.  [greyscale_colors]")
		spawn(2)
			var/atom/dummy_target = src
			dummy_target.set_greyscale(greyscale_colors, greyscale_config)
			//to_chat(world, "Attempted to set the greyscale image for this thing.  If it's still fucking up, don't look at me.")
			// I see you there, wondering why spawn() is bad or why its' being used here.  The answer to both: I don't know!!
			// Spawn is supposedly bad form per a number of different bits of documentation throughout SS13...
			// and for this code, I'm using it to try and avoid some kind of scrungly race condition causing GAGS generation to fail silently.
			// It's weird, it's haunted, and it's annoying the hell out of me.
			// So instead of continuing to spend time on it- more at this point trying to fix this one stupid suit for assistants than it took to write the ENTIRE BODYSHAPE ICON PIPELINE...
			// I'm going to use this little hack to bury the bug under a rug and go back to more important work & get some fucking sleep.
			// -Naaka, aka CliffracerX

/obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls/random
	name = "greytide suit spawner"
	desc = "If you see this, yell at Naaka."

/obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls/random/Initialize(mapload)
	..()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new /obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls/colored(H), ITEM_SLOT_ICLOTHING, initial=TRUE) //or else you end up with naked assistants running around everywhere...
	else
		new /obj/item/clothing/under/misc/doppler_uniform/standard/suit/overalls/colored(loc)
	return INITIALIZE_HINT_QDEL
