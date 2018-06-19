/obj/machinery/ai_slipper
	name = "foam dispenser"
	desc = "A remotely-activatable dispenser for crowd-controlling foam."
	icon = 'icons/obj/device.dmi'
	icon_state = "ai-slipper0"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	plane = FLOOR_PLANE
	max_integrity = 200
	armor = list("melee" = 50, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)

	var/uses = 20
	var/cooldown = 0
	var/cooldown_time = 100
	req_access = list(ACCESS_AI_UPLOAD)

/obj/machinery/ai_slipper/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It has <b>[uses]</b> uses of foam remaining.</span>")

/obj/machinery/ai_slipper/power_change()
	if(stat & BROKEN)
		return
	else
		if(powered())
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		if((stat & (NOPOWER|BROKEN)) || cooldown_time > world.time || !uses)
			icon_state = "ai-slipper0"
		else
			icon_state = "ai-slipper1"

/obj/machinery/ai_slipper/interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='danger'>Access denied.</span>")
		return
	if(!uses)
		to_chat(user, "<span class='danger'>[src] is out of foam and cannot be activated.</span>")
		return
	if(cooldown_time > world.time)
		to_chat(user, "<span class='danger'>[src] cannot be activated for <b>[DisplayTimeText(world.time - cooldown_time)]</b>.</span>")
		return
	new /obj/effect/particle_effect/foam(loc)
	uses--
	to_chat(user, "<span class='notice'>You activate [src]. It now has <b>[uses]</b> uses of foam remaining.</span>")
	cooldown = world.time + cooldown_time
	power_change()
	addtimer(CALLBACK(src, .proc/power_change), cooldown_time)
