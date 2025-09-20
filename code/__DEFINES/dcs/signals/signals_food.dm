
//Food

// Eating stuff
/// From datum/component/edible/proc/TakeBite: (mob/living/eater, mob/feeder, bitecount, bitesize)
#define COMSIG_FOOD_EATEN "food_eaten"
	#define DESTROY_FOOD (1<<0)
/// From base of datum/component/edible/on_entered: (mob/crosser, bitecount)
#define COMSIG_FOOD_CROSSED "food_crossed"
/// From base of Component/edible/On_Consume: (mob/living/eater, mob/living/feeder)
#define COMSIG_FOOD_CONSUMED "food_consumed"
/// called when a pill is injested (mob/living/eater, mob/living/feeder)
#define COMSIG_PILL_CONSUMED "pill_consumed"
/// called when an item is used as an ingredient: (atom/customized)
#define COMSIG_ITEM_USED_AS_INGREDIENT "item_used_as_ingredient"
/// called when an edible ingredient is added: (datum/component/edible/ingredient)
#define COMSIG_FOOD_INGREDIENT_ADDED "edible_ingredient_added"

/// from base of /datum/component/edible/get_recipe_complexity(): (list/extra_complexity)
#define COMSIG_FOOD_GET_EXTRA_COMPLEXITY "food_get_extra_complexity"

// Deep frying foods
/// An item becomes fried - From /datum/element/fried_item/Attach: (fry_time)
#define COMSIG_ITEM_FRIED "item_fried"
/// An item entering the deep frying (not fried yet) - From obj/machinery/deepfryer/start_fry: ()
#define COMSIG_ITEM_ENTERED_FRYER "item_entered_fryer"

// Microwaving foods
///called on item when microwaved (): (obj/machinery/microwave/microwave, mob/microwaver)
#define COMSIG_ITEM_MICROWAVE_ACT "microwave_act"
	/// Return on success - that is, a microwaved item was produced
	#define COMPONENT_MICROWAVE_SUCCESS (1<<0)
	/// Returned on "failure" - an item was produced but it was the default fail recipe
	#define COMPONENT_MICROWAVE_BAD_RECIPE (1<<1)
///called on item when created through microwaving (): (obj/machinery/microwave/M, cooking_efficiency)
#define COMSIG_ITEM_MICROWAVE_COOKED "microwave_cooked"
///called on the ingredient through microwawing: (result)
#define COMSIG_ITEM_MICROWAVE_COOKED_FROM "item_microwave_cooked_from"

// Grilling foods (griddle, grill, and bonfire)
///Called when an object is placed onto a griddle
#define COMSIG_ITEM_GRILL_PLACED "item_placed_on_griddle"
///Called when a griddle is turned on
#define COMSIG_ITEM_GRILL_TURNED_ON "item_grill_turned_on"
///Called when a griddle is turned off
#define COMSIG_ITEM_GRILL_TURNED_OFF "item_grill_turned_off"
///Called when an object is grilled ontop of a griddle
#define COMSIG_ITEM_GRILL_PROCESS "item_griddled"
	/// Return to not burn the item
	#define COMPONENT_HANDLED_GRILLING (1<<0)
///Called when an object is turned into another item through grilling ontop of a griddle
#define COMSIG_ITEM_GRILLED "item_grill_completed"
///Sent to the newly spawned object when it's grilled on a griddle.
#define COMSIG_ITEM_GRILLED_RESULT "item_grilled_result"

///Called when the object is grilled by the grill (not to be confused by the griddle, but oh gee the two should be merged in one)
#define COMSIG_ITEM_BARBEQUE_GRILLED "item_barbeque_grilled"

// Baking foods (oven)
//Called when an object is inserted into an oven (atom/oven, mob/baker)
#define COMSIG_ITEM_OVEN_PLACED_IN "item_placed_in_oven"
//Called when an object is in an oven
#define COMSIG_ITEM_OVEN_PROCESS "item_baked"
	/// Return to not burn the item
	#define COMPONENT_HANDLED_BAKING (1<<0)
	/// Return if the result of the baking was a good thing
	#define COMPONENT_BAKING_GOOD_RESULT (1<<1)
	/// Return if the result of the baking was a bad thing / failuire
	#define COMPONENT_BAKING_BAD_RESULT (1<<2)
///Called when an object is turned into another item through baking in an oven
#define COMSIG_ITEM_BAKED "item_bake_completed"
///Sent to the newly spawned object when it's baked in an oven.
#define COMSIG_ITEM_BAKED_RESULT "item_baked_result"

///Called on the result spawned during decomposition: (obj/decomposed)
#define COMSIG_OBJ_DECOMPOSITION_RESULT "obj_decomposition_result"

//Drink

///from base of obj/item/reagent_containers/cup/attack(): (mob/M, mob/user)
#define COMSIG_GLASS_DRANK "glass_drank"
