/datum/status_effect/freon
	id = "frozen"
	duration = 10
	unique = TRUE
	alert_type = /obj/screen/alert/status_effect/freon
	var/icon/cube

/obj/screen/alert/status_effect/freon
	name = "Frozen Solid"
	desc = "You're frozen inside of an ice cube, and cannot move! You can still do stuff, like shooting. Resist out of the cube!"
	icon_state = "frozen"

/datum/status_effect/freon/on_apply()
	owner.visible_message("<span class='warning'>A chunk of ice forms around [owner]!</span>", "<span class='userdanger'>You're frozen solid!</span>")
	playsound(owner, 'sound/effects/ice_form.ogg', 50, 1)
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	owner.overlays += cube
	owner.update_canmove()

/datum/status_effect/freon/tick()
	owner.update_canmove()
	if(owner)
		if(owner.bodytemperature >= 310.055)
			cancel_effect()

/datum/status_effect/freon/on_remove()
	owner.visible_message("<span class='warning'>The ice cube shatters!</span>", "<span class='userdanger'>The ice cube around you falls apart!</span>")
	playsound(owner, 'sound/effects/ice_shatter.ogg', 50, 1)
	owner.overlays -= cube
	owner.bodytemperature += 100
	owner.update_canmove()
