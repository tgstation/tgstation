
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

/obj/item/weapon/reagent_containers/food/snacks/breadslice/attackby(obj/item/I,mob/user,params)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		if(!recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
			to_chat(user, "<span class='warning'>Sorry, no recursive food.</span>")
			return
		var/obj/F = new/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich(get_turf(src),I) //boy ain't this a mouthful
		F.attackby(I, user, params)
		qdel(src)
	else return ..()

/obj/item/weapon/reagent_containers/food/snacks/bun/attackby(obj/item/I,mob/user,params)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		if(!recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
			to_chat(user, "<span class='warning'>Sorry, no recursive food.</span>")
			return
		var/obj/F = new/obj/item/weapon/reagent_containers/food/snacks/customizable/burger(get_turf(src),I)
		F.attackby(I, user, params)
		qdel(src)
	else return ..()

/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough/attackby(obj/item/I,mob/user,params)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		if(!recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
			to_chat(user, "<span class='warning'>Sorry, no recursive food.</span>")
			return
		var/obj/F = new/obj/item/weapon/reagent_containers/food/snacks/customizable/pizza(get_turf(src),I)
		F.attackby(I, user, params)
		qdel(src)
	else return ..()

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti/attackby(obj/item/I,mob/user,params)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		if(!recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
			to_chat(user, "<span class='warning'>Sorry, no recursive food.</span>")
			return
		var/obj/F = new/obj/item/weapon/reagent_containers/food/snacks/customizable/pasta(get_turf(src),I)
		F.attackby(I, user, params)
		qdel(src)
	else return ..()

// Custom Meals ////////////////////////////////////////////////

/obj/item/trash/plate/attackby(obj/item/I,mob/user,params)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom)) //no platestacking even with recursive food, for now
			to_chat(user, "<span class='warning'>That's already got a plate!</span>")
			return
		var/obj/F = new/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom(get_turf(src),I)
		F.attackby(I, user, params)
		qdel(src)
	else return ..()

/obj/item/trash/bowl
	name = "bowl"
	desc = "An empty bowl. Put some food in it to start making a soup."
	icon = 'icons/obj/food.dmi'
	icon_state = "soup"

/obj/item/trash/bowl/attackby(obj/item/I,mob/user,params)
	if(istype(I,/obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/S = I
		S.use(1)
		new/obj/item/weapon/reagent_containers/mortar(get_turf(src))
		qdel(src)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		if(!recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
			to_chat(user, "<span class='warning'>Sorry, no recursive food.</span>")
			return
		var/obj/F = new/obj/item/weapon/reagent_containers/food/snacks/customizable/soup(get_turf(src),I)
		F.attackby(I, user,params)
		qdel(src)
	else return ..()

// Customizable Foods //////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/customizable
	trash = /obj/item/trash/plate
	bitesize = 2

	var/ingMax = 100
	var/list/ingredients = list()
	var/stackIngredients = 0
	var/fullyCustom = 0
	var/addTop = 0
	var/image/topping
	var/image/filling

/obj/item/weapon/reagent_containers/food/snacks/customizable/New(loc,ingredient)
	. = ..()
	topping = image(icon,,"[initial(icon_state)]_top")
	filling = image(icon,,"[initial(icon_state)]_filling")
	src.reagents.add_reagent("nutriment",3)
	src.updateName()
	return

/obj/item/weapon/reagent_containers/food/snacks/customizable/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		if((src.contents.len >= src.ingMax) || (src.contents.len >= ingredientLimit))
			to_chat(user, "<span class='warning'>That's already looking pretty stuffed.</span>")
			return
		var/obj/item/weapon/reagent_containers/food/snacks/S = I
		if(istype(S,/obj/item/weapon/reagent_containers/food/snacks/customizable))
			var/obj/item/weapon/reagent_containers/food/snacks/customizable/SC = S
			if(src.fullyCustom && SC.fullyCustom)
				to_chat(user, "<span class='warning'>You slap yourself on the back of the head for thinking that stacking plates is an interesting dish.</span>")
				message_admins("<span class='warning'>POSSIBLE EXPLOIT ATTEMPT:</span> [key_name_admin(user)] tried to stack multiple plates together, which used to generate excessive atom names, resulting in crashes. See <a href='https://github.com/d3athrow/vgstation13/issues/6402'>#6402</a>.")
				return
		if(!recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
			to_chat(user, "<span class='warning'>[pick("Sorry, no recursive food.","That would be a straining topological exercise.","This world just isn't ready for your cooking genius.","It's possible that you may have a problem.","It won't fit.","You don't think that would taste very good.","Quit goofin' around.")]</span>")
			return
		S.reagents.trans_to(src,S.reagents.total_volume)
		user.drop_item(I, src)
		src.ingredients += S

		if(src.addTop) src.overlays -= src.topping //thank you Comic
		if(!src.fullyCustom && !src.stackIngredients && src.overlays.len)
			src.overlays -= src.filling //we can't directly modify the overlay, so we have to remove it and then add it again
			var/newcolor = S.filling_color != "#FFFFFF" ? S.filling_color : AverageColor(getFlatIcon(S, S.dir, 0), 1, 1)
			src.filling.color = BlendRGB(src.filling.color, newcolor, 1/src.ingredients.len)
			src.overlays += src.filling
		else
			src.overlays += generateFilling(S, params)
		if(src.addTop) src.drawTopping()

		src.updateName()
		to_chat(user, "<span class='notice'>You add the [I.name] to the [src.name].</span>")
	else . = ..()
	return

/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/generateFilling(var/obj/item/weapon/reagent_containers/food/snacks/S, params)
	var/image/I
	if(src.fullyCustom)
		var/icon/C = getFlatIcon(S, S.dir, 0)
		I = image(C)
		I.pixel_y = 12-empty_Y_space(C)
	else
		I = src.filling
		if(istype(S) && S.filling_color != "#FFFFFF")
			I.color = S.filling_color
		else
			I.color = AverageColor(getFlatIcon(S, S.dir, 0), 1, 1)
		if(src.stackIngredients)
			I.pixel_y = src.ingredients.len*2
		else
			src.overlays.len = 0
	if(src.fullyCustom || src.stackIngredients)
		var/clicked_x = text2num(params2list(params)["icon-x"])
		if (isnull(clicked_x))   I.pixel_x = 0
		else if (clicked_x < 9)  I.pixel_x = -2 //this looks pretty shitty
		else if (clicked_x < 14) I.pixel_x = -1 //but hey
		else if (clicked_x < 19) I.pixel_x = 0  //it works
		else if (clicked_x < 25) I.pixel_x = 1
		else 					 I.pixel_x = 2
	return I

/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/updateName()
	var/i = 1
	var/new_name
	for(var/obj/item/S in src.ingredients)
		if(i == 1) new_name += "[S.name]"
		else if(i == src.ingredients.len) new_name += " and [S.name]"
		else new_name += ", [S.name]"
		i++
	new_name = "[new_name] [initial(src.name)]"
	if(length(new_name) >= 150) src.name = "something yummy"
	else src.name = new_name
	return new_name

/obj/item/weapon/reagent_containers/food/snacks/customizable/Destroy()
	for(. in src.ingredients) qdel(.)
	return ..()

// Sandwiches //////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich
	name = "sandwich"
	desc = "A timeless classic."
	icon_state = "c_sandwich"
	stackIngredients = 1
	addTop = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/breadslice) && !addTop)
		I.reagents.trans_to(src,I.reagents.total_volume)
		qdel(I)
		addTop = 1
		src.drawTopping()
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/drawTopping()
	var/image/I = src.topping
	I.pixel_y = (src.ingredients.len+1)*2
	src.overlays += I

/obj/item/weapon/reagent_containers/food/snacks/customizable/burger
	name = "burger"
	desc = "The apex of space culinary achievement."
	icon_state = "c_burger"
	stackIngredients = 1
	addTop = 1

// Misc Subtypes ///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom
	name = "on a plate"
	desc = "A unique dish."
	icon_state = "fullycustom"
	fullyCustom = 1 //how the fuck do you forget to add this?
	ingMax = 1

/obj/item/weapon/reagent_containers/food/snacks/customizable/soup
	name = "soup"
	desc = "A bowl with liquid and... stuff in it."
	icon_state = "soup"
	trash = /obj/item/trash/bowl

/obj/item/weapon/reagent_containers/food/snacks/customizable/pizza
	name = "pan pizza"
	desc = "A personalized pan pizza meant for only one person."
	icon_state = "personal_pizza"

/obj/item/weapon/reagent_containers/food/snacks/customizable/pasta
	name = "spaghetti"
	desc = "Noodles. With stuff. Delicious."
	icon_state = "pasta_bot"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/bread
	name = "bread"
	icon_state = "breadcustom"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/customizable/slices/breadslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/customizable/slices/breadslice
	name = "slice"
	desc = "Moist and oozing with flavor, just like how bread should be."
	icon_state = "breadslicecustom"
	trash = /obj/item/trash/plate
	bitesize = 2
	ingMax = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/pie
	name = "pie"
	icon_state = "piecustom"

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/cake
	name = "cake"
	desc = "A popular band."
	icon_state = "cakecustom"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/customizable/slices/cakeslicecustom
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/customizable/slices/cakeslicecustom
	name = "slice"
	desc = "Delicious and moist."
	icon_state = "cakeslicecustom"
	trash = /obj/item/trash/plate
	bitesize = 2
	ingMax = 0

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
	desc = "Nothing beats a jelly-filled donut."
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

// Customizable Drinks /////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable
	volume = 100
	gulp_size = 2
	var/list/ingredients = list()
	var/initReagent
	var/ingMax = 3
	var/image/filling
	isGlass = 1

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/New()
	. = ..()
	src.reagents.add_reagent(src.initReagent,50)
	var/icon/opaquefilling = new(icon,"[initial(icon_state)]_filling")
	opaquefilling.ChangeOpacity(0.8)
	filling = image(opaquefilling)
	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/pen))
		var/n_name = copytext(sanitize(input(user, "What would you like to name this drink?", "Booze Renaming", null) as text|null), 1, MAX_NAME_LEN*3)
		if(n_name && Adjacent(user) && !user.stat)
			name = "[n_name]"
		return
	else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		if(src.ingredients.len < src.ingMax)
			var/obj/item/weapon/reagent_containers/food/snacks/S = I
			if(!recursiveFood && istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
				to_chat(user, "<span class='warning'>[pick("Sorry, no recursive food.","That would be a straining topological exercise.","This world just isn't ready for your cooking genius.","It's possible that you may have a problem.","It won't fit.","You don't think that would taste very good.","Quit goofin' around.")]</span>")
				return
			user.drop_item(I, src)
			to_chat(user, "<span class='notice'>You add the [S.name] to the [src.name].</span>")
			S.reagents.trans_to(src,S.reagents.total_volume)
			src.ingredients += S
			src.updateName()
			src.overlays -= src.filling //we can't directly modify the overlay, so we have to remove it and then add it again
			var/newcolor = S.filling_color != "#FFFFFF" ? S.filling_color : AverageColor(getFlatIcon(S, S.dir, 0), 1, 1)
			src.filling.color = BlendRGB(src.filling.color, newcolor, 1/src.ingredients.len)
			src.overlays += src.filling
		else to_chat(user, "<span class='warning'>That won't fit.</span>")
	else . = ..()
	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/proc/updateName() //copypaste of food's updateName()
	var/i = 1
	var/new_name
	for(var/obj/item/weapon/reagent_containers/food/snacks/S in src.ingredients)
		if(i == 1) new_name += "[S.name]"
		else if(i == src.ingredients.len) new_name += " and [S.name]"
		else new_name += ", [S.name]"
		i++
	new_name = "[new_name] [initial(src.name)]"
	if(length(new_name) >= 150) src.name = "something yummy"
	else src.name = new_name
	return new_name

/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable/proc/generateFilling(var/obj/item/weapon/reagent_containers/food/snacks/S)
	src.overlays.len = 0
	var/image/I = filling
	if(S.filling_color != "#FFFFFF")
		I.color = S.filling_color
	else
		I.color = AverageColor(getFlatIcon(S, S.dir, 0), 1, 1)
	return I

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
	initReagent = "ale"
