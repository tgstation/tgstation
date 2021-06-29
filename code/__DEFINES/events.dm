#define SUCCESSFUL_SPAWN 2
#define NOT_ENOUGH_PLAYERS 3
#define MAP_ERROR 4
#define WAITING_FOR_SOMETHING 5

#define EVENT_CANT_RUN 0
#define EVENT_READY 1
#define EVENT_CANCELLED 2
#define EVENT_INTERRUPTED 3

//defines for merchant event//

///cost for the merchant ship to visit
#define INITIAL_VISIT_COST 500
///max time merchant will stay, regardless of emergency shuttle calls
#define TOTAL_MERCHANT_VISIT_TIME 20 MINUTES
///index of the comm response to say yes
#define RESPONSE_MERCHANT_DOCK 1
///index of the comm response to say no
#define RESPONSE_MERCHANT_LEAVE 2
