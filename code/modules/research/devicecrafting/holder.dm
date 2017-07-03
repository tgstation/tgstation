/datum/devicecrafting/holder
	var/list/devices = list()
	var/max_devices = 3
	var/obj/my_obj
	var/icon = 'icons/obj/devicecrafting.dmi'
	var/icon_state = "holder"

/datum/devicecrafting/holder/proc/init_holder()
	my_obj.icon = icon
	my_obj.icon_state = icon_state

/datum/devicecrafting/holder/proc/add_device(var/obj/item/devicecrafting/device/D)
	D.my_obj = my_obj
	D.my_holder = src
	D.on_add()

/datum/devicecrafting/holder/proc/on_tesla(var/power)
	for(var/D in devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.on_tesla(power)

/datum/devicecrafting/holder/proc/on_throw(atom/target)
	for(var/D in devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.on_throw(target)

/datum/devicecrafting/holder/proc/on_afterattack(atom/target, mob/user, proximity_flag)
	for(var/D in devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.on_afterattack(target,user,proximity_flag)

/datum/devicecrafting/holder/proc/on_attackby(obj/item/I, mob/living/user)
	for(var/D in devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.on_attackby(I,user)

/datum/devicecrafting/holder/proc/on_attack_hand(mob/user)
	for(var/D in devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.on_attack_hand(user)

/datum/devicecrafting/holder/proc/on_attack_self(mob/user)
	for(var/D in devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.on_attack_self(user)

/datum/devicecrafting/holder/proc/on_attack_ai(mob/user)
	for(var/D in devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.on_attack_ai(user)