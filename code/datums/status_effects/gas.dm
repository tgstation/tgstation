/datum/status_effect/freon
	id = "frozen"
	duration = 100
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /obj/screen/alert/status_effect/freon
	var/icon/cube
	var/can_melt = TRUE

/obj/screen/alert/status_effect/freon
	name = "Frozen Solid"
	desc = "You're frozen inside of an ice cube, and cannot move! You can still do stuff, like shooting. Resist out of the cube!"
	icon_state = "frozen"

/datum/status_effect/freon/on_apply()
	if(!owner.stat)
		to_chat(owner, "<span class='userdanger'>You become frozen in a cube!</span>")
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	owner.add_overlay(cube)
	owner.update_canmove()
	return ..()

/datum/status_effect/freon/tick()
	owner.update_canmove()
	if(can_melt && owner.bodytemperature >= 310.055)
		qdel(src)

/datum/status_effect/freon/on_remove()
	if(!owner.stat)
		to_chat(owner, "The cube melts!")
	owner.cut_overlay(cube)
	owner.bodytemperature += 100
	owner.update_canmove()

/datum/status_effect/freon/watcher
	duration = 8
	can_melt = FALSE
