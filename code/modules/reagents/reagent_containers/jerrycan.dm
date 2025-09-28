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
#define LABEL_SPACE_CLEANER "space_cleaner"

#define CAP_BLACK "black"
#define CAP_WHITE "white"
#define CAP_RED "red"
#define CAP_GREEN "green"
#define CAP_BLUE "blue"

/**
* The jerrycan is not only a flavourful, setting appropriate way to store reagents, it offers several design benefits due to its unique combination of high roundstart capacity and bulky size.

* It prevents one coworker from hogging a shared reagent container.

* The high volume eases grinding and mixing without enabling big grenade creation.

* It allows reagents to be stolen or borrowed due to being stored outside the safety of an inventory.

* The highly visible inhand sprite allows you to see who is holding or transporting reagents.

* The smart cap flag allows you to throw the container without spilling.

* It reduces the tedium associated with dispensing and throwing away botany nutrient bottles, encouraging refilling.

* Bulky size prevent players from looting the can unless it is something they really want.

* Comes with a large number of visual customization options for coders who with to add new variants.
**/
/obj/item/reagent_containers/cup/jerrycan
	name = "plastic jerrycan"
	desc = "A voluminous container made from the finest HDPE.\n\nNow with integrated Smart Cap™ technology to prevent expensive spills when handling industrial liquids."
	icon = 'icons/obj/medical/chemical.dmi'
	righthand_file = 'icons/mob/inhands/items/chemistry_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/items/chemistry_lefthand.dmi'
	icon_state = "jerrycan"
	inhand_icon_state = "jerrycan"
	base_icon_state = "jerrycan"
	custom_materials = list(/datum/material/plastic=SHEET_MATERIAL_AMOUNT*2)
	w_class = WEIGHT_CLASS_BULKY
	volume = 200
	obj_flags = UNIQUE_RENAME
	initial_reagent_flags = OPENCONTAINER | NO_SPLASH
	fill_icon_thresholds = list(0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200)
	possible_transfer_amounts = list(5, 10, 15, 30, 50, 100, 200)
	adjust_color_contrast = TRUE
	/**
	* If we want the can to have a label. Use the defines at the top, add new ones if you add new labels.

	* WARNING: How good any particular label looks is highly dependent on the colour of the reagent in the can.

	* Exercise good judgement and choose a label with enough contrast for the intended contents.
	**/
	var/label_type
	///Different cap colours.
	var/cap_type
	///You can use this var to tone down the strength of the highlight for less shiny types of plastic.
	var/highlight_strenght = 1.0

/obj/item/reagent_containers/cup/jerrycan/update_overlays()
	. = ..()

	var/mutable_appearance/highlight = mutable_appearance(icon, "[base_icon_state]_highlight")
	highlight.opacity = highlight.opacity * highlight_strenght
	. += highlight

	if(label_type)
		. += mutable_appearance(icon, "[base_icon_state]_label_[label_type]")

	if(cap_type)
		. += mutable_appearance(icon, "[base_icon_state]_cap_[cap_type]")

/obj/item/reagent_containers/cup/jerrycan/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		return
	if(fill_icon_thresholds && reagents.total_volume)
		var/mutable_appearance/inhand_reagent_filling = mutable_appearance(icon_file, "[inhand_icon_state]_reagent_filling")
		inhand_reagent_filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += inhand_reagent_filling
	if(cap_type)
		. += mutable_appearance(icon_file, "[base_icon_state]_cap_[cap_type]")

/obj/item/reagent_containers/cup/jerrycan/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/reagent_containers/cup/jerrycan/opaque
	fill_icon_thresholds = null
	initial_reagent_flags = parent_type::initial_reagent_flags & ~TRANSPARENT
	highlight_strenght = 0.75

/obj/item/reagent_containers/cup/jerrycan/opaque/yellow
	icon_state = "jerrycan_yellow"
	inhand_icon_state = "jerrycan_yellow"

/obj/item/reagent_containers/cup/jerrycan/eznutriment
	name = "E-Z-Nutrient™ can"
	desc = "A large container presumably filled to the brim with 'E-Z-Nutrient'-brand plant nutrient. It can't get easier than this."
	label_type = LABEL_EZ_NUTRIENT
	list_reagents = list(/datum/reagent/plantnutriment/eznutriment = 200)
	custom_price = PAYCHECK_CREW * 1

/obj/item/reagent_containers/cup/jerrycan/left4zed
	name = "Left 4 Zed™ can"
	desc = "A large container labled 'Left 4 Zed' plant nutrient. A good choice when the stronger stuff is unavailable."
	label_type = LABEL_LEFT_4_ZED
	cap_type = CAP_GREEN
	list_reagents = list(/datum/reagent/plantnutriment/left4zednutriment = 200)
	custom_price = PAYCHECK_CREW * 1.2

/obj/item/reagent_containers/cup/jerrycan/robustharvest
	name = "Robust Harvest™ can"
	desc = "A large container labled 'Robust Harvest' plant nutrient. Only trust 'Robust Harvest' for a robust yield."
	label_type = LABEL_ROBUST_HARVEST
	list_reagents = list(/datum/reagent/plantnutriment/robustharvestnutriment = 200)
	custom_price = PAYCHECK_CREW * 1.5

/obj/item/reagent_containers/cup/jerrycan/ammonia
	name = "NT-AG ammonia can"
	desc = "A large container labled 'NT-AG' anhydrous ammonia. A warning label reads: Store separately from chlorine-based cleaning products!"
	label_type = LABEL_TEXT
	cap_type = CAP_BLUE
	list_reagents = list(/datum/reagent/ammonia = 200)

/obj/item/reagent_containers/cup/jerrycan/diethylamine
	name = "NT-AG diethylamine can"
	label_type = LABEL_TEXT_OLD
	cap_type = CAP_GREEN
	desc = "A large container labled 'NT-AG' diethylamine. A disclaimer written in bold letters reads: FOR AGRICULTURAL USE ONLY. RESALE PROHIBITED."
	list_reagents = list(/datum/reagent/diethylamine = 200)

/obj/item/reagent_containers/cup/jerrycan/sus
	name = "DonkCo great value phlogiston can"
	label_type = LABEL_SUSPICIOUS_BLACK
	desc = "A large can of phlogiston, ostensibly for removing dried out Donk-pocket™ filling from the production line."
	list_reagents = list(/datum/reagent/phlogiston = 200)

/obj/item/reagent_containers/cup/jerrycan/oil
	name = "oil can"
	label_type = LABEL_INFLAMMABLE
	cap_type = CAP_RED
	desc = "A large can full of synthetic lubricating oil."
	list_reagents = list(/datum/reagent/fuel/oil = 200)

/obj/item/reagent_containers/cup/jerrycan/space_cleaner
	name = "BLAM!™-brand non-foaming space cleaner can"
	label_type = LABEL_SPACE_CLEANER
	cap_type = CAP_RED
	desc = "Stubborn stains, grease and grime got you cornered? No duty to retreat when you got BLAM!™ on your side!\nBLAM!™ - A WaffleCo product."
	list_reagents = list(/datum/reagent/space_cleaner = 200)

/obj/item/reagent_containers/cup/jerrycan/milk
	name = "milk jug"
	label_type = LABEL_NT_MINI
	cap_type = CAP_BLUE
	desc = "A jug of most wholesome milk."
	list_reagents = list(/datum/reagent/consumable/milk = 200)


#undef LABEL_TEXT
#undef LABEL_TEXT_OLD
#undef LABEL_INFLAMMABLE
#undef LABEL_NT
#undef LABEL_NT_MINI
#undef LABEL_SUSPICIOUS
#undef LABEL_SUSPICIOUS_BLACK
#undef LABEL_SUSPICIOUS_MINI
#undef LABEL_SUSPICIOUS_MINI_BLACK
#undef LABEL_EZ_NUTRIENT
#undef LABEL_ROBUST_HARVEST
#undef LABEL_LEFT_4_ZED
#undef LABEL_SPACE_CLEANER
#undef CAP_BLACK
#undef CAP_WHITE
#undef CAP_RED
#undef CAP_GREEN
#undef CAP_BLUE
