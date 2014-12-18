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

		var/fullness = M.nutrition + 10
		for(var/datum/reagent/consumable/C in M.reagents.reagent_list) //we add the nutrition value of what we're currently digesting
			fullness += C.nutriment_factor * C.volume / C.metabolization_rate

		if(M == user)								//If you're eating it yourself.
			if(src.reagents.has_reagent("sugar") && M.satiety < -150 && M.nutrition > NUTRITION_LEVEL_STARVING + 50 )
				M << "<span class='notice'>You don't feel like eating any more sugary food at the moment.</span>"
				return 0

			if(wrapped)
				M << "<span class='notice'>You can't eat wrapped food!</span>"
				return 0
			else if(fullness <= 50)
				M << "<span class='notice'>You hungrily [eatverb] some of \the [src] and gobble it down!</span>"
			else if(fullness > 50 && fullness < 150)
				M << "<span class='notice'>You hungrily begin to [eatverb] \the [src].</span>"
			else if(fullness > 150 && fullness < 500)
				M << "<span class='notice'>You [eatverb] \the [src].</span>"
			else if(fullness > 500 && fullness < 600)
				M << "<span class='notice'>You unwillingly [eatverb] a bit of \the [src].</span>"
			else if(fullness > (600 * (1 + M.overeatduration / 2000)))	// The more you eat - the more you can eat
				M << "<span class='notice'>You cannot force any more of \the [src] to go down your throat.</span>"
				return 0
		else
			if(! (isslime(M) || isbrain(M)) )		//If you're feeding it to someone else.
				if(wrapped)
					return 0
				if(fullness <= (600 * (1 + M.overeatduration / 1000)))
					M.visible_message("<span class='danger'>[user] attempts to feed [M] [src].</span>", \
										"<span class='userdanger'>[user] attempts to feed [M] [src].</span>")
				else
					M.visible_message("<span class='danger'>[user] cannot force anymore of [src] down [M]'s throat!</span>", \
										"<span class='userdanger'>[user] cannot force anymore of [src] down [M]'s throat!</span>")
					return 0

				if(!do_mob(user, M))
					return
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
				M.emote("me", 1, "nibbles away at \the [src]")
			bitecount++
			if(bitecount >= 5)
				var/sattisfaction_text = pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where \the [src] was")
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

//All foods (except slicable, since they have unique procs) are distributed among various categories. Use common sense.

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
	reagents.add_reagent("vitamin", 5)
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