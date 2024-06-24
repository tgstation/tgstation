/obj/item/suppressor/standard
	desc = "A small-arms suppressor for maximum espionage."

/obj/item/gun/ballistic
	/// Does this gun have mag and nomag on mob variance?
	var/alt_icons = FALSE
	/// What the icon state is for the on-back guns
	var/alt_icon_state
	/// How long it takes to reload a magazine.
	var/reload_time = 2 SECONDS
	/// if this gun has a penalty for reloading with an ammo_box type
	var/box_reload_penalty = TRUE
	/// reload penalty inflicted by using an ammo box instead of an individual cartridge, if not outright exchanging the magazine
	var/box_reload_delay = CLICK_CD_MELEE

/*
* hey there's like... no better place to put these overrides, sorry
* if there's other guns that use speedloader-likes or otherwise have a reason to
* probably not have a CLICK_CD_MELEE cooldown for reloading them with something else
* i guess add it here? only current example is revolvers
* you could maybe make a case for double-barrels? i'll leave that for discussion in the pr comments
*/

/obj/item/gun/ballistic/revolver
	box_reload_delay = CLICK_CD_RAPID // honestly this is negligible because of the inherent delay of having to switch hands

/obj/item/gun/ballistic/rifle/boltaction // slightly less negligible than a revolver, since this is mostly for fairly powerful but crew-accessible stuff like mosins
	box_reload_delay = CLICK_CD_RANGE

/obj/item/gun/ballistic/Initialize(mapload)
	. = ..()

	if(alt_icons)
		AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/update_overlays()
	. = ..()
	if(alt_icons)
		if(!magazine)
			if(alt_icon_state)
				inhand_icon_state = "[alt_icon_state]_nomag"
				worn_icon_state = "[alt_icon_state]_nomag"
			else
				inhand_icon_state = "[initial(icon_state)]_nomag"
				worn_icon_state = "[initial(icon_state)]_nomag"
		else
			if(alt_icon_state)
				inhand_icon_state = "[alt_icon_state]"
				worn_icon_state = "[alt_icon_state]"
			else
				inhand_icon_state = "[initial(icon_state)]"
				worn_icon_state = "[initial(icon_state)]"

/obj/item/gun/ballistic/proc/handle_magazine(mob/user, obj/item/ammo_box/magazine/inserting_magazine)
	if(magazine) // If we already have a magazine inserted, we're going to begin tactically reloading it.
		if(reload_time && !HAS_TRAIT(user, TRAIT_INSTANT_RELOAD)) // Check if we have a reload time to tactical reloading, or if we have the instant reload trait.
			to_chat(user, span_notice("You start to insert the magazine into [src]!"))
			if(!do_after(user, reload_time, src, IGNORE_USER_LOC_CHANGE)) // We are allowed to move while reloading.
				to_chat(user, span_danger("You fail to insert the magazine into [src]!"))
				return TRUE
		eject_magazine(user, FALSE, inserting_magazine) // We eject the magazine then insert the new one, while putting the old one in hands.
	else
		insert_magazine(user, inserting_magazine) // Otherwise, just insert it.

	return TRUE

/// Reloading with ammo box can incur penalty with some guns
/obj/item/gun/ballistic/proc/handle_box_reload(mob/user, obj/item/ammo_box/ammobox, num_loaded)
	var/box_load = FALSE // if you're reloading with an ammo box, inflicts a cooldown
	if(istype(ammobox, /obj/item/ammo_box) && box_reload_penalty)
		box_load = TRUE
		user.changeNext_move(box_reload_delay) // cooldown to simulate having to fumble for another round
		balloon_alert(user, "reload encumbered!")
	to_chat(user, span_notice("You load [num_loaded] [cartridge_wording]\s into [src][box_load ?  ", but it takes some extra effort" : ""]."))

/obj/effect/temp_visual/dir_setting/firing_effect
	light_system = OVERLAY_LIGHT
	light_outer_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

// Prevents gun sizes from changing due to suppressors
/obj/item/gun/ballistic/install_suppressor(obj/item/suppressor/added_suppressor)
	. = ..()
	// Prevents the w_class of the weapon from actually being increased
	w_class -= added_suppressor.w_class

// Prevents gun sizes from changing due to suppressors
/obj/item/gun/ballistic/clear_suppressor()
	if(!can_unsuppress)
		return
	// Adds to the w_class of the item before its promptly removed, resulting in a net zero w_class change
	if(isitem(suppressed))
		var/obj/item/item_suppressor = suppressed
		w_class += item_suppressor.w_class
	return ..()

/obj/item/gun/energy/laser
	name = "\improper Allstar SC-1 laser carbine"
	desc = "A basic energy-based laser carbine that fires concentrated beams of light which pass through glass and thin metal."

/obj/item/gun/energy/laser/carbine
	name = "\improper Allstar SC-1A laser auto-carbine"
	desc = "An basic energy-based laser auto-carbine that rapidly fires weakened, concentrated beams of light which pass through glass and thin metal."

/obj/item/gun/energy/e_gun
	name = "\improper Allstar SC-2 energy carbine"
	desc = "A basic hybrid energy carbine with two settings: disable and kill."

//Gunset for the APS Machine Pistol

/obj/item/storage/toolbox/guncase/skyrat/pistol
	name = "'Makarov pistol' gunset"

	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol
	extra_to_spawn = /obj/item/ammo_box/magazine/m9mm

/obj/item/storage/toolbox/guncase/skyrat/pistol/aps
	name = "'Stechkin APS machine pistol' gunset"

	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/aps
	extra_to_spawn = /obj/item/ammo_box/magazine/m9mm_aps


/obj/item/storage/toolbox/guncase/skyrat/c20r
	name = "'C-20r SMG' gunset"

	weapon_to_spawn = /obj/item/gun/ballistic/automatic/c20r
	extra_to_spawn = /obj/item/ammo_box/magazine/smgm45

/// Adds the gun manufacturer examine component to the gun on subtypes, does nothing by default
/obj/item/gun/proc/give_manufacturer_examine()
	return

// Ballistics

/obj/item/gun/ballistic/automatic/pistol/aps/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/rifle/boltaction/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SAKHNO)

/obj/item/gun/ballistic/rifle/boltaction/prime/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_XHIHAO)

/obj/item/gun/ballistic/rifle/boltaction/pipegun/give_manufacturer_examine()
	return

/obj/item/gun/ballistic/rifle/boltaction/harpoon/give_manufacturer_examine()
	return

/obj/item/gun/ballistic/rifle/boltaction/lionhunter/give_manufacturer_examine()
	return

/obj/item/gun/ballistic/revolver/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/shotgun/riot/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/shotgun/bulldog/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/shotgun/automatic/combat/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/automatic/pistol/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/revolver/c38/detective/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/shotgun/toy/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_DONK)

/obj/item/gun/ballistic/automatic/c20r/toy/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_DONK)

/obj/item/gun/ballistic/automatic/pistol/clandestine/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/automatic/l6_saw/toy/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_DONK)

/obj/item/gun/ballistic/revolver/mateba/give_manufacturer_examine()
	return

/obj/item/gun/ballistic/revolver/russian/give_manufacturer_examine()
	return

// Energy

/obj/item/gun/energy/e_gun/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ALLSTAR)

/obj/item/gun/energy/laser/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ALLSTAR)

/obj/item/gun/energy/pulse/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/energy/laser/redtag/give_manufacturer_examine()
	return

/obj/item/gun/energy/laser/bluetag/give_manufacturer_examine()
	return

/obj/item/gun/energy/laser/instakill/give_manufacturer_examine()
	return

/obj/item/gun/energy/laser/chameleon/give_manufacturer_examine()
	return

/obj/item/gun/energy/laser/captain/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/energy/laser/retro/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_REMOVED)

/obj/item/gun/energy/laser/retro/old/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/energy/e_gun/old/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/energy/e_gun/advtaser/cyborg/give_manufacturer_examine()
	return

/obj/item/gun/energy/recharge/ebow/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/energy/lasercannon/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ALLSTAR)

/obj/item/gun/energy/ionrifle/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ALLSTAR)

/obj/item/gun/energy/temperature/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ALLSTAR)

/obj/item/gun/energy/shrink_ray/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ABDUCTOR)

/obj/item/gun/energy/alien/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_ABDUCTOR)

// Syringe

/obj/item/gun/syringe/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_INTERDYNE)

/obj/item/gun/syringe/blowgun/give_manufacturer_examine()
	return

/obj/item/gun/syringe/syndicate/prototype/give_manufacturer_examine()
	return

/obj/item/gun/ballistic/revolver/syndicate/nuclear
	pin = /obj/item/firing_pin/implant/pindicate

/obj/item/gun/ballistic/bow/can_trigger_gun(mob/living/user, akimbo_usage)
	return TRUE
