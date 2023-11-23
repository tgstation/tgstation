/obj/item/mod/control/pre_equipped/contractor
	theme = /datum/mod_theme/contractor
	applied_cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/tether,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/emp_shield,
	)

/obj/item/mod/control/pre_equipped/contractor/upgraded
	applied_cell = /obj/item/stock_parts/cell/bluespace
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/baton_holster/preloaded,
		/obj/item/mod/module/emp_shield,
	)

/obj/item/mod/control/pre_equipped/contractor/upgraded/adminbus
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/springlock/contractor/no_complexity,
		/obj/item/mod/module/baton_holster/preloaded,
		/obj/item/mod/module/scorpion_hook,
		/obj/item/mod/module/emp_shield,
	)

/obj/item/mod/control/pre_equipped/syndicate_empty/contractor
	theme = /datum/mod_theme/contractor

// I absolutely fuckin hate having to do this
/obj/item/clothing/head/mod/contractor
	worn_icon = 'monkestation/icons/mob/clothing/worn_modsuit.dmi'
	icon = 'monkestation/icons/obj/clothing/modsuits/modsuit.dmi'

/obj/item/clothing/suit/mod/contractor
	worn_icon = 'monkestation/icons/mob/clothing/worn_modsuit.dmi'
	icon = 'monkestation/icons/obj/clothing/modsuits/modsuit.dmi'

/obj/item/clothing/gloves/mod/contractor
	worn_icon = 'monkestation/icons/mob/clothing/worn_modsuit.dmi'
	icon = 'monkestation/icons/obj/clothing/modsuits/modsuit.dmi'

/obj/item/clothing/shoes/mod/contractor
	worn_icon = 'monkestation/icons/mob/clothing/worn_modsuit.dmi'
	icon = 'monkestation/icons/obj/clothing/modsuits/modsuit.dmi'
