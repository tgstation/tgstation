//DO NOT ADD MECHA PARTS TO THE GAME WITH THE DEFAULT "SPRITE ME" SPRITE!
//I'm annoyed I even have to tell you this! SPRITE FIRST, then commit.

/obj/item/mecha_parts/mecha_equipment
	name = "mecha equipment"
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_equip"
	force = 5
	max_integrity = 300
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
	var/selectable = 1	// Set to 0 for passive equipment such as mining scanner or armor plates
	var/harmful = FALSE //Controls if equipment can be used to attack by a pacifist.
	var/destroy_sound = 'sound/mecha/critdestr.ogg'

/obj/item/mecha_parts/mecha_equipment/proc/update_chassis_page()
	if(chassis)
		send_byjax(chassis.occupants,"exosuit.browser","eq_list",chassis.get_equipment_list())
		send_byjax(chassis.occupants,"exosuit.browser","equipment_menu",chassis.get_equipment_menu(),"dropdowns")
		return TRUE
	return

/obj/item/mecha_parts/mecha_equipment/proc/update_equip_info()
	if(chassis)
		send_byjax(chassis.occupants,"exosuit.browser","[REF(src)]",get_equip_info())
		return TRUE
	return

/obj/item/mecha_parts/mecha_equipment/Destroy()
	if(chassis)
		LAZYREMOVE(chassis.equipment, src)
		if(chassis.selected == src)
			chassis.selected = null
		update_chassis_page()
		log_message("[src] is destroyed.", LOG_MECHA)
		if(LAZYLEN(chassis.occupants))
			to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='danger'>[src] is destroyed!</span>")
			playsound(chassis, destroy_sound, 50)
		if(!detachable) //If we're a built-in nondetachable equipment, let's lock up the slot that we were in.
			chassis.max_equip--
		chassis = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/try_attach_part(mob/user, obj/vehicle/sealed/mecha/M)
	if(can_attach(M))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return FALSE
		attach(M)
		user.visible_message("<span class='notice'>[user] attaches [src] to [M].</span>", "<span class='notice'>You attach [src] to [M].</span>")
		return TRUE
	to_chat(user, "<span class='warning'>You are unable to attach [src] to [M]!</span>")
	return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/get_equip_info()
	if(!chassis)
		return
	var/txt = "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;"
	if(chassis.selected == src)
		txt += "<b>[src.name]</b>"
	else if(selectable)
		txt += "<a href='?src=[REF(chassis)];select_equip=[REF(src)]'>[src.name]</a>"
	else
		txt += "[src.name]"

	return txt

/obj/item/mecha_parts/mecha_equipment/proc/action_checks(atom/target)
	if(!target)
		return FALSE
	if(!chassis)
		return FALSE
	if(!equip_ready)
		return FALSE
	if(energy_drain && !chassis.has_charge(energy_drain))
		return FALSE
	if(chassis.is_currently_ejecting)
		return FALSE
	if(chassis.equipment_disabled)
		to_chat(chassis.occupants, "<span=warn>Error -- Equipment control unit is unresponsive.</span>")
		return FALSE
	if(TIMER_COOLDOWN_CHECK(chassis, COOLDOWN_MECHA_EQUIPMENT))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/proc/action(mob/source, atom/target, params)
	TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_EQUIPMENT, equip_cooldown)//Cooldown is on the MECH so people dont bypass it by switching equipment
	send_byjax(chassis.occupants,"exosuit.browser","[REF(src)]",src.get_equip_info())
	chassis.use_power(energy_drain)
	return TRUE

/obj/item/mecha_parts/mecha_equipment/proc/do_after_cooldown(atom/target, mob/user, interaction_key)
	if(!chassis)
		return
	var/C = chassis.loc
	chassis.use_power(energy_drain)
	. = do_after(user, equip_cooldown, target=target, interaction_key = interaction_key)
	if(!chassis || 	chassis.loc != C || src != chassis.selected || !(get_dir(chassis, target)&chassis.dir))
		return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/do_after_mecha(atom/target, mob/user, delay)
	if(!chassis)
		return
	var/C = chassis.loc
	. = do_after(user, delay, target=target)
	if(!chassis || 	chassis.loc != C || src != chassis.selected || !(get_dir(chassis, target)&chassis.dir))
		return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/can_attach(obj/vehicle/sealed/mecha/M)
	if(LAZYLEN(M.equipment)<M.max_equip)
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/attach(obj/vehicle/sealed/mecha/M)
	LAZYADD(M.equipment, src)
	chassis = M
	forceMove(M)
	log_message("[src] initialized.", LOG_MECHA)
	update_chassis_page()
	return

/obj/item/mecha_parts/mecha_equipment/proc/detach(atom/moveto=null)
	moveto = moveto || get_turf(chassis)
	if(src.Move(moveto))
		LAZYREMOVE(chassis.equipment, src)
		if(chassis.selected == src)
			chassis.selected = null
		update_chassis_page()
		log_message("[src] removed from equipment.", LOG_MECHA)
		chassis = null
	return


/obj/item/mecha_parts/mecha_equipment/Topic(href,href_list)
	if(href_list["detach"])
		detach()

/obj/item/mecha_parts/mecha_equipment/log_message(message, message_type=LOG_GAME, color=null, log_globally)
	if(chassis)
		chassis.log_message("ATTACHMENT: [src] [message]", message_type, color)
	else
		..()


//Used for reloading weapons/tools etc. that use some form of resource
/obj/item/mecha_parts/mecha_equipment/proc/rearm()
	return FALSE


/obj/item/mecha_parts/mecha_equipment/proc/needs_rearm()
	return FALSE
