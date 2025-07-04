GLOBAL_LIST_INIT(possible_food_allergies, list(
	"Alcohol" = ALCOHOL,
	"Bugs" = BUGS,
	"Dairy" = DAIRY,
	"Fruit" = FRUIT,
	"Grain" = GRAIN,
	"Meat" = MEAT,
	"Nuts" = NUTS,
	"Seafood" = SEAFOOD,
	"Sugar" = SUGAR,
	"Vegetables" = VEGETABLES,
))

/datum/quirk/item_quirk/food_allergic
	name = "Food Allergy"
	desc = "Ever since you were a kid, you've been allergic to certain foods."
	icon = FA_ICON_SHRIMP
	value = -2
	gain_text = span_danger("You feel your immune system shift.")
	lose_text = span_notice("You feel your immune system phase back into perfect shape.")
	medical_record_text = "Patient's immune system responds violently to certain food."
	hardcore_value = 1
	quirk_flags = QUIRK_HUMAN_ONLY
	mail_goodies = list(/obj/item/reagent_containers/hypospray/medipen)
	/// Footype flags that will trigger the allergy
	var/target_foodtypes = NONE

/datum/quirk_constant_data/food_allergy
	associated_typepath = /datum/quirk/item_quirk/food_allergic
	customization_options = list(/datum/preference/choiced/food_allergy)

/datum/quirk/item_quirk/food_allergic/add(client/client_source)
	if(target_foodtypes != NONE) // Already set, don't care
		return

	var/desired_allergy = client_source?.prefs.read_preference(/datum/preference/choiced/food_allergy) || "Random"
	if(desired_allergy != "Random")
		target_foodtypes = GLOB.possible_food_allergies[desired_allergy]
		if(target_foodtypes != NONE) // Got a preference, don't care
			return

	target_foodtypes = pick(flatten_list(GLOB.possible_food_allergies))

/datum/quirk/item_quirk/food_allergic/add_unique(client/client_source)
	var/what_are_we_actually_killed_by = english_list(bitfield_to_list(target_foodtypes, FOOD_FLAGS_IC)) // This should never be more than one thing but just in case we can support it
	to_chat(client_source.mob, span_info("You are allergic to [what_are_we_actually_killed_by]. Watch what you eat!"))

	var/obj/item/clothing/accessory/dogtag/allergy/dogtag = new(quirk_holder, what_are_we_actually_killed_by)
	give_item_to_holder(dogtag, list(LOCATION_BACKPACK, LOCATION_HANDS), flavour_text = "Keep it close around the kitchen.", notify_player = TRUE)
