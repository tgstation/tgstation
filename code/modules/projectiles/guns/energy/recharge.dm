//Recharge subtype - used by stuff like protokinetic accelerators and ebows, one shot at a time, recharges.
/obj/item/gun/energy/recharge
	icon_state = "kineticgun"
	base_icon_state = "kineticgun"
	desc = "A self recharging gun. Holds one shot at a time."
	automatic_charge_overlays = FALSE
	cell_type = /obj/item/stock_parts/cell/emproof
	/// If set to something, instead of an overlay, sets the icon_state directly.
	var/no_charge_state
	/// Does it hold charge when not put away?
	var/holds_charge = FALSE
	/// How much time we need to recharge
	var/recharge_time = 1.6 SECONDS
	/// Sound we use when recharged
	var/recharge_sound = 'sound/weapons/kinetic_reload.ogg'
	/// An ID for our recharging timer.
	var/recharge_timerid
	/// Do we recharge slower with more of our type?
	var/unique_frequency = FALSE

/obj/item/gun/energy/recharge/apply_fantasy_bonuses(bonus)
	. = ..()
	recharge_time = modify_fantasy_variable("recharge_time", recharge_time, -bonus, minimum = 0.2 SECONDS)

/obj/item/gun/energy/recharge/remove_fantasy_bonuses(bonus)
	recharge_time = reset_fantasy_variable("recharge_time", recharge_time)
	return ..()

/obj/item/gun/energy/recharge/Initialize(mapload)
	. = ..()
	if(!holds_charge)
		empty()
	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/item/gun/energy/recharge/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	. = ..()
	attempt_reload()

/obj/item/gun/energy/recharge/equipped(mob/user)
	. = ..()
	if(!can_shoot())
		attempt_reload()

/obj/item/gun/energy/recharge/dropped()
	. = ..()
	if(!QDELING(src) && !holds_charge)
		// Put it on a delay because moving item from slot to hand
		// calls dropped().
		addtimer(CALLBACK(src, PROC_REF(empty_if_not_held)), 0.1 SECONDS)

/obj/item/gun/energy/recharge/handle_chamber()
	. = ..()
	attempt_reload()

/obj/item/gun/energy/recharge/proc/empty_if_not_held()
	if(!ismob(loc))
		empty()
		deltimer(recharge_timerid)

/obj/item/gun/energy/recharge/proc/empty()
	if(cell)
		cell.use(cell.charge)
	update_appearance()

/obj/item/gun/energy/recharge/proc/attempt_reload(set_recharge_time)
	if(!cell)
		return
	if(cell.charge == cell.maxcharge)
		return
	if(!set_recharge_time)
		set_recharge_time = recharge_time
	var/carried = 0
	if(!unique_frequency)
		for(var/obj/item/gun/energy/recharge/recharging_gun in loc.get_all_contents())
			if(recharging_gun.type != type || recharging_gun.unique_frequency)
				continue
			carried++
	carried = max(carried, 1)
	deltimer(recharge_timerid)
	recharge_timerid = addtimer(CALLBACK(src, PROC_REF(reload)), set_recharge_time * carried, TIMER_STOPPABLE)

/obj/item/gun/energy/recharge/proc/reload()
	cell.give(cell.maxcharge)
	if(!suppressed && recharge_sound)
		playsound(src.loc, recharge_sound, 60, TRUE)
	else
		to_chat(loc, span_warning("[src] silently charges up."))
	update_appearance()

/obj/item/gun/energy/recharge/update_overlays()
	. = ..()
	if(!no_charge_state && !can_shoot())
		. += "[base_icon_state]_empty"

/obj/item/gun/energy/recharge/update_icon_state()
	. = ..()
	if(no_charge_state && !can_shoot())
		icon_state = no_charge_state

/obj/item/gun/energy/recharge/ebow
	name = "mini energy crossbow"
	desc = "A weapon favored by syndicate stealth specialists."
	icon_state = "crossbow"
	base_icon_state = "crossbow"
	inhand_icon_state = "crossbow"
	no_charge_state = "crossbow_empty"
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT)
	suppressed = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)
	recharge_time = 2 SECONDS
	holds_charge = TRUE
	unique_frequency = TRUE
	can_bayonet = TRUE
	knife_x_offset = 20
	knife_y_offset = 12

/obj/item/gun/energy/recharge/ebow/halloween
	name = "candy corn crossbow"
	desc = "A weapon favored by Syndicate trick-or-treaters."
	icon_state = "crossbow_halloween"
	base_icon_state = "crossbow_halloween"
	no_charge_state = "crossbow_halloween_empty"
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/halloween)

/obj/item/gun/energy/recharge/ebow/large
	name = "energy crossbow"
	desc = "A reverse engineered weapon using syndicate technology."
	icon_state = "crossbowlarge"
	base_icon_state = "crossbowlarge"
	no_charge_state = "crossbowlarge_empty"
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*2)
	suppressed = null
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/large)

/// A silly gun that does literally zero damage, but disrupts electrical sources of light, like flashlights.
/obj/item/gun/energy/recharge/fisher
	name = "\improper SC/FISHER disruptor"
	desc = "A self-recharging, permanently suppressed, and very haphazardly modified accelerator handgun that does literally nothing to anything except light fixtures and cameras. \
	Can fire twice before requiring a recharge, with bolts passing through machinery, but demands precision."
	icon_state = "fisher"
	base_icon_state = "fisher"
	dry_fire_sound_volume = 10
	w_class = WEIGHT_CLASS_SMALL
	holds_charge = TRUE
	suppressed = TRUE
	recharge_time = 1.2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/fisher)

/obj/item/gun/energy/recharge/fisher/examine_more(mob/user)
	. = ..()
	. += span_notice("The SC/FISHER is an illegally-modified kinetic accelerator cut down and refit into a disassembled miniature energy gun chassis, \
	with its pressure chamber attenuated to launch kinetic bolts that <b>temporarily disrupt flashlights, cameras, and certain other electronics</b>. \
	This effect also works on <b>cyborg headlamps<b>, and works longer in melee.<br><br>\
	While some would argue that this is a really terrible design choice, others argue that it is very funny to be able to shoot at light sources.<br>\
	Caveat emptor.")

/obj/item/gun/energy/recharge/fisher/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()
	if(.)
		return
	var/obj/projectile/energy/fisher/melee/simulated_hit = new
	simulated_hit.firer = user
	simulated_hit.on_hit(target_mob)

/obj/item/gun/energy/recharge/fisher/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	// ...you reeeeeally just shoot them, but in case you can't/won't
	. = ..()
	var/obj/projectile/energy/fisher/melee/simulated_hit = new
	simulated_hit.firer = throwingdatum.get_thrower()
	simulated_hit.on_hit(hit_atom)
