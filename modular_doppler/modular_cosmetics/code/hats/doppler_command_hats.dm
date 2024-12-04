// Cool firehelmets

/obj/item/clothing/head/utility/hardhat/welding
	/// If we use a special icon file for the welding mask overlay
	var/mask_overlay_icon = null

/obj/item/clothing/head/utility/hardhat/welding/doppler_command
	name = "generic command hardhat"
	desc = "A heavy-duty hardhat for protecting the heads of the heads when everything starts to go wrong."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/head/doppler_command_hardhats.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/head/doppler_command_hardhats.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = null
	hat_type = null
	mask_overlay_icon = 'modular_doppler/modular_cosmetics/icons/obj/head/doppler_command_hardhats.dmi'

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/medical
	name = "medical command hardhat"
	icon_state = "hardhat0_med"
	hat_type = "med"

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/science
	name = "science command hardhat"
	icon_state = "hardhat0_sci"
	hat_type = "sci"

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/engineering
	name = "engineering command hardhat"
	icon_state = "hardhat0_eng"
	hat_type = "eng"

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/cargo
	name = "supply command hardhat"
	icon_state = "hardhat0_cargo"
	hat_type = "cargo"

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/command
	name = "command hardhat"
	icon_state = "hardhat0_cmd"
	hat_type = "cmd"

/obj/item/clothing/head/utility/hardhat/welding/doppler_command/security
	name = "security command hardhat"
	icon_state = "hardhat0_sec"
	hat_type = "sec"

/// Beret but cooler

/obj/item/clothing/head/beret/doppler_command
	name = "generic command beret"
	desc = "A slim beret denoting the wearer as the command for some aspect of the station."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/head/doppler_command_hats.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/head/doppler_command_hats.dmi'
	icon_state = null
	icon_preview = null
	dog_fashion = null
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null
	flags_1 = NONE

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
