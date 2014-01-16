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


	//Placeholder for effect that trigger on eating that aren't tied to reagents.
/obj/item/weapon/reagent_containers/food/snacks/proc/On_Consume()
	if(!usr)	return
	if(!reagents.total_volume)
		usr.drop_from_inventory(src)	//so icons update :[

		if(trash)
			if(ispath(trash,/obj/item))
				var/obj/item/TrashItem = new trash(usr)
				usr.put_in_hands(TrashItem)
			else if(istype(trash,/obj/item))
				usr.put_in_hands(trash)
		del(src)
	return


/obj/item/weapon/reagent_containers/food/snacks/attack_self(mob/user)
	return


/obj/item/weapon/reagent_containers/food/snacks/attack(mob/M, mob/user, def_zone)
	if(!eatverb)
		eatverb = pick("bite","chew","nibble","gnaw","gobble","chomp")
	if(!reagents.total_volume)						//Shouldn't be needed but it checks to see if it has anything left in it.
		user << "<span class='notice'>None of [src] left, oh no!</span>"
		M.drop_from_inventory(src)	//so icons update :[
		del(src)
		return 0
	if(istype(M, /mob/living/carbon))
		if(M == user)								//If you're eating it yourself.
			var/fullness = M.nutrition + (M.reagents.get_reagent_amount("nutriment") * 25)
			if(wrapped)
				M << "<span class='notice'>You can't eat wrapped food!</span>"
				return 0
			else if(fullness <= 50)
				M << "<span class='notice'>You hungrily [eatverb] some of the [src] and gobble it down!</span>"
			else if(fullness > 50 && fullness < 150)
				M << "<span class='notice'>You hungrily begin to [eatverb] the [src].</span>"
			else if(fullness > 150 && fullness < 350)
				M << "<span class='notice'>You [eatverb] the [src].</span>"
			else if(fullness > 350 && fullness < 550)
				M << "<span class='notice'>You unwillingly [eatverb] a bit of the [src].</span>"
			else if(fullness > (550 * (1 + M.overeatduration / 2000)))	// The more you eat - the more you can eat
				M << "<span class='notice'>You cannot force any more of the [src] to go down your throat.</span>"
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

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")

				log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

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


/obj/item/weapon/reagent_containers/food/snacks/examine()
	set src in view()
	..()
	if(!(usr in range(1)) && usr != loc)
		return
	if(bitecount == 0)
		return
	else if(bitecount == 1)
		usr << "[src] was bitten by someone!"
	else if(bitecount <= 3)
		usr << "[src] was bitten [bitecount] times!"
	else
		usr << "[src] was bitten multiple times!"


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
	else if(W.w_class <= 2 && istype(src,/obj/item/weapon/reagent_containers/food/snacks/sliceable))
		if(!iscarbon(user))
			return 0
		user << "<span class='notice'>You slip [W] inside [src].</span>"
		user.u_equip(W)
		if ((user.client && user.s_active != src))
			user.client.screen -= W
		W.dropped(user)
		add_fingerprint(user)
		contents += W
		return 1 // no afterattack here
	else
		return 0 // --- this is everything that is NOT a slicing implement, and which is not being slipped into food; allow afterattack ---

	if ( \
			!isturf(src.loc) || \
			!(locate(/obj/structure/table) in src.loc) && \
			!(locate(/obj/structure/optable) in src.loc) && \
			!(locate(/obj/item/weapon/tray) in src.loc) \
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
	del(src) // so long and thanks for all the fish


/obj/item/weapon/reagent_containers/food/snacks/Del()
	if(contents)
		for(var/atom/movable/something in contents)
			something.loc = get_turf(src)
	..()


/obj/item/weapon/reagent_containers/food/snacks/attack_animal(mob/M)
	if(isanimal(M))
		if(iscorgi(M))
			if(bitecount == 0 || prob(50))
				M.emote("nibbles away at the [src]")
			bitecount++
			if(bitecount >= 5)
				var/sattisfaction_text = pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where the [src] was")
				if(sattisfaction_text)
					M.emote("[sattisfaction_text]")
				del(src)


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




/obj/item/weapon/reagent_containers/food/snacks/aesirsalad
	name = "\improper Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		eatverb = pick("crunch","devour","nibble","gnaw","gobble","chomp")
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("tricordrazine", 8)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	New()
		..()
		reagents.add_reagent("nutriment", 1)
		reagents.add_reagent("sugar", 3)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Can be stored in a detective's hat."
	icon_state = "candy_corn"
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("sugar", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	trash = /obj/item/trash/chips
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		bitesize = 1

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
		user << "<span class='notice'>You remove the foil.</span>"
		wrapped = 0


/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/wrapped
	desc = "It's wrapped in some foil."
	icon_state = "chocolatebar"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg
	name = "chocolate egg"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolateegg"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("sugar", 2)
		reagents.add_reagent("coco", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	icon_state = "donut1"

/obj/item/weapon/reagent_containers/food/snacks/donut/normal
	desc = "Goes great with Robust Coffee."
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
	name = "chaos donut"
	desc = "Like life, it never quite tastes the same."
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

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	New()
		..()
		reagents.add_reagent("nutriment", 1)

	throw_impact(atom/hit_atom)
		..()
		new/obj/effect/decal/cleanable/egg_smudge(src.loc)
		reagents.reaction(hit_atom, TOUCH)
		del(src)

	attackby(obj/item/weapon/W as obj, mob/user as mob)
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
	New()
		..()
		reagents.add_reagent("nutriment", 2)

// /obj/item/weapon/reagent_containers/food/snacks/flour //Has been converted into a reagent. Use that instead of the item!

/obj/item/weapon/reagent_containers/food/snacks/tofu
	name = "tofu"
	desc = "We all love tofu."
	icon_state = "tofu"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat"
	icon_state = "fishfillet"
	New()
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

/obj/item/weapon/reagent_containers/food/snacks/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	New()
		..()
		reagents.add_reagent("nutriment", 12)
		reagents.add_reagent("hyperzine", 5)
		src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/xenomeat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "xenomeat"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		src.bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/faggot
	name = "faggot"
	desc = "A great meal all round. Not a cord of wood."
	icon_state = "faggot"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	New()
		..()
		eatverb = pick("bite","chew","nibble","deep throat","gobble","chomp")
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
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

/obj/item/weapon/reagent_containers/food/snacks/human/burger
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/appendixburger
	name = "appendix burger"
	desc = "Tastes like appendicitis."
	icon_state = "hburger"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fishburger
	name = "fillet -o- carp sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
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
	trash = /obj/item/trash/plate

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 1

	attackby(obj/item/weapon/W, mob/user)
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
				del(src)

/obj/item/weapon/reagent_containers/food/snacks/muffin
	name = "muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"
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

/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("banana",5)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/pie_smudge(src.loc)
	del(src)

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/plate
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
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm
	name = "eggplant parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	name = "\improper Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	name = "\improper Soylent Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/meatpie
	name = "meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofupie
	name = "tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	New()
		..()
		reagents.add_reagent("nutriment", 5)
		reagents.add_reagent("amatoxin", 3)
		reagents.add_reagent("psilocybin", 1)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	New()
		..()
		if(prob(10))
			name = "exceptional plump pie"
			desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
			reagents.add_reagent("nutriment", 8)
			reagents.add_reagent("tricordrazine", 5)
			bitesize = 2
		else
			reagents.add_reagent("nutriment", 8)
			bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/xemeatpie
	name = "xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu
	name = "wing fang chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/human/kabob
	name = "-kabob"
	icon_state = "kabob"
	desc = "A human meat, on a stick."
	trash = /obj/item/stack/rods
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeykabob
	name = "meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofukabob
	name = "tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "\improper Cuban carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
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
	New()
		..()
		eatverb = pick("bite","crunch","nibble","gnaw","gobble","chomp")
		unpopped = rand(1,10)
		reagents.add_reagent("nutriment", 2)
		bitesize = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0
	On_Consume()
		if(prob(unpopped))	//lol ...what's the point? << AINT SO POINTLESS NO MORE
			usr << "\red You bite down on an un-popped kernel, and it hurts your teeth!"
			unpopped = max(0, unpopped-1)
			reagents.add_reagent("sacid",0.1) //only a little tingle.
		..()


/obj/item/weapon/reagent_containers/food/snacks/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash = /obj/item/trash/sosjerky
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

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie
	name = "space twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer then you will."
	New()
		..()
		reagents.add_reagent("sugar", 4)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers
	name = "cheesie honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	icon_state = "cheesie_honkers"
	trash = /obj/item/trash/cheesie
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/syndicake
	name = "syndi-cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	trash = /obj/item/trash/syndi_cakes
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("doctorsdelight", 5)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato
	name = "loaded baked potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fries
	name = "space fries"
	desc = "AKA: French Fries, Freedom Fries, etc"
	icon_state = "fries"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soydope
	name = "soy dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spagetti
	name = "spagetti"
	desc = "Now thats a nice pasta!"
	icon_state = "spagetti"
	New()
		..()
		reagents.add_reagent("nutriment", 1)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries
	name = "cheesy fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	name = "fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/badrecipe
	name = "burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	New()
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
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("sodiumchloride", 1)
		reagents.add_reagent("blackpepper", 1)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff
	name = "spacy liberty duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook"
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("psilocybin", 6)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	name = "amanita jelly"
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
	name = "poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bitesize = 2
	New()
		..()
		reagents.add_reagent("nutriment", 5)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatballsoup
	name = "meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("water", 5)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/slimesoup
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("slimejelly", 5)
		reagents.add_reagent("water", 10)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/bloodsoup
	name = "tomato soup"
	desc = "Smells like copper"
	icon_state = "tomatosoup"
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("blood", 10)
		reagents.add_reagent("water", 5)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/clownstears
	name = "clown's tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("banana", 5)
		reagents.add_reagent("water", 10)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/vegetablesoup
	name = "vegetable soup"
	desc = "A true vegan meal"
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("water", 5)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/nettlesoup
	name = "nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("water", 5)
		reagents.add_reagent("tricordrazine", 5)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/mysterysoup
	name = "mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		switch(rand(1,10))
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
	name = "wish soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("water", 10)
		bitesize = 5
		if(prob(25))
			desc = "A wish come true!"
			reagents.add_reagent("nutriment", 8)

/obj/item/weapon/reagent_containers/food/snacks/hotchili
	name = "hot chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("capsaicin", 3)
		reagents.add_reagent("tomatojuice", 2)
		bitesize = 5


/obj/item/weapon/reagent_containers/food/snacks/coldchili
	name = "cold chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("frostoil", 3)
		reagents.add_reagent("tomatojuice", 2)
		bitesize = 5

/* No more of this
/obj/item/weapon/reagent_containers/food/snacks/telebacon
	name = "tele bacon"
	desc = "It tastes a little odd but it is still delicious."
	icon_state = "bacon"
	var/obj/item/device/radio/beacon/bacon/baconbeacon
	bitesize = 2
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		baconbeacon = new /obj/item/device/radio/beacon/bacon(src)
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
	wrapped = 0

	New()
		..()
		reagents.add_reagent("nutriment",10)

	afterattack(obj/O, mob/user,proximity)
		if(!proximity) return
		if(istype(O,/obj/structure/sink) && !wrapped)
			user << "<span class='notice'>You place [src] under a stream of water...</span>"
			user.drop_item()
			loc = get_turf(O)
			return Expand()
		..()

	attack_self(mob/user)
		if(wrapped)
			Unwrap(user)

	proc/Expand()
		visible_message("<span class='notice'>[src] expands!</span>")
		new /mob/living/carbon/monkey(get_turf(src))
		del(src)

	proc/Unwrap(mob/user)
		icon_state = "monkeycube"
		desc = "Just add water!"
		user << "<span class='notice'>You unwrap the cube.</span>"
		wrapped = 0


/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped
	desc = "Still wrapped in some paper."
	icon_state = "monkeycubewrap"
	wrapped = 1


/obj/item/weapon/reagent_containers/food/snacks/spellburger
	name = "spell burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger
	name = "big bite burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	New()
		..()
		reagents.add_reagent("nutriment", 14)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/enchiladas
	name = "enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	New()
		..()
		reagents.add_reagent("nutriment",8)
		reagents.add_reagent("capsaicin", 6)
		bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's delight"
	desc = "A delicious soup with dumplings and hunks of monkey meat simmered to perfection, in a broth that tastes faintly of bananas."
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		reagents.add_reagent("nutriment", 10)
		reagents.add_reagent("banana", 5)
		reagents.add_reagent("blackpepper", 1)
		reagents.add_reagent("sodiumchloride", 1)
		bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/baguette
	name = "baguette"
	desc = "Bon appetit!"
	icon_state = "baguette"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("blackpepper", 1)
		reagents.add_reagent("sodiumchloride", 1)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishandchips
	name = "fish and chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("carpotoxin", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sandwich
	name = "sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich
	name = "toasted sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("carbon", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/grilledcheese
	name = "grilled cheese sandwich"
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 7)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tomatosoup
	name = "tomato soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("nutriment", 5)
		reagents.add_reagent("tomatojuice", 10)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	name = "roffle waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("psilocybin", 8)
		bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stew
	name = "stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("nutriment", 10)
		reagents.add_reagent("tomatojuice", 5)
		reagents.add_reagent("imidazoline", 5)
		reagents.add_reagent("water", 5)
		bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast
	name = "jellied toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	trash = /obj/item/trash/plate
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
	name = "jelly burger"
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
	name = "milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/snack_bowl
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("water", 5)
		bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat
	name = "stewed soy meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	New()
		..()
		eatverb = pick("slurp","sip","suck","inhale","drink")
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledspagetti
	name = "boiled spagetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spagettiboiled"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pastatomato
	name = "spagetti"
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

/obj/item/weapon/reagent_containers/food/snacks/meatballspagetti
	name = "spagetti and meatballs"
	desc = "Now thats a nic'e meatball!"
	icon_state = "meatballspagetti"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spesslaw
	name = "spesslaw"
	desc = "A lawyers favourite"
	icon_state = "spesslaw"
	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/carrotfries
	name = "carrot fries"
	desc = "Tasty fries from fresh Carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/plate
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("imidazoline", 3)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/superbiteburger
	name = "super bite burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	New()
		..()
		reagents.add_reagent("nutriment", 40)
		bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/candiedapple
	name = "candied apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/applepie
	name = "apple pie"
	desc = "A pie containing sweet sweet love...or apple."
	icon_state = "applepie"
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/cherrypie
	name = "cherry pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	New()
		..()
		reagents.add_reagent("nutriment", 4)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/twobread
	name = "two bread"
	desc = "This seems awfully bitter."
	icon_state = "twobread"
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich
	name = "jelly sandwich"
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
		eatverb = pick("slurp","sip","suck","inhale","drink")
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
	New()
		..()
		reagents.add_reagent("nutriment", 5)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	trash = /obj/item/trash/snack_bowl
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

/obj/item/weapon/reagent_containers/food/snacks/sliceable/xenomeatbread
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice
	slices_num = 5
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

/obj/item/weapon/reagent_containers/food/snacks/sliceable/braincake
	name = "brain cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/braincakeslice
	slices_num = 5
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

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesecake
	name = "cheese cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesecakeslice
	slices_num = 5
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

/obj/item/weapon/reagent_containers/food/snacks/sliceable/plaincake
	name = "vanilla cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/plaincakeslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/plaincakeslice
	name = "vanilla cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/orangecake
	name = "orange cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/orangecakeslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/orangecakeslice
	name = "orange cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/limecake
	name = "lime cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/limecakeslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/limecakeslice
	name = "lime cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/lemoncake
	name = "lemon cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice
	name = "lemon cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/chocolatecake
	name = "chocolate cake"
	desc = "A cake with added chocolate"
	icon_state = "chocolatecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 20)

/obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice
	name = "chocolate cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel
	name = "cheese wheel"
	desc = "A big wheel of delcious Cheddar."
	icon_state = "cheesewheel"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 20)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	name = "cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake
	name = "birthday cake"
	desc = "Happy Birthday little clown..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/birthdaycakeslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 20)
		reagents.add_reagent("sprinkles", 10)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/birthdaycakeslice
	name = "birthday cake slice"
	desc = "A slice of your birthday."
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread
	name = "bread"
	icon_state = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/breadslice
	name = "bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/sliceable/creamcheesebread
	name = "cream cheese bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 20)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice
	name = "cream cheese bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	trash = /obj/item/trash/plate
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	name = "watermelon slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/sliceable/applecake
	name = "apple cake"
	desc = "A cake centred with Apple"
	icon_state = "applecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/applecakeslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 15)

/obj/item/weapon/reagent_containers/food/snacks/applecakeslice
	name = "apple cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	trash = /obj/item/trash/plate
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	New()
		..()
		reagents.add_reagent("nutriment", 15)

/obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	bitesize = 2



/////////////////////////////////////////////////PIZZA////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza
	slices_num = 6

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita
	name = "margherita"
	desc = "The most cheezy pizza in galaxy"
	icon_state = "pizzamargherita"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/margheritaslice
	slices_num = 6
	New()
		..()
		reagents.add_reagent("nutriment", 40)
		reagents.add_reagent("tomatojuice", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/margheritaslice
	name = "margherita slice"
	desc = "A slice of the most cheezy pizza in galaxy"
	icon_state = "pizzamargheritaslice"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza
	name = "meatpizza"
	desc = "" //TODO:
	icon_state = "meatpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice
	slices_num = 6
	New()
		..()
		reagents.add_reagent("nutriment", 50)
		reagents.add_reagent("tomatojuice", 6)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice
	name = "meatpizza slice"
	desc = "A slice of " //TODO:
	icon_state = "meatpizzaslice"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza
	name = "mushroom pizza"
	desc = "Very special pizza"
	icon_state = "mushroompizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/mushroompizzaslice
	slices_num = 6
	New()
		..()
		reagents.add_reagent("nutriment", 35)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mushroompizzaslice
	name = "mushroom pizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza
	name = "vegetable pizza"
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
	name = "vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients "
	icon_state = "vegetablepizzaslice"
	bitesize = 2

/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food.dmi'
	icon_state = "pizzabox1"
	var/open = 0 // Is the box open?
	var/ismessy = 0 // Fancy mess on the lid
	var/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/pizza // Content pizza
	var/list/boxes = list() // If the boxes are stacked, they come here
	var/boxtag = ""

/obj/item/pizzabox/update_icon()
	overlays = list()

	// Set appropriate description
	if(open && pizza)
		desc = "A box suited for pizzas. It appears to have [pizza] inside."
	else if(boxes.len > 0)
		desc = "A pile of boxes suited for pizzas. There appears to be [boxes.len + 1] boxes in the pile."

		var/obj/item/pizzabox/topbox = boxes[boxes.len]
		var/toptag = topbox.boxtag
		if(toptag != "")
			desc = "[desc] The box on top has a tag, it reads: '[toptag]'."
	else
		desc = "A box suited for pizzas."

		if(boxtag != "")
			desc = "[desc] The box has a tag, it reads: '[boxtag]'."

	// Icon states and overlays
	if(open)
		if(ismessy)
			icon_state = "pizzabox_messy"
		else
			icon_state = "pizzabox_open"

		if(pizza)
			var/image/pizzaimg = image("food.dmi", icon_state = pizza.icon_state)
			pizzaimg.pixel_y = -3
			overlays += pizzaimg

		return
	else
		// Stupid code because byondcode sucks
		var/doimgtag = 0
		if(boxes.len > 0)
			var/obj/item/pizzabox/topbox = boxes[boxes.len]
			if( topbox.boxtag != "" )
				doimgtag = 1
		else
			if(boxtag != "")
				doimgtag = 1

		if(doimgtag)
			var/image/tagimg = image("food.dmi", icon_state = "pizzabox_tag")
			tagimg.pixel_y = boxes.len * 3
			overlays += tagimg

	icon_state = "pizzabox[boxes.len+1]"


/obj/item/pizzabox/attack_hand(mob/user)
	if(open && pizza)
		user.put_in_hands( pizza )

		user << "<span class='notice'>You take the [pizza] out of [src].</span>"
		pizza = null
		update_icon()
		return

	if(boxes.len > 0)
		if(user.get_inactive_hand() != src)
			..()
			return

		var/obj/item/pizzabox/box = boxes[boxes.len]
		boxes -= box

		user.put_in_hands(box)
		user << "<span class='notice'>You remove the topmost [src.name] from your hand.</span>"
		box.update_icon()
		update_icon()
		return
	..()

/obj/item/pizzabox/attack_self(mob/user)
	if(boxes.len > 0 )
		return

	open = !open

	if(open && pizza)
		ismessy = 1

	update_icon()


/obj/item/pizzabox/attackby(obj/item/I, mob/user)
	if( istype(I, /obj/item/pizzabox/) )
		var/obj/item/pizzabox/box = I

		if(!box.open && !open)
			// Make a list of all boxes to be added
			var/list/boxestoadd = list()
			boxestoadd += box
			for(var/obj/item/pizzabox/i in box.boxes)
				boxestoadd += i

			if((boxes.len+1) + boxestoadd.len <= 5)
				user.drop_item()

				box.loc = src
				box.boxes = list() // Clear the box boxes so we don't have boxes inside boxes. - Xzibit
				boxes.Add( boxestoadd )

				box.update_icon()
				update_icon()

				user << "<span class='notice'>You put [box] on top of [src]!</span>"
			else
				user << "<span class='notice'>The stack is dangerously high!</span>"
		else
			user << "<span class='notice'>Close [box] first!</span>"

		return

	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/)) // Long ass fucking object name
		if(open)
			user.drop_item()
			I.loc = src
			pizza = I

			update_icon()

			user << "<span class='notice'>You put [I] in [src].</span>"
		else
			user << "<span class='notice'>You try to push [I] through the lid but it doesn't work!</span>"
		return

	if(istype(I, /obj/item/weapon/pen/))
		if(open )
			return

		var/t = input("Enter what you want to add to the tag:", "Write", null, null) as text

		var/obj/item/pizzabox/boxtotagto = src
		if(boxes.len > 0)
			boxtotagto = boxes[boxes.len]

		boxtotagto.boxtag = copytext("[boxtotagto.boxtag][t]", 1, 30)

		update_icon()
		return
	..()

/obj/item/weapon/reagent_containers/food/snacks/cracker
	name = "cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"

	New()
		..()
		reagents.add_reagent("nutriment", 1)


////////////////////////////////FOOD ADDITIONS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/wrap
	name = "egg wrap"
	desc = "The precursor to Pigs in a Blanket."
	icon_state = "wrap"
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
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Fresh footlong ready to go down on."
	icon_state = "hotdog"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("ketchup", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be Dog."
	icon_state = "meatbun"
	New()
		..()
		reagents.add_reagent("nutriment", 6)
		bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in it's own packaging."
	icon_state = "icecreamsandwich"
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
	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("sugar", 5)
		bitesize = 2