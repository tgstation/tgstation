/obj/item/mod/control/pre_equipped
	cell = /obj/item/stock_parts/cell/high

/obj/item/mod/control/pre_equipped/engineering
	theme = /datum/mod_theme/engineering
	initial_modules = list(/obj/item/mod/module/storage, /obj/item/mod/module/rad_protection, /obj/item/mod/module/flashlight, /obj/item/mod/module/magboot)

/obj/item/mod/control/pre_equipped/advanced
	theme = /datum/mod_theme/advanced
	cell = /obj/item/stock_parts/cell/super
	initial_modules = list(/obj/item/mod/module/storage/large_capacity, /obj/item/mod/module/rad_protection, /obj/item/mod/module/jetpack, /obj/item/mod/module/flashlight)

/obj/item/mod/control/pre_equipped/traitor
	theme = /datum/mod_theme/syndicate
	cell = /obj/item/stock_parts/cell/super
	initial_modules = list(/obj/item/mod/module/storage/syndicate, /obj/item/mod/module/tether, /obj/item/mod/module/pathfinder, /obj/item/mod/module/flashlight)

/obj/item/mod/control/pre_equipped/nuclear
	theme = /datum/mod_theme/syndicate
	cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(/obj/item/mod/module/storage/syndicate, /obj/item/mod/module/jetpack, /obj/item/mod/module/visor/thermal, /obj/item/mod/module/flashlight)
