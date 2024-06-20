/obj/item/gun/energy/e_gun
	name = "energy gun"
	desc = "A basic hybrid energy gun with two settings: disable and kill."
	icon_state = "energy"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = null //so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	modifystate = TRUE
	ammo_x_offset = 3
	dual_wield_spread = 60

/obj/item/gun/energy/e_gun/Initialize(mapload)
	. = ..()
	// Only actual eguns can be converted
	if(type != /obj/item/gun/energy/e_gun)
		return
	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/advancedegun, /datum/crafting_recipe/tempgun, /datum/crafting_recipe/beam_rifle)

	AddComponent(
		/datum/component/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/gun/energy/e_gun/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 15, \
		overlay_y = 10)

/obj/item/gun/energy/e_gun/mini
	name = "miniature energy gun"
	desc = "A small, pistol-sized energy gun with a built-in flashlight. It has two settings: disable and kill."
	icon_state = "mini"
	inhand_icon_state = "gun"
	w_class = WEIGHT_CLASS_SMALL
	cell_type = /obj/item/stock_parts/power_store/cell/mini_egun
	ammo_x_offset = 2
	charge_sections = 3
	single_shot_type_overlay = FALSE

/obj/item/gun/energy/e_gun/mini/add_seclight_point()
	// The mini energy gun's light comes attached but is unremovable.
	AddComponent(/datum/component/seclite_attachable, \
		starting_light = new /obj/item/flashlight/seclite(src), \
		is_light_removable = FALSE, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 19, \
		overlay_y = 13)

/obj/item/gun/energy/e_gun/stun
	name = "tactical energy gun"
	desc = "Military issue energy gun, is able to fire stun rounds."
	icon_state = "energytac"
	ammo_x_offset = 2
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/spec, /obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/e_gun/old
	name = "prototype energy gun"
	desc = "NT-P:01 Prototype Energy Gun. Early stage development of a unique laser rifle that has multifaceted energy lens allowing the gun to alter the form of projectile it fires on command."
	icon_state = "protolaser"
	ammo_x_offset = 2
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/electrode/old)

/obj/item/gun/energy/e_gun/mini/practice_phaser
	name = "practice phaser"
	desc = "A modified version of the basic phaser gun, this one fires less concentrated energy bolts designed for target practice."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser/practice)
	icon_state = "decloner"
	//You have no icons for energy types, you're a decloner
	modifystate = FALSE
	gun_flags = NOT_A_REAL_GUN

/obj/item/gun/energy/e_gun/hos
	name = "\improper X-01 MultiPhase Energy Gun"
	desc = "This is an expensive, modern recreation of an antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	cell_type = /obj/item/stock_parts/power_store/cell/hos_gun
	icon_state = "hoslaser"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/hos, /obj/item/ammo_casing/energy/laser/hos, /obj/item/ammo_casing/energy/ion/hos)
	ammo_x_offset = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1

/obj/item/gun/energy/e_gun/dragnet
	name = "\improper DRAGnet"
	desc = "The \"Dynamic Rapid-Apprehension of the Guilty\" net is a revolution in law enforcement technology. Can by synced with a DRAGnet beacon to set a teleport destination for snare rounds."
	icon_state = "dragnet"
	inhand_icon_state = "dragnet"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/net, /obj/item/ammo_casing/energy/trap)
	modifystate = FALSE
	w_class = WEIGHT_CLASS_NORMAL
	ammo_x_offset = 1
	///A dragnet beacon set to be the teleport destination for snare teleport rounds.
	var/obj/item/dragnet_beacon/linked_beacon

/obj/item/gun/energy/e_gun/dragnet/add_seclight_point()
	return

/obj/item/gun/energy/e_gun/dragnet/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/dragnet_beacon))
		link_beacon(user, tool)

///Sets the linked_beacon var on the dragnet, which becomes the snare round's teleport destination.
/obj/item/gun/energy/e_gun/dragnet/proc/link_beacon(mob/living/user, obj/item/dragnet_beacon/our_beacon)
	if(linked_beacon)
		if(our_beacon == linked_beacon)
			balloon_alert(user, "already synced!")
			return
		else
			UnregisterSignal(linked_beacon, COMSIG_QDELETING) //You're getting overridden dude.

	linked_beacon = our_beacon
	balloon_alert(user, "beacon synced")
	RegisterSignal(our_beacon, COMSIG_QDELETING, PROC_REF(handle_beacon_disable))

///Handles clearing the linked_beacon reference in the event that it is deleted.
/obj/item/gun/energy/e_gun/dragnet/proc/handle_beacon_disable(datum/source)
	SIGNAL_HANDLER
	visible_message(span_warning("A light on the [src] flashes, indicating that it is no longer linked with a DRAGnet beacon!"))
	linked_beacon = null

/obj/item/gun/energy/e_gun/dragnet/snare
	name = "Energy Snare Launcher"
	desc = "Fires an energy snare that slows the target down."
	ammo_type = list(/obj/item/ammo_casing/energy/trap)

/obj/item/gun/energy/e_gun/turret
	name = "hybrid turret gun"
	desc = "A heavy hybrid energy cannon with two settings: Stun and kill."
	icon_state = "turretlaser"
	inhand_icon_state = "turretlaser"
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	weapon_weight = WEAPON_HEAVY
	trigger_guard = TRIGGER_GUARD_NONE
	ammo_x_offset = 2

/obj/item/gun/energy/e_gun/turret/add_seclight_point()
	return

/obj/item/gun/energy/e_gun/nuclear
	name = "advanced energy gun"
	desc = "An energy gun with an experimental miniaturized nuclear reactor that automatically charges the internal power cell."
	icon_state = "nucgun"
	inhand_icon_state = "nucgun"
	charge_delay = 10
	can_charge = FALSE
	ammo_x_offset = 1
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/disabler)
	selfcharge = 1
	var/reactor_overloaded
	var/fail_tick = 0
	var/fail_chance = 0

/obj/item/gun/energy/e_gun/nuclear/process(seconds_per_tick)
	if(fail_tick > 0)
		fail_tick -= seconds_per_tick * 0.5
	..()

/obj/item/gun/energy/e_gun/nuclear/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	failcheck()
	update_appearance()
	..()

/obj/item/gun/energy/e_gun/nuclear/proc/failcheck()
	if(prob(fail_chance) && isliving(loc))
		var/mob/living/M = loc
		switch(fail_tick)
			if(0 to 200)
				fail_tick += (2*(fail_chance))
				M.adjustFireLoss(3)
				to_chat(M, span_userdanger("Your [name] feels warmer."))
			if(201 to INFINITY)
				SSobj.processing.Remove(src)
				M.adjustFireLoss(10)
				reactor_overloaded = TRUE
				to_chat(M, span_userdanger("Your [name]'s reactor overloads!"))

/obj/item/gun/energy/e_gun/nuclear/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	fail_chance = min(fail_chance + round(15/severity), 100)

/obj/item/gun/energy/e_gun/nuclear/update_overlays()
	. = ..()
	if(reactor_overloaded)
		. += "[icon_state]_fail_3"
		return

	switch(fail_tick)
		if(0)
			. += "[icon_state]_fail_0"
		if(1 to 150)
			. += "[icon_state]_fail_1"
		if(151 to INFINITY)
			. += "[icon_state]_fail_2"

/obj/item/gun/energy/e_gun/lethal
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/disabler)
