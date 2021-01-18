/**
 * A gun that consumes a TTV to shoot an projectile with equivalent power.
 *
 * It's basically an immovable rod launcher.
 */
/obj/item/gun/blastcannon
	name = "pipe gun"
	desc = "A pipe welded onto a gun stock, with a mechanical trigger. The pipe has an opening near the top, and there seems to be a spring loaded wheel in the hole. Small enough to stow in a bag."
	icon_state = "empty_blastcannon"
	inhand_icon_state = "blastcannon_empty"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	fire_sound = 'sound/weapons/blastcannon.ogg'
	item_flags = NONE
	clumsy_check = FALSE
	randomspread = FALSE
	/// The icon state used when this is loaded with a bomb.
	var/icon_state_loaded = "loaded_blastcannon"

	/// The TTV this contains that will be used to create the projectile
	var/obj/item/transfer_valve/bomb
	/// Additional volume added to the gasmixture used to calculate the bombs power.
	var/reaction_volume_mod = 0
	/// Whether the gases are reacted once before calculating the range
	var/prereaction = TRUE
	/// How many times gases react() before calculation. Very finnicky value, do not mess with without good reason.
	var/reaction_cycles = 3
	/// The maximum power the blastcannon is capable of reaching
	var/max_power = INFINITY

	// For debugging/badminry
	/// Whether you can fire this without a bomb.
	var/bombcheck = TRUE
	/// The range this defaults to without a bomb for debugging and badminry
	var/debug_power = 0


/obj/item/gun/blastcannon/debug
	debug_power = 80
	bombcheck = FALSE

/obj/item/gun/blastcannon/Initialize()
	. = ..()
	if(!pin)
		pin = new

/obj/item/gun/blastcannon/Destroy()
	if(bomb)
		QDEL_NULL(bomb)
	return ..()

/obj/item/gun/blastcannon/attack_self(mob/user)
	if(bomb)
		bomb.forceMove(user.loc)
		user.put_in_hands(bomb)
		user.visible_message("<span class='warning'>[user] detaches [bomb] from [src].</span>")
		bomb = null
		name = initial(name)
		desc = initial(desc)
	update_icon()
	return ..()

/obj/item/gun/blastcannon/update_icon_state()
	. = ..()
	icon_state = bomb ? icon_state_loaded : initial(icon_state)

/obj/item/gun/blastcannon/attackby(obj/item/transfer_valve/bomb_to_attach, mob/user)
	if(!istype(bomb_to_attach))
		return ..()

	if(!bomb_to_attach.tank_one || !bomb_to_attach.tank_two)
		to_chat(user, "<span class='warning'>What good would an incomplete bomb do?</span>")
		return FALSE
	if(!user.transferItemToLoc(bomb_to_attach, src))
		to_chat(user, "<span class='warning'>[bomb_to_attach] seems to be stuck to your hand!</span>")
		return FALSE

	user.visible_message("<span class='warning'>[user] attaches [bomb_to_attach] to [src]!</span>")
	bomb = bomb_to_attach
	name = "blast cannon"
	desc = "A makeshift device used to concentrate a bomb's blast energy to a narrow wave."
	update_icon()
	return TRUE

/// Handles the bomb power calculations
/obj/item/gun/blastcannon/proc/calculate_bomb()
	if(!istype(bomb) || !istype(bomb.tank_one) || !istype(bomb.tank_two))
		return 0

	var/datum/gas_mixture/temp = new(max(reaction_volume_mod, 0))
	bomb.merge_gases(temp)

	if(prereaction)
		temp.react(src)
		var/prereaction_pressure = temp.return_pressure()
		if(prereaction_pressure < TANK_FRAGMENT_PRESSURE)
			return 0
	for(var/i in 1 to reaction_cycles)
		temp.react(src)

	var/pressure = temp.return_pressure()
	qdel(temp)
	if(pressure < TANK_FRAGMENT_PRESSURE)
		return 0
	return ((pressure - TANK_FRAGMENT_PRESSURE) / TANK_FRAGMENT_SCALE)


/obj/item/gun/blastcannon/afterattack(atom/target, mob/user, flag, params)
	if((!bomb && bombcheck) || (!target) || (get_dist(get_turf(target), get_turf(user)) <= 2))
		return ..()

	var/power =  bomb ? calculate_bomb() : debug_power
	power = min(power, max_power)
	QDEL_NULL(bomb)
	update_icon()

	var/heavy = power * 0.25
	var/medium = power * 0.5
	var/light = power
	user.visible_message("<span class='danger'>[user] opens [bomb] on [user.p_their()] [name] and fires a blast wave at [target]!</span>","<span class='danger'>You open [bomb] on your [name] and fire a blast wave at [target]!</span>")
	playsound(user, "explosion", 100, TRUE)
	var/turf/starting = get_turf(user)
	var/turf/targturf = get_turf(target)
	message_admins("Blast wave fired from [ADMIN_VERBOSEJMP(starting)] at [ADMIN_VERBOSEJMP(targturf)] ([target.name]) by [ADMIN_LOOKUPFLW(user)] with power [heavy]/[medium]/[light].")
	log_game("Blast wave fired from [AREACOORD(starting)] at [AREACOORD(targturf)] ([target.name]) by [key_name(user)] with power [heavy]/[medium]/[light].")
	var/obj/projectile/blastwave/BW = new(loc, heavy, medium, light)
	BW.preparePixelProjectile(target, get_turf(src), params, 0)
	BW.fire()
	name = initial(name)
	desc = initial(desc)

/// The projectile used by the blastcannon
/obj/projectile/blastwave
	name = "blast wave"
	icon_state = "blastwave"
	damage = 0
	nodamage = FALSE
	movement_type = FLYING
	projectile_phasing = ALL		// just blows up the turfs lmao
	/// The maximum distance this will inflict [EXPLODE_DEVASTATE]
	var/heavyr = 0
	/// The maximum distance this will inflict [EXPLODE_HEAVY]
	var/mediumr = 0
	/// The maximum distance this will inflict [EXPLODE_LIGHT]
	var/lightr = 0

/obj/projectile/blastwave/Initialize(mapload, _heavy, _medium, _light)
	range = max(_heavy, _medium, _light, 0)
	heavyr = _heavy
	mediumr = _medium
	lightr = _light
	return ..()

/obj/projectile/blastwave/Range()
	. = ..()
	if(QDELETED(src))
		return

	heavyr = max(heavyr - 1, 0)
	mediumr = max(mediumr - 1, 0)
	lightr = max(lightr - 1, 0)

	if(heavyr)
		SSexplosions.highturf += loc
	else if(mediumr)
		SSexplosions.medturf += loc
	else if(lightr)
		SSexplosions.lowturf += loc
	else
		qdel(src)
		return

/obj/projectile/blastwave/ex_act()
	return
