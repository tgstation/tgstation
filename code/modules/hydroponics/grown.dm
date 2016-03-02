// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

//Grown foods
//Subclass so we can pass on values
/obj/item/weapon/reagent_containers/food/snacks/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	var/seed = null
	var/plantname = ""
	var/product	//a type path
	var/lifespan = 0
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0
	var/plant_type = 0
	var/bitesize_mod = 0
	// If set, bitesize = 1 + round(reagents.total_volume / bitesize_mod)
	var/list/reagents_add = list()
	// A list of reagents to add.
	// Format: "reagent_id" = potency multiplier
	// Stronger reagents must always come first to avoid being displaced by weaker ones.
	// Total amount of any reagent in plant is calculated by formula: 1 + round(potency * multiplier)
	potency = -1
	dried_type = -1
	// Saves us from having to define each stupid grown's dried_type as itself.
	// If you don't want a plant to be driable (watermelons) set this to null in the time definition.
	burn_state = FLAMMABLE

/obj/item/weapon/reagent_containers/food/snacks/grown/New(newloc, new_potency = 50)
	..()
	potency = new_potency
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	if(dried_type == -1)
		dried_type = src.type

	if(seed && lifespan == 0)
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type. This feels like a hack but people insist on putting these things on the map...
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
		for(var/reagent_id in reagents_add)
			reagents.add_reagent(reagent_id, 1 + round(potency * reagents_add[reagent_id]))
		if(bitesize_mod)
			bitesize = 1 + round(reagents.total_volume / bitesize_mod)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(obj/item/O, mob/user, params)
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

		var/list/scannable_reagents = list("charcoal" = "Anti-Toxin", "morphine" = "Morphine", "amatoxin" = "Amatoxins",
			"toxin" = "Toxins", "mushroomhallucinogen" = "Mushroom Hallucinogen", "condensedcapsaicin" = "Condensed Capsaicin",
			"capsaicin" = "Capsaicin", "frostoil" = "Frost Oil", "gold" = "Mineral Content",
			"radium" = "Radioactive Material", "uranium" = "Radioactive Material")
		var/reag_txt = ""
		for(var/reagent_id in scannable_reagents)
			if(reagent_id in reagents_add)
				var/amt = reagents.get_reagent_amount(reagent_id)
				reag_txt += "<span class='info'>- [scannable_reagents[reagent_id]]: [amt*100/reagents.maximum_volume]%</span>\n"

		user << msg
		if(reag_txt)
			user << reag_txt
			user << "<span class='info'>*---------*</span>"
		return
	return


/obj/item/weapon/reagent_containers/food/snacks/grown/corn
	seed = /obj/item/seeds/cornseed
	name = "ear of corn"
	desc = "Needs some butter!"
	icon_state = "corn"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/popcorn
	filling_color = "#FFFF00"
	trash = /obj/item/weapon/grown/corncob
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/cherries
	seed = /obj/item/seeds/cherryseed
	name = "cherries"
	desc = "Great for toppings!"
	icon_state = "cherry"
	gender = PLURAL
	filling_color = "#FF0000"
	reagents_add = list("nutriment" = 0.07, "sugar" = 0.07)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries
	seed = /obj/item/seeds/bluecherryseed
	name = "blue cherries"
	desc = "They're cherries that are blue."
	icon_state = "bluecherry"
	filling_color = "#6495ED"
	reagents_add = list("nutriment" = 0.07, "sugar" = 0.07)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/potato
	seed = /obj/item/seeds/potatoseed
	name = "potato"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "potato"
	filling_color = "#E9967A"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)
	bitesize = 100

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if (C.use(5))
			user << "<span class='notice'>You add some cable to the potato and slide it inside the battery encasing.</span>"
			var/obj/item/weapon/stock_parts/cell/potato/pocell = new /obj/item/weapon/stock_parts/cell/potato(user.loc)
			pocell.maxcharge = src.potency * 20
			pocell.charge = pocell.maxcharge
			qdel(src)
			return
		else
			user << "<span class='warning'>You need five lengths of cable to make a potato battery!</span>"
			return

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/sweet
	seed = /obj/item/seeds/sweetpotatoseed
	name = "sweet potato"
	desc = "It's sweet."
	icon_state = "sweetpotato"
	reagents_add = list("vitamin" = 0.1, "sugar" = 0.1, "nutriment" = 0.1)


/obj/item/weapon/reagent_containers/food/snacks/grown/grapes
	seed = /obj/item/seeds/grapeseed
	name = "bunch of grapes"
	desc = "Nutritious!"
	icon_state = "grapes"
	dried_type = /obj/item/weapon/reagent_containers/food/snacks/no_raisin
	filling_color = "#FF1493"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1, "sugar" = 0.1)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/grapes/green
	seed = /obj/item/seeds/greengrapeseed
	name = "bunch of green grapes"
	desc = "Nutritious!"
	icon_state = "greengrapes"
	dried_type = /obj/item/weapon/reagent_containers/food/snacks/no_raisin
	filling_color = "#7FFF00"
	reagents_add = list("salglu_solution" = 0.25, "vitamin" = 0.04, "nutriment" = 0.1, "sugar" = 0.1)


/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	seed = /obj/item/seeds/cabbageseed
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	icon_state = "cabbage"
	filling_color = "#90EE90"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod
	seed = /obj/item/seeds/cocoapodseed
	name = "cocoa pod"
	desc = "Fattening... Mmmmm... chucklate."
	icon_state = "cocoapod"
	filling_color = "#FFD700"
	reagents_add = list("cocoa" = 0.25, "nutriment" = 0.1)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/vanillapod
	seed = /obj/item/seeds/vanillapodseed
	name = "vanilla pod"
	desc = "Fattening... Mmmmm... vanilla."
	icon_state = "vanillapod"
	filling_color = "#FFD700"
	reagents_add = list("vanilla" = 0.25, "nutriment" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane
	seed = /obj/item/seeds/sugarcaneseed
	name = "sugarcane"
	desc = "Sickly sweet."
	icon_state = "sugarcane"
	filling_color = "#FFD700"
	reagents_add = list("sugar" = 0.25)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia //abstract type
	name = "ambrosia branch"
	desc = "This is a plant."
	icon_state = "ambrosiavulgaris"
	slot_flags = SLOT_HEAD
	filling_color = "#008000"
	reagents_add = list("nutriment" = 0)
	// It means 1 nutriment no matter how low or high potency is
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	seed = /obj/item/seeds/ambrosiavulgarisseed
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	reagents_add = list("space_drugs" = 0.15, "salglu_solution" = 0.25, "vitamin" = 0.04, "nutriment" = 0, "toxin" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus
	seed = /obj/item/seeds/ambrosiadeusseed
	name = "ambrosia deus branch"
	desc = "Eating this makes you feel immortal!"
	icon_state = "ambrosiadeus"
	filling_color = "#008B8B"
	reagents_add = list("omnizine" = 0.15, "synaptizine" = 0.15, "space_drugs" = 0.1, "vitamin" = 0.04, "nutriment" = 0)


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
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.2, "water" = 0.1)
	bitesize_mod = 3

/obj/item/weapon/reagent_containers/food/snacks/grown/holymelon
	seed = /obj/item/seeds/holymelonseed
	name = "holymelon"
	desc = "The water within this melon has been blessed by some deity that's particularly fond of watermelon."
	icon_state = "holymelon"
	filling_color = "#FFD700"
	dried_type = null
	reagents_add = list("holywater" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
	seed = /obj/item/seeds/pumpkinseed
	name = "pumpkin"
	desc = "It's large and scary."
	icon_state = "pumpkin"
	filling_color = "#FFA500"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.2)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if(W.is_sharp())
		user.show_message("<span class='notice'>You carve a face into [src]!</span>", 1)
		new /obj/item/clothing/head/hardhat/pumpkinhead(user.loc)
		qdel(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/blumpkin
	seed = /obj/item/seeds/blumpkinseed
	name = "blumpkin"
	desc = "The pumpkin's toxic sibling."
	icon_state = "blumpkin"
	filling_color = "#87CEFA"
	reagents_add = list("ammonia" = 0.2, "nutriment" = 0.2)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
	seed = /obj/item/seeds/whitebeetseed
	name = "white-beet"
	desc = "You can't beat white-beet."
	icon_state = "whitebeet"
	filling_color = "#F4A460"
	reagents_add = list("vitamin" = 0.04, "sugar" = 0.2, "nutriment" = 0.05)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/parsnip
	seed = /obj/item/seeds/parsnipseed
	name = "parsnip"
	desc = "Closely related to carrots."
	icon_state = "parsnip"
	reagents_add = list("vitamin" = 0.05, "nutriment" = 0.05)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/redbeet
	seed = /obj/item/seeds/redbeetseed
	name = "red beet"
	desc = "You can't beat red beet."
	icon_state = "redbeet"
	reagents_add = list("vitamin" = 0.05, "nutriment" = 0.05)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	seed = /obj/item/seeds/eggplantseed
	name = "eggplant"
	desc = "Maybe there's a chicken inside?"
	icon_state = "eggplant"
	filling_color = "#800080"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/shell
	var/inside_type = null

/obj/item/weapon/reagent_containers/food/snacks/grown/shell/attack_self(mob/user as mob)
	if(inside_type)
		new inside_type(user.loc)
	user.unEquip(src)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/shell/eggy
	seed = /obj/item/seeds/eggyseed
	name = "Egg-plant"
	desc = "There MUST be a chicken inside."
	icon_state = "eggyplant"
	inside_type = /obj/item/weapon/reagent_containers/food/snacks/egg
	filling_color = "#F8F8FF"
	reagents_add = list("nutriment" = 0.1)
	bitesize_mod = 2


/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	seed = /obj/item/seeds/soyaseed
	name = "soybeans"
	desc = "It's pretty bland, but oh the possibilities..."
	gender = PLURAL
	icon_state = "soybeans"
	filling_color = "#F0E68C"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.05)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans
	seed = /obj/item/seeds/koiseed
	name = "koibean"
	desc = "Something about these seems fishy."
	icon_state = "koibeans"
	filling_color = "#F0E68C"
	reagents_add = list("carpotoxin" = 0.05, "vitamin" = 0.04, "nutriment" = 0.05)
	bitesize_mod = 2









/obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	seed = /obj/item/seeds/wheatseed
	name = "wheat"
	desc = "Sigh... wheat... a-grain?"
	gender = PLURAL
	icon_state = "wheat"
	filling_color = "#F0E68C"
	bitesize_mod = 2
	reagents_add = list("nutriment" = 0.04)

/obj/item/weapon/reagent_containers/food/snacks/grown/oat
	seed = /obj/item/seeds/oatseed
	name = "oat"
	desc = "Eat oats, do squats."
	gender = PLURAL
	icon_state = "oat"
	filling_color = "#556B2F"
	bitesize_mod = 2
	reagents_add = list("nutriment" = 0.04)

/obj/item/weapon/reagent_containers/food/snacks/grown/rice
	seed = /obj/item/seeds/riceseed
	name = "rice"
	desc = "Rice to meet you."
	gender = PLURAL
	icon_state = "rice"
	filling_color = "#FAFAD2"
	bitesize_mod = 2
	reagents_add = list("nutriment" = 0.04)

/obj/item/weapon/reagent_containers/food/snacks/grown/grass
	seed = /obj/item/seeds/grassseed
	name = "grass"
	desc = "Green and lush."
	icon_state = "grassclump"
	filling_color = "#32CD32"
	bitesize_mod = 2
	reagents_add = list("nutriment" = 0.02)

/obj/item/weapon/reagent_containers/food/snacks/grown/grass/attack_self(mob/user)
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

/obj/item/weapon/reagent_containers/food/snacks/grown/carpet/attack_self(mob/user)
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
	bitesize_mod = 2
	reagents_add = list("charcoal" = 0.04, "nutriment" = 0.02)


/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	seed = /obj/item/seeds/carrotseed
	name = "carrot"
	desc = "It's good for the eyes!"
	icon_state = "carrot"
	filling_color = "#FFA500"
	bitesize_mod = 2
	reagents_add = list("oculine" = 0.25, "vitamin" = 0.04, "nutriment" = 0.05)

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/kitchen/knife) || istype(I, /obj/item/weapon/hatchet))
		user << "<span class='notice'>You sharpen the carrot into a shiv with [I].</span>"
		var/obj/item/weapon/kitchen/knife/carrotshiv/Shiv = new /obj/item/weapon/kitchen/knife/carrotshiv
		if(!remove_item_from_storage(user))
			user.unEquip(src)
		user.put_in_hands(Shiv)
		qdel(src)
	else
		return ..()


/obj/item/weapon/reagent_containers/food/snacks/grown/shell/moneyfruit
	seed = /obj/item/seeds/cashseed
	name = "Money Fruit"
	desc = "Looks like a lemon with someone buldging from the inside."
	icon_state = "moneyfruit"
	inside_type = null
	reagents_add = list("nutriment" = 0.05)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/shell/moneyfruit/add_juice()
	..()
	switch(potency)
		if(0 to 10)
			inside_type = /obj/item/stack/spacecash
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
	bitesize_mod = 2
	reagents_add = list("sulfur" = 0.1, "carbon" = 0.1, "nitrogen" = 0.07, "potassium" = 0.05)


/obj/item/weapon/reagent_containers/food/snacks/grown/coffee //abstract type
	seed = /obj/item/seeds/coffee_arabica_seed
	name = "coffee arabica beans"
	desc = "Dry them out to make coffee."
	icon_state = "coffee_arabica"
	filling_color = "#DC143C"
	bitesize_mod = 2
	reagents_add = list("vitamin" = 0.04, "coffeepowder" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta
	seed = /obj/item/seeds/coffee_robusta_seed
	name = "coffee robusta beans"
	icon_state = "coffee_robusta"
	reagents_add = list("morphine" = 0.05, "vitamin" = 0.04, "coffeepowder" = 0.1)


/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco
	seed = /obj/item/seeds/tobacco_seed
	name = "tobacco leaves"
	desc = "Dry them out to make some smokes."
	icon_state = "tobacco_leaves"
	filling_color = "#008000"
	reagents_add = list("nicotine" = 0.03, "nutriment" = 0.03)

/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco/space
	seed = /obj/item/seeds/tobacco_space_seed
	name = "space tobacco leaves"
	desc = "Dry them out to make some space-smokes."
	icon_state = "stobacco_leaves"
	filling_color = "#008000"
	reagents_add = list("salbutamol" = 0.05, "nicotine" = 0.08, "nutriment" = 0.03)


/obj/item/weapon/reagent_containers/food/snacks/grown/tea
	seed = /obj/item/seeds/tea_aspera_seed
	name = "Tea Aspera tips"
	desc = "These aromatic tips of the tea plant can be dried to make tea."
	icon_state = "tea_aspera_leaves"
	filling_color = "#008000"
	reagents_add = list("vitamin" = 0.04, "teapowder" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra
	seed = /obj/item/seeds/tea_astra_seed
	name = "Tea Astra tips"
	icon_state = "tea_astra_leaves"
	filling_color = "#4582B4"
	reagents_add = list("salglu_solution" = 0.05, "vitamin" = 0.04, "teapowder" = 0.1)
