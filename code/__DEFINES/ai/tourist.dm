//Robot customer AI controller blackboard keys
/// Corresponds to the customer's order.
/// This can be a an item typepath or an instance of a custom order datum
#define BB_CUSTOMER_CURRENT_ORDER "BB_customer_current_order"
#define BB_CUSTOMER_MY_SEAT "BB_customer_my_seat"
#define BB_CUSTOMER_PATIENCE "BB_customer_patience"
/// A reference to a customer data datum, containing stuff like saylines and food desires
#define BB_CUSTOMER_CUSTOMERINFO "BB_customer_customerinfo"
/// Whether we're busy eating something already
#define BB_CUSTOMER_EATING "BB_customer_eating"
/// A reference to the venue being attended
#define BB_CUSTOMER_ATTENDING_VENUE "BB_customer_attending_avenue"
/// Whether we're leaving the venue entirely, either happily or forced out
#define BB_CUSTOMER_LEAVING "BB_customer_leaving"
#define BB_CUSTOMER_CURRENT_TARGET "BB_customer_current_target"
/// Robot customer has said their can't find seat line at least once. Used to rate limit how often they'll complain after the first time.
#define BB_CUSTOMER_SAID_CANT_FIND_SEAT_LINE "BB_customer_said_cant_find_seat_line"
