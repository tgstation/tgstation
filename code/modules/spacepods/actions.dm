

/obj/spacepod/proc/Grant_Actions(mob/living/user)
	exit_action.Grant(user, src)
	lock_action.Grant(user, src)
	door_action.Grant(user, src)
	fire_action.Grant(user, src)
	unload_action.Grant(user, src)
	light_action.Grant(user, src)
	seat_action.Grant(user, src)
	tank_action.Grant(user, src)


/obj/spacepod/proc/Remove_Actions(mob/living/user)
	exit_action.Remove(user)
	lock_action.Remove(user)
	door_action.Remove(user)
	fire_action.Remove(user)
	unload_action.Remove(user)
	light_action.Remove(user)
	seat_action.Remove(user)
	tank_action.Remove(user)

/datum/action/innate/spacepod
	var/obj/spacepod/S
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_CONSCIOUS

/datum/action/innate/spacepod/Grant(mob/living/L, obj/spacepod/M)
	if(M)
		S = M
	..()

/datum/action/innate/spacepod/exit
	name = "Exit Spacepod"
	desc = "Exits the spacepod"

/datum/action/innate/spacepod/exit/Activate()
	if(!S)
		return
	S.exit_pod(owner)

/datum/action/innate/spacepod/lockpod
	name = "Lock Pod"
	desc = "Locks or unlocks the pod"

/datum/action/innate/spacepod/lockpod/Activate()
	if(!S)
		return
	S.lock_pod(owner)

/datum/action/innate/spacepod/poddoor
	name = "Toggle Nearby Pod Doors"
	desc = "Opens any nearby pod doors"

/datum/action/innate/spacepod/poddoor/Activate()
	if(!S)
		return
	S.toggleDoors(owner)

/datum/action/innate/spacepod/weapons
	name = "Fire Pod Weapons"
	desc = "Fires the pods weapon system if there is one"

/datum/action/innate/spacepod/weapons/Activate()
	if(!S)
		return
	S.fireWeapon(owner)

/datum/action/innate/spacepod/cargo
	name = "Unload Cargo"
	desc = "Unloads the pod's cargo, if any"

/datum/action/innate/spacepod/cargo/Activate()
	if(!S)
		return
	S.unload(owner)

/datum/action/innate/spacepod/lights
	name = "Toggle Lights"
	desc = "Toggle the pod's lights"

/datum/action/innate/spacepod/lights/Activate()
	if(!S)
		return
	S.toggleLights(owner)

/datum/action/innate/spacepod/checkseat
	name = "Check Under Seat"
	desc = "Check under the pod's seat for anything that might've been dropped."

/datum/action/innate/spacepod/checkseat/Activate()
	if(!S)
		return
	S.checkSeat(owner)


/datum/action/innate/spacepod/airtank
	name = "Toggle internal airtank usage"
	desc = "Toggle whether you want to take air from outside or use the internal air tank."

/datum/action/innate/spacepod/airtank/Activate()
	if(!S)
		return
	S.toggle_internal_tank(owner)