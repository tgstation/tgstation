////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	container_type = OPENCONTAINER
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	volume = 50
	resistance_flags = 0

/obj/item/reagent_containers/food/drinks/on_reagent_change()
	if (gulp_size < 5) gulp_size = 5
	else gulp_size = max(round(reagents.total_volume / 5), 5)

/obj/item/reagent_containers/food/drinks/attack(mob/M, mob/user, def_zone)

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return 0

	if(!canconsume(M, user))
		return 0

	if (!is_open_container())
		to_chat(user, "<span class='warning'>[src]'s lid hasn't been opened!</span>")
		return 0

	if(M == user)
		to_chat(M, "<span class='notice'>You swallow a gulp of [src].</span>")

	else
		M.visible_message("<span class='danger'>[user] attempts to feed the contents of [src] to [M].</span>", "<span class='userdanger'>[user] attempts to feed the contents of [src] to [M].</span>")
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return // The drink might be empty after the delay, such as by spam-feeding
		M.visible_message("<span class='danger'>[user] feeds the contents of [src] to [M].</span>", "<span class='userdanger'>[user] feeds the contents of [src] to [M].</span>")
		add_logs(user, M, "fed", reagentlist(src))

	var/fraction = min(gulp_size/reagents.total_volume, 1)
	checkLiked(fraction, M)
	reagents.reaction(M, INGEST, fraction)
	reagents.trans_to(M, gulp_size)
	playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
	return 1

/obj/item/reagent_containers/food/drinks/afterattack(obj/target, mob/user , proximity)
	if(!proximity) return
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if (!is_open_container())
			to_chat(user, "<span class='warning'>[target]'s tab isn't open!</span>")
			return

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty.</span>")
			return

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return
		var/refill = reagents.get_master_reagent_id()
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

		if(iscyborg(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			var/mob/living/silicon/robot/bro = user
			bro.cell.use(30)
			addtimer(CALLBACK(reagents, /datum/reagents.proc/add_reagent, refill, trans), 600)

/obj/item/reagent_containers/food/drinks/attackby(obj/item/I, mob/user, params)
	if(I.is_hot())
		var/added_heat = (I.is_hot() / 100) //ishot returns a temperature
		if(reagents)
			reagents.chem_temp += added_heat
			to_chat(user, "<span class='notice'>You heat [src] with [I].</span>")
			reagents.handle_reactions()
	..()






////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////


/obj/item/reagent_containers/food/drinks/trophy
	name = "pewter cup"
	desc = "Everyone gets a trophy."
	icon_state = "pewter_cup"
	w_class = WEIGHT_CLASS_TINY
	force = 1
	throwforce = 1
	amount_per_transfer_from_this = 5
	materials = list(MAT_METAL=100)
	possible_transfer_amounts = list()
	volume = 5
	flags = CONDUCT
	container_type = OPENCONTAINER
	spillable = 1
	resistance_flags = FIRE_PROOF

/obj/item/reagent_containers/food/drinks/trophy/gold_cup
	name = "gold cup"
	desc = "You're winner!"
	icon_state = "golden_cup"
	w_class = WEIGHT_CLASS_BULKY
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	materials = list(MAT_GOLD=1000)
	volume = 150

/obj/item/reagent_containers/food/drinks/trophy/silver_cup
	name = "silver cup"
	desc = "Best loser!"
	icon_state = "silver_cup"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	throwforce = 8
	amount_per_transfer_from_this = 15
	materials = list(MAT_SILVER=800)
	volume = 100


/obj/item/reagent_containers/food/drinks/trophy/bronze_cup
	name = "bronze cup"
	desc = "At least you ranked!"
	icon_state = "bronze_cup"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 4
	amount_per_transfer_from_this = 10
	materials = list(MAT_METAL=400)
	volume = 25

///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.

/obj/item/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	list_reagents = list("coffee" = 30)
	spillable = 1
	resistance_flags = FREEZE_PROOF

/obj/item/reagent_containers/food/drinks/ice
	name = "Ice Cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "coffee"
	list_reagents = list("ice" = 30)
	spillable = 1

/obj/item/reagent_containers/food/drinks/mug/ // parent type is literally just so empty mug sprites are a thing
	name = "mug"
	desc = "A drink served in a classy mug."
	icon_state = "tea"
	item_state = "coffee"
	spillable = 1

/obj/item/reagent_containers/food/drinks/mug/on_reagent_change()
	if(reagents.total_volume)
		icon_state = "tea"
	else
		icon_state = "tea_empty"

/obj/item/reagent_containers/food/drinks/mug/tea
	name = "Duke Purple Tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	list_reagents = list("tea" = 30)

/obj/item/reagent_containers/food/drinks/mug/coco
	name = "Dutch Hot Coco"
	desc = "Made in Space South America."
	list_reagents = list("hot_coco" = 30, "sugar" = 5)
	foodtype = SUGAR

	resistance_flags = FREEZE_PROOF


/obj/item/reagent_containers/food/drinks/dry_ramen
	name = "Cup Ramen"
	desc = "Just add 10ml of water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	list_reagents = list("dry_ramen" = 30)
	foodtype = GRAIN

/obj/item/reagent_containers/food/drinks/beer
	name = "Space Beer"
	desc = "Beer. In space."
	icon_state = "beer"
	list_reagents = list("beer" = 30)
	foodtype = GRAIN | ALCOHOL

/obj/item/reagent_containers/food/drinks/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	item_state = "beer"
	list_reagents = list("ale" = 30)
	foodtype = GRAIN | ALCOHOL

/obj/item/reagent_containers/food/drinks/sillycup
	name = "paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = list()
	volume = 10
	spillable = 1

/obj/item/reagent_containers/food/drinks/sillycup/on_reagent_change()
	if(reagents.total_volume)
		icon_state = "water_cup"
	else
		icon_state = "water_cup_e"

/obj/item/reagent_containers/food/drinks/sillycup/smallcarton
	name = "small carton"
	desc = "A small carton, intended for holding drinks."
	icon_state = "juicebox"
	volume = 15 //I figure if you have to craft these it should at least be slightly better than something you can get for free from a watercooler

/obj/item/reagent_containers/food/drinks/sillycup/smallcarton/on_reagent_change()
	if (reagents.reagent_list.len)
		switch(reagents.get_master_reagent_id())
			if("orangejuice")
				icon_state = "orangebox"
				name = "orange juice box"
				desc = "A great source of vitamins. Stay healthy!"
				foodtype = FRUIT
			if("milk")
				icon_state = "milkbox"
				name = "carton of milk"
				desc = "An excellent source of calcium for growing space explorers."
				foodtype = DAIRY
			if("applejuice")
				icon_state = "juicebox"
				name = "apple juice box"
				desc = "Sweet apple juice. Don't be late for school!"
				foodtype = FRUIT
			if("grapejuice")
				icon_state = "grapebox"
				name = "grape juice box"
				desc = "Tasty grape juice in a fun little container. Non-alcoholic!"
				foodtype = FRUIT
			if("chocolate_milk")
				icon_state = "chocolatebox"
				name = "carton of chocolate milk"
				desc = "Milk for cool kids!"
				foodtype = SUGAR
			if("eggnog")
				icon_state = "nog2"
				name = "carton of eggnog"
				desc = "For enjoying the most wonderful time of the year."
				foodtype = MEAT
	else
		icon_state = "juicebox"
		name = "small carton"
		desc = "A small carton, intended for holding drinks."



//////////////////////////drinkingglass and shaker//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/reagent_containers/food/drinks/shaker
	name = "shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	materials = list(MAT_METAL=1500)
	amount_per_transfer_from_this = 10
	volume = 100

/obj/item/reagent_containers/food/drinks/flask
	name = "flask"
	desc = "Every good spaceman knows it's a good idea to bring along a couple of pints of whiskey wherever they go."
	icon_state = "flask"
	materials = list(MAT_METAL=250)
	volume = 60

/obj/item/reagent_containers/food/drinks/flask/gold
	name = "captain's flask"
	desc = "A gold flask belonging to the captain."
	icon_state = "flask_gold"
	materials = list(MAT_GOLD=500)

/obj/item/reagent_containers/food/drinks/flask/det
	name = "detective's flask"
	desc = "The detective's only true friend."
	icon_state = "detflask"
	list_reagents = list("hearty_punch" = 30)

/obj/item/reagent_containers/food/drinks/britcup
	name = "cup"
	desc = "A cup with the british flag emblazoned on it."
	icon_state = "britcup"
	volume = 30
	spillable = 1

///Lavaland bowls and bottles///

/obj/item/reagent_containers/food/drinks/mushroom_bowl
	name = "mushroom bowl"
	desc = "A bowl made out of mushrooms. Not food, though it might have contained some at some point."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_bowl"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = 0


//////////////////////////soda_cans//
//These are in their own group to be used as IED's in /obj/item/grenade/ghettobomb.dm

/obj/item/reagent_containers/food/drinks/soda_cans
	name = "soda can"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	container_type = 0
	spillable = FALSE

/obj/item/reagent_containers/food/drinks/soda_cans/attack(mob/M, mob/user)
	if(M == user && !src.reagents.total_volume && user.a_intent == INTENT_HARM && user.zone_selected == "head")
		user.visible_message("<span class='warning'>[user] crushes the can of [src] on [user.p_their()] forehead!</span>", "<span class='notice'>You crush the can of [src] on your forehead.</span>")
		playsound(user.loc,'sound/weapons/pierce.ogg', rand(10,50), 1)
		var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(user.loc)
		crushed_can.icon_state = icon_state
		qdel(src)
	..()


/obj/item/reagent_containers/food/drinks/soda_cans/attack_self(mob/user)
	if(!is_open_container())
		to_chat(user, "You pull back the tab of \the [src] with a satisfying pop.") //Ahhhhhhhh
		container_type = OPENCONTAINER
		playsound(src, "can_open", 50, 1)
		spillable = TRUE
		return
	return ..()

/obj/item/reagent_containers/food/drinks/soda_cans/cola
	name = "Space Cola"
	desc = "Cola. in space."
	icon_state = "cola"
	list_reagents = list("cola" = 30)
	foodtype = SUGAR

/obj/item/reagent_containers/food/drinks/soda_cans/tonic
	name = "T-Borg's Tonic Water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
	list_reagents = list("tonic" = 50)
	foodtype = ALCOHOL

/obj/item/reagent_containers/food/drinks/soda_cans/sodawater
	name = "Soda Water"
	desc = "A can of soda water. Why not make a scotch and soda?"
	icon_state = "sodawater"
	list_reagents = list("sodawater" = 50)

/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime
	name = "Orange Soda"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	list_reagents = list("lemon_lime" = 30)
	foodtype = FRUIT

/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime/New()
	..()
	name = "Lemon-Lime Soda"

/obj/item/reagent_containers/food/drinks/soda_cans/space_up
	name = "Space-Up!"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	list_reagents = list("space_up" = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	list_reagents = list("cola" = 15, "orangejuice" = 15)
	foodtype = SUGAR | FRUIT | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	list_reagents = list("spacemountainwind" = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko
	name = "Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkenness, or even death. Please Drink Responsibly."
	icon_state = "thirteen_loko"
	list_reagents = list("thirteenloko" = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
	list_reagents = list("dr_gibb" = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game
	name = "Pwr Game"
	desc = "The only drink with the PWR that true gamers crave."
	icon_state = "purple_can"
	list_reagents = list("pwr_game" = 30)

/obj/item/reagent_containers/food/drinks/soda_cans/shamblers
	name = "Shambler's Juice"
	desc = "~Shake me up some of that Shambler's Juice!~"
	icon_state = "shamblers"
	list_reagents = list("shamblers" = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/air
	name = "Canned Air"
	desc = "There is no air shortage. Do not drink."
	icon_state = "air"
	list_reagents = list("nitrogen" = 24, "oxygen" = 6)
