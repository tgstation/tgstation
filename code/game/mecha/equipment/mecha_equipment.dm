//TODO: Add critfail checks and reliability

/obj/item/mecha_parts/mecha_equipment
	name = "mecha equipment"
	icon = 'mech_construct.dmi'
	icon_state = "mecha_equip"
	force = 5
	construction_time = 100
	construction_cost = list("metal"=10000)
	var/equip_cooldown = 0
	var/equip_ready = 1
	var/energy_drain = 0
	var/obj/mecha/chassis = null
	var/range = MELEE //bitflags


/obj/item/mecha_parts/mecha_equipment/proc/do_after_cooldown()
	sleep(equip_cooldown)
	if(src && chassis)
		return 1
	return 0


/obj/item/mecha_parts/mecha_equipment/New()
	..()
	return


/obj/item/mecha_parts/mecha_equipment/proc/destroy()//missiles detonating, teleporter creating singularity?
	spawn
		del src
	return

/obj/item/mecha_parts/mecha_equipment/proc/get_equip_info()
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span> [src.name]"

/obj/item/mecha_parts/mecha_equipment/proc/is_ranged()//add a distance restricted equipment. Why not?
	return range&RANGED

/obj/item/mecha_parts/mecha_equipment/proc/is_melee()
	return range&MELEE


/obj/item/mecha_parts/mecha_equipment/proc/action_checks(atom/target)
	if(!target)
		return 0
	if(!chassis)
		return 0
	if(energy_drain && chassis.get_charge() < energy_drain)
		return 0
	if(!equip_ready)
		return 0
	return 1

/obj/item/mecha_parts/mecha_equipment/proc/action(atom/target)
	return

/obj/item/mecha_parts/mecha_equipment/proc/can_attach(obj/mecha/M as obj)
	if(istype(M))
		if(M.equipment.len<M.max_equip)
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/proc/attach(obj/mecha/M as obj)
	M.equipment += src
	src.chassis = M
	src.loc = M
	M.log_message("[src] initialized.")
	if(!M.selected)
		M.selected = src
	return

/obj/item/mecha_parts/mecha_equipment/weapon/can_attach(obj/mecha/M as obj)
	if(..())
		if(istype(M, /obj/mecha/combat))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/proc/detach()
	if(src.Move(get_turf(chassis)))
		chassis.equipment -= src
		if(chassis.selected == src)
			chassis.selected = null
		chassis.log_message("[src] removed from equipment.")
		src.chassis = null
		src.equip_ready = 1
	return


