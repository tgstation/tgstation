/**
 * A gun that consumes a TTV to shoot an projectile with equivalent power.
 *
 * It's basically an immovable rod launcher.
 */
/obj/item/gun/blastcannon
	name = "blast cannon"
	desc = "A makeshift device used to concentrate a bomb's blast energy to a narrow wave. Small enough to stow in a bag."
	icon_state = "empty_blastcannon"
	inhand_icon_state = "blastcannon_empty"
	base_icon_state = "blastcannon"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	fire_sound = 'sound/weapons/blastcannon.ogg'
	item_flags = NONE
	clumsy_check = FALSE
	randomspread = FALSE

	// Firing data.
	/// The person who opened the valve on the TTV loaded into this.
	var/datum/weakref/cached_firer
	/// The target from the last click.
	var/datum/weakref/cached_target
	/// The modifiers from the last click.
	var/cached_modifiers

	// Explosion data:
	/// The TTV this contains that will be used to create the projectile
	var/obj/item/transfer_valve/bomb

	// For debugging/badminry
	/// Whether you can fire this without a bomb.
	var/bombcheck = TRUE
	/// The range this defaults to without a bomb for debugging and badminry
	var/debug_power = 0


/obj/item/gun/blastcannon/Initialize()
	. = ..()
	if(!pin)
		pin = new
	RegisterSignal(src, COMSIG_ATOM_INTERNAL_EXPLOSION, .proc/channel_blastwave)

/obj/item/gun/blastcannon/Destroy()
	if(bomb)
		QDEL_NULL(bomb)
	UnregisterSignal(src, COMSIG_ATOM_INTERNAL_EXPLOSION)
	cached_firer = null
	cached_target = null
	return ..()

/obj/item/gun/blastcannon/handle_atom_del(atom/A)
	if(A == bomb)
		bomb = null
		update_appearance()
	return ..()

/obj/item/gun/blastcannon/assume_air(datum/gas_mixture/giver)
	qdel(giver)
	return null // Required to make the TTV not vent gas directly into the firer.

/obj/item/gun/blastcannon/examine(mob/user)
	. = ..()
	if(bomb)
		. += "<span class='notice'>A bomb is loaded inside.</span>"

/obj/item/gun/blastcannon/attack_self(mob/user)
	if(bomb)
		bomb.forceMove(user.loc)
		user.put_in_hands(bomb)
		user.visible_message("<span class='warning'>[user] detaches [bomb] from [src].</span>")
		bomb = null
	update_appearance()
	return ..()

/obj/item/gun/blastcannon/update_icon_state()
	icon_state = "[bomb ? "loaded" : "empty"]_[base_icon_state]"
	return ..()

/obj/item/gun/blastcannon/attackby(obj/item/transfer_valve/bomb_to_attach, mob/user)
	if(!istype(bomb_to_attach))
		return ..()

	if(bomb)
		to_chat(user, "<span class='warning'>[bomb] is already attached to [src]!</span>")
		return
	if(!bomb_to_attach.ready())
		to_chat(user, "<span class='warning'>What good would an incomplete bomb do?</span>")
		return FALSE
	if(!user.transferItemToLoc(bomb_to_attach, src))
		to_chat(user, "<span class='warning'>[bomb_to_attach] seems to be stuck to your hand!</span>")
		return FALSE

	user.visible_message("<span class='warning'>[user] attaches [bomb_to_attach] to [src]!</span>")
	bomb = bomb_to_attach
	update_appearance()
	return TRUE

/obj/item/gun/blastcannon/afterattack(atom/target, mob/user, flag, params)
	if((!bomb && bombcheck) || !target || (get_dist(get_turf(target), get_turf(user)) <= 2))
		return ..()

	cached_target = WEAKREF(target)
	cached_modifiers = params
	if(bomb?.valve_open)
		user.visible_message(
			"<span class='danger'>[user] points [src] at [target]!</span>",
			"<span class='danger'>You point [src] at [target]!</span>"
		)
		return

	cached_firer = WEAKREF(user)
	if(!bomb)
		fire_debug(target, user, flag, params)
		return

	playsound(src, dry_fire_sound, 30, TRUE) // *click
	user.visible_message(
		"<span class='danger'>[user] opens [bomb] on [user.p_their()] [src] and points [p_them()] at [target]!</span>",
		"<span class='danger'>You open [bomb] on your [src] and point [p_them()] at [target]!</span>"
	)
	var/turf/current_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	message_admins("Blastcannon transfer valve opened by [ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(current_turf)] while aiming at [ADMIN_VERBOSEJMP(target_turf)] (target).")
	log_game("Blastcannon transfer valve opened by [key_name(user)] at [AREACOORD(current_turf)] while aiming at [AREACOORD(target_turf)] (target).")
	bomb.toggle_valve()
	return


/**
 * Channels an internal explosion into a blastwave projectile.
 *
 * Arguments:
 * - [blastwave_data][/list]: A list containing all of the data for the blastwave.
 */
/obj/item/gun/blastcannon/proc/channel_blastwave(atom/source, list/arguments)
	SIGNAL_HANDLER
	. = COMSIG_CANCEL_EXPLOSION

	var/heavy = arguments[EXARG_KEY_DEV_RANGE]
	var/medium = arguments[EXARG_KEY_HEAVY_RANGE]
	var/light = arguments[EXARG_KEY_LIGHT_RANGE]
	var/range = max(heavy, medium, light, 0)
	if(!range)
		visible_message("<span class='warning'>[src] lets out a little \"phut\".</span>")
		return

	if(!ismob(loc))
		INVOKE_ASYNC(src, .proc/fire_dropped, heavy, medium, light)
		return

	var/mob/holding = loc
	var/target = cached_target?.resolve()
	if(target && (holding.get_active_held_item() == src) && cached_firer && (holding == cached_firer.resolve()))
		INVOKE_ASYNC(src, .proc/fire_intentionally, target, holding, heavy, medium, light, cached_modifiers)
	else
		INVOKE_ASYNC(src, .proc/fire_accidentally, holding, heavy, medium, light)
	return

/**
 * Prepares and fires a blastwave.
 *
 * Arguments:
 * - [target][/atom]: The thing that the blastwave is being fired at.
 * - heavy: The devastation range of the blastwave.
 * - medium: The heavy impact range of the blastwave.
 * - light: The light impact range of the blastwave.
 * - modifiers: Modifiers as a string used while firing this.
 * - spread: How inaccurate the blastwave is.
 */
/obj/item/gun/blastcannon/proc/fire_blastwave(atom/target, heavy, medium, light, modifiers, spread = 0)
	var/turf/start_turf = get_turf(src)

	var/cap_multiplier = SSmapping.level_trait(start_turf.z, ZTRAIT_BOMBCAP_MULTIPLIER)
	if(isnull(cap_multiplier))
		cap_multiplier = 1
	var/capped_heavy = min(GLOB.MAX_EX_DEVESTATION_RANGE * cap_multiplier, heavy)
	var/capped_medium = min(GLOB.MAX_EX_HEAVY_RANGE * cap_multiplier, medium)
	SSexplosions.shake_the_room(start_turf, max(heavy, medium, light, 0), (capped_heavy * 15) + (capped_medium * 20), capped_heavy, capped_medium)

	var/obj/projectile/blastwave/blastwave = new(loc, heavy, medium, light)
	blastwave.preparePixelProjectile(target, start_turf, params2list(modifiers), spread)
	blastwave.fire()
	cached_firer = null
	cached_target = null
	cached_modifiers = null
	return


/**
 * Handles firing the blastcannon intentionally at a specific target.
 *
 * Arguments:
 * - [firer][/mob]: The mob who is firing this weapon.
 * - [target][/atom]: The target we are firing the
 * - heavy: The devastation range of the blastwave.
 * - medium: The heavy impact range of the blastwave.
 * - light: The light impact range of the blastwave.
 * - modifiers: The modifier string to use when preparing the blastwave.
 */
/obj/item/gun/blastcannon/proc/fire_intentionally(atom/target, mob/firer, heavy, medium, light, modifiers)
	firer.visible_message(
		"<span class='danger'>[firer] fires a blast wave at [target]!</span>",
		"<span class='danger'>You fire a blast wave at [target]!</span>"
	)
	var/turf/start_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	message_admins("Blast wave fired from [ADMIN_VERBOSEJMP(start_turf)] at [ADMIN_VERBOSEJMP(target_turf)] ([target]) by [ADMIN_LOOKUPFLW(firer)] with power [heavy]/[medium]/[light].")
	log_game("Blast wave fired from [AREACOORD(start_turf)] at [AREACOORD(target_turf)] ([target]) by [key_name(firer)] with power [heavy]/[medium]/[light].")
	fire_blastwave(target, heavy, medium, light, modifiers)
	return

/**
 * Handles firing the blastcannon if it was handed to someone else between opening the valve and the bomb exploding.
 *
 * Arguments:
 * - [holder][/mob]: The person who happened to be holding the cannon when it went off.
 * - heavy: The devastation range of the blastwave.
 * - medium: The heavy impact range of the blastwave.
 * - light: The light impact range of the blastwave.
 */
/obj/item/gun/blastcannon/proc/fire_accidentally(mob/holder, heavy, medium, light)
	var/turf/target
	var/holding
	if(holder.is_holding(src))
		target = get_edge_target_turf(holder, holder.dir)
		holding = TRUE
	else
		target = get_edge_target_turf(holder, dir)
		holding = FALSE

	var/mob/firer = cached_firer?.resolve()
	var/turf/start_turf = get_turf(src)
	holder.visible_message(
		"<span class='danger'>[src] suddenly goes off[holding ? " in [holder]'s hands" : null]!</span>",
		"<span class='danger'>[src] suddenly goes off[holding ? " in your hands" : null]!</span>"
	)
	message_admins("Blast wave primed by [ADMIN_LOOKUPFLW(firer)] fired from [ADMIN_VERBOSEJMP(start_turf)] roughly towards [ADMIN_VERBOSEJMP(target)] while being held by [ADMIN_LOOKUPFLW(holder)] with power [heavy]/[medium]/[light].")
	log_game("Blast wave primed by [key_name(firer)] fired from [AREACOORD(start_turf)] roughly towards [AREACOORD(target)] while being held by [key_name(holder)] with power [heavy]/[medium]/[light].")
	return fire_blastwave(target, heavy, medium, light, null, (90 * (rand() - 0.5))) // +- anywhere between 0 and 45 degrees

/**
 * Handles firing the blastcannon if it was dropped on the ground or shoved into a backpack.
 *
 * Arguments:
 * - heavy: The devastation range of the blastwave.
 * - medium: The heavy impact range of the blastwave.
 * - light: The light impact range of the blastwave.
 */
/obj/item/gun/blastcannon/proc/fire_dropped(heavy, medium, light)
	src.visible_message("<span class='danger'>[src] suddenly goes off!")
	var/turf/target = get_edge_target_turf(src, dir)
	var/mob/firer = cached_firer.resolve()
	var/turf/start_turf = get_turf(src)
	message_admins("Blast wave primed by [ADMIN_LOOKUPFLW(firer)] fired from [ADMIN_VERBOSEJMP(start_turf)] roughly towards [ADMIN_VERBOSEJMP(target)] at [ADMIN_VERBOSEJMP(loc)] ([loc]) with power [heavy]/[medium]/[light].")
	log_game("Blast wave primed by [key_name(firer)] fired from [AREACOORD(start_turf)] roughly towards [AREACOORD(target)] at [AREACOORD(loc)] ([loc]) with power [heavy]/[medium]/[light].")
	return fire_blastwave(target, heavy, medium, light, null, 360 * rand())

/**
 * Handles firing the blastcannon with debug power.
 *
 * Arguments:
 * - [target][/atom]: The thing the blastcannon is being fired at.
 * - [user][/mob]: The person firing the blastcannon.
 * - modifiers: A string containing click data.
 */
/obj/item/gun/blastcannon/proc/fire_debug(atom/target, mob/user, modifiers)
	fire_intentionally(target, user, debug_power * 0.25, debug_power * 0.5, debug_power, modifiers)
	return


/// The projectile used by the blastcannon
/obj/projectile/blastwave
	name = "blast wave"
	icon_state = "blastwave"
	damage = 0
	nodamage = FALSE
	movement_type = FLYING
	projectile_phasing = ALL // just blows up the turfs lmao
	/// The maximum distance this will inflict [EXPLODE_DEVASTATE]
	var/heavy_ex_range = 0
	/// The maximum distance this will inflict [EXPLODE_HEAVY]
	var/medium_ex_range = 0
	/// The maximum distance this will inflict [EXPLODE_LIGHT]
	var/light_ex_range = 0

/obj/projectile/blastwave/Initialize(mapload, heavy_ex_range, medium_ex_range, light_ex_range)
	range = max(heavy_ex_range, medium_ex_range, light_range, 0)
	src.heavy_ex_range = heavy_ex_range
	src.medium_ex_range = medium_ex_range
	src.light_ex_range = light_ex_range
	return ..()

/obj/projectile/blastwave/Range()
	. = ..()
	if(QDELETED(src))
		return

	heavy_ex_range = max(heavy_ex_range - 1, 0)
	medium_ex_range = max(medium_ex_range - 1, 0)
	light_ex_range = max(light_ex_range - 1, 0)

	if(heavy_ex_range)
		SSexplosions.highturf += loc
	else if(medium_ex_range)
		SSexplosions.medturf += loc
	else if(light_range)
		SSexplosions.lowturf += loc
	else
		qdel(src)
		return

/obj/projectile/blastwave/ex_act()
	return FALSE
