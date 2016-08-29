/datum/status_effect/freon
	name = "Frozen Solid"
	desc = "You're frozen inside of an ice cube!"
	id = "frozen"
	duration = 10
	unique = TRUE
	var/icon/cube

/datum/status_effect/freon/on_apply()
	owner << "You become frozen in a cube!"
	owner.Stun(2)
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	owner.overlays += cube

/datum/status_effect/freon/tick()
	if(owner)
		owner.Stun(2)
		if(owner.bodytemperature >= 310.055)
			cancel_effect()

/datum/status_effect/freon/on_remove()
	owner.overlays -= cube
	owner.bodytemperature += 100
