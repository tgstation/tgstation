///Restaurant

///(wanted_item) custom order signal sent when checking if the order is correct.
#define COMSIG_ITEM_IS_CORRECT_CUSTOM_ORDER "item_is_correct_order"
	#define COMPONENT_CORRECT_ORDER (1<<0)

///(customer, container) venue signal sent when a venue sells an item. source is the thing sold, which can be a datum, so we send container for location checks
#define COMSIG_ITEM_SOLD_TO_CUSTOMER "item_sold_to_customer"
///(customer, container) venue signal sent when a venue sells an reagent. source is the thing sold, which can be a datum, so we send container for location checks
#define COMSIG_REAGENT_SOLD_TO_CUSTOMER "reagent_sold_to_customer"
	/// Return from either above signal to denote the transaction completed successfully, so the venue can finish processing it
	#define TRANSACTION_SUCCESS (1<<0)
	/// Return from either above to stop the venue default processing, allowing you to handle cleanup / aftermath yourself
	#define TRANSACTION_HANDLED (1<<1)
