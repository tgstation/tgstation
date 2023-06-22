// Defines that give callbacks/values to callbacks stored in SSwardrobe
// Made to be passed into provide_type(), these avoid missing arguments by abstracting filling in optional args

/// Gives an amount to /obj/item/stacks before they are spawned
#define WARDROBE_STACK_AMOUNT "stack_amount"
#define SET_STACK_AMOUNT(amount) list(WARDROBE_STACK_AMOUNT, (amount))

/// Gives a custom material list to the sheets we spawn
#define WARDROBE_STACK_MATS "stack_mats"
#define SET_STACK_MATS(mat_list) list(WARDROBE_STACK_MATS, (mat_list))
