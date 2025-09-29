//Boxes of ammo
/obj/item/ammo_box
	name = "ammo box (null_reference_exception)"
	desc = "A box of ammo."
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	abstract_type = /obj/item/ammo_box
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT
	inhand_icon_state = "syringe_kit"
	worn_icon_state = "ammobox"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*15)
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	override_notes = TRUE
	///list containing the actual ammo within the magazine
	var/list/stored_ammo = list()
	///type that the magazine will be searching for, rejects if not a subtype of
	var/ammo_type = /obj/item/ammo_casing
	/// wording used for individual units of ammo, e.g. cartridges (regular ammo), shells (shotgun shells)
	var/casing_phrasing = "round"
	///maximum amount of ammo in the magazine
	var/max_ammo = 7
	///Controls how sprites are updated for the ammo box; see defines in combat.dm: AMMO_BOX_ONE_SPRITE; AMMO_BOX_PER_BULLET; AMMO_BOX_FULL_EMPTY
	var/multiple_sprites = AMMO_BOX_ONE_SPRITE
	///For sprite updating, do we use initial(icon_state) or base_icon_state?
	var/multiple_sprite_use_base = FALSE
	///String, used for checking if ammo of different types but still fits can fit inside it; generally used for magazines
	var/caliber
	/// Determines whether ammo boxes can multiload in or out. See code/__DEFINES/combat.dm for details.
	var/ammo_box_multiload = AMMO_BOX_MULTILOAD_BOTH

	///Whether the magazine should start with nothing in it
	var/start_empty = FALSE

	/// If this and ammo_band_icon aren't null, run update_ammo_band(). Is the color of the band, such as blue on the detective's Iceblox.
	var/ammo_band_color
	/// If this and ammo_band_color aren't null, run update_ammo_band(). Is the greyscale icon used for the ammo band.
	var/ammo_band_icon
	/// Is the greyscale icon used for the ammo band when it's empty of bullets, only if it's not null.
	var/ammo_band_icon_empty

/obj/item/ammo_box/Initialize(mapload)
	. = ..()
	custom_materials = SSmaterials.FindOrCreateMaterialCombo(custom_materials, 0.1)
	if(!start_empty)
		top_off(starting=TRUE)
	update_icon_state()

/obj/item/ammo_box/Destroy(force)
	for (var/obj/item/ammo_casing/casing as anything in stored_ammo)
		if (!ispath(casing))
			qdel(casing)
	stored_ammo = null
	return ..()

/obj/item/ammo_box/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone in stored_ammo)
		remove_from_stored_ammo(gone)

/obj/item/ammo_box/proc/remove_from_stored_ammo(atom/movable/gone)
	stored_ammo -= gone
	update_appearance()

/obj/item/ammo_box/add_weapon_description()
	AddElement(/datum/element/weapon_description, attached_proc = PROC_REF(add_notes_box))

/obj/item/ammo_box/proc/add_notes_box()
	var/list/readout = list()

	if(caliber && max_ammo) // Text references a 'magazine' as only magazines generally have the caliber variable initialized
		readout += "Up to [span_warning("[max_ammo] [caliber] [casing_phrasing]s")] can be found within this magazine. \
		\nAccidentally discharging any of these projectiles may void your insurance contract."

	var/obj/item/ammo_casing/mag_ammo = get_and_shuffle_round()

	if(istype(mag_ammo))
		readout += "\n[mag_ammo.add_notes_ammo()]"

	return readout.Join("\n")

///list of every bullet in the box
///forces all bullets to lazyload
/obj/item/ammo_box/proc/ammo_list()
	for (var/i in 1 to length(stored_ammo))
		if (ispath(stored_ammo[i]))
			var/casing_type = stored_ammo[i]
			stored_ammo[i] = new casing_type(src)
	return stored_ammo.Copy()

/**
 * top_off is used to refill the magazine to max, in case you want to increase the size of a magazine with VV then refill it at once
 *
 * Arguments:
 * * load_type - if you want to specify a specific ammo casing type to load, enter the path here, otherwise it'll use the basic [/obj/item/ammo_box/var/ammo_type]. Must be a compatible round
 * * starting - Relevant for revolver cylinders, if FALSE then we mind the nulls that represent the empty cylinders (since those nulls don't exist yet if we haven't initialized when this is TRUE)
 */
/obj/item/ammo_box/proc/top_off(load_type, starting=FALSE)
	if(!load_type) //this check comes first so not defining an argument means we just go with default ammo
		load_type = ammo_type

	var/obj/item/ammo_casing/round_check = load_type
	if(!starting && !(caliber ? (caliber == initial(round_check.caliber)) : (ammo_type == load_type)))
		stack_trace("Tried loading unsupported ammocasing type [load_type] into ammo box [type].")
		return

	for(var/i in max(1, stored_ammo.len + 1) to max_ammo)
		stored_ammo += starting ? round_check : new round_check(src)
	update_appearance()

///gets a round from the magazine
/obj/item/ammo_box/proc/get_round()
	var/ammo_len = length(stored_ammo)
	if (!ammo_len)
		return null
	var/casing = stored_ammo[ammo_len]
	if (ispath(casing))
		casing = new casing(src)
		stored_ammo[ammo_len] = casing
	return casing

/// Gets a round from the magazine and puts it back at the bottom of the ammo list
/obj/item/ammo_box/proc/get_and_shuffle_round()
	var/casing = get_round()
	if (!casing)
		return null
	stored_ammo -= casing
	stored_ammo.Insert(1, casing)
	return casing

///puts a round into the magazine
/obj/item/ammo_box/proc/give_round(obj/item/ammo_casing/new_round, replace_spent = 0)
	// Boxes don't have a caliber type, magazines do. Not sure if it's intended or not, but if we fail to find a caliber, then we fall back to ammo_type.
	if(!new_round || !(caliber ? (caliber == new_round.caliber) : (ammo_type == new_round.type)))
		return FALSE

	if (stored_ammo.len < max_ammo)
		stored_ammo += new_round
		new_round.forceMove(src)
		return TRUE

	if(!replace_spent)
		return FALSE

	//for accessibles magazines (e.g internal ones) when full, start replacing spent ammo
	for(var/obj/item/ammo_casing/casing as anything in stored_ammo)
		if(ispath(casing) || casing.loaded_projectile)
			continue
		//found a spent ammo
		stored_ammo -= casing
		casing.forceMove(get_turf(src))

		stored_ammo += new_round
		new_round.forceMove(src)
		return TRUE
	return FALSE

///Whether or not the box can be loaded, used in overrides
/obj/item/ammo_box/proc/can_load(mob/user)
	return TRUE

/obj/item/ammo_box/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(IS_WRITING_UTENSIL(tool))
		if(!ammo_band_icon)
			balloon_alert(user, "no indicator support!")
			return
		var/new_color = input(user, "Set a new ammo band color, cancel to remove indicator", "Ammo Box Indicator Color", ammo_band_color) as color|null
		ammo_band_color = new_color
		balloon_alert(user, "indicator updated")
		update_appearance()
		return

	if(try_load(user, tool))
		return ITEM_INTERACT_SUCCESS

/obj/item/ammo_box/proc/try_load(mob/living/user, obj/item/tool, silent = FALSE, replace_spent = FALSE)
	var/num_loaded = 0
	if(!can_load(user))
		return

	if(istype(tool, /obj/item/ammo_box))
		var/obj/item/ammo_box/other_box = tool
		for(var/obj/item/ammo_casing/casing in other_box.ammo_list())
			var/did_load = give_round(casing, replace_spent)
			if(did_load)
				other_box.stored_ammo -= casing
				num_loaded++
			// failed to load (full already? ran out of ammo?)
			if(!did_load)
				break
			// this box can't accept being multiloaded into
			if(!(ammo_box_multiload & AMMO_BOX_MULTILOAD_IN))
				break
			// the other box can't give multiple bullets in one go to an unloaded magazine
			if(!isgun(loc) && !(other_box.ammo_box_multiload & AMMO_BOX_MULTILOAD_OUT))
				break
			// the other box can't give multiple bullets in one go to a loaded magazine
			if(isgun(loc) && !(other_box.ammo_box_multiload & AMMO_BOX_MULTILOAD_OUT_LOADED))
				break

		if(num_loaded)
			other_box.update_appearance()

	if(isammocasing(tool))
		var/obj/item/ammo_casing/casing = tool
		if(give_round(casing, replace_spent))
			user.transferItemToLoc(casing, src, TRUE)
			num_loaded++
			casing.update_appearance()

	if(num_loaded)
		if(!silent)
			to_chat(user, span_notice("You load [num_loaded > 1 ? "[num_loaded] [casing_phrasing]s" : "a [casing_phrasing]"] into \the [src]!"))
			playsound(src, 'sound/items/weapons/gun/general/mag_bullet_insert.ogg', 60, TRUE)
		update_appearance()

	return num_loaded

/obj/item/ammo_box/attack_self(mob/user)
	var/obj/item/ammo_casing/A = get_round()
	if(!A)
		return

	A.forceMove(drop_location())
	if(!user.is_holding(src) || !user.put_in_hands(A)) //incase they're using TK
		A.bounce_away(FALSE, NONE)
	playsound(src, 'sound/items/weapons/gun/general/mag_bullet_insert.ogg', 60, TRUE)
	to_chat(user, span_notice("You remove a [casing_phrasing] from [src]!"))
	update_appearance()

/obj/item/ammo_box/examine(mob/user)
	. = ..()
	var/shells_left = LAZYLEN(stored_ammo)
	var/obj/item/ammo_casing/top_round = get_round()
	if(!top_round)
		return
	. += "It has <b>[shells_left]</b> [casing_phrasing]\s remaining."
	// this is kind of awkward phrasing, but it's the top/ready ammo in the box
	// intended for people who have like three mislabeled magazines
	. += span_notice("\A <b>[top_round]</b> is ready.")

/obj/item/ammo_box/update_icon_state()
	. = ..()
	var/shells_left = LAZYLEN(stored_ammo)
	switch(multiple_sprites)
		if(AMMO_BOX_PER_BULLET)
			icon_state = "[multiple_sprite_use_base ? base_icon_state : initial(icon_state)]-[shells_left]"
		if(AMMO_BOX_FULL_EMPTY)
			icon_state = "[multiple_sprite_use_base ? base_icon_state : initial(icon_state)]-[shells_left ? "full" : "empty"]"

/obj/item/ammo_box/update_overlays()
	. = ..()
	if(ammo_band_color && ammo_band_icon)
		. += update_ammo_band()

/obj/item/ammo_box/proc/update_ammo_band()
	var/band_icon = ammo_band_icon
	if(!(length(stored_ammo)) && ammo_band_icon_empty)
		band_icon = ammo_band_icon_empty
	var/image/ammo_band_image = image(icon, src, band_icon)
	ammo_band_image.color = ammo_band_color
	ammo_band_image.appearance_flags = RESET_COLOR|KEEP_APART
	return ammo_band_image

/obj/item/ammo_box/magazine
	name = "A magazine (what?)"
	desc = "A magazine of rounds, they look like error signs... this should probably be reported somewhere."
	abstract_type = /obj/item/ammo_box/magazine
	ammo_box_multiload = AMMO_BOX_MULTILOAD_IN // so you can't use a magazine like a bootleg speedloader
	drop_sound = 'sound/items/handling/gun/ballistics/magazine/magazine_drop1.ogg'
	pickup_sound = 'sound/items/handling/gun/ballistics/magazine/magazine_pickup1.ogg'

///Count of number of bullets in the magazine
/obj/item/ammo_box/magazine/proc/ammo_count(countempties = TRUE)
	var/boolets = 0
	for(var/obj/item/ammo_casing/bullet as anything in stored_ammo)
		if(ispath(bullet) || bullet && (bullet.loaded_projectile || countempties))
			boolets++
	return boolets

///drops the entire contents of the magazine on the floor
/obj/item/ammo_box/magazine/proc/empty_magazine()
	var/turf/turf_mag = get_turf(src)
	var/obj/item/ammo_casing/casing = get_round()
	while (casing)
		casing.forceMove(turf_mag)
		casing = get_round()
