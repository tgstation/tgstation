/obj/item/devicecrafting/device
	name = "device"
	icon = 'icons/obj/devicecrafting.dmi'
	icon_state = "device"
	var/obj/my_obj
	var/datum/devicecrafting/holder/my_holder

/obj/item/devicecrafting/device/proc/trigger(var/list/trigger_data, trigger)
	return

/obj/item/devicecrafting/device/proc/on_add()
	return

/obj/item/devicecrafting/device/proc/on_tesla(var/power)
	return

/obj/item/devicecrafting/device/proc/on_throw(atom/target)
	return

/obj/item/devicecrafting/device/proc/on_afterattack(atom/target, mob/user, proximity_flag)
	return

/obj/item/devicecrafting/device/proc/on_attackby(obj/item/I, mob/living/user)
	return

/obj/item/devicecrafting/device/proc/on_attack_hand(mob/user)
	return

/obj/item/devicecrafting/device/proc/on_attack_self(mob/user)
	return

/obj/item/devicecrafting/device/proc/on_attack_ai(mob/user)
	return

/obj/item/devicecrafting/device/trigger/tesla // tiles surrouding my tile
	name = "tesla trigger"
	desc = "Activates when zapped by a tesla bolt." // oh shit i'm sorry

/obj/item/devicecrafting/device/trigger/tesla/on_tesla(var/power)
	for(var/D in my_holder.devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.trigger(list("power" = power), src)
	return

/obj/item/devicecrafting/device/trigger/throwing // colliding
	name = "impact trigger"
	desc = "Activates when colliding after a throw." // sorry for what? our codebase taught us not to be ashamed of our line limits, 'specially since they're such good size and all

/obj/item/devicecrafting/device/trigger/throwing/on_throw(atom/target)
	for(var/D in my_holder.devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.trigger(list("target" = target), src)
	return

/obj/item/devicecrafting/device/trigger/ranged // ranged attack
	name = "beam trigger"
	desc = "Can be used to activate onto a target from a range." // yeah, i see that, your codebase gave you good advice

/obj/item/devicecrafting/device/trigger/ranged/on_afterattack(atom/target, mob/user, proximity_flag)
	for(var/D in my_holder.devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.trigger(list("target" = target, "user" = user, "prox_flag" = proximity_flag), src)
	return

/obj/item/devicecrafting/device/trigger/melee // melee attack
	name = "blunt trigger"
	desc = "Can be used to activate on a target by hitting them." // it gets bigger when i pull it, and sometimes, i pull on it so hard, i get a merge conflict

/obj/item/devicecrafting/device/trigger/melee/on_attackby(obj/item/I, mob/living/user)
	for(var/D in my_holder.devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.trigger(list("user" = user, "item" = I), src)
	return

/obj/item/devicecrafting/device/trigger/hand // click item
	name = "button trigger"
	desc = "Activates when touched." // my codebase taught me a few things too, like how not to get a merge conflict by using someone else's branch, to steady your own PR

/obj/item/devicecrafting/device/trigger/hand/on_attack_hand(mob/user)
	for(var/D in my_holder.devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.trigger(list("user" = user), src)
	return

/obj/item/devicecrafting/device/trigger/self // use inhand
	name = "grip trigger"
	desc = "Activates when used." // will you show me?

/obj/item/devicecrafting/device/trigger/self/on_attack_self(mob/user)
	for(var/D in my_holder.devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.trigger(list("user" = user), src)
	return

/obj/item/devicecrafting/device/trigger/ai
	name = "silicon trigger"
	desc = "Activates when a silicon uses it." // i'd be right happy to

/obj/item/devicecrafting/device/trigger/ai/on_attack_ai(mob/user)
	for(var/D in my_holder.devices)
		var/obj/item/devicecrafting/device/DE = D
		DE.trigger(list("user" = user), src)
	return