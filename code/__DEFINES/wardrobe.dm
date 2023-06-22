// Defines that give callbacks/values to callbacks stored in SSwardrobe
// Made to be passed into provide(), these avoid missing arguments by abstracting filling in optional args

/// Gives an amount to /obj/item/stacks before they are spawned
#define WARDROBE_STACK_AMOUNT "stack_amount"
#define STACK_AMOUNT(amount) list(WARDROBE_STACK_AMOUNT, (amount))

/// Gives a custom material list to the sheets we spawn
#define WARDROBE_STACK_MATS "stack_mats"
#define STACK_MATS(mat_list) list(WARDROBE_STACK_MATS, (mat_list))

/// Gives conveyer belts an id
#define WARDROBE_CONVEYOR_ID "conveyor_id"
#define CONVEYOR_ID(id) list(WARDROBE_CONVEYOR_ID, (id))
