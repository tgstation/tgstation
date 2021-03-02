/obj/machinery/ai_slipper
	name = "foam dispenser"
	desc = "A remotely-activatable dispenser for crowd-controlling foam."
	icon = 'icons/obj/device.dmi'
	icon_state = "ai-slipper0"
	base_icon_state = "ai-slipper"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	plane = FLOOR_PLANE
	max_integrity = 200
	armor = list(MELEE = 50, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)

	var/uses = 20
	var/cooldown = 0
	var/cooldown_time = 100
	req_access = list(ACCESS_AI_UPLOAD)

/obj/machinery/ai_slipper/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It has <b>[uses]</b> uses of foam remaining.</span>"

/obj/machinery/ai_slipper/update_icon_state()
	if(machine_stat & BROKEN)
		return ..()
	if((machine_stat & NOPOWER) || cooldown_time > world.time || !uses)
		icon_state = "[base_icon_state]0"
		return ..()
	icon_state = "[base_icon_state]1"
	return ..()

/obj/machinery/ai_slipper/interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='danger'>Access denied.</span>")
		return
	if(!uses)
		to_chat(user, "<span class='warning'>[src] is out of foam and cannot be activated!</span>")
		return
	if(cooldown_time > world.time)
		to_chat(user, "<span class='warning'>[src] cannot be activated for <b>[DisplayTimeText(world.time - cooldown_time)]</b>!</span>")
		return
	new /obj/effect/particle_effect/foam(loc)
	uses--
	to_chat(user, "<span class='notice'>You activate [src]. It now has <b>[uses]</b> uses of foam remaining.</span>")
	cooldown = world.time + cooldown_time
	power_change()
	addtimer(CALLBACK(src, .proc/power_change), cooldown_time)
