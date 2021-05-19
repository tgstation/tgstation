/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magboot_state = "magboots"
	var/magpulse = FALSE
	var/slowdown_active = 2
	permeability_coefficient = 0.05
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 70
	equip_delay_other = 70
	resistance_flags = FIRE_PROOF

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	set src in usr
	if(!can_use(usr))
		return
	attack_self(usr)


/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(magpulse)
		clothing_flags &= ~NOSLIP
		slowdown = SHOES_SLOWDOWN
	else
		clothing_flags |= NOSLIP
		slowdown = slowdown_active
	magpulse = !magpulse
	icon_state = "[magboot_state][magpulse]"
	to_chat(user, "<span class='notice'>You [magpulse ? "enable" : "disable"] the mag-pulse traction system.</span>")
	user.update_inv_shoes() //so our mob-overlays update
	user.update_gravity(user.has_gravity())
	user.update_equipment_speed_mods() //we want to update our speed so we arent running at max speed in regular magboots
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/shoes/magboots/negates_gravity()
	return clothing_flags & NOSLIP

/obj/item/clothing/shoes/magboots/examine(mob/user)
	. = ..()
	. += "Its mag-pulse traction system appears to be [magpulse ? "enabled" : "disabled"]."


/obj/item/clothing/shoes/magboots/advance
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "advanced magboots"
	icon_state = "advmag0"
	magboot_state = "advmag"
	slowdown_active = SHOES_SLOWDOWN
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/magboots/syndie
	desc = "Reverse-engineered magnetic boots that have a heavy magnetic pull. Property of Gorlex Marauders."
	name = "blood-red magboots"
	icon_state = "syndiemag0"
	magboot_state = "syndiemag"

/obj/item/clothing/shoes/magboots/gravboots
	desc = "A pair of modified magnetic boots that use an anomaly core to generate gravity around the user instead of pulling their feet to the ground. Requires a gravitational anomaly core to function."
	name = "zero-point magboots"
	icon_state = "gravboots0"
	magboot_state = "gravboots"
	slowdown_active = 1
	var/core = FALSE
	var/list/grav_turfs = list()

/obj/item/clothing/shoes/magboots/gravboots/attackby(obj/item/C, mob/user)
	if(istype(C, /obj/item/assembly/signaler/anomaly/grav))
		to_chat(user, "<span class='notice'>You insert [C] into [src] and their circuitry gently hums to life.</span>")
		core = TRUE
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		qdel(C)
		return
	return ..()

/obj/item/clothing/shoes/magboots/gravboots/attack_self(mob/user)
	if(!core)
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		to_chat(user, "<span class='warning'>[src] fail to activate without an inserted anomaly core!</span>")
		return

	if(magpulse)
		clothing_flags &= ~NOSLIP
		slowdown = SHOES_SLOWDOWN
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	else
		clothing_flags |= NOSLIP
		slowdown = slowdown_active
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/distance_check)

	magpulse = !magpulse
	icon_state = "[magboot_state][magpulse]"
	to_chat(user, "<span class='notice'>You [magpulse ? "enable" : "disable"] the mag-pulse traction system.</span>")
	user.update_inv_shoes()
	user.update_gravity(user.has_gravity())
	user.update_equipment_speed_mods()

	distance_check()

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/shoes/magboots/gravboots/proc/distance_check(mob/user)
	for(var/turf/grav_turf in grav_turfs)
		if(get_dist(src, grav_turf) > 2)
			grav_turf.RemoveElement(/datum/element/forced_gravity, 1)
			grav_turfs.Remove(grav_turf)

	for(var/turf/grav_turf in range(2, user))
		if(!(grav_turf in grav_turfs))
			grav_turf.AddElement(/datum/element/forced_gravity, 1)
			grav_turfs.Add(grav_turf)

