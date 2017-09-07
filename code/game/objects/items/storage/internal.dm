/obj/item/storage/internal
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 50 // Limited by slots, not combined weight class
	w_class = WEIGHT_CLASS_BULKY
	rustle_jimmies = FALSE

/obj/item/storage/internal/Adjacent(A)
	if(loc)
		return loc.Adjacent(A)

/obj/item/storage/internal/pocket
	var/priority = TRUE
	// TRUE if opens when clicked, like a backpack.
	// FALSE if opens only when dragged on mob's icon (hidden pocket)
	var/quickdraw = FALSE
	// TRUE if you can quickdraw items from it with alt-click.

/obj/item/storage/internal/pocket/New()
	..()
	if(loc)
		name = loc.name

/obj/item/storage/internal/pocket/handle_item_insertion(obj/item/W, prevent_warning = 0, mob/user)
	. = ..()
	if(. && silent && !prevent_warning)
		if(quickdraw)
			to_chat(user, "<span class='notice'>You discreetly slip [W] into [src]. Alt-click [src] to remove it.</span>")
		else
			to_chat(user, "<span class='notice'>You discreetly slip [W] into [src].")

/obj/item/storage/internal/pocket/big
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/internal/pocket/small
	storage_slots = 1
	priority = FALSE

/obj/item/storage/internal/pocket/tiny
	storage_slots = 1
	max_w_class = WEIGHT_CLASS_TINY
	priority = FALSE

/obj/item/storage/internal/pocket/shoes
	can_hold = list(
		/obj/item/kitchen/knife, /obj/item/switchblade, /obj/item/pen,
		/obj/item/scalpel, /obj/item/reagent_containers/syringe, /obj/item/dnainjector,
		/obj/item/reagent_containers/hypospray/medipen, /obj/item/reagent_containers/dropper,
		/obj/item/implanter, /obj/item/screwdriver, /obj/item/weldingtool/mini,
		/obj/item/device/firing_pin
		)
	//can hold both regular pens and energy daggers. made for your every-day tactical curators/murderers.
	priority = FALSE
	quickdraw = TRUE
	silent = TRUE


/obj/item/storage/internal/pocket/shoes/clown
	can_hold = list(
		/obj/item/kitchen/knife, /obj/item/switchblade, /obj/item/pen,
		/obj/item/scalpel, /obj/item/reagent_containers/syringe, /obj/item/dnainjector,
		/obj/item/reagent_containers/hypospray/medipen, /obj/item/reagent_containers/dropper,
		/obj/item/implanter, /obj/item/screwdriver, /obj/item/weldingtool/mini,
		/obj/item/device/firing_pin, /obj/item/bikehorn)

/obj/item/storage/internal/pocket/small/detective
	priority = TRUE // so the detectives would discover pockets in their hats

/obj/item/storage/internal/pocket/small/detective/PopulateContents()
	new /obj/item/reagent_containers/food/drinks/flask/det(src)

/obj/item/storage/internal/pocket/pocketprotector
	storage_slots = 3
	max_w_class = WEIGHT_CLASS_TINY
	can_hold = list( //Same items as a PDA
		/obj/item/pen,
		/obj/item/toy/crayon,
		/obj/item/lipstick,
		/obj/item/device/flashlight/pen,
		/obj/item/clothing/mask/cigarette)

/obj/item/storage/internal/pocket/pocketprotector/cosmetology/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/lipstick/random(src)

/obj/item/storage/internal/pocket/pocketprotector/full/PopulateContents()
	new /obj/item/pen/red(src)
	new /obj/item/pen(src)
	new /obj/item/pen/blue(src)
