// Defines that give callbacks/values to callbacks stored in SSwardrobe
// Made to be passed into provide_type(), these avoid missing arguments by abstracting filling in optional args

/// Gives an amount to /obj/item/stacks before they are spawned
#define WARDROBE_STACK_AMOUNT "stack_amount"
#define SET_STACK_AMOUNT(amount) WARDROBE_STACK_AMOUNT, (amount)
