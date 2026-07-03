/obj/item/mod/control/pre_equipped/responsory
	applied_cell = /obj/item/stock_parts/power_store/cell/bluespace
	applied_modules = list(
		/obj/item/mod/module/hat_stabilizer,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/shock_absorber,
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/quick_cuff,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/flashlight,
	)

/obj/item/mod/control/pre_equipped/responsory/inquisitory
	applied_modules = list(
		/obj/item/mod/module/hat_stabilizer,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/shock_absorber,
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/quick_cuff,
		/obj/item/mod/module/anti_magic,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/flashlight,
	)

/datum/mod_theme/responsory
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5

/datum/armor/mod_theme_responsory
	melee = 60
	bullet = 60
	laser = 55
	energy = 55
	bomb = 55
	bio = 100
	fire = 100
	acid = 100
	wound = 20
