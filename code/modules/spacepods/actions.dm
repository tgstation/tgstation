/obj/spacepod/proc/Grant(mob/living/user, list/thing, type)
	thing[user] = new type
	var/datum/action/innate/spacepod/crap = thing[user]
	crap.Grant(user, src)
	return thing

/obj/spacepod/proc/Delete(mob/living/user, list/thing, type)
	var/datum/action/innate/spacepod/crap = thing[user]
	crap.Remove(user)
	QDEL_NULL(thing[user])
	return thing

/obj/spacepod/proc/Grant_Actions(mob/living/user)
	if(user == pilot)
		unload_action = Grant(user, unload_action, /datum/action/innate/spacepod/cargo)
		fire_action = Grant(user, fire_action, /datum/action/innate/spacepod/weapons)
		door_action = Grant(user, door_action	, /datum/action/innate/spacepod/poddoor)
		tank_action = Grant(user, tank_action, /datum/action/innate/spacepod/airtank)
		lock_action = Grant(user, lock_action, /datum/action/innate/spacepod/lockpod)
		if(istype(equipment_system.syndicate_system, /obj/item/device/spacepod_equipment/syndicate/cloak))
			cloak_action = Grant(user, cloak_action, /datum/action/innate/spacepod/cloak)
	exit_action = Grant(user, exit_action, /datum/action/innate/spacepod/exit)
	light_action = Grant(user, light_action, /datum/action/innate/spacepod/lights)
	seat_action = Grant(user, seat_action, /datum/action/innate/spacepod/checkseat)


/obj/spacepod/proc/Remove_Actions(mob/living/user)
	unload_action = Delete(user, unload_action, /datum/action/innate/spacepod/cargo)
	fire_action = Delete(user, fire_action, /datum/action/innate/spacepod/weapons)
	door_action = Delete(user, door_action	, /datum/action/innate/spacepod/poddoor)
	tank_action = Delete(user, tank_action, /datum/action/innate/spacepod/airtank)
	lock_action = Delete(user, lock_action, /datum/action/innate/spacepod/lockpod)
	exit_action = Delete(user, exit_action, /datum/action/innate/spacepod/exit)
	light_action = Delete(user, light_action, /datum/action/innate/spacepod/lights)
	seat_action = Delete(user, seat_action, /datum/action/innate/spacepod/checkseat)
	cloak_action = Delete(user, cloak_action, /datum/action/innate/spacepod/cloak)

/datum/action/innate/spacepod
	var/obj/spacepod/S
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_spacepod.dmi'

/datum/action/innate/spacepod/Grant(mob/living/L, obj/spacepod/M)
	if(M)
		S = M
	..()

/datum/action/innate/spacepod/exit
	name = "Exit Spacepod"
	desc = "Exits the spacepod"
	button_icon_state = "exit"

/datum/action/innate/spacepod/exit/Activate()
	if(!S)
		return
	S.exit_pod(owner)

/datum/action/innate/spacepod/lockpod
	name = "Lock Pod"
	desc = "Locks or unlocks the pod"
	button_icon_state = "lock_off"

/datum/action/innate/spacepod/lockpod/Activate()
	if(!S)
		return
	S.lock_pod(owner)
	button_icon_state = "lock_[S.unlocked ? "off" : "on"]"
	UpdateButtonIcon()

/datum/action/innate/spacepod/poddoor
	name = "Toggle Nearby Pod Doors"
	desc = "Opens any nearby pod doors"
	button_icon_state = "bay_open"

/datum/action/innate/spacepod/poddoor/Activate()
	if(!S)
		return
	S.toggleDoors(owner)

/datum/action/innate/spacepod/weapons
	name = "Fire Pod Weapons"
	desc = "Fires the pods weapon system if there is one"
	button_icon_state = "fire"

/datum/action/innate/spacepod/weapons/Activate()
	if(!S)
		return
	S.fireWeapon(owner)

/datum/action/innate/spacepod/cargo
	name = "Unload Cargo"
	desc = "Unloads the pod's cargo, if any"
	button_icon_state = "unload"

/datum/action/innate/spacepod/cargo/Activate()
	if(!S)
		return
	S.unload(owner)

/datum/action/innate/spacepod/lights
	name = "Toggle Lights"
	desc = "Toggle the pod's lights"
	button_icon_state = "lights_off"

/datum/action/innate/spacepod/lights/Activate()
	if(!S)
		return
	S.toggleLights(owner)
	button_icon_state = "lights_[S.lights?"on":"off"]"
	UpdateButtonIcon()

/datum/action/innate/spacepod/checkseat
	name = "Check Under Seat"
	desc = "Check under the pod's seat for anything that might've been dropped."
	button_icon_state = "chair"

/datum/action/innate/spacepod/checkseat/Activate()
	if(!S)
		return
	S.checkSeat(owner)


/datum/action/innate/spacepod/airtank
	name = "Toggle internal airtank usage"
	desc = "Toggle whether you want to take air from outside or use the internal air tank."
	button_icon_state = "air_on"

/datum/action/innate/spacepod/airtank/Activate()
	if(!S)
		return
	S.toggle_internal_tank(owner)
	button_icon_state = "air_[S.use_internal_tank ? "on" : "off"]"
	UpdateButtonIcon()

/datum/action/innate/spacepod/cloak
	name = "Toggle Cloaking Device"
	desc = "Toggle the cloaking system"
	button_icon_state = "cloak"

/datum/action/innate/spacepod/cloak/Activate()
	if(!S)
		return
	if(istype(S.equipment_system.syndicate_system, /obj/item/device/spacepod_equipment/syndicate/cloak))
		var/obj/item/device/spacepod_equipment/syndicate/cloak/CL = S.equipment_system.syndicate_system
		CL.cloak()