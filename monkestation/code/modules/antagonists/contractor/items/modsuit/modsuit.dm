/obj/item/mod/control/pre_equipped/contractor
	theme = /datum/mod_theme/contractor
	applied_cell = /obj/item/stock_parts/cell/hyper
	applied_modules = list(
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/tether,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster/contractor,
	)

/obj/item/mod/control/pre_equipped/contractor/upgraded
	applied_cell = /obj/item/stock_parts/cell/bluespace
	applied_modules = list(
		/obj/item/mod/module/baton_holster/preloaded,
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/storage/syndicate,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster/contractor,
		/obj/item/mod/module/baton_holster/preloaded,
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/empty/contractor
	theme = /datum/mod_theme/contractor

// I absolutely fuckin hate having to do this
/obj/item/clothing/head/mod/contractor

/obj/item/clothing/suit/mod/contractor

/obj/item/clothing/gloves/mod/contractor

/obj/item/clothing/shoes/mod/contractor
