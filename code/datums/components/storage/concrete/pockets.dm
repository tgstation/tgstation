/datum/component/storage/concrete/pockets
	max_items = 2
	max_atom_size = ITEM_SIZE_SMALL
	max_total_atom_size = ITEM_SIZE_SMALL * 2
	rustle_sound = FALSE

/datum/component/storage/concrete/pockets/handle_item_insertion(obj/item/I, prevent_warning, mob/user)
	. = ..()
	if(. && silent && !prevent_warning)
		if(quickdraw)
			to_chat(user, span_notice("You discreetly slip [I] into [parent]. Right-click [parent] to remove it."))
		else
			to_chat(user, span_notice("You discreetly slip [I] into [parent]."))

/datum/component/storage/concrete/pockets/small
	max_items = 1
	max_atom_size = ITEM_SIZE_SMALL
	attack_hand_interact = FALSE

/datum/component/storage/concrete/pockets/tiny
	max_items = 1
	max_atom_size = ITEM_SIZE_TINY
	attack_hand_interact = FALSE

/datum/component/storage/concrete/pockets/small/fedora/Initialize()
	. = ..()
	var/static/list/exception_cache = typecacheof(list(
		/obj/item/katana, /obj/item/toy/katana, /obj/item/nullrod/claymore/katana,
		/obj/item/energy_katana, /obj/item/gun/ballistic/automatic/tommygun
		))
	exception_hold = exception_cache

/datum/component/storage/concrete/pockets/small/fedora/detective
	attack_hand_interact = TRUE // so the detectives would discover pockets in their hats

/datum/component/storage/concrete/pockets/chefhat
	attack_hand_interact = TRUE
	max_items = 1
	max_atom_size = ITEM_SIZE_NORMAL
	max_total_atom_size = ITEM_SIZE_NORMAL

/datum/component/storage/concrete/pockets/chefhat/Initialize()
	. = ..()
	set_holdable(list(
		/obj/item/clothing/head/mob_holder,
		/obj/item/food/deadmouse
	))

/datum/component/storage/concrete/pockets/chefhat/can_be_inserted(obj/item/I, stop_messages, mob/M)
	. = ..()
	if(istype(I,/obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/mausholder = I
		if(locate(/mob/living/simple_animal/mouse) in mausholder.contents)
			return
		return FALSE

/datum/component/storage/concrete/pockets/shoes
	attack_hand_interact = FALSE
	quickdraw = TRUE
	silent = TRUE

/datum/component/storage/concrete/pockets/shoes/Initialize()
	. = ..()
	set_holdable(list(
		/obj/item/knife, /obj/item/switchblade, /obj/item/pen,
		/obj/item/scalpel, /obj/item/reagent_containers/syringe, /obj/item/dnainjector,
		/obj/item/reagent_containers/hypospray/medipen, /obj/item/reagent_containers/dropper,
		/obj/item/implanter, /obj/item/screwdriver, /obj/item/weldingtool/mini,
		/obj/item/firing_pin
		),
		list(/obj/item/screwdriver/power)
		)

/datum/component/storage/concrete/pockets/shoes/clown/Initialize()
	. = ..()
	set_holdable(list(
		/obj/item/knife, /obj/item/switchblade, /obj/item/pen,
		/obj/item/scalpel, /obj/item/reagent_containers/syringe, /obj/item/dnainjector,
		/obj/item/reagent_containers/hypospray/medipen, /obj/item/reagent_containers/dropper,
		/obj/item/implanter, /obj/item/screwdriver, /obj/item/weldingtool/mini,
		/obj/item/firing_pin, /obj/item/bikehorn),
		list(/obj/item/screwdriver/power)
		)

/datum/component/storage/concrete/pockets/pocketprotector
	max_items = 3
	max_atom_size = ITEM_SIZE_TINY
	max_total_atom_size = ITEM_SIZE_TINY * 3
	var/atom/original_parent

/datum/component/storage/concrete/pockets/pocketprotector/Initialize()
	original_parent = parent
	. = ..()
	set_holdable(list( //Same items as a PDA
		/obj/item/pen,
		/obj/item/toy/crayon,
		/obj/item/lipstick,
		/obj/item/flashlight/pen,
		/obj/item/clothing/mask/cigarette)
		)

/datum/component/storage/concrete/pockets/pocketprotector/real_location()
	// if the component is reparented to a jumpsuit, the items still go in the protector
	return original_parent

/datum/component/storage/concrete/pockets/helmet
	quickdraw = TRUE
	max_total_atom_size = ITEM_SIZE_SMALL * 2

/datum/component/storage/concrete/pockets/helmet/Initialize()
	. = ..()
	set_holdable(list(/obj/item/reagent_containers/food/drinks/bottle/vodka,
					  /obj/item/reagent_containers/food/drinks/bottle/molotov,
					  /obj/item/reagent_containers/food/drinks/drinkingglass,
					  /obj/item/ammo_box/a762))


/datum/component/storage/concrete/pockets/void_cloak
	quickdraw = TRUE
	max_items = 3
	max_total_atom_size = ITEM_SIZE_NORMAL * 3

/datum/component/storage/concrete/pockets/void_cloak/Initialize()
	. = ..()
	var/static/list/exception_cache = typecacheof(list(/obj/item/living_heart,/obj/item/forbidden_book))
	exception_hold = exception_cache
