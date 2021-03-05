#define MEAT (1<<0)
#define VEGETABLES (1<<1)
#define RAW (1<<2)
#define JUNKFOOD (1<<3)
#define GRAIN (1<<4)
#define FRUIT (1<<5)
#define DAIRY (1<<6)
#define FRIED (1<<7)
#define ALCOHOL (1<<8)
#define SUGAR (1<<9)
#define GROSS (1<<10)
#define TOXIC (1<<11)
#define PINEAPPLE (1<<12)
#define BREAKFAST (1<<13)
#define CLOTH (1<<14)

#define DRINK_NICE 1
#define DRINK_GOOD 2
#define DRINK_VERYGOOD 3
#define DRINK_FANTASTIC 4
#define FOOD_AMAZING 5

#define FOOD_IN_CONTAINER (1<<0)
#define FOOD_FINGER_FOOD (1<<1)

#define STOP_SERVING_BREAKFAST (15 MINUTES)

#define FOOD_WORTHLESS 0
#define FOOD_JUNK 6
#define FOOD_FAST 40
#define FOOD_RARE 80
#define FOOD_EXOTIC 150
#define FOOD_LEGENDARY 1000
#define FOOD_ILLEGAL 1000

#define FOOD_MEAT_NORMAL 5
#define FOOD_MEAT_HUMAN 50
#define FOOD_MEAT_MUTANT 100
#define FOOD_MEAT_MUTANT_RARE 200

///Amount of reagents you start with on crafted food excluding the used parts
#define CRAFTED_FOOD_BASE_REAGENT_MODIFIER 0.7
///Modifier of reagents you get when crafting food from the parts used
#define CRAFTED_FOOD_INGREDIENT_REAGENT_MODIFIER  0.5

#define IS_EDIBLE(O) (O.GetComponent(/datum/component/edible))


///Food trash flags
#define FOOD_TRASH_POPABLE (1<<0)
#define FOOD_TRASH_OPENABLE (1<<1)



///Food preference enums
#define FOOD_LIKED 1
#define FOOD_DISLIKED 2
#define FOOD_TOXIC 3

///Venue reagent requirement
#define VENUE_BAR_MINIMUM_REAGENTS 10



///Food price classes
#define FOOD_PRICE_TRASH 10  //cheap and quick.
#define FOOD_PRICE_CHEAP 40 //In line with prices of cheap snacks and foods you find in vending machine, practically disposable.
#define FOOD_PRICE_NORMAL 100 //Half a crate of profit, selling 4 of these lets you buy a kitchen crate from cargo.
#define FOOD_PRICE_EXOTIC 300 //Making one of these should be worth the time investment, solid chunk of profit.
#define FOOD_PRICE_LEGENDARY 1000 //Large windfall for making something from this list.


#define DRINK_PRICE_STOCK 20
#define DRINK_PRICE_EASY 35
#define DRINK_PRICE_MEDIUM 80
#define DRINK_PRICE_HIGH 200
