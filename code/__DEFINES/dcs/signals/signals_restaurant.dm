///Restaurant

///(wanted_item) custom order signal sent when checking if the order is correct.
#define COMSIG_ITEM_IS_CORRECT_CUSTOM_ORDER "item_is_correct_order"
	#define COMPONENT_CORRECT_ORDER (1<<0)

///(customer, container) venue signal sent when a venue sells an item. source is the thing sold, which can be a datum, so we send container for location checks
#define COMSIG_ITEM_SOLD_TO_CUSTOMER "item_sold_to_customer"
