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
	var/recharge_sound = 'sound/weapons/kenetic_reload.ogg'
	/// An ID for our recharging timer.
	var/recharge_timerid
	/// Do we recharge slower with more of our type?
	var/unique_frequency = FALSE

/obj/item/gun/energy/recharge/Initialize(mapload)
	. = ..()
	if(!holds_charge)
		empty()

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

/obj/item/gun/energy/recharge/emp_act(severity)
	return

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
	else
		icon_state = base_icon_state

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

//Inferno and Cryo Pistols

/obj/item/gun/energy/recharge/thermal //the common parent of these guns, it just shoots hard bullets, somoene might like that?
	name = "nanite pistol"
	desc = "A modified handcannon with a metamorphic reserve of decommissioned weaponized nanites. Spit globs of angry robots into the bad guys. \
		Automatically resets the charge after a time. Recharges instantly if you spin the gun, but you can only do it once per minute. Hope you have a holster!"
	icon_state = "infernopistol"
	base_icon_state = "infernopistol"
	no_charge_state = "infernopistol_empty"
	inhand_icon_state = "infernopistol"
	cell_type = /obj/item/stock_parts/cell/emproof/thermal
	ammo_type = list(/obj/item/ammo_casing/energy/nanite)
	holds_charge = TRUE
	obj_flags = UNIQUE_RENAME
	can_bayonet = TRUE
	knife_x_offset = 19
	knife_y_offset = 13
	w_class = WEIGHT_CLASS_NORMAL
	dual_wield_spread = 0 //as intended by the coders
	recharge_time = 1.5 MINUTES //you really should spin the gun
	flip_cooldown_time = 1 MINUTES //SPEEN

/obj/item/gun/energy/recharge/thermal/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 15, \
		overlay_y = 9)

/obj/item/gun/energy/recharge/thermal/gun_spin_performed(mob/user)
	. = ..()
	reload()
	deltimer(recharge_timerid)

/obj/item/gun/energy/recharge/thermal/inferno //the magma gun
	name = "inferno pistol"
	desc = "A modified handcannon with a metamorphic reserve of decommissioned weaponized nanites. Spit globs of molten angry robots into the bad guys. \
		While it doesn't manipulate temperature in and of itself, it does cause an violent eruption in anyone who is severely cold. \
		Automatically resets the charge after a time. Recharges instantly if you spin the gun, but you can only do it once per minute. Hope you have a holster!"
	ammo_type = list(/obj/item/ammo_casing/energy/nanite/inferno)

/obj/item/gun/energy/recharge/thermal/cryo //the ice gun
	name = "cryo pistol"
	desc = "A modified handcannon with a metamorphic reserve of decommissioned weaponized nanites. Spit shards of frozen angry robots into the bad guys. \
		While it doesn't manipulate temperature in and of itself, it does cause an internal explosion in anyone who is severely hot. \
		Automatically resets the charge after a time. Recharges instantly if you spin the gun, but you can only do it once per minute. Hope you have a holster!"
	icon_state = "cryopistol"
	base_icon_state = "cryopistol"
	no_charge_state = "cryopistol_empty"
	inhand_icon_state = "cryopistol"
	ammo_type = list(/obj/item/ammo_casing/energy/nanite/cryo)
