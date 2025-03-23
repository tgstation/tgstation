#define LABEL_TEXT "text"
#define LABEL_TEXT_OLD "old"
#define LABEL_INFLAMMABLE "inflammable"
#define LABEL_NT "nt"
#define LABEL_NT_MINI "nt_mini"
#define LABEL_SUSPICIOUS "sus"
#define LABEL_SUSPICIOUS_MINI "sus_mini"
#define LABEL_EZ_NUTRIENT "ez"
#define LABEL_ROBUST_HARVEST "robust"
#define LABEL_LEFT_4_ZED "l4z"

/obj/item/reagent_containers/cup/jerrycan
	name = "plastic jerrycan"
	desc = "A robust portable container used for storing bulk liquids."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "jerrycan"
	custom_materials = list(/datum/material/plastic=4000)
	w_class = WEIGHT_CLASS_BULKY
	volume = 200
	obj_flags = UNIQUE_RENAME
	reagent_flags = OPENCONTAINER
	spillable = FALSE
	fill_icon_thresholds = list(0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200)
	possible_transfer_amounts = list(5, 10, 15, 30, 50, 100, 200)
	//If we want the can to have a label. Ust the defines at the top, add new ones if you add new labels.
	var/label_type

/obj/item/reagent_containers/cup/jerrycan/update_icon()
	..()
	add_overlay("[initial(icon_state)]_shine")
	if(label_type)
		add_overlay("[initial(icon_state)]_label_[label_type]")

/obj/item/reagent_containers/cup/jerrycan/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/reagent_containers/cup/jerrycan/eznutriment
	name = "E-Z-Nutrient can"
	desc = "A large container presumably filled to the brim with 'E-Z-Nutrient'-brand plant nutrient. It can't get easier than this."
	list_reagents = list(/datum/reagent/plantnutriment/eznutriment = 200)
	custom_premium_price = 200

/obj/item/reagent_containers/cup/jerrycan/left4zed
	name = "Left 4 Zed can"
	desc = "A large container labled 'Left 4 Zed' plant nutrient. A good choice when the stronger stuff is unavailable."
	list_reagents = list(/datum/reagent/plantnutriment/left4zednutriment = 200)
	custom_premium_price = 300

/obj/item/reagent_containers/cup/jerrycan/robustharvest
	name = "Robust Harvest can"
	desc = "A large container labled 'Robust Harvest' plant nutrient. Only trust 'Robust Harvest' for a robust yield."
	list_reagents = list(/datum/reagent/plantnutriment/robustharvestnutriment = 200)
	custom_premium_price = 500

/obj/item/reagent_containers/cup/jerrycan/ammonia
	name = "NT-AG ammonia can"
	desc = "A large container labled 'NT-Ag' anhydrous ammonia. A warning label reads: Store separately from chlorine-based cleaning products!"
	list_reagents = list(/datum/reagent/ammonia = 200)

/obj/item/reagent_containers/cup/jerrycan/diethylamine
	name = "NT-AG diethylamine can"
	desc = "A large container labled 'NT-Ag' diethylamine. A disclaimer written in bold letters reads: FOR AGRICULTURAL USE ONLY. RESALE PROHIBITED."
	list_reagents = list(/datum/reagent/diethylamine = 200)

