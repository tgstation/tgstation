////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	flags = FPRINT  | OPENCONTAINER
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	possible_transfer_amounts = list(5, 10, 25)
	volume = 50

	//Merged from bottle.dm - Hinaichigo
	var/const/duration = 13 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/isGlass = 0 //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

	//Molotov and smashing variables
	var/molotov = 0 //-1 = can be made into molotov, 0 = can't, 1 = has had rag stuffed into it
	var/lit = 0
	var/brightness_lit = 3
	var/bottleheight = 23 //To offset the molotov rag and fire - beer and ale are 23
	var/smashtext = "bottle of " //To handle drinking glasses and the flask of holy water
	var/smashname = "broken bottle" //As above
	var/viewcontents = 1
	var/flammable = 0
	var/flammin = 0
	var/flammin_color = null

/obj/item/weapon/reagent_containers/food/drinks/on_reagent_change()
	if(gulp_size < 5)
		gulp_size = 5
	else
		gulp_size = max(round(reagents.total_volume / 5), 5)
	if(reagents.has_reagent("blackcolor"))
		viewcontents = 0
	else
		viewcontents = 1

/obj/item/weapon/reagent_containers/food/drinks/attack_self(mob/user as mob)
	if(!is_open_container())
		to_chat(user, "<span class='warning'>You can't, \the [src] is closed.</span>")//Added this here and elsewhere to prevent drinking, etc. from closed drink containers. - Hinaichigo

		return 0

	else if(!src.reagents.total_volume || !src)
		to_chat(user, "<span class='warning'>\The [src] is empty.<span>")
		return 0

	else
		imbibe(user)
		return 0

/obj/item/weapon/reagent_containers/food/drinks/attack(mob/living/M as mob, mob/user as mob, def_zone)
	var/datum/reagents/R = src.reagents
	var/fillevel = gulp_size

	//Smashing on someone
	if(user.a_intent == I_HURT && isGlass && molotov != 1)  //To smash a bottle on someone, the user must be harm intent, the bottle must be out of glass, and we don't want a rag in here

		if(!M) //This really shouldn't be checked here, but sure
			return

		force = 15 //Smashing bottles over someoen's head hurts. //todo: check that this isn't overwriting anything it shouldn't be

		var/datum/organ/external/affecting = user.zone_sel.selecting //Find what the player is aiming at

		var/armor_block = 0 //Get the target's armour values for normal attack damage.
		var/armor_duration = 0 //The more force the bottle has, the longer the duration.

		//Calculating duration and calculating damage.
		if(ishuman(M))

			var/mob/living/carbon/human/H = M
			var/headarmor = 0 // Target's head armour
			armor_block = H.run_armor_check(affecting, "melee") // For normal attack damage

			//If they have a hat/helmet and the user is targeting their head.
			if(istype(H.head, /obj/item/clothing/head) && affecting == "head")

				// If their head has an armour value, assign headarmor to it, else give it 0.
				if(H.head.armor["melee"])
					headarmor = H.head.armor["melee"]
				else
					headarmor = 0
			else
				headarmor = 0

			//Calculate the weakening duration for the target.
			armor_duration = (duration - headarmor) + force

		else
			//Only humans can have armour, right?
			armor_block = M.run_armor_check(affecting, "melee")
			if(affecting == "head")
				armor_duration = duration + force
		armor_duration /= 10

		//Apply the damage!
		M.apply_damage(force, BRUTE, affecting, armor_block)

		// You are going to knock someone out for longer if they are not wearing a helmet.
		// For drinking glass
		if(affecting == "head" && istype(M, /mob/living/carbon/))

			//Display an attack message.
			for(var/mob/O in viewers(user, null))
				if(M != user) O.show_message(text("<span class='danger'>[M] has been hit over the head with a [smashtext][src.name], by [user]!</span>"), 1)
				else O.show_message(text("<span class='danger'>[M] hit himself with a [smashtext][src.name] on the head!</span>"), 1)
			//Weaken the target for the duration that we calculated and divide it by 5.
			if(armor_duration)
				M.apply_effect(min(armor_duration, 10) , WEAKEN) // Never weaken more than a flash!

		else
			//Default attack message and don't weaken the target.
			for(var/mob/O in viewers(user, null))
				if(M != user) O.show_message(text("<span class='danger'>[M] has been attacked with a [smashtext][src.name], by [user]!</span>"), 1)
				else O.show_message(text("<span class='danger'>[M] has attacked himself with a [smashtext][src.name]!</span>"), 1)

		//Attack logs
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has attacked [M.name] ([M.ckey]) with a bottle!</font>")
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been smashed with a bottle by [user.name] ([user.ckey])</font>")
		log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] with a bottle. ([M.ckey])</font>")
		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user

		//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
		if(src.reagents)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("<span class='bnotice'>The contents of \the [smashtext][src] splashes all over [M]!</span>"), 1)
			src.reagents.reaction(M, TOUCH)

		//Finally, smash the bottle. This kills (del) the bottle.
		src.smash(M, user)

		return

	else if(!is_open_container())
		to_chat(user, "<span class='warning'>You can't, \the [src] is closed.</span>")//Added this here and elsewhere to prevent drinking, etc. from closed drink containers. - Hinaichigo

		return 0

	else if(!R.total_volume || !R)
		to_chat(user, "<span class='warning'>\The [src] is empty.<span>")
		return 0

	else if(M == user)
		imbibe(user)
		return 0

	else if(istype(M, /mob/living/carbon/human))

		user.visible_message("<span class='danger'>[user] attempts to feed [M] \the [src].</span>", "<span class='danger'>You attempt to feed [M] \the [src].</span>")

		if(!do_mob(user, M))
			return

		user.visible_message("<span class='danger'>[user] feeds [M] \the [src].</span>", "<span class='danger'>You feed [M] \the [src].</span>")

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
		log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user

		if(reagents.total_volume)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.species.chem_flags & NO_DRINK)
					reagents.reaction(get_turf(H), TOUCH)
					H.visible_message("<span class='warning'>The contents in [src] fall through and splash onto the ground, what a mess!</span>")
					return 0

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


/obj/item/weapon/reagent_containers/food/drinks/afterattack(var/atom/target, var/mob/user, var/adjacency_flag, var/click_params)
	if (!adjacency_flag)
		return

	// Attempt to transfer to our glass
	if (transfer(target, user, can_send = FALSE, can_receive = TRUE))
		return

	// Attempt to transfer from our glass
	var/refill_id = reagents.get_master_reagent_id()
	var/refill_name = reagents.get_master_reagent_name()

	var/sent_amount = transfer(target, user, can_send = TRUE, can_receive = FALSE)

	// Service borgs regenerate the amount transferred after a while
	// TODO Why doesn't the borg module handle this nonsense?
	if (sent_amount > 0 && isrobot(user))
		var/mob/living/silicon/robot/borg = user
		if (!istype(borg.module, /obj/item/weapon/robot_module/butler) || !borg.cell)
			return

		var/charge_amount = max(30, 4*sent_amount)
		borg.cell.use(charge_amount)

		to_chat(user, "Now synthesizing [sent_amount] units of [refill_name]...")
		spawn(300)
			reagents.add_reagent(refill_id, sent_amount)
			to_chat(user, "<span class='notice'>Cyborg [src] refilled with [refill_name] ([sent_amount] units).</span>")

/obj/item/weapon/reagent_containers/food/drinks/examine(mob/user)

	if(viewcontents)
		..()
	else
		to_chat(user, "\icon[src] That's \a [src].")
		to_chat(user, desc)
		to_chat(user, "<span class='info'>You can't quite make out its content!</span>")

	if(!reagents || reagents.total_volume == 0)
		to_chat(user, "<span class='info'>\The [src] is empty!</span>")
	else if (reagents.total_volume <= src.volume/4)
		to_chat(user, "<span class='info'>\The [src] is almost empty!</span>")
	else if (reagents.total_volume <= src.volume*0.66)
		to_chat(user, "<span class='info'>\The [src] is about half full, or about half empty!</span>")
	else if (reagents.total_volume <= src.volume*0.90)
		to_chat(user, "<span class='info'>\The [src] is almost full!</span>")
	else
		to_chat(user, "<span class='info'>\The [src] is full!</span>")

/obj/item/weapon/reagent_containers/food/drinks/proc/imbibe(mob/user) //Drink the liquid within


	to_chat(user, "<span  class='notice'>You swallow a gulp of \the [src].[lit ? " It's hot!" : ""]</span>")
	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)

	if(lit)
		user.bodytemperature += 30 * TEMPERATURE_DAMAGE_COEFFICIENT//only the first gulp will be hot.

	if(isrobot(user))
		reagents.remove_any(gulp_size)
		return 1
	if(reagents.total_volume)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.species.chem_flags & NO_DRINK)
				reagents.reaction(get_turf(H), TOUCH)
				H.visible_message("<span class='warning'>The contents in [src] fall through and splash onto the ground, what a mess!</span>")
				return 0

		reagents.reaction(user, INGEST)
		spawn(5)
			reagents.trans_to(user, gulp_size)

	update_brightness()
	return 1

/obj/item/weapon/reagent_containers/food/drinks/New()
	..()

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
	flags = FPRINT  | OPENCONTAINER
	siemens_coefficient = 1

/obj/item/weapon/reagent_containers/food/drinks/golden_cup/tournament_26_06_2011
	desc = "A golden cup. It will be presented to a winner of tournament 26 june and name of the winner will be graved on it."


///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.

/obj/item/weapon/reagent_containers/food/drinks/milk
	name = "space milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "carton"
	vending_cat = "dairy products"
/obj/item/weapon/reagent_containers/food/drinks/milk/New()
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
/obj/item/weapon/reagent_containers/food/drinks/flour/New()
	..()
	reagents.add_reagent("flour", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soymilk
	name = "soy milk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	item_state = "carton"
	vending_cat = "dairy products"//it's not a dairy product but oh come on who cares
/obj/item/weapon/reagent_containers/food/drinks/soymilk/New()
	..()
	reagents.add_reagent("soymilk", 50)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)


/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
/obj/item/weapon/reagent_containers/food/drinks/coffee/New()
	..()
	reagents.add_reagent("coffee", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/tea
	name = "Duke Purple Tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "tea"
	item_state = "coffee"
/obj/item/weapon/reagent_containers/food/drinks/tea/New()
	..()
	reagents.add_reagent("tea", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/ice
	name = "Ice Cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "coffee"
/obj/item/weapon/reagent_containers/food/drinks/ice/New()
	..()
	reagents.add_reagent("ice", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate
	name = "Dutch Hot Coco"
	desc = "Made in Space South America."
	icon_state = "tea"
	item_state = "coffee"
/obj/item/weapon/reagent_containers/food/drinks/h_chocolate/New()
	..()
	reagents.add_reagent("hot_coco", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen
	name = "Cup Ramen"
	desc = "Just add 10ml water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/New()
	..()
	reagents.add_reagent("dry_ramen", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/groans
	name = "Groans Soda"
	desc = "Groans Soda: We'll make you groan."
	icon_state = "groans"
/obj/item/weapon/reagent_containers/food/drinks/groans/New()
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
/obj/item/weapon/reagent_containers/food/drinks/filk/New()
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
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo/New()
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
			reagents.add_reagent("tequila", 10)
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
/obj/item/weapon/reagent_containers/food/drinks/groansbanned/New()
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
/obj/item/weapon/reagent_containers/food/drinks/mannsdrink/New()
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
	to_chat(user, "Now spawning groans.")
	var/turf/T = get_turf(user.loc)
	var/obj/item/weapon/reagent_containers/food/drinks/groans/A = new /obj/item/weapon/reagent_containers/food/drinks/groans(T)
	A.desc += " It also smells like a toddler." //This is required

/obj/item/weapon/reagent_containers/food/drinks/discount_ramen_hot
	name = "\improper Discount Dan's Noodle Soup"
	desc = "Discount Dan is proud to introduce his own take on noodle soups, with this on the go treat! Simply pull the tab, and a self heating mechanism activates!"
	icon_state = "ramen"
	var/list/ddname = list("Discount Deng's Quik-Noodles - Sweet and Sour Lo Mein Flavor","Frycook Dan's Quik-Noodles - Curly Fry Ketchup Hoedown Flavor","Rabatt Dan's Snabb-Nudlar - Inkokt Lax Sm?rg?sbord Smak","Discount Deng's Quik-Noodles - Teriyaki TVP Flavor","Sconto Danilo's Quik-Noodles - Italian Strozzapreti Lunare Flavor")
/obj/item/weapon/reagent_containers/food/drinks/discount_ramen_hot/New()
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
	var/list/ddname = list("Discount Deng's Quik-Noodles - Sweet and Sour Lo Mein Flavor","Frycook Dan's Quik-Noodles - Curly Fry Ketchup Hoedown Flavor","Rabatt Dan's Snabb-Nudlar - Inkokt Lax Sm?rg?sbord Smak","Discount Deng's Quik-Noodles - Teriyaki TVP Flavor","Sconto Danilo's Quik-Noodles - Italian Strozzapreti Lunare Flavor")
/obj/item/weapon/reagent_containers/food/drinks/discount_ramen/New()
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
	to_chat(user, "You pull the tab, you feel the drink heat up in your hands, and its horrible fumes hits your nose like a ton of bricks. You drop the soup in disgust.")
	var/turf/T = get_turf(user.loc)
	var/obj/item/weapon/reagent_containers/food/drinks/discount_ramen_hot/A = new /obj/item/weapon/reagent_containers/food/drinks/discount_ramen_hot(T)
	A.desc += " It feels warm.." //This is required
	user.drop_from_inventory(src)
	del(src)



/obj/item/weapon/reagent_containers/food/drinks/beer
	name = "Space Beer"
	desc = "Beer. In space."
	icon_state = "beer"
	vending_cat = "fermented"
	molotov = -1 //can become a molotov
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/beer/New()
	..()
	reagents.add_reagent("beer", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	item_state = "beer"
	vending_cat = "fermented"
	molotov = -1 //can become a molotov
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/ale/New()
	..()
	reagents.add_reagent("ale", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans
	vending_cat = "carbonated drinks"

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola
	name = "Space Cola"
	desc = "Cola. in space."
	icon_state = "cola"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola/New()
	..()
	reagents.add_reagent("cola", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/tonic
	name = "T-Borg's Tonic Water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/tonic/New()
	..()
	reagents.add_reagent("tonic", 50)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sodawater
	name = "Soda Water"
	desc = "A can of soda water. Why not make a scotch and soda?"
	icon_state = "sodawater"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sodawater/New()
	..()
	reagents.add_reagent("sodawater", 50)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime
	name = "Lemon-Lime"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/lemon_lime/New()
	..()
	reagents.add_reagent("lemon_lime", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up
	name = "Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_up/New()
	..()
	reagents.add_reagent("space_up", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/starkist/New()
	..()
	reagents.add_reagent("cola", 15)
	reagents.add_reagent("orangejuice", 15)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/space_mountain_wind/New()
	..()
	reagents.add_reagent("spacemountainwind", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/thirteenloko
	name = "Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkeness, or even death. Please Drink Responsably."
	icon_state = "thirteen_loko"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/thirteenloko/New()
	..()
	reagents.add_reagent("thirteenloko", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/dr_gibb/New()
	..()
	reagents.add_reagent("dr_gibb", 30)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/nuka
	name = "Nuka Cola"
	desc = "Cool, refreshing, Nuka Cola."
	icon_state = "nuka"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/nuka/New()
	..()
	reagents.add_reagent("nuka_cola", 30)
	src.pixel_x = rand(-10, 10)
	src.pixel_y = rand(-10, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/quantum
	name = "Nuka Cola Quantum"
	desc = "Take the leap... enjoy a Quantum!"
	icon_state = "quantum"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/quantum/New()
	..()
	reagents.add_reagent("quantum", 30)
	src.pixel_x = rand(-10, 10)
	src.pixel_y = rand(-10, 10)

/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sportdrink
	name = "Brawndo"
	icon_state = "brawndo"
	desc = "It has what plants crave! Electrolytes!"
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sportdrink/New()
	..()
	reagents.add_reagent("sportdrink", 30)
	src.pixel_x = rand(-10, 10)
	src.pixel_y = rand(-10, 10)

/obj/item/weapon/reagent_containers/food/drinks/coloring
	name = "Vial of Food Coloring"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "vial"
	volume = 25
	possible_transfer_amounts = list(1,5)
/obj/item/weapon/reagent_containers/food/drinks/coloring/New()
	..()
	reagents.add_reagent("blackcolor", 25)
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/sillycup
	name = "Paper Cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = null
	volume = 10
/obj/item/weapon/reagent_containers/food/drinks/sillycup/New()
	..()
	src.pixel_x = rand(-10.0, 10)
	src.pixel_y = rand(-10.0, 10)
/obj/item/weapon/reagent_containers/food/drinks/sillycup/on_reagent_change()
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
	desc = "A cup with the British flag emblazoned on it."
	icon_state = "britcup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/americup
	name = "cup"
	desc = "A cup with the American flag emblazoned on it."
	icon_state = "americup"
	volume = 30

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom


/obj/item/weapon/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	starting_materials = list(MAT_GLASS = 500)
	bottleheight = 31
	melt_temperature = MELTPOINT_GLASS
	w_type=RECYK_GLASS

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/weapon/broken_bottle

	name = "broken bottle" // changed to lowercase - Hinaichigo
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	sharpness = 0.8 //same as glass shards
	w_class = 1
	item_state = "beer"
	attack_verb = list("stabbed", "slashed", "attacked")
	var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")
	starting_materials = list(MAT_GLASS = 500)
	melt_temperature = MELTPOINT_GLASS
	w_type=RECYK_GLASS

/obj/item/weapon/broken_bottle/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()


/obj/item/weapon/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	vending_cat = "spirits"
	bottleheight = 30
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/gin/New()
	..()
	reagents.add_reagent("gin", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey/New()
	..()
	reagents.add_reagent("whiskey", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka/New()
	..()
	reagents.add_reagent("vodka", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/tequila
	name = "Caccavo Guaranteed Quality Tequila"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequilabottle"
	vending_cat = "spirits"
	isGlass = 1
	molotov = -1
/obj/item/weapon/reagent_containers/food/drinks/bottle/tequila/New()
	..()
	reagents.add_reagent("tequila", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing"
	icon_state = "bottleofnothing"
	isGlass = 1
	molotov = -1
	smashtext = ""
/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing/New()
	..()
	reagents.add_reagent("nothing", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequila, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	bottleheight = 26 //has a cork but for now it goes on top of the cork
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/patron/New()
	..()
	reagents.add_reagent("patron", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	vending_cat = "spirits"
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/rum/New()
	..()
	reagents.add_reagent("rum", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	vending_cat = "fermented"
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth/New()
	..()
	reagents.add_reagent("vermouth", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK"
	icon_state = "kahluabottle"
	vending_cat = "fermented"
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua/New()
	..()
	reagents.add_reagent("kahlua", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager/New()
	..()
	reagents.add_reagent("goldschlager", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	vending_cat = "spirits"
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac/New()
	..()
	reagents.add_reagent("cognac", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	vending_cat = "fermented"
	bottleheight = 30
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/wine/New()
	..()
	reagents.add_reagent("wine", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe
	name = "Jailbreaker Verte"
	desc = "One sip of this and you just know you're gonna have a good time."
	icon_state = "absinthebottle"
	bottleheight = 27
	molotov = -1
	isGlass = 1
/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe/New()
	..()
	reagents.add_reagent("absinthe", 100)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	item_state = "carton"
	vending_cat = "fruit juices"
	starting_materials = null

/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice/New()
	..()
	reagents.add_reagent("orangejuice", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	item_state = "carton"
	vending_cat = "dairy products"
	starting_materials = null

/obj/item/weapon/reagent_containers/food/drinks/bottle/cream/New()
	..()
	reagents.add_reagent("cream", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	item_state = "carton"
	vending_cat = "fruit juices"
	starting_materials = null

/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice/New()
	..()
	reagents.add_reagent("tomatojuice", 100)


/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	item_state = "carton"
	vending_cat = "fruit juices"
	starting_materials = null

/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice/New()
	..()
	reagents.add_reagent("limejuice", 100)





/obj/item/weapon/reagent_containers/food/drinks/proc/smash(mob/living/M as mob, mob/living/user as mob)


	if(molotov == 1) //for molotovs
		if(lit)
			new /obj/effect/decal/cleanable/ash(get_turf(src))
		else
			new /obj/item/weapon/reagent_containers/glass/rag(get_turf(src))

	//Creates a shattering noise and replaces the bottle with a broken_bottle
	user.drop_item()
	var/obj/item/weapon/broken_bottle/B = new /obj/item/weapon/broken_bottle(user.loc)
	B.icon_state = src.icon_state
	B.force = src.force
	B.name = src.smashname

	if(istype(src, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass))  //for drinking glasses
		B.icon_state = "glass_empty"

	if(prob(33))
		getFromPool(/obj/item/weapon/shard, get_turf(M)) // Create a glass shard at the target's location!

	var/icon/I = new('icons/obj/drinks.dmi', B.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	user.put_in_active_hand(B)
	src.transfer_fingerprints_to(B)
	playsound(src, "shatter", 70, 1)

	del(src)

//smashing when thrown
/obj/item/weapon/reagent_containers/food/drinks/throw_impact(atom/hit_atom)
	..()
	if(isGlass)
		isGlass = 0 //to avoid it from hitting the wall, then hitting the floor, which would cause two broken bottles to appear
		src.visible_message("<span  class='warning'>The [smashtext][src.name] shatters!</span>","<span  class='warning'>You hear a shatter!</span>")
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		if(reagents.total_volume)
			src.reagents.reaction(hit_atom, TOUCH)  //maybe this could be improved?
			spawn(5) src.reagents.clear_reagents()  //maybe this could be improved?
		invisibility = INVISIBILITY_MAXIMUM  //so it stays a while to ignite any fuel

		if(molotov == 1) //for molotovs
			if(lit)
				new /obj/effect/decal/cleanable/ash(get_turf(src))
				var/turf/loca = get_turf(src)
				if(loca)
//					to_chat(world, "<span  class='warning'>Burning...</span>")
					loca.hotspot_expose(700, 1000,surfaces=istype(loc,/turf))
			else
				new /obj/item/weapon/reagent_containers/glass/rag(get_turf(src))


		//create new broken bottle
		var/obj/item/weapon/broken_bottle/B = new /obj/item/weapon/broken_bottle(loc)
		B.force = src.force
		B.name = src.smashname
		B.icon_state = src.icon_state

		if(istype(src, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass))  //for drinking glasses
			B.icon_state = "glass_empty"

		if(prob(33))
			getFromPool(/obj/item/weapon/shard, get_turf(src)) // Create a glass shard at the hit location!

		var/icon/Q = new('icons/obj/drinks.dmi', B.icon_state)
		Q.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
		Q.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
		B.icon = Q
		src.transfer_fingerprints_to(B)


		spawn(50)
			del(src)



//////////////////////
// molotov cocktail //
//  by Hinaichigo   //
//////////////////////

/obj/item/weapon/reagent_containers/food/drinks/attackby(var/obj/item/I, mob/user as mob)
	if(istype(I, /obj/item/weapon/reagent_containers/glass/rag) && molotov == -1)  //check if it is a molotovable drink - just beer and ale for now - other bottles require different rag overlay positions - if you can figure this out then go for it
		to_chat(user, "<span  class='notice'>You stuff the [I] into the mouth of the [src].</span>")
		del(I)
		molotov = 1
		flags ^= OPENCONTAINER
		name = "incendiary cocktail"
		smashtext = ""
		desc = "A rag stuffed into a bottle."
		update_icon()
		slot_flags = SLOT_BELT
	else if(I.is_hot())
		light(user,I)
		update_brightness(user)
	else if(istype(I, /obj/item/device/assembly/igniter))
		var/obj/item/device/assembly/igniter/C = I
		C.activate()
		light(user,I)
		update_brightness(user)
		return

/obj/item/weapon/reagent_containers/food/drinks/proc/light(mob/user,obj/item/I)
	var/flavor_text = "<span  class='rose'>[user] lights \the [name] with \the [I].</span>"
	if(!lit && molotov == 1)
		lit = 1
		visible_message(flavor_text)
		processing_objects.Add(src)
		update_icon()
	if(!lit && flammable)
		lit = 1
		visible_message(flavor_text)
		flammable = 0
		name = "Flaming [name]"
		desc += " Damn that looks hot!"
		icon_state += "-flamin"
		update_icon()

/obj/item/weapon/reagent_containers/food/drinks/proc/update_brightness(var/mob/user = null)
	if(lit)
		set_light(src.brightness_lit)
	else
		set_light(0)

/obj/item/weapon/reagent_containers/food/drinks/update_icon()
	src.overlays.len = 0
	var/image/Im
	if(molotov == 1)
		Im = image('icons/obj/grenade.dmi', icon_state = "molotov_rag")
		Im.pixel_y += src.bottleheight-23 //since the molotov rag and fire are placed one pixel above the mouth of the bottle, and start out at a height of 23 (for beer and ale)
		overlays += Im
	if(molotov == 1 && lit)
		Im = image('icons/obj/grenade.dmi', icon_state = "molotov_fire")
		Im.pixel_y += src.bottleheight-23
		overlays += Im
	else
		item_state = initial(item_state)
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		H.update_inv_belt()

	return


/obj/item/weapon/reagent_containers/food/drinks/process()
	var/turf/loca = get_turf(src)
	if(lit && loca)
//		to_chat(world, "<span  class='warning'>Burning...</span>")
		loca.hotspot_expose(700, 1000,surfaces=istype(loc,/turf))
	return


//todo: can light cigarettes with
//todo: is force = 15 overwriting the force?

////////  Could be expanded upon:
//  make it work with more chemicals and reagents, more like a chem grenade
//  only allow the bottle to be stuffed if there are certain reagents inside, like fuel
//  different flavor text for different means of lighting
//  new fire overlay - current is edited version of the IED one
//  a chance to not break, if desired
//  fingerprints appearing on the object, which might already happen, and the shard
//  belt sprite and new hand sprite
//	ability to put out with water or otherwise
//	burn out after a time causing the contents to ignite
//	make into its own item type so they could be spawned full of fuel with New()
//  colored light instead of white light
//	the rag can store chemicals as well so maybe the rag's chemicals could react with the bottle's chemicals before or upon breaking
//  somehow make it possible to wipe down the bottles instead of exclusively stuffing rags into them
//  make rag retain chemical properties or color (if implemented) after smashing
////////
