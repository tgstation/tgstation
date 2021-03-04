/obj/item/food/cake
	icon = 'icons/obj/food/piecake.dmi'
	bite_consumption = 3
	max_volume = 80
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 1)
	foodtypes = GRAIN | DAIRY

/obj/item/food/cake/Initialize()
	. = ..()
	AddComponent(/datum/component/food_storage)

/obj/item/food/cakeslice
	icon = 'icons/obj/food/piecake.dmi'
	trash_type = /obj/item/trash/plate
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("cake" = 1)
	foodtypes = GRAIN | DAIRY
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/cake/plain
	name = "plain cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/consumable/nutriment/vitamin = 7)
	tastes = list("sweetness" = 2, "cake" = 5)
	foodtypes = GRAIN | DAIRY | SUGAR

/obj/item/food/cake/plain/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/plain, 5, 30)

/obj/item/food/cakeslice/plain
	name = "plain cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	tastes = list("sweetness" = 2,"cake" = 5)
	foodtypes = GRAIN | DAIRY | SUGAR

/obj/item/food/cake/carrot
	name = "carrot cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/medicine/oculine = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "carrot" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES | SUGAR
	venue_value = FOOD_PRICE_CHEAP


/obj/item/food/cake/carrot/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/carrot, 5, 30)

/obj/item/food/cakeslice/carrot
	name = "carrot cake slice"
	desc = "Carrotty slice of Carrot Cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/medicine/oculine = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("cake" = 5, "sweetness" = 2, "carrot" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES | SUGAR

/obj/item/food/cake/brain
	name = "brain cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 15, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/medicine/mannitol = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "brains" = 1)
	foodtypes = GRAIN | DAIRY | MEAT | GROSS | SUGAR

/obj/item/food/cake/brain/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/brain, 5, 30)

/obj/item/food/cakeslice/brain
	name = "brain cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/medicine/mannitol = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("cake" = 5, "sweetness" = 2, "brains" = 1)
	foodtypes = GRAIN | DAIRY | MEAT | GROSS | SUGAR

/obj/item/food/cake/cheese
	name = "cheese cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 8, /datum/reagent/consumable/nutriment/protein = 5)
	tastes = list("cake" = 4, "cream cheese" = 3)
	foodtypes = GRAIN | DAIRY
	venue_value = FOOD_PRICE_CHEAP


/obj/item/food/cake/cheese/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/cheese, 5, 30)

/obj/item/food/cakeslice/cheese
	name = "cheese cake slice"
	desc = "Slice of pure cheestisfaction."
	icon_state = "cheesecake_slice"
	tastes = list("cake" = 4, "cream cheese" = 3)
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/nutriment/vitamin = 1.3)
	foodtypes = GRAIN | DAIRY

/obj/item/food/cake/orange
	name = "orange cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cake" = 5, "sweetness" = 2, "oranges" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/cake/orange/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/orange, 5, 30)

/obj/item/food/cakeslice/orange
	name = "orange cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	tastes = list("cake" = 5, "sweetness" = 2, "oranges" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR

/obj/item/food/cake/lime
	name = "lime cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cake" = 5, "sweetness" = 2, "unbearable sourness" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/cake/lime/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/lime, 5, 30)

/obj/item/food/cakeslice/lime
	name = "lime cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	tastes = list("cake" = 5, "sweetness" = 2, "unbearable sourness" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR

/obj/item/food/cake/lemon
	name = "lemon cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cake" = 5, "sweetness" = 2, "sourness" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/cake/lemon/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/lemon, 5, 30)

/obj/item/food/cakeslice/lemon
	name = "lemon cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	tastes = list("cake" = 5, "sweetness" = 2, "sourness" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR

/obj/item/food/cake/chocolate
	name = "chocolate cake"
	desc = "A cake with added chocolate."
	icon_state = "chocolatecake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cake" = 5, "sweetness" = 1, "chocolate" = 4)
	foodtypes = GRAIN | DAIRY | JUNKFOOD | SUGAR
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/cake/chocolate/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/chocolate, 5, 30)

/obj/item/food/cakeslice/chocolate
	name = "chocolate cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	tastes = list("cake" = 5, "sweetness" = 1, "chocolate" = 4)
	foodtypes = GRAIN | DAIRY | JUNKFOOD | SUGAR

/obj/item/food/cake/birthday
	name = "birthday cake"
	desc = "Happy Birthday little clown..."
	icon_state = "birthdaycake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/sprinkles = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 5, "sweetness" = 1)
	foodtypes = GRAIN | DAIRY | JUNKFOOD | SUGAR

/obj/item/food/cake/birthday/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/birthday, 5, 30)

/obj/item/food/cake/birthday/microwave_act(obj/machinery/microwave/M) //super sekrit club
	new /obj/item/clothing/head/hardhat/cakehat(get_turf(src))
	qdel(src)

/obj/item/food/cakeslice/birthday
	name = "birthday cake slice"
	desc = "A slice of your birthday."
	icon_state = "birthdaycakeslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sprinkles = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("cake" = 5, "sweetness" = 1)
	foodtypes = GRAIN | DAIRY | JUNKFOOD | SUGAR

/obj/item/food/cake/birthday/energy
	name = "energy cake"
	desc = "Just enough calories for a whole nuclear operative squad."
	icon_state = "energycake"
	force = 5
	hitsound = 'sound/weapons/blade1.ogg'
	food_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/sprinkles = 10, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/pwr_game = 10, /datum/reagent/consumable/liquidelectricity = 10)
	tastes = list("cake" = 3, "a Vlad's Salad" = 1)

/obj/item/food/cake/birthday/energy/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/birthday/energy, 5, 30)

/obj/item/food/cake/birthday/energy/proc/energy_bite(mob/living/user)
	to_chat(user, "<font color='red' size='5'>As you eat the cake, you accidentally hurt yourself on the embedded energy sword!</font>")
	user.apply_damage(30,BRUTE,BODY_ZONE_HEAD)
	playsound(user, 'sound/weapons/blade1.ogg', 5, TRUE)

/obj/item/food/cake/birthday/energy/attack(mob/living/M, mob/living/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM) && M != user) //Prevents pacifists from attacking others directly
		return
	energy_bite(M, user)

/obj/item/food/cake/birthday/energy/microwave_act(obj/machinery/microwave/M) //super sekriter club
	new /obj/item/clothing/head/hardhat/cakehat/energycake(get_turf(src))
	qdel(src)

/obj/item/food/cakeslice/birthday/energy
	name = "energy cake slice"
	desc = "For the traitor on the go."
	icon_state = "energycakeslice"
	force = 2
	hitsound = 'sound/weapons/blade1.ogg'
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sprinkles = 2, /datum/reagent/consumable/nutriment/vitamin = 1,  /datum/reagent/consumable/pwr_game = 2, /datum/reagent/consumable/liquidelectricity = 2)
	tastes = list("cake" = 3, "a Vlad's Salad" = 1)

/obj/item/food/cakeslice/birthday/energy/proc/energy_bite(mob/living/user)
	to_chat(user, "<font color='red' size='5'>As you eat the cake slice, you accidentally hurt yourself on the embedded energy dagger!</font>")
	user.apply_damage(18,BRUTE,BODY_ZONE_HEAD)
	playsound(user, 'sound/weapons/blade1.ogg', 5, TRUE)

/obj/item/food/cakeslice/birthday/energy/attack(mob/living/M, mob/living/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM) && M != user) //Prevents pacifists from attacking others directly
		return
	energy_bite(M, user)

/obj/item/food/cake/apple
	name = "apple cake"
	desc = "A cake centred with Apple."
	icon_state = "applecake"

	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cake" = 5, "sweetness" = 1, "apple" = 1)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/cake/apple/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/apple, 5, 30)

/obj/item/food/cakeslice/apple
	name = "apple cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	tastes = list("cake" = 5, "sweetness" = 1, "apple" = 1)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR

/obj/item/food/cake/slimecake
	name = "Slime cake"
	desc = "A cake made of slimes. Probably not electrified."
	icon_state = "slimecake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "slime" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR

/obj/item/food/cake/slimecake/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/slimecake, 5, 30)

/obj/item/food/cakeslice/slimecake
	name = "slime cake slice"
	desc = "A slice of slime cake."
	icon_state = "slimecake_slice"
	tastes = list("cake" = 5, "sweetness" = 1, "slime" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR

/obj/item/food/cake/pumpkinspice
	name = "pumpkin spice cake"
	desc = "A hollow cake with real pumpkin."
	icon_state = "pumpkinspicecake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "pumpkin" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES | SUGAR
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/cake/pumpkinspice/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/pumpkinspice, 5, 30)

/obj/item/food/cakeslice/pumpkinspice
	name = "pumpkin spice cake slice"
	desc = "A spicy slice of pumpkin goodness."
	icon_state = "pumpkinspicecakeslice"
	tastes = list("cake" = 5, "sweetness" = 1, "pumpkin" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES | SUGAR

/obj/item/food/cake/bsvc // blackberry strawberries vanilla cake
	name = "blackberry and strawberry vanilla cake"
	desc = "A plain cake, filled with assortment of blackberries and strawberries!"
	icon_state = "blackbarry_strawberries_cake_vanilla_cake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("blackberry" = 2, "strawberries" = 2, "vanilla" = 2, "sweetness" = 2, "cake" = 3)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR

/obj/item/food/cake/bsvc/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/bsvc, 5, 30)

/obj/item/food/cakeslice/bsvc
	name = "blackberry and strawberry vanilla cake slice"
	desc = "Just a slice of cake  filled with assortment of blackberries and strawberries!"
	icon_state = "blackbarry_strawberries_cake_vanilla_slice"
	tastes = list("blackberry" = 2, "strawberries" = 2, "vanilla" = 2, "sweetness" = 2,"cake" = 3)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR

/obj/item/food/cake/bscc // blackbarry strawberries chocolate cake
	name = "blackberry and strawberry chocolate cake"
	desc = "A chocolate cake, filled with assortment of blackberries and strawberries!"
	icon_state = "blackbarry_strawberries_cake_coco_cake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/coco = 5)
	tastes = list("blackberry" = 2, "strawberries" = 2, "chocolate" = 2, "sweetness" = 2,"cake" = 3)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR

/obj/item/food/cake/bscc/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/bscc, 5, 30)

/obj/item/food/cakeslice/bscc
	name = "blackberry and strawberry chocolate cake slice"
	desc = "Just a slice of cake  filled with assortment of blackberries and strawberries!"
	icon_state = "blackbarry_strawberries_cake_coco_slice"
	tastes = list("blackberry" = 2, "strawberries" = 2, "chocolate" = 2, "sweetness" = 2,"cake" = 3)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR

/obj/item/food/cake/holy_cake
	name = "angel food cake"
	desc = "A cake made for angels and chaplains alike! Contains holy water."
	icon_state = "holy_cake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 3, /datum/reagent/water/holywater = 10)
	tastes = list("cake" = 5, "sweetness" = 1, "clouds" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR

/obj/item/food/cake/holy_cake/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/holy_cake_slice, 5, 30)

/obj/item/food/cakeslice/holy_cake_slice
	name = "angel food cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "holy_cake_slice"
	tastes = list("cake" = 5, "sweetness" = 1, "clouds" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR

/obj/item/food/cake/pound_cake
	name = "pound cake"
	desc = "A condensed cake made for filling people up quickly."
	icon_state = "pound_cake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 60, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "batter" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR | JUNKFOOD
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/cake/pound_cake/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/pound_cake_slice, 7, 30)

/obj/item/food/cakeslice/pound_cake_slice
	name = "pound cake slice"
	desc = "A slice of condensed cake made for filling people up quickly."
	icon_state = "pound_cake_slice"
	tastes = list("cake" = 5, "sweetness" = 5, "batter" = 1)
	food_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/nutriment/vitamin = 0.5)
	foodtypes = GRAIN | DAIRY | SUGAR | JUNKFOOD

/obj/item/food/cake/hardware_cake
	name = "hardware cake"
	desc = "A quote on quote cake that is made with electronic boards and leaks acid..."
	icon_state = "hardware_cake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/toxin/acid = 15, /datum/reagent/fuel/oil = 15)
	tastes = list("acid" = 3, "metal" = 4, "glass" = 5)
	foodtypes = GRAIN | GROSS

/obj/item/food/cake/hardware_cake/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/hardware_cake_slice, 5, 30)

/obj/item/food/cakeslice/hardware_cake_slice
	name = "hardware cake slice"
	desc = "A slice of electronic boards and some acid."
	icon_state = "hardware_cake_slice"
	tastes = list("acid" = 3, "metal" = 4, "glass" = 5)
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/toxin/acid = 3, /datum/reagent/fuel/oil = 3)
	foodtypes = GRAIN | GROSS

/obj/item/food/cake/vanilla_cake
	name = "vanilla cake"
	desc = "A vanilla frosted cake."
	icon_state = "vanillacake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/sugar = 15, /datum/reagent/consumable/vanilla = 15)
	tastes = list("cake" = 1, "sugar" = 1, "vanilla" = 10)
	foodtypes = GRAIN | SUGAR | DAIRY

/obj/item/food/cake/vanilla_cake/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/vanilla_slice, 5, 30)

/obj/item/food/cakeslice/vanilla_slice
	name = "vanilla cake slice"
	desc = "A slice of vanilla frosted cake."
	icon_state = "vanillacake_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/vanilla = 3)
	tastes = list("cake" = 1, "sugar" = 1, "vanilla" = 10)
	foodtypes = GRAIN | SUGAR | DAIRY

/obj/item/food/cake/clown_cake
	name = "clown cake"
	desc = "A funny cake with a clown face on it."
	icon_state = "clowncake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/sugar = 15)
	tastes = list("cake" = 1, "sugar" = 1, "joy" = 10)
	foodtypes = GRAIN | SUGAR | DAIRY

/obj/item/food/cake/clown_cake/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/clown_slice, 5, 30)

/obj/item/food/cakeslice/clown_slice
	name = "clown cake slice"
	desc = "A slice of bad jokes, and silly props."
	icon_state = "clowncake_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/sugar = 3)
	tastes = list("cake" = 1, "sugar" = 1, "joy" = 10)
	foodtypes = GRAIN | SUGAR | DAIRY

/obj/item/food/cake/trumpet
	name = "spaceman's cake"
	desc = "A spaceman's trumpet frosted cake."
	icon_state = "trumpetcake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/medicine/polypyr = 15, /datum/reagent/consumable/cream = 5, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/berryjuice = 5)
	tastes = list("cake" = 4, "violets" = 2, "jam" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR

/obj/item/food/cake/trumpet/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/trumpet, 5, 30)

/obj/item/food/cakeslice/trumpet
	name = "spaceman's cake"
	desc = "A spaceman's trumpet frosted cake."
	icon_state = "trumpetcakeslice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/medicine/polypyr = 3, /datum/reagent/consumable/cream = 1, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/berryjuice = 1)
	tastes = list("cake" = 4, "violets" = 2, "jam" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR

/obj/item/food/cake/brioche
	name = "brioche cake"
	desc = "A ring of sweet, glazed buns."
	icon_state = "briochecake"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 4, "butter" = 2, "cream" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR

/obj/item/food/cake/brioche/MakeProcessable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/brioche, 6, 30)

/obj/item/food/cakeslice/brioche
	name = "brioche cake slice"
	desc = "Delicious sweet-bread. Who needs anything else?"
	icon_state = "briochecake_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("cake" = 4, "butter" = 2, "cream" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR
