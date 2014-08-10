////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	possible_transfer_amounts = list(5,10,25)
	volume = 50

	on_reagent_change()
		if (gulp_size < 5) gulp_size = 5
		else gulp_size = max(round(reagents.total_volume / 5), 5)

	attack_self(mob/user as mob)
		attack(user,user)
		return

	attack(mob/M as mob, mob/user as mob, def_zone)
		var/datum/reagents/R = src.reagents
		var/fillevel = gulp_size

		if(!R.total_volume || !R)
			user << "\red None of [src] left, oh no!"
			return 0

		if(M == user)
			M << "\blue You swallow a gulp of [src]."
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, gulp_size)

			playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
			return 1
		else if( istype(M, /mob/living/carbon/human) )

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to feed [M] [src].", 1)
			if(!do_mob(user, M)) return
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] feeds [M] [src].", 1)

			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")

			log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user

			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, gulp_size)

			if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
				var/mob/living/silicon/robot/bro = user
				bro.cell.use(30)
				var/refill = R.get_master_reagent_id()
				spawn(600)
					R.add_reagent(refill, fillevel)

			playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
			return 1

		return 0


	afterattack(obj/target, mob/user , flag)

		if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
			user << "\blue You fill [src] with [trans] units of the contents of [target]."

		else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return



			var/datum/reagent/refill
			var/datum/reagent/refillName
			if(isrobot(user))
				refill = reagents.get_master_reagent_id()
				refillName = reagents.get_master_reagent_name()

			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			user << "\blue You transfer [trans] units of the solution to [target]."

			if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
				var/mob/living/silicon/robot/bro = user
				var/chargeAmount = max(30,4*trans)
				bro.cell.use(chargeAmount)
				user << "Now synthesizing [trans] units of [refillName]..."


				spawn(300)
					reagents.add_reagent(refill, trans)
					user << "Cyborg [src] refilled."

		return

	examine()
		set src in view()
		..()
		if (!(usr in range(0)) && usr!=src.loc) return
		if(!reagents || reagents.total_volume==0)
			usr << "\blue \The [src] is empty!"
		else if (reagents.total_volume<=src.volume/4)
			usr << "\blue \The [src] is almost empty!"
		else if (reagents.total_volume<=src.volume*0.66)
			usr << "\blue \The [src] is half full!"
		else if (reagents.total_volume<=src.volume*0.90)
			usr << "\blue \The [src] is almost full!"
		else
			usr << "\blue \The [src] is full!"
	New()
		..()
		score["meals"]++

////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/golden_cup
	desc = "A golden cup"
	name = "golden cup"
	icon_state = "golden_cup"
	item_state = "" //nope :(
	w_class = 4
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = null
	volume = 150
	flags = FPRINT | CONDUCT | TABLEPASS | OPENCONTAINER

/obj/item/weapon/reagent_containers/food/drinks/golden_cup/tournament_26_06_2011
	desc = "A golden cup. It will be presented to a winner of tournament 26 june and name of the winner will be graved on it."


///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.

/obj/item/weapon/reagent_containers/food/drinks/milk
	name = "Space Milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "carton"
	New()
		..()
		reagents.add_reagent("milk", 50)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon = 'icons/obj/food.dmi'
	icon_state = "flour"
	item_state = "flour"
	New()
		..()
		reagents.add_reagent("flour", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soymilk
	name = "SoyMilk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	item_state = "carton"
	New()
		..()
		reagents.add_reagent("soymilk", 50)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	New()
		..()
		reagents.add_reagent("coffee", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/tea
	name = "Duke Purple Tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "tea"
	item_state = "coffee"
	New()
		..()
		reagents.add_reagent("tea", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/ice
	name = "Ice Cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "coffee"
	New()
		..()
		reagents.add_reagent("ice", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate
	name = "Dutch Hot Coco"
	desc = "Made in Space South America."
	icon_state = "tea"
	item_state = "coffee"
	New()
		..()
		reagents.add_reagent("hot_coco", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen
	name = "Cup Ramen"
	desc = "Just add 10ml water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	New()
		..()
		reagents.add_reagent("dry_ramen", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/groans
	name = "Groans Soda"
	desc = "Groans Soda: We'll make you groan."
	icon_state = "groans"
	New()
		..()
		switch(pick(1,2,3,4,5))
			if(1)
				name = "Groans Soda: Cuban Spice Flavor"
				desc = "Warning: Long exposure to liquid inside may cause you to follow the rumba beat."
				icon_state += "_hot"
				reagents.add_reagent("condensedcapsaicin", 10)
				reagents.add_reagent("rum", 10)
			if(2)
				name = "Groans Soda: Icey Cold Flavor"
				desc = "Cold in a can. Er, bottle."
				icon_state += "_cold"
				reagents.add_reagent("frostoil", 10)
				reagents.add_reagent("ice", 10)
			if(3)
				name = "Groans Soda: Zero Calories"
				desc = "Zero Point Calories. That's right, we fit even MORE nutriment in this thing."
				icon_state += "_nutriment"
				reagents.add_reagent("nutriment", 20)
			if(4)
				name = "Groans Soda: Energy Shot"
				desc = "Warning: The Groans Energy Blend(tm), may be toxic to those without constant exposure to chemical waste. Drink responsibly."
				icon_state += "_energy"
				reagents.add_reagent("sugar", 10)
				reagents.add_reagent("chemical_waste", 10)
			if(5)
				name = "Groans Soda: Double Dan"
				desc = "Just when you thought you've had enough Dan, The 'Double Dan' strikes back with this wonderful mixture of too many flavors. Bring a barf bag, Drink responsibly."
				icon_state += "_doubledew"
				reagents.add_reagent("discount", 20)
		reagents.add_reagent("discount", 10)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/filk
	name = "Filk"
	desc = "Only the best Filk for your crew."
	icon_state = "filk"
	New()
		..()
		switch(pick(1,2,3,4,5))
			if(1)
				name = "Filk: Chocolate Edition"
				reagents.add_reagent("hot_coco", 10)
			if(2)
				name = "Filk: Scripture Edition"
				reagents.add_reagent("holywater", 30)
			if(3)
				name = "Filk: Carribean Edition"
				reagents.add_reagent("rum", 30)
			if(4)
				name = "Filk: Sugar Blast Editon"
				reagents.add_reagent("sugar", 30)
				reagents.add_reagent("radium", 10) // le epik fallout may mays
				reagents.add_reagent("toxicwaste", 10)
			if(5)
				name = "Filk: Pure Filk Edition"
				reagents.add_reagent("discount", 20)
		reagents.add_reagent("discount", 10)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo
	name = "Grifeo"
	desc = "A quality drink."
	icon_state = "griefo"
	New()
		..()
		switch(pick(1,2,3,4,5))
			if(1)
				name = "Grifeo: Spicy"
				reagents.add_reagent("condensedcapsaicin", 30)
			if(2)
				name = "Grifeo: Frozen"
				reagents.add_reagent("frostoil", 30)
			if(3)
				name = "Grifeo: Crystallic"
				reagents.add_reagent("sugar", 20)
				reagents.add_reagent("ice", 20)
				reagents.add_reagent("space_drugs", 20)
			if(4)
				name = "Grifeo: Rich"
				reagents.add_reagent("tequilla", 10)
				reagents.add_reagent("chemical_waste", 10)
			if(5)
				name = "Grifeo: Pure"
				reagents.add_reagent("discount", 20)
		reagents.add_reagent("discount", 10)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/groansbanned
	name = "Groans: Banned Edition"
	desc = "Banned literally everywhere."
	icon_state = "groansevil"
	New()
		..()
		switch(pick(1,2,3,4,5))
			if(1)
				name = "Groans Banned Soda: Fish Suprise"
				reagents.add_reagent("carpotoxin", 10)
			if(2)
				name = "Groans Banned Soda: Bitter Suprise"
				reagents.add_reagent("toxin", 20)
			if(3)
				name = "Groans Banned Soda: Sour Suprise"
				reagents.add_reagent("pacid", 20)
			if(4)
				name = "Groans Banned Soda: Sleepy Suprise"
				reagents.add_reagent("stoxin", 10)
			if(5)
				name = "Groans Banned Soda: Quadruple Dan"
				reagents.add_reagent("discount", 40)
		reagents.add_reagent("discount", 10)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/mannsdrink
	name = "Mann's Drink"
	desc = "The only thing a <B>REAL MAN</B> needs."
	icon_state = "mannsdrink"
	New()
		..()
		reagents.add_reagent("discount", 30)
		reagents.add_reagent("water", 20)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/groans
	name = "Groan-o-matic 9000"
	desc = "This is for testing reasons."
	icon_state = "toddler"

/obj/item/weapon/groans/attack_self(mob/user as mob)
	user << "Now spawning groans."
	var/turf/T = get_turf(user.loc)
	var/obj/item/weapon/reagent_containers/food/drinks/groans/A = new /obj/item/weapon/reagent_containers/food/drinks/groans(T)
	A.desc += " It also smells like a toddler." //This is required

/obj/item/weapon/reagent_containers/food/drinks/discount_ramen_hot
	name = "\improper Discount Dan's Noodle Soup"
	desc = "Discount Dan is proud to introduce his own take on noodle soups, with this on the go treat! Simply pull the tab, and a self heating mechanism activates!"
	icon_state = "ramen"
	var/list/ddname = list("Discount Deng's Quik-Noodles - Sweet and Sour Lo Mein Flavor","Frycook Dan's Quik-Noodles - Curly Fry Ketchup Hoedown Flavor","Rabatt Dan's Snabb-Nudlar - Inkokt Lax Smörgåsbord Smak","Discount Deng's Quik-Noodles - Teriyaki TVP Flavor","Sconto Danilo's Quik-Noodles - Italian Strozzapreti Lunare Flavor")
	New()
		..()
		name = pick(ddname)
		reagents.add_reagent("hot_ramen", 20)
		reagents.add_reagent("discount", 10)
		reagents.add_reagent("glowingramen", 8)
		reagents.add_reagent("toxicwaste", 8)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/discount_ramen
	name = "\improper Discount Dan's Noodle Soup"
	desc = "Discount Dan is proud to introduce his own take on noodle soups, with this on the go treat! Simply pull the tab, and a self heating mechanism activates!"
	icon_state = "ramen"
	var/list/ddname = list("Discount Deng's Quik-Noodles - Sweet and Sour Lo Mein Flavor","Frycook Dan's Quik-Noodles - Curly Fry Ketchup Hoedown Flavor","Rabatt Dan's Snabb-Nudlar - Inkokt Lax Smörgåsbord Smak","Discount Deng's Quik-Noodles - Teriyaki TVP Flavor","Sconto Danilo's Quik-Noodles - Italian Strozzapreti Lunare Flavor")
	New()
		..()
		name = pick(ddname)
		reagents.add_reagent("dry_ramen", 20)
		reagents.add_reagent("discount", 10)
		reagents.add_reagent("toxicwaste", 4)
		reagents.add_reagent("greenramen", 4)
		reagents.add_reagent("glowingramen", 4)
		reagents.add_reagent("deepfriedramen", 4)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/discount_ramen/attack_self(mob/user as mob)
	user << "You pull the tab, you feel the drink heat up in your hands, and its horrible fumes hits your nose like a ton of bricks. You drop the soup in disgust."
	var/turf/T = get_turf(user.loc)
	var/obj/item/weapon/reagent_containers/food/drinks/discount_ramen_hot/A = new /obj/item/weapon/reagent_containers/food/drinks/discount_ramen_hot(T)
	A.desc += " It feels warm.." //This is required
	user.drop_from_inventory(src)
	del(src)


/obj/item/weapon/reagent_containers/food/drinks/beer
	name = "Space Beer"
	desc = "Beer. In space."
	icon_state = "beer"
	New()
		..()
		reagents.add_reagent("beer", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	item_state = "beer"
	New()
		..()
		reagents.add_reagent("ale", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola
	name = "Space Cola"
	desc = "Cola. in space."
	icon_state = "cola"
	New()
		..()
		reagents.add_reagent("cola", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/tonic
	name = "T-Borg's Tonic Water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
	New()
		..()
		reagents.add_reagent("tonic", 50)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sodawater
	name = "Soda Water"
	desc = "A can of soda water. Why not make a scotch and soda?"
	icon_state = "sodawater"
	New()
		..()
		reagents.add_reagent("sodawater", 50)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime
	name = "Lemon-Lime"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	New()
		..()
		reagents.add_reagent("lemon_lime", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up
	name = "Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	New()
		..()
		reagents.add_reagent("space_up", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	New()
		..()
		reagents.add_reagent("cola", 15)
		reagents.add_reagent("orangejuice", 15)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	New()
		..()
		reagents.add_reagent("spacemountainwind", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/thirteenloko
	name = "Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkeness, or even death. Please Drink Responsably."
	icon_state = "thirteen_loko"
	New()
		..()
		reagents.add_reagent("thirteenloko", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
	New()
		..()
		reagents.add_reagent("dr_gibb", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)


/obj/item/weapon/reagent_containers/food/drinks/sillycup
	name = "Paper Cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = null
	volume = 10
	New()
		..()
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)
	on_reagent_change()
		if(reagents.total_volume)
			icon_state = "water_cup"
		else
			icon_state = "water_cup_e"
//////////////////////////drinkingglass and shaker//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/weapon/reagent_containers/food/drinks/shaker
	name = "Shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	amount_per_transfer_from_this = 10
	volume = 100

/obj/item/weapon/reagent_containers/food/drinks/flask
	name = "Captain's Flask"
	desc = "A metal flask belonging to the captain"
	icon_state = "flask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/detflask
	name = "Detective's Flask"
	desc = "A metal flask with a leather band and golden badge belonging to the detective."
	icon_state = "detflask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/barflask
	name = "flask"
	desc = "For those who can't be bothered to hang out at the bar to drink."
	icon_state = "barflask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/britcup
	name = "cup"
	desc = "A cup with the british flag emblazoned on it."
	icon_state = "britcup"
	volume = 30