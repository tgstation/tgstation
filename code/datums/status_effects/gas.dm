/datum/status_effect/freon
	id = "frozen"
	duration = 100
	unique = TRUE
	alert_type = /obj/screen/alert/status_effect/freon
	var/icon/cube

/obj/screen/alert/status_effect/freon
	name = "Frozen Solid"
	desc = "You're frozen inside of an ice cube, and cannot move! You can still do stuff, like shooting. Resist out of the cube!"
	icon_state = "frozen"

/datum/status_effect/freon/on_apply()
	if(!owner.stat)
		owner << "You become frozen in a cube!"
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	owner.overlays += cube
	owner.update_canmove()

/datum/status_effect/freon/tick()
	owner.update_canmove()
	if(owner && owner.bodytemperature >= 310.055)
		qdel(src)

/datum/status_effect/freon/on_remove()
	if(!owner.stat)
		owner << "The cube melts!"
	owner.overlays -= cube
	owner.bodytemperature += 100
	owner.update_canmove()
