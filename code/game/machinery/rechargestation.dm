/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = 0
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 1000
	req_access = list(GLOB.access_robotics)
	var/recharge_speed
	var/repairs
	state_open = 1
	var/datum/action/reset_module/reset_module_action

/obj/machinery/recharge_station/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/cyborgrecharger(null)
	reset_module_action = new
	B.apply_default_parts(src)
	update_icon()

/obj/machinery/recharge_station/Destroy()
	qdel(reset_module_action)
	. = ..()

/obj/item/weapon/circuitboard/machine/cyborgrecharger
	name = "Cyborg Recharger (Machine Board)"
	build_path = /obj/machinery/recharge_station
	origin_tech = "powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/cell = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)
	def_components = list(
		/obj/item/weapon/stock_parts/cell = /obj/item/weapon/stock_parts/cell/high)

/obj/machinery/recharge_station/RefreshParts()
	recharge_speed = 0
	repairs = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		recharge_speed += C.rating * 100
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		repairs += M.rating - 1
	for(var/obj/item/weapon/stock_parts/cell/C in component_parts)
		recharge_speed *= C.maxcharge / 10000

/obj/machinery/recharge_station/process()
	if(!is_operational())
		return

	if(occupant)
		process_occupant()
	return 1

/obj/machinery/recharge_station/relaymove(mob/user)
	if(user.stat)
		return
	open_machine()

/obj/machinery/recharge_station/emp_act(severity)
	if(!(stat & (BROKEN|NOPOWER)))
		if(occupant)
			occupant.emp_act(severity)
		open_machine()
	..()

/obj/machinery/recharge_station/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/recharge_station/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/recharge_station/attackby(obj/item/P, mob/user, params)
	if(state_open)
		if(default_deconstruction_screwdriver(user, "borgdecon2", "borgcharger0", P))
			return

	if(exchange_parts(user, P))
		return

	if(default_pry_open(P))
		return

	if(default_deconstruction_crowbar(P))
		return
	return ..()

/obj/machinery/recharge_station/attack_hand(mob/user)
	if(..(user,1,set_machine = 0))
		return

	toggle_open()
	add_fingerprint(user)

/obj/machinery/recharge_station/proc/toggle_open()
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/recharge_station/open_machine()
	..()
	use_power = 1
	reset_module_action.Grant() // empty Grant() removes action from owner

/obj/machinery/recharge_station/close_machine()
	if(!panel_open)
		for(var/mob/living/silicon/robot/R in loc)
			R.forceMove(src)
			occupant = R
			use_power = 2
			add_fingerprint(R)
			reset_module_action.Grant(occupant)
			break
		state_open = 0
		density = 1
		update_icon()

/datum/action/reset_module
	name = "Reset Module"
	desc = "Reset your active module."
	icon_icon = 'icons/mob/robots.dmi'
	button_icon_state = "robot"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_CONSCIOUS | AB_CHECK_STUNNED

/datum/action/reset_module/IsAvailable()
	if(!owner || !iscyborg(owner))
		return FALSE

	var/mob/living/silicon/robot/R = owner
	if(R.module == null || R.module.type == /obj/item/weapon/robot_module)
		return FALSE

	. = ..()

/datum/action/reset_module/Trigger()
	if(!..())
		return FALSE
	var/mob/living/silicon/robot/R = owner

	R.ResetModule()

/obj/machinery/recharge_station/update_icon()
	if(is_operational())
		if(state_open)
			icon_state = "borgcharger0"
		else
			icon_state = (occupant ? "borgcharger1" : "borgcharger2")
	else
		icon_state = (state_open ? "borgcharger-u0" : "borgcharger-u1")

/obj/machinery/recharge_station/power_change()
	..()
	update_icon()

/obj/machinery/recharge_station/proc/process_occupant()
	if(occupant)
		var/mob/living/silicon/robot/R = occupant
		restock_modules()
		if(repairs)
			R.heal_bodypart_damage(repairs, repairs - 1)
		if(R.cell)
			R.cell.charge = min(R.cell.charge + recharge_speed, R.cell.maxcharge)

/obj/machinery/recharge_station/proc/restock_modules()
	if(occupant)
		var/mob/living/silicon/robot/R = occupant
		if(R && R.module)
			var/coeff = recharge_speed * 0.005
			R.module.respawn_consumable(R, coeff)
