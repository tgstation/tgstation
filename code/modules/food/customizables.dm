
/obj/item/weapon/reagent_containers/food/snacks/breadslice/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/S = new(get_turf(user))
		S.attackby(W,user)
		qdel(src)
/obj/item/weapon/reagent_containers/food/snacks/bun/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/burger/S = new(get_turf(user))
		S.attackby(W,user)
		qdel(src)
	..()

/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/pizza/S = new(get_turf(user))
		S.attackby(W,user)
		qdel(src)
	..()

/obj/item/weapon/reagent_containers/food/snacks/boiledspagetti/attackby(obj/item/W as obj, mob/user as mob)

	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/pasta/S = new(get_turf(user))
		S.attackby(W,user)
		qdel(src)

/obj/item/trash/plate/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom/S = new(get_turf(user))
		S.attackby(W,user)
		qdel(src)

/obj/item/trash/bowl
	name = "bowl"
	desc = "An empty bowl. Put some food in it to start making a soup."
	icon = 'icons/obj/food.dmi'
	icon_state = "soup"

/obj/item/trash/bowl/attackby(obj/item/W as obj, mob/user as mob)

	if(istype(W,/obj/item/weapon/shard) || istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/soup/S = new(get_turf(user))
		S.attackby(W,user)
		qdel(src)
	..()

/obj/item/weapon/reagent_containers/food/snacks/customizable
	name = "sandwich"
	desc = "A sandwich! A timeless classic."
	icon_state = "breadslice"
	var/baseicon = "sandwich"
	var/basename = "sandwich"
	var/top = 1	//Do we have a top?
	var/add_overlays = 1	//Do we stack?
//	var/offsetstuff = 1 //Do we offset the overlays?
	var/sandwich_limit = 600
	var/fullycustom = 0
	var/list/descriptors = list("absurd","colossal","enormous","ridiculous","massive","oversized","cardiac-arresting","pipe-clogging","edible but sickening","sickening","gargantuan","mega","belly-burster","chest-burster")
	trash = /obj/item/trash/plate
	bitesize = 2

	var/list/ingredients = list()

	New()
		..()
		reagents.add_reagent("nutriment", 8)

/obj/item/weapon/reagent_containers/food/snacks/customizable/pizza
	name = "personal pizza"
	desc = "A personalized pan pizza meant for only one person."
	icon_state = "personal_pizza"
	baseicon = "personal_pizza"
	basename = "personal pizza"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/pasta
	name = "spagetti"
	desc = "Noodles. With stuff. Delicious."
	icon_state = "pasta_bot"
	baseicon = "pasta_bot"
	basename = "spagetti"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/bread
	name = "bread"
	desc = "Tasty bread."
	icon_state = "breadcustom"
	baseicon = "breadcustom"
	basename = "bread"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/pie
	name = "pie"
	desc = "Tasty pie."
	icon_state = "piecustom"
	baseicon = "piecustom"
	basename = "pie"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/cake
	name = "cake"
	desc = "A popular band."
	icon_state = "cakecustom"
	baseicon = "cakecustom"
	basename = "cake"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/jelly
	name = "jelly"
	desc = "Totally jelly."
	icon_state = "jellycustom"
	baseicon = "jellycustom"
	basename = "jelly"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/donkpocket
	name = "donk pocket"
	desc = "You wanna put a bangin-Oh nevermind."
	icon_state = "donkcustom"
	baseicon = "donkcustom"
	basename = "donk pocket"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/kebab
	name = "kebab"
	desc = "Kebab or Kabab?"
	icon_state = "kababcustom"
	baseicon = "kababcustom"
	basename = "kebab"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/salad
	name = "salad"
	desc = "Very tasty."
	icon_state = "saladcustom"
	baseicon = "saladcustom"
	basename = "salad"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/waffles
	name = "waffles"
	desc = "Made with love."
	icon_state = "wafflecustom"
	baseicon = "wafflecustom"
	basename = "waffles"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/cookie
	name = "cookie"
	desc = "COOKIE!!1!"
	icon_state = "cookiecustom"
	baseicon = "cookiecustom"
	basename = "cookie"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/cotton
	name = "flavored cotton candy"
	desc = "Who can take a sunrise, sprinkle it with dew,"
	icon_state = "cottoncandycustom"
	baseicon = "cottoncandycustom"
	basename = "flavored cotton candy"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/gummybear
	name = "flavored giant gummy bear"
	desc = "Cover it in chocolate and a miracle or two,"
	icon_state = "gummybearcustom"
	baseicon = "gummybearcustom"
	basename = "flavored giant gummy bear"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/gummyworm
	name = "flavored giant gummy worm"
	desc = "The Candy Man can 'cause he mixes it with love,"
	icon_state = "gummywormcustom"
	baseicon = "gummywormcustom"
	basename = "flavored giant gummy worm"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/jellybean
	name = "flavored giant jelly bean"
	desc = "And makes the world taste good."
	icon_state = "jellybeancustom"
	baseicon = "jellybeancustom"
	basename = "flavored giant jelly bean"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/jawbreaker
	name = "flavored jawbreaker"
	desc = "Who can take a rainbow, Wrap it in a sigh,"
	icon_state = "jawbreakercustom"
	baseicon = "jawbreakercustom"
	basename = "flavored jawbreaker"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/candycane
	name = "flavored candy cane"
	desc = "Soak it in the sun and make strawberry-lemon pie,"
	icon_state = "candycanecustom"
	baseicon = "candycanecustom"
	basename = "flavored candy cane"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/gum
	name = "flavored gum"
	desc = "The Candy Man can 'cause he mixes it with love and makes the world taste good. And the world tastes good 'cause the Candy Man thinks it should..."
	icon_state = "gumcustom"
	baseicon = "gumcustom"
	basename = "flavored gum"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/donut
	name = "filled donut"
	desc = "Donut eat this!" // kill me
	icon_state = "donutcustom"
	baseicon = "donutcustom"
	basename = "filled donut"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/bar
	name = "flavored chocolate bar"
	desc = "Made in a factory downtown."
	icon_state = "barcustom"
	baseicon = "barcustom"
	basename = "flavored chocolate bar"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/sucker
	name = "flavored sucker"
	desc = "Suck suck suck."
	icon_state = "suckercustom"
	baseicon = "suckercustom"
	basename = "flavored sucker"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/cash
	name = "flavored chocolate cash"
	desc = "I got piles!"
	icon_state = "cashcustom"
	baseicon = "cashcustom"
	basename = "flavored cash"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/coin
	name = "flavored chocolate coin"
	desc = "Clink, clink, clink."
	icon_state = "coincustom"
	baseicon = "coincustom"
	basename = "flavored coin"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom // In the event you fuckers find something I forgot to add a customizable food for.
	name = "on a plate"
	desc = "A unique dish."
	icon_state = "fullycustom"
	baseicon = "fullycustom"
	basename = "on a plate"
	add_overlays = 0
	top = 0
	fullycustom = 1

/obj/item/weapon/reagent_containers/food/snacks/customizable/soup
	name = "soup"
	desc = "A bowl with liquid and... stuff in it."
	icon_state = "soup"
	baseicon = "soup"
	basename = "soup"
	add_overlays = 0
	trash = /obj/item/trash/bowl
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/burger
	name = "burger bun"
	desc = "A bun for a burger. Delicious."
	icon_state = "burger"
	baseicon = "burger"
	basename = "burger"

/obj/item/weapon/reagent_containers/food/snacks/customizable/attackby(obj/item/W as obj, mob/user as mob)
	if(src.contents.len > sandwich_limit)
		user << "<span class='warning'>If you put anything else in or on [src] it's going to make a mess.</span>"
		return
	else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		user << "<span class='notice'>[W] was added to [src].</span>" //This message shows when the MACHINES do it too, so I made it indirect
		var/obj/item/weapon/reagent_containers/F = W
		F.reagents.trans_to(src, F.reagents.total_volume)
		user.drop_item()
		W.loc = src
		ingredients += W
		update()
		return
	..()

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

		if(!fullycustom)
			var/image/I = new(src.icon, "[baseicon]_filling")
			if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
				var/obj/item/weapon/reagent_containers/food/snacks/food = O
				if(!food.filling_color == "#FFFFFF")
					I.color = food.filling_color
				else
					I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
			if(add_overlays)
				I.pixel_x = rand(-1,1)
				I.pixel_y = (i*2)+1
			overlays += I
		else
			var/image/F = new(O.icon, O.icon_state)
			F.pixel_x = rand(-1,1)
			F.pixel_y = rand(-1,1)
			overlays += F
			overlays += O.overlays

	if(top)
		var/image/T = new(src.icon, "[baseicon]_top")
		T.pixel_x = rand(-1,1)
		T.pixel_y = (ingredients.len * 2)+1
		overlays += T

	name = lowertext("[fullname] [basename]")
	if(length(name) > 80) name = "[pick(descriptors)] [basename]"
	w_class = n_ceil(Clamp((ingredients.len/2),1,3))

/obj/item/weapon/reagent_containers/food/snacks/customizable/Destroy()
	for(var/obj/item/O in ingredients)
		del(O) // qdelling certain foods causes runtimes up the ass sometimes, best just to standard del()
	..()

/obj/item/weapon/reagent_containers/food/snacks/customizable/examine()
	..()
	var/whatsinside = pick(ingredients)

	usr << "<span class='notice'>You think you can see [whatsinside] in there.</span>"

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable // Shamelessly stolen from original customizables, so that I can easily use the oven code.
	name = "Customizable Drink"
	desc = "If you can see this, tell a coder."
	icon_state = "winecustom"
	var/baseicon = "winecustom"
	var/basename = "wine"
	var/top = 1	//Do we have a top?
	var/add_overlays = 1	//Do we stack?
//	var/offsetstuff = 1 //Do we offset the overlays?
	var/sandwich_limit = 1
	var/fullycustom = 0
	volume = 100
	gulp_size = 2

	var/list/ingredients = list()

	New()
		..()
		reagents.add_reagent("nutriment", 1)

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/wine
	name = "wine bottle"
	desc = "Classy."
	icon_state = "winecustom"
	baseicon = "winecustom"
	basename = "wine bottle"
	add_overlays = 0
	top = 0
	New()
		..()
		reagents.add_reagent("wine", 50)

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/whiskey
	name = "whiskey bottle"
	desc = "A bottle of quite-a-bit-proof whiskey."
	icon_state = "whiskeycustom"
	baseicon = "whiskeycustom"
	basename = "whiskey bottle"
	add_overlays = 0
	top = 0
	New()
		..()
		reagents.add_reagent("whiskey", 50)

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vermouth
	name = "vermouth bottle"
	desc = "Shaken, not stirred."
	icon_state = "vermouthcustom"
	baseicon = "vermouthcustom"
	basename = "vermouth bottle"
	add_overlays = 0
	top = 0
	New()
		..()
		reagents.add_reagent("vermouth", 50)

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/vodka
	name = "vodka"
	desc = "Get drunk, comrade."
	icon_state = "vodkacustom"
	baseicon = "vodkacustom"
	basename = "vodka"
	add_overlays = 0
	top = 0
	New()
		..()
		reagents.add_reagent("vodka", 50)

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/ale
	name = "ale"
	desc = "Strike the asteroid!"
	icon_state = "alecustom"
	baseicon = "alecustom"
	basename = "ale"
	add_overlays = 0
	top = 0
	New()
		..()
		reagents.add_reagent("wine", 50)

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/pen))
		var/n_name = copytext(sanitize(input(usr, "What would you like to name this bottle?", "Food Renaming", null)  as text), 1, MAX_NAME_LEN)
		if((loc == usr && usr.stat == 0))
			name = "[n_name]"
		return
	if(src.contents.len > sandwich_limit)
		user << "<span class='warning'>You can't fit it into [src].</span>"
		return
	else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		user << "<span class='notice'>[W] was added to [src].</span>" //This message shows when the MACHINES do it too, so I made it indirect
		var/obj/item/weapon/reagent_containers/F = W
		F.reagents.trans_to(src, F.reagents.total_volume)
		user.drop_item()
		W.loc = src
		ingredients += W
		update()
		return
	..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/proc/update()
	var/fullname = "" //We need to build this from the contents of the var.
	var/i = 0

	overlays.Cut()

	for(var/obj/item/weapon/reagent_containers/food/snacks/O in ingredients)

		i++
		if(i == 1)
			fullname += "[O.name]"
		if(!fullycustom)
			var/image/I = new(src.icon, "[baseicon]_filling")
			if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
				var/obj/item/weapon/reagent_containers/food/snacks/food = O
				if(!food.filling_color == "#FFFFFF")
					I.color = food.filling_color
				else
					I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
			if(add_overlays)
				I.pixel_x = rand(-1,1)
				I.pixel_y = (i*2)+1
			overlays += I
		else
			var/image/F = new(O.icon, O.icon_state)
			F.pixel_x = rand(-1,1)
			F.pixel_y = rand(-1,1)
			overlays += F
			overlays += O.overlays

	if(top)
		var/image/T = new(src.icon, "[baseicon]_top")
		T.pixel_x = pick(list(-1,0,1))
		T.pixel_y = (ingredients.len * 2)+1
		overlays += T

	name = lowertext("[fullname] [basename]")
	if(length(name) > 80) name = "incomprehensible mixture [basename]"
	w_class = n_ceil(Clamp((ingredients.len/2),1,3))

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/Destroy()
	for(var/obj/item/O in ingredients)
		del(O) // qdelling certain foods causes runtimes up the ass sometimes, best just to standard del()
	..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/examine()
	..()
	var/whatsinside = pick(ingredients)

	usr << "<span class='notice'> You think you can see [whatsinside] in there.</span>"