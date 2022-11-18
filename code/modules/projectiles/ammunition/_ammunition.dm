/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	icon_state = "s-casing"
	worn_icon_state = "bullet"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron = 500)
	override_notes = TRUE
	///What sound should play when this ammo is fired
	var/fire_sound = null
	///Which kind of guns it can be loaded into
	var/caliber = null
	///The bullet type to create when New() is called
	var/projectile_type = null
	///the loaded projectile in this ammo casing
	var/obj/projectile/loaded_projectile = null
	///Pellets for spreadshot
	var/pellets = 1
	///Variance for inaccuracy fundamental to the casing
	var/variance = 0
	///Randomspread for automatics
	var/randomspread = 0
	///Delay for energy weapons
	var/delay = 0
	///Override this to make your gun have a faster fire rate, in tenths of a second. 4 is the default gun cooldown.
	var/click_cooldown_override = 0
	///the visual effect appearing when the ammo is fired.
	var/firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect
	var/heavy_metal = TRUE
	///pacifism check for boolet, set to FALSE if bullet is non-lethal
	var/harmful = TRUE

/obj/item/ammo_casing/spent
	name = "spent bullet casing"
	loaded_projectile = null

/obj/item/ammo_casing/Initialize(mapload)
	. = ..()
	if(projectile_type)
		loaded_projectile = new projectile_type(src)
	pixel_x = base_pixel_x + rand(-10, 10)
	pixel_y = base_pixel_y + rand(-10, 10)
	setDir(pick(GLOB.alldirs))
	update_appearance()

/obj/item/ammo_casing/Destroy()
	var/turf/T = get_turf(src)
	if(T && !loaded_projectile && is_station_level(T.z))
		SSblackbox.record_feedback("tally", "station_mess_destroyed", 1, name)
	QDEL_NULL(loaded_projectile)
	return ..()

/obj/item/ammo_casing/add_weapon_description()
	AddElement(/datum/element/weapon_description, attached_proc = PROC_REF(add_notes_ammo))

/**
 *
 * Outputs type-specific weapon stats for ammunition based on the projectile loaded inside the casing.
 * Distinguishes between critting and stam-critting in separate lines
 *
 */
/obj/item/ammo_casing/proc/add_notes_ammo()
	// Try to get a projectile to derive stats from
	var/obj/projectile/exam_proj = projectile_type
	if(!ispath(exam_proj) || pellets == 0)
		return

	var/list/readout = list()
	// No dividing by 0
	if(initial(exam_proj.damage) > 0)
		readout += "Most monkeys our legal team subjected to these [span_warning(caliber)] rounds succumbed to their wounds after [span_warning("[HITS_TO_CRIT(initial(exam_proj.damage) * pellets)] shot\s")] at point-blank, taking [span_warning("[pellets] shot\s")] per round"
	if(initial(exam_proj.stamina) > 0)
		readout += "[!readout.len ? "Most monkeys" : "More fortunate monkeys"] collapsed from exhaustion after [span_warning("[HITS_TO_CRIT(initial(exam_proj.stamina) * pellets)] impact\s")] of these [span_warning("[caliber]")] rounds"
	if(!readout.len) // Everything else failed, give generic text
		return "Our legal team has determined the offensive nature of these [span_warning(caliber)] rounds to be esoteric"
	return readout.Join("\n") // Sending over a single string, rather than the whole list

/obj/item/ammo_casing/update_icon_state()
	icon_state = "[initial(icon_state)][loaded_projectile ? "-live" : null]"
	return ..()

/obj/item/ammo_casing/update_desc()
	desc = "[initial(desc)][loaded_projectile ? null : " This one is spent."]"
	return ..()

/*
 * On accidental consumption, 'spend' the ammo, and add in some gunpowder
 */
/obj/item/ammo_casing/on_accidental_consumption(mob/living/carbon/victim, mob/living/carbon/user, obj/item/source_item,  discover_after = TRUE)
	if(loaded_projectile)
		loaded_projectile = null
		update_appearance()
		victim.reagents?.add_reagent(/datum/reagent/gunpowder, 3)
		source_item?.reagents?.add_reagent(/datum/reagent/gunpowder, source_item.reagents.total_volume*(2/3))

	return ..()

//proc to magically refill a casing with a new projectile
/obj/item/ammo_casing/proc/newshot() //For energy weapons, syringe gun, shotgun shells and wands (!).
	if(!loaded_projectile)
		loaded_projectile = new projectile_type(src, src)

/obj/item/ammo_casing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box))
		var/obj/item/ammo_box/box = I
		if(isturf(loc))
			var/boolets = 0
			for(var/obj/item/ammo_casing/bullet in loc)
				if (box.stored_ammo.len >= box.max_ammo)
					break
				if (bullet.loaded_projectile)
					if (box.give_round(bullet, 0))
						boolets++
				else
					continue
			if (boolets > 0)
				box.update_appearance()
				to_chat(user, span_notice("You collect [boolets] shell\s. [box] now contains [box.stored_ammo.len] shell\s."))
			else
				to_chat(user, span_warning("You fail to collect anything!"))
	else
		return ..()

/obj/item/ammo_casing/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	bounce_away(FALSE, NONE)
	return ..()

/obj/item/ammo_casing/proc/bounce_away(still_warm = FALSE, bounce_delay = 3)
	if(!heavy_metal)
		return
	update_appearance()
	SpinAnimation(10, 1)
	var/turf/T = get_turf(src)
	if(still_warm && T?.bullet_sizzle)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/items/welder.ogg', 20, 1), bounce_delay) //If the turf is made of water and the shell casing is still hot, make a sizzling sound when it's ejected.
	else if(T?.bullet_bounce_sound)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, T.bullet_bounce_sound, 20, 1), bounce_delay) //Soft / non-solid turfs that shouldn't make a sound when a shell casing is ejected over them.
