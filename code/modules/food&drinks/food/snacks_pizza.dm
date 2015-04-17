
/////////////////////////////////////////////////PIZZA////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/pizza
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	w_class = 3
	slices_num = 6
	volume = 80
	list_reagents = list("nutriment" = 30, "tomatojuice" = 6, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	list_reagents = list("nutriment" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizza/margherita
	name = "margherita"
	desc = "The most cheezy pizza in galaxy."
	icon_state = "pizzamargherita"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/margherita
	bonus_reagents = list("nutriment" = 5, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/margherita
	name = "margherita slice"
	desc = "A slice of the most cheezy pizza in galaxy."
	icon_state = "pizzamargheritaslice"
	filling_color = "#FFA500"

/obj/item/weapon/reagent_containers/food/snacks/pizza/meat
	name = "meatpizza"
	desc = "Greasy pizza with delicious meat."
	icon_state = "meatpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/meat
	bonus_reagents = list("nutriment" = 5, "vitamin" = 8)
	list_reagents = list("nutriment" = 30, "tomatojuice" = 6, "vitamin" = 8)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/meat
	name = "meatpizza slice"
	desc = "A nutritious slice of meatpizza."
	icon_state = "meatpizzaslice"
	filling_color = "#A52A2A"

/obj/item/weapon/reagent_containers/food/snacks/pizza/mushroom
	name = "mushroom pizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/mushroom
	bonus_reagents = list("nutriment" = 5, "vitamin" = 5)
	list_reagents = list("nutriment" = 30, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/mushroom
	name = "mushroom pizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	filling_color = "#FFE4C4"

/obj/item/weapon/reagent_containers/food/snacks/pizza/vegetable
	name = "vegetable pizza"
	desc = "No one of Tomatos Sapiens were harmed during making this pizza."
	icon_state = "vegetablepizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/vegetable
	bonus_reagents = list("nutriment" = 5, "vitamin" = 5)
	list_reagents = list("nutriment" = 25, "tomatojuice" = 6, "oculine" = 12, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/vegetable
	name = "vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients."
	icon_state = "vegetablepizzaslice"
	filling_color = "#FFA500"

/obj/item/weapon/reagent_containers/food/snacks/pizza/donkpocket
	name = "donkpocket pizza"
	desc = "Who thought this would be a good idea?"
	icon_state = "donkpocketpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/donkpocket
	bonus_reagents = list("nutriment" = 5, "vitamin" = 5)
	list_reagents = list("nutriment" = 25, "tomatojuice" = 6, "omnizine" = 10, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/donkpocket
	name = "donkpocket pizza slice"
	desc = "Smells like donkpocket."
	icon_state = "donkpocketpizzaslice"
	filling_color = "#FFA500"

/obj/item/weapon/reagent_containers/food/snacks/pizza/dank
	name = "dank pizza"
	desc = "The hippie's pizza of choice."
	icon_state = "dankpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/dank
	bonus_reagents = list("nutriment" = 2, "vitamin" = 6)
	list_reagents = list("nutriment" = 25, "doctorsdelight" = 5, "tomatojuice" = 6, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/dank
	name = "dank pizza slice"
	desc = "So good, man..."
	icon_state = "dankpizzaslice"
	filling_color = "#2E8B57"

/obj/item/weapon/reagent_containers/food/snacks/pizza/sassysage
	name = "sassysage pizza"
	desc = "You can really smell the sassiness."
	icon_state = "sassysagepizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/sassysage
	bonus_reagents = list("nutriment" = 6, "vitamin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/sassysage
	name = "sassysage pizza slice"
	desc = "Deliciously sassy."
	icon_state = "sassysagepizzaslice"
	filling_color = "#FF4500"

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/custom
	name = "pizza slice"
	icon_state = "pizzamargheritaslice"
	filling_color = "#FFFFFF"

/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "pizzabox1"
	var/open = 0 // Is the box open?
	var/ismessy = 0 // Fancy mess on the lid
	var/obj/item/weapon/reagent_containers/food/snacks/pizza/pizza // Content pizza
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
			var/image/pizzaimg = image('icons/obj/food/pizzaspaghetti.dmi', icon_state = pizza.icon_state)
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
			var/image/tagimg = image('icons/obj/food/containers.dmi', icon_state = "pizzabox_tag")
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


/obj/item/pizzabox/attackby(obj/item/I, mob/user, params)
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

	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/pizza/)) // Long ass fucking object name
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

		var/t = stripped_input(user, "Enter what you want to add to the tag:", "Write", "", 30)

		var/obj/item/pizzabox/boxtotagto = src
		if(boxes.len > 0)
			boxtotagto = boxes[boxes.len]

		boxtotagto.boxtag = "[boxtotagto.boxtag][t]"

		update_icon()
		return
	..()

/obj/item/pizzabox/margherita/New()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/pizza/margherita(src)
	boxtag = "Margherita Deluxe"
	update_icon()

/obj/item/pizzabox/vegetable/New()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/pizza/vegetable(src)
	boxtag = "Gourmet Vegatable"
	update_icon()

/obj/item/pizzabox/mushroom/New()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/pizza/mushroom(src)
	boxtag = "Mushroom Special"
	update_icon()

/obj/item/pizzabox/meat/New()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/pizza/meat(src)
	boxtag = "Meatlover's Supreme"
	update_icon()