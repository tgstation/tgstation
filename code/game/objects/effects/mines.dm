/obj/effect/mine
	name = "dummy mine"
	desc = "Better stay away from that thing."
	density = FALSE
	anchored = TRUE
	icon = 'icons/obj/weapons/items_and_weapons.dmi'
	icon_state = "uglymine"
	base_icon_state = "uglymine"
	/// We manually check to see if we've been triggered in case multiple atoms cross us in the time between the mine being triggered and it actually deleting, to avoid a race condition with multiple detonations
	var/triggered = FALSE
	/// Can be set to FALSE if we want a short 'coming online' delay, then set to TRUE. Can still be set off by damage
	var/armed = TRUE
	/// If set, we default armed to FALSE and set it to TRUE after this long from initializing
	var/arm_delay

	/// Who's got their foot on the mine's pressure plate
	/// Stepping on the mine will set this to the first mob who stepped over it
	/// The mine will not detonate via movement unless the first mob steps off of it
	var/datum/weakref/foot_on_mine

/obj/effect/mine/Initialize(mapload)
	. = ..()
	if(arm_delay)
		armed = FALSE
		update_appearance(UPDATE_ICON_STATE)
		addtimer(CALLBACK(src, PROC_REF(now_armed)), arm_delay)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/mine/examine(mob/user)
	. = ..()
	if(!armed)
		. += span_info("It appears to be inactive...")

	var/atom/movable/unlucky_sod = foot_on_mine?.resolve()
	if(user == unlucky_sod)
		. += span_bolddanger("The pressure plate is depressed. Any movement you make will set it off now.")
	else if(!isnull(unlucky_sod))
		. += span_danger("The pressure plate is depressed by [unlucky_sod]. Any move they make'll set it off now.")

/obj/effect/mine/update_icon_state()
	. = ..()
	if(armed)
		icon_state = base_icon_state
	else
		icon_state = "[base_icon_state]-inactive"

/// The effect of the mine
/obj/effect/mine/proc/mineEffect(mob/victim)
	return

/// If the landmine was previously inactive, this beeps and displays a message marking it active
/obj/effect/mine/proc/now_armed()
	armed = TRUE
	update_appearance(UPDATE_ICON_STATE)
	playsound(src, 'sound/machines/nuke/angry_beep.ogg', 40, FALSE, -2)
	visible_message(span_danger("\The [src] beeps softly, indicating it is now active."), vision_distance = COMBAT_MESSAGE_RANGE)

/// Can this mine trigger on the passed movable?
/obj/effect/mine/proc/can_trigger(atom/movable/on_who)
	if(triggered || !isturf(loc) || iseffect(on_who) || !armed)
		return FALSE
	return TRUE

/obj/effect/mine/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER

	if(!can_trigger(arrived))
		return
	// Flying = can't step on a mine
	if(arrived.movement_type & FLYING)
		return
	// Someone already on it
	if(foot_on_mine?.resolve())
		return

	foot_on_mine = WEAKREF(arrived)
	visible_message(span_danger("[icon2html(src, viewers(src))] *click*"))
	playsound(src, 'sound/machines/click.ogg', 60, TRUE)

/obj/effect/mine/proc/on_exited(datum/source, atom/movable/gone)
	SIGNAL_HANDLER

	if(!can_trigger(gone))
		return
	// Check that the guy who's on it is stepping off
	if(foot_on_mine && !IS_WEAKREF_OF(gone, foot_on_mine))
		return

	triggermine(gone)
	foot_on_mine = null

/obj/effect/mine/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	triggermine()

/// When something sets off a mine
/obj/effect/mine/proc/triggermine(atom/movable/triggerer)
	if(triggered) //too busy detonating to detonate again
		return
	if(triggerer)
		visible_message(span_danger("[triggerer] sets off [icon2html(src, viewers(src))] [src]!"))
	else
		visible_message(span_danger("[icon2html(src, viewers(src))] [src] detonates!"))

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	if(ismob(triggerer))
		mineEffect(triggerer)
	triggered = TRUE
	SEND_SIGNAL(src, COMSIG_MINE_TRIGGERED, triggerer)
	qdel(src)

/obj/effect/mine/explosive
	name = "explosive mine"
	/// The devastation range of the resulting explosion.
	var/range_devastation = 0
	/// The heavy impact range of the resulting explosion.
	var/range_heavy = 1
	/// The light impact range of the resulting explosion.
	var/range_light = 2
	/// The flame range of the resulting explosion.
	var/range_flame = 0
	/// The flash range of the resulting explosion.
	var/range_flash = 3

/obj/effect/mine/explosive/mineEffect(mob/victim)
	explosion(src, range_devastation, range_heavy, range_light, range_flame, range_flash)

/obj/effect/mine/stun
	name = "stun mine"
	var/stun_time = 80

/obj/effect/mine/stun/mineEffect(mob/living/victim)
	if(isliving(victim) && Adjacent(victim))
		victim.Paralyze(stun_time)

/obj/effect/mine/kickmine
	name = "kick mine"

/obj/effect/mine/kickmine/mineEffect(mob/victim)
	if(isliving(victim) && victim.client && Adjacent(victim))
		to_chat(victim, span_userdanger("You have been kicked FOR NO REISIN!"))
		qdel(victim.client)


/obj/effect/mine/gas
	name = "oxygen mine"
	var/gas_amount = 360
	var/gas_type = "o2"

/obj/effect/mine/gas/mineEffect(mob/victim)
	atmos_spawn_air("[gas_type]=[gas_amount]")


/obj/effect/mine/gas/plasma
	name = "plasma mine"
	gas_type = "plasma"


/obj/effect/mine/gas/n2o
	name = "\improper N2O mine"
	gas_type = "n2o"


/obj/effect/mine/gas/water_vapor
	name = "chilled vapor mine"
	gas_amount = 500
	gas_type = "water_vapor"

/obj/effect/mine/sound
	name = "honkblaster 1000"
	var/sound = 'sound/items/bikehorn.ogg'

/obj/effect/mine/sound/mineEffect(mob/victim)
	playsound(loc, sound, 100, TRUE)


/obj/effect/mine/sound/bwoink
	name = "bwoink mine"
	sound = 'sound/effects/adminhelp.ogg'

/// These mines spawn pellet_clouds around them when triggered
/obj/effect/mine/shrapnel
	name = "shrapnel mine"
	/// The type of projectiles we're shooting out of this
	var/shrapnel_type = /obj/projectile/bullet/shrapnel
	/// Broadly, how many pellets we're spawning, the total is n! - (n-1)! pellets, so don't set it too high. For reference, 15 is probably pushing it at MAX
	var/shrapnel_magnitude = 3
	/// If TRUE, we spawn extra pellets to eviscerate the person who stepped on it, otherwise it just spawns a ring of pellets around the tile we're on (making setting it off an offensive move)
	var/shred_triggerer = FALSE

/obj/effect/mine/shrapnel/mineEffect(mob/victim)
	return

/obj/effect/mine/shrapnel/triggermine(atom/movable/AM)
	AddComponent(/datum/component/pellet_cloud, projectile_type=shrapnel_type, magnitude=shrapnel_magnitude)
	return ..()

/obj/effect/mine/shrapnel/sting
	name = "stinger mine"
	shrapnel_type = /obj/projectile/bullet/pellet/stingball

/obj/effect/mine/shrapnel/capspawn
	name = "\improper AP mine"
	desc = "A defensive landmine filled with 'AP shrapnel', good for defending cramped spaces without breaching hulls. The AP stands for 'Asset Protection', though it's still plenty nasty against any fool who sets it off."
	shrapnel_type = /obj/projectile/bullet/pellet/capmine
	shrapnel_magnitude = 4
	shred_triggerer = TRUE
	arm_delay = 3 SECONDS
	light_range = 1.6
	light_power = 2
	light_color = COLOR_VIVID_RED

/obj/effect/mine/shrapnel/capspawn/now_armed()
	. = ..()
	set_light_on(TRUE)

/obj/item/minespawner
	name = "landmine deployment device"
	desc = "When activated, will deploy an Asset Protection landmine after 3 seconds passes, perfect for high ranking NT officers looking to cover their assets from afar."
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon"

	var/mine_type = /obj/effect/mine/shrapnel/capspawn
	var/active = FALSE

/obj/item/minespawner/attack_self(mob/user)
	. = ..()
	if(active)
		return


	playsound(src, 'sound/weapons/armbomb.ogg', 70, TRUE)
	to_chat(user, span_warning("You arm \the [src], causing it to shake! It will deploy in 3 seconds."))
	active = TRUE
	addtimer(CALLBACK(src, PROC_REF(deploy_mine)), 3 SECONDS)

/// Deploys the mine and deletes itself
/obj/item/minespawner/proc/deploy_mine()
	do_alert_animation()
	playsound(loc, 'sound/machines/chime.ogg', 30, FALSE, -3)
	var/obj/effect/mine/new_mine = new mine_type(get_turf(src))
	visible_message(span_danger("\The [src] releases a puff of smoke, revealing \a [new_mine]!"))
	var/obj/effect/particle_effect/fluid/smoke/poof = new (get_turf(src))
	poof.lifetime = 3
	qdel(src)
