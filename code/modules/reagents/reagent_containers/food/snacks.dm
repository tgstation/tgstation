//Food items that are eaten normally and don't leave anything behind.

/obj/item/weapon/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon = 'icons/obj/food.dmi'
	icon_state = null

	var/food_flags	//Possible flags: FOOD_LIQUID, FOOD_MEAT, FOOD_ANIMAL, FOOD_SWEET
					//FOOD_LIQUID	- for stuff like soups
					//FOOD_MEAT		- stuff that is made from (or contains) meat. Anything that vegetarians won't eat!
					//FOOD_ANIMAL	- stuff that is made from (or contains) animal products other than meat (eggs, honey, ...). Anything that vegans won't eat!
					//FOOD_SWEET	- sweet stuff like chocolate and candy

					//Example: food_flags = FOOD_SWEET | FOOD_ANIMAL
					//Unfortunately, food created by cooking doesn't inherit food_flags!

	var/bitesize = 1 //How much reagents per bite (and thus how fast is the food consumed ?)
	var/bitecount = 0 //How much times was the item bitten ?
	var/trash = null //What left-over should we spawn, if any ?
	var/slice_path //What can we slice this item into, if anything ?
	var/slices_num //How much slices should we expect ?
	var/eatverb //How do I eat thing ? (Note : Used for message, "bite", "chew", etc...)
	var/wrapped = 0 //Is the food wrapped (preventing one from eating until unwrapped)
	var/dried_type = null //What can we dry the food into
	var/deepfried = 0 //Is the food deep-fried ?
	var/filling_color = "#FFFFFF" //What color would a filling of this item be ?
	volume = 100 //Double amount snacks can carry, so that food prepared from excellent items can contain all the nutriments it deserves

//Proc for effects that trigger on eating that aren't directly tied to the reagents.
/obj/item/weapon/reagent_containers/food/snacks/proc/On_Consume(var/mob/user)
	if(!user)
		return
	if(!reagents.total_volume) //Are we done eating (determined by the amount of reagents left, here 0)
		user.visible_message("<span class='notice'>[user] finishes eating \the [src].</span>", \
		"<span class='notice'>You finish eating \the [src].</span>")
		score["foodeaten"]++ //For post-round score
		user.drop_from_inventory(src) //Drop our item before we delete it

		if(trash) //Do we have somehing defined as trash for our snack item ?
			//Note : This makes sense in some way, or at least this works, just don't mess with it
			if(ispath(trash, /obj/item))
				var/obj/item/TrashItem = new trash(user)
				user.put_in_hands(TrashItem)
			else if(istype(trash, /obj/item))
				user.put_in_hands(trash)

		del(src) //Remove the item, we consumed it

	return

/obj/item/weapon/reagent_containers/food/snacks/attack_self(mob/user)

	attack(user, user) //This is painful, but it works, I guess
	return

/obj/item/weapon/reagent_containers/food/snacks/New()

	..()

/obj/item/weapon/reagent_containers/food/snacks/attack(mob/living/M, mob/user, def_zone, eat_override = 0)	//M is target of attack action, user is the one initiating it
	if(!eatverb)
		eatverb = pick("bite", "chew", "nibble", "gnaw", "gobble", "chomp")
	if(!reagents.total_volume)	//Are we done eating (determined by the amount of reagents left, here 0)
		//This is mostly caused either by "persistent" food items or spamming
		to_chat(user, "<span class='notice'>There's nothing left of \the [src]!</span>")
		M.drop_from_inventory(src)	//Drop our item before we delete it
		del(src)
		return 0

	if(istype(M, /mob/living/carbon)) //Avoid messing with simple mobs
		var/mob/living/carbon/target = M //First definition to avoid colons
		if(target == user)	//If you're eating it yourself
			//In that case, target is the user, but we'll still ask "target" to do things
			if(!target.hasmouth)
				to_chat(user, "<span class='warning'>You have no mouth to eat with</span>")//Good luck figuring out how that would happen

				return 0
			var/fullness = target.nutrition + (target.reagents.get_reagent_amount("nutriment") * 25) //This reminds me how unlogical mob nutrition is
			if(wrapped)
				to_chat(target, "<span class='warning'>You can't eat wrapped food!</span>")
				return 0
			if (!eat_override && ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.species.chem_flags & NO_EAT)
					user.drop_from_inventory(src)
					src.forceMove(get_turf(H))
					playsound(get_turf(H),'sound/items/eatfood.ogg', rand(10,50), 1)
					H.visible_message("<span class='warning'>As [M] attempts to eat \the [src] it falls through and onto the ground as if untouched.</span>", "<span class='notice'>As you attempt to eat \the [src] it falls through your body and onto the ground as if untouched.</span>")
					return 0
			if(fullness <= 50)
				target.visible_message("<span class='notice'>[target] hungrily [eatverb]s some of \the [src] and gobbles it down!</span>", \
				"<span class='notice'>You hungrily [eatverb] some of \the [src] and gobble it down!</span>")
			else if(fullness > 50 && fullness < 150)
				target.visible_message("<span class='notice'>[target] hungrily [eatverb]s \the [src].</span>", \
				"<span class='notice'>You hungrily [eatverb] \the [src].</span>")
			else if(fullness > 150 && fullness < 350)
				target.visible_message("<span class='notice'>[target] [eatverb]s \the [src].</span>", \
				"<span class='notice'>You [eatverb] \the [src].</span>")
			else if(fullness > 350 && fullness < 550)
				target.visible_message("<span class='notice'>[target] unwillingly [eatverb]s some of \the [src].</span>", \
				"<span class='notice'>You unwillingly [eatverb] some of \the [src].</span>")
			else if(fullness > (550 * (1 + M.overeatduration / 2000)))	// The more you eat - the more you can eat
				to_chat(target, "<span class='notice'>You cannot force any more of \the [src] to go down your throat.</span>")
				return 0
		else //Feeding someone else, target is eating, user is feeding
			if(target.hasmouth)
				var/fullness = target.nutrition + (target.reagents.get_reagent_amount("nutriment") * 25)
				if(wrapped)
					to_chat(user, "<span class='warning'>The food is wrapped, you can't feed it to [target] like that!</span>")
					return 0
				if(fullness <= (550 * (1 + M.overeatduration / 1000))) //The mob will accept
					target.visible_message("<span class='danger'>[user] attempts to feed [target] \the [src].</span>", \
					"<span class='userdanger'>[user] attempts to feed you \the [src].</span>")
				else //The mob is overfed and will refuse
					target.visible_message("<span class='danger'>[user] cannot force anymore of \the [src] down [target]'s throat!</span>", \
					"<span class='userdanger'>[user] cannot force anymore of \the [src] down your throat!</span>")
					return 0

				if(!do_mob(user, target))
					return
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.species.chem_flags & NO_EAT)
						user.drop_from_inventory(src)
						src.forceMove(get_turf(H))
						H.visible_message("<span class='warning'>As [user] attempts to feed [M] \the [src] it falls through and onto the ground as if untouched.</span>", "<span class='notice'>As [user] attempts to feed you \the [src] it falls through your body and onto the ground as if untouched.</span>")
						return 0

				add_logs(user, target, "fed", object="[reagentlist(src)]")
				target.visible_message("<span class='danger'>[user] feeds [target] \the [src].</span>", \
				"<span class='userdanger'>[user] feeds you \the [src].</span>")

			else
				to_chat(user, "<span class='warning'>[target] doesn't seem to have a mouth. Awkward!</span>")
				return

		if(reagents)	//Handle ingestion of any reagents (Note : Foods always have reagents)
			playsound(target.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
			if(reagents.total_volume)
				reagents.reaction(target, INGEST)
				spawn(5)
					if(reagents.total_volume > bitesize)
						/*
						 * I totally cannot understand what this code supposed to do.
						 * Right now every snack consumes in 2 bites, my popcorn does not work right, so I simplify it. -- rastaf0
						var/temp_bitesize =  max(reagents.total_volume /2, bitesize)
						reagents.trans_to(target, temp_bitesize)
						*/
						reagents.trans_to(target, bitesize)
					else
						reagents.trans_to(target, reagents.total_volume)
					bitecount++
					On_Consume(target)
			return 1
	return 0

/obj/item/weapon/reagent_containers/food/snacks/examine(mob/user)
	..()
	if (bitecount)
		if(bitecount == 1)
			to_chat(user, "<span class='info'>\The [src] was bitten by someone!</span>")
		else if(bitecount > 1 && bitecount <= 3)
			to_chat(user, "<span class='info'>\The [src] was bitten [bitecount] times!</span>")
		else
			to_chat(user, "<span class='info'>\The [src] was bitten multiple times!</span>")

/obj/item/weapon/reagent_containers/food/snacks/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/pen)) //Renaming food
		var/n_name = copytext(sanitize(input(user, "What would you like to name this dish?", "Food Renaming", null) as text|null), 1, MAX_NAME_LEN*3)
		if(n_name && Adjacent(user) && !user.stat)
			name = "[n_name]"
		return
	if(istype(W, /obj/item/weapon/kitchen/utensil/fork))
		var/obj/item/weapon/kitchen/utensil/fork/fork = W
		if(slices_num || slice_path)
			to_chat(user, "<span class='notice'>You can't take the whole [src] at once!.</span>")
			return
		else
			return fork.load_food(src, user)

	if (..()) return

	if((slices_num <= 0 || !slices_num) || !slice_path) //If the food item isn't sliceable, we have no more business to do here, return
		return 0

	if(W.w_class <= 2 && W.is_sharp() < 0.8 && !istype(W,/obj/item/device/analyzer/plant_analyzer)) //Make sure the item is valid to attempt slipping shit into it
		if(!iscarbon(user))
			return 0
		to_chat(user, "<span class='notice'>You slip \the [W] inside [src].</span>")
		user.drop_item(W, src)
		add_fingerprint(user)
		contents += W
		return 1 //No afterattack here

	if(W.is_sharp() < 0.8) //At this point we are slicing food, so if our item isn't sharp enough, just abort
		return 0

	if(!isturf(src.loc) || !(locate(/obj/structure/table) in src.loc) && !(locate(/obj/item/weapon/tray) in src.loc))
		to_chat(user, "<span class='notice'>You cannot slice \the [src] here! You need a table or at least a tray.</span>")
		return 1

	var/slices_lost = 0
	if(W.is_sharp() >= 1.2) //Actually sharp things are this sharp, yes
		user.visible_message("<span class='notice'>[user] slices \the [src].</span>", \
		"<span class='notice'>You slice \the [src].</span>")
	else //We're above 0.8 //The magic threshold of pizza slicing
		user.visible_message("<span class='notice'>[user] inaccurately slices \the [src] with \the [W]!</span>", \
		"<span class='notice'>You inaccurately slice \the [src] with \the [W]!</span>")
		slices_lost = rand(1, min(1, round(slices_num/2))) //Randomly lose a few slices along the way, but at least one and up to half
	var/reagents_per_slice = reagents.total_volume/slices_num //Figure out how much reagents each slice inherits (losing slices loses reagents)
	for(var/i = 1 to (slices_num - slices_lost)) //Transfer those reagents
		var/obj/slice = new slice_path(src.loc)
		if(istype(src, /obj/item/weapon/reagent_containers/food/snacks/customizable)) //custom sliceable foods have overlays we need to apply
			var/obj/item/weapon/reagent_containers/food/snacks/customizable/C = src
			var/obj/item/weapon/reagent_containers/food/snacks/customizable/S = slice
			S.name = "[C.name][S.name]"
			S.filling.color = C.filling.color
			S.overlays += S.filling
		reagents.trans_to(slice, reagents_per_slice)
	qdel(src) //So long and thanks for all the fish
	return 1

/obj/item/weapon/reagent_containers/food/snacks/Destroy()
	if(contents) //Did someone slip shit in the pizza again ?
		for(var/atom/movable/surprise in contents) //Find it
			surprise.loc = get_turf(src) //Recover it
	..()

/obj/item/weapon/reagent_containers/food/snacks/attack_animal(mob/M)
	if(isanimal(M))
		if(iscorgi(M)) //Feeding food to a corgi
			M.delayNextAttack(10)
			if(bitecount >= 4) //This really, really shouldn't be hardcoded like this, but sure I guess
				M.visible_message("[M] [pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where \the [src] was")].", "<span class='notice'>You swallow up the last of \the [src].")
				playsound(src.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
				var/mob/living/simple_animal/corgi/C = M
				if(C.health <= C.maxHealth + 5)
					C.health += 5
				else
					C.health = C.maxHealth
				del(src)
			else
				M.visible_message("[M] takes a bite of \the [src].", "<span class='notice'>You take a bite of \the [src].</span>")
				playsound(src.loc,'sound/items/eatfood.ogg', rand(10, 50), 1)
				bitecount++
		else if(ismouse(M)) //Mouse eating shit
			M.delayNextAttack(10)
			var/mob/living/simple_animal/mouse/N = M
			if(prob(25)) //We are noticed
				N.visible_message("[N] nibbles away at \the [src].", "You nibble away at \the [src]")
			else
				to_chat(N, ("<span class='notice'>You nibble away at \the [src].</span>"))
			N.health = min(N.health + 1, N.maxHealth)


////////////////////////////////////////////////////////////////////////////////
/// FOOD END
////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////
////////////////////////////////////////////Snacks
//////////////////////////////////////////////////
//Items in the "Snacks" subcategory are food items that people actually eat. The key points are that they are created
//	already filled with reagents and are destroyed when empty. Additionally, they make a "munching" noise when eaten.

//Notes by Darem: Food in the "snacks" subtype can hold a maximum of 50 units Generally speaking, you don't want to go over 40
//	total for the item because you want to leave space for extra condiments. If you want effect besides healing, add a reagent for
//	it. Try to stick to existing reagents when possible (so if you want a stronger healing effect, just use Tricordrazine). On use
//	effect (such as the old officer eating a donut code) requires a unique reagent (unless you can figure out a better way).

//The nutriment reagent and bitesize variable replace the old heal_amt and amount variables. Each unit of nutriment is equal to
//	2 of the old heal_amt variable. Bitesize is the rate at which the reagents are consumed. So if you have 6 nutriment and a
//	bitesize of 2, then it'll take 3 bites to eat. Unlike the old system, the contained reagents are evenly spread among all
//	the bites. No more contained reagents = no more bites.

//Here is an example of the new formatting for anyone who wants to add more food items.
///obj/item/weapon/reagent_containers/food/snacks/xenoburger			//Identification path for the object.
//	name = "Xenoburger"													//Name that displays in the UI.
//	desc = "Smells caustic. Tastes like heresy."						//Duh
//	icon_state = "xburger"												//Refers to an icon in food.dmi
//	food_flags = FOOD_MEAT												//For flavour, not that important. Flags are: FOOD_MEAT, FOOD_ANIMAL (for things that vegans don't eat), FOOD_SWEET, FOOD_LIQUID (soups). You can have multiple flags in here by doing this: food_flags = FOOD_MEAT | FOOD_SWEET
//
//	New()																//Don't mess with this.
//		..()															//Same here.
//		reagents.add_reagent("xenomicrobes", 10)						//This is what is in the food item. you may copy/paste
//		reagents.add_reagent("nutriment", 2)							//	this line of code for all the contents.
//		bitesize = 3													//This is the amount each bite consumes.




/obj/item/weapon/reagent_containers/food/snacks/aesirsalad
	name = "Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		eatverb = pick("crunch", "devour", "nibble", "gnaw", "gobble", "chomp")
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("tricordrazine", 8)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 1)
		reagents.add_reagent("sugar", 3)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/donor
	name = "Donor Candy"
	desc = "A little treat for blood donors."
	trash = /obj/item/trash/candy
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		reagents.add_reagent("sugar", 3)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Can be stored in a detective's hat."
	icon_state = "candy_corn"
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("sugar", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	New()
		..()
		reagents.add_reagent("nutriment", 5)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
	name = "chocolate bar"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolatebarunwrapped"
	wrapped = 0
	bitesize = 2
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 5)
		reagents.add_reagent("sugar", 5)
		reagents.add_reagent("coco", 5)

	attack_self(mob/user)
		if(wrapped)
			Unwrap(user)
		else
			..()

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/proc/Unwrap(mob/user)
		icon_state = "chocolatebarunwrapped"
		desc = "It won't make you all sticky."
		to_chat(user, "<span class='notice'>You remove the foil.</span>")
		wrapped = 0


/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped
	desc = "It's wrapped in some foil."
	icon_state = "chocolatebar"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg
	name = "chocolate egg"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolateegg"
	food_flags = FOOD_SWEET | FOOD_ANIMAL //eggs are used

	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("sugar", 2)
		reagents.add_reagent("coco", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	food_flags = FOOD_SWEET | FOOD_ANIMAL //eggs are used

/obj/item/weapon/reagent_containers/food/snacks/donut/normal
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("sprinkles", 1)
		src.bitesize = 3
		if(prob(30))
			src.icon_state = "donut2"
			src.name = "frosted donut"
			reagents.add_reagent("sprinkles", 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos
	name = "Chaos Donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut1"
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("sprinkles", 1)
		bitesize = 10
		switch(rand(1,10))
			if(1)
				reagents.add_reagent("nutriment", 3)
			if(2)
				reagents.add_reagent("capsaicin", 3)
			if(3)
				reagents.add_reagent("frostoil", 3)
			if(4)
				reagents.add_reagent("sprinkles", 3)
			if(5)
				reagents.add_reagent("plasma", 3)
			if(6)
				reagents.add_reagent("coco", 3)
			if(7)
				reagents.add_reagent("slimejelly", 3)
			if(8)
				reagents.add_reagent("banana", 3)
			if(9)
				reagents.add_reagent("berryjuice", 3)
			if(10)
				reagents.add_reagent("tricordrazine", 3)
		if(prob(30))
			icon_state = "donut2"
			name = "frosted chaos donut"
			reagents.add_reagent("sprinkles", 2)


/obj/item/weapon/reagent_containers/food/snacks/donut/jelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	bitesize = 5
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("sprinkles", 1)
		reagents.add_reagent("berryjuice", 5)
		if(prob(30))
			icon_state = "jdonut2"
			name = "Frosted Jelly Donut"
			reagents.add_reagent("sprinkles", 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	bitesize = 5
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("sprinkles", 1)
		reagents.add_reagent("slimejelly", 5)
		bitesize = 5
		if(prob(30))
			icon_state = "jdonut2"
			name = "Frosted Jelly Donut"
			reagents.add_reagent("sprinkles", 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	bitesize = 5
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("sprinkles", 1)
		reagents.add_reagent("cherryjelly", 5)
		if(prob(30))
			icon_state = "jdonut2"
			name = "Frosted Jelly Donut"
			reagents.add_reagent("sprinkles", 2)

// Eggs

/obj/item/weapon/reagent_containers/food/snacks/friedegg
	name = "fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	food_flags = FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("sodiumchloride", 1)
		reagents.add_reagent("blackpepper", 1)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/boiledegg
	name = "boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"
	food_flags = FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 2)

/*/obj/item/weapon/reagent_containers/food/snacks/flour //Has been converted into a reagent. Use that instead of the item!
	name = "flour"
	desc = "Some flour"
	icon_state = "flour"
	New()
		..()
		reagents.add_reagent("nutriment", 1)*/

/*
/obj/item/weapon/reagent_containers/food/snacks/appendix //yes, this is the same as meat. I might do something different in future
	name = "appendix"
	desc = "An appendix which looks perfectly healthy."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "appendix"
	New()
		..()
		reagents.add_reagent("nutriment", rand(3,5))
		reagents.add_reagent("toxin", rand(1,3))
		src.bitesize = 3
	*/

/obj/item/weapon/reagent_containers/food/snacks/organ
	name		=	"organ"
	desc		=	"It's good for you."
	icon		=	'icons/obj/surgery.dmi'
	icon_state	=	"appendix"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", rand(3,5))
		reagents.add_reagent("toxin",	rand(1,3))
		src.bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/tofu
	name = "Tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/tofurkey
	name = "Tofurkey"
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
	New()
		..()
		reagents.add_reagent("nutriment", 12)
		reagents.add_reagent("stoxin", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/stuffing
	name = "Stuffing"
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon_state = "stuffing"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("carpotoxin", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("psilocybin", 3)
		src.bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato"
	icon_state = "tomatomeat"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		src.bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("toxin", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/faggot
	name = "faggot"
	desc = "A great meal all round. Not a cord of wood."
	icon_state = "faggot"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 3)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	food_flags = FOOD_MEAT

	New()
		..()
		eatverb = pick("bite","chew","nibble","deep throat","gobble","chomp")
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 4)

	var/warm = 0
	proc/cooltime() //Not working, derp?
		if(warm)
			spawn(4200)	//ew
				warm = 0
				reagents.del_reagent("tricordrazine")
				name = initial(name)
		return

/obj/item/weapon/reagent_containers/food/snacks/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("alkysine", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/ghostburger
	name = "ghost burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/human
	var/hname = ""
	var/job = null


	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger/synth
	name = "synthetic burger"
	desc = "It tastes like a normal burger, but it's just not the same."
	icon_state = "hburger"
	New()
		..()
		reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/appendixburger
	name = "appendix burger"
	desc = "Tastes like appendicitis."
	icon_state = "hburger"
	food_flags = FOOD_MEAT
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fishburger
	name = "fillet -o- carp sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	food_flags = FOOD_MEAT
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("carpotoxin", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/tofuburger
	name = "tofu burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chickenburger
	name = "chicken burger"
	desc = "Tastes like chi...oh wait!"
	icon_state = "mc_chicken"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/chickenburger/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	New()
		..()
		reagents.add_reagent("nanites", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	volume = 100
	New()
		..()
		reagents.add_reagent("nanites", 100)
		bitesize = 0.1

/obj/item/weapon/reagent_containers/food/snacks/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	food_flags = FOOD_MEAT
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/clownburger
	name = "clown burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	New()
		..()
/*
		var/datum/disease/F = new /datum/disease/pierrot_throat(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 4, data)
*/
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mimeburger
	name = "mime burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/omelette	//FUCK THIS
	name = "omelette du fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	food_flags = FOOD_ANIMAL //made from eggs
	trash = /obj/item/trash/plate

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/muffin
	name = "muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"
	food_flags = FOOD_SWEET | FOOD_ANIMAL
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/muffin/berry
	name = "berry muffin"
	icon_state = "berrymuffin"
	desc = "A delicious and spongy little cake, with berries."

/obj/item/weapon/reagent_containers/food/snacks/muffin/booberry
	name = "booberry muffin"
	icon_state = "booberrymuffin"
	desc = "My stomach is a graveyard! No living being can quench my bloodthirst!"

/obj/item/weapon/reagent_containers/food/snacks/muffin/dindumuffin
	name = "Dindu Muffin"
	desc = "This muffin didn't do anything."
	icon_state = "dindumuffins"

/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("banana",5)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/pie_smudge(src.loc)
	new trash(src.loc)
	del(src)

/obj/item/weapon/reagent_containers/food/snacks/pie/empty //so the H.O.N.K. cream pie mortar can't generate free nutriment
	trash = null
	New()
		..()
		reagents.clear_reagents()

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/plate
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("berryjuice", 5)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles"
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	food_flags = FOOD_ANIMAL
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm
	name = "Eggplant Parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	name = "Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	name = "Soylen Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/discount
	name = "Discount Pie"
	icon_state = "meatpie"
	desc = "Regulatory laws prevent us from lying to you in the technical sense, so you know this has to contain at least some meat!"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("nutriment",2)
		reagents.add_reagent("discount",2)
		reagents.add_reagent("toxin",2)
		reagents.add_reagent("sugar",4)

/obj/item/weapon/reagent_containers/food/snacks/pie/meatpie
	name = "Meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/tofupie
	name = "Tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."

	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("nutriment", 5)
		reagents.add_reagent("amatoxin", 3)
		reagents.add_reagent("psilocybin", 1)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	New()
		..()
		reagents.clear_reagents()
		if(prob(10))
			name = "exceptional plump pie"
			desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
			reagents.add_reagent("nutriment", 8)
			reagents.add_reagent("tricordrazine", 5)
			bitesize = 2
		else
			reagents.add_reagent("nutriment", 8)
			bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/xemeatpie
	name = "Xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu
	name = "Wing Fang Chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/human/kabob
	name = "-kabob"
	icon_state = "kabob"
	desc = "A human meat, on a stick."
	trash = /obj/item/stack/rods
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeykabob
	name = "Meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeykabob/synth
	name = "Synth-kabob"
	icon_state = "kabob"
	desc = "Synthetic meat, on a stick."
	trash = /obj/item/stack/rods
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/corgikabob
	name = "Corgi-kabob"
	icon_state = "kabob"
	desc = "Only someone without a heart could make this."
	trash = /obj/item/stack/rods
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofukabob
	name = "Tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "Cuban Carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("carpotoxin", 3)
		reagents.add_reagent("capsaicin", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/popcorn
	name = "popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	var/unpopped = 0

/obj/item/weapon/reagent_containers/food/snacks/popcorn/New()
		..()
		eatverb = pick("bite","crunch","nibble","gnaw","gobble","chomp")
		unpopped = rand(1,10)
		reagents.add_reagent("nutriment", 2)
		bitesize = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0

/obj/item/weapon/reagent_containers/food/snacks/popcorn/On_Consume()
	if(prob(unpopped))	//lol ...what's the point? << AINT SO POINTLESS NO MORE
		to_chat(usr, "<span class='warning'>You bite down on an un-popped kernel, and it hurts your teeth!</span>")
		unpopped = max(0, unpopped-1)
		reagents.add_reagent("sacid", 0.1) //only a little tingle.


/obj/item/weapon/reagent_containers/food/snacks/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash = /obj/item/trash/sosjerky
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 4)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/no_raisin
	name = "4no raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins
	New()
		..()
		reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/bustanuts
	name = "Busta-Nuts"
	icon_state = "busta_nut"
	desc = "2hard4u"
	trash = /obj/item/trash/bustanuts
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("bustanut", 6)
		reagents.add_reagent("sodiumchloride", 6)

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie
	name = "space twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer than you will."
	New()
		..()
		reagents.add_reagent("sugar", 4)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers
	name = "Cheesie Honkers"
	icon_state = "cheesie_honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth"
	trash = /obj/item/trash/cheesie
	food_flags = FOOD_ANIMAL //cheese

	New()
		..()
		reagents.add_reagent("nutriment", 4)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/syndicake
	name = "Syndi-Cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	trash = /obj/item/trash/syndi_cakes
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("doctorsdelight", 5)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/discountchocolate
	name = "\improper Discount Dan's Chocolate Bar"
	desc = "Something tells you that the glowing green filling inside, isn't healthy."
	icon_state = "danbar"
	trash = /obj/item/trash/discountchocolate
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("discount", 4)
		reagents.add_reagent("moonrocks", 4)
		reagents.add_reagent("toxicwaste", 8)
		reagents.add_reagent("chemical_waste", 2) //Does nothing, but it's pretty fucking funny.
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/discountburger
	name = "\improper Discount Dan's On The Go Burger"
	desc = "Its still warm..."
	icon_state = "goburger" //Someone make a better sprite for this.
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("discount", 4)
		reagents.add_reagent("beff", 4)
		reagents.add_reagent("horsemeat", 4)
		reagents.add_reagent("offcolorcheese", 4)
		reagents.add_reagent("chemical_waste", 2) //Does nothing, but it's pretty fucking funny.
		bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/danitos
	name = "Danitos"
	desc = "For only the most MLG hardcore robust spessmen."
	icon_state = "danitos"
	trash = /obj/item/trash/danitos
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("discount", 4)
		reagents.add_reagent("bonemarrow", 4)
		reagents.add_reagent("toxicwaste", 8)
		reagents.add_reagent("bustanut", 2) //YOU FEELIN HARDCORE BRAH?
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/discountburrito
	name = "Discount Dan's Burritos"
	desc = "The perfect blend of cheap processing and cheap materials."
	icon_state = "danburrito"
	var/list/ddname = list("Spooky Dan's BOO-ritos - Texas Toast Chainsaw Massacre Flavor","Sconto Danilo's Burritos - 50% Real Mozzarella Pepperoni Pizza Party Flavor","Descuento Danito's Burritos - Pancake Sausage Brunch Flavor","Descuento Danito's Burritos - Homestyle Comfort Flavor","Spooky Dan's BOO-ritos - Nightmare on Elm Meat Flavor","Descuento Danito's Burritos - Strawberrito Churro Flavor","Descuento Danito's Burritos - Beff and Bean Flavor")
	food_flags = FOOD_MEAT

	New()
		..()
		name = pick(ddname)
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("discount", 6)
		reagents.add_reagent("irradiatedbeans", 4)
		reagents.add_reagent("refriedbeans", 4)
		reagents.add_reagent("mutatedbeans", 4)
		reagents.add_reagent("beff", 4)
		reagents.add_reagent("chemical_waste", 2) //Does nothing, but it's pretty fucking funny.
		bitesize = 2



/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato
	name = "Loaded Baked Potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fries
	name = "Space Fries"
	desc = "AKA: French Fries, Freedom Fries, etc"
	icon_state = "fries"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soydope
	name = "Soy Dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spaghetti
	name = "Spaghetti"
	desc = "Now thats a nice pasta!"
	icon_state = "spaghetti"
	New()
		..()
		reagents.add_reagent("nutriment", 1)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries
	name = "Cheesy Fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	trash = /obj/item/trash/plate
	food_flags = FOOD_ANIMAL //cheese

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	name = "Fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/badrecipe
	name = "Burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	New()
		..()
		reagents.add_reagent("toxin", 1)
		reagents.add_reagent("carbon", 3)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatsteak
	name = "Meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatstake"
	trash = /obj/item/trash/plate
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("sodiumchloride", 1)
		reagents.add_reagent("blackpepper", 1)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/synth
	name = "Synthmeat steak"
	desc = "It's still a delicious steak, but it has no soul."
	icon_state = "meatstake"
	trash = /obj/item/trash/plate
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("sodiumchloride", 1)
		reagents.add_reagent("blackpepper", 1)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff
	name = "Spacy Liberty Duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook"
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("psilocybin", 6)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	name = "Amanita Jelly"
	desc = "Looks curiously toxic"
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("amatoxin", 6)
		reagents.add_reagent("psilocybin", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "Poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bitesize = 2
	New()
		..()
		reagents.add_reagent("nutriment", 5)
		bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/meatballsoup
	name = "Meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_MEAT | FOOD_LIQUID

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("water", 5)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/slimesoup
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	food_flags = FOOD_LIQUID

	New()
		..()
		reagents.add_reagent("slimejelly", 5)
		reagents.add_reagent("water", 10)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/bloodsoup
	name = "Tomato soup"
	desc = "Smells like copper"
	icon_state = "tomatosoup"
	food_flags = FOOD_LIQUID

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("blood", 10)
		reagents.add_reagent("water", 5)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/clownstears
	name = "Clown's Tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	food_flags = FOOD_LIQUID | FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("banana", 5)
		reagents.add_reagent("water", 10)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/vegetablesoup
	name = "Vegetable soup"
	desc = "A true vegan meal." //TODO
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("water", 5)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/nettlesoup
	name = "Nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("water", 5)
		reagents.add_reagent("tricordrazine", 5)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/mysterysoup
	name = "Mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID

	New()
		..()
		var/mysteryselect = pick(1,2,3,4,5,6,7,8,9,10)
		switch(mysteryselect)
			if(1)
				reagents.add_reagent("nutriment", 6)
				reagents.add_reagent("capsaicin", 3)
				reagents.add_reagent("tomatojuice", 2)
			if(2)
				reagents.add_reagent("nutriment", 6)
				reagents.add_reagent("frostoil", 3)
				reagents.add_reagent("tomatojuice", 2)
			if(3)
				reagents.add_reagent("nutriment", 5)
				reagents.add_reagent("water", 5)
				reagents.add_reagent("tricordrazine", 5)
			if(4)
				reagents.add_reagent("nutriment", 5)
				reagents.add_reagent("water", 10)
			if(5)
				reagents.add_reagent("nutriment", 2)
				reagents.add_reagent("banana", 10)
			if(6)
				reagents.add_reagent("nutriment", 6)
				reagents.add_reagent("blood", 10)
				food_flags |= FOOD_MEAT
			if(7)
				reagents.add_reagent("slimejelly", 10)
				reagents.add_reagent("water", 10)
			if(8)
				reagents.add_reagent("carbon", 10)
				reagents.add_reagent("toxin", 10)
			if(9)
				reagents.add_reagent("nutriment", 5)
				reagents.add_reagent("tomatojuice", 10)
			if(10)
				reagents.add_reagent("nutriment", 6)
				reagents.add_reagent("tomatojuice", 5)
				reagents.add_reagent("imidazoline", 5)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/wishsoup
	name = "Wish Soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID

	New()
		..()
		reagents.add_reagent("water", 10)
		bitesize = 5
		if(prob(25))
			src.desc = "A wish come true!"
			reagents.add_reagent("nutriment", 8)

/obj/item/weapon/reagent_containers/food/snacks/hotchili
	name = "Hot Chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("capsaicin", 3)
		reagents.add_reagent("tomatojuice", 2)
		bitesize = 5


/obj/item/weapon/reagent_containers/food/snacks/coldchili
	name = "Cold Chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("frostoil", 3)
		reagents.add_reagent("tomatojuice", 2)
		bitesize = 5

/* No more of this
/obj/item/weapon/reagent_containers/food/snacks/telebacon
	name = "Tele Bacon"
	desc = "It tastes a little odd but it is still delicious."
	icon_state = "bacon"
	var/obj/item/beacon/bacon/baconbeacon
	bitesize = 2
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		baconbeacon = new /obj/item/beacon/bacon(src)
	On_Consume()
		if(!reagents.total_volume)
			baconbeacon.loc = usr
			baconbeacon.digest_delay()
*/

/obj/item/weapon/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bitesize = 12
	//var/wrapped = 0
	food_flags = FOOD_MEAT

	var/monkey_type = /mob/living/carbon/monkey

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/New()
	..()
	reagents.add_reagent("nutriment",10)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/afterattack(obj/O, mob/user,proximity)
	if(!proximity) return
	if(istype(O,/obj/structure/sink) && !wrapped)
		to_chat(user, "<span class='notice'>You place [src] under a stream of water...</span>")
		return Expand()
	..()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/On_Consume(var/mob/M)

	to_chat(M, "<span class = 'warning'>Something inside of you suddently expands!</span>")

	if (istype(M, /mob/living/carbon/human))
		//Do not try to understand.
		var/obj/item/weapon/surprise = new/obj/item/weapon(M)
		var/mob/living/carbon/monkey/ook = new monkey_type(null) //no other way to get access to the vars, alas
		surprise.icon = ook.icon
		surprise.icon_state = ook.icon_state
		surprise.name = "malformed [ook.name]"
		surprise.desc = "Looks like \a very deformed [ook.name], a little small for its kind. It shows no signs of life."
		qdel(ook)	//rip nullspace monkey
		surprise.transform *= 0.6
		surprise.add_blood(M)
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/E = H.get_organ("chest")
		E.fracture()
		for (var/datum/organ/internal/I in E.internal_organs)
			I.take_damage(rand(I.min_bruised_damage, I.min_broken_damage+1))

		if (!E.hidden && prob(60)) //set it snuggly
			E.hidden = surprise
			E.cavity = 0
		else 		//someone is having a bad day
			E.createwound(CUT, 30)
			E.embed(surprise)
	else if (ismonkey(M))
		M.visible_message("<span class='danger'>[M] suddenly tears in half!</span>")
		var/mob/living/carbon/monkey/ook = new monkey_type(M.loc)
		ook.name = "malformed [ook.name]"
		ook.transform *= 0.6
		ook.add_blood(M)
		M.gib()
	..()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/proc/Expand()

	for(var/mob/M in viewers(src,7))
		to_chat(M, "<span class='warning'>\The [src] expands!</span>")
	new monkey_type(get_turf(src))
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/proc/Unwrap(mob/user as mob)

	icon_state = "monkeycube"
	desc = "Just add water!"
	to_chat(user, "You unwrap the cube.")
	wrapped = 0
	return

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped
	desc = "Still wrapped in some paper."
	icon_state = "monkeycubewrap"
	wrapped = 1


/obj/item/weapon/reagent_containers/food/snacks/monkeycube/farwacube
	name = "farwa cube"
	monkey_type =/mob/living/carbon/monkey/tajara
/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube
	name = "farwa cube"
	monkey_type =/mob/living/carbon/monkey/tajara


/obj/item/weapon/reagent_containers/food/snacks/monkeycube/stokcube
	name = "stok cube"
	monkey_type =/mob/living/carbon/monkey/unathi
/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube
	name = "stok cube"
	monkey_type =/mob/living/carbon/monkey/unathi


/obj/item/weapon/reagent_containers/food/snacks/monkeycube/neaeracube
	name = "neaera cube"
	monkey_type =/mob/living/carbon/monkey/skrell
/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube
	name = "neaera cube"
	monkey_type =/mob/living/carbon/monkey/skrell


/obj/item/weapon/reagent_containers/food/snacks/spellburger
	name = "Spell Burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger
	name = "Big Bite Burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 14)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/enchiladas
	name = "Enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment",8)
		reagents.add_reagent("capsaicin", 6)
		bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's Delight"
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/tray
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		reagents.add_reagent("banana", 5)
		reagents.add_reagent("blackpepper", 1)
		reagents.add_reagent("sodiumchloride", 1)
		bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/baguette
	name = "Baguette"
	desc = "Bon appetit!"
	icon_state = "baguette"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("blackpepper", 1)
		reagents.add_reagent("sodiumchloride", 1)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishandchips
	name = "Fish and Chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("carpotoxin", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sandwich
	name = "Sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	trash = /obj/item/trash/plate
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	food_flags = FOOD_MEAT //This is made from a sandwich, which contains meat!

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("carbon", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/grilledcheese
	name = "Grilled Cheese Sandwich"
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 7)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tomatosoup
	name = "Tomato Soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID

	New()
		..()
		reagents.add_reagent("nutriment", 5)
		reagents.add_reagent("tomatojuice", 10)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	name = "Roffle Waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	food_flags = FOOD_ANIMAL //eggs

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("psilocybin", 8)
		bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stew
	name = "Stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	food_flags = FOOD_LIQUID | FOOD_MEAT

	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("nutriment", 10)
		reagents.add_reagent("tomatojuice", 5)
		reagents.add_reagent("imidazoline", 5)
		reagents.add_reagent("water", 5)
		bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast
	name = "Jellied Toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	trash = /obj/item/trash/plate
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 1)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry
	New()
		..()
		reagents.add_reagent("cherryjelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime
	New()
		..()
		reagents.add_reagent("slimejelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/jellyburger
	name = "Jelly Burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	New()
		..()
		reagents.add_reagent("nutriment", 5)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/slime
	New()
		..()
		reagents.add_reagent("slimejelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/cherry
	New()
		..()
		reagents.add_reagent("cherryjelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/milosoup
	name = "Milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("water", 5)
		bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat
	name = "Stewed Soy Meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti
	name = "Boiled Spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spaghettiboiled"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	name = "Boiled Rice"
	desc = "A boring dish of boring rice."
	icon_state = "boiledrice"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/ricepudding
	name = "Rice Pudding"
	desc = "Where's the Jam!"
	icon_state = "rpudding"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pastatomato
	name = "Spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("tomatojuice", 10)
		bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon_state = "copypasta"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 12)
		reagents.add_reagent("tomatojuice", 20)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti
	name = "Spaghetti & Meatballs"
	desc = "Now thats a nic'e meatball!"
	icon_state = "meatballspaghetti"
	trash = /obj/item/trash/plate
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spesslaw
	name = "Spesslaw"
	desc = "A lawyers favourite"
	icon_state = "spesslaw"
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "Poppy Pretzel"
	desc = "A large soft pretzel full of POP!"
	icon_state = "poppypretzel"
	New()
		..()
		reagents.add_reagent("nutriment", 5)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/carrotfries
	name = "Carrot Fries"
	desc = "Tasty fries from fresh Carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("imidazoline", 3)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/superbiteburger
	name = "Super Bite Burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 40)
		bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/candiedapple
	name = "Candied Apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/applepie
	name = "Apple Pie"
	desc = "A pie containing sweet sweet love...or apple."
	icon_state = "applepie"
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("nutriment", 4)
		bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/pie/cherrypie
	name = "Cherry Pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("nutriment", 4)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/twobread
	name = "Two Bread"
	desc = "It is very bitter and winy."
	icon_state = "twobread"
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich
	name = "Jelly Sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime
	New()
		..()
		reagents.add_reagent("slimejelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry
	New()
		..()
		reagents.add_reagent("cherryjelly", 5)
/*
/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore
	name = "Boiled slime Core"
	desc = "A boiled red thing."
	icon_state = "boiledslimecore"
	New()
		..()
		reagents.add_reagent("slimejelly", 5)
		bitesize = 3
*/
/obj/item/weapon/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "it is only wafer thin."
	icon_state = "mint"
	New()
		..()
		reagents.add_reagent("minttoxin", 1)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	New()
		..()
		if(prob(10))
			name = "exceptional plump helmet biscuit"
			desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
			reagents.add_reagent("nutriment", 8)
			reagents.add_reagent("tricordrazine", 5)
			bitesize = 2
		else
			reagents.add_reagent("nutriment", 5)
			bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 5)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_LIQUID

	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		name = pick("borsch","bortsch","borstch","borsh","borshch","borscht")
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/herbsalad
	name = "herb salad"
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/validsalad
	name = "valid salad"
	desc = "It's just an herb salad with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("doctorsdelight", 5)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/plate
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("gold", 5)
		bitesize = 3

/////////////////////////////////////////////////Sliceable////////////////////////////////////////
// All the food items that can be sliced into smaller bits like Meatbread and Cheesewheels

// sliceable is just an organization type path, it doesn't have any additional code or variables tied to it.

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice
	slices_num = 5
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 30)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatbreadslice
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/sliceable/xenomeatbread
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice
	slices_num = 5
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 30)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/sliceable/spidermeatbread
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/spidermeatbreadslice
	slices_num = 5
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 30)
		reagents.add_reagent("toxin", 15)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spidermeatbreadslice
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("toxin", 2)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread/synth
	name = "synthmeatbread loaf"
	desc = "A loaf of synthetic meatbread. You can just taste the mass-production."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice/synth
	slices_num = 5
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 30)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatbreadslice/synth
	name = "synthmeatbread slice"
	desc = "A slice of synthetic meatbread."
	icon_state = "meatbreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread
	name = "banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/bananabreadslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("banana", 20)
		reagents.add_reagent("nutriment", 20)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bananabreadslice
	name = "banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/tofubread
	name = "Tofubread"
	icon_state = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/tofubreadslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 30)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofubreadslice
	name = "tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/sliceable/carrotcake
	name = "carrot cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/carrotcakeslice
	slices_num = 5
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 25)
		reagents.add_reagent("imidazoline", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/carrotcakeslice
	name = "carrot cake slice"
	desc = "Carrotty slice of Carrot Cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_SWEET

/obj/item/weapon/reagent_containers/food/snacks/sliceable/braincake
	name = "brain cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/braincakeslice
	slices_num = 5
	food_flags = FOOD_MEAT | FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 25)
		reagents.add_reagent("alkysine", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/braincakeslice
	name = "brain cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL //meat, milk, eggs

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesecake
	name = "cheese cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesecakeslice
	slices_num = 5
	food_flags = FOOD_SWEET | FOOD_ANIMAL //cheese

	New()
		..()
		reagents.add_reagent("nutriment", 25)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesecakeslice
	name = "cheese cake slice"
	desc = "Slice of pure cheestisfaction"
	icon_state = "cheesecake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/plaincake
	name = "vanilla cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/plaincakeslice
	slices_num = 5
	food_flags = FOOD_SWEET | FOOD_ANIMAL //milk and eggs

	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/plaincakeslice
	name = "vanilla cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/orangecake
	name = "orange cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/orangecakeslice
	slices_num = 5
	food_flags = FOOD_SWEET | FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/orangecakeslice
	name = "orange cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/limecake
	name = "lime cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/limecakeslice
	slices_num = 5
	food_flags = FOOD_SWEET | FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/limecakeslice
	name = "lime cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/lemoncake
	name = "lemon cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice
	slices_num = 5
	food_flags = FOOD_SWEET | FOOD_ANIMAL
	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice
	name = "lemon cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/chocolatecake
	name = "chocolate cake"
	desc = "A cake with added chocolate"
	icon_state = "chocolatecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice
	slices_num = 5
	food_flags = FOOD_SWEET | FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice
	name = "chocolate cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel
	name = "cheese wheel"
	desc = "A big wheel of delicious Cheddar."
	icon_state = "cheesewheel"
	filling_color = "#FFCC33"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	food_flags = FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 20)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	name = "cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	filling_color = "#FFCC33"
	bitesize = 2
	food_flags = FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake
	name = "Birthday Cake"
	desc = "Happy Birthday..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/birthdaycakeslice
	slices_num = 5
	food_flags = FOOD_SWEET | FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 20)
		reagents.add_reagent("sprinkles", 10)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/birthdaycakeslice
	name = "Birthday Cake slice"
	desc = "A slice of your birthday"
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread
	name = "Bread"
	icon_state = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/breadslice
	name = "Bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/sliceable/creamcheesebread
	name = "Cream Cheese Bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 20)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice
	name = "Cream Cheese Bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	name = "Watermelon Slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	bitesize = 2
	food_flags = FOOD_SWEET


/obj/item/weapon/reagent_containers/food/snacks/sliceable/applecake
	name = "Apple Cake"
	desc = "A cake centred with Apple"
	icon_state = "applecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/applecakeslice
	slices_num = 5
	food_flags = FOOD_SWEET | FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 15)

/obj/item/weapon/reagent_containers/food/snacks/applecakeslice
	name = "Apple Cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie //You can't throw this pie
	name = "Pumpkin Pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET | FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 15)

/obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	name = "Pumpkin Pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/cracker
	name = "Cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"

	New()
		..()
		reagents.add_reagent("nutriment", 1)



/////////////////////////////////////////////////PIZZA////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza
	slices_num = 6

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita
	name = "Margherita"
	desc = "The most cheezy pizza in galaxy"
	icon_state = "pizzamargherita"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/margheritaslice
	slices_num = 6
	food_flags = FOOD_ANIMAL //cheese

	New()
		..()
		reagents.add_reagent("nutriment", 40)
		reagents.add_reagent("tomatojuice", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/margheritaslice
	name = "Margherita slice"
	desc = "A slice of the most cheezy pizza in galaxy"
	icon_state = "pizzamargheritaslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza
	name = "Meatpizza"
	desc = "A filling pizza laden with meat; perfect for the manliest of carnivores."
	icon_state = "meatpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice
	slices_num = 6
	food_flags = FOOD_MEAT | FOOD_ANIMAL //It has cheese!

	New()
		..()
		reagents.add_reagent("nutriment", 50)
		reagents.add_reagent("tomatojuice", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice
	name = "Meatpizza slice"
	desc = "A slice of pizza, packed with delicious meat."
	icon_state = "meatpizzaslice"
	bitesize = 2
	food_flags = FOOD_MEAT | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza/synth
	name = "Synthmeatpizza"
	desc = "A synthetic pizza laden with artificial meat; perfect for the stingiest of chefs."
	icon_state = "meatpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice/synth
	slices_num = 6

	New()
		..()
		reagents.add_reagent("nutriment", 50)
		reagents.add_reagent("tomatojuice", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice/synth
	name = "Synthmeatpizza slice"
	desc = "A slice of pizza, packed with synthetic meat."
	icon_state = "meatpizzaslice"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza
	name = "Mushroompizza"
	desc = "Very special pizza"
	icon_state = "mushroompizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/mushroompizzaslice
	slices_num = 6
	New()
		..()
		reagents.add_reagent("nutriment", 35)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mushroompizzaslice
	name = "Mushroompizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza
	name = "Vegetable pizza"
	desc = "No one of Tomatos Sapiens were harmed during making this pizza"
	icon_state = "vegetablepizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/vegetablepizzaslice
	slices_num = 6
	New()
		..()
		reagents.add_reagent("nutriment", 30)
		reagents.add_reagent("tomatojuice", 6)
		reagents.add_reagent("imidazoline", 12)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/vegetablepizzaslice
	name = "Vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients "
	icon_state = "vegetablepizzaslice"
	bitesize = 2

/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food.dmi'
	icon_state = "pizzabox1"
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC

	var/open = 0 // Is the box open?
	var/ismessy = 0 // Fancy mess on the lid
	var/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/pizza // Content pizza
	var/list/boxes = list() // If the boxes are stacked, they come here
	var/boxtag = ""

/obj/item/pizzabox/update_icon()

	overlays = list()

	// Set appropriate description
	if( open && pizza )
		desc = "A box suited for pizzas. It appears to have a [pizza.name] inside."
	else if( boxes.len > 0 )
		desc = "A pile of boxes suited for pizzas. There appears to be [boxes.len + 1] boxes in the pile."

		var/obj/item/pizzabox/topbox = boxes[boxes.len]
		var/toptag = topbox.boxtag
		if( toptag != "" )
			desc = "[desc] The box on top has a tag, it reads: '[toptag]'."
	else
		desc = "A box suited for pizzas."

		if( boxtag != "" )
			desc = "[desc] The box has a tag, it reads: '[boxtag]'."

	// Icon states and overlays
	if( open )
		if( ismessy )
			icon_state = "pizzabox_messy"
		else
			icon_state = "pizzabox_open"

		if( pizza )
			var/image/pizzaimg = image("food.dmi", icon_state = pizza.icon_state)
			pizzaimg.pixel_y = -3
			overlays += pizzaimg

		return
	else
		// Stupid code because byondcode sucks
		var/doimgtag = 0
		if( boxes.len > 0 )
			var/obj/item/pizzabox/topbox = boxes[boxes.len]
			if( topbox.boxtag != "" )
				doimgtag = 1
		else
			if( boxtag != "" )
				doimgtag = 1

		if( doimgtag )
			var/image/tagimg = image("food.dmi", icon_state = "pizzabox_tag")
			tagimg.pixel_y = boxes.len * 3
			overlays += tagimg

	icon_state = "pizzabox[boxes.len+1]"

/obj/item/pizzabox/attack_hand( mob/user as mob )

	if( open && pizza )
		user.put_in_hands( pizza )

		to_chat(user, "<span class='notice'>You take the [src.pizza] out of the [src].</span>")
		src.pizza = null
		update_icon()
		return

	if( boxes.len > 0 )
		if( user.get_inactive_hand() != src )
			..()
			return

		var/obj/item/pizzabox/box = boxes[boxes.len]
		boxes -= box

		user.put_in_hands( box )
		to_chat(user, "<span class='warning'>You remove the topmost [src] from your hand.</span>")
		box.update_icon()
		update_icon()
		return
	..()

/obj/item/pizzabox/attack_self( mob/user as mob )

	if( boxes.len > 0 )
		return

	open = !open

	if( open && pizza )
		ismessy = 1

	update_icon()

/obj/item/pizzabox/attackby( obj/item/I as obj, mob/user as mob )
	if( istype(I, /obj/item/pizzabox/) )
		var/obj/item/pizzabox/box = I

		if( !box.open && !src.open )
			// Make a list of all boxes to be added
			var/list/boxestoadd = list()
			boxestoadd += box
			for(var/obj/item/pizzabox/i in box.boxes)
				boxestoadd += i

			if( (boxes.len+1) + boxestoadd.len <= 5 )
				user.drop_item(I, src)

				box.boxes = list() // Clear the box boxes so we don't have boxes inside boxes. - Xzibit
				src.boxes.Add( boxestoadd )

				box.update_icon()
				update_icon()

				to_chat(user, "<span class='notice'>You put the [box] ontop of the [src]!</span>")
			else
				to_chat(user, "<span class='warning'>The stack is too high!</span>")
		else
			to_chat(user, "<span class='warning'>Close the [box] first!</span>")

		return

	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/)) // Long ass fucking object name
		if(src.pizza) to_chat(user, "<span class='warning'>[src] already has a pizza in it.</span>")
		else if(src.open)
			user.drop_item(I, src)
			src.pizza = I
			src.update_icon()
			to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		else to_chat(user, "<span class='warning'>Open [src] first.</span>")
		return

	if( istype(I, /obj/item/weapon/pen/) )

		if( src.open )
			return

		var/t = input("Enter what you want to add to the tag:", "Write", null, null) as text
		if (!Adjacent(user) || user.stat) return

		var/obj/item/pizzabox/boxtotagto = src
		if( boxes.len > 0 )
			boxtotagto = boxes[boxes.len]

		boxtotagto.boxtag = copytext("[boxtotagto.boxtag][t]", 1, 30)

		update_icon()
		return
	..()

/obj/item/pizzabox/margherita/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita(src)
	boxtag = "Margherita Deluxe"

/obj/item/pizzabox/vegetable/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza(src)
	boxtag = "Gourmet Vegatable"

/obj/item/pizzabox/mushroom/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza(src)
	boxtag = "Mushroom Special"

/obj/item/pizzabox/meat/New()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza(src)
	boxtag = "Meatlover's Supreme"

////////////////////////////////FOOD ADDITIONS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/wrap
	name = "egg wrap"
	desc = "The precursor to Pigs in a Blanket."
	icon_state = "wrap"
	food_flags = FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 5)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/beans
	name = "tin of beans"
	desc = "Musical fruit in a slightly less musical container."
	icon_state = "beans"
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/benedict
	name = "eggs benedict"
	desc = "There is only one egg on this, how rude."
	icon_state = "benedict"
	food_flags = FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Fresh footlong ready to go down on."
	icon_state = "hotdog"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("ketchup", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be Dog."
	icon_state = "meatbun"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in it's own packaging."
	icon_state = "icecreamsandwich"
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("ice", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon_state = "notasandwich"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	desc = "Just like your little sister used to make."
	icon_state = "sugarcookie"
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("sugar", 5)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	trash = /obj/item/trash/plate
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("toxin", 2)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spidereggs
	name = "spider eggs"
	desc = "A cluster of juicy spider eggs. A great side dish for when you care not for your health."
	icon_state = "spidereggs"
	food_flags = FOOD_ANIMAL //eggs are eggs

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("toxin", 3)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham
	name = "green eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon_state = "spidereggsham"
	trash = /obj/item/trash/plate
	food_flags = FOOD_MEAT | FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("sodiumchloride", 1)
		reagents.add_reagent("toxin", 3)
		bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon_state = "sashimi"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("toxin", 5)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/assburger
	name = "assburger"
	desc = "You better be REALLY nice to this burger, or it'll report you to the police!"
	icon_state = "assburger"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("spiritbreaker", 10) // Screaming
		reagents.add_reagent("mercury",       10) // Idiot
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pie/asspie
	name = "asspie"
	desc = "Please remember to check your privlidge, pie eating scum."
	icon_state = "asspie"
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("spiritbreaker", 10) // Screaming
		reagents.add_reagent("mercury",       10) // Idiot
		bitesize = 3

////////////////////////////////ICE CREAM///////////////////////////////////
/obj/item/weapon/reagent_containers/food/snacks/icecream
        name = "ice cream"
        desc = "Delicious ice cream."
        icon = 'icons/obj/kitchen.dmi'
        icon_state = "icecream_cone"
        food_flags = FOOD_SWEET

        New()
                ..()
                reagents.add_reagent("nutriment", 1)
                reagents.add_reagent("sugar",1)
                bitesize = 1
                update_icon()

        update_icon()
                overlays.len = 0
                var/image/filling = image('icons/obj/kitchen.dmi', src, "icecream_color")
                filling.icon += mix_color_from_reagents(reagents.reagent_list)
                overlays += filling

/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcone
        name = "ice cream cone"
        desc = "Delicious ice cream."
        icon_state = "icecream_cone"
        volume = 500
        New()
                ..()
                reagents.add_reagent("nutriment", 2)
                reagents.add_reagent("sugar",6)
                reagents.add_reagent("ice",2)
                bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcup
        name = "chocolate ice cream cone"
        desc = "Delicious ice cream."
        icon_state = "icecream_cup"
        volume = 500
        New()
                ..()
                reagents.add_reagent("nutriment", 4)
                reagents.add_reagent("sugar",8)
                reagents.add_reagent("ice",2)
                bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/cereal
	name = "box of cereal"
	desc = "A box of cereal."
	icon = 'icons/obj/food.dmi'
	icon_state = "cereal_box"
	bitesize = 2
	New()
		..()
		reagents.add_reagent("nutriment", 3)

/obj/item/weapon/reagent_containers/food/snacks/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	icon = 'icons/obj/food.dmi'
	icon_state = "deepfried_holder_icon"
	bitesize = 2
	deepfried = 1
	New()
		..()
		reagents.add_reagent("nutriment",deepFriedNutriment)

///////////////////////////////////////////
// new old food stuff from bs12
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	bitesize = 2
	food_flags = FOOD_ANIMAL //eggs

	New()
		..()
		reagents.add_reagent("nutriment", 3)

// Dough + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/dough/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough(loc)
			to_chat(user, "<span class='notice'>You flatten [src].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to roll it out!</span>")
	else
		..()

// slicable into 3xdoughslices
/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	slices_num = 3
	food_flags = FOOD_ANIMAL //eggs

	New()
		..()
		reagents.add_reagent("nutriment", 3)

/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "doughslice"
	bitesize = 2
	food_flags = FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 1)

/obj/item/weapon/reagent_containers/food/snacks/bun
	name = "burger bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "bun"
	bitesize = 2
	New()
		..()
		reagents.add_reagent("nutriment", 4)

//////////////////CHRISTMAS AND WINTER FOOD//////////////////

/obj/item/weapon/reagent_containers/food/snacks/sliceable/buchedenoel
	name = "\improper Buche de Noel"
	desc = "Merry Christmas"
	icon_state = "buche"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/bucheslice
	slices_num = 5
	trash = /obj/item/trash/tray
	food_flags = FOOD_SWEET | FOOD_ANIMAL //eggs

/obj/item/weapon/reagent_containers/food/snacks/sliceable/buchedenoel/New()
	..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("sugar", 9)
	reagents.add_reagent("coco", 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/bucheslice
	name = "\improper Buche de Noel slice"
	desc = "A slice of winter magic"
	icon_state = "buche_slice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey
	name = "turkey"
	desc = "Tastes like chicken"
	icon_state = "turkey"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/turkeyslice
	slices_num = 2
	trash = /obj/item/trash/tray
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey/New()
	..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("blackpepper", 1)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("cornoil", 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/turkeyslice
	name = "turkey drumstick"
	desc = "Guaranteed vox-free"
	icon_state = "turkey_drumstick"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_MEAT

//////////////////CHICKEN//////////////////

/obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets
	name = "Chicken Nuggets"
	desc = "You'd rather not know how they were prepared."
	icon_state = "kfc_nuggets"
	item_state = "kfc_bucket"
	trash = /obj/item/trash/chicken_bucket
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chicken_drumstick
	name = "chicken drumstick"
	desc = "We can fry further..."
	icon_state = "chicken_drumstick"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/chicken_drumstick/New()
	..()
	reagents.add_reagent("nutriment", 3)
	bitesize = 1


//////////////////CURRY//////////////////

/obj/item/weapon/reagent_containers/food/snacks/curry
	name = "Chicken Balti"
	desc = "Finest Indian Cuisine, at least you think it is chicken."
	icon_state = "curry_balti"
	item_state = "curry_balti"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/curry/New()
	..()
	reagents.add_reagent("nutriment", 20)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/curry/vindaloo
	name = "Chicken Vindaloo"
	desc = "Me and me Mum and me Dad and me Nan are off to Waterloo, me and me Mum and me Dad and me Nan and a bucket of Vindaloo!"
	icon_state = "curry_vindaloo"
	item_state = "curry_vindaloo"

/obj/item/weapon/reagent_containers/food/snacks/curry/vindaloo/New()
	..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("capsaicin", 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/curry/lemon
	name = "Lemon Curry"
	desc = "This actually exists?"
	icon_state = "curry_lemon"
	item_state = "curry_lemon"

/obj/item/weapon/reagent_containers/food/snacks/curry/lemon/New()
	..()
	reagents.add_reagent("nutriment", 20)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/curry/xeno
	name = "Xeno Balti"
	desc = "Waste not want not."
	icon_state = "curry_xeno"
	item_state = "curry_xeno"

/obj/item/weapon/reagent_containers/food/snacks/curry/xeno/New()
	..()
	reagents.add_reagent("nutriment", 20)
	bitesize = 3


//////////////////CHIPS//////////////////


/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	trash = /obj/item/trash/chips
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable
	name = "Plain Chips"
	desc = "Where did the bag come from?"
	icon_state = "plain_chips"
	item_state = "plain_chips"
	trash = null

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/New()
	..()
	reagents.add_reagent("nutriment", 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/vinegar
	name = "Salt and Vinegar Chips"
	desc = "The objectively best flavour."
	icon_state = "salt_vinegar_chips"
	item_state = "salt_vinegar_chips"

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/vinegar/New()
	..()
	reagents.add_reagent("nutriment", 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/cheddar
	name = "Cheddar Chips"
	desc = "Dangerously cheesy."
	icon_state = "cheddar_chips"
	item_state = "cheddar_chips"

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/cheddar/New()
	..()
	reagents.add_reagent("nutriment", 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/clown
	name = "Banana Chips"
	desc = "A clown's favourite snack!"
	icon_state = "clown_chips"
	item_state = "clown_chips"

/obj/item/weapon/reagent_containers/food/snacks/chip/cookable/clown/New()
	..()
	reagents.add_reagent("nutriment", 5)
	reagents.add_reagent("honkserum", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nuclear
	name = "Nuclear Chips"
	desc = "Radioactive taste!"
	icon_state = "nuclear_chips"
	item_state = "nuclear_chips"

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/nuclear/New()
	..()
	reagents.add_reagent("nutriment", 5)
	reagents.add_reagent("nuka_cola", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/communist
	name = "Communist Chips"
	desc = "A perfect snack to share with the party!"
	icon_state = "commie_chips"
	item_state = "commie_chips"

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/communist/New()
	..()
	reagents.add_reagent("nutriment", 5)
	reagents.add_reagent("vodka", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/xeno
	name = "Xeno Raiders"
	desc = "A great taste that is out of this world!"
	icon_state = "xeno_chips"
	item_state = "xeno_chips"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/chips/cookable/xeno/New()
	..()
	reagents.add_reagent("nutriment", 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/gigapuddi
	name = "Giga Puddi"
	desc = "A large crème caramel"
	icon_state = "gigapuddi"
	trash = /obj/item/trash/plate
	food_flags = FOOD_ANIMAL //milk

	New()
		..()
		reagents.add_reagent("nutriment", 20)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/gigapuddi/happy
	desc = "A large crème caramel made with extra love"
	icon_state = "happypuddi"
	food_flags = FOOD_SWEET

/obj/item/weapon/reagent_containers/food/snacks/gigapuddi/anger
	desc = "A large crème caramel made with extra hate"
	icon_state = "angerpuddi"

/obj/item/weapon/reagent_containers/food/snacks/flan
	name = "Flan"
	desc = "A small crème caramel"
	icon_state = "flan"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/omurice
	name = "omelette rice"
	desc = "Just like your Japanese animes!"
	icon_state = "omurice"
	trash = /obj/item/trash/plate
	food_flags = FOOD_ANIMAL //egg

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/omurice/heart
	icon_state = "omuriceheart"

/obj/item/weapon/reagent_containers/food/snacks/omurice/face
	icon_state = "omuriceface"

/obj/item/weapon/reagent_containers/food/snacks/muffin/bluespace
	name = "Bluespace-berry Muffin"
	desc = "Just like a normal blueberry muffin, except with completely unnecessary floaty things!"
	icon_state = "bluespace"
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/yellowcake
	name = "Yellowcake"
	desc = "For Fat Men."
	icon_state = "yellowcake"
	food_flags = FOOD_SWEET | FOOD_ANIMAL //egg

	New()
		..()
		reagents.add_reagent("nutriment", 40)
		reagents.add_reagent("radium", 10)
		reagents.add_reagent("uranium", 5)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/yellowcupcake
	name = "Yellowcupcake"
	desc = "For Little Boys."
	icon_state = "yellowcupcake"
	food_flags = FOOD_SWEET | FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 15)
		reagents.add_reagent("radium", 5)
		reagents.add_reagent("uranium", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cookiebowl
	name = "Bowl of cookies"
	desc = "A bowl full of small cookies."
	icon_state = "cookiebowl"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 5)
		reagents.add_reagent("sugar", 5)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/chococherrycake
	name = "chocolate-cherry cake"
	desc = "A chocolate cake with icing and cherries."
	icon_state = "chococherrycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/chococherrycakeslice
	slices_num = 5
	food_flags = FOOD_SWEET | FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/chococherrycakeslice
	name = "chocolate-cherry cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chococherrycake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2
	food_flags = FOOD_SWEET | FOOD_ANIMAL

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinbread
	name = "Pumpkin Bread"
	desc = "A loaf of pumpkin bread."
	icon_state = "pumpkinbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pumpkinbreadslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 15)

/obj/item/weapon/reagent_containers/food/snacks/pumpkinbreadslice
	name = "Pumpkin Bread slice"
	desc = "A slice of pumpkin bread."
	icon_state = "pumpkinbreadslice"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/corndog
	name = "Corndog"
	desc = "Battered hotdog on a stick!"
	icon_state = "corndog"
	food_flags = FOOD_MEAT | FOOD_ANIMAL //eggs

	New()
		..()
		reagents.add_reagent("nutriment", 5)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/cornydog
	name = "CORNY DOG"
	desc = "This is just ridiculous."
	icon_state = "cornydog"
	trash = /obj/item/stack/rods  //no fun allowed
	food_flags = FOOD_MEAT

	New()
		..()
		reagents.add_reagent("nutriment", 15)
		bitesize = 5

////////////////SLIDERS////////////////

/obj/item/weapon/reagent_containers/food/snacks/slider
	name = "slider"
	desc = "It's so tiny!"
	icon_state = "slider"
	food_flags = FOOD_MEAT

/obj/item/weapon/reagent_containers/food/snacks/slider/New()
	..()
	reagents.add_reagent("nutriment", 2.5)
	bitesize = 1.5

/obj/item/weapon/reagent_containers/food/snacks/slider/synth
	name = "synth slider"
	desc = "It's made to be tiny!"

/obj/item/weapon/reagent_containers/food/snacks/slider/xeno
	name = "xeno slider"
	desc = "It's green!"
	icon_state = "slider_xeno"

/obj/item/weapon/reagent_containers/food/snacks/slider/xeno/New()
	..()
	reagents.add_reagent("nutriment", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/slider/chicken
	name = "chicken slider"
	desc = "Chicken sliders? That's new."
	icon_state = "slider_chicken"

/obj/item/weapon/reagent_containers/food/snacks/slider/chicken/New()
	..()
	reagents.add_reagent("nutriment", 1)
	bitesize = 2
/
/obj/item/weapon/reagent_containers/food/snacks/slider/carp
	name = "carp slider"
	desc = "I wonder how it tastes!"
	icon_state = "slider_carp"

/obj/item/weapon/reagent_containers/food/snacks/slider/carp/New()
	..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("toxin", 1)
	bitesize = 2.5

/obj/item/weapon/reagent_containers/food/snacks/slider/carp/spider
	name = "spidey slidey"
	desc = "I think there's still a leg in there!"
	icon_state = "slider_spider"

/obj/item/weapon/reagent_containers/food/snacks/slider/clown
	name = "honky slider"
	desc = "HONK!"
	icon_state = "slider_clown"

/obj/item/weapon/reagent_containers/food/snacks/slider/clown/New()
	..()
	reagents.add_reagent("honkserum", 2.5)
	bitesize = 2.5

/obj/item/weapon/reagent_containers/food/snacks/slider/mime
	name = "quiet Slider"
	desc = "..."
	icon_state = "slider_mime"

/obj/item/weapon/reagent_containers/food/snacks/slider/slippery
	name = "slippery slider"
	desc = "It's so slippery!"
	icon_state = "slider_slippery"

/obj/item/weapon/reagent_containers/food/snacks/slider/slippery/Crossed(atom/movable/O) //exactly the same as soap
	if (istype(O, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = O

		if (H.CheckSlip() < 1)
			return

		H.stop_pulling()
		to_chat(H, "<SPAN CLASS='notice'>You slipped on the [name]!</SPAN>")
		playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
		H.Stun(3)
		H.Weaken(2)



////////////////SLIDERS END////////////////

/obj/item/weapon/reagent_containers/food/snacks/higashikata
	name = "Higashikata Special"
	desc = "9 layer parfait, very expensive."
	icon_state = "higashikata"
	food_flags = FOOD_SWEET | FOOD_ANIMAL

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		reagents.add_reagent("sugar", 10)
		reagents.add_reagent("ice", 10)
		reagents.add_reagent("melonjuice", 5)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sundae
	name = "Sundae"
	desc = "A colorful ice cream treat."
	icon_state = "sundae"
	food_flags = FOOD_SWEET | FOOD_ANIMAL //milk

	New()
		..()
		reagents.add_reagent("nutriment", 5)
		reagents.add_reagent("sugar", 5)
		reagents.add_reagent("ice", 5)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/potatosalad
	name = "Potato Salad"
	desc = "With 21st century technology, it could take as long as three days to make this."
	icon_state = "potato_salad"
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cinnamonroll
	name = "cinnamon roll"
	desc = "Sweet and spicy!"
	icon_state = "cinnamon_roll"
	trash = /obj/item/trash/plate
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("cinnamon",5)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cinnamonpie
	name = "cinnamon pie"
	desc = "Guarranted snail-free!"
	icon_state = "cinnamon_pie"
	trash = /obj/item/trash/pietin
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("cinnamon",5)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sundaeramen
	name = "Sundae Ramen"
	desc = "This is... sundae (?) flavored (?) ramen (?). You just don't know."
	icon_state = "sundaeramen"
	food_flags = FOOD_SWEET

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		reagents.add_reagent("discount", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen
	name = "Sweet Sundae Ramen"
	desc = "It's a delicious ramen recipe that can soothe the soul of a savage spaceman."
	icon_state = "sweetsundaeramen"
	food_flags = FOOD_SWEET | FOOD_ANIMAL //uses puddi in recipe

	New()
		..()
		bitesize = 4
		while(reagents.total_volume<70)
			generatecontents()

/obj/item/weapon/reagent_containers/food/snacks/sweetsundaeramen/proc/generatecontents()
	switch(pick(1,2,3,4,5,6,7,8,9,10))
		if(1)
			desc += " It has peppermint flavoring! But just a few drops."
			reagents.add_reagent("zombiepowder", 10)
		if(2)
			desc += " This may not be everyone's cup of tea, but it's great, I promise."
			reagents.add_reagent("oxycodone", 10)
		if(3)
			desc += " This has the cook's favorite ingredient -- and a lot of it!"
			reagents.add_reagent("mindbreaker", 10)
		if(4)
			desc += " It has TONS of flavor!"
			reagents.add_reagent("minttoxin", 10)
		if(5)
			desc += " The recipe for this thing got lost somewhere..."
			reagents.add_reagent("nutriment", 10)
		if(6)
			desc += " It has extra sweetness and a little bit of crumble!"
			reagents.add_reagent("tricordrazine", 10)
		if(7)
			desc += " It may be thick, but the noodles slip around easily."
			reagents.add_reagent("nutriment", 10)
		if(8)
			desc += " It has a nice crunch!"
			reagents.add_reagent("nutriment", 10)
		if(9)
			desc += " Yummy, but with all the sweets, your chest starts to hurt."
			reagents.add_reagent("nutriment", 10)
		if(10)
			desc += " Just a dollop of garnishes."
			reagents.add_reagent("nutriment", 10)

/obj/item/weapon/reagent_containers/food/snacks/chocofrog
	name = "chocolate frog"
	desc = "An exotic snack originating from the Space Wizard Federation. Very slippery!"
	icon = 'icons/obj/wiz_cards.dmi'
	icon_state = "frog"

	flags = PROXMOVE
	food_flags = FOOD_SWEET

	var/jump_cd

/obj/item/weapon/reagent_containers/food/snacks/chocofrog/New()
	..()
	reagents.add_reagent("nutriment",2)
	reagents.add_reagent("hyperzine",1)

/obj/item/weapon/reagent_containers/food/snacks/chocofrog/HasProximity(atom/movable/AM as mob|obj)
	if(!jump_cd)
		jump()
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/chocofrog/proc/jump()
	if(!istype(src.loc,/turf)) return
	jump_cd=1
	spawn(50)
		jump_cd=0

	var/list/escape_paths=list()

	for(var/turf/T in view(7,src))
		escape_paths |= T

	var/turf/T = pick(escape_paths)
	src.throw_at(T, 10, 2)
	return 1

/obj/item/weapon/reagent_containers/food/snacks/chocofrog/pickup(mob/living/user as mob)
	var/mob/living/carbon/human/H = user
	if(!H) return 1

	spawn(0)
		if(((M_CLUMSY in H.mutations)) || prob(25))
			user.visible_message("<span class='warning'>[src] escapes from [H]'s hands!</span>","<span class='warning'>[src] escapes from your grasp!</span>")
			H.drop_item()

			jump()
	return 1

/obj/item/weapon/reagent_containers/food/snacks/potentham
	name = "potent ham"
	desc = "I'm sorry Dave, but I am afraid I can't let you eat that."
	icon_state = "potentham"
	volume = 1
	New()
		..()
		reagents.add_reagent("hamserum", 1)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sweet
	name = "\improper Sweet"
	desc = "Comes in many different and unique flavours!"
	food_flags = FOOD_SWEET
	icon = 'icons/obj/candymachine.dmi'
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/sweet/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 2)
	icon_state = "sweet[rand(1,12)]"

/obj/item/weapon/reagent_containers/food/snacks/sweet/strange
	desc = "Something about this sweet doesn't seem right."

/obj/item/weapon/reagent_containers/food/snacks/sweet/strange/New()
	..()
	var/list/possible_reagents=list("zombiepowder"=5, "mindbreaker"=5, "pacid"=5, "hyperzine"=5, "chloralhydrate"=5, "tricordazine"=5, "doctorsdelight"=5, "mutationtoxin"=5, "mercury"=5, "anti_toxin"=5, "space_drugs"=5, "holywater"=5,  "ryetalyn"=5, "cryptobiolin"=5, "dexalinp"=5, "hamserum"=1)
	var/reagent=pick(possible_reagents)
	reagents.add_reagent(reagent, possible_reagents[reagent])
