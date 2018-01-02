/datum/action/vehicle/spacepod
	var/obj/vehicle/sealed/spacepod/S //so we don't have to do lots of type conversions, we just do it in Grant!
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_spacepod.dmi'

/datum/action/vehicle/spacepod/Grant(mob/living/L)
	if(isspacepod(vehicle_target))
		S = vehicle_target
	else if(isspacepod(L.loc))
		S = L.loc
	return ..()

/datum/action/vehicle/spacepod/exit
	name = "Exit Spacepod"
	desc = "Exits the spacepod"
	button_icon_state = "exit"

/datum/action/vehicle/spacepod/exit/Trigger()
	if(!S)
		return
	owner.visible_message("<span class='notice'>[owner] climbs out of \the [S].</span>")
	S.mob_exit(owner, TRUE)

/datum/action/vehicle/spacepod/lockpod
	name = "Lock Pod"
	desc = "Locks or unlocks the pod"
	button_icon_state = "lock_off"

/datum/action/vehicle/spacepod/lockpod/Trigger()
	if(!S)
		return
	S.lock_pod(owner)
	button_icon_state = "lock_[S.unlocked ? "off" : "on"]"
	UpdateButtonIcon()

//open the pod bay door, HAL
/datum/action/vehicle/spacepod/poddoor
	name = "Toggle Nearby Pod Doors"
	desc = "Opens any nearby pod doors"
	button_icon_state = "bay_open"

/datum/action/vehicle/spacepod/poddoor/Trigger()
	if(!S)
		return
	S.toggleDoors(owner)

/datum/action/vehicle/spacepod/weapons
	name = "Fire Pod Weapons"
	desc = "Fires the pods weapon system if there is one"
	button_icon_state = "fire"

/datum/action/vehicle/spacepod/weapons/Trigger()
	if(!S)
		return
	if(!LAZYLEN(S.equipment)|| !istype(S.equipment[POD_EQUIPMENT_WEAPON], /obj/item/device/spacepod_equipment/weaponry))
		to_chat(owner, "<span class='warning'>[src] has no weapons!</span>")
		return
	var/obj/item/device/spacepod_equipment/weaponry/weapon = S.equipment[POD_EQUIPMENT_WEAPON]
	weapon.fire_weapons()

/datum/action/vehicle/spacepod/cargo
	name = "Unload Cargo"
	desc = "Unloads the pod's cargo, if any"
	button_icon_state = "unload"

/datum/action/vehicle/spacepod/cargo/Trigger()
	if(!S)
		return
	S.unload(owner)

/datum/action/vehicle/spacepod/lights
	name = "Toggle Lights"
	desc = "Toggle the pod's lights"
	button_icon_state = "lights_off"

/datum/action/vehicle/spacepod/lights/Trigger()
	if(!S)
		return
	S.lights = !S.lights
	if(S.lights)
		S.set_light(S.lights_power)
	else
		S.set_light(0)
	button_icon_state = "lights_[S.lights?"on":"off"]"
	UpdateButtonIcon()

/datum/action/vehicle/spacepod/checkseat
	name = "Check Under Seat"
	desc = "Check under the pod's seat for anything that might've been dropped."
	button_icon_state = "chair"

/datum/action/vehicle/spacepod/checkseat/Trigger()
	if(!S)
		return
	S.checkSeat(owner)


/datum/action/vehicle/spacepod/airtank
	name = "Toggle internal airtank usage"
	desc = "Toggle whether you want to take air from outside or use the internal air tank."
	button_icon_state = "air_on"

/datum/action/vehicle/spacepod/airtank/Trigger()
	if(!S)
		return
	S.use_internal_tank = !S.use_internal_tank
	to_chat(owner, "<span class='notice'>Now taking air from [S.use_internal_tank?"internal airtank":"environment"].</span>")
	button_icon_state = "air_[S.use_internal_tank ? "on" : "off"]"
	UpdateButtonIcon()

///

/datum/action/vehicle/spacepod/equipment
	name = "INVALID ACTION"
	desc = "You shouldn't see this"
	button_icon_state = "air_on"
	var/obj/item/device/spacepod_equipment/action/action
	var/action_type

/datum/action/vehicle/spacepod/equipment/Trigger()
	if(!action)
		action = locate(action_type) in (S.contents + S.GetAllEquipment()) //this is hacky but i couldn't find another way that worked
	if(action.my_atom == S) //make sure we didn't get a stray equipment laying on the floor!
		action.action_trigger(owner)

/datum/action/vehicle/spacepod/equipment/cloaker
	name = "Toggle Cloak"
	desc = "Toggles the syndicate cloaking device"
	button_icon_state = "cloak"
	action_type = /obj/item/device/spacepod_equipment/action/cloaker