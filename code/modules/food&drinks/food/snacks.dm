/obj/item/weapon/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon = 'icons/obj/food.dmi'
	icon_state = null
	var/bitesize = 1
	var/bitecount = 0
	var/trash = null
	var/slice_path
	var/slices_num
	var/eatverb
	var/wrapped = 0
	var/dried_type = null
	var/potency = null
	var/dry = 0

	//Placeholder for effect that trigger on eating that aren't tied to reagents.
/obj/item/weapon/reagent_containers/food/snacks/proc/On_Consume()
	if(!usr)	return
	if(!reagents.total_volume)
		usr.unEquip(src)	//so icons update :[

		if(trash)
			if(ispath(trash,/obj/item/weapon/grown))
				var/obj/item/TrashItem = new trash(usr,src.potency)
				usr.put_in_hands(TrashItem)
			else if(ispath(trash,/obj/item))
				var/obj/item/TrashItem = new trash(usr)
				usr.put_in_hands(TrashItem)
			else if(istype(trash,/obj/item))
				usr.put_in_hands(trash)
		qdel(src)
	return


/obj/item/weapon/reagent_containers/food/snacks/attack_self(mob/user)
	return


/obj/item/weapon/reagent_containers/food/snacks/attack(mob/M, mob/user, def_zone)
	if(!eatverb)
		eatverb = pick("bite","chew","nibble","gnaw","gobble","chomp")
	if(!reagents.total_volume)						//Shouldn't be needed but it checks to see if it has anything left in it.
		user << "<span class='notice'>None of [src] left, oh no!</span>"
		M.unEquip(src)	//so icons update :[
		qdel(src)
		return 0
	if(istype(M, /mob/living/carbon))
		if(!canconsume(M, user))
			return 0

		if(M == user)								//If you're eating it yourself.
			var/fullness = M.nutrition + (M.reagents.get_reagent_amount("nutriment") * 25)
			if(wrapped)
				M << "<span class='notice'>You can't eat wrapped food!</span>"
				return 0
			else if(fullness <= 50)
				M << "<span class='notice'>You hungrily [eatverb] some of \the [src] and gobble it down!</span>"
			else if(fullness > 50 && fullness < 150)
				M << "<span class='notice'>You hungrily begin to [eatverb] \the [src].</span>"
			else if(fullness > 150 && fullness < 350)
				M << "<span class='notice'>You [eatverb] \the [src].</span>"
			else if(fullness > 350 && fullness < 550)
				M << "<span class='notice'>You unwillingly [eatverb] a bit of \the [src].</span>"
			else if(fullness > (550 * (1 + M.overeatduration / 2000)))	// The more you eat - the more you can eat
				M << "<span class='notice'>You cannot force any more of \the [src] to go down your throat.</span>"
				return 0
		else
			if(! (isslime(M) || isbrain(M)) )		//If you're feeding it to someone else.
				var/fullness = M.nutrition + (M.reagents.get_reagent_amount("nutriment") * 25)
				if(wrapped)
					return 0
				if(fullness <= (550 * (1 + M.overeatduration / 1000)))
					M.visible_message("<span class='danger'>[user] attempts to feed [M] [src].</span>", \
										"<span class='userdanger'>[user] attempts to feed [M] [src].</span>")
				else
					M.visible_message("<span class='danger'>[user] cannot force anymore of [src] down [M]'s throat!</span>", \
										"<span class='userdanger'>[user] cannot force anymore of [src] down [M]'s throat!</span>")
					return 0

				if(!do_mob(user, M)) return
				add_logs(user, M, "fed", object="[reagentlist(src)]")
				M.visible_message("<span class='danger'>[user] forces [M] to eat [src].</span>", \
									"<span class='userdanger'>[user] feeds [M] to eat [src].</span>")

			else
				user << "<span class='notice'>[M] doesn't seem to have a mouth!</span>"
				return

		if(reagents)								//Handle ingestion of the reagent.
			playsound(M.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					if(reagents.total_volume > bitesize)	//pretty sure this is unnecessary
						reagents.trans_to(M, bitesize)
					else
						reagents.trans_to(M, reagents.total_volume)
					bitecount++
					On_Consume()
			return 1

	return 0


/obj/item/weapon/reagent_containers/food/snacks/afterattack(obj/target, mob/user , proximity)
	return


/obj/item/weapon/reagent_containers/food/snacks/examine(mob/user)
	..()
	if(bitecount == 0)
		return
	else if(bitecount == 1)
		user << "[src] was bitten by someone!"
	else if(bitecount <= 3)
		user << "[src] was bitten [bitecount] times!"
	else
		user << "[src] was bitten multiple times!"


/obj/item/weapon/reagent_containers/food/snacks/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/storage))
		..() // -> item/attackby()
		return 0
	if((slices_num <= 0 || !slices_num) || !slice_path)
		return 0
	var/inaccurate = 0
	if( \
			istype(W, /obj/item/weapon/kitchenknife) || \
			istype(W, /obj/item/weapon/butch) || \
			istype(W, /obj/item/weapon/scalpel) || \
			istype(W, /obj/item/weapon/kitchen/utensil/knife) \
		)
	else if( \
			istype(W, /obj/item/weapon/circular_saw) || \
			istype(W, /obj/item/weapon/melee/energy/sword) && W:active || \
			istype(W, /obj/item/weapon/melee/energy/blade) || \
			istype(W, /obj/item/weapon/shovel) || \
			istype(W, /obj/item/weapon/hatchet) \
		)
		inaccurate = 1
	else
		return 0 // --- this is everything that is NOT a slicing implement, and which is not being slipped into food; allow afterattack ---

	if ( \
			!isturf(src.loc) || \
			!(locate(/obj/structure/table) in src.loc) && \
			!(locate(/obj/structure/optable) in src.loc) && \
			!(locate(/obj/item/weapon/storage/bag/tray) in src.loc) \
		)
		user << "<span class='notice'>You cannot slice [src] here! You need a table or at least a tray.</span>"
		return 1

	var/slices_lost = 0
	if (!inaccurate)
		user.visible_message( \
			"<span class='notice'>[user] slices [src].</span>", \
			"<span class='notice'>You slice [src].</span>" \
		)
	else
		user.visible_message( \
			"<span class='notice'>[user] inaccurately slices [src] with [W]!</span>", \
			"<span class='notice'>You inaccurately slice [src] with your [W]!</span>" \
		)
		slices_lost = rand(1,min(1,round(slices_num/2)))
	var/reagents_per_slice = reagents.total_volume/slices_num
	for(var/i=1 to (slices_num-slices_lost))
		var/obj/slice = new slice_path (src.loc)
		reagents.trans_to(slice,reagents_per_slice)
	qdel(src) // so long and thanks for all the fish


/obj/item/weapon/reagent_containers/food/snacks/Destroy()
	if(contents)
		for(var/atom/movable/something in contents)
			something.loc = get_turf(src)
	..()


/obj/item/weapon/reagent_containers/food/snacks/attack_animal(mob/M)
	if(isanimal(M))
		if(iscorgi(M))
			if(bitecount == 0 || prob(50))
				M.emote("me", 1, "nibbles away at the [src]")
			bitecount++
			if(bitecount >= 5)
				var/sattisfaction_text = pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where the [src] was")
				if(sattisfaction_text)
					M.emote("me", 1, "[sattisfaction_text]")
				qdel(src)


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
//	New()																//Don't mess with this.
//		..()															//Same here.
//		reagents.add_reagent("xenomicrobes", 10)						//This is what is in the food item. you may copy/paste
//		reagents.add_reagent("nutriment", 2)							//	this line of code for all the contents.
//		bitesize = 3													//This is the amount each bite consumes.


////////////////////////////////////////////SALAD////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/aesirsalad
	name = "\improper Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/aesirsalad/New()
	..()
	eatverb = pick("crunch","devour","nibble","gnaw","gobble","chomp")
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("tricordrazine", 8)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/herbsalad
	name = "herb salad"
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/herbsalad/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/validsalad
	name = "valid salad"
	desc = "It's just an herb salad with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/validsalad/New()
	..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("doctorsdelight", 5)
	bitesize = 3

////////////////////////////////////////////DONUTS////////////////////////////////////////////


/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	icon_state = "donut1"

/obj/item/weapon/reagent_containers/food/snacks/donut/normal
	desc = "Goes great with Robust Coffee."

/obj/item/weapon/reagent_containers/food/snacks/donut/normal/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sprinkles", 1)
	src.bitesize = 3
	if(prob(30))
		src.icon_state = "donut2"
		src.name = "frosted donut"
		reagents.add_reagent("sprinkles", 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos
	name = "chaos donut"
	desc = "Like life, it never quite tastes the same."

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos/New()
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

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly/New()
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

/obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly/New()
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

/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sprinkles", 1)
	reagents.add_reagent("cherryjelly", 5)
	if(prob(30))
		icon_state = "jdonut2"
		name = "Frosted Jelly Donut"
		reagents.add_reagent("sprinkles", 2)

////////////////////////////////////////////WAFFLES////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles."
	icon_state = "waffles"
	trash = /obj/item/trash/waffles

/obj/item/weapon/reagent_containers/food/snacks/waffles/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	name = "\improper Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen/New()
	..()
	reagents.add_reagent("nutriment", 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	name = "\improper Soylent Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians/New()
	..()
	reagents.add_reagent("nutriment", 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	name = "roffle waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles/New()
	..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("mushroomhallucinogen", 8)
	bitesize = 4

////////////////////////////////////////////FISH////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "\improper Cuban carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/cubancarp/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("carpotoxin", 3)
	reagents.add_reagent("capsaicin", 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat."
	icon_state = "fishfillet"

/obj/item/weapon/reagent_containers/food/snacks/carpmeat/New()
	..()
	eatverb = pick("bite","chew","choke down","gnaw","swallow","chomp")
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("carpotoxin", 3)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/carpmeat/imitation
	name = "imitation carp fillet"
	desc = "Almost just like the real thing, kinda."

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"

/obj/item/weapon/reagent_containers/food/snacks/fishfingers/New()
	..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("carpotoxin", 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishandchips
	name = "fish and chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"

/obj/item/weapon/reagent_containers/food/snacks/fishandchips/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("carpotoxin", 3)
	bitesize = 3

////////////////////////////////////////////EGGS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg
	name = "chocolate egg"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolateegg"

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg/New()
	..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("sugar", 2)
	reagents.add_reagent("coco", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"

/obj/item/weapon/reagent_containers/food/snacks/egg/New()
	..()
	reagents.add_reagent("nutriment", 1)

/obj/item/weapon/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/egg_smudge(src.loc)
	reagents.reaction(hit_atom, TOUCH)
	del(src) // Not qdel, because it'll hit other mobs then the floor for runtimes.

/obj/item/weapon/reagent_containers/food/snacks/egg/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype( W, /obj/item/toy/crayon ))
		var/obj/item/toy/crayon/C = W
		var/clr = C.colourName

		if(!(clr in list("blue", "green", "mime", "orange", "purple", "rainbow", "red", "yellow")))
			usr << "<span class='notice'>[src] refuses to take on this colour!</span>"
			return

		usr << "<span class='notice'>You colour [src] [clr].</span>"
		icon_state = "egg-[clr]"
		item_color = clr
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/egg/blue
	icon_state = "egg-blue"
	item_color = "blue"

/obj/item/weapon/reagent_containers/food/snacks/egg/green
	icon_state = "egg-green"
	item_color = "green"

/obj/item/weapon/reagent_containers/food/snacks/egg/mime
	icon_state = "egg-mime"
	item_color = "mime"

/obj/item/weapon/reagent_containers/food/snacks/egg/orange
	icon_state = "egg-orange"
	item_color = "orange"

/obj/item/weapon/reagent_containers/food/snacks/egg/purple
	icon_state = "egg-purple"
	item_color = "purple"

/obj/item/weapon/reagent_containers/food/snacks/egg/rainbow
	icon_state = "egg-rainbow"
	item_color = "rainbow"

/obj/item/weapon/reagent_containers/food/snacks/egg/red
	icon_state = "egg-red"
	item_color = "red"

/obj/item/weapon/reagent_containers/food/snacks/egg/yellow
	icon_state = "egg-yellow"
	item_color = "yellow"

/obj/item/weapon/reagent_containers/food/snacks/friedegg
	name = "fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"

/obj/item/weapon/reagent_containers/food/snacks/friedegg/New()
	..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("blackpepper", 1)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/boiledegg
	name = "boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"

/obj/item/weapon/reagent_containers/food/snacks/boiledegg/New()
	..()
	reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/omelette	//FUCK THIS
	name = "omelette du fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/omelette/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/omelette/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchen/utensil/fork))
		if(W.icon_state == "forkloaded")
			user << "<span class='notice'>You already have omelette on your fork.</span>"
			return
		W.icon_state = "forkloaded"
		user.visible_message( \
			"<span class='notice'>[user] takes a piece of omelette with their fork!</span>", \
			"<span class='notice'>You take a piece of omelette with your fork!</span>" \
		)
		reagents.remove_reagent("nutriment", 1)
		if(reagents.total_volume <= 0)
			qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/benedict
	name = "eggs benedict"
	desc = "There is only one egg on this, how rude."
	icon_state = "benedict"

/obj/item/weapon/reagent_containers/food/snacks/benedict/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 3

////////////////////////////////////////////MUFFINS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/muffin
	name = "muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"

/obj/item/weapon/reagent_containers/food/snacks/muffin/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/muffin/berry
	name = "berry muffin"
	icon_state = "berrymuffin"
	desc = "A delicious and spongy little cake, with berries."

/obj/item/weapon/reagent_containers/food/snacks/muffin/booberry
	name = "booberry muffin"
	icon_state = "berrymuffin"
	alpha = 125
	desc = "My stomach is a graveyard! No living being can quench my bloodthirst!"

////////////////////////////////////////////OTHER////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy

/obj/item/weapon/reagent_containers/food/snacks/candy/New()
	..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("sugar", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Can be stored in a detective's hat."
	icon_state = "candy_corn"

/obj/item/weapon/reagent_containers/food/snacks/candy_corn/New()
	..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("sugar", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	trash = /obj/item/trash/chips

/obj/item/weapon/reagent_containers/food/snacks/chips/New()
	..()
	reagents.add_reagent("nutriment", 3)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"

/obj/item/weapon/reagent_containers/food/snacks/cookie/New()
	..()
	reagents.add_reagent("nutriment", 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
	name = "chocolate bar"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolatebarunwrapped"
	wrapped = 0
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 2)
	reagents.add_reagent("coco", 2)

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/proc/Unwrap(mob/user)
		icon_state = "chocolatebarunwrapped"
		desc = "It won't make you all sticky."
		user << "<span class='notice'>You remove the foil.</span>"
		wrapped = 0


/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped
	desc = "It's wrapped in some foil."
	icon_state = "chocolatebar"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/tofu
	name = "tofu"
	desc = "We all love tofu."
	icon_state = "tofu"

/obj/item/weapon/reagent_containers/food/snacks/tofu/New()
	..()
	reagents.add_reagent("nutriment", 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"

/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice/New()
	..()
	reagents.add_reagent("nutriment", 3)
	src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"

/obj/item/weapon/reagent_containers/food/snacks/tomatomeat/New()
	..()
	reagents.add_reagent("nutriment", 3)
	src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"

/obj/item/weapon/reagent_containers/food/snacks/bearmeat/New()
	..()
	reagents.add_reagent("nutriment", 12)
	reagents.add_reagent("hyperzine", 5)
	src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/xenomeat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "xenomeat"

/obj/item/weapon/reagent_containers/food/snacks/xenomeat/New()
	..()
	reagents.add_reagent("nutriment", 3)
	src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spidermeat
	name = "spider meat"
	desc = "A slab of spider meat."
	icon_state = "spidermeat"

/obj/item/weapon/reagent_containers/food/snacks/spidermeat/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("toxin", 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"

/obj/item/weapon/reagent_containers/food/snacks/spiderleg/New()
	..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("toxin", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cornedbeef
	name = "corned beef and cabbage"
	desc = "Now you can feel like a real tourist vacationing in Ireland."
	icon_state = "cornedbeef"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/cornedbeef/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/faggot
	name = "faggot"
	desc = "A great meal all round. Not a cord of wood."
	icon_state = "faggot"

/obj/item/weapon/reagent_containers/food/snacks/faggot/New()
	..()
	reagents.add_reagent("nutriment", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"

/obj/item/weapon/reagent_containers/food/snacks/sausage/New()
	..()
	eatverb = pick("bite","chew","nibble","deep throat","gobble","chomp")
	reagents.add_reagent("nutriment", 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	var/warm = 0

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/New()
	..()
	reagents.add_reagent("nutriment", 4)



/obj/item/weapon/reagent_containers/food/snacks/donkpocket/proc/cooltime() //Not working, derp?
	if(warm)
		spawn(4200)	//ew
			warm = 0
			reagents.del_reagent("tricordrazine")
			name = initial(name)
	return

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu
	name = "wing fang chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/human/kebab
	name = "-kebab"
	icon_state = "kebab"
	desc = "A human meat, on a stick."
	trash = /obj/item/stack/rods

/obj/item/weapon/reagent_containers/food/snacks/human/kebab/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeykebab
	name = "meat-kebab"
	icon_state = "kebab"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods

/obj/item/weapon/reagent_containers/food/snacks/monkeykebab/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofukebab
	name = "tofu-kebab"
	icon_state = "kebab"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods

/obj/item/weapon/reagent_containers/food/snacks/tofukebab/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 2

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
		usr << "<span class='danger'>You bite down on an un-popped kernel, and it hurts your teeth!</span>"
		unpopped = max(0, unpopped-1)
		reagents.add_reagent("sacid",0.1) //only a little tingle.
	..()


/obj/item/weapon/reagent_containers/food/snacks/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash = /obj/item/trash/sosjerky

/obj/item/weapon/reagent_containers/food/snacks/sosjerky/New()
	..()
	reagents.add_reagent("nutriment", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/no_raisin
	name = "4no raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins

/obj/item/weapon/reagent_containers/food/snacks/no_raisin/New()
	..()
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie
	name = "space twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer than you will."

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie/New()
	..()
	reagents.add_reagent("sugar", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers
	name = "cheesie honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	icon_state = "cheesie_honkers"
	trash = /obj/item/trash/cheesie

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers/New()
	..()
	reagents.add_reagent("nutriment", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/syndicake
	name = "syndi-cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	trash = /obj/item/trash/syndi_cakes

/obj/item/weapon/reagent_containers/food/snacks/syndicake/New()
	..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("doctorsdelight", 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato
	name = "loaded baked potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fries
	name = "space fries"
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon_state = "fries"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/fries/New()
	..()
	reagents.add_reagent("nutriment", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soydope
	name = "soy dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/soydope/New()
	..()
	reagents.add_reagent("nutriment", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries
	name = "cheesy fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	name = "fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie/New()
	..()
	reagents.add_reagent("nutriment", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/badrecipe
	name = "burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"

/obj/item/weapon/reagent_containers/food/snacks/badrecipe/New()
	..()
	eatverb = pick("choke down","nibble","gnaw","chomp")
	reagents.add_reagent("toxin", 1)
	reagents.add_reagent("carbon", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatsteak
	name = "meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatsteak"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/New()
	..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("blackpepper", 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff
	name = "spacy liberty duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("mushroomhallucinogen", 6)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	name = "amanita jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("amatoxin", 6)
	reagents.add_reagent("mushroomhallucinogen", 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel/New()
	..()
	reagents.add_reagent("nutriment", 5)
	bitesize = 2

/* No more of this
/obj/item/weapon/reagent_containers/food/snacks/telebacon
	name = "tele bacon"
	desc = "It tastes a little odd but it is still delicious."
	icon_state = "bacon"
	var/obj/item/device/radio/beacon/bacon/baconbeacon
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/telebacon/New()
	..()
	reagents.add_reagent("nutriment", 4)
	baconbeacon = new /obj/item/device/radio/beacon/bacon(src)
/obj/item/weapon/reagent_containers/food/snacks/telebacon/On_Consume()
	if(!reagents.total_volume)
		baconbeacon.loc = usr
		baconbeacon.digest_delay()
*/

/obj/item/weapon/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bitesize = 12
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/New()
	..()
	reagents.add_reagent("nutriment",10)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/afterattack(obj/O, mob/user,proximity)
	if(!proximity) return
	if(istype(O,/obj/structure/sink) && !wrapped)
		user << "<span class='notice'>You place [src] under a stream of water...</span>"
		user.drop_item()
		loc = get_turf(O)
		return Expand()
	..()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/proc/Expand()
	visible_message("<span class='notice'>[src] expands!</span>")
	new /mob/living/carbon/monkey(get_turf(src))
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/proc/Unwrap(mob/user)
	icon_state = "monkeycube"
	desc = "Just add water!"
	user << "<span class='notice'>You unwrap the cube.</span>"
	wrapped = 0


/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped
	desc = "Still wrapped in some paper."
	icon_state = "monkeycubewrap"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/enchiladas
	name = "enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"

/obj/item/weapon/reagent_containers/food/snacks/enchiladas/New()
	..()
	reagents.add_reagent("nutriment",8)
	reagents.add_reagent("capsaicin", 6)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stew
	name = "stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/stew/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("tomatojuice", 5)
	reagents.add_reagent("imidazoline", 5)
	reagents.add_reagent("water", 5)
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat
	name = "stewed soy meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/carrotfries
	name = "carrot fries"
	desc = "Tasty fries from fresh Carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/carrotfries/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("imidazoline", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candiedapple
	name = "candied apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"

/obj/item/weapon/reagent_containers/food/snacks/candiedapple/New()
	..()
	reagents.add_reagent("nutriment", 3)
	bitesize = 3

/*
/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore
	name = "Boiled slime Core"
	desc = "A boiled red thing."
	icon_state = "boiledslimecore"

/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore/New()
	..()
	reagents.add_reagent("slimejelly", 5)
	bitesize = 3
*/
/obj/item/weapon/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "it is only wafer thin."
	icon_state = "mint"

/obj/item/weapon/reagent_containers/food/snacks/mint/New()
	..()
	reagents.add_reagent("minttoxin", 1)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit/New()
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

/obj/item/weapon/reagent_containers/food/snacks/chawanmushi/New()
	..()
	reagents.add_reagent("nutriment", 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/appletart/New()
	..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("gold", 5)
	bitesize = 3

/////////////////////////////////////////////////Sliceable////////////////////////////////////////
// All the food items that can be sliced into smaller bits like Meatbread and Cheesewheels

//sliceable only changes w class, storage is handled by sliceable/store
/obj/item/weapon/reagent_containers/food/snacks/sliceable
	w_class = 3

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store

/obj/item/weapon/reagent_containers/food/snacks/sliceable/store/attackby(obj/item/weapon/W, mob/user)
	if(W.w_class <= 2)
		if(contents.len)
			return 0
		if(!iscarbon(user))
			return 0
		user << "<span class='notice'>You slip [W] inside [src].</span>"
		user.unEquip(W)
		add_fingerprint(user)
		contents += W
		return 1 // no afterattack here
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel
	name = "cheese wheel"
	desc = "A big wheel of delcious Cheddar."
	icon_state = "cheesewheel"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel/New()
	..()
	reagents.add_reagent("nutriment", 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	name = "cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	name = "watermelon slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cracker
	name = "cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"

/obj/item/weapon/reagent_containers/food/snacks/cracker/New()
	..()
	reagents.add_reagent("nutriment", 1)


////////////////////////////////FOOD ADDITIONS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/wrap
	name = "egg wrap"
	desc = "The precursor to Pigs in a Blanket."
	icon_state = "wrap"

/obj/item/weapon/reagent_containers/food/snacks/wrap/New()
	..()
	reagents.add_reagent("nutriment", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/beans
	name = "tin of beans"
	desc = "Musical fruit in a slightly less musical container."
	icon_state = "beans"

/obj/item/weapon/reagent_containers/food/snacks/beans/New()
	..()
	reagents.add_reagent("nutriment", 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Fresh footlong ready to go down on."
	icon_state = "hotdog"

/obj/item/weapon/reagent_containers/food/snacks/hotdog/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("ketchup", 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be Dog."
	icon_state = "meatbun"

/obj/item/weapon/reagent_containers/food/snacks/meatbun/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	desc = "Just like your little sister used to make."
	icon_state = "sugarcookie"

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/New()
	..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("sugar", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("toxin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spidereggs
	name = "spider eggs"
	desc = "A cluster of juicy spider eggs. A great side dish for when you care not for your health."
	icon_state = "spidereggs"

/obj/item/weapon/reagent_containers/food/snacks/spidereggs/New()
	..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("toxin", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham
	name = "green eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon_state = "spidereggsham"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("toxin", 3)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon_state = "sashimi"

/obj/item/weapon/reagent_containers/food/snacks/sashimi/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("toxin", 5)
	bitesize = 3
