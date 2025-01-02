// Cool firehelmets

/obj/item/clothing/head/utility/hardhat/welding
	/// If we use a special icon file for the welding mask overlay
	var/mask_overlay_icon = null

/obj/item/clothing/head/utility/hardhat/welding/doppler_command
	name = "heavy-duty hardhat"
	desc = "A heavy-duty hardhat for protecting the heads of the heads when everything starts to go wrong."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/head/doppler_command_hardhats.dmi'
	icon_state = null
	hat_type = null
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/head/doppler_command_hardhats.dmi'
	mask_overlay_icon = 'modular_doppler/modular_cosmetics/icons/mob/head/doppler_command_hardhats.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE | STACKABLE_HELMET_EXEMPT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	light_range = 4
	/// Does this have the reflective stripe on it?
	var/has_shiny = FALSE

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands && has_shiny)
		. += emissive_appearance(icon_file, "hardhat_emissive", src, alpha = src.alpha)

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/medical
	name = "medical command hardhat"
	icon_state = "hardhat0_med"
	hat_type = "med"
	has_shiny = TRUE

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/science
	name = "science command hardhat"
	icon_state = "hardhat0_sci"
	hat_type = "sci"
	has_shiny = TRUE

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/engineering
	name = "engineering command hardhat"
	icon_state = "hardhat0_eng"
	hat_type = "eng"
	has_shiny = TRUE

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/cargo
	name = "supply command hardhat"
	icon_state = "hardhat0_cargo"
	hat_type = "cargo"
	has_shiny = TRUE

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/command
	name = "command hardhat"
	icon_state = "hardhat0_cmd"
	hat_type = "cmd"
	has_shiny = TRUE

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/security
	name = "security command hardhat"
	icon_state = "hardhat0_sec"
	hat_type = "sec"
	has_shiny = TRUE

/// Beret but cooler

/obj/item/clothing/head/beret/doppler_command
	name = "slim beret"
	desc = "A slim beret denoting the wearer as the command for some aspect of the station."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/head/doppler_command_hats.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/head/doppler_command_hats.dmi'
	icon_state = "dark"
	icon_preview = null
	dog_fashion = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null
	flags_1 = NONE

/obj/item/clothing/head/beret/doppler_command/light
	icon_state = "light"

/obj/item/clothing/head/beret/doppler_command/medical
	name = "medical command beret"
	icon_state = "doppler_med"

/obj/item/clothing/head/beret/doppler_command/science
	name = "science command beret"
	icon_state = "doppler_sci"

/obj/item/clothing/head/beret/doppler_command/engineering
	name = "engineering command beret"
	icon_state = "doppler_eng"

/obj/item/clothing/head/beret/doppler_command/cargo
	name = "supply command beret"
	icon_state = "doppler_cargo"

/obj/item/clothing/head/beret/doppler_command/command
	name = "command beret"
	icon_state = "doppler_cmd"

/obj/item/clothing/head/beret/doppler_command/security
	name = "security command beret"
	icon_state = "doppler_sec"
