//DO NOT ADD MECHA PARTS TO THE GAME WITH THE DEFAULT "SPRITE ME" SPRITE!
//I'm annoyed I even have to tell you this! SPRITE FIRST, then commit.

/obj/item/mecha_parts/mecha_equipment
	name = "mecha equipment"
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_equip"
	force = 5
	max_integrity = 300
	var/equipment_slot = MECHA_WEAPON
	var/equip_cooldown = 0
	var/equip_ready = TRUE //whether the equipment is ready for use. (or deactivated/activated for static stuff)
	var/energy_drain = 0
	var/obj/vehicle/sealed/mecha/chassis = null
	///Bitflag. Determines the range of the equipment.
	var/range = MECHA_MELEE
	/// Bitflag. Used by exosuit fabricator to assign sub-categories based on which exosuits can equip this.
	var/mech_flags = NONE
	var/salvageable = 1
	var/detachable = TRUE // Set to FALSE for built-in equipment that cannot be removed
	var/selectable = 1 // Set to 0 for passive equipment such as mining scanner or armor plates
	var/harmful = FALSE //Controls if equipment can be used to attack by a pacifist.
	var/destroy_sound = 'sound/mecha/critdestr.ogg'

/obj/item/mecha_parts/mecha_equipment/Destroy()
	if(chassis)
		detach(get_turf(src))
		log_message("[src] is destroyed.", LOG_MECHA)
		if(LAZYLEN(chassis.occupants))
			to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_danger("[src] is destroyed!")]")
			playsound(chassis, destroy_sound, 50)
		chassis = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/try_attach_part(mob/user, obj/vehicle/sealed/mecha/M, rightclickattach = FALSE)
	if(can_attach(M, rightclickattach))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return FALSE
		attach(M, rightclickattach)
		user.visible_message(span_notice("[user] attaches [src] to [M]."), span_notice("You attach [src] to [M]."))
		return TRUE
	to_chat(user, span_warning("You are unable to attach [src] to [M]!"))
	return FALSE

/obj/item/mecha_parts/mecha_equipment/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("detach")
			detach(get_turf(src))
			return TRUE
		if("toggle")
			equip_ready = !equip_ready
			return TRUE
		if("repair")
			ui.close() // allow watching for baddies and the ingame effects
			chassis.balloon_alert(usr, "Starting repair")
			while(do_after(usr, 1 SECONDS, chassis) && get_integrity() < max_integrity)
				repair_damage(30)
			if(get_integrity() == max_integrity)
				balloon_alert(usr, "Repair complete")
			return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/action_checks(atom/target)
	if(!target)
		return FALSE
	if(!equip_ready)
		return FALSE
	if(energy_drain && !chassis?.has_charge(energy_drain))
		return FALSE
	if(chassis.is_currently_ejecting)
		return FALSE
	if(chassis.equipment_disabled)
		to_chat(chassis.occupants, span_warning("Error -- Equipment control unit is unresponsive."))
		return FALSE
	if(TIMER_COOLDOWN_CHECK(chassis, COOLDOWN_MECHA_EQUIPMENT(type)))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/proc/action(mob/source, atom/target, list/modifiers)
	TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_EQUIPMENT(type), equip_cooldown)//Cooldown is on the MECH so people dont bypass it by switching equipment
	chassis.use_power(energy_drain)
	return TRUE

/obj/item/mecha_parts/mecha_equipment/proc/do_after_cooldown(atom/target, mob/user, interaction_key)
	if(!chassis)
		return
	var/C = chassis.loc
	chassis.use_power(energy_drain)
	. = do_after(user, equip_cooldown, target=target, interaction_key = interaction_key)
	if(!chassis || chassis.loc != C || !(get_dir(chassis, target)&chassis.dir))
		return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/do_after_mecha(atom/target, mob/user, delay)
	if(!chassis)
		return
	var/C = chassis.loc
	. = do_after(user, delay, target=target)
	if(!chassis || chassis.loc != C || !(get_dir(chassis, target)&chassis.dir))
		return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/can_attach(obj/vehicle/sealed/mecha/M, rightclickattach = FALSE)
	return default_can_attach(M, rightclickattach)

/obj/item/mecha_parts/mecha_equipment/proc/default_can_attach(obj/vehicle/sealed/mecha/mech, rightclickattach = FALSE)
	if(equipment_slot == MECHA_WEAPON)
		if(rightclickattach)
			if(mech.equip_by_category[MECHA_R_ARM])
				return FALSE
		else
			if(mech.equip_by_category[MECHA_L_ARM])
				return FALSE
		return TRUE
	return length(mech.equip_by_category[equipment_slot]) < mech.max_equip_by_category[equipment_slot]

/obj/item/mecha_parts/mecha_equipment/proc/attach(obj/vehicle/sealed/mecha/M, rightclickattach = FALSE)
	LAZYADD(M.flat_equipment, src)
	var/to_equip_slot = equipment_slot
	if(equipment_slot == MECHA_WEAPON)
		if(rightclickattach)
			to_equip_slot = MECHA_R_ARM
		else
			to_equip_slot = MECHA_L_ARM
	if(islist(M.equip_by_category[to_equip_slot]))
		M.equip_by_category[to_equip_slot] += src
	else
		M.equip_by_category[to_equip_slot] = src
	chassis = M
	forceMove(M)
	log_message("[src] initialized.", LOG_MECHA)

/obj/item/mecha_parts/mecha_equipment/proc/detach(atom/moveto)
	moveto = moveto || get_turf(chassis)
	if(src.Move(moveto))
		LAZYREMOVE(chassis.flat_equipment, src)
		var/to_unequip_slot = equipment_slot
		if(equipment_slot == MECHA_WEAPON)
			if(chassis.equip_by_category[MECHA_R_ARM] == src)
				to_unequip_slot = MECHA_R_ARM
			else
				to_unequip_slot = MECHA_L_ARM
		if(islist(chassis.equip_by_category[to_unequip_slot]))
			chassis.equip_by_category[to_unequip_slot] -= src
		else
			chassis.equip_by_category[to_unequip_slot] = null
		log_message("[src] removed from equipment.", LOG_MECHA)
		chassis = null
	return

/obj/item/mecha_parts/mecha_equipment/log_message(message, message_type=LOG_GAME, color=null, log_globally)
	if(chassis)
		chassis.log_message("ATTACHMENT: [src] [message]", message_type, color)
	else
		..()

/**
 * ## get_snowflake_data
 * handles the returning of snowflake data required by the UI of the mecha
 * not the prettiest of procs honeslty
 * returns:
 * * an assoc list
 * * must include an list("snowflake_id" = snowflake_id)
 */
/obj/item/mecha_parts/mecha_equipment/proc/get_snowflake_data()
	return list()

//Used for reloading weapons/tools etc. that use some form of resource
/obj/item/mecha_parts/mecha_equipment/proc/rearm()
	return FALSE


/obj/item/mecha_parts/mecha_equipment/proc/needs_rearm()
	return FALSE
