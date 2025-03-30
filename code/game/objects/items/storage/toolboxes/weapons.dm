/obj/item/storage/toolbox/maint_kit
	name = "gun maintenance kit"
	desc = "It contains some gun maintenance supplies"
	icon_state = "maint_kit"
	inhand_icon_state = "ammobox"
	has_latches = FALSE
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'

/obj/item/storage/toolbox/maint_kit/PopulateContents(datum/storage_config/config)
	config.compute_max_item_weight = TRUE
	config.compute_max_total_weight = TRUE

	return list(
		/obj/item/gun_maintenance_supplies,
		/obj/item/gun_maintenance_supplies,
		/obj/item/gun_maintenance_supplies,
	)

/obj/item/storage/toolbox/ammobox
	name = "ammo canister"
	desc = "A metal canister designed to hold ammunition"
	icon_state = "ammobox"
	inhand_icon_state = "ammobox"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	has_latches = FALSE
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	///The ammo box to spawn
	var/obj/item/ammo_box/ammo_to_spawn

/obj/item/storage/toolbox/ammobox/PopulateContents()
	if(isnull(ammo_to_spawn))
		return NONE

	. = list()
	for(var/_ in 1 to 6)
		. += ammo_to_spawn

/obj/item/storage/toolbox/ammobox/strilka310
	name = ".310 Strilka ammo box (Surplus?)"
	desc = "It contains a few clips. Goddamn, this thing smells awful. \
		Has this been sitting in a warehouse for the last several centuries?"
	ammo_to_spawn = /obj/item/ammo_box/strilka310

/obj/item/storage/toolbox/ammobox/strilka310/surplus
	ammo_to_spawn = /obj/item/ammo_box/strilka310/surplus

/obj/item/storage/toolbox/ammobox/wt550m9
	name = "4.6x30mm ammo box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/wt550m9

/obj/item/storage/toolbox/ammobox/wt550m9ap
	name = "4.6x30mm AP ammo box"
	ammo_to_spawn = /obj/item/ammo_box/magazine/wt550m9/wtap

/obj/item/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "syndicate"
	inhand_icon_state = "toolbox_syndi"
	force = 15
	throwforce = 18
	material_flags = NONE
	storage_type = /datum/storage/toolbox/syndicate

/obj/item/storage/toolbox/syndicate/PopulateContents()
	return list(
		/obj/item/screwdriver/nuke,
		/obj/item/wrench,
		/obj/item/weldingtool/largetank,
		/obj/item/crowbar/red,
		new /obj/item/wirecutters(null, "red"),
		/obj/item/multitool,
		/obj/item/clothing/gloves/combat,
	)

/obj/item/storage/toolbox/guncase
	name = "gun case"
	desc = "A weapon's case. Has a blood-red 'S' stamped on the cover."
	icon = 'icons/obj/storage/case.dmi'
	icon_state = "infiltrator_case"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	inhand_icon_state = "infiltrator_case"
	has_latches = FALSE
	storage_type = /datum/storage/toolbox/guncase

	///Weapon to spawn in this toolbox
	var/weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol
	///Extra item to spawn in this toolbox
	var/extra_to_spawn = /obj/item/ammo_box/magazine/m9mm

/obj/item/storage/toolbox/guncase/PopulateContents()
	new weapon_to_spawn(src)
	for(var/i in 1 to 3)
		new extra_to_spawn(src)

	. = list()
	for(var/obj/item/insert as anything in src)
		insert.moveToNullspace()
		. += insert

/obj/item/storage/toolbox/guncase/traitor
	name = "makarov gun case"
	desc = "A weapon's case. Has a blood-red 'S' stamped on the cover. There seems to be a strange switch along the side inside a plastic flap."
	icon_state = "pistol_case"
	base_icon_state = "pistol_case"
	// What ammo box do we spawn in our case?
	var/ammo_box_to_spawn = /obj/item/ammo_box/c9mm
	// Timer for the bomb in the case.
	var/explosion_timer
	// Whether or not our case is exploding. Used for determining sprite changes.
	var/currently_exploding = FALSE

/obj/item/storage/toolbox/guncase/traitor/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/storage/toolbox/guncase/traitor/examine(mob/user)
	. = ..()
	. += span_notice("Activate the Evidence Disposal Explosive using Alt-Right-Click.")

/obj/item/storage/toolbox/guncase/traitor/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	context[SCREENTIP_CONTEXT_ALT_RMB] = "Activate Evidence Disposal Explosive"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/storage/toolbox/guncase/traitor/PopulateContents()
	. = list()

	. += weapon_to_spawn
	for(var/i in 1 to 2)
		. += extra_to_spawn
	. += ammo_box_to_spawn

/obj/item/storage/toolbox/guncase/traitor/update_icon_state()
	. = ..()
	if(currently_exploding)
		icon_state = "[base_icon_state]_exploding"
	else
		icon_state = "[base_icon_state]"

/obj/item/storage/toolbox/guncase/traitor/click_alt_secondary(mob/user)
	. = ..()
	var/i_dont_even_think_once_about_blowing_stuff_up = tgui_alert(user, "Would you like to activate the evidence disposal bomb now?", "BYE BYE", list("Yes","No"))
	if(i_dont_even_think_once_about_blowing_stuff_up == "No")
		return
	explosion_timer = addtimer(CALLBACK(src, PROC_REF(think_fast_chucklenuts)), 5 SECONDS, (TIMER_UNIQUE|TIMER_OVERRIDE))
	to_chat(user, span_warning("You prime [src]'s evidence disposal bomb!"))
	log_bomber(user, "has activated a", src, "for detonation")
	playsound(src, 'sound/items/weapons/armbomb.ogg', 50, TRUE)
	currently_exploding = TRUE
	update_appearance()

/// proc to handle our detonation
/obj/item/storage/toolbox/guncase/traitor/proc/think_fast_chucklenuts()
	explosion(src, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 2, explosion_cause = src)
	qdel(src)

/obj/item/storage/toolbox/guncase/traitor/ammunition
	name = "makarov 9mm magazine case"
	weapon_to_spawn = /obj/item/ammo_box/magazine/m9mm

/obj/item/storage/toolbox/guncase/traitor/donksoft
	name = "\improper Donksoft riot pistol gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/toy/riot/clandestine
	extra_to_spawn = /obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_box_to_spawn = /obj/item/ammo_box/foambox/riot

/obj/item/storage/toolbox/guncase/traitor/ammunition/donksoft
	name = "\improper Donksoft riot pistol magazine case"
	weapon_to_spawn = /obj/item/ammo_box/magazine/toy/pistol/riot
	extra_to_spawn = /obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_box_to_spawn = /obj/item/ammo_box/foambox/riot

/obj/item/storage/toolbox/guncase/bulldog
	name = "bulldog gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/shotgun/bulldog
	extra_to_spawn = /obj/item/ammo_box/magazine/m12g

/obj/item/storage/toolbox/guncase/c20r
	name = "c-20r gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/c20r
	extra_to_spawn = /obj/item/ammo_box/magazine/smgm45

/obj/item/storage/toolbox/guncase/smartgun
	name = "adielle smartgun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/smartgun
	extra_to_spawn = /obj/item/ammo_box/magazine/smartgun

/obj/item/storage/toolbox/guncase/clandestine
	name = "clandestine gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/clandestine
	extra_to_spawn = /obj/item/ammo_box/magazine/m10mm

/obj/item/storage/toolbox/guncase/m90gl
	name = "m-90gl gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/m90
	extra_to_spawn = /obj/item/ammo_box/magazine/m223

/obj/item/storage/toolbox/guncase/m90gl/PopulateContents()
	. = list()

	. += weapon_to_spawn
	for(var/i in 1 to 2)
		. += extra_to_spawn
	. += /obj/item/ammo_box/a40mm/rubber

/obj/item/storage/toolbox/guncase/rocketlauncher
	name = "rocket launcher gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/rocketlauncher
	extra_to_spawn = /obj/item/ammo_box/rocket

/obj/item/storage/toolbox/guncase/rocketlauncher/PopulateContents()
	return list(
		weapon_to_spawn,
		extra_to_spawn
	)

/obj/item/storage/toolbox/guncase/revolver
	name = "revolver gun case"
	weapon_to_spawn = /obj/item/gun/ballistic/revolver/badass/nuclear
	extra_to_spawn = /obj/item/ammo_box/a357

/obj/item/storage/toolbox/guncase/sword_and_board
	name = "energy sword and shield weapon case"
	weapon_to_spawn = /obj/item/melee/energy/sword
	extra_to_spawn = /obj/item/shield/energy

/obj/item/storage/toolbox/guncase/sword_and_board/PopulateContents()
	return list(
		weapon_to_spawn,
		extra_to_spawn,
		/obj/item/clothing/head/costume/knight,
	)

/obj/item/storage/toolbox/guncase/cqc
	name = "\improper CQC equipment case"
	weapon_to_spawn = /obj/item/book/granter/martial/cqc
	extra_to_spawn = /obj/item/storage/box/syndie_kit/imp_stealth

/obj/item/storage/toolbox/guncase/cqc/PopulateContents(datum/storage_config/config)
	config.compute_max_total_weight = TRUE

	return list(
		weapon_to_spawn,
		extra_to_spawn,
		/obj/item/clothing/head/costume/snakeeater,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
	)

/obj/item/storage/toolbox/guncase/soviet
	name = "ancient gun case"
	desc = "A weapon's case. Has the symbol of the Third Soviet Union stamped on the side."
	icon_state = "sakhno_case"
	inhand_icon_state = "sakhno_case"
	weapon_to_spawn = /obj/effect/spawner/random/sakhno
	extra_to_spawn = /obj/effect/spawner/random/sakhno/ammo

/obj/item/storage/toolbox/guncase/soviet/PopulateContents(datum/storage_config/config)
	config.compute_max_total_weight = TRUE

	return ..()

/obj/item/storage/toolbox/guncase/monkeycase
	name = "monkey gun case"
	desc = "Everything a monkey needs to truly go ape-shit. There's a paw-shaped hand scanner lock on the front of the case."

/obj/item/storage/toolbox/guncase/monkeycase/Initialize(mapload)
	. = ..()
	atom_storage.locked = STORAGE_SOFT_LOCKED

/obj/item/storage/toolbox/guncase/monkeycase/attack_self(mob/user, modifiers)
	if(!monkey_check(user))
		return
	return ..()

/obj/item/storage/toolbox/guncase/monkeycase/attack_self_secondary(mob/user, modifiers)
	attack_self(user, modifiers)
	return

/obj/item/storage/toolbox/guncase/monkeycase/attack_hand(mob/user, list/modifiers)
	if(!monkey_check(user))
		return
	return ..()

/obj/item/storage/toolbox/guncase/monkeycase/proc/monkey_check(mob/user)
	if(atom_storage.locked == STORAGE_NOT_LOCKED)
		return TRUE

	if(is_simian(user))
		atom_storage.locked = STORAGE_NOT_LOCKED
		to_chat(user, span_notice("You place your paw on the paw scanner, and hear a soft click as [src] unlocks!"))
		playsound(src, 'sound/items/click.ogg', 25, TRUE)
		return TRUE
	to_chat(user, span_warning("You put your hand on the hand scanner, and it rejects it with an angry chimpanzee screech!"))
	playsound(src, SFX_SCREECH, 75, TRUE)
	return FALSE

/obj/item/storage/toolbox/guncase/monkeycase/PopulateContents(datum/storage_config/config)
	config.compute_max_item_count = TRUE
	config.compute_max_total_weight = TRUE

	switch(rand(1, 3))
		if(1)
			// Uzi with a boxcutter.
			. = list(
				/obj/item/gun/ballistic/automatic/mini_uzi/chimpgun,
				/obj/item/ammo_box/magazine/uzim9mm,
				/obj/item/ammo_box/magazine/uzim9mm,
				/obj/item/boxcutter/extended,
			)
		if(2)
			// Thompson with a boxcutter.
			. = list(
				/obj/item/gun/ballistic/automatic/tommygun/chimpgun,
				/obj/item/ammo_box/magazine/tommygunm45,
				/obj/item/ammo_box/magazine/tommygunm45,
				/obj/item/boxcutter/extended,
			)
		if(3)
			// M1911 with a switchblade and an extra banana bomb.
			. = list(
				/obj/item/gun/ballistic/automatic/pistol/m1911/chimpgun,
				/obj/item/ammo_box/magazine/m45,
				/obj/item/ammo_box/magazine/m45,
				/obj/item/switchblade/extended,
				/obj/item/food/grown/banana/bunch/monkeybomb,
			)

	// Banana bomb! Basically a tiny flashbang for monkeys.
	. += /obj/item/food/grown/banana/bunch/monkeybomb
	// Somewhere to store it all.
	. += /obj/item/storage/backpack/messenger


/obj/item/storage/toolbox/guncase/doublesword
	name = "double-bladed energy sword weapon case"
	weapon_to_spawn = /obj/item/dualsaber
	extra_to_spawn = /obj/item/soap/syndie
	storage_type = /datum/storage/toolbox/double_sword

/obj/item/storage/toolbox/guncase/doublesword/PopulateContents()
	return list(
		weapon_to_spawn,
		extra_to_spawn,
		/obj/item/mod/module/noslip,
		/obj/item/reagent_containers/hypospray/medipen/methamphetamine,
		/obj/item/clothing/under/rank/prisoner/nosensor,
	)
