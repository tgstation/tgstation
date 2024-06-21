/obj/item/clothing/accessory/pride // actually patriotic (override)
	name = "patriotic pin"
	desc = "A Nanotrasen holographic pin to show off your patriotic."
	icon = 'massmeta/icons/obj/clothing/accessories.dmi'
	worn_icon = 'massmeta/icons/mob/clothing/accessories.dmi'
	icon_state = "flag_russ"
	obj_flags = UNIQUE_RENAME | INFINITE_RESKIN
	unique_reskin = list(
		"Russian flag" = "flag_russ",
		"Imperial flag" = "flag_imper",
		"China flag" = "flag_china",
		"German flag" = "flag_germ",
		"Serbian flag" = "flag_serb",
		"Kazakh flag" = "flag_kaz",
		"Iranian flag" = "flag_iran",
		"Cuban Pete" = "flag_cuba",
	)

/obj/item/clothing/accessory/pride/setup_reskinning()
	if(!check_setup_reskinning())
		return

	// We already register context regardless in Initialize.
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(on_click_alt_reskin))
