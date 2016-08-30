/datum/status_effect/freon
	name = "Frozen Solid"
	desc = "You're frozen inside of an ice cube, and cannot move! You can still do stuff, like shooting. Resist out of the cube!"
	id = "frozen"
	icon_state = "frozen"
	duration = 10
	unique = TRUE
	var/icon/cube

/datum/status_effect/freon/on_apply()
	if(!owner.stat)
		owner << "You become frozen in a cube!"
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	owner.overlays += cube
	owner.update_canmove()

/datum/status_effect/freon/tick()
	owner.update_canmove()
	if(owner)
		if(owner.bodytemperature >= 310.055)
			cancel_effect()

/datum/status_effect/freon/on_remove()
	if(!owner.stat)
		owner << "The cube melts!"
	owner.overlays -= cube
	owner.bodytemperature += 100
	owner.update_canmove()
