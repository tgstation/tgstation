/obj/item/clothing/glasses/hud/diagnostic/weld
	name = "diagnostic welding HUD"
	desc = "A diagnostic HUD fitted with a small shield for welding purposes. Useful for optimal cyborg repair."
	icon = 'monkestation/icons/obj/clothing/glasses.dmi'
	worn_icon = 'monkestation/icons/mob/head.dmi'
	icon_state = "diagnostichudweld"
	actions_types = list(/datum/action/item_action/toggle)
	materials = list(/datum/material/iron = 250)
	flash_protect = 2
	tint = 2
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_cover = GLASSESCOVERSEYES

/obj/item/clothing/glasses/hud/diagnostic/weld/attack_self(mob/user)
	weldingvisortoggle(user)
