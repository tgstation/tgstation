
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
		new/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich(get_turf(src),I)
		qdel(src)
	else . = ..()
	return

/obj/item/weapon/reagent_containers/food/snacks/bun/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		new/obj/item/weapon/reagent_containers/food/snacks/customizable/burger(get_turf(src),I)
		qdel(src)
	else . = ..()
	return

/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		new/obj/item/weapon/reagent_containers/food/snacks/customizable/pizza(get_turf(src),I)
		qdel(src)
	else . = ..()
	return

/obj/item/weapon/reagent_containers/food/snacks/boiledspagetti/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		new/obj/item/weapon/reagent_containers/food/snacks/customizable/pasta(get_turf(src),I)
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
		user.drop_item()
		S.loc = src
		src.ingredients += S
		S.reagents.trans_to(src,S.reagents.total_volume)
		src.update()
		user << "<span class='notice'>You add the [I.name] to the [src.name].</span>"
	else . = ..()
	return

/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/update()
	var/i = 1
	var/image/I
	src.overlays.Cut()
	for(var/obj/item/weapon/reagent_containers/food/snacks/S in src.ingredients)
		if(i == 1) . += "[S.name]"
		else if(i == src.ingredients.len) . += "and [S.name]"
		else . += ", [S.name]"
		i++
		src.name = "[.] [src.name]"
		if(src.fullyCustom)
			I = image(S.icon,,S.icon_state)
			I.pixel_x = rand(-1,1)
			I.pixel_y = rand(-1,1)
			src.overlays += I
			src.overlays += I.overlays
		else
			I = new(src.icon,"[initial(src.icon_state)]_filling")
			if(S.filling_color == "#FFFFFF") I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
			else I.color = S.filling_color
			if(src.stackIngredients)
				I.pixel_x = rand(-1,1)
				I.pixel_y = (i*2)+1
			else src.overlays.Cut()
			src.overlays += I
	if(src.addTop)
		I = image(src.icon,,"src.[icon_state]_top")
		I.pixel_x = rand(-1,1)
		I.pixel_y = (ingredients.len*2)+1
		src.overlays += I
	if(!src.overlays.len)
		I = new(src.icon,"[initial(src.icon_state)]_filling")
		I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
		src.overlays += I
	return

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
			user.drop_item()
			S.loc = src
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
