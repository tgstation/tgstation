
// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

//Grown foods
//Subclass so we can pass on values
/obj/item/weapon/reagent_containers/food/snacks/grown/
	var/seed = ""
	var/plantname = ""
	var/productname = ""
	var/species = ""
	var/lifespan = 0
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0
	var/potency = -1
	var/plant_type = 0
	icon = 'icons/obj/harvest.dmi'
	New(newloc,newpotency)
		if (!isnull(newpotency))
			potency = newpotency
		..()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		var/msg
		msg = "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>\n"
		switch(plant_type)
			if(0)
				msg += "- Plant type: <i>Normal plant</i>\n"
			if(1)
				msg += "- Plant type: <i>Weed</i>\n"
			if(2)
				msg += "- Plant type: <i>Mushroom</i>\n"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\reagents\reagent_containers\food\snacks\grown.dm:42: msg += "- Potency: <i>[potency]</i>\n"
		msg += {"- Potency: <i>[potency]</i>\n
			- Yield: <i>[yield]</i>\n
			- Maturation speed: <i>[maturation]</i>\n
			- Production speed: <i>[production]</i>\n
			- Endurance: <i>[endurance]</i>\n
			- Healing properties: <i>[reagents.get_reagent_amount("nutriment")]</i>\n
			*---------*</span>"}
		// END AUTOFIX
		usr << msg
		return

	/*if (istype(O, /obj/item/weapon/storage/bag/plants))
		var/obj/item/weapon/plantbag/S = O
		if (S.mode == 1)
			for(var/obj/item/G in get_turf(src))
				if(istype(G, /obj/item/seeds) || istype(G, /obj/item/weapon/reagent_containers/food/snacks/grown))
					if (S.contents.len < S.capacity)
						S.contents += G
					else
						user << "\blue The plant bag is full."
						return
			user << "\blue You pick up all the plants and seeds."
		else
			if (S.contents.len < S.capacity)
				S.contents += src;
			else
				user << "\blue The plant bag is full."*/
	return

/*/obj/item/seeds/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (istype(O, /obj/item/weapon/storage/bag/plants))
		var/obj/item/weapon/plantbag/S = O
		if (S.mode == 1)
			for(var/obj/item/G in get_turf(src))
				if(istype(G, /obj/item/seeds) || istype(G, /obj/item/weapon/reagent_containers/food/snacks/grown))
					if (S.contents.len < S.capacity)
						S.contents += G
					else
						user << "\blue The plant bag is full."
						return
			user << "\blue You pick up all the plants and seeds."
		else
			if (S.contents.len < S.capacity)
				S.contents += src;
			else
				user << "\blue The plant bag is full."
	return*/

/obj/item/weapon/grown/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		var/msg
		msg = "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>\n"
		switch(plant_type)
			if(0)
				msg += "- Plant type: <i>Normal plant</i>\n"
			if(1)
				msg += "- Plant type: <i>Weed</i>\n"
			if(2)
				msg += "- Plant type: <i>Mushroom</i>\n"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\reagents\reagent_containers\food\snacks\grown.dm:101: msg += "- Acid strength: <i>[potency]</i>\n"
		msg += {"- Acid strength: <i>[potency]</i>\n
			- Yield: <i>[yield]</i>\n
			- Maturation speed: <i>[maturation]</i>\n
			- Production speed: <i>[production]</i>\n
			- Endurance: <i>[endurance]</i>\n
			*---------*</span>"}
		// END AUTOFIX
		usr << msg
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/corn
	seed = "/obj/item/seeds/cornseed"
	name = "ear of corn"
	desc = "Needs some butter!"
	icon_state = "corn"
	potency = 40
	trash = /obj/item/weapon/corncob

	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/cherries
	seed = "/obj/item/seeds/cherryseed"
	name = "cherries"
	desc = "Great for toppings!"
	icon_state = "cherry"
	gender = PLURAL
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 15), 1))
			reagents.add_reagent("sugar", 1+round((potency / 15), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy
	seed = "/obj/item/seeds/poppyseed"
	name = "poppy"
	desc = "Long-used as a symbol of rest, peace, and death."
	icon_state = "poppy"
	potency = 30
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
			reagents.add_reagent("bicaridine", 1+round((potency / 10), 1))
			bitesize = 1+round(reagents.total_volume / 3, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/harebell
	seed = "obj/item/seeds/harebellseed"
	name = "harebell"
	desc = "\"I'll sweeten thy sad grave: thou shalt not lack the flower that's like thy face, pale primrose, nor the azured hare-bell, like thy veins; no, nor the leaf of eglantine, whom not to slander, out-sweeten�d not thy breath.\""
	icon_state = "harebell"
	potency = 1
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
			bitesize = 1+round(reagents.total_volume / 3, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/potato
	seed = "/obj/item/seeds/potatoseed"
	name = "potato"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "potato"
	potency = 25
	New()
		..()
		reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
		spawn(5)	//So potency can be set in the proc that creates these crops
			bitesize = reagents.total_volume

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/cable_coil))
		if(W:amount >= 5)
			W:amount -= 5
			if(!W:amount) del(W)
			user << "<span class='notice'>You add some cable to the potato and slide it inside the battery encasing.</span>"
			var/obj/item/weapon/cell/potato/pocell = new /obj/item/weapon/cell/potato(user.loc)
			pocell.maxcharge = src.potency * 10
			pocell.charge = pocell.maxcharge
			del(src)
			return

/obj/item/weapon/reagent_containers/food/snacks/grown/grapes
	seed = "/obj/item/seeds/grapeseed"
	name = "bunch of grapes"
	desc = "Nutritious!"
	icon_state = "grapes"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			reagents.add_reagent("sugar", 1+round((potency / 5), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes
	seed = "/obj/item/seeds/greengrapeseed"
	name = "bunch of green grapes"
	desc = "Nutritious!"
	icon_state = "greengrapes"
	potency = 25
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			reagents.add_reagent("kelotane", 3+round((potency / 5), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	seed = "/obj/item/seeds/cabbageseed"
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	icon_state = "cabbage"
	potency = 25
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			bitesize = reagents.total_volume

/obj/item/weapon/reagent_containers/food/snacks/grown/berries
	seed = "/obj/item/seeds/berryseed"
	name = "bunch of berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium
	seed = "/obj/item/seeds/plastiseed"
	name = "clump of plastellium"
	desc = "Hmm, needs some processing"
	icon_state = "plastellium"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("plasticide", 1+round((potency / 10), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries
	seed = "/obj/item/seeds/glowberryseed"
	name = "bunch of glow-berries"
	desc = "Nutritious!"
	var/light_on = 1
	var/brightness_on = 2 //luminosity when on
	icon_state = "glowberrypile"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", round((potency / 10), 1))
			reagents.add_reagent("uranium", 3+round(potency / 5, 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries/Destroy()
	if(istype(loc,/mob))
		loc.SetLuminosity(round(loc.luminosity - potency/5,1))
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries/pickup(mob/user)
	src.SetLuminosity(0)
	user.SetLuminosity(round(user.luminosity + (potency/5),1))

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries/dropped(mob/user)
	user.SetLuminosity(round(user.luminosity - (potency/5),1))
	src.SetLuminosity(round(potency/5,1))

/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod
	seed = "/obj/item/seeds/cocoapodseed"
	name = "cocoa pod"
	desc = "Fattening... Mmmmm... chucklate."
	icon_state = "cocoapod"
	potency = 50
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			reagents.add_reagent("coco", 4+round((potency / 5), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane
	seed = "/obj/item/seeds/sugarcaneseed"
	name = "sugarcane"
	desc = "Sickly sweet."
	icon_state = "sugarcane"
	potency = 50
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("sugar", 4+round((potency / 5), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries
	seed = "/obj/item/seeds/poisonberryseed"
	name = "bunch of poison-berries"
	desc = "Taste so good, you could die!"
	icon_state = "poisonberrypile"
	gender = PLURAL
	potency = 15
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1)
			reagents.add_reagent("toxin", 3+round(potency / 5, 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/deathberries
	seed = "/obj/item/seeds/deathberryseed"
	name = "bunch of death-berries"
	desc = "Taste so good, you could die!"
	icon_state = "deathberrypile"
	gender = PLURAL
	potency = 50
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1)
			reagents.add_reagent("toxin", 3+round(potency / 3, 1))
			reagents.add_reagent("lexorin", 1+round(potency / 5, 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris
	seed = "/obj/item/seeds/ambrosiavulgaris"
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	icon_state = "ambrosiavulgaris"
	potency = 10
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1)
			reagents.add_reagent("space_drugs", 1+round(potency / 8, 1))
			reagents.add_reagent("kelotane", 1+round(potency / 8, 1))
			reagents.add_reagent("bicaridine", 1+round(potency / 10, 1))
			reagents.add_reagent("toxin", 1+round(potency / 10, 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/paper))
		del(O)
		user << "<span class='notice'>You roll a blunt.</span>"
		var/obj/item/clothing/mask/cigarette/blunt/rolled/B = new/obj/item/clothing/mask/cigarette/blunt/rolled(src.loc)
		reagents.trans_to(B, (reagents.total_volume))
		user.put_in_hands(B)
		user.drop_from_inventory(src)
		del(src)
	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/cruciatus
	seed = "/obj/item/seeds/ambrosiavulgaris/cruciatus"
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	icon_state = "ambrosiavulgaris"
	potency = 10
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1)
			reagents.add_reagent("space_drugs", 1+round(potency / 8, 1))
			reagents.add_reagent("kelotane", 1+round(potency / 8, 1))
			reagents.add_reagent("bicaridine", 1+round(potency / 10, 1))
			reagents.add_reagent("toxin", 1+round(potency / 10, 1))
			reagents.add_reagent("spiritbreaker", 10)
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/cruciatus/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/paper))
		del(O)
		user << "<span class='notice'>You roll a blunt.</span>"
		var/obj/item/clothing/mask/cigarette/blunt/cruciatus/rolled/B = new/obj/item/clothing/mask/cigarette/blunt/cruciatus/rolled(src.loc)
		reagents.trans_to(B, (reagents.total_volume))
		user.put_in_hands(B)
		user.drop_from_inventory(src)
		del(src)
	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus
	seed = "/obj/item/seeds/ambrosiadeus"
	name = "ambrosia deus branch"
	desc = "Eating this makes you feel immortal!"
	icon_state = "ambrosiadeus"
	potency = 10
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1)
			reagents.add_reagent("bicaridine", 1+round(potency / 8, 1))
			reagents.add_reagent("synaptizine", 1+round(potency / 8, 1))
			reagents.add_reagent("hyperzine", 1+round(potency / 10, 1))
			reagents.add_reagent("space_drugs", 1+round(potency / 10, 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/paper))
		del(O)
		user << "<span class='notice'>You roll a godly blunt.</span>"
		var/obj/item/clothing/mask/cigarette/blunt/deus/rolled/B = new/obj/item/clothing/mask/cigarette/blunt/deus/rolled(src.loc)
		reagents.trans_to(B, (reagents.total_volume))
		user.put_in_hands(B)
		user.drop_from_inventory(src)
		del(src)
	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/apple
	seed = "/obj/item/seeds/appleseed"
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	potency = 15
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.maximum_volume = 20
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			bitesize = reagents.maximum_volume // Always eat the apple in one

/obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned
	seed = "/obj/item/seeds/poisonedappleseed"
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	potency = 15
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.maximum_volume = 20
			reagents.add_reagent("cyanide", 1+round((potency / 5), 1))
			bitesize = reagents.maximum_volume // Always eat the apple in one

/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple
	seed = "/obj/item/seeds/goldappleseed"
	name = "golden apple"
	desc = "Emblazoned upon the apple is the word 'Kallisti'."
	icon_state = "goldapple"
	potency = 15
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			reagents.add_reagent("gold", 1+round((potency / 5), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Mineral Content: <i>[reagents.get_reagent_amount("gold")]%</i></span>"


/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon
	seed = "/obj/item/seeds/watermelonseed"
	name = "watermelon"
	desc = "It's full of watery goodness."
	icon_state = "watermelon"
	potency = 10
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	slices_num = 5
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 6), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
	seed = "/obj/item/seeds/pumpkinseed"
	name = "pumpkin"
	desc = "It's large and scary."
	icon_state = "pumpkin"
	potency = 10
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 6), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || istype(W, /obj/item/weapon/twohanded/fireaxe) || istype(W, /obj/item/weapon/kitchen/utensil/knife) || istype(W, /obj/item/weapon/kitchenknife) || istype(W, /obj/item/weapon/melee/energy))
		user.show_message("<span class='notice'>You carve a face into [src]!</span>", 1)
		new /obj/item/clothing/head/pumpkinhead (user.loc)
		del(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/lime
	seed = "/obj/item/seeds/limeseed"
	name = "lime"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	potency = 20
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/lemon
	seed = "/obj/item/seeds/lemonseed"
	name = "lemon"
	desc = "When life gives you lemons, be grateful they aren't limes."
	icon_state = "lemon"
	potency = 20
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/orange
	seed = "/obj/item/seeds/orangeseed"
	name = "orange"
	desc = "It's an tangy fruit."
	icon_state = "orange"
	potency = 20
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
	seed = "/obj/item/seeds/whitebeetseed"
	name = "white-beet"
	desc = "You can't beat white-beet."
	icon_state = "whitebeet"
	potency = 15
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", round((potency / 20), 1))
			reagents.add_reagent("sugar", 1+round((potency / 5), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/banana
	seed = "/obj/item/seeds/bananaseed"
	name = "banana"
	desc = "It's an excellent prop for a comedy."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana"
	item_state = "banana"
	trash = /obj/item/weapon/bananapeel

	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("banana", 1+round((potency / 10), 1))
			bitesize = 5
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/weapon/reagent_containers/food/snacks/grown/chili
	seed = "/obj/item/seeds/chiliseed"
	name = "chili"
	desc = "It's spicy! Wait... IT'S BURNING ME!!"
	icon_state = "chilipepper"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 25), 1))
			reagents.add_reagent("capsaicin", 3+round(potency / 5, 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/chili/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Capsaicin: <i>[reagents.get_reagent_amount("capsaicin")]%</i></span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chilli
	seed = "/obj/item/seeds/chillighost"
	name = "ghost chili"
	desc = "It seems to be vibrating gently."
	icon_state = "ghostchilipepper"
	var/mob/held_mob
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 25), 1))
			reagents.add_reagent("capsaicin", 8+round(potency / 2, 1))
			reagents.add_reagent("condensedcapsaicin", 4+round(potency / 4, 1))
			bitesize = 1+round(reagents.total_volume / 4, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chilli/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Capsaicin: <i>[reagents.get_reagent_amount("capsaicin")]%</i></span>"
		user << "<span class='info'>- Condensed Capsaicin: <i>[reagents.get_reagent_amount("condensedcapsaicin")]%</i></span>"
/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	seed = "/obj/item/seeds/eggplantseed"
	name = "eggplant"
	desc = "Maybe there's a chicken inside?"
	icon_state = "eggplant"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	seed = "/obj/item/seeds/soyaseed"
	name = "soybeans"
	desc = "It's pretty bland, but oh the possibilities..."
	gender = PLURAL
	icon_state = "soybeans"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans
	seed = "/obj/item/seeds/koiseed"
	name = "koibean"
	desc = "Something about these seems fishy."
	icon_state = "koibeans"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 30), 1))
			reagents.add_reagent("carpotoxin", 1+round((potency / 20), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower
	seed = "/obj/item/seeds/moonflowerseed"
	name = "moonflower"
	desc = "Store in a location at least 50 yards away from werewolves."
	icon_state = "moonflower"
	slot_flags = SLOT_HEAD
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
			reagents.add_reagent("moonshine", 1+round((potency / 10), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	seed = "/obj/item/seeds/tomatoseed"
	name = "tomato"
	desc = "I say to-mah-to, you say tom-mae-to."
	icon_state = "tomato"
	potency = 10
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

	throw_impact(atom/hit_atom)
		..()
		new/obj/effect/decal/cleanable/tomato_smudge(src.loc)
		src.visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
		del(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato
	seed = "/obj/item/seeds/killertomatoseed"
	name = "killer-tomato"
	desc = "I say to-mah-to, you say tom-mae-to... OH GOD IT'S EATING MY LEGS!!"
	icon_state = "killertomato"
	potency = 10
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)
		if(istype(src.loc,/mob))
			pickup(src.loc)
	lifespan = 120
	endurance = 30
	maturation = 15
	production = 1
	yield = 3
	potency = 30
	plant_type = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/space))
		return
	new /mob/living/simple_animal/tomato(user.loc)
	del(src)

	user << "<span class='notice'>You plant the killer-tomato.</span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato
	seed = "/obj/item/seeds/bloodtomatoseed"
	name = "blood-tomato"
	desc = "So bloody...so...very...bloody....AHHHH!!!!"
	icon_state = "bloodtomato"
	potency = 10
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
			reagents.add_reagent("blood", 1+round((potency / 5), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

	throw_impact(atom/hit_atom)
		..()
		new/obj/effect/decal/cleanable/blood/splatter(src.loc)
		src.visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
		src.reagents.reaction(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			src.reagents.reaction(A)
		del(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato
	seed = "/obj/item/seeds/bluetomatoseed"
	name = "blue-tomato"
	desc = "I say blue-mah-to, you say blue-mae-to."
	icon_state = "bluetomato"
	potency = 10
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
			reagents.add_reagent("lube", 1+round((potency / 5), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

	throw_impact(atom/hit_atom)
		..()
		new/obj/effect/decal/cleanable/blood/oil(src.loc)
		src.visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
		src.reagents.reaction(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			src.reagents.reaction(A)
		del(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if (istype(M, /mob/living/carbon/human) && (isobj(M:shoes) && M:shoes.flags&NOSLIP))
			return

		M.stop_pulling()
		M << "\blue You slipped on the [name]!"
		playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(8)
		M.Weaken(5)

/obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	seed = "/obj/item/seeds/wheatseed"
	name = "wheat"
	desc = "Sigh... wheat... a-grain?"
	gender = PLURAL
	icon_state = "wheat"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 25), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk
	seed = "/obj/item/seeds/riceseed"
	name = "rice stalk"
	desc = "Rice to see you."
	gender = PLURAL
	icon_state = "rice"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 25), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod
	seed = "/obj/item/seeds/kudzuseed"
	name = "kudzu pod"
	desc = "<I>Pueraria Virallis</I>: An invasive species with vines that rapidly creep and wrap around whatever they contact."
	icon_state = "kudzupod"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment",1+round((potency / 50), 1))
			reagents.add_reagent("anti_toxin",1+round((potency / 25), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
	seed = "/obj/item/seeds/icepepperseed"
	name = "ice-pepper"
	desc = "It's a mutant strain of chili"
	icon_state = "icepepper"
	potency = 20
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
			reagents.add_reagent("frostoil", 3+round(potency / 5, 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Frostoil: <i>[reagents.get_reagent_amount("frostoil")]%</i></span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	seed = "/obj/item/seeds/carrotseed"
	name = "carrot"
	desc = "It's good for the eyes!"
	icon_state = "carrot"
	potency = 10
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
			reagents.add_reagent("imidazoline", 3+round(potency / 5, 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi
	seed = "/obj/item/seeds/reishimycelium"
	name = "reishi"
	desc = "<I>Ganoderma lucidum</I>: A special fungus believed to help relieve stress."
	icon_state = "reishi"
	potency = 10
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1)
			reagents.add_reagent("stoxin", 3+round(potency / 3, 1))
			reagents.add_reagent("space_drugs", 1+round(potency / 25, 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Sleep Toxin: <i>[reagents.get_reagent_amount("stoxin")]%</i></span>"
		user << "<span class='info'>- Space Drugs: <i>[reagents.get_reagent_amount("space_drugs")]%</i></span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	seed = "/obj/item/seeds/amanitamycelium"
	name = "fly amanita"
	desc = "<I>Amanita Muscaria</I>: Learn poisonous mushrooms by heart. Only pick mushrooms you know."
	icon_state = "amanita"
	potency = 10
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1)
			reagents.add_reagent("amatoxin", 3+round(potency / 3, 1))
			reagents.add_reagent("psilocybin", 1+round(potency / 25, 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Amatoxins: <i>[reagents.get_reagent_amount("amatoxin")]%</i></span>"
		user << "<span class='info'>- Psilocybin: <i>[reagents.get_reagent_amount("psilocybin")]%</i></span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel
	seed = "/obj/item/seeds/angelmycelium"
	name = "destroying angel"
	desc = "<I>Amanita Virosa</I>: Deadly poisonous basidiomycete fungus filled with alpha amatoxins."
	icon_state = "angel"
	potency = 15
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round(potency / 50, 1))
			reagents.add_reagent("amanatin", 1+round(potency / 3, 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Amatoxins: <i>[reagents.get_reagent_amount("amanatin")]%</i></span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap
	seed = "/obj/item/seeds/libertymycelium"
	name = "liberty-cap"
	desc = "<I>Psilocybe Semilanceata</I>: Liberate yourself!"
	icon_state = "libertycap"
	potency = 15
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
			reagents.add_reagent("psilocybin", 3+round(potency / 5, 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap/attackby(var/obj/item/O as obj, var/mob/user as mob)
	. = ..()
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "<span class='info'>- Psilocybin: <i>[reagents.get_reagent_amount("psilocybin")]%</i></span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	seed = "/obj/item/seeds/plumpmycelium"
	name = "plump-helmet"
	desc = "<I>Plumus Hellmus</I>: Plump, soft and s-so inviting~"
	icon_state = "plumphelmet"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 2+round((potency / 10), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	seed = "/obj/item/seeds/walkingmushroom"
	name = "walking mushroom"
	desc = "<I>Plumus Locomotus</I>: The beginning of the great walk."
	icon_state = "walkingmushroom"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 2+round((potency / 10), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)
		if(istype(src.loc,/mob))
			pickup(src.loc)
	lifespan = 120
	endurance = 30
	maturation = 15
	production = 1
	yield = 3
	potency = 30
	plant_type = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/space))
		return
	var/mob/living/simple_animal/hostile/mushroom/M = new /mob/living/simple_animal/hostile/mushroom(user.loc)
	M.maxHealth += round(endurance / 4)
	M.melee_damage_lower += round(potency / 20)
	M.melee_damage_upper += round(potency / 20)
	M.move_to_delay -= round(production / 50)
	M.health = M.maxHealth
	del(src)

	user << "<span class='notice'>You plant the walking mushroom.</span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle
	seed = "/obj/item/seeds/chantermycelium"
	name = "chanterelle cluster"
	desc = "<I>Cantharellus Cibarius</I>: These jolly yellow little shrooms sure look tasty!"
	icon_state = "chanterelle"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment",1+round((potency / 25), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom
	seed = "/obj/item/seeds/glowshroom"
	name = "glowshroom cluster"
	desc = "<I>Mycena Bregprox</I>: This species of mushroom glows in the dark. Or does it?"
	icon_state = "glowshroom"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("radium",1+round((potency / 20), 1))
		if(istype(src.loc,/mob))
			pickup(src.loc)
		else
			src.SetLuminosity(round(potency/10,1))
	lifespan = 120 //ten times that is the delay
	endurance = 30
	maturation = 15
	production = 1
	yield = 3
	potency = 30
	plant_type = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/attack_self(mob/user as mob)
	if(istype(user.loc,/turf/space))
		return
	var/obj/effect/glowshroom/planted = new /obj/effect/glowshroom(user.loc)

	planted.delay = lifespan * 50
	planted.endurance = endurance
	planted.yield = yield
	planted.potency = potency
	del(src)

	user << "<span class='notice'>You plant the glowshroom.</span>"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/Destroy()
	if(istype(loc,/mob))
		loc.SetLuminosity(round(loc.luminosity - potency/10,1))
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/pickup(mob/user)
	SetLuminosity(0)
	user.SetLuminosity(round(user.luminosity + (potency/10),1))

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/dropped(mob/user)
	user.SetLuminosity(round(user.luminosity + (potency/10),1))
	SetLuminosity(round(potency/10,1))


// *************************************
// Complex Grown Object Defines -
// Putting these at the bottom so they don't clutter the list up. -Cheridan
// *************************************

/*
//This object is just a transition object. All it does is make a grass tile and delete itself.
/obj/item/weapon/reagent_containers/food/snacks/grown/grass
	seed = "/obj/item/seeds/grassseed"
	name = "grass"
	desc = "Green and lush."
	icon_state = "spawner"
	potency = 20
	New()
		new/obj/item/stack/tile/grass(src.loc)
		spawn(5) //Workaround to keep harvesting from working weirdly.
			del(src)
*/

//This object is just a transition object. All it does is make dosh and delete itself. -Cheridan
/obj/item/weapon/reagent_containers/food/snacks/grown/money
	seed = "/obj/item/seeds/cashseed"
	name = "dosh"
	desc = "Green and lush."
	icon_state = "spawner"
	potency = 10
	New()
		..()
		dispense_cash(rand(1,100)*10,src.loc)//(potency) //It wants to use the default potency instead of the new, so it was always 10. Will try to come back to this later - Cheridan
		spawn(5) //Workaround to keep harvesting from working weirdly.
			del(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/meat
	seed = "/obj/item/seeds/synthmeatseed"
	name = "synthmeat"
	desc = "Tasty?"
	icon_state = "spawner"
	potency = 10
	New()
		..()
		new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(src.loc)
		spawn(5) //Workaround to keep harvesting from working weirdly.
			del(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/butt
	seed = "/obj/item/seeds/synthbuttseed"
	name = "synthbutt"
	desc = "Tasty?"
	icon_state = "spawner"
	potency = 10
	New()
		..()
		new /obj/item/clothing/head/butt(src.loc)
		spawn(5) //Workaround to keep harvesting from working weirdly.
			del(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/brain
	seed = "/obj/item/seeds/synthbrainseed"
	name = "synthmeat"
	desc = "Tasty?"
	icon_state = "spawner"
	potency = 10
	New()
		..()
		new /obj/item/organ/brain(src.loc)
		spawn(5) //Workaround to keep harvesting from working weirdly.
			del(src)


/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato
	seed = "/obj/item/seeds/bluespacetomatoseed"
	name = "blue-space tomato"
	desc = "So lubricated, you might slip through space-time."
	icon_state = "bluespacetomato"
	potency = 20
	origin_tech = "bluespace=3"
	New()
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
			reagents.add_reagent("singulo", 1+round((potency / 5), 1))
			bitesize = 1+round(reagents.total_volume / 2, 1)

	throw_impact(atom/hit_atom)
		..()
		var/mob/M = usr
		var/outer_teleport_radius = potency/10 //Plant potency determines radius of teleport.
		var/inner_teleport_radius = potency/15
		var/list/turfs = new/list()
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		if(inner_teleport_radius < 1) //Wasn't potent enough, it just splats.
			new/obj/effect/decal/cleanable/blood/oil(src.loc)
			src.visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
			del(src)
			return
		for(var/turf/T in orange(M,outer_teleport_radius))
			if(T in orange(M,inner_teleport_radius)) continue
			if(istype(T,/turf/space)) continue
			if(T.density) continue
			if(T.x>world.maxx-outer_teleport_radius || T.x<outer_teleport_radius)	continue
			if(T.y>world.maxy-outer_teleport_radius || T.y<outer_teleport_radius)	continue
			turfs += T
		if(!turfs.len)
			var/list/turfs_to_pick_from = list()
			for(var/turf/T in orange(M,outer_teleport_radius))
				if(!(T in orange(M,inner_teleport_radius)))
					turfs_to_pick_from += T
			turfs += pick(/turf in turfs_to_pick_from)
		var/turf/picked = pick(turfs)
		if(!isturf(picked)) return
		switch(rand(1,2))//Decides randomly to teleport the thrower or the throwee.
			if(1) // Teleports the person who threw the tomato.
				s.set_up(3, 1, M)
				s.start()
				new/obj/effect/decal/cleanable/molten_item(M.loc) //Leaves a pile of goo behind for dramatic effect.
				M.loc = picked //
				sleep(1)
				s.set_up(3, 1, M)
				s.start() //Two set of sparks, one before the teleport and one after.
			if(2) //Teleports mob the tomato hit instead.
				for(var/mob/A in get_turf(hit_atom))//For the mobs in the tile that was hit...
					s.set_up(3, 1, A)
					s.start()
					new/obj/effect/decal/cleanable/molten_item(A.loc) //Leave a pile of goo behind for dramatic effect...
					A.loc = picked//And teleport them to the chosen location.
					sleep(1)
					s.set_up(3, 1, A)
					s.start()
		new/obj/effect/decal/cleanable/blood/oil(src.loc)
		src.visible_message("<span class='notice'>The [src.name] has been squashed, causing a distortion in space-time.</span>","<span class='moderate'>You hear a splat and a crackle.</span>")
		del(src)
		return
