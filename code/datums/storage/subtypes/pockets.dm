/datum/storage/pockets
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = 50
	rustle_sound = FALSE

/datum/storage/pockets/attempt_insert(datum/source, obj/item/to_insert, mob/user, override, force)
	. = ..()
	if(. && silent && !override)
		if(quickdraw)
			to_chat(user, span_notice("You discreetly slip [I] into [parent]. Right-click [parent] to remove it."))
		else
			to_chat(user, span_notice("You discreetly slip [I] into [parent]."))

/datum/storage/pockets/small
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_SMALL
	attack_hand_interact = FALSE

/datum/storage/pockets/tiny
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_TINY
	attack_hand_interact = FALSE

/datum/storage/pockets/small/fedora/New()
	. = ..()
	var/static/list/exception_cache = typecacheof(list(
		/obj/item/katana,
		/obj/item/toy/katana,
		/obj/item/nullrod/claymore/katana,
		/obj/item/energy_katana,
		/obj/item/gun/ballistic/automatic/tommygun,
	))
	exception_hold = exception_cache

/datum/storage/pockets/small/fedora/detective
	attack_hand_interact = TRUE // so the detectives would discover pockets in their hats

/datum/storage/pockets/chefhat
	attack_hand_interact = TRUE
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/pockets/chefhat/New()
	. = ..()
	set_holdable(list(
		/obj/item/clothing/head/mob_holder,
		/obj/item/food/deadmouse
	))

/datum/storage/pockets/chefhat/can_insert(obj/item/to_insert, mob/user, messages, force)
	. = ..()
	if(istype(to_insert, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/mausholder = to_insert
		if(locate(/mob/living/simple_animal/mouse) in mausholder.contents)
			return
		return FALSE

/datum/storage/pockets/shoes
	attack_hand_interact = FALSE
	quickdraw = TRUE
	silent = TRUE

/datum/storage/pockets/shoes/New()
	. = ..()
	set_holdable(list(
		/obj/item/knife,
		/obj/item/switchblade,
		/obj/item/pen,
		/obj/item/scalpel,
		/obj/item/reagent_containers/syringe,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/reagent_containers/dropper,
		/obj/item/implanter,
		/obj/item/screwdriver,
		/obj/item/weldingtool/mini,
		/obj/item/firing_pin,
		/obj/item/suppressor,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_casing,
		/obj/item/lipstick,
		/obj/item/clothing/mask/cigarette,
		/obj/item/lighter,
		/obj/item/match,
		/obj/item/holochip,
		/obj/item/toy/crayon),
		list(/obj/item/screwdriver/power,
		/obj/item/ammo_casing/caseless/rocket,
		/obj/item/clothing/mask/cigarette/pipe,
		/obj/item/toy/crayon/spraycan)
		)

/datum/storage/pockets/shoes/clown/New()
	. = ..()
	set_holdable(list(
		/obj/item/knife,
		/obj/item/switchblade,
		/obj/item/pen,
		/obj/item/scalpel,
		/obj/item/reagent_containers/syringe,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/reagent_containers/dropper,
		/obj/item/implanter,
		/obj/item/screwdriver,
		/obj/item/weldingtool/mini,
		/obj/item/firing_pin,
		/obj/item/suppressor,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_casing,
		/obj/item/lipstick,
		/obj/item/clothing/mask/cigarette,
		/obj/item/lighter,
		/obj/item/match,
		/obj/item/holochip,
		/obj/item/toy/crayon,
		/obj/item/bikehorn),
		list(/obj/item/screwdriver/power,
		/obj/item/ammo_casing/caseless/rocket,
		/obj/item/clothing/mask/cigarette/pipe,
		/obj/item/toy/crayon/spraycan)
		)

/datum/storage/pockets/pocketprotector
	max_slots = 3
	max_specific_storage = WEIGHT_CLASS_TINY
	var/atom/original_parent

/datum/storage/pockets/pocketprotector/New()
	original_parent = parent
	. = ..()
	set_holdable(list( //Same items as a PDA
		/obj/item/pen,
		/obj/item/toy/crayon,
		/obj/item/lipstick,
		/obj/item/flashlight/pen,
		/obj/item/clothing/mask/cigarette)
		)

/datum/storage/pockets/pocketprotector/real_location()
	return original_parent

/datum/storage/pockets/helmet
	quickdraw = TRUE
	max_total_storage = 6

/datum/storage/pockets/helmet/New()
	. = ..()
	set_holdable(list(/obj/item/reagent_containers/food/drinks/bottle/vodka,
					  /obj/item/reagent_containers/food/drinks/bottle/molotov,
					  /obj/item/reagent_containers/food/drinks/drinkingglass,
					  /obj/item/ammo_box/a762))


/datum/storage/pockets/void_cloak
	quickdraw = TRUE
	max_slots = 3

/datum/storage/pockets/void_cloak/New()
	. = ..()
	var/static/list/exception_cache = typecacheof(list(/obj/item/clothing/neck/heretic_focus, /obj/item/codex_cicatrix))
	exception_hold = exception_cache
