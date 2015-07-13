

// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

//Grown foods
//Subclass so we can pass on values
/obj/item/weapon/reagent_containers/food/snacks/grown/
	var/seed = null
	var/plantname = ""
	var/product	//a type path
	var/lifespan = 0
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0
	var/plant_type = 0
	icon = 'icons/obj/hydroponics/harvest.dmi'
	potency = -1
	dried_type = -1 //bit different. saves us from having to define each stupid grown's dried_type as itself. If you don't want a plant to be driable (watermelons) set this to null in the time definition.
	burn_state = 0 //Burnable

/obj/item/weapon/reagent_containers/food/snacks/grown/New(newloc, new_potency = 50)
	..()
	potency = new_potency
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	if(dried_type == -1)
		dried_type = src.type

	if(seed && lifespan == 0) //This is for adminspawn or map-placed growns. They get the default stats of their seed type. This feels like a hack but people insist on putting these things on the map...
		var/obj/item/seeds/S = new seed(src)
		lifespan = S.lifespan
		endurance = S.endurance
		maturation = S.maturation
		production = S.production
		yield = S.yield
		qdel(S) //Foods drop their contents when eaten, so delete the default seed.

	add_juice()
	transform *= TransformUsingVariable(potency, 100, 0.5) //Makes the resulting produce's sprite larger or smaller based on potency!


/obj/item/weapon/reagent_containers/food/snacks/grown/proc/add_juice()
	if(reagents)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		var/msg
		msg = "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>\n"
		switch(plant_type)
			if(0)
				msg += "- Plant type: <i>Normal plant</i>\n"
			if(1)
				msg += "- Plant type: <i>Weed</i>.  Can grow in nutrient-poor soil.\n"
			if(2)
				msg += "- Plant type: <i>Mushroom</i>.  Can grow in dry soil.\n"
		msg += "- Potency: <i>[potency]</i>\n"
		msg += "- Yield: <i>[yield]</i>\n"
		msg += "- Maturation speed: <i>[maturation]</i>\n"
		msg += "- Production speed: <i>[production]</i>\n"
		msg += "- Endurance: <i>[endurance]</i>\n"
		msg += "- Nutritional value: <i>[reagents.get_reagent_amount("nutriment")]</i>\n"
		msg += "- Other substances: <i>[reagents.total_volume-reagents.get_reagent_amount("nutriment")]</i>\n"
		msg += "*---------*</span>"
		usr << msg
		return
	return

/obj/item/weapon/grown/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		var/msg
		msg = "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>\n"
		switch(plant_type)
			if(0)
				msg += "- Plant type: <i>Normal plant</i>\n"
			if(1)
				msg += "- Plant type: <i>Weed</i>.  Can grow in nutrient-poor soil.\n"
			if(2)
				msg += "- Plant type: <i>Mushroom</i>.  Can grow in dry soil.\n"
		msg += "- Potency: <i>[potency]</i>\n"
		msg += "- Yield: <i>[yield]</i>\n"
		msg += "- Maturation speed: <i>[maturation]</i>\n"
		msg += "- Production speed: <i>[production]</i>\n"
		msg += "- Endurance: <i>[endurance]</i>\n"
		msg += "*---------*</span>"
		usr << msg
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/corn
	seed = /obj/item/seeds/cornseed
	name = "ear of corn"
	desc = "Needs some butter!"
	icon_state = "corn"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/popcorn
	filling_color = "#FFFF00"
	trash = /obj/item/weapon/grown/corncob

/obj/item/weapon/reagent_containers/food/snacks/grown/corn/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/cherries
	seed = /obj/item/seeds/cherryseed
	name = "cherries"
	desc = "Great for toppings!"
	icon_state = "cherry"
	gender = PLURAL
	filling_color = "#FF0000"

/obj/item/weapon/reagent_containers/food/snacks/grown/cherries/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 15), 1))
		reagents.add_reagent("sugar", 1 + round((potency / 15), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries
	seed = /obj/item/seeds/bluecherryseed
	name = "blue cherries"
	desc = "They're cherries that are blue."
	icon_state = "bluecherry"
	filling_color = "#6495ED"

/obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 15), 1))
		reagents.add_reagent("sugar", 1 + round((potency / 50), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/poppy
	seed = /obj/item/seeds/poppyseed
	name = "poppy"
	desc = "Long-used as a symbol of rest, peace, and death."
	icon_state = "poppy"
	slot_flags = SLOT_HEAD
	filling_color = "#FF6347"

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 20), 1))
		reagents.add_reagent("salglu_solution", 1 + round((potency / 20), 1))
		bitesize = 1 + round(reagents.total_volume / 3, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy/lily
	seed = /obj/item/seeds/lilyseed
	name = "lily"
	desc = "A beautiful orange flower"
	icon_state = "lily"
	filling_color = "#FFA500"

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy/geranium
	seed = /obj/item/seeds/geraniumseed
	name = "geranium"
	desc = "A beautiful blue flower"
	icon_state = "geranium"
	filling_color = "#008B8B"

/obj/item/weapon/reagent_containers/food/snacks/grown/harebell
	seed = /obj/item/seeds/harebell
	name = "harebell"
	desc = "\"I'll sweeten thy sad grave: thou shalt not lack the flower that's like thy face, pale primrose, nor the azured hare-bell, like thy veins; no, nor the leaf of eglantine, whom not to slander, out-sweeten'd not thy breath.\""
	icon_state = "harebell"
	slot_flags = SLOT_HEAD
	filling_color = "#E6E6FA"

/obj/item/weapon/reagent_containers/food/snacks/grown/harebell/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 20), 1))
		bitesize = 1 + round(reagents.total_volume / 3, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/potato
	seed = /obj/item/seeds/potatoseed
	name = "potato"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "potato"
	filling_color = "#E9967A"

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = reagents.total_volume

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if (C.use(5))
			user << "<span class='notice'>You add some cable to the potato and slide it inside the battery encasing.</span>"
			var/obj/item/weapon/stock_parts/cell/potato/pocell = new /obj/item/weapon/stock_parts/cell/potato(user.loc)
			pocell.maxcharge = src.potency * 10
			pocell.charge = pocell.maxcharge
			qdel(src)
			return
		else
			user << "<span class='warning'>You need five lengths of cable to make a potato battery!</span>"
			return


/obj/item/weapon/reagent_containers/food/snacks/grown/grapes
	seed = /obj/item/seeds/grapeseed
	name = "bunch of grapes"
	desc = "Nutritious!"
	icon_state = "grapes"
	dried_type = /obj/item/weapon/reagent_containers/food/snacks/no_raisin
	filling_color = "#FF1493"

/obj/item/weapon/reagent_containers/food/snacks/grown/grapes/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
		reagents.add_reagent("sugar", 1 + round((potency / 10), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/grapes/green
	seed = /obj/item/seeds/greengrapeseed
	name = "bunch of green grapes"
	desc = "Nutritious!"
	icon_state = "greengrapes"
	dried_type = /obj/item/weapon/reagent_containers/food/snacks/no_raisin
	filling_color = "#7FFF00"

/obj/item/weapon/reagent_containers/food/snacks/grown/grapes/green/add_juice()
	..()
	reagents.add_reagent("salglu_solution", 3 + round((potency / 5), 1))


/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	seed = /obj/item/seeds/cabbageseed
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	icon_state = "cabbage"
	filling_color = "#90EE90"

/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/berries
	seed = /obj/item/seeds/berryseed
	name = "bunch of berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	gender = PLURAL
	filling_color = "#FF00FF"

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/poison
	seed = /obj/item/seeds/poisonberryseed
	name = "bunch of poison-berries"
	desc = "Taste so good, you could die!"
	icon_state = "poisonberrypile"
	filling_color = "#C71585"

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/poison/add_juice()
	..()
	reagents.add_reagent("toxin", 3 + round(potency / 5, 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/death
	seed = /obj/item/seeds/deathberryseed
	name = "bunch of death-berries"
	desc = "Taste so good, you could die!"
	icon_state = "deathberrypile"
	filling_color = "#708090"

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/death/add_juice()
	..()
	reagents.add_reagent("toxin", 3 + round(potency / 3, 1))
	reagents.add_reagent("lexorin", 1 + round(potency / 5, 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/glow
	seed = /obj/item/seeds/glowberryseed
	name = "bunch of glow-berries"
	desc = "Nutritious!"
	var/on = 1
	var/brightness_on = 2 //luminosity when on
	icon_state = "glowberrypile"
	filling_color = "#7CFC00"

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/glow/add_juice()
	..()
	reagents.add_reagent("uranium", 3 + round(potency / 5, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/glow/Destroy()
	if(istype(loc,/mob))
		loc.AddLuminosity(round(-potency / 5,1))
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/glow/pickup(mob/user)
	src.SetLuminosity(0)
	user.AddLuminosity(round(potency / 5,1))

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/glow/dropped(mob/user)
	user.AddLuminosity(round(-potency / 5,1))
	src.SetLuminosity(round(potency / 5,1))


/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod
	seed = /obj/item/seeds/cocoapodseed
	name = "cocoa pod"
	desc = "Fattening... Mmmmm... chucklate."
	icon_state = "cocoapod"
	filling_color = "#FFD700"

/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
		reagents.add_reagent("cocoa", 4 + round((potency / 5), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/vanillapod
	seed = /obj/item/seeds/vanillapodseed
	name = "vanilla pod"
	desc = "Fattening... Mmmmm... vanilla."
	icon_state = "vanillapod"
	filling_color = "#FFD700"

/obj/item/weapon/reagent_containers/food/snacks/grown/vanillapod/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
		reagents.add_reagent("vanilla", 4 + round((potency / 5), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane
	seed = /obj/item/seeds/sugarcaneseed
	name = "sugarcane"
	desc = "Sickly sweet."
	icon_state = "sugarcane"
	filling_color = "#FFD700"

/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane/add_juice()
	if(..())
		reagents.add_reagent("sugar", 4 + round((potency / 5), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia //abstract type
	name = "ambrosia branch"
	desc = "This is a plant."
	icon_state = "ambrosiavulgaris"
	slot_flags = SLOT_HEAD
	filling_color = "#008000"

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1)
		bitesize = 1 + round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	seed = /obj/item/seeds/ambrosiavulgarisseed
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris/add_juice()
	..()
	reagents.add_reagent("space_drugs", 1 + round(potency / 8, 1))
	reagents.add_reagent("salglu_solution", 1 + round(potency / 8, 1))
	reagents.add_reagent("salglu_solution", 1 + round(potency / 10, 1))
	reagents.add_reagent("toxin", 1 + round(potency / 10, 1))
	reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))


/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus
	seed = /obj/item/seeds/ambrosiadeusseed
	name = "ambrosia deus branch"
	desc = "Eating this makes you feel immortal!"
	icon_state = "ambrosiadeus"
	filling_color = "#008B8B"

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus/add_juice()
	..()
	reagents.add_reagent("omnizine", 1 + round(potency / 8, 1))
	reagents.add_reagent("synaptizine", 1 + round(potency / 8, 1))
	reagents.add_reagent("space_drugs", 1 + round(potency / 10, 1))
	reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))


/obj/item/weapon/reagent_containers/food/snacks/grown/apple
	seed = /obj/item/seeds/appleseed
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	filling_color = "#FF4500"

/obj/item/weapon/reagent_containers/food/snacks/grown/apple/add_juice()
	if(..())
		reagents.maximum_volume = 20
		reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = reagents.maximum_volume // Always eat the apple in one


/obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned
	seed = /obj/item/seeds/poisonedappleseed
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"

/obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned/add_juice()
	..()
	reagents.add_reagent("cyanide", 1 + round((potency / 5), 1))


/obj/item/weapon/reagent_containers/food/snacks/grown/apple/gold
	seed = /obj/item/seeds/goldappleseed
	name = "golden apple"
	desc = "Emblazoned upon the apple is the word 'Kallisti'."
	icon_state = "goldapple"
	filling_color = "#FFD700"

/obj/item/weapon/reagent_containers/food/snacks/grown/apple/gold/add_juice()
	..()
	reagents.add_reagent("gold", 1 + round((potency / 5), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/apple/gold/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Mineral Content: <i>[reagents.get_reagent_amount("gold")]%</i></span>"


/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon
	seed = /obj/item/seeds/watermelonseed
	name = "watermelon"
	desc = "It's full of watery goodness."
	icon_state = "watermelon"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	slices_num = 5
	dried_type = null
	w_class = 3
	filling_color = "#008000"

/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 6), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/holymelon
	seed = /obj/item/seeds/holymelonseed
	name = "holymelon"
	desc = "The water within this melon has been blessed by some deity that's particularly fond of watermelon."
	icon_state = "holymelon"
	filling_color = "#FFD700"
	dried_type = null

/obj/item/weapon/reagent_containers/food/snacks/grown/holymelon/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 15), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		reagents.add_reagent("holywater", 1 + round((potency / 6), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
	seed = /obj/item/seeds/pumpkinseed
	name = "pumpkin"
	desc = "It's large and scary."
	icon_state = "pumpkin"
	filling_color = "#FFA500"

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 6), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if(is_sharp(W))
		user.show_message("<span class='notice'>You carve a face into [src]!</span>", 1)
		new /obj/item/clothing/head/hardhat/pumpkinhead (user.loc)
		qdel(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/blumpkin
	seed = /obj/item/seeds/blumpkinseed
	name = "blumpkin"
	desc = "The pumpkin's toxic sibling."
	icon_state = "blumpkin"
	filling_color = "#87CEFA"

/obj/item/weapon/reagent_containers/food/snacks/grown/blumpkin/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 6), 1))
		reagents.add_reagent("ammonia", 1 + round((potency / 6), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/ //abstract type
	seed = /obj/item/seeds/limeseed
	name = "citrus"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"

/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 20), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime
	seed = /obj/item/seeds/limeseed
	name = "lime"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	filling_color = "#00FF00"

/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon
	seed = /obj/item/seeds/lemonseed
	name = "lemon"
	desc = "When life gives you lemons, be grateful they aren't limes."
	icon_state = "lemon"
	filling_color = "#FFD700"

/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange
	seed = /obj/item/seeds/orangeseed
	name = "orange"
	desc = "It's an tangy fruit."
	icon_state = "orange"
	filling_color = "#FFA500"


/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
	seed = /obj/item/seeds/whitebeetseed
	name = "white-beet"
	desc = "You can't beat white-beet."
	icon_state = "whitebeet"
	filling_color = "#F4A460"

/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet/add_juice()
	if(..())
		reagents.add_reagent("nutriment", round((potency / 20), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		reagents.add_reagent("sugar", 1 + round((potency / 5), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/sweetpotato
	seed = /obj/item/seeds/sweetpotatoseed
	name = "sweet potato"
	desc = "It's sweet."
	icon_state = "sweetpotato"

/obj/item/weapon/reagent_containers/food/snacks/grown/sweetpotato/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 10), 1))
		reagents.add_reagent("sugar", 1 + round((potency / 10), 1))
		bitesize = reagents.total_volume

/obj/item/weapon/reagent_containers/food/snacks/grown/parsnip
	seed = /obj/item/seeds/parsnipseed
	name = "parsnip"
	desc = "Closely related to carrots."
	icon_state = "parsnip"

/obj/item/weapon/reagent_containers/food/snacks/grown/parsnip/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 20), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 20), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/redbeet
	seed = /obj/item/seeds/redbeetseed
	name = "red beet"
	desc = "You can't beat red beet."
	icon_state = "redbeet"

/obj/item/weapon/reagent_containers/food/snacks/grown/redbeet/add_juice()
	if(..())
		reagents.add_reagent("nutriment", round((potency / 20), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 20), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/banana
	seed = /obj/item/seeds/bananaseed
	name = "banana"
	desc = "It's an excellent prop for a clown."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana"
	item_state = "banana"
	trash = /obj/item/weapon/grown/bananapeel
	filling_color = "#FFFF00"

/obj/item/weapon/reagent_containers/food/snacks/grown/banana/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 50), 1))
		reagents.add_reagent("banana", 1 + round((potency / 10), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/banana/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is aiming the [src.name] at themself! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/items/bikehorn.ogg', 50, 1, -1)
	sleep(25)
	user.say("BANG!")
	sleep(25)
	user.visible_message("<B>[user]</B> laughs so hard they begin to suffocate!")
	return (OXYLOSS)

/obj/item/weapon/reagent_containers/food/snacks/grown/mimana
	seed = /obj/item/seeds/mimanaseed
	name = "mimana"
	desc = "It's an excellent prop for a mime."
	icon_state = "mimana"
	trash = /obj/item/weapon/grown/bananapeel/mimanapeel
	filling_color = "#FFFFEE"

/obj/item/weapon/reagent_containers/food/snacks/grown/mimana/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 50), 1))
		reagents.add_reagent("nothing", 2 + round((potency / 10), 1))
		reagents.add_reagent("mutetoxin", 2 + round((potency / 10), 1))
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/chili
	seed = /obj/item/seeds/chiliseed
	name = "chili"
	desc = "It's spicy! Wait... IT'S BURNING ME!!"
	icon_state = "chilipepper"
	filling_color = "#FF0000"

/obj/item/weapon/reagent_containers/food/snacks/grown/chili/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 25), 1))
		reagents.add_reagent("capsaicin", 3+round(potency / 5, 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/chili/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Capsaicin: <i>[reagents.get_reagent_amount("capsaicin")]%</i></span>"


/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
	seed = /obj/item/seeds/icepepperseed
	name = "ice pepper"
	desc = "It's a mutant strain of chili"
	icon_state = "icepepper"
	filling_color = "#0000CD"

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper/add_juice()
	..()
	reagents.add_reagent("nutriment", 1 + round((potency / 50), 1))
	reagents.add_reagent("vitamin", 1 + round((potency / 50), 1))
	reagents.add_reagent("frostoil", 3+round(potency / 5, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Frost Oil: <i>[reagents.get_reagent_amount("frostoil")]%</i></span>"


/obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chili
	seed = /obj/item/seeds/chilighost
	name = "ghost chili"
	desc = "It seems to be vibrating gently."
	icon_state = "ghostchilipepper"
	var/mob/held_mob
	filling_color = "#F8F8FF"

/obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chili/add_juice()
	..()
	reagents.add_reagent("nutriment", 1 + round((potency / 25), 1))
	reagents.add_reagent("capsaicin", 8+round(potency / 2, 1))
	reagents.add_reagent("condensedcapsaicin", 4+round(potency / 4, 1))
	bitesize = 1 + round(reagents.total_volume / 4, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chili/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Capsaicin: <i>[reagents.get_reagent_amount("capsaicin")]%</i></span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chili/attack_hand(mob/user as mob)
	..()
	if( istype(src.loc, /mob) )
		held_mob = src.loc
		SSobj.processing |= src

/obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chili/process()
	if(held_mob && src.loc == held_mob)
		if( (held_mob.l_hand == src) || (held_mob.r_hand == src))
			if(hasvar(held_mob,"gloves") && held_mob:gloves)
				return
			held_mob.bodytemperature += 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(10))
				held_mob << "<span class='warning'>Your hand holding [src] burns!</span>"
	else
		held_mob = null
		..()

/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	seed = /obj/item/seeds/eggplantseed
	name = "eggplant"
	desc = "Maybe there's a chicken inside?"
	icon_state = "eggplant"
	filling_color = "#800080"

/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/shell/
	var/inside_type = null

/obj/item/weapon/reagent_containers/food/snacks/grown/shell/attack_self(mob/user as mob)
	if(inside_type)
		new inside_type(user.loc)
	user.unEquip(src)
	qdel(src)

obj/item/weapon/reagent_containers/food/snacks/grown/shell/eggy
	seed = /obj/item/seeds/eggyseed
	name = "Egg-plant"
	desc = "There MUST be a chicken inside."
	icon_state = "eggyplant"
	inside_type = /obj/item/weapon/reagent_containers/food/snacks/egg
	filling_color = "#F8F8FF"

obj/item/weapon/reagent_containers/food/snacks/grown/shell/eggy/add_juice()
	..()
	reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	seed = /obj/item/seeds/soyaseed
	name = "soybeans"
	desc = "It's pretty bland, but oh the possibilities..."
	gender = PLURAL
	icon_state = "soybeans"
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 20), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans
	seed = /obj/item/seeds/koiseed
	name = "koibean"
	desc = "Something about these seems fishy."
	icon_state = "koibeans"
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 30), 1))
		reagents.add_reagent("carpotoxin", 1 + round((potency / 20), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower
	seed = /obj/item/seeds/moonflowerseed
	name = "moonflower"
	desc = "Store in a location at least 50 yards away from werewolves."
	icon_state = "moonflower"
	slot_flags = SLOT_HEAD
	filling_color = "#E6E6FA"

/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 50), 1))
		reagents.add_reagent("moonshine", 1 + round((potency / 10), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 50), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

//tomaters
/obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	seed = /obj/item/seeds/tomatoseed
	name = "tomato"
	desc = "I say to-mah-to, you say tom-mae-to."
	icon_state = "tomato"
	var/splat = /obj/effect/decal/cleanable/tomato_smudge
	filling_color = "#FF6347"

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/proc/squish(atom/target)
	var/turf/T = get_turf(target)
	new splat(T)
	visible_message("The [src.name] has been squashed.","<span class='italics'>You hear a smack.</span>")
	for(var/atom/A in get_turf(target))
		reagents.reaction(A)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/throw_impact(atom/hit_atom)
	if(!..()) //was it caught by a mob?
		squish(hit_atom)
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/killer
	seed = /obj/item/seeds/killertomatoseed
	name = "killer-tomato"
	desc = "I say to-mah-to, you say tom-mae-to... OH GOD IT'S EATING MY LEGS!!"
	icon_state = "killertomato"
	var/awakening = 0
	filling_color = "#FF0000"

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/killer/attack(mob/M, mob/user, def_zone)
	if(awakening)
		user << "<span class='warning'>The tomato is twitching and shaking, preventing you from eating it.</span>"
		return
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/killer/attack_self(mob/user as mob)
	if(awakening || istype(user.loc,/turf/space))
		return
	user << "<span class='notice'>You begin to awaken the Killer Tomato...</span>"
	awakening = 1

	spawn(30)
		if(!gc_destroyed)
			var/mob/living/simple_animal/hostile/killertomato/K = new /mob/living/simple_animal/hostile/killertomato(get_turf(src.loc))
			K.maxHealth += round(endurance / 3)
			K.melee_damage_lower += round(potency / 10)
			K.melee_damage_upper += round(potency / 10)
			K.move_to_delay -= round(production / 50)
			K.health = K.maxHealth
			K.visible_message("<span class='notice'>The Killer Tomato growls as it suddenly awakens.</span>")
			if(user)
				user.unEquip(src)
			qdel(src)



/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blood
	seed = /obj/item/seeds/bloodtomatoseed
	name = "blood-tomato"
	desc = "So bloody...so...very...bloody....AHHHH!!!!"
	icon_state = "bloodtomato"
	splat = /obj/effect/gibspawner/generic
	filling_color = "#FF0000"

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blood/add_juice(var/loc, var/potency = 10)
	..()
	reagents.add_reagent("blood", 1 + round((potency / 5), 1))


/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue
	seed = /obj/item/seeds/bluetomatoseed
	name = "blue-tomato"
	desc = "I say blue-mah-to, you say blue-mae-to."
	icon_state = "bluetomato"
	splat = /obj/effect/decal/cleanable/oil
	filling_color = "#0000FF"

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/add_juice()
	..()
	reagents.add_reagent("lube", 1 + round((potency / 5), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		var/stun = Clamp(potency / 10, 1, 10)
		var/weaken = Clamp(potency / 20, 0.5, 5)
		M.slip(stun, weaken, src)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/bluespace
	seed = /obj/item/seeds/bluespacetomatoseed
	name = "blue-space tomato"
	desc = "So lubricated, you might slip through space-time."
	icon_state = "bluespacetomato"
	origin_tech = "bluespace=3"

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/bluespace/add_juice()
	..()
	reagents.add_reagent("singulo", 1 + round((potency / 5), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/bluespace/attack_self(var/mob/user)
	squish(user)
	user.unEquip(src)
	src.visible_message("[user] squashes the [src.name].","<span class='italics'>You hear a smack.</span>")
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/bluespace/squish(atom/squishee)
	..()
	var/teleport_radius = potency / 10
	if(isliving(squishee))
		var/turf/T = get_turf(squishee)
		new /obj/effect/decal/cleanable/molten_item(T) //Leave a pile of goo behind for dramatic effect...
		do_teleport(squishee, get_turf(squishee), teleport_radius)


/obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	seed = /obj/item/seeds/wheatseed
	name = "wheat"
	desc = "Sigh... wheat... a-grain?"
	gender = PLURAL
	icon_state = "wheat"
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/grown/wheat/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/oat
	seed = /obj/item/seeds/oatseed
	name = "oat"
	desc = "Eat oats, do squats."
	gender = PLURAL
	icon_state = "oat"
	filling_color = "#556B2F"

/obj/item/weapon/reagent_containers/food/snacks/grown/oat/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/rice
	seed = /obj/item/seeds/riceseed
	name = "rice"
	desc = "Rice to meet you."
	gender = PLURAL
	icon_state = "rice"
	filling_color = "#FAFAD2"

/obj/item/weapon/reagent_containers/food/snacks/grown/rice/add_juice()
	if(..())
		reagents.add_reagent("rice", 1 + round((potency / 6), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/grass
	seed = /obj/item/seeds/grassseed
	name = "grass"
	desc = "Green and lush."
	icon_state = "grassclump"
	filling_color = "#32CD32"

/obj/item/weapon/reagent_containers/food/snacks/grown/grass/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 50), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/grass/attack_self(mob/user as mob)
	user << "<span class='notice'>You prepare the astroturf.</span>"
	var/grassAmt = 1 + round(potency / 50) // The grass we're holding
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/grass/G in user.loc) // The grass on the floor
		grassAmt += 1 + round(G.potency / 50)
		qdel(G)
	while(grassAmt > 0)
		var/obj/item/stack/tile/GT = new /obj/item/stack/tile/grass(user.loc)
		if(grassAmt >= GT.max_amount)
			GT.amount = GT.max_amount
		else
			GT.amount = grassAmt
			for(var/obj/item/stack/tile/grass/GR in user.loc)
				if(GR != GT && GR.amount < GR.max_amount)
					GR.attackby(GT, user) //we try to transfer all old unfinished stacks to the new stack we created.
		grassAmt -= GT.max_amount
	qdel(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/grown/carpet
	seed = /obj/item/seeds/carpetseed
	name = "carpet"
	desc = "The textile industry's dark secret."
	icon_state = "carpetclump"

/obj/item/weapon/reagent_containers/food/snacks/grown/carpet/attack_self(mob/user as mob)
	user << "<span class='notice'>You roll out the red carpet.</span>"
	var/carpetAmt = 1 + round(potency / 50) // The carpet we're holding
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/carpet/C in user.loc) // The carpet on the floor
		carpetAmt += 1 + round(C.potency / 50)
		qdel(C)
	while(carpetAmt > 0)
		var/obj/item/stack/tile/CT = new /obj/item/stack/tile/carpet(user.loc)
		if(carpetAmt >= CT.max_amount)
			CT.amount = CT.max_amount
		else
			CT.amount = carpetAmt
			for(var/obj/item/stack/tile/carpet/CA in user.loc)
				if(CA != CT && CA.amount < CA.max_amount)
					CA.attackby(CT, user) //we try to transfer all old unfinished stacks to the new stack we created.
		carpetAmt -= CT.max_amount
	qdel(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod
	seed = /obj/item/seeds/kudzuseed
	name = "kudzu pod"
	desc = "<I>Pueraria Virallis</I>: An invasive species with vines that rapidly creep and wrap around whatever they contact."
	icon_state = "kudzupod"
	var/list/mutations = list()
	filling_color = "#6B8E23"

/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 50), 1))
		reagents.add_reagent("charcoal", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	seed = /obj/item/seeds/carrotseed
	name = "carrot"
	desc = "It's good for the eyes!"
	icon_state = "carrot"
	filling_color = "#FFA500"

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 20), 1))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		reagents.add_reagent("oculine", 3+round(potency / 5, 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom
	name = "mushroom"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi
	seed = /obj/item/seeds/reishimycelium
	name = "reishi"
	desc = "<I>Ganoderma lucidum</I>: A special fungus known for its medicinal and stress relieving properties."
	icon_state = "reishi"
	filling_color = "#FF4500"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi/add_juice()
	..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("charcoal", 3+round(potency / 3, 1))
	reagents.add_reagent("morphine", 3+round(potency / 3, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Anti-Toxin: <i>[reagents.get_reagent_amount("charcoal")]%</i></span>"
		user << "<span class='info'>- Morphine: <i>[reagents.get_reagent_amount("morphine")]%</i></span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	seed = /obj/item/seeds/amanitamycelium
	name = "fly amanita"
	desc = "<I>Amanita Muscaria</I>: Learn poisonous mushrooms by heart. Only pick mushrooms you know."
	icon_state = "amanita"
	filling_color = "#FF0000"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita/add_juice()
	..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("amatoxin", 3+round(potency / 3, 1))
	reagents.add_reagent("mushroomhallucinogen", 1 + round(potency / 25, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Amatoxins: <i>[reagents.get_reagent_amount("amatoxin")]%</i></span>"
		user << "<span class='info'>- Mushroom Hallucinogen: <i>[reagents.get_reagent_amount("mushroomhallucinogen")]%</i></span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel
	seed = /obj/item/seeds/angelmycelium
	name = "destroying angel"
	desc = "<I>Amanita Virosa</I>: Deadly poisonous basidiomycete fungus filled with alpha amatoxins."
	icon_state = "angel"
	filling_color = "#C0C0C0"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel/add_juice()
	..()
	reagents.add_reagent("nutriment", 1 + round((potency / 50), 1))
	reagents.add_reagent("amatoxin", 13+round(potency / 3, 1))
	reagents.add_reagent("mushroomhallucinogen", 1 + round(potency / 25, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Amatoxins: <i>[reagents.get_reagent_amount("amatoxin")]%</i></span>"
		user << "<span class='info'>- Mushroom Hallucinogen: <i>[reagents.get_reagent_amount("mushroomhallucinogen")]%</i></span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap
	seed = /obj/item/seeds/libertymycelium
	name = "liberty-cap"
	desc = "<I>Psilocybe Semilanceata</I>: Liberate yourself!"
	icon_state = "libertycap"
	filling_color = "#DAA520"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap/add_juice(var/loc, var/potency = 15)
	..()
	reagents.add_reagent("nutriment", 1 + round((potency / 50), 1))
	reagents.add_reagent("mushroomhallucinogen", 3+round(potency / 5, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Mushroom Hallucinogen: <i>[reagents.get_reagent_amount("mushroomhallucinogen")]%</i></span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	seed = /obj/item/seeds/plumpmycelium
	name = "plump-helmet"
	desc = "<I>Plumus Hellmus</I>: Plump, soft and s-so inviting~"
	icon_state = "plumphelmet"
	filling_color = "#9370DB"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet/add_juice()
	..()
	reagents.add_reagent("nutriment", 2+round((potency / 10), 1))
	reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	seed = /obj/item/seeds/walkingmushroommycelium
	name = "walking mushroom"
	desc = "<I>Plumus Locomotus</I>: The beginning of the great walk."
	icon_state = "walkingmushroom"
	filling_color = "#9370DB"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom/add_juice()
	..()
	reagents.add_reagent("nutriment", 2+round((potency / 10), 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/space))
		return
	var/mob/living/simple_animal/hostile/mushroom/M = new /mob/living/simple_animal/hostile/mushroom(user.loc)
	M.maxHealth += round(endurance / 4)
	M.melee_damage_lower += round(potency / 20)
	M.melee_damage_upper += round(potency / 20)
	M.move_to_delay -= round(production / 50)
	M.health = M.maxHealth
	qdel(src)
	user << "<span class='notice'>You plant the walking mushroom.</span>"


/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle
	seed = /obj/item/seeds/chantermycelium
	name = "chanterelle cluster"
	desc = "<I>Cantharellus Cibarius</I>: These jolly yellow little shrooms sure look tasty!"
	icon_state = "chanterelle"
	filling_color = "#FFA500"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle/add_juice()
	..()
	reagents.add_reagent("nutriment", 1 + round((potency / 25), 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom
	seed = /obj/item/seeds/glowshroom
	name = "glowshroom cluster"
	desc = "<I>Mycena Bregprox</I>: This species of mushroom glows in the dark."
	icon_state = "glowshroom"
	filling_color = "#00FA9A"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/New(var/loc, var/new_potency = 10)
	..()
	if(lifespan == 0) //basically, if you're spawning these via admin or on the map, then set up some default stats.
		lifespan = 120
		endurance = 30
		maturation = 15
		production = 1
		yield = 3
		potency = 30
		plant_type = 2
	if(istype(src.loc,/mob))
		pickup(src.loc)//adjusts the lighting on the mob
	else
		src.SetLuminosity(round(potency / 10,1))

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/add_juice()
	..()
	reagents.add_reagent("nutriment", 1 + round((potency / 25), 1))
	reagents.add_reagent("radium", 1 + round((potency / 20), 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/space))
		return
	var/obj/effect/glowshroom/planted = new /obj/effect/glowshroom(user.loc)
	planted.delay = planted.delay - production * 100 //So the delay goes DOWN with better stats instead of up. :I
	planted.endurance = endurance
	planted.yield = yield
	planted.potency = potency
	qdel(src)
	user << "<span class='notice'>You plant the glowshroom.</span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/Destroy()
	if(istype(loc,/mob))
		loc.AddLuminosity(round(-potency / 10,1))
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/pickup(mob/user)
	SetLuminosity(0)
	user.AddLuminosity(round(potency / 10,1))

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/dropped(mob/user)
	user.AddLuminosity(round(-potency / 10,1))
	SetLuminosity(round(potency / 10,1))


/obj/item/weapon/reagent_containers/food/snacks/grown/shell/moneyfruit
	seed = /obj/item/seeds/cashseed
	name = "Money Fruit"
	desc = "Looks like a lemon with someone buldging from the inside."
	icon_state = "moneyfruit"
	inside_type = null

/obj/item/weapon/reagent_containers/food/snacks/grown/shell/moneyfruit/add_juice()
	..()
	reagents.add_reagent("nutriment", 1 + round((potency / 20), 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)
	switch(potency)
		if(0 to 10)
			inside_type = /obj/item/stack/spacecash/
		if(11 to 20)
			inside_type = /obj/item/stack/spacecash/c10
		if(21 to 30)
			inside_type = /obj/item/stack/spacecash/c20
		if(31 to 40)
			inside_type = /obj/item/stack/spacecash/c50
		if(41 to 50)
			inside_type = /obj/item/stack/spacecash/c100
		if(51 to 60)
			inside_type = /obj/item/stack/spacecash/c200
		if(61 to 80)
			inside_type = /obj/item/stack/spacecash/c500
		else
			inside_type = /obj/item/stack/spacecash/c1000


/obj/item/weapon/reagent_containers/food/snacks/grown/gatfruit
	seed = /obj/item/seeds/gatfruit
	name = "gatfruit"
	desc = "It smells like burning."
	icon_state = "gatfruit"
	origin_tech = "combat=3"
	trash = /obj/item/weapon/gun/projectile/revolver

/obj/item/weapon/reagent_containers/food/snacks/grown/gatfruit/add_juice()
	if(..())
		reagents.add_reagent("sulfur", 1 + round((potency / 10), 1))
		reagents.add_reagent("carbon", 1 + round((potency / 10), 1))
		reagents.add_reagent("nitrogen", 1 + round((potency / 15), 1))
		reagents.add_reagent("potassium", 1 + round((potency / 20), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/coffee //abstract type
	seed = /obj/item/seeds/coffee_arabica_seed
	name = "coffee beans"
	desc = "Dry them out to make coffee."
	icon_state = "coffee_arabica"
	filling_color = "#DC143C"

/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/add_juice()
	if(..())
		reagents.add_reagent("coffeepowder", 1 + round((potency / 10), 2))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))
		bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/arabica
	seed = /obj/item/seeds/coffee_arabica_seed
	name = "coffee arabica beans"
	desc = "Dry them out to make coffee."
	icon_state = "coffee_arabica"

/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta
	seed = /obj/item/seeds/coffee_robusta_seed
	name = "coffee robusta beans"
	desc = "Dry them out to make coffee."
	icon_state = "coffee_robusta"

/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta/add_juice(var/loc, var/potency = 20)
	..()
	reagents.add_reagent("morphine", 1 + round((potency / 20), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco
	seed = /obj/item/seeds/tobacco_seed
	name = "tobacco leaves"
	desc = "Dry them out to make some smokes."
	icon_state = "tobacco_leaves"
	filling_color = "#008000"

/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 1 + round((potency / 40), 1))
		reagents.add_reagent("nicotine", 1 + round((potency / 40), 1))


/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco/space
	seed = /obj/item/seeds/tobacco_space_seed
	name = "space tobacco leaves"
	desc = "Dry them out to make some space-smokes."
	icon_state = "stobacco_leaves"
	filling_color = "#008000"

/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco/space/add_juice()
	..()
	reagents.add_reagent("salbutamol", 1 + round((potency / 20), 1))
	reagents.add_reagent("nicotine", 1 + round((potency / 20), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/tea //abstract type
	seed = /obj/item/seeds/tea_aspera_seed
	name = "Tea tips"
	desc = "These aromatic tips of the tea plant can be dried to make tea."
	icon_state = "tea_aspera_leaves"

/obj/item/weapon/reagent_containers/food/snacks/grown/tea/add_juice()
	if(..())
		reagents.add_reagent("teapowder", 1 + round((potency / 10), 2))
		reagents.add_reagent("vitamin", 1 + round((potency / 25), 1))


/obj/item/weapon/reagent_containers/food/snacks/grown/tea/aspera
	seed = /obj/item/seeds/tea_aspera_seed
	name = "Tea Aspera tips"
	filling_color = "#008000"

/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra
	seed = /obj/item/seeds/tea_astra_seed
	name = "Tea Astra tips"
	desc = "These aromatic tips of the tea plant can be dried to make tea."
	icon_state = "tea_astra_leaves"
	filling_color = "#4582B4"

/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra/add_juice()
	..()
	reagents.add_reagent("salglu_solution", 1 + round((potency / 20), 1))
