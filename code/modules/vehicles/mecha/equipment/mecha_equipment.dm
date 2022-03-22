/**
 * Mecha Equipment
 * All mech equippables are currently childs of this
 */
/obj/item/mecha_parts/mecha_equipment
	name = "mecha equipment"
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_equip"
	force = 5
	max_integrity = 300
	///Cooldown in ticks required between activations of the equipment
	var/equip_cooldown = 0
	///used for equipment that can be turned on/off, boolean
	var/activated = TRUE
	///Chassis power cell quantity used on activation
	var/energy_drain = 0
	///Reference to mecha that this equipment is currently attached to
	var/obj/vehicle/sealed/mecha/chassis
	///Bitflag. Determines the range of the equipment.
	var/range = MECHA_MELEE
	/// Bitflag. Used by exosuit fabricator to assign sub-categories based on which exosuits can equip this.
	var/mech_flags = NONE
	///boolean: FALSE if this equipment can not be removed/salvaged
	var/detachable = TRUE
	///Boolean: whether we can equip this equipment through the mech UI or the cycling ability
	var/selectable = TRUE
	///Boolean: whether a pacifist can use this equipment
	var/harmful = FALSE
	///Sound file: Sound to play when this equipment is destroyed while still attached to the mech
	var/destroy_sound = 'sound/mecha/critdestr.ogg'

///Updates chassis equipment list html menu
/obj/item/mecha_parts/mecha_equipment/proc/update_chassis_page()
	SHOULD_CALL_PARENT(TRUE)
	send_byjax(chassis.occupants,"exosuit.browser","eq_list", chassis.get_equipment_list())
	send_byjax(chassis.occupants,"exosuit.browser","equipment_menu", chassis.get_equipment_menu(),"dropdowns")
	return TRUE

///Updates chassis equipment list html menu with custom data
/obj/item/mecha_parts/mecha_equipment/proc/update_equip_info()
	if(!chassis)
		return
	send_byjax(chassis.occupants,"exosuit.browser","[REF(src)]",get_equip_info())
	return TRUE

/obj/item/mecha_parts/mecha_equipment/Destroy()
	if(chassis)
		LAZYREMOVE(chassis.equipment, src)
		if(chassis.selected == src)
			chassis.selected = null
		update_chassis_page()
		log_message("[src] is destroyed.", LOG_MECHA)
		if(LAZYLEN(chassis.occupants))
			to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_danger("[src] is destroyed!")]")
			playsound(chassis, destroy_sound, 50)
		if(!detachable) //If we're a built-in nondetachable equipment, let's lock up the slot that we were in.
			chassis.max_equip--
		chassis = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/try_attach_part(mob/user, obj/vehicle/sealed/mecha/mech)
	if(!can_attach(mech))
		to_chat(user, span_warning("You are unable to attach [src] to [mech]!"))
		return FALSE
	if(!user.temporarilyRemoveItemFromInventory(src))
		return FALSE
	attach(mech)
	user.visible_message(span_notice("[user] attaches [src] to [mech]."), span_notice("You attach [src] to [mech]."))
	return TRUE

///fetches and returns a html formatted string with equippability status
/obj/item/mecha_parts/mecha_equipment/proc/get_equip_info()
	if(!chassis)
		return
	var/txt = "<span style=\"color:[activated?"#0f0":"#f00"];\">*</span>&nbsp;"
	if(chassis.selected == src)
		txt += "<b>[src]</b>"
	else if(selectable)
		txt += "<a href='?src=[REF(chassis)];select_equip=[REF(src)]'>[src]</a>"
	else
		txt += "[src]"

	return txt

/**
 * Checks whether this mecha equipment can be activated
 * Returns a bool
 * Arguments:
 * * target: atom we are activating/clicked on
 */
/obj/item/mecha_parts/mecha_equipment/proc/action_checks(atom/target)
	if(!target)
		return FALSE
	if(!chassis)
		return FALSE
	if(!activated)
		return FALSE
	if(energy_drain && !chassis.has_charge(energy_drain))
		return FALSE
	if(chassis.is_currently_ejecting)
		return FALSE
	if(chassis.equipment_disabled)
		to_chat(chassis.occupants, span_warning("Error -- Equipment control unit is unresponsive."))
		return FALSE
	if(TIMER_COOLDOWN_CHECK(chassis, COOLDOWN_MECHA_EQUIPMENT))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/proc/action(mob/source, atom/target, list/modifiers)
	TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_EQUIPMENT, equip_cooldown)//Cooldown is on the MECH so people dont bypass it by switching equipment
	send_byjax(chassis.occupants,"exosuit.browser","[REF(src)]", get_equip_info())
	chassis.use_power(energy_drain)
	return TRUE

/**
 * Cooldown proc variant for using do_afters between activations instead of timers
 * Example of usage is mech drills, rcds
 * arguments:
 * * target: targetted atom for action activation
 * * user: occupant to display do after for
 * * interaction_key: interaction key to pass to [/proc/do_after]
 */
/obj/item/mecha_parts/mecha_equipment/proc/do_after_cooldown(atom/target, mob/user, interaction_key)
	if(!chassis)
		return
	chassis.use_power(energy_drain)
	. = do_after(user, equip_cooldown, target=target, interaction_key = interaction_key)
	if(!chassis || src != chassis.selected || !(get_dir(chassis, target) & chassis.dir))
		return FALSE

///Do after wrapper for mecha equipment
/obj/item/mecha_parts/mecha_equipment/proc/do_after_mecha(atom/target, mob/user, delay)
	if(!chassis)
		return
	. = do_after(user, delay, target=target)
	if(!chassis || src != chassis.selected || !(get_dir(chassis, target) & chassis.dir))
		return FALSE

///Returns TRUE if equipment should be allowed to attach to the targetted necha
/obj/item/mecha_parts/mecha_equipment/proc/can_attach(obj/vehicle/sealed/mecha/M)
	return LAZYLEN(M.equipment) < M.max_equip

///Attaches equipment and updates relevant equipment trackers
/obj/item/mecha_parts/mecha_equipment/proc/attach(obj/vehicle/sealed/mecha/M)
	LAZYADD(M.equipment, src)
	chassis = M
	forceMove(M)
	log_message("[src] attached.", LOG_MECHA)
	update_chassis_page()

///Detaches equipment and updates relevant equipment trackers. Optional argument of atom to forcemove to once detached
/obj/item/mecha_parts/mecha_equipment/proc/detach(atom/moveto)
	SHOULD_CALL_PARENT(TRUE)
	moveto = moveto || get_turf(chassis)
	forceMove(moveto)
	LAZYREMOVE(chassis.equipment, src)
	if(chassis.selected == src)
		chassis.selected = null
	update_chassis_page()
	log_message("[src] removed from equipment.", LOG_MECHA)
	chassis = null

/obj/item/mecha_parts/mecha_equipment/Topic(href,href_list)
	. = ..()
	if(.)
		return
	if(href_list["detach"])
		detach()

/obj/item/mecha_parts/mecha_equipment/log_message(message, message_type=LOG_GAME, color=null, log_globally)
	if(chassis)
		return chassis.log_message("ATTACHMENT: [src] [message]", message_type, color)
	return ..()


/**
 * Proc for reloading weapons from HTML UI or by AI
 * note that this is old and likely broken code
 */
/obj/item/mecha_parts/mecha_equipment/proc/rearm()
	return FALSE

/// AI mech pilot: returns TRUE if the Ai should try to reload the mecha
/obj/item/mecha_parts/mecha_equipment/proc/needs_rearm()
	return FALSE
