//DO NOT ADD MECHA PARTS TO THE GAME WITH THE DEFAULT "SPRITE ME" SPRITE!
//I'm annoyed I even have to tell you this! SPRITE FIRST, then commit.

/obj/item/mecha_parts/mecha_equipment
	name = "mecha equipment"
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_equip"
	force = 5
	max_integrity = 300
	var/equip_cooldown = 0 // cooldown after use
	var/equip_ready = 1 //whether the equipment is ready for use. (or deactivated/activated for static stuff)
	var/energy_drain = 0
	var/obj/mecha/chassis = null
	var/range = MELEE //bitFflags
	var/salvageable = 1
	var/selectable = 1	// Set to 0 for passive equipment such as mining scanner or armor plates
	var/harmful = FALSE //Controls if equipment can be used to attack by a pacifist.

/obj/item/mecha_parts/mecha_equipment/proc/update_chassis_page()
	if(chassis)
		send_byjax(chassis.occupant,"exosuit.browser","eq_list",chassis.get_equipment_list())
		send_byjax(chassis.occupant,"exosuit.browser","equipment_menu",chassis.get_equipment_menu(),"dropdowns")
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/proc/update_equip_info()
	if(chassis)
		send_byjax(chassis.occupant,"exosuit.browser","[REF(src)]",get_equip_info())
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/Destroy()
	if(chassis)
		chassis.equipment -= src
		if(chassis.selected == src)
			chassis.selected = null
		src.update_chassis_page()
		chassis.occupant_message("<span class='danger'>[src] is destroyed!</span>")
		log_message("[src] is destroyed.", LOG_MECHA)
		SEND_SOUND(chassis.occupant, sound(istype(src, /obj/item/mecha_parts/mecha_equipment/weapon) ? 'sound/mecha/weapdestr.ogg' : 'sound/mecha/critdestr.ogg', volume=50))
		chassis = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/proc/critfail()
	log_message("Critical failure", LOG_MECHA, color="red")

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

/obj/item/mecha_parts/mecha_equipment/proc/is_ranged()//add a distance restricted equipment. Why not?
	return range&RANGED

/obj/item/mecha_parts/mecha_equipment/proc/is_melee()
	return range&MELEE


/obj/item/mecha_parts/mecha_equipment/proc/action_checks(atom/target)
	if(!target)
		return 0
	if(!chassis)
		return 0
	if(!equip_ready)
		return 0
	if(crit_fail)
		return 0
	if(energy_drain && !chassis.has_charge(energy_drain))
		return 0
	return 1

/obj/item/mecha_parts/mecha_equipment/proc/action(atom/target)
	return 0

/obj/item/mecha_parts/mecha_equipment/proc/start_cooldown()
	set_ready_state(0)
	chassis.use_power(energy_drain)
	addtimer(CALLBACK(src, .proc/set_ready_state, 1), equip_cooldown)

/obj/item/mecha_parts/mecha_equipment/proc/do_after_cooldown(atom/target)
	if(!chassis)
		return
	var/C = chassis.loc
	set_ready_state(0)
	chassis.use_power(energy_drain)
	. = do_after(chassis.occupant, equip_cooldown, target=target)
	set_ready_state(1)
	if(!chassis || 	chassis.loc != C || src != chassis.selected || !(get_dir(chassis, target)&chassis.dir))
		return 0

/obj/item/mecha_parts/mecha_equipment/proc/do_after_mecha(atom/target, delay)
	if(!chassis)
		return
	var/C = chassis.loc
	. = do_after(chassis.occupant, delay, target=target)
	if(!chassis || 	chassis.loc != C || src != chassis.selected || !(get_dir(chassis, target)&chassis.dir))
		return 0

/obj/item/mecha_parts/mecha_equipment/proc/can_attach(obj/mecha/M)
	if(M.equipment.len<M.max_equip)
		return 1

/obj/item/mecha_parts/mecha_equipment/proc/attach(obj/mecha/M)
	M.equipment += src
	chassis = M
	forceMove(M)
	log_message("[src] initialized.", LOG_MECHA)
	if(!M.selected && selectable)
		M.selected = src
	update_chassis_page()
	return

/obj/item/mecha_parts/mecha_equipment/proc/detach(atom/moveto=null)
	moveto = moveto || get_turf(chassis)
	if(src.Move(moveto))
		chassis.equipment -= src
		if(chassis.selected == src)
			chassis.selected = null
		update_chassis_page()
		log_message("[src] removed from equipment.", LOG_MECHA)
		chassis = null
		set_ready_state(1)
	return


/obj/item/mecha_parts/mecha_equipment/Topic(href,href_list)
	if(href_list["detach"])
		detach()

/obj/item/mecha_parts/mecha_equipment/proc/set_ready_state(state)
	equip_ready = state
	if(chassis)
		send_byjax(chassis.occupant,"exosuit.browser","[REF(src)]",src.get_equip_info())
	return

/obj/item/mecha_parts/mecha_equipment/proc/occupant_message(message)
	if(chassis)
		chassis.occupant_message("[icon2html(src, chassis.occupant)] [message]")
	return

/obj/item/mecha_parts/mecha_equipment/log_message(message, message_type=LOG_GAME, color=null, log_globally)
	if(chassis)
		chassis.log_message("ATTACHMENT: [src] [message]", message_type, color)
	else
		..()


//Used for reloading weapons/tools etc. that use some form of resource
/obj/item/mecha_parts/mecha_equipment/proc/rearm()
	return 0


/obj/item/mecha_parts/mecha_equipment/proc/needs_rearm()
	return 0
