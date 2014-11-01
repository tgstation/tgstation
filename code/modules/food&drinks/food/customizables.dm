
//**************************************************************
//
// Customizable Food
// ---------------------------
// Did the best I could. Still tons of duplication.
// Part of it is due to shitty reagent system.
// Other part due to limitations of attackby().
//
//**************************************************************

// Various Snacks //////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/breadslice/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/A = new/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich(get_turf(src),I)
		A.attackby(I, user)
		qdel(src)
	else . = ..()
	return

/obj/item/weapon/reagent_containers/food/snacks/bun/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/A = new/obj/item/weapon/reagent_containers/food/snacks/customizable/burger(get_turf(src),I)
		A.attackby(I, user)
		qdel(src)
	else . = ..()
	return

/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/A = new/obj/item/weapon/reagent_containers/food/snacks/customizable/pizza(get_turf(src),I)
		A.attackby(I, user)
		qdel(src)
	else . = ..()
	return

/obj/item/weapon/reagent_containers/food/snacks/boiledspagetti/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/A = new/obj/item/weapon/reagent_containers/food/snacks/customizable/pasta(get_turf(src),I)
		A.attackby(I, user)
		qdel(src)
	else . = ..()
	return

// Custom Meals ////////////////////////////////////////////////

/obj/item/trash/plate/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		new/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom(get_turf(src),I)
		qdel(src)
	else . = ..()
	return

/obj/item/trash/bowl
	name = "bowl"
	desc = "An empty bowl. Put some food in it to start making a soup."
	icon = 'icons/obj/food.dmi'
	icon_state = "soup"

/obj/item/trash/bowl/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/shard) || istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		new/obj/item/weapon/reagent_containers/food/snacks/customizable/soup(get_turf(src),I)
		qdel(src)
	else . = ..()
	return

// Customizable Foods //////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/customizable
	trash = /obj/item/trash/plate
	bitesize = 2

	var/ingMax = 600
	var/list/ingredients = list()
	var/stackIngredients = 0
	var/fullyCustom = 0
	var/addTop = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/New(loc,ingredient)
	. = ..()
	src.reagents.add_reagent("nutriment",8)
	src.update()
	return

/obj/item/weapon/reagent_containers/food/snacks/customizable/attackby(obj/item/I,mob/user)
	if((src.contents.len >= src.ingMax) || (src.contents.len >= ingredientLimit))
		user << "<span class='warning'>How about no.</span>"
	else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/S = I
		if(user)
			user.drop_item()
		S.loc = src
		src.ingredients += S
		S.reagents.trans_to(src,S.reagents.total_volume)
		src.update()
		if(user)
			user << "<span class='notice'>You add the [I.name] to the [src.name].</span>"
	else . = ..()
	return

/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/update()
	var/fullname = "" //We need to build this from the contents of the var.
	var/i = 0

	overlays.Cut()

	for(var/obj/item/weapon/reagent_containers/food/snacks/O in ingredients)

		i++
		if(i == 1)
			fullname += "[O.name]"
		else if(i == ingredients.len)
			fullname += " and [O.name]"
		else
			fullname += ", [O.name]"

		if(!fullyCustom)
			var/image/I = new(src.icon, "[src.icon_state]_filling")
			if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
				var/obj/item/weapon/reagent_containers/food/snacks/food = O
				if(!food.filling_color == "#FFFFFF")
					I.color = food.filling_color
				else
					I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
			if(stackIngredients)
				I.pixel_x = pick(list(-1,0,1))
				I.pixel_y = (i*2)+1
			overlays += I
		else
			var/image/F = new(O.icon, O.icon_state)
			F.pixel_x = pick(list(-1,0,1))
			F.pixel_y = pick(list(-1,0,1))
			overlays += F
			overlays += O.overlays

	if(addTop)
		var/image/T = new(src.icon, "[src.icon_state]_top")
		T.pixel_x = pick(list(-1,0,1))
		T.pixel_y = (ingredients.len * 2)+1
		overlays += T

	name = lowertext("[fullname] [initial(src.name)]")
	if(length(name) > 80) name = "[pick(list("absurd","colossal","enormous","ridiculous","massive","oversized","cardiac-arresting","pipe-clogging","edible but sickening","sickening","gargantuan","mega","belly-burster","chest-burster"))] [initial(src.name)]"
	w_class = n_ceil(Clamp((ingredients.len/2),1,3))

/obj/item/weapon/reagent_containers/food/snacks/customizable/Destroy()
	for(. in src.ingredients) qdel(.)
	return ..()

// Sandwiches //////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich
	name = "sandwich"
	desc = "A timeless classic."
	icon_state = "breadslice"
	stackIngredients = 1
	addTop = 1

// Misc Subtypes ///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/customizable/pizza
	name = "personal pizza"
	desc = "A personalized pan pizza meant for only one person."
	icon_state = "personal_pizza"

/obj/item/weapon/reagent_containers/food/snacks/customizable/pasta
	name = "spagetti"
	desc = "Noodles. With stuff. Delicious."
	icon_state = "pasta_bot"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/bread
	name = "bread"
	icon_state = "breadcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/pie
	name = "pie"
	icon_state = "piecustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/cake
	name = "cake"
	desc = "A popular band."
	icon_state = "cakecustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/jelly
	name = "jelly"
	desc = "Totally jelly."
	icon_state = "jellycustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/donkpocket
	name = "donk pocket"
	desc = "You wanna put a bangin-Oh nevermind."
	icon_state = "donkcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/kebab
	name = "kebab"
	icon_state = "kababcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/salad
	name = "salad"
	desc = "Very tasty."
	icon_state = "saladcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/waffles
	name = "waffles"
	desc = "Made with love."
	icon_state = "wafflecustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/cookie
	name = "cookie"
	icon_state = "cookiecustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/cotton
	name = "flavored cotton candy"
	icon_state = "cottoncandycustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/gummybear
	name = "flavored giant gummy bear"
	icon_state = "gummybearcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/gummyworm
	name = "flavored giant gummy worm"
	icon_state = "gummywormcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/jellybean
	name = "flavored giant jelly bean"
	icon_state = "jellybeancustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/jawbreaker
	name = "flavored jawbreaker"
	icon_state = "jawbreakercustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/candycane
	name = "flavored candy cane"
	icon_state = "candycanecustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/gum
	name = "flavored gum"
	icon_state = "gumcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/donut
	name = "filled donut"
	desc = "Donut eat this!" // kill me
	icon_state = "donutcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/bar
	name = "flavored chocolate bar"
	desc = "Made in a factory downtown."
	icon_state = "barcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/sucker
	name = "flavored sucker"
	desc = "Suck suck suck."
	icon_state = "suckercustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/cash
	name = "flavored chocolate cash"
	desc = "I got piles!" //I bet you do
	icon_state = "cashcustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/coin
	name = "flavored chocolate coin"
	icon_state = "coincustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom
	name = "on a plate"
	desc = "A unique dish."
	icon_state = "fullycustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/soup
	name = "soup"
	desc = "A bowl with liquid and... stuff in it."
	icon_state = "soup"
	trash = /obj/item/trash/bowl

/obj/item/weapon/reagent_containers/food/snacks/customizable/burger
	name = "burger bun"
	desc = "A bun for a burger. Delicious."
	icon_state = "burger"
	stackIngredients = 1
	addTop = 1
// Customizable Drinks /////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable
	volume = 100
	gulp_size = 2
	var/list/ingredients = list()
	var/initReagent
	var/ingMax = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/New()
	. = ..()
	src.reagents.add_reagent(src.initReagent,50)
	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/pen))
		src.name = copytext(sanitize(input(usr,"Name the bottle.",,src.name)),1,MAX_NAME_LEN)
	else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		if(src.ingredients.len < src.ingMax)
			var/obj/item/weapon/reagent_containers/food/snacks/S = I
			if(user)
				user.drop_item()
			S.loc = src
			if(user)
				user << "<span class='notice'>You add the [S.name] to the [src.name].</span>"
			S.reagents.trans_to(src,S.reagents.total_volume)
			src.ingredients += S
			src.update()
		else user << "<span class='warning'>That won't fit.</span>"
	else . = ..()
	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/proc/update()
	var/obj/item/weapon/reagent_containers/food/snacks/S = src.ingredients[1]
	src.name = S.name + src.name
	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/Destroy()
	for(. in src.ingredients) qdel(.)
	return ..()

// Drink Subtypes //////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/wine
	name = "wine"
	desc = "Classy."
	icon_state = "winecustom"
	initReagent = "wine"

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/whiskey
	name = "whiskey"
	desc = "A bottle of quite-a-bit-proof whiskey."
	icon_state = "whiskeycustom"
	initReagent = "whiskey"

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vermouth
	name = "vermouth"
	desc = "Shaken, not stirred."
	icon_state = "vermouthcustom"
	initReagent = "vermouth"

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vodka
	name = "vodka"
	desc = "Get drunk, comrade."
	icon_state = "vodkacustom"
	initReagent = "vodka"

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/ale
	name = "ale"
	desc = "Strike the asteroid!"
	icon_state = "alecustom"
	initReagent = "wine"



// Cooking Machine Food Items  //////////////////////////////////////////////

////////////////////////////////ICE CREAM///////////////////////////////////
/obj/item/weapon/reagent_containers/food/snacks/icecream
        name = "ice cream"
        desc = "Delicious ice cream."
        icon = 'icons/obj/kitchen.dmi'
        icon_state = "icecream_cone"
        New()
                ..()
                reagents.add_reagent("nutriment", 1)
                reagents.add_reagent("sugar",1)
                bitesize = 1
                update_icon()

        update_icon()
                overlays.Cut()
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

// Flour + egg = dough
/obj/item/weapon/reagent_containers/food/snacks/flour/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/egg))
		new /obj/item/weapon/reagent_containers/food/snacks/dough(src)
		user << "You make some dough."
		del(W)
		del(src)

// Egg + flour = dough
/obj/item/weapon/reagent_containers/food/snacks/egg/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/flour))
		new /obj/item/weapon/reagent_containers/food/snacks/dough(src)
		user << "You make some dough."
		del(W)
		del(src)

/obj/item/weapon/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	bitesize = 2
	New()
		..()
		reagents.add_reagent("nutriment", 3)

// Dough + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/dough/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough(loc)
			user << "<span class='notice'>You flatten [src].</span>"
			qdel(src)
		else
			user << "<span class='notice'>You need to put [src] on a surface to roll it out!</span>"
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
	New()
		..()
		reagents.add_reagent("nutriment", 3)

/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "doughslice"
	bitesize = 2
	New()
		..()
		reagents.add_reagent("nutriment", 1)

/obj/item/weapon/reagent_containers/food/snacks/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "bun"
	bitesize = 2
	New()
		..()
		reagents.add_reagent("nutriment", 4)
