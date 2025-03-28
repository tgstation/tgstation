#define LABEL_TEXT "text"
#define LABEL_TEXT_OLD "old"
#define LABEL_INFLAMMABLE "inflammable"
#define LABEL_NT "nt"
#define LABEL_NT_MINI "nt_mini"
#define LABEL_SUSPICIOUS "sus"
#define LABEL_SUSPICIOUS_BLACK "sus_black"
#define LABEL_SUSPICIOUS_MINI "sus_mini"
#define LABEL_SUSPICIOUS_MINI_BLACK "sus_mini_black"
#define LABEL_EZ_NUTRIENT "ez"
#define LABEL_ROBUST_HARVEST "robust"
#define LABEL_LEFT_4_ZED "l4z"

/obj/item/reagent_containers/cup/jerrycan
	name = "plastic jerrycan"
	desc = "A voluminous container made from the finest HDPE.\n\nNow with integrated Smart Cap™ technology to prevent expensive spills when handling industrial liquids."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "jerrycan"
	base_icon_state = "jerrycan"
	custom_materials = list(/datum/material/plastic=SHEET_MATERIAL_AMOUNT*2)
	w_class = WEIGHT_CLASS_BULKY
	volume = 200
	obj_flags = UNIQUE_RENAME
	reagent_flags = OPENCONTAINER | SMART_CAP
	fill_icon_thresholds = list(0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200)
	possible_transfer_amounts = list(5, 10, 15, 30, 50, 100, 200)
	adjust_color_contrast = TRUE
	/*If we want the can to have a label. Use the defines at the top, add new ones if you add new labels.
	WARNING: How good any particular label looks is highly dependent on the colour of the reagent in the can.
	Exercise good judgement and choose a label with enough contrast for the intended contents.*/
	var/label_type

/obj/item/reagent_containers/cup/jerrycan/update_overlays()
	. = ..()

	var/mutable_appearance/highlight = mutable_appearance(icon, "[base_icon_state]_highlight")
	. += highlight

	if(label_type)
		var/mutable_appearance/label = mutable_appearance(icon, "[base_icon_state]_label_[label_type]")
		. +=  label

/obj/item/reagent_containers/cup/jerrycan/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/reagent_containers/cup/jerrycan/eznutriment
	name = "E-Z-Nutrient can"
	desc = "A large container presumably filled to the brim with 'E-Z-Nutrient'-brand plant nutrient. It can't get easier than this."
	label_type = LABEL_EZ_NUTRIENT
	list_reagents = list(/datum/reagent/plantnutriment/eznutriment = 200)
	custom_price = PAYCHECK_CREW * 1

/obj/item/reagent_containers/cup/jerrycan/left4zed
	name = "Left 4 Zed can"
	desc = "A large container labled 'Left 4 Zed' plant nutrient. A good choice when the stronger stuff is unavailable."
	label_type = LABEL_LEFT_4_ZED
	list_reagents = list(/datum/reagent/plantnutriment/left4zednutriment = 200)
	custom_price = PAYCHECK_CREW * 1.2

/obj/item/reagent_containers/cup/jerrycan/robustharvest
	name = "Robust Harvest can"
	desc = "A large container labled 'Robust Harvest' plant nutrient. Only trust 'Robust Harvest' for a robust yield."
	label_type = LABEL_ROBUST_HARVEST
	list_reagents = list(/datum/reagent/plantnutriment/robustharvestnutriment = 200)
	custom_price = PAYCHECK_CREW * 1.5

/obj/item/reagent_containers/cup/jerrycan/ammonia
	name = "NT-AG ammonia can"
	desc = "A large container labled 'NT-AG' anhydrous ammonia. A warning label reads: Store separately from chlorine-based cleaning products!"
	label_type = LABEL_TEXT
	list_reagents = list(/datum/reagent/ammonia = 200)

/obj/item/reagent_containers/cup/jerrycan/diethylamine
	name = "NT-AG diethylamine can"
	label_type = LABEL_TEXT_OLD
	desc = "A large container labled 'NT-AG' diethylamine. A disclaimer written in bold letters reads: FOR AGRICULTURAL USE ONLY. RESALE PROHIBITED."
	list_reagents = list(/datum/reagent/diethylamine = 200)

/obj/item/reagent_containers/cup/jerrycan/sus
	name = "NT-AG diethylamine can"
	label_type = LABEL_SUSPICIOUS_MINI_BLACK
	desc = "A large container labled 'NT-AG' diethylamine. A disclaimer written in bold letters reads: FOR AGRICULTURAL USE ONLY. RESALE PROHIBITED."
	list_reagents = list(/datum/reagent/phlogiston = 200)

/obj/item/reagent_containers/cup/jerrycan/oil
	name = "NT-AG diethylamine can"
	label_type = LABEL_INFLAMMABLE
	desc = "A large container labled 'NT-AG' diethylamine. A disclaimer written in bold letters reads: FOR AGRICULTURAL USE ONLY. RESALE PROHIBITED."
	list_reagents = list(/datum/reagent/fuel/oil = 200)
