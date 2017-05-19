/obj/item/weapon/storage/internal
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 50 // Limited by slots, not combined weight class
	w_class = WEIGHT_CLASS_BULKY
	rustle_jimmies = FALSE

/obj/item/weapon/storage/internal/Adjacent(A)
	if(loc)
		return loc.Adjacent(A)

/obj/item/weapon/storage/internal/pocket
	var/priority = TRUE
	// TRUE if opens when clicked, like a backpack.
	// FALSE if opens only when dragged on mob's icon (hidden pocket)
	var/quickdraw = FALSE
	// TRUE if you can quickdraw items from it with alt-click.

/obj/item/weapon/storage/internal/pocket/New()
	..()
	if(loc)
		name = loc.name

/obj/item/weapon/storage/internal/pocket/handle_item_insertion(obj/item/W, prevent_warning = 0, mob/user)
	. = ..()
	if(. && silent && !prevent_warning)
		if(quickdraw)
			to_chat(user, "<span class='notice'>You discreetly slip [W] into [src]. Alt-click [src] to remove it.</span>")
		else
			to_chat(user, "<span class='notice'>You discreetly slip [W] into [src].")

/obj/item/weapon/storage/internal/pocket/big
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/weapon/storage/internal/pocket/small
	storage_slots = 1
	priority = FALSE

/obj/item/weapon/storage/internal/pocket/tiny
	storage_slots = 1
	max_w_class = WEIGHT_CLASS_TINY
	priority = FALSE

/obj/item/weapon/storage/internal/pocket/shoes
	can_hold = list(
		/obj/item/weapon/kitchen/knife, /obj/item/weapon/switchblade, /obj/item/weapon/pen,
		/obj/item/weapon/scalpel, /obj/item/weapon/reagent_containers/syringe, /obj/item/weapon/dnainjector,
		/obj/item/weapon/reagent_containers/hypospray/medipen, /obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/implanter, /obj/item/weapon/screwdriver, /obj/item/weapon/weldingtool/mini,
		/obj/item/device/firing_pin
		)
	//can hold both regular pens and energy daggers. made for your every-day tactical curators/murderers.
	priority = FALSE
	quickdraw = TRUE
	silent = TRUE


/obj/item/weapon/storage/internal/pocket/shoes/clown
	can_hold = list(
		/obj/item/weapon/kitchen/knife, /obj/item/weapon/switchblade, /obj/item/weapon/pen,
		/obj/item/weapon/scalpel, /obj/item/weapon/reagent_containers/syringe, /obj/item/weapon/dnainjector,
		/obj/item/weapon/reagent_containers/hypospray/medipen, /obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/implanter, /obj/item/weapon/screwdriver, /obj/item/weapon/weldingtool/mini,
		/obj/item/device/firing_pin, /obj/item/weapon/bikehorn)

/obj/item/weapon/storage/internal/pocket/small/detective
	priority = TRUE // so the detectives would discover pockets in their hats

/obj/item/weapon/storage/internal/pocket/small/detective/PopulateContents()
	new /obj/item/weapon/reagent_containers/food/drinks/flask/det(src)

/obj/item/weapon/storage/internal/pocket/small/webbing
	storage_slots = 2
	can_hold = list(
		/obj/item/weapon/grenade,
		/obj/item/weapon/reagent_containers/spray/pepper,
		/obj/item/weapon/restraints/handcuffs,
		/obj/item/device/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_box,
		/obj/item/weapon/reagent_containers/food/snacks/donut,
		/obj/item/weapon/reagent_containers/food/snacks/donut/jelly,
		/obj/item/weapon/kitchen/knife/combat,
		/obj/item/device/flashlight/seclite,
		/obj/item/weapon/melee/classic_baton/telescopic,
		/obj/item/device/radio,
		/obj/item/clothing/gloves/,
		/obj/item/weapon/restraints/legcuffs/bola
		)
	priority = TRUE

/obj/item/weapon/storage/internal/pocket/small/webbing/adv
	storage_slots = 3