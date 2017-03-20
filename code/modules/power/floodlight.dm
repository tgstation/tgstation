
/obj/machinery/power/floodlight
	name = "floodlight"
	desc = "A pole with powerful mounted lights on it. Due to its high power draw, it must be powered by a direct connection to a wire node."1
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floodlight"
	anchored = 1
	idle_power_usage = 100
	active_power_usage = 1000
	var/light_setting_list = list(0, 5, 10, 15)
	var/light_power_coefficient = 300
	var/setting = 1

/obj/machinery/power/floodlight/process()
	if(avail(active_power_usage))
		add_load(active_power_usage))
	else
		change_setting(1)

/obj/machinery/power/floodlight/proc/change_setting(val, mob/user)
	if(val<1||val>light_setting_list.len)
		return
	active_power_usage = light_setting_list[val]
	if(!avail(active_power_usage))
		return change_setting(val - 1)
	setting = val
	light_range = light_setting_list[val]
	light_power = val
	update_light()
	var/setting_text = ""
	if(val > 1)
		icon_state = "[icon_state]_on"
	else
		icon_state = initial(icon_state)
	switch(val)
		if(1)
			setting_text = "OFF"
		if(2)
			setting_text = "low power"
		if(3)
			setting_text = "standard lighting"
		if(4)
			setting_text = "high power"
	if(user)
		to_chat(user, setting_text)

/obj/machinery/power/floodlight/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/weapon/wrench))
		if(!anchored && !isinspace())
			connect_to_network()
			to_chat(user, "<span class='notice'>You secure the generator to the floor.</span>")
			anchored = 1
		else if(anchored)
			disconnect_from_network()
			to_chat(user, "<span class='notice'>You unsecure the generator from the floor.</span>")
			anchored = 0
	. = ..()

/obj/machinery/power/floodlight/attack_hand(mob/user)
	var/current = val
	if(current == 1)
		current = light_setting_list.len
	else
		current--
	change_setting(current, user)
	..()

/obj/machinery/power/floodlight/attack_ai(mob/living/silicon/user)
	attack_hand(user)
	..()
