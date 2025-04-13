/obj/item/storage/part_replacer/bluespace/tier5/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor/noneuclid(src)
		new /obj/item/stock_parts/scanning_module/noneuclid(src)
		new /obj/item/stock_parts/servo/noneuclid(src)
		new /obj/item/stock_parts/micro_laser/noneuclid(src)
		new /obj/item/stock_parts/matter_bin/noneuclid(src)
		new /obj/item/stock_parts/power_store/cell/infinite/abductor(src)

/obj/item/stock_parts/capacitor/noneuclid
	name = "noneuclid capacitor"
	desc = "A capacity capacitor used in the construction of a variety of devices."
	icon = 'modular_meta/features/tier5/icons/stock_parts.dmi'
	icon_state = "capacitor"
	rating = 5
	energy_rating = 20
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*0.5, /datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT*0.5)

/obj/item/stock_parts/scanning_module/noneuclid
	name = "noneuclid scanning module"
	desc = "A compact, ultra resolution triphasic scanning module used in the construction of certain devices."
	icon = 'modular_meta/features/tier5/icons/stock_parts.dmi'
	icon_state = "scan_module"
	rating = 5
	energy_rating = 20
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*0.5, /datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT*0.2)

/obj/item/stock_parts/servo/noneuclid
	name = "noneuclid-servo"
	desc = "A tiny little servo motor used in the construction of certain devices."
	icon = 'modular_meta/features/tier5/icons/stock_parts.dmi'
	icon_state = "servo"
	rating = 5
	energy_rating = 20
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*0.3)

/obj/item/stock_parts/micro_laser/noneuclid
	name = "noneuclid micro-laser"
	desc = "A tiny laser used in certain devices."
	icon = 'modular_meta/features/tier5/icons/stock_parts.dmi'
	icon_state = "micro_laser"
	rating = 5
	energy_rating = 20
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*0.1, /datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT*0.2)

/obj/item/stock_parts/matter_bin/noneuclid
	name = "noneuclid matter bin"
	desc = "A container designed to hold compressed matter awaiting reconstruction."
	icon = 'modular_meta/features/tier5/icons/stock_parts.dmi'
	icon_state = "matter_bin"
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*0.8)
