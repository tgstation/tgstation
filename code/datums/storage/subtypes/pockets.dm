/datum/storage/pockets
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = 50
	rustle_sound = FALSE

/datum/storage/pockets/attempt_insert(obj/item/to_insert, mob/user, override, force, messages)
	. = ..()
	if(!.)
		return

	if(!silent || override)
		return

	if(quickdraw)
		to_chat(user, span_notice("You discreetly slip [to_insert] into [parent]. Right-click to remove it."))
	else
		to_chat(user, span_notice("You discreetly slip [to_insert] into [parent]."))

/datum/storage/pockets/small
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_SMALL
	attack_hand_interact = FALSE

/datum/storage/pockets/tiny
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_TINY
	attack_hand_interact = FALSE

/datum/storage/pockets/small/fedora/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
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
	click_alt_open = FALSE

/datum/storage/pockets/chefhat
	attack_hand_interact = TRUE
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_NORMAL

/datum/storage/pockets/chefhat/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(list(
		/obj/item/clothing/head/mob_holder,
		/obj/item/food/deadmouse
	))

/datum/storage/pockets/chefhat/can_insert(obj/item/to_insert, mob/user, messages, force)
	. = ..()
	if(ispickedupmob(to_insert))
		var/obj/item/clothing/head/mob_holder/mausholder = to_insert
		if(locate(/mob/living/basic/mouse) in mausholder.contents)
			return
		return FALSE

/datum/storage/pockets/shoes
	max_slots = 2
	attack_hand_interact = FALSE
	quickdraw = TRUE
	silent = TRUE

/datum/storage/pockets/shoes/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(list(
		/obj/item/knife,
		/obj/item/spess_knife,
		/obj/item/switchblade,
		/obj/item/boxcutter,
		/obj/item/pen,
		/obj/item/scalpel,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/reagent_containers/dropper,
		/obj/item/implanter,
		/obj/item/screwdriver,
		/obj/item/weldingtool/mini,
		/obj/item/firing_pin,
		/obj/item/suppressor,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_box/magazine/toy/pistol,
		/obj/item/ammo_casing,
		/obj/item/lipstick,
		/obj/item/clothing/mask/cigarette,
		/obj/item/lighter,
		/obj/item/match,
		/obj/item/holochip,
		/obj/item/toy/crayon,
		/obj/item/reagent_containers/cup/glass/flask),
		list(/obj/item/screwdriver/power,
		/obj/item/ammo_casing/rocket,
		/obj/item/clothing/mask/cigarette/pipe,
		/obj/item/toy/crayon/spraycan)
		)

/datum/storage/pockets/shoes/clown/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(
		can_hold_list = list(
			/obj/item/ammo_box/magazine/m10mm,
			/obj/item/ammo_box/magazine/m45,
			/obj/item/ammo_box/magazine/m9mm,
			/obj/item/ammo_casing,
			/obj/item/bikehorn,
			/obj/item/clothing/mask/cigarette,
			/obj/item/dnainjector,
			/obj/item/firing_pin,
			/obj/item/holochip,
			/obj/item/implanter,
			/obj/item/knife,
			/obj/item/lighter,
			/obj/item/lipstick,
			/obj/item/match,
			/obj/item/pen,
			/obj/item/reagent_containers/cup/glass/flask,
			/obj/item/reagent_containers/dropper,
			/obj/item/reagent_containers/hypospray/medipen,
			/obj/item/reagent_containers/syringe,
			/obj/item/scalpel,
			/obj/item/screwdriver,
			/obj/item/spess_knife,
			/obj/item/suppressor,
			/obj/item/switchblade,
			/obj/item/toy/crayon,
			/obj/item/weldingtool/mini,
		),
		cant_hold_list = list(
			/obj/item/ammo_casing/rocket,
			/obj/item/clothing/mask/cigarette/pipe,
			/obj/item/screwdriver/power,
			/obj/item/toy/crayon/spraycan,
		),
	)

/datum/storage/pockets/pocketprotector
	max_slots = 3
	max_specific_storage = WEIGHT_CLASS_TINY

/datum/storage/pockets/pocketprotector/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(list( //Same items as a PDA
		/obj/item/pen,
		/obj/item/toy/crayon,
		/obj/item/lipstick,
		/obj/item/flashlight/pen,
		/obj/item/lipstick,
	))

/datum/storage/pockets/helmet
	max_slots = 2
	quickdraw = TRUE
	max_total_storage = 6

/datum/storage/pockets/helmet/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(list(/obj/item/reagent_containers/cup/glass/bottle/vodka,
					  /obj/item/reagent_containers/cup/glass/bottle/molotov,
					  /obj/item/reagent_containers/cup/glass/drinkingglass,
					  /obj/item/ammo_box/strilka310))


/datum/storage/pockets/void_cloak
	quickdraw = TRUE
	max_total_storage = 5 // 2 small items + 1 tiny item, or 1 normal item + 1 small item
	max_slots = 3

/datum/storage/pockets/void_cloak/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(list(
		/obj/item/ammo_box/strilka310/lionhunter,
		/obj/item/bodypart, // Bodyparts are often used in rituals. They're also often normal sized, so you can only fit one.
		/obj/item/clothing/neck/eldritch_amulet,
		/obj/item/clothing/neck/heretic_focus,
		/obj/item/codex_cicatrix,
		/obj/item/eldritch_potion,
		/obj/item/food/grown/poppy, // Used to regain a Living Heart.
		/obj/item/melee/rune_carver,
		/obj/item/melee/sickly_blade, // Normal sized, so you can only fit one.
		/obj/item/organ, // Organs are also often used in rituals.
		/obj/item/reagent_containers/cup/beaker/eldritch,
	))

	var/static/list/exception_cache = typecacheof(list(/obj/item/bodypart, /obj/item/melee/sickly_blade))
	exception_hold = exception_cache
