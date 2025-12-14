/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	icon_state = "s-casing"
	worn_icon_state = "bullet"
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT)
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
	///pacifism check for boolet, set to FALSE if bullet is non-lethal
	var/harmful = TRUE
	/// How much force is applied when fired in zero-G
	var/newtonian_force = 1

	///If set to true or false, this ammunition can or cannot misfire, regardless the gun can_misfire setting
	var/can_misfire = null
	///This is how much misfire probability is added to the gun when it fires this casing.
	var/misfire_increment = 0
	///If set, this casing will damage any gun it's fired from by the specified amount
	var/integrity_damage = 0

	/// Set when this casing is fired. Only used for checking if it should burn a user's hand when caught from an ejection port.
	var/shot_timestamp = 0

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
	var/initial_damage = initial(exam_proj.damage)
	var/initial_stamina = initial(exam_proj.stamina)
	// projectile damage multiplier for guns with snowflaked damage multipliers
	var/proj_damage_mult = 1
	if(!ispath(exam_proj) || pellets == 0)
		return

	// are we in an ammo box?
	if(isammobox(loc))
		var/obj/item/ammo_box/our_box = loc
		// is our ammo box in a gun?
		if(isgun(our_box.loc))
			var/obj/item/gun/our_gun = our_box.loc
			// grab the damage multiplier
			proj_damage_mult = our_gun.projectile_damage_multiplier
	// if not, are we just in a gun e.g. chambered
	else if(isgun(loc))
		var/obj/item/gun/our_gun = loc
		// grab the damage multiplier.
		proj_damage_mult = our_gun.projectile_damage_multiplier
	var/list/readout = list()
	if(proj_damage_mult <= 0 || (initial_damage <= 0 && initial_stamina <= 0))
		return "Our legal team has determined the offensive nature of these [span_warning(caliber)] rounds to be esoteric."
	// No dividing by 0
	if(initial_damage)
		readout += "Most monkeys our legal team subjected to these [span_warning(caliber)] rounds succumbed to their wounds after [span_warning("[HITS_TO_CRIT((initial(exam_proj.damage) * proj_damage_mult) * pellets)] shot\s")] at point-blank, taking [span_warning("[pellets] shot\s")] per round."
	if(initial_stamina)
		readout += "[!readout.len ? "Most monkeys" : "More fortunate monkeys"] collapsed from exhaustion after [span_warning("[HITS_TO_CRIT((initial(exam_proj.stamina) * proj_damage_mult) * pellets)] impact\s")] of these [span_warning("[caliber]")] rounds."
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

/obj/item/ammo_casing/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
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
				to_chat(user, span_notice("You collect [boolets] [box.casing_phrasing]\s. [box] now contains [box.stored_ammo.len] [box.casing_phrasing]\s."))
			else
				to_chat(user, span_warning("You fail to collect anything!"))
	else
		return ..()

/obj/item/ammo_casing/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	bounce_away(FALSE, NONE)
	return ..()

/obj/item/ammo_casing/proc/bounce_away(still_warm = FALSE, bounce_delay = 3)
	update_appearance()
	SpinAnimation(10, 1)
	var/turf/T = get_turf(src)
	if(still_warm && T?.bullet_sizzle)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/items/tools/welder.ogg', 20, 1), bounce_delay) //If the turf is made of water and the shell casing is still hot, make a sizzling sound when it's ejected.
	else if(T?.bullet_bounce_sound)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, T.bullet_bounce_sound, 20, 1), bounce_delay) //Soft / non-solid turfs that shouldn't make a sound when a shell casing is ejected over them.
