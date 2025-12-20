/obj/item/wallframe/secure_safe
	name = "secure safe frame"
	desc = "A locked safe. It being unpowered prevents any access until placed back onto a wall."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "wall_safe"
	base_icon_state = "wall_safe"
	result_path = /obj/structure/secure_safe
	pixel_shift = 32
	w_class = WEIGHT_CLASS_GIGANTIC
	obj_flags = CONDUCTS_ELECTRICITY
	resistance_flags = FIRE_PROOF
	custom_materials = list(
		/datum/material/alloy/plasteel = SHEET_MATERIAL_AMOUNT * 8,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
	)
	material_flags = MATERIAL_EFFECTS
	/// The lock code transferred from the structure
	var/stored_lock_code

/obj/item/wallframe/secure_safe/Initialize(mapload)
	. = ..()
	create_storage(
		max_specific_storage = WEIGHT_CLASS_GIGANTIC,
		max_total_storage = 20,
	)
	if(stored_lock_code && !(obj_flags & EMAGGED))
		atom_storage.set_locked(STORAGE_FULLY_LOCKED)
	update_appearance()

/obj/item/wallframe/secure_safe/update_icon_state()
	. = ..()
	if(obj_flags & EMAGGED)
		icon_state = "[base_icon_state]_broken"
	else
		icon_state = "[base_icon_state][stored_lock_code ? "_locked" : null]"

/obj/item/wallframe/secure_safe/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE

	obj_flags |= EMAGGED
	visible_message(span_warning("Sparks fly from [src]!"), blind_message = span_hear("You hear a faint electrical spark."))
	balloon_alert(user, "lock destroyed")
	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	stored_lock_code = null
	atom_storage.locked = STORAGE_NOT_LOCKED
	update_appearance()
	return TRUE

/obj/item/wallframe/secure_safe/after_attach(obj/structure/secure_safe/safe)
	if(!istype(safe))
		return ..()

	for(var/obj/item in contents)
		item.forceMove(safe)

	var/datum/component/lockable_storage/storage_component = safe.GetComponent(/datum/component/lockable_storage)
	if(stored_lock_code)
		storage_component?.set_lock_code(stored_lock_code)

	if(obj_flags & EMAGGED)
		storage_component?.break_lock()

	return ..()

/datum/armor/secure_safe
	melee = 30
	bullet = 30
	laser = 20
	energy = 20
	bomb = 30
	fire = 95
	acid = 30

/**
 * Wall safes
 * Holds items and uses the lockable storage component
 * to allow people to lock items up.
 */
/obj/structure/secure_safe
	name = "secure safe"
	desc = "Excellent for securing things away from grubby hands."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "wall_safe"
	base_icon_state = "wall_safe"
	anchored = TRUE
	density = FALSE
	resistance_flags = FIRE_PROOF
	obj_flags = CONDUCTS_ELECTRICITY
	armor_type = /datum/armor/secure_safe
	max_integrity = 300
	damage_deflection = 21
	custom_materials = list(
		/datum/material/alloy/plasteel = SHEET_MATERIAL_AMOUNT*5,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT*3,
	)
	material_flags = MATERIAL_EFFECTS
	/// The lock code used to open the safe
	var/stored_lock_code

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/secure_safe, 32)

/obj/structure/secure_safe/Initialize(mapload)
	. = ..()
	//this will create the storage for us.
	AddComponent(/datum/component/lockable_storage, stored_lock_code)
	if(mapload)
		PopulateContents()
		find_and_mount_on_atom()
	RegisterSignal(src, COMSIG_LOCKABLE_STORAGE_SET_CODE, PROC_REF(update_lock_code))

/obj/structure/secure_safe/find_and_mount_on_atom(mark_for_late_init, late_init)
	if(!density)
		return ..()

/obj/structure/secure_safe/atom_deconstruct(disassembled)
	if(!density) //if we're a wall item, we'll drop a wall frame.
		var/obj/item/wallframe/secure_safe/new_safe = new(get_turf(src))

		// Transfer lock code to the wallframe
		var/datum/component/lockable_storage/storage_component = GetComponent(/datum/component/lockable_storage)
		if(storage_component)
			new_safe.stored_lock_code = storage_component.lock_code

		if(obj_flags & EMAGGED)
			new_safe.obj_flags |= EMAGGED

		new_safe.update_appearance()

		for(var/obj/item in contents)
			item.forceMove(new_safe)

/obj/structure/secure_safe/proc/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/structure/secure_safe/proc/update_lock_code(obj/structure/secure_safe/safe, new_code)
	SIGNAL_HANDLER

	stored_lock_code = new_code

/obj/structure/secure_safe/ex_act(severity, target)
	if(severity <= EXPLODE_LIGHT)
		return FALSE
	return ..()

/obj/structure/secure_safe/hos
	name = "head of security's safe"

/**
 * This safe is meant to be damn robust. To break in, you're supposed to get creative, or use acid or an explosion.
 *
 * This makes the safe still possible to break in for someone who is prepared and capable enough, either through
 * chemistry, botany or whatever else.
 *
 * The safe is also weak to explosions, so spending some early TC could allow an antag to blow it upen if they can
 * get access to it.
 */
/obj/structure/secure_safe/caps_spare
	name = "captain's spare ID safe"
	desc = "In case of emergency, do not break glass. All Captains and Acting Captains are provided with codes to access this safe. \
		It is made out of the same material as the station's Black Box and is designed to resist all conventional weaponry. \
		There appears to be a small amount of surface corrosion. It doesn't look like it could withstand much of an explosion.\
		Due to the expensive material, it was made incredibly small to cut corners, leaving only enough room to fit something as slim as an ID card."
	icon_state = "spare_safe"
	base_icon_state = "spare_safe"
	armor_type = /datum/armor/safe_caps_spare
	damage_deflection = 30 // prevents stealing the captain's spare using null rods/lavaland monsters/AP projectiles
	density = TRUE
	anchored_tabletop_offset = 6
	custom_materials = list(
		/datum/material/alloy/plasteel = SHEET_MATERIAL_AMOUNT*5,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT*3,
	)
	material_flags = MATERIAL_EFFECTS

/datum/armor/safe_caps_spare
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 70
	fire = 80
	acid = 70

/obj/structure/secure_safe/caps_spare/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(/obj/item/card/id)
	AddComponent(/datum/component/lockable_storage, \
		lock_code = SSid_access.spare_id_safe_code, \
		can_hack_open = FALSE, \
	)

/obj/structure/secure_safe/caps_spare/PopulateContents()
	new /obj/item/card/id/advanced/gold/captains_spare(src)

/obj/structure/secure_safe/caps_spare/rust_heretic_act()
	take_damage(damage_amount = 100, damage_type = BRUTE, damage_flag = MELEE, armour_penetration = 100)
