/obj/machinery/ai_slipper
	name = "\improper AI liquid dispenser"
	icon = 'icons/obj/device.dmi'
	icon_state = "ai-slipper0"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	anchored = 1
	obj_integrity = 200
	max_integrity = 200
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 30)

	var/uses = 20
	var/disabled = 1
	var/lethal = 0
	var/locked = 1
	var/cooldown_time = 0
	var/cooldown_timeleft = 0
	var/cooldown_on = 0
	req_access = list(access_ai_upload)

/obj/machinery/ai_slipper/power_change()
	if(stat & BROKEN)
		return
	else
		if( powered() )
			stat &= ~NOPOWER
		else
			icon_state = "ai-slipper0"
			stat |= NOPOWER

/obj/machinery/ai_slipper/proc/setState(enabled, uses)
	src.disabled = disabled
	src.uses = uses
	src.power_change()

/obj/machinery/ai_slipper/attackby(obj/item/weapon/W, mob/user, params)
	if(stat & (NOPOWER|BROKEN))
		return
	if (issilicon(user))
		return src.attack_hand(user)
	else // trying to unlock the interface
		if (src.allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the device.</span>")
			if (locked)
				if (user.machine==src)
					user.unset_machine()
					user << browse(null, "window=ai_slipper")
			else
				if (user.machine==src)
					src.attack_hand(user)
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")


/obj/machinery/ai_slipper/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/ai_slipper/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if ( (get_dist(src, user) > 1 ))
		if (!(issilicon(user) || IsAdminGhost(user)))
			to_chat(user, text("Too far away."))
			user.unset_machine()
			user << browse(null, "window=ai_slipper")
			return

	user.set_machine(src)
	var/area/A = get_area(src)
	var/t = "<TT><B>AI Liquid Dispenser</B> ([format_text(A.name)])<HR>"

	if(locked && (!(issilicon(user) || IsAdminGhost(user))))
		t += "<I>(Swipe ID card to unlock control panel.)</I><BR>"
	else
		t += "Dispenser [disabled?"deactivated":"activated"] - <A href='?src=\ref[src];toggleOn=1'>[disabled?"Enable":"Disable"]?</a><br>\n"
		t += "Uses Left: [uses]. <A href='?src=\ref[src];toggleUse=1'>Activate the dispenser?</A><br>\n"
	user << browse(t, "window=computer;size=575x450")
	onclose(user, "computer")

/obj/machinery/ai_slipper/Topic(href, href_list)
	if(..())
		return
	if (src.locked)
		if(!(issilicon(usr)|| IsAdminGhost(usr)))
			to_chat(usr, "Control panel is locked!")
			return
	if (href_list["toggleOn"])
		src.disabled = !src.disabled
		icon_state = src.disabled? "ai-slipper0":"ai-slipper1"
	if (href_list["toggleUse"])
		if(cooldown_on || disabled)
			return
		else
			new /obj/effect/particle_effect/foam(loc)
			src.uses--
			cooldown_on = 1
			cooldown_time = world.timeofday + 100
			slip_process()
			return

	src.attack_hand(usr)

/obj/machinery/ai_slipper/proc/slip_process()
	while(cooldown_time - world.timeofday > 0)
		var/ticksleft = cooldown_time - world.timeofday

		if(ticksleft > 1e5)
			cooldown_time = world.timeofday + 10	// midnight rollover


		cooldown_timeleft = (ticksleft / 10)
		sleep(5)
	if (uses <= 0)
		return
	if (uses >= 0)
		cooldown_on = 0
	src.power_change()
