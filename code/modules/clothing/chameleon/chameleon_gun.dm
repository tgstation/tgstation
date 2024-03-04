
/obj/item/gun/energy/laser/chameleon
	ammo_type = list(/obj/item/ammo_casing/energy/chameleon)
	pin = /obj/item/firing_pin
	automatic_charge_overlays = FALSE
	can_select = FALSE
	actions_types = list(/datum/action/item_action/chameleon/change/gun)

	/// The vars copied over to our projectile on fire.
	var/list/chameleon_projectile_vars

	/// The badmin mode. Makes your projectiles act like the real deal.
	var/real_hits = FALSE

/obj/item/gun/energy/laser/chameleon/Initialize(mapload)
	. = ..()
	recharge_newshot()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)
	// Init order shenanigans dictate we have to do this last so we can't just use `active_type`
	var/datum/action/item_action/chameleon/change/gun/gun_action = locate() in actions
	gun_action?.update_look(/obj/item/gun/energy/laser)

/**
 * Description: Resets the currently loaded chameleon variables, essentially resetting it to brand new.
 * Arguments: []
 */
/obj/item/gun/energy/laser/chameleon/proc/reset_chameleon_vars()
	chameleon_projectile_vars = list()

	if(chambered)
		chambered.firing_effect_type = initial(chambered.firing_effect_type)

	fire_sound = initial(fire_sound)
	burst_size = initial(burst_size)
	fire_delay = initial(fire_delay)
	inhand_x_dimension = initial(inhand_x_dimension)
	inhand_y_dimension = initial(inhand_y_dimension)

	QDEL_NULL(chambered.loaded_projectile)
	chambered.newshot()

/**
 * Description: Sets what gun we should be mimicking.
 * Arguments: [obj/item/gun/gun_to_set (the gun we're trying to mimic)]
 */
/obj/item/gun/energy/laser/chameleon/proc/set_chameleon_gun(obj/item/gun/gun_to_set)
	if(!istype(gun_to_set))
		stack_trace("[gun_to_set] is not a valid gun.")
		return FALSE

	fire_sound = gun_to_set.fire_sound
	burst_size = gun_to_set.burst_size
	fire_delay = gun_to_set.fire_delay
	inhand_x_dimension = gun_to_set.inhand_x_dimension
	inhand_y_dimension = gun_to_set.inhand_y_dimension

	if(istype(gun_to_set, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/ball_gun = gun_to_set
		var/obj/item/ammo_box/ball_ammo = new ball_gun.spawn_magazine_type(gun_to_set)
		qdel(ball_gun)

		if(!istype(ball_ammo) || !ball_ammo.ammo_type)
			qdel(ball_ammo)
			return FALSE

		var/obj/item/ammo_casing/ball_cartridge = new ball_ammo.ammo_type(gun_to_set)
		set_chameleon_ammo(ball_cartridge)

	else if(istype(gun_to_set, /obj/item/gun/magic))
		var/obj/item/gun/magic/magic_gun = gun_to_set
		var/obj/item/ammo_casing/magic_cartridge = new magic_gun.ammo_type(gun_to_set)
		set_chameleon_ammo(magic_cartridge)

	else if(istype(gun_to_set, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = gun_to_set
		if(islist(energy_gun.ammo_type) && energy_gun.ammo_type.len)
			var/obj/item/ammo_casing/energy_cartridge = energy_gun.ammo_type[1]
			set_chameleon_ammo(energy_cartridge)

	else if(istype(gun_to_set, /obj/item/gun/syringe))
		var/obj/item/ammo_casing/syringe_cartridge = new /obj/item/ammo_casing/syringegun(src)
		set_chameleon_ammo(syringe_cartridge)

	else
		var/obj/item/ammo_casing/default_cartridge = new /obj/item/ammo_casing(src)
		set_chameleon_ammo(default_cartridge)

/**
 * Description: Sets the ammo type our gun should have.
 * Arguments: [obj/item/ammo_casing/cartridge (the ammo_casing we're trying to copy)]
 */
/obj/item/gun/energy/laser/chameleon/proc/set_chameleon_ammo(obj/item/ammo_casing/cartridge)
	if(!istype(cartridge))
		stack_trace("[cartridge] is not a valid ammo casing.")
		return FALSE

	var/obj/projectile/projectile = cartridge.loaded_projectile
	set_chameleon_projectile(projectile)

/**
 * Description: Sets the current projectile variables for our chameleon gun.
 * Arguments: [obj/projectile/template_projectile (the projectile we're trying to copy)]
 */
/obj/item/gun/energy/laser/chameleon/proc/set_chameleon_projectile(obj/projectile/template_projectile)
	if(!istype(template_projectile))
		stack_trace("[template_projectile] is not a valid projectile.")
		return FALSE

	chameleon_projectile_vars = list("name" = "practice laser", "icon" = 'icons/obj/weapons/guns/projectiles.dmi', "icon_state" = "laser")

	var/default_state = isnull(template_projectile.icon_state) ? "laser" : template_projectile.icon_state

	chameleon_projectile_vars["name"] = template_projectile.name
	chameleon_projectile_vars["icon"] = template_projectile.icon
	chameleon_projectile_vars["icon_state"] = default_state
	chameleon_projectile_vars["speed"] = template_projectile.speed
	chameleon_projectile_vars["color"] = template_projectile.color
	chameleon_projectile_vars["hitsound"] = template_projectile.hitsound
	chameleon_projectile_vars["impact_effect_type"] = template_projectile.impact_effect_type
	chameleon_projectile_vars["range"] = template_projectile.range
	chameleon_projectile_vars["suppressed"] = template_projectile.suppressed
	chameleon_projectile_vars["hitsound_wall"] = template_projectile.hitsound_wall
	chameleon_projectile_vars["pass_flags"] = template_projectile.pass_flags

	if(istype(chambered, /obj/item/ammo_casing/energy/chameleon))
		var/obj/item/ammo_casing/energy/chameleon/cartridge = chambered

		cartridge.loaded_projectile.name = template_projectile.name
		cartridge.loaded_projectile.icon = template_projectile.icon
		cartridge.loaded_projectile.icon_state = default_state
		cartridge.loaded_projectile.speed = template_projectile.speed
		cartridge.loaded_projectile.color = template_projectile.color
		cartridge.loaded_projectile.hitsound = template_projectile.hitsound
		cartridge.loaded_projectile.impact_effect_type = template_projectile.impact_effect_type
		cartridge.loaded_projectile.range = template_projectile.range
		cartridge.loaded_projectile.suppressed = template_projectile.suppressed
		cartridge.loaded_projectile.hitsound_wall =	template_projectile.hitsound_wall
		cartridge.loaded_projectile.pass_flags = template_projectile.pass_flags

		cartridge.projectile_vars = chameleon_projectile_vars.Copy()

	if(real_hits)
		qdel(chambered.loaded_projectile)
		chambered.projectile_type = template_projectile.type

	qdel(template_projectile)


/**
 * Description: Resets our chameleon variables, then resets the entire gun to mimic the given guntype.
 * Arguments: [guntype (the gun we're copying, pathtyped to obj/item/gun)]
 */
/obj/item/gun/energy/laser/chameleon/proc/set_chameleon_disguise(guntype)
	reset_chameleon_vars()
	var/obj/item/gun/new_gun = new guntype(src)
	set_chameleon_gun(new_gun)
	qdel(new_gun)
