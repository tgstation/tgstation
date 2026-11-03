/obj/item/reagent_containers/food
	rogue_faretype = ROGUE_FARE_IMPOVERISHED
	rogue_portable = TRUE

/obj/item/reagent_containers/food/snacks/allspice
	tastes = list("fragrant spices" = 1, "a pleasantly complex aroma" = 1)

/obj/item/reagent_containers/food/snacks/badrecipe
	food_reagents = list(/datum/reagent/toxin/bad_food = 30)
	foodtypes = GROSS
	burntime = 0

/obj/item/reagent_containers/food/snacks/balefire
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	bitesize = 4
	slice_path = /obj/item/reagent_containers/food/snacks/balefire/slice
	slices_num = 4
	slice_batch = FALSE
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/butter
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = DAIRY
	bitesize = 6
	slice_path = /obj/item/reagent_containers/food/snacks/butterslice
	slices_num = 6
	slice_batch = FALSE

/obj/item/reagent_containers/food/snacks/butterslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	foodtypes = DAIRY

/obj/item/reagent_containers/food/snacks/chocolate
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("sugary richness" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 4
	slice_path = /obj/item/reagent_containers/food/snacks/chocolate/slice
	slices_num = 2
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/crow
	food_reagents = list(/datum/reagent/consumable/nutriment = 4)
	foodtypes = RAW
	eat_effect = /datum/status_effect/rogue_food/uncooked
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/friedcrow

/obj/item/reagent_containers/food/snacks/deadmouse
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	foodtypes = GROSS | MEAT | RAW

/obj/item/reagent_containers/food/snacks/egg
	food_reagents = list(/datum/reagent/consumable/eggyolk = 5)
	foodtypes = MEAT
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/fried
	rotprocess = 9000

/obj/item/reagent_containers/food/snacks/fat
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	eat_effect = /datum/status_effect/rogue_food/uncooked
	rogue_fat_yield = 20

/obj/item/reagent_containers/food/snacks/fish
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	eat_effect = /datum/status_effect/rogue_food/uncooked
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/fish
	slices_num = 2
	slice_bclass = BCLASS_CHOP
	rogue_cooked_smell = "cooked fish"

/obj/item/reagent_containers/food/snacks/pepper
	food_reagents = list(/datum/reagent/consumable/blackpepper = 1)
	tastes = list("tingling spiciness" = 1, "a subtle hint of bitterness" = 1)

/obj/item/reagent_containers/food/snacks/roastseeds
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = VEGETABLES
	tastes = list("toasted seeds" = 1)

/obj/item/reagent_containers/food/snacks/smallrat
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	foodtypes = RAW
	eat_effect = /datum/status_effect/rogue_food/uncooked
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/friedrat

/obj/item/reagent_containers/food/snacks/squiresdelight
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = DAIRY | GRAIN
	tastes = list("crunchy toastcrumbs" = 1, "molten butter" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_snack
	bitesize = 6
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugar
	food_reagents = list(/datum/reagent/consumable/sugar = 15)
	tastes = list("sweet" = 1)

/obj/item/reagent_containers/food/snacks/tallow
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("grease" = 1, "oil" = 1, "regret" = 1)
	eat_effect = /datum/status_effect/rogue_food/uncooked
	bitesize = 1
	rogue_fat_yield = 5

/obj/item/reagent_containers/food/snacks/zizo_bane
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/sleep_powder = 5)
	foodtypes = VEGETABLES
	tastes = list("numbing mintiness" = 1, "purpliness" = 1)
	bitesize = 1
	rotprocess = 18000

/obj/item/reagent_containers/food/snacks/balefire/slice
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	bitesize = 2
	slice_path = null
	slices_num = 0

/obj/item/reagent_containers/food/snacks/chocolate/slice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("sugary richness" = 1)
	bitesize = 3
	slice_path = null
	slices_num = 0

/obj/item/reagent_containers/food/snacks/eoran_aril/auric
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	bitesize = 1
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/fat/salo
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	eat_effect = null
	bitesize = 6
	slice_path = /obj/item/reagent_containers/food/snacks/fat/salo/slice
	slices_num = 4
	slice_batch = FALSE

/obj/item/reagent_containers/food/snacks/fish/crab
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/crab
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/crab
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/crab
	rogue_cooked_smell = "fried crab"

/obj/item/reagent_containers/food/snacks/fish/dead
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)

/obj/item/reagent_containers/food/snacks/fish/lobster
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/lobster
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/lobster
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/shellfish
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_cooked_smell = "fried shellfish"

/obj/item/reagent_containers/food/snacks/fish/oyster
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/shellfish
	rogue_cooked_smell = "fried shellfish"

/obj/item/reagent_containers/food/snacks/fish/plaice
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/plaice
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/plaice
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/fish/sole
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/sole
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/sole
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/fish/sunny
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/sunny
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/sunny
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/grown/apple
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("apple" = 1)
	rotprocess = 9000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/fruit/apple_sliced
	slices_num = 3
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/carrot
	tastes = list("carrot" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/carrot_baked

/obj/item/reagent_containers/food/snacks/grown/coffee
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	tastes = list("hibicus sweetness" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/coffeebeans
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	tastes = list("unpleasant bitterness" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/grown/coffeebeansroasted
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/coffeebeans_spiced
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("rich caramel smoothness" = 1, "a mouthful of cough-inducing powderiness" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/coffeebeansroasted
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("rich caramel smoothness" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/cucumber
	tastes = list("cucumber" = 1)
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/veg/cucumber_sliced
	slices_num = 2

/obj/item/reagent_containers/food/snacks/grown/eggplant
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/eggplantcarved
	slices_num = 1

/obj/item/reagent_containers/food/snacks/grown/nut
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/drug/nicotine = 1)
	foodtypes = FRUIT
	tastes = list("nutty" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/nut_sugared
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	tastes = list("overpoweringly sweet and nutty" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/grown/oat
	foodtypes = GRAIN
	tastes = list("oat" = 1)

/obj/item/reagent_containers/food/snacks/grown/rice
	foodtypes = GRAIN
	tastes = list("rice" = 1)

/obj/item/reagent_containers/food/snacks/grown/skysugarslab
	food_reagents = list(/datum/reagent/starsugar = 16, /datum/reagent/water = 6, /datum/reagent/consumable/nutriment = 6)
	tastes = list("a slightly less bad idea" = 1, "shards of fruit-tinged glass" = 1)
	bitesize = 7

/obj/item/reagent_containers/food/snacks/grown/sugarcane
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/sugar = 5)

/obj/item/reagent_containers/food/snacks/grown/tea
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	tastes = list("grass" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/wheat
	foodtypes = GRAIN
	tastes = list("wheat" = 1)

/obj/item/reagent_containers/food/snacks/rogue/alecod
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN
	tastes = list("flaky ale-soaked fish" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/applebread
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN
	tastes = list("crisp-laden doughiness" = 1, "deliciously soft apples" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 8
	rotprocess = 54000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/applebreadslice
	slices_num = 6
	slice_batch = FALSE
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/applebreadslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("crisp-laden doughiness" = 1, "deliciously soft apples" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/applecake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "apple" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/applecakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/applecakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "apple" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/applenutcake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48, /datum/reagent/drug/nicotine = 1)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "apple" = 1, "nutty" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/applenutcakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/applenutcakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "apple" = 1, "nutty" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/berrycake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48, /datum/reagent/water = 5)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "berry" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/berrycakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/berrycakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "berry" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/berrysalmon
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN
	tastes = list("peppered fish" = 1, "fruity lightness" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/biscuit
	food_reagents = list(/datum/reagent/consumable/nutriment = 11.5)
	foodtypes = GRAIN | FRUIT | DAIRY
	tastes = list("crispy butterdough" = 1, "raisins" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/blackberrycake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "blackberry" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/blackberrycakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/blackberrycakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "blackberry" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/bookbread
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN | DAIRY
	tastes = list("chewy, crispy-edged butterdough" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 8
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/bookbread_slice
	slices_num = 5
	slice_batch = FALSE
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/bookbread_slice
	food_reagents = list(/datum/reagent/consumable/nutriment = 17)
	foodtypes = GRAIN | DAIRY
	tastes = list("chewy, crispy-edged butterdough" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/bread
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = GRAIN
	tastes = list("bread" = 1)
	cooktime = 300
	bitesize = 8
	rotprocess = 54000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/breadslice
	slices_num = 6
	slice_batch = FALSE
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/breadslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	cooktime = 300
	bitesize = 2
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/bun
	food_reagents = list(/datum/reagent/consumable/nutriment = 7.5)
	foodtypes = GRAIN
	tastes = list("bread" = 1)
	cooktime = 300
	rotprocess = 54000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/bun_grenz
	food_reagents = list(/datum/reagent/consumable/nutriment = 16.5)
	foodtypes = GRAIN | MEAT
	tastes = list("savory sausage" = 1, "bread" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/bun_jamtallow
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = GRAIN
	tastes = list("sweetly-sour jamminess" = 1, "a lavish break from the dae's woes" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_snack
	cooktime = 300
	bitesize = 4
	rotprocess = 54000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/bun_raston
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = GRAIN
	tastes = list("cheese" = 1, "bread" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_snack
	cooktime = 300
	rotprocess = 54000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/butterdough
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/bookbread
	cooktime = 300
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/butterdoughslice
	slices_num = 2
	rogue_cooked_smell = "fresh baked loaf of bookbread"

/obj/item/reagent_containers/food/snacks/rogue/butterdoughslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/pastry
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/frybread
	cooktime = 300
	rogue_cooked_smell = "fresh baked pastry"

/obj/item/reagent_containers/food/snacks/rogue/buttersole
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN
	tastes = list("fatty fish" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/cake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY
	tastes = list("cake" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/cake_base
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN | DAIRY
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/cake
	cooktime = 300
	rotprocess = 27000
	rogue_cooked_smell = "fresh baked cake"

/obj/item/reagent_containers/food/snacks/rogue/cakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/carrotcake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY | SUGAR | VEGETABLES
	tastes = list("cake" = 1, "sugary frosting" = 1, "carrot" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/carrotcakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/carrotcakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR | VEGETABLES
	tastes = list("cake" = 1, "sugary frosting" = 1, "carrot" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/carrotsteak
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = MEAT
	tastes = list("steak" = 1, "carrot" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/ccake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY
	tastes = list("cake" = 1, "creamy cheese" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/ccakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/ccakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY
	tastes = list("cake" = 1, "creamy cheese" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 2
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/ccakeuncooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN | DAIRY
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/ccake
	cooktime = 300
	rotprocess = 18000
	rogue_cooked_smell = "fresh baked cheese cake"

/obj/item/reagent_containers/food/snacks/rogue/cheddar
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = GRAIN
	tastes = list("cheese" = 1)
	cooktime = 300
	bitesize = 10
	rotprocess = 27000
	become_rot_type = /obj/item/reagent_containers/food/snacks/rogue/cheddar/aged
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cheddarwedge
	slices_num = 6
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/cheddarslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	tastes = list("cheese" = 1)
	cooktime = 300
	bitesize = 1
	rotprocess = 9000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("cheese" = 1)
	cooktime = 300
	rotprocess = 27000
	become_rot_type = /obj/item/reagent_containers/food/snacks/rogue/cheddarwedge/aged
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cheddarslice
	slices_num = 3
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/cheese
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("cheese" = 1)
	cooktime = 300
	bitesize = 1
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/cheesebun
	food_reagents = list(/datum/reagent/consumable/nutriment = 13.5)
	foodtypes = GRAIN | DAIRY
	tastes = list("crispy bread and cream cheese" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_snack
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/cookie
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = GRAIN | DAIRY
	tastes = list("rich and gooey chocolate" = 1, "crispy dough with a hint of butteriness" = 1)
	cooktime = 300
	bitesize = 8
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cookieslice
	slices_num = 6
	slice_batch = FALSE
	rogue_faretype = ROGUE_FARE_LAVISH
	rogue_cooked_smell = "freshly baked chocolate cookies"

/obj/item/reagent_containers/food/snacks/rogue/cookier
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = GRAIN | DAIRY | FRUIT
	tastes = list("little bursts of fruity sweetness" = 1, "crispy dough with a hint of butteriness" = 1)
	cooktime = 300
	bitesize = 8
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cookieslicer
	slices_num = 6
	slice_batch = FALSE
	rogue_faretype = ROGUE_FARE_FINE
	rogue_cooked_smell = "freshly baked raisined cookies"

/obj/item/reagent_containers/food/snacks/rogue/cookieslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = GRAIN | DAIRY
	tastes = list("rich and gooey chocolate" = 1, "crispy dough with a hint of butteriness" = 1)
	cooktime = 300
	bitesize = 2
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/cookieslicec
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = GRAIN | DAIRY
	tastes = list("tooth-grippingly sweet caramel" = 1, "crispy dough with a hint of butteriness" = 1)
	cooktime = 300
	bitesize = 2
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/cookieslicer
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = GRAIN | DAIRY | FRUIT
	tastes = list("little bursts of fruity sweetness" = 1, "crispy dough with a hint of butteriness" = 1)
	cooktime = 300
	bitesize = 2
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/crackerscooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("spelt" = 1)
	cooktime = 300
	bitesize = 6
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/dendorsalmon
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN
	tastes = list("warm fish" = 1, "fatty herbaceousness" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/dough
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/bread
	cooktime = 300
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/doughslice
	slices_num = 2

/obj/item/reagent_containers/food/snacks/rogue/dough_base
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooktime = 300

/obj/item/reagent_containers/food/snacks/rogue/doughslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/bun
	cooktime = 300
	rogue_cooked_smell = "fresh baked buns"

/obj/item/reagent_containers/food/snacks/rogue/eggplantcarved
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooktime = 300
	rotprocess = 27000

/obj/item/reagent_containers/food/snacks/rogue/eggplantmeat
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooktime = 300
	rotprocess = 27000

/obj/item/reagent_containers/food/snacks/rogue/eggplantstuffedraw
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/eggplantstuffed
	cooktime = 300
	rotprocess = 27000

/obj/item/reagent_containers/food/snacks/rogue/fishtomatoplate
	food_reagents = list(/datum/reagent/consumable/nutriment = 36)
	foodtypes = GRAIN | FRUIT | DAIRY | MEAT
	tastes = list("richly smooth and salty tomatoes" = 1, "hot and gooey cheese" = 1, "oily fish" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 8
	rotprocess = 54000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/fishtomatoplate_slice
	slices_num = 6
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/fishtomatoplate_slice
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = GRAIN | FRUIT | DAIRY | MEAT
	tastes = list("richly smooth and salty tomatoes" = 1, "hot and gooey cheese" = 1, "oily fish" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 54000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/flatdough
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/frybread
	cooktime = 300

/obj/item/reagent_containers/food/snacks/rogue/friedcrow
	food_reagents = list(/datum/reagent/consumable/nutriment = 4)
	foodtypes = GRAIN
	tastes = list("burnt flesh" = 1)
	cooktime = 300
	bitesize = 2
	rotprocess = 9000

/obj/item/reagent_containers/food/snacks/rogue/friedrat
	food_reagents = list(/datum/reagent/consumable/nutriment = 4)
	foodtypes = GRAIN
	tastes = list("burnt flesh" = 1)
	cooktime = 300
	bitesize = 2
	rotprocess = 9000

/obj/item/reagent_containers/food/snacks/rogue/frostedcake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY | SUGAR
	tastes = list("cake" = 1, "sugary frosting" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/frostedcakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/frostedcakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR
	tastes = list("cake" = 1, "sugary frosting" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/frostedcakeuncooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN | DAIRY | SUGAR
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	cooktime = 300
	rotprocess = 27000
	rogue_cooked_smell = "fresh baked frosted cake"

/obj/item/reagent_containers/food/snacks/rogue/frosting
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = DAIRY | SUGAR
	tastes = list("sugary frosting" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooktime = 300
	bitesize = 1
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/frybirdbucket
	food_reagents = list(/datum/reagent/consumable/nutriment = 45)
	foodtypes = VEGETABLES | MEAT
	tastes = list("frybird" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	warming = 1800
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/frybirdtato
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = VEGETABLES | MEAT
	tastes = list("frybird" = 1, "tato" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	warming = 1800
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/frybread
	food_reagents = list(/datum/reagent/consumable/nutriment = 8.5)
	foodtypes = GRAIN
	tastes = list("crispy bread with a soft inside" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 4
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/garlickbass
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN
	tastes = list("pungent aromatics" = 1, "flaky fish goodness" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/handpie
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 13)
	foodtypes = GRAIN
	tastes = list("crispy dough" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_snack
	cooktime = 300
	bitesize = 4
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/hcake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY | SUGAR
	tastes = list("cake" = 1, "delicious honeyfrosting" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/hcakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/hcakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR
	tastes = list("cake" = 1, "delicious honeyfrosting" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/hcakeuncooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN | DAIRY | SUGAR
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/hcake
	cooktime = 300
	rotprocess = 18000
	rogue_cooked_smell = "fresh baked honey cake"

/obj/item/reagent_containers/food/snacks/rogue/honey
	food_reagents = list(/datum/reagent/consumable/honey = 5, /datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("sweetness" = 1)
	cooktime = 300
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/lemoncake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "lemon" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/lemoncakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/lemoncakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "lemon" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/lemoncoppiette
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = GRAIN
	tastes = list("lip-puckering sweetness" = 1, "an unfortunate aftertaste of burnt wood" = 1)
	cooktime = 300
	bitesize = 5
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/limecake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "lime" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/limecakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/limecakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "lime" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/meat
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	eat_effect = /datum/status_effect/rogue_food/uncooked
	cooktime = 300
	rotprocess = 18000
	become_rot_type = /obj/item/reagent_containers/food/snacks/rogue/meat_rotten
	rogue_cooked_smell = "fried meat"

/obj/item/reagent_containers/food/snacks/rogue/meat_rotten
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN
	eat_effect = /datum/status_effect/rogue_food/rotten
	cooktime = 300

/obj/item/reagent_containers/food/snacks/rogue/meattomatoplate
	food_reagents = list(/datum/reagent/consumable/nutriment = 36)
	foodtypes = GRAIN | FRUIT | DAIRY | MEAT
	tastes = list("richly smooth and salty tomatoes" = 1, "hot and gooey cheese" = 1, "crispy sausages" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 8
	rotprocess = 54000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meattomatoplate_slice
	slices_num = 6
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/meattomatoplate_slice
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = GRAIN | FRUIT | DAIRY | MEAT
	tastes = list("richly smooth and salty tomatoes" = 1, "hot and gooey cheese" = 1, "crispy sausages" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 54000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/menthacake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY | SUGAR
	tastes = list("cake" = 1, "sugary frosting" = 1, "fresh herbaceousness" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/menthacakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/menthacakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR
	tastes = list("cake" = 1, "sugary frosting" = 1, "fresh herbaceousness" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/onionplaice
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN
	tastes = list("oniony fish" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/onionsteak
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = MEAT
	tastes = list("steak" = 1, "onions" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/pastry
	food_reagents = list(/datum/reagent/consumable/nutriment = 7.5)
	foodtypes = GRAIN
	tastes = list("crispy butterdough" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 54000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/peacecake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "peace" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/peacecakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/peacecakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "peace" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/pepperfish
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = GRAIN
	tastes = list("warm fish" = 1, "pepper" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/pepperlobsta
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = GRAIN
	tastes = list("peppered crustacean" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/peppersteak
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	tastes = list("steak" = 1, "pepper" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/piedough
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/foodbase/piebottom
	cooktime = 300
	rogue_cooked_smell = "fresh baked pie crust"

/obj/item/reagent_containers/food/snacks/rogue/pieslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY
	tastes = list("pie" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/prezzel
	food_reagents = list(/datum/reagent/consumable/nutriment = 7.5)
	foodtypes = GRAIN
	tastes = list("crispy butterdough" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/psycrossbun
	food_reagents = list(/datum/reagent/consumable/nutriment = 7.5)
	foodtypes = GRAIN
	tastes = list("bread" = 1)
	cooktime = 300
	rotprocess = 54000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/psycrossbun_jamtallowed
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN | FRUIT
	tastes = list("sweet-tarty jamminess" = 1, "a sense of enduring sorrow" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_snack
	cooktime = 300
	bitesize = 4
	rotprocess = 54000
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/raisinbread
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN
	tastes = list("crisp-laden doughiness" = 1, "little bursts of caramelized fruitiness" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 8
	rotprocess = 54000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/raisinbreadslice
	slices_num = 6
	slice_batch = FALSE
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/raisinbreadslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	foodtypes = GRAIN
	tastes = list("crisp-laden doughiness" = 1, "little bursts of caramelized fruitiness" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/raisins
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("dried jackberries" = 1, "shriveled bursts of sweetness" = 1)
	cooktime = 300
	bitesize = 5
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/raspberrycake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "raspberry" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/raspberrycakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/raspberrycakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "raspberry" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/ricebeef
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = GRAIN
	tastes = list("rice" = 1, "steak" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/ricebeefcar
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN
	tastes = list("rice" = 1, "steak" = 1, "carrot" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_meal
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/ricebird
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = GRAIN
	tastes = list("rice" = 1, "tasty birdmeat" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/ricebirdcar
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN
	tastes = list("rice" = 1, "tasty birdmeat" = 1, "carrot" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_meal
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/ricecheese
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = GRAIN
	tastes = list("rice" = 1, "cheese" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/riceegg
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = GRAIN
	tastes = list("rice" = 1, "egg" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/riceeggcheese
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = GRAIN
	tastes = list("rice" = 1, "cheese" = 1, "egg" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_meal
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/ricepork
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = GRAIN
	tastes = list("rice" = 1, "pork" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/riceporkcuc
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN
	tastes = list("rice" = 1, "pork" = 1, "fresh cucumber" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_meal
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/riceshrimp
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = GRAIN
	tastes = list("rice" = 1, "shrimp" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/riceshrimpcar
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = GRAIN
	tastes = list("rice" = 1, "shrimp" = 1, "carrot" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_meal
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/ricewet
	foodtypes = GRAIN
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/rice_cooked
	cooktime = 300

/obj/item/reagent_containers/food/snacks/rogue/rocknutcake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48, /datum/reagent/drug/nicotine = 1)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "nutty" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/rocknutcakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/rocknutcakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "nutty" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/steakcarrotonion
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = VEGETABLES | MEAT
	tastes = list("steak" = 1, "onion" = 1, "carrots" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_meal
	cooktime = 300
	rotprocess = 18000
	warming = 1800
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/strawberrycake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "strawberry" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/strawberrycakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/strawberrycakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "strawberry" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/tangerinecake
	food_reagents = list(/datum/reagent/consumable/nutriment = 48)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "tangerine" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 16
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/tangerinecakeslice
	slices_num = 8
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/tangerinecakeslice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "tangerine" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/toastcrumbs
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("crunch" = 1)
	cooktime = 300
	bitesize = 1
	rotprocess = 18000

/obj/item/reagent_containers/food/snacks/rogue/tomatoplate
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = GRAIN | FRUIT | DAIRY
	tastes = list("richly smooth and salty tomatoes" = 1, "hot and gooey cheese" = 1, "a hint of herbiness" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 8
	rotprocess = 54000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/tomatoplate_slice
	slices_num = 6
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/tomatoplate_slice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | FRUIT | DAIRY
	tastes = list("richly smooth and salty tomatoes" = 1, "hot and gooey cheese" = 1, "a hint of herbiness" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 54000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/trailmix
	food_reagents = list(/datum/reagent/consumable/nutriment = 27)
	foodtypes = GRAIN
	tastes = list("raisin" = 1, "pumpkin" = 1, "dry paper" = 1)
	cooktime = 300
	bitesize = 7
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/truffles
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	foodtypes = GRAIN
	tastes = list("mushroom" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/truffles/cooked
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/truffles/cooked
	cooktime = 300
	rogue_cooked_smell = "cooked truffles"

/obj/item/reagent_containers/food/snacks/rogue/wienercabbage
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = VEGETABLES | MEAT
	tastes = list("savory sausage" = 1, "cabbage" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 27000
	warming = 1800
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/wieneronions
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = VEGETABLES | MEAT
	tastes = list("savory sausage" = 1, "fried onions" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 27000
	warming = 1800
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/wienerpotato
	food_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = VEGETABLES | MEAT
	tastes = list("savory sausage" = 1, "potato" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 27000
	warming = 1800
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/wienerpotatonions
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = VEGETABLES | MEAT
	tastes = list("savory sausage" = 1, "potato" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_meal
	cooktime = 300
	rotprocess = 18000
	warming = 1800
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/smallrat/dead
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	foodtypes = RAW
	rotprocess = 9000

/obj/item/reagent_containers/food/snacks/sugarstatue/amark
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 2
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/arch
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/archway
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 4
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/castle
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 4
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/dmark
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 2
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/flag
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 2
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/hmark
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 2
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/house
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 2
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/pmark
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 2
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/smark
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 2
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/statuek
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/statuel
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/statuer
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/statuey
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/tower
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/towers
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 2
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/tree
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/sugarstatue/zmark
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("crispy sugarglass" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 2
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/tallow/red
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("grease" = 1, "oil" = 1, "regret" = 1, "blood" = 1)

/obj/item/reagent_containers/food/snacks/tallow/soft
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("grease" = 1, "oil" = 1, "regret" = 1)

/obj/item/reagent_containers/food/snacks/fat/salo/slice
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	bitesize = 2
	slice_path = null
	slices_num = 0

/obj/item/reagent_containers/food/snacks/grown/berries/rogue
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/water = 5)
	tastes = list("berry" = 1)
	bitesize = 5
	rotprocess = 9000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/grown/cabbage/rogue
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("blandness" = 1)
	bitesize = 10
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/veg/cabbage_sliced
	slices_num = 3

/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("blackberry" = 1)
	bitesize = 2
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry_sugared
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = FRUIT
	tastes = list("overpoweringly sweet" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 2
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/grown/fruit/lemon
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("lemon" = 1)
	bitesize = 2
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/fruit/lime
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("lime" = 1)
	bitesize = 2
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/fruit/pear
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("pear" = 1)
	bitesize = 2
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/fruit/plum
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("plum" = 1)
	bitesize = 2
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/fruit/raspberry
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("raspberry" = 1)
	bitesize = 2
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/fruit/strawberry
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("strawberry" = 1)
	bitesize = 2
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/fruit/tangerine
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("tangerine" = 1)
	bitesize = 2
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/fruit/tangerine_sugared
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = FRUIT
	tastes = list("overpoweringly sweet" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	bitesize = 2
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/grown/fruit/tomato
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("tomato" = 1)
	bitesize = 2
	rotprocess = 18000
	slice_path = /obj/item/reagent_containers/food/snacks/grown/fruit/tomato_sliced
	slices_num = 1
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/fruit/tomato_sliced
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("to" = 1, "mato" = 1)
	bitesize = 2
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/garlick/rogue
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/water/blessed = 2)
	tastes = list("pungent savoriness" = 1)
	bitesize = 2
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/veg/garlick_clove
	slices_num = 5

/obj/item/reagent_containers/food/snacks/grown/onion/rogue
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("spicy sweetness" = 1)
	bitesize = 2
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/veg/onion_sliced
	slices_num = 2

/obj/item/reagent_containers/food/snacks/grown/potato/rogue
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	tastes = list("potato" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/potato_baked
	bitesize = 2
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/veg/potato_sliced
	slices_num = 2

/obj/item/reagent_containers/food/snacks/grown/rogue/chocolate_spiced
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("sugary richness" = 1, "a mouthful of cough-inducing powderiness" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	bitesize = 2
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/grown/rogue/fyritius
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/toxin/fyritiusnectar = 5)
	tastes = list("tastes like a burning coal and fire" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed
	food_reagents = list(/datum/reagent/drug/nicotine = 2, /datum/reagent/consumable/nutriment = 1, /datum/reagent/berrypoison = 5)
	foodtypes = VEGETABLES
	tastes = list("sweet" = 1, "bitterness" = 1)
	eat_effect = /datum/status_effect/rogue_food/bad_meal
	rotprocess = 9000

/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry
	food_reagents = list(/datum/reagent/drug/nicotine = 5, /datum/reagent/consumable/nutriment = 1)
	eat_effect = /datum/status_effect/rogue_food/bad_meal

/obj/item/reagent_containers/food/snacks/grown/rogue/rosa_petals
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/medicine/antidote = 1)
	tastes = list("mild sweetness" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/rogue/rosa_petals_dried
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/medicine/antidote = 1)
	tastes = list("mild sweetness" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/rogue/rosa_petals_spiced
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/medicine/antidote = 1)
	tastes = list("mild sweetness" = 1, "a mouthful of cough-inducing powderiness" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/rogue/swampweed
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/berrypoison = 5)
	foodtypes = VEGETABLES
	tastes = list("sweet" = 1, "bitterness" = 1)
	eat_effect = /datum/status_effect/rogue_food/bad_meal
	rotprocess = 9000

/obj/item/reagent_containers/food/snacks/grown/rogue/swampweeddry
	food_reagents = list(/datum/reagent/drug/space_drugs = 2, /datum/reagent/consumable/nutriment = 1)
	eat_effect = /datum/status_effect/rogue_food/bad_meal

/obj/item/reagent_containers/food/snacks/grown/rogue/tealeaves_dry
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("bitterness" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/rogue/tealeaves_ground
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("bitterness" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/rogue/tealeaves_spiced
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("bitterness" = 1, "a mouthful of cough-inducing powderiness" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/grown/sugarshape/amark
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/amark
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/arch
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/arch
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/archway
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/archway
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/castle
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/castle
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/dmark
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/dmark
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/flag
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/flag
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/hmark
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/hmark
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/house
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/house
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/pmark
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/pmark
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/smark
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/smark
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/statuek
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/statuek
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/statuel
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/statuel
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/statuer
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/statuer
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/statuey
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/statuey
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/tower
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/tower
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/towers
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/towers
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/tree
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/tree
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/sugarshape/zmark
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("a mouthful of sugar" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/sweet
	cooked_type = /obj/item/reagent_containers/food/snacks/sugarstatue/zmark
	bitesize = 2
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/grown/vegetable/turnip
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = VEGETABLES
	tastes = list("dirt" = 1)
	bitesize = 1
	rotprocess = 54000
	slice_path = /obj/item/reagent_containers/food/snacks/veg/turnip_sliced
	slices_num = 1

/obj/item/reagent_containers/food/snacks/rogue/berrycake/poison
	food_reagents = list(/datum/reagent/berrypoison = 5, /datum/reagent/consumable/nutriment = 48, /datum/reagent/water = 5)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "berry" = 1)
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/berrycakeslice/poison

/obj/item/reagent_containers/food/snacks/rogue/berrycakeslice/poison
	food_reagents = list(/datum/reagent/berrypoison = 1, /datum/reagent/consumable/nutriment = 6, /datum/reagent/water = 1)
	foodtypes = GRAIN | DAIRY | SUGAR | FRUIT
	tastes = list("cake" = 1, "sugary frosting" = 1, "berry" = 1)

/obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	tastes = list("crispy bread" = 1)
	cooked_type = null
	bitesize = 3
	rotprocess = 0
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/cheddar/aged
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = GRAIN
	tastes = list("cheese" = 1)
	rotprocess = 0
	become_rot_type = null
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cheddarwedge/aged
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/cheddarslice/aged
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	tastes = list("cheese" = 1)
	rotprocess = 0
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge/aged
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("cheese" = 1)
	rotprocess = 0
	become_rot_type = null
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cheddarslice/aged
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN
	eat_effect = /datum/status_effect/rogue_food/uncooked
	cooktime = 300

/obj/item/reagent_containers/food/snacks/rogue/foodbase/chickentender
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN
	eat_effect = /datum/status_effect/rogue_food/uncooked
	cooktime = 300
	rogue_cooked_smell = "fried chicken"

/obj/item/reagent_containers/food/snacks/rogue/foodbase/cookie_raw
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN | DAIRY
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/cookie
	cooktime = 300
	rogue_cooked_smell = "freshly baked chocolate cookies"

/obj/item/reagent_containers/food/snacks/rogue/foodbase/cookier_raw
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN | DAIRY | FRUIT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/cookier
	cooktime = 300
	rogue_cooked_smell = "freshly baked raisined cookies"

/obj/item/reagent_containers/food/snacks/rogue/foodbase/halfcookie_raw
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN | DAIRY
	cooktime = 300
	rogue_cooked_smell = "freshly baked chocolate cookies"

/obj/item/reagent_containers/food/snacks/rogue/foodbase/halfcookier_raw
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN | DAIRY | FRUIT
	cooktime = 300
	rogue_cooked_smell = "freshly baked raisined cookies"

/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN
	eat_effect = /datum/status_effect/rogue_food/uncooked
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/handpie
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/handpie
	cooktime = 300

/obj/item/reagent_containers/food/snacks/rogue/foodbase/hardtack_raw
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/crackerscooked
	cooktime = 300
	rogue_cooked_smell = "fresh baked crackers"

/obj/item/reagent_containers/food/snacks/rogue/foodbase/nitzel
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN
	eat_effect = /datum/status_effect/rogue_food/uncooked
	cooktime = 300
	rogue_cooked_smell = "fried meat"

/obj/item/reagent_containers/food/snacks/rogue/foodbase/piebottom
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN
	eat_effect = /datum/status_effect/rogue_food/uncooked
	cooktime = 300
	rogue_cooked_smell = "fresh baked pie crust"

/obj/item/reagent_containers/food/snacks/rogue/foodbase/schnitzel
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN
	eat_effect = /datum/status_effect/rogue_food/uncooked
	cooktime = 300
	rogue_cooked_smell = "fried meat"

/obj/item/reagent_containers/food/snacks/rogue/foodbase/squires_delight
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN
	eat_effect = /datum/status_effect/rogue_food/uncooked
	cooktime = 300
	rogue_cooked_smell = "fried butter"

/obj/item/reagent_containers/food/snacks/rogue/foodbase/wienernitzel
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN
	eat_effect = /datum/status_effect/rogue_food/uncooked
	cooktime = 300
	rogue_cooked_smell = "fried sausage"

/obj/item/reagent_containers/food/snacks/rogue/friedegg/bacon
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = MEAT
	tastes = list("fried egg" = 1, "bacon" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/friedegg/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	tastes = list("fried egg" = 1)
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/friedegg/hammerhold
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = MEAT
	tastes = list("fried egg" = 1, "sausage" = 1, "bacon" = 1, "toast" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_LAVISH
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/friedegg/sausage
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = MEAT
	tastes = list("fried egg" = 1, "sausage" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/friedegg/sausagebacon
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = MEAT
	tastes = list("fried egg" = 1, "sausage" = 1, "bacon" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/friedegg/tiberian
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = MEAT
	tastes = list("fried egg" = 1, "cheese" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/friedegg/two
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = MEAT
	tastes = list("fried egg" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/fruit/apple_sliced
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	tastes = list("airy apple" = 1)
	cooktime = 300
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/fruit/pumpkin_sliced
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	tastes = list("pumpkin" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/pumpkin_mashed
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/pumpkin_mashed
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/fryfish/carp
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	foodtypes = MEAT
	tastes = list("fish" = 1)
	cooktime = 300

/obj/item/reagent_containers/food/snacks/rogue/fryfish/cod
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	foodtypes = MEAT
	tastes = list("fish" = 1)
	cooktime = 300
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/fryfish/crab
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	foodtypes = MEAT
	tastes = list("crab" = 1)
	cooktime = 300
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/fryfish/lobster
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	foodtypes = MEAT
	tastes = list("fish" = 1)
	cooktime = 300
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/fryfish/plaice
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	foodtypes = MEAT
	tastes = list("fish" = 1)
	cooktime = 300
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/fryfish/salmon
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	foodtypes = MEAT
	tastes = list("fish" = 1)
	cooktime = 300
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/fryfish/shrimp
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	foodtypes = MEAT
	tastes = list("shrimp" = 1)
	cooktime = 300
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/fryfish/sole
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	foodtypes = MEAT
	tastes = list("fish" = 1)
	cooktime = 300
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/fryfish/sunny
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	foodtypes = MEAT
	tastes = list("fish" = 1)
	cooktime = 300
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/handpie/apple
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 13)
	foodtypes = GRAIN
	tastes = list("crispy dough" = 1)

/obj/item/reagent_containers/food/snacks/rogue/handpie/berry
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 13)
	foodtypes = GRAIN
	tastes = list("crispy dough" = 1)

/obj/item/reagent_containers/food/snacks/rogue/handpie/cabbage
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 13)
	foodtypes = GRAIN
	tastes = list("crispy dough" = 1)

/obj/item/reagent_containers/food/snacks/rogue/handpie/crab
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 13)
	foodtypes = GRAIN
	tastes = list("crispy dough" = 1)

/obj/item/reagent_containers/food/snacks/rogue/handpie/fish
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 13)
	foodtypes = GRAIN
	tastes = list("crispy dough" = 1)

/obj/item/reagent_containers/food/snacks/rogue/handpie/meat
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 13)
	foodtypes = GRAIN
	tastes = list("crispy dough" = 1)

/obj/item/reagent_containers/food/snacks/rogue/handpie/potato
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 13)
	foodtypes = GRAIN
	tastes = list("crispy dough" = 1)

/obj/item/reagent_containers/food/snacks/rogue/honey/spider
	food_reagents = list(/datum/reagent/consumable/honey = 5, /datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("sweetness and spiderwebs" = 1)

/obj/item/reagent_containers/food/snacks/rogue/meat/bacon
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried
	rogue_cooked_smell = "fried bacon"

/obj/item/reagent_containers/food/snacks/rogue/meat/brothbrique
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = MEAT
	tastes = list("salted meat" = 1, "dried berries" = 1, "a slightly greasy aftertaste" = 1)
	eat_effect = null
	bitesize = 6
	rotprocess = 0
	become_rot_type = null
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/brothbrique/slice
	slices_num = 4
	slice_batch = FALSE
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/meat/chickentender
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = MEAT | GRAIN
	tastes = list("crunchy toastcrumbs" = 1, "tender chicken" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_snack
	bitesize = 5
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	tastes = list("salted meat" = 1)
	eat_effect = null
	bitesize = 5
	rotprocess = 0
	become_rot_type = null
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/meat/crab
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/crab/fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/crab/fried
	rogue_cooked_smell = "fried crab"

/obj/item/reagent_containers/food/snacks/rogue/meat/driedfishfilet
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	tastes = list("salted fish" = 1)
	eat_effect = null
	rotprocess = 0
	become_rot_type = null
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/meat/fatty
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/fatty/roast
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/bacon
	slices_num = 3
	slice_bclass = BCLASS_CHOP

/obj/item/reagent_containers/food/snacks/rogue/meat/fish
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/fish/fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/fish/fried
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/mince/fish
	slices_num = 1
	rogue_cooked_smell = "cooked fish"

/obj/item/reagent_containers/food/snacks/rogue/meat/mince
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	rotprocess = 6000

/obj/item/reagent_containers/food/snacks/rogue/meat/nitzel
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = MEAT | GRAIN
	tastes = list("crunchy toastcrumbs" = 1, "tender pork" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_snack
	bitesize = 5
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/meat/pork_belly
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = MEAT
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/bacon
	slices_num = 4
	rogue_cooked_smell = "fried bacon"

/obj/item/reagent_containers/food/snacks/rogue/meat/poultry
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet
	slices_num = 2
	rogue_cooked_smell = "cooked chicken"

/obj/item/reagent_containers/food/snacks/rogue/meat/rabbit
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/rabbit/fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/rabbit/fried
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/mince/rabbit
	slices_num = 1

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga/cooked
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga/cooked
	rotprocess = 27000

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins/cooked
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins/cooked
	rotprocess = 27000

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins_z
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	eat_effect = /datum/status_effect/rogue_food/rotten
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins_z/cooked
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins_z/cooked
	rotprocess = 0
	become_rot_type = null

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime/cooked
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime/cooked
	rotprocess = 27000

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime_z
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	eat_effect = /datum/status_effect/rogue_food/rotten
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime_z/cooked
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime_z/cooked
	rotprocess = 0
	become_rot_type = null

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs/cooked
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs/cooked
	rotprocess = 27000

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs_z
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	eat_effect = /datum/status_effect/rogue_food/rotten
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs_z/cooked
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs_z/cooked
	rotprocess = 0
	become_rot_type = null

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	eat_effect = /datum/status_effect/rogue_food/rotten
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z/cooked
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z/cooked
	rotprocess = 0
	become_rot_type = null

/obj/item/reagent_containers/food/snacks/rogue/meat/salami
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	tastes = list("salted meat" = 1)
	eat_effect = null
	bitesize = 7
	rotprocess = 0
	become_rot_type = null
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/salami/slice
	slices_num = 4
	slice_batch = FALSE
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/meat/sausage
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked
	rogue_cooked_smell = "fried sausage"

/obj/item/reagent_containers/food/snacks/rogue/meat/shellfish
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/shellfish/fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/shellfish/fried
	rotprocess = 27000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/mince/fish
	slices_num = 1
	rogue_cooked_smell = "fried shellfish"

/obj/item/reagent_containers/food/snacks/rogue/meat/spider
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	tastes = list("chitin" = 1, "mild venom" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/spider/fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/spider/fried
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/mince/spider
	slices_num = 2
	rogue_cooked_smell = "fried spidermeat"

/obj/item/reagent_containers/food/snacks/rogue/meat/steak
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/mince/beef
	slices_num = 2
	slice_bclass = BCLASS_CHOP

/obj/item/reagent_containers/food/snacks/rogue/peppersteak/ducal
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	tastes = list("steak" = 1, "pepper" = 1, "garlick" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_meal
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/pieslice/pumpkin
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	tastes = list("crispy butterdough" = 1, "pumpkin" = 1, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/rogue/preserved/cabbage_fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("warm cabbage" = 1)
	cooktime = 300
	bitesize = 6
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_POOR
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/preserved/carrot_baked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("carrot" = 1)
	cooktime = 300
	bitesize = 6
	rotprocess = 18000

/obj/item/reagent_containers/food/snacks/rogue/preserved/eggplantstuffed
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = GRAIN
	tastes = list("meat" = 1, "tomato" = 1, "aubergine" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/preserved/eggplantstuffedcheese
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = GRAIN
	tastes = list("meat" = 1, "tomato" = 1, "aubergine" = 1, "cheese" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_snack
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/preserved/onion_fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("savoury morsel" = 1)
	cooktime = 300
	bitesize = 6
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/preserved/potato_baked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	cooktime = 300
	bitesize = 4
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/preserved/potato_fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("warm potato" = 1)
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/preserved/pumpkin_mashed
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_POOR
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/preserved/rice_cooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	cooktime = 300
	rotprocess = 27000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/raisins/blackberry
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("dried blackberries" = 1, "shriveled bursts of sour-sweetness" = 1)

/obj/item/reagent_containers/food/snacks/rogue/raisins/lemon
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("dried lemons" = 1, "shriveled bursts of tarty-sourness" = 1)

/obj/item/reagent_containers/food/snacks/rogue/raisins/lime
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("dried limes" = 1, "shriveled bursts of sour-tartiness" = 1)

/obj/item/reagent_containers/food/snacks/rogue/raisins/pear
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("dried pears" = 1, "shriveled bursts of tarty-honeyiness" = 1)

/obj/item/reagent_containers/food/snacks/rogue/raisins/plum
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("dried plums" = 1, "shriveled bursts of honey-sweetness" = 1)

/obj/item/reagent_containers/food/snacks/rogue/raisins/raspberry
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("dried raspberries" = 1, "shriveled bursts of tartness" = 1)

/obj/item/reagent_containers/food/snacks/rogue/raisins/strawberry
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("dried strawberries" = 1, "shriveled bursts of sweetness" = 1)

/obj/item/reagent_containers/food/snacks/rogue/raisins/tangerine
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("dried tangerines" = 1, "shriveled bursts of tarty-sweetness" = 1)

/obj/item/reagent_containers/food/snacks/rogue/sandwich/bacon
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN | MEAT
	tastes = list("bacon" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 4
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/sandwich/cheese
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = GRAIN | DAIRY
	tastes = list("cheese" = 1, "bread" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 4
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/sandwich/egg
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN | MEAT
	tastes = list("cheese" = 1, "egg" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 4
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/sandwich/ham
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = GRAIN | MEAT
	tastes = list("ham" = 1, "bread" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 4
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/sandwich/salami
	food_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = GRAIN | MEAT
	tastes = list("salumoi" = 1, "bread" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 4
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/sandwich/salo
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = GRAIN | MEAT
	tastes = list("salty fat" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 4
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/truffles/cooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2)
	foodtypes = GRAIN
	tastes = list("succulent truffles" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooked_type = null
	fried_type = null

/obj/item/reagent_containers/food/snacks/rogue/veg/cabbage_sliced
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/cabbage_fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/cabbage_fried
	cooktime = 300
	rogue_cooked_smell = "fried cabbage"

/obj/item/reagent_containers/food/snacks/rogue/veg/cucumber_sliced
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	tastes = list("crunchy freshness" = 1)
	cooktime = 300

/obj/item/reagent_containers/food/snacks/rogue/veg/garlick_clove
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/water/blessed = 2)
	foodtypes = GRAIN
	tastes = list("pungent savoriness" = 1)
	cooktime = 300
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/veg/onion_sliced
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/onion_fried
	cooktime = 300
	rogue_cooked_smell = "fried onion"

/obj/item/reagent_containers/food/snacks/rogue/veg/potato_sliced
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtypes = GRAIN
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/potato_fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/potato_fried
	cooktime = 300
	rogue_cooked_smell = "baked potatos"

/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison
	food_reagents = list(/datum/reagent/berrypoison = 5, /datum/reagent/consumable/nutriment = 3, /datum/reagent/water = 5)
	tastes = list("berry" = 1)

/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry/skysugarbase
	food_reagents = list(/datum/reagent/toxin/killersice = 1, /datum/reagent/starsugar = 8, /datum/reagent/water = 7, /datum/reagent/consumable/nutriment = 3)
	foodtypes = FRUIT
	tastes = list("a horrifically bad idea" = 1, "slightly fruity aftertaste" = 1)
	eat_effect = /datum/status_effect/rogue_food/uncooked
	rogue_faretype = ROGUE_FARE_IMPOVERISHED
	rogue_deep_fried_type = /obj/item/reagent_containers/food/snacks/grown/skysugarslab

/obj/item/reagent_containers/food/snacks/grown/rogue/fyritius/bloodied
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/toxin/fyritiusnectar = 5)
	tastes = list("tastes like a burning coal and fire and blood" = 1)
	rotprocess = 9000

/obj/item/reagent_containers/food/snacks/rogue/breadslice/toast/buttered
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = GRAIN
	tastes = list("butter" = 1)
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/apple
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN | FRUIT
	tastes = list("apple" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/apple
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/apple

/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/berry
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN | FRUIT
	tastes = list("berry" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/berry
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/berry

/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/cabbage
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN | VEGETABLES
	tastes = list("cabbage" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/cabbage
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/cabbage

/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/crab
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN | MEAT
	tastes = list("crab" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/crab
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/crab

/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/fish
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN | MEAT
	tastes = list("fish" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/fish
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/fish

/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/meat
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN | MEAT
	tastes = list("meat" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/meat
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/meat

/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/mushroom
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN | VEGETABLES
	tastes = list("mushrooms" = 1)

/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/potato
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = GRAIN | VEGETABLES
	tastes = list("potato" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/potato
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/handpie/potato

/obj/item/reagent_containers/food/snacks/rogue/fryfish/lobster/meal
	food_reagents = list(/datum/reagent/consumable/nutriment = 18)
	foodtypes = MEAT
	tastes = list("lobster" = 1, "butter" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	rotprocess = 18000
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	eat_effect = null
	cooked_type = null
	fried_type = null
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/meat/brothbrique/slice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	tastes = list("salted meat" = 1, "dried berries" = 1, "a slightly greasy aftertaste" = 1)
	bitesize = 3
	slice_path = null
	slices_num = 0

/obj/item/reagent_containers/food/snacks/rogue/meat/crab/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	eat_effect = null
	cooked_type = null
	fried_type = null
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/meat/fatty/roast
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	tastes = list("crispy pork" = 1)
	eat_effect = null
	fried_type = null
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/meat/fish/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	tastes = list("warm fish" = 1)
	eat_effect = null
	cooked_type = null
	fried_type = null
	slice_path = null
	slices_num = 0
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/meat/ham/boar
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	tastes = list("hog" = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/ham/steamed
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/ham/steamed

/obj/item/reagent_containers/food/snacks/rogue/meat/ham/sliced
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = MEAT
	tastes = list("hog" = 1)
	eat_effect = null
	bitesize = 2

/obj/item/reagent_containers/food/snacks/rogue/meat/ham/steamed
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = MEAT
	tastes = list("hog" = 1)
	eat_effect = null
	bitesize = 6
	rotprocess = 0
	become_rot_type = null
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/ham/sliced
	slices_num = 4
	slice_batch = FALSE
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/meat/mince/beef
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT

/obj/item/reagent_containers/food/snacks/rogue/meat/mince/fish
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT

/obj/item/reagent_containers/food/snacks/rogue/meat/mince/poultry
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	rogue_cooked_smell = "cooked chicken"

/obj/item/reagent_containers/food/snacks/rogue/meat/mince/rabbit
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT

/obj/item/reagent_containers/food/snacks/rogue/meat/mince/spider
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT

/obj/item/reagent_containers/food/snacks/rogue/meat/nitzel/schnitzel
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = MEAT | GRAIN
	tastes = list("crunchy toastcrumbs" = 1, "tender spidermeat" = 1)

/obj/item/reagent_containers/food/snacks/rogue/meat/nitzel/wiener
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = MEAT | GRAIN
	tastes = list("crunchy toastcrumbs" = 1, "tender wiener" = 1)

/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = MEAT
	tastes = list("tasty birdmeat" = 1)
	eat_effect = null
	cooked_type = null
	slice_path = null
	slices_num = 0
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet/fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet/fried
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/mince/poultry
	slices_num = 1
	slice_bclass = BCLASS_CHOP

/obj/item/reagent_containers/food/snacks/rogue/meat/rabbit/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	tastes = list("warm cabbit" = 1)
	eat_effect = null
	cooked_type = null
	fried_type = null
	slice_path = null
	slices_num = 0
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga/cooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = MEAT
	tastes = list("forest venison" = 1)
	eat_effect = null
	cooked_type = null
	fried_type = null
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins/cooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = MEAT
	tastes = list("forest loins" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	cooked_type = null
	fried_type = null
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins_z/cooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	tastes = list("grout and grime" = 1)
	eat_effect = null
	cooked_type = null
	fried_type = null
	rotprocess = 27000
	become_rot_type = /obj/item/reagent_containers/food/snacks/rogue/meat_rotten
	rogue_faretype = ROGUE_FARE_POOR
	rogue_cooked_smell = "rotten flesh"

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime/cooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = MEAT
	tastes = list("forest bounty" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_meal
	cooked_type = null
	fried_type = null
	bitesize = 6
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime_z/cooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = MEAT
	tastes = list("grout and grime" = 1)
	eat_effect = null
	cooked_type = null
	fried_type = null
	bitesize = 6
	rotprocess = 27000
	become_rot_type = /obj/item/reagent_containers/food/snacks/rogue/meat_rotten
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_cooked_smell = "rotten flesh"

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs/cooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = MEAT
	tastes = list("forest venison" = 1)
	eat_effect = null
	cooked_type = null
	fried_type = null
	rogue_faretype = ROGUE_FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs_z/cooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	tastes = list("grout and grime" = 1)
	cooked_type = null
	fried_type = null
	rotprocess = 27000
	become_rot_type = /obj/item/reagent_containers/food/snacks/rogue/meat_rotten
	rogue_faretype = ROGUE_FARE_POOR
	rogue_cooked_smell = "rotten flesh"

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z/cooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	tastes = list("grout and grime" = 1)
	cooked_type = null
	fried_type = null
	rotprocess = 27000
	become_rot_type = /obj/item/reagent_containers/food/snacks/rogue/meat_rotten
	rogue_faretype = ROGUE_FARE_POOR
	rogue_cooked_smell = "rotten flesh"

/obj/item/reagent_containers/food/snacks/rogue/meat/salami/slice
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = MEAT
	tastes = list("salted meat" = 1)
	bitesize = 2
	slice_path = null
	slices_num = 0
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	eat_effect = null
	cooked_type = null
	fried_type = null
	rotprocess = 54000
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/meat/shellfish/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	eat_effect = null
	cooked_type = null
	fried_type = null
	slice_path = null
	slices_num = 0
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/meat/spider/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = MEAT
	tastes = list("chitin" = 1, "mild venom" = 1)
	eat_effect = null
	cooked_type = null
	fried_type = null
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/bear
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/bear/fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/bear/fried

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/beetle
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/beetle/cooked

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	tastes = list("warm steak" = 1)
	eat_effect = null
	cooked_type = null
	fried_type = null
	slice_path = null
	slices_num = 0
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/gnoll
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/gnoll/seared
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/gnoll/seared
	rotprocess = 54000

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/rat
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/rat/fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/rat/fried

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/troll
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/troll/fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/troll/fried
	rotprocess = 54000
	slice_path = null
	slices_num = 0

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/vilespawn
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = null
	fried_type = null
	rotprocess = 0
	become_rot_type = null
	slice_path = null
	slices_num = 0

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf/fried
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf/fried

/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/apple
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = GRAIN | DAIRY
	tastes = list("baked apples and crispy butterdough" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 7
	warming = 6000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/pieslice
	slices_num = 4
	rogue_faretype = ROGUE_FARE_LAVISH
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/berry
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = GRAIN | DAIRY
	tastes = list("crispy butterdough" = 1, "sweet berries" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 7
	warming = 6000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/pieslice
	slices_num = 4
	rogue_faretype = ROGUE_FARE_LAVISH
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/crab
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = GRAIN | DAIRY
	tastes = list("crispy butterdough" = 1, "rich crab meat" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 7
	warming = 6000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/pieslice
	slices_num = 4
	rogue_faretype = ROGUE_FARE_LAVISH
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/meat
	food_reagents = list(/datum/reagent/consumable/nutriment = 30)
	foodtypes = GRAIN | DAIRY | MEAT
	tastes = list("succulent meat and crispy butterdough" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 8
	warming = 6000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/pieslice
	slices_num = 5
	rogue_faretype = ROGUE_FARE_LAVISH
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/poison
	food_reagents = list(/datum/reagent/consumable/nutriment = 24, /datum/reagent/berrypoison = 12)
	foodtypes = GRAIN | DAIRY
	tastes = list("crispy butterdough" = 1, "bitter berries" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 7
	warming = 6000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/pieslice
	slices_num = 4
	rogue_faretype = ROGUE_FARE_LAVISH
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/pot
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = GRAIN | DAIRY | MEAT
	tastes = list("succulent filling and crispy butterdough" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 8
	warming = 6000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/pieslice
	slices_num = 5
	rogue_faretype = ROGUE_FARE_LAVISH
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/pumpkin
	food_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	tastes = list("crispy butterdough" = 1, "pumpkin" = 1, "cheese" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/snack
	cooktime = 300
	bitesize = 8
	warming = 6000
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/pieslice/pumpkin
	slices_num = 4
	rogue_faretype = ROGUE_FARE_LAVISH
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked/butter
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = MEAT
	tastes = list("buttery birdmeat" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked/doublestacked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 30)
	foodtypes = MEAT
	tastes = list("tasty birdmeat" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal

/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked/spiced
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = MEAT
	tastes = list("spicy birdmeat" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	rogue_faretype = ROGUE_FARE_LAVISH

/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	eat_effect = null
	cooked_type = null
	fried_type = null
	slice_path = null
	slices_num = 0
	rogue_faretype = ROGUE_FARE_FINE
	rogue_portable = FALSE

/obj/item/reagent_containers/food/snacks/rogue/meat/rabbit/fried/garlick
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	tastes = list("warm cabbit" = 1, "garlick" = 1)

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins/cooked/sauced
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = MEAT
	tastes = list("tender venison" = 1, "caramelized wine" = 1, "berry paste" = 1)

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins_z/cooked/cubed
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	tastes = list("gelatin" = 1, "squishy meat" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	rotprocess = 0
	become_rot_type = null
	rogue_faretype = ROGUE_FARE_NEUTRAL
	rogue_cooked_smell = "strangely delicious meat"

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime/cooked/choice
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = MEAT
	tastes = list("mellow venison" = 1, "garlyck" = 1, "onion" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime_z/cooked/roses
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = MEAT
	tastes = list("thin sticky meat" = 1, "garlyck" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	rotprocess = 0
	become_rot_type = null
	rogue_faretype = ROGUE_FARE_FINE
	rogue_cooked_smell = "strangely delicious meat"

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs/cooked/glazed
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = MEAT
	tastes = list("sweet venison" = 1, "honey" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs_z/cooked/crown
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	tastes = list("mashed meat" = 1, "jackberries" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal
	rotprocess = 0
	become_rot_type = null
	rogue_cooked_smell = "strangely delicious meat"

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z/cooked/meatloaf
	food_reagents = list(/datum/reagent/consumable/nutriment = 12)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	tastes = list("crumbly squishy meatloaf" = 1, "ghoul" = 1, "grout and grime" = 1)
	eat_effect = null
	bitesize = 7
	rotprocess = 0
	become_rot_type = null
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z/cooked/meatloaf_slice
	slices_num = 6
	slice_batch = FALSE
	rogue_cooked_smell = "strangely delicious meat"

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z/cooked/meatloaf_slice
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	tastes = list("crumbly squishy meatloaf" = 1, "ghoul" = 1, "grout and grime" = 1)
	eat_effect = null
	bitesize = 2
	rogue_cooked_smell = "strangely delicious meat"

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/bear/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = MEAT
	eat_effect = null
	cooked_type = null
	fried_type = null
	bitesize = 4
	slice_path = null
	slices_num = 0
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/beetle/cooked
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	cooked_type = null
	slice_path = null
	slices_num = 0

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/gnoll/seared
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 12)
	foodtypes = MEAT
	eat_effect = null
	cooked_type = null
	fried_type = null
	slice_path = null
	slices_num = 0
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/rat/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	eat_effect = null
	cooked_type = null
	fried_type = null
	slice_path = null
	slices_num = 0
	rogue_faretype = ROGUE_FARE_POOR

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/troll/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 3)
	foodtypes = MEAT
	cooked_type = /obj/item/reagent_containers/food/snacks/fat
	fried_type = /obj/item/reagent_containers/food/snacks/fat
	cooktime = 1500
	bitesize = 5

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf/fried
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	eat_effect = null
	cooked_type = null
	fried_type = null
	slice_path = null
	slices_num = 0
	rogue_faretype = ROGUE_FARE_NEUTRAL

/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/meat/fish
	food_reagents = list(/datum/reagent/consumable/nutriment = 30)
	foodtypes = GRAIN | DAIRY | MEAT
	tastes = list("baked fish and crispy butterdough" = 1)

/obj/item/reagent_containers/food/snacks/rogue/pie/cooked/meat/spider
	food_reagents = list(/datum/reagent/consumable/nutriment = 30)
	foodtypes = GRAIN | DAIRY | MEAT
	tastes = list("spider innards and crispy butterdough" = 1)

/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked/spiced/ducal
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 15)
	foodtypes = MEAT
	tastes = list("spicy birdmeat" = 1, "garlick" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/great_meal

/obj/item/reagent_containers/food/snacks/rogue/meat/rabbit/fried/garlick/cucumber
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6)
	foodtypes = MEAT
	tastes = list("warm cabbit" = 1, "garlick" = 1, "cucumber" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal

/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime/cooked/choice/butter
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 24)
	foodtypes = MEAT
	tastes = list("mellow venison" = 1, "garlyck" = 1, "onion" = 1, "butter" = 1)
	rotprocess = 0
	become_rot_type = null

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf/fried/garlick
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	tastes = list("gamey volf" = 1, "garlick" = 1)

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf/fried/garlick/cucumber
	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 9)
	foodtypes = MEAT
	tastes = list("gamey volf" = 1, "garlick" = 1, "cucumber" = 1)
	eat_effect = /datum/status_effect/rogue_food_buff/meal

/datum/rogue_food_recipe/bacon_egg
	name = "Bacon and Eggs"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/friedegg/fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/bacon

/datum/rogue_food_recipe/bacon_wiener_egg
	name = "Wiener Egg with Bacon (from Bacon)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/friedegg/sausage)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/sausagebacon

/datum/rogue_food_recipe/baked/cookie_dough_chocolate
	name = "Chocolate Cookie Dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/foodbase/halfcookie_raw
	ingredients = list(/obj/item/reagent_containers/food/snacks/chocolate/slice)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/foodbase/cookie_raw

/datum/rogue_food_recipe/baked/cookie_dough_raisin
	name = "Raisin Cookie Dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/foodbase/halfcookier_raw
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/raisins)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/foodbase/cookier_raw

/datum/rogue_food_recipe/baked/half_cookie_chocolate
	name = "Chocolate Cookie Dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/foodbase/hardtack_raw
	ingredients = list(/obj/item/reagent_containers/food/snacks/chocolate/slice)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/foodbase/halfcookie_raw

/datum/rogue_food_recipe/baked/half_cookie_raisin
	name = "Raisin Cookie Dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/foodbase/hardtack_raw
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/raisins)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/foodbase/halfcookier_raw

/datum/rogue_food_recipe/butter_bird
	name = "Butter Bird-Roast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked
	ingredients = list(/obj/item/reagent_containers/food/snacks/butter)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked/butter

/datum/rogue_food_recipe/cake/apple_cake
	name = "Apple Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/apple)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/applecake
	time_per_step = 50

/datum/rogue_food_recipe/cake/applenut_cake
	name = "Applenut Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/applecake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/nut)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/applenutcake
	time_per_step = 30

/datum/rogue_food_recipe/cake/applenut_cake_alt
	name = "Applenut Cake (from Rocknut)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/rocknutcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/apple)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/applenutcake
	time_per_step = 30

/datum/rogue_food_recipe/cake/berry_cake
	name = "Berry Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/berrycake
	time_per_step = 50

/datum/rogue_food_recipe/cake/berry_cake_poison
	name = "Poison Berry Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/berrycake/poison
	time_per_step = 50

/datum/rogue_food_recipe/cake/blackberry_cake
	name = "Blackberry Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/blackberrycake
	time_per_step = 50

/datum/rogue_food_recipe/cake/carrot_cake
	name = "Carrot Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/preserved/carrot_baked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/carrotcake
	time_per_step = 50

/datum/rogue_food_recipe/cake/carrot_cake_alt
	name = "Carrot Cake (Raw Carrot)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/carrot)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/carrotcake
	time_per_step = 50

/datum/rogue_food_recipe/cake/cheesecake_base
	name = "Cheesecake Base"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/cake_base
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/cheese)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/ccakeuncooked
	time_per_step = 50

/datum/rogue_food_recipe/cake/frosted_cake_base
	name = "Frosted Cake Base"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/cake_base
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/frosting)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/frostedcakeuncooked
	time_per_step = 30

/datum/rogue_food_recipe/cake/frosted_cake_postbake
	name = "Frosted Cake (Post-Bake)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/cake
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/frosting)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	time_per_step = 50

/datum/rogue_food_recipe/cake/honeycake_base
	name = "Honey Cake Base"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/cake_base
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/honey)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/hcakeuncooked
	time_per_step = 50

/datum/rogue_food_recipe/cake/lemon_cake
	name = "Lemon Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/fruit/lemon)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/lemoncake
	time_per_step = 50

/datum/rogue_food_recipe/cake/lime_cake
	name = "Lime Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/fruit/lime)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/limecake
	time_per_step = 50

/datum/rogue_food_recipe/cake/mentha_cake
	name = "Mentha Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/alch/mentha)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/menthacake
	time_per_step = 50

/datum/rogue_food_recipe/cake/peace_cake
	name = "Peace Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/clothing/head/peaceflower)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/peacecake
	time_per_step = 50

/datum/rogue_food_recipe/cake/raspberry_cake
	name = "Raspberry Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/fruit/raspberry)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/raspberrycake
	time_per_step = 50

/datum/rogue_food_recipe/cake/rocknut_cake
	name = "Rocknut Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/nut)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/rocknutcake
	time_per_step = 50

/datum/rogue_food_recipe/cake/strawberry_cake
	name = "Strawberry Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/fruit/strawberry)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/strawberrycake
	time_per_step = 50

/datum/rogue_food_recipe/cake/tangerine_cake
	name = "Tangerine Cake"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/frostedcake
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/fruit/tangerine)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/tangerinecake
	time_per_step = 50

/datum/rogue_food_recipe/carrot_steak
	name = "Carrot Steak"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/carrot_baked
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/carrotsteak

/datum/rogue_food_recipe/carrot_steak_meat
	name = "Carrot Steak"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/preserved/carrot_baked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/carrotsteak

/datum/rogue_food_recipe/deadite_loaf
	name = "meatloaf"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z, /obj/item/alch/viscera, /obj/item/alch/viscera, /obj/item/reagent_containers/food/snacks/rogue/meat)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_z/cooked/meatloaf
	needs_cooking = TRUE
	time_per_step = 10

/datum/rogue_food_recipe/deadite_loins_cubed
	name = "gelatinous meat cube"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins_z
	ingredients = list(/obj/item/natural/bone, /obj/item/alch/viscera)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins_z/cooked/cubed
	needs_cooking = TRUE
	time_per_step = 10

/datum/rogue_food_recipe/deadite_ribs_crown
	name = "berry rib crown"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs_z
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs_z/cooked/crown
	needs_cooking = TRUE
	time_per_step = 10

/datum/rogue_food_recipe/deadite_rose
	name = "meat roses"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime_z
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/veg/garlick_clove, /obj/item/reagent_containers/food/snacks/rogue/veg/garlick_clove, /obj/item/reagent_containers/food/snacks/rogue/veg/garlick_clove)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime_z/cooked/roses
	needs_cooking = TRUE
	time_per_step = 10

/datum/rogue_food_recipe/double_bird
	name = "Double Stacked Bird-Roast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked/doublestacked

/datum/rogue_food_recipe/ducal_birdroast
	name = "Ducal Bird-Roast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked/spiced
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/garlick/rogue)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked/spiced/ducal
	time_per_step = 30

/datum/rogue_food_recipe/eggplant_cheese
	name = "Stuffed Eggplant with Cheese"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/eggplantstuffed
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/eggplantstuffedcheese

/datum/rogue_food_recipe/eggplant_meat
	name = "Stuffed Eggplant with Meat"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/eggplantcarved
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/mince/beef)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/eggplantmeat

/datum/rogue_food_recipe/eggplant_tomato
	name = "Stuffed Eggplant with Tomato"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/eggplantmeat
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/fruit/tomato)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/eggplantstuffedraw

/datum/rogue_food_recipe/eggs/bacon_and_eggs
	name = "Bacon and Eggs"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/two
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/bacon
	time_per_step = 50

/datum/rogue_food_recipe/eggs/hammerholdian_breakfast
	name = "Hammerholdian Breakfast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/sausagebacon
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/breadslice/toast)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/hammerhold
	time_per_step = 50

/datum/rogue_food_recipe/eggs/twin_fried_eggs
	name = "Twin Fried Eggs"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/friedegg/fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/two
	time_per_step = 30

/datum/rogue_food_recipe/eggs/valerian_omelette
	name = "Valerian Omelette"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/two
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/tiberian
	time_per_step = 50

/datum/rogue_food_recipe/eggs/wiener_egg
	name = "Wiener Egg"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/sausage
	time_per_step = 30

/datum/rogue_food_recipe/eggs/wiener_egg_bacon
	name = "Wiener Egg with Bacon"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/bacon
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/sausagebacon
	time_per_step = 50

/datum/rogue_food_recipe/eggs/wiener_egg_bacon_alt
	name = "Wiener Egg with Bacon (Alt)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/sausage
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/sausagebacon
	time_per_step = 50

/datum/rogue_food_recipe/elven_cabbit_roast
	name = "Elven Cabbit Roast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/rabbit/fried/garlick
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/veg/cucumber_sliced)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/rabbit/fried/garlick/cucumber
	time_per_step = 30

/datum/rogue_food_recipe/frybird_tato
	name = "Frybird Tato"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/potato_baked
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet/fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/frybirdtato

/datum/rogue_food_recipe/frybird_tato_alt
	name = "Frybird Tato (Alt)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/potato_fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet/fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/frybirdtato

/datum/rogue_food_recipe/frybird_tato_meat
	name = "Frybird Tato"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet/fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/preserved/potato_baked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/frybirdtato

/datum/rogue_food_recipe/frybird_tato_meat_alt
	name = "Frybird Tato (Alt)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet/fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/preserved/potato_fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/frybirdtato

/datum/rogue_food_recipe/garlick_cabbit
	name = "Garlick Cabbit"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/rabbit/fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/veg/garlick_clove)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/rabbit/fried/garlick

/datum/rogue_food_recipe/garlick_volf
	name = "Garlick Volf"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf/fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/veg/garlick_clove)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf/fried/garlick

/datum/rogue_food_recipe/hunters_feast
	name = "Hunter's Feast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf/fried/garlick
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/veg/cucumber_sliced)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf/fried/garlick/cucumber
	time_per_step = 30

/datum/rogue_food_recipe/onion_steak
	name = "Onion Steak"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/preserved/onion_fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/onionsteak

/datum/rogue_food_recipe/pepper_fish
	name = "Pepper Fish"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/fish/fried
	ingredients = list(/datum/reagent/consumable/blackpepper = 1)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/pepperfish

/datum/rogue_food_recipe/pepper_steak
	name = "Pepper Steak"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried
	ingredients = list(/datum/reagent/consumable/blackpepper = 1)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/peppersteak

/datum/rogue_food_recipe/peppersteak_ducal
	name = "Ducal Peppersteak"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/peppersteak
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/garlick/rogue)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/peppersteak/ducal
	time_per_step = 30

/datum/rogue_food_recipe/rice/beef
	name = "Rice and Beef"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/rice_cooked
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/ricebeef

/datum/rogue_food_recipe/rice/beef_carrot
	name = "Rice and Beef Meal"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/ricebeef
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/preserved/carrot_baked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/ricebeefcar

/datum/rogue_food_recipe/rice/bird
	name = "Rice and Bird"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/rice_cooked
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet/fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/ricebird

/datum/rogue_food_recipe/rice/bird_carrot
	name = "Rice and Bird Meal"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/ricebird
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/preserved/carrot_baked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/ricebirdcar

/datum/rogue_food_recipe/rice/cheese
	name = "Rice and Cheese"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/rice_cooked
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/cheddarslice)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/ricecheese

/datum/rogue_food_recipe/rice/cheese_egg
	name = "Rice with Egg and Cheese (Alt)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/ricecheese
	ingredients = list(/obj/item/reagent_containers/food/snacks/egg)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/riceeggcheese

/datum/rogue_food_recipe/rice/egg
	name = "Rice and Egg"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/rice_cooked
	ingredients = list(/obj/item/reagent_containers/food/snacks/egg)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/riceegg

/datum/rogue_food_recipe/rice/egg_cheese
	name = "Rice with Egg and Cheese"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/riceegg
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/cheddarslice)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/riceeggcheese

/datum/rogue_food_recipe/rice/pork
	name = "Rice and Pork"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/rice_cooked
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/fatty/roast)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/ricepork

/datum/rogue_food_recipe/rice/pork_cucumber
	name = "Rice and Pork Meal"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/ricepork
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/veg/cucumber_sliced)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/riceporkcuc

/datum/rogue_food_recipe/rice/shrimp
	name = "Rice and Shrimp"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/rice_cooked
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/fryfish/shrimp)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/riceshrimp

/datum/rogue_food_recipe/rice/shrimp_carrot
	name = "Rice and Shrimp Meal"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/riceshrimp
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/preserved/carrot_baked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/riceshrimpcar

/datum/rogue_food_recipe/rice_beef_carrot_baked
	name = "Rice Beef with Carrot"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/carrot_baked
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/ricebeef)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/ricebeefcar

/datum/rogue_food_recipe/sandwich/bacon
	name = "Bacon Bread"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/sandwich/bacon

/datum/rogue_food_recipe/sandwich/buttered_toast
	name = "Buttered Toast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	ingredients = list(/obj/item/reagent_containers/food/snacks/butterslice)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast/buttered

/datum/rogue_food_recipe/sandwich/cheese
	name = "Cheese Bread"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/cheddarslice)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/sandwich/cheese

/datum/rogue_food_recipe/sandwich/egg_toast
	name = "Egg Toast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/friedegg/fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/sandwich/egg

/datum/rogue_food_recipe/sandwich/grenzelbun
	name = "Grenzelbun"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/bun
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/bun_grenz

/datum/rogue_food_recipe/sandwich/ham
	name = "Ham Bread"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/ham/sliced)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/sandwich/ham

/datum/rogue_food_recipe/sandwich/raston
	name = "Raston"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/bun
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/bun_raston

/datum/rogue_food_recipe/sandwich/salami
	name = "Salumoi Bread"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/salami/slice)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/sandwich/salami

/datum/rogue_food_recipe/sandwich/salo
	name = "Salo Bread"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice
	ingredients = list(/obj/item/reagent_containers/food/snacks/fat/salo/slice)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/sandwich/salo

/datum/rogue_food_recipe/seafood/ale_cod
	name = "Ale Cod"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/fryfish/cod
	ingredients = list(/datum/reagent/consumable/ethanol/beer = 1)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/alecod

/datum/rogue_food_recipe/seafood/berry_salmon
	name = "Berry Salmon"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/fryfish/salmon
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/berrysalmon

/datum/rogue_food_recipe/seafood/buttered_lobster
	name = "Buttered Lobster"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/fryfish/lobster
	ingredients = list(/obj/item/reagent_containers/food/snacks/butterslice)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/fryfish/lobster/meal

/datum/rogue_food_recipe/seafood/buttered_sole
	name = "Buttered Sole"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/fryfish/sole
	ingredients = list(/obj/item/reagent_containers/food/snacks/butterslice)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/buttersole

/datum/rogue_food_recipe/seafood/mentha_salmon
	name = "Mentha Salmon"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/fryfish/salmon
	ingredients = list(/obj/item/alch/mentha)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/dendorsalmon

/datum/rogue_food_recipe/seafood/onion_plaice
	name = "Onion Plaice"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/fryfish/plaice
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/veg/onion_sliced)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/onionplaice

/datum/rogue_food_recipe/seafood/pepper_lobster
	name = "Pepper Lobster"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/fryfish/lobster
	ingredients = list(/datum/reagent/consumable/blackpepper = 1)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/pepperlobsta

/datum/rogue_food_recipe/spiced_bird
	name = "Spiced Bird-Roast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked
	ingredients = list(/datum/reagent/consumable/blackpepper = 1)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked/spiced

/datum/rogue_food_recipe/steakmeal_carrot
	name = "Steak Meal (Carrot)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/onionsteak
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/preserved/carrot_baked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/steakcarrotonion
	time_per_step = 30

/datum/rogue_food_recipe/steakmeal_onion
	name = "Steak Meal (Onion)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/carrotsteak
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/preserved/onion_fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/steakcarrotonion
	time_per_step = 30

/datum/rogue_food_recipe/venison_loins_sauced
	name = "wine glazed venison loins"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins
	ingredients = list(/datum/reagent/consumable/ethanol/redwine = 5, /obj/item/reagent_containers/food/snacks/grown/berries/rogue)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_loins/cooked/sauced
	needs_cooking = TRUE

/datum/rogue_food_recipe/venison_prime_choice
	name = "Choice cut steak"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/veg/onion_sliced, /obj/item/reagent_containers/food/snacks/rogue/veg/garlick_clove)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime/cooked/choice
	needs_cooking = TRUE
	time_per_step = 10

/datum/rogue_food_recipe/venison_prime_choice_butter
	name = "Choice cut steak (with butter)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime/cooked/choice
	ingredients = list(/obj/item/reagent_containers/food/snacks/butterslice)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_prime/cooked/choice/butter
	time_per_step = 10

/datum/rogue_food_recipe/venison_ribs_glazed
	name = "glazed venison ribs"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/honey)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/meat/saiga_ribs/cooked/glazed
	needs_cooking = TRUE
	time_per_step = 10

/datum/rogue_food_recipe/wiener_cabbage
	name = "Wiener Cabbage"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/cabbage_fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/wienercabbage

/datum/rogue_food_recipe/wiener_egg_sausage
	name = "Wiener Egg (from Sausage)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/friedegg/fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/sausage

/datum/rogue_food_recipe/wiener_meal_onion
	name = "Wiener Meal (Onion)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/wienerpotato
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/preserved/onion_fried)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/wienerpotatonions
	time_per_step = 30

/datum/rogue_food_recipe/wiener_meal_potato
	name = "Wiener Meal (Potato)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/wieneronions
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/preserved/potato_baked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/wienerpotatonions
	time_per_step = 30

/datum/rogue_food_recipe/wiener_onions
	name = "Wiener Onions"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/onion_fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/wieneronions

/datum/rogue_food_recipe/wiener_potato
	name = "Wiener Potato"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/potato_baked
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/wienerpotato

/datum/rogue_food_recipe/wiener_potato_alt
	name = "Wiener Potato (Alt)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/preserved/potato_fried
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/wienerpotato
