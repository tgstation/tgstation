// The station holomap, use it and you get a map of how the pipes should be.

/obj/item/device/holomap
	name = "holomap"
	desc = "Displays the layout of the station's pipe and cable networks."

	icon = 'icons/obj/device.dmi'
	icon_state = "holomap"

	var/list/image/showing = list()
	var/client/viewing // Client that is using the device right now, also determines whether it's on or off.
	//var/datum/delay_controller/delayer
	var/hacked = FALSE
	var/panel  = FALSE

/obj/item/device/holomap/New()
	..()
	//delayer = new(0, ARBITRARILY_LARGE_NUMBER)

/obj/item/device/holomap/Destroy()
	//qdel(delayer)
	//delayer = null

	if (viewing)
		viewing.mob.on_logout.Remove("\ref[src]:mob_logout")

/obj/item/device/holomap/examine(var/mob/M)
	..()
	if (panel)
		to_chat(M, "The panel is open.")

/obj/item/device/holomap/attack_self(var/mob/user)
	if (viewing)
		viewing.images -= showing
		showing.Cut()
		to_chat(user, "You turn off \the [src].")
		viewing.mob.on_logout.Remove("\ref[src]:mob_logout")
		viewing = null
		return

	if (!user.client) // delayer.blocked()
		return

	viewing = user.client
	showing = get_images(get_turf(user), viewing.view)
	viewing.images |= showing
	//delayer.addDelay(2 SECONDS) // Should be enough to prevent lag due to spam.
	user.on_logout.Add(src, "mob_logout")

/obj/item/device/holomap/proc/mob_logout(var/list/args, var/mob/M)
	if (viewing)
		viewing.images -= showing
		viewing = null

	M.on_logout.Remove("\ref[src]:mob_logout")

	visible_message("\The [src] turns off.")
	showing.Cut()

/obj/item/device/holomap/proc/get_images(var/turf/T, var/view)
	. = list()
	for (var/turf/TT in trange(view, T))
		if (TT.holomap_data)
			. += TT.holomap_data

/obj/item/device/holomap/afterattack(var/turf/target, var/mob/user, var/proximity_flag, var/click_parameters)
	if (!hacked)
		return

	if (!isturf(target))
		target = get_turf(target)

	if (target.holomap_data)
		target.holomap_data.Cut()

	for (var/obj/O in target)
		if (O.holomap)
			target.add_holomap(O)

	to_chat(user, "You reset the holomap data.")

/obj/item/device/holomap/attackby(obj/item/W, mob/user)
	if (isscrewdriver(W))
		panel = !panel
		to_chat(user, "<span class='notify'>You [panel ? "open" : "close"] the panel on \the [src].</span>")
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
		return 1

	if (ismultitool(W) && panel)
		hacked = !hacked
		to_chat(user, "<span class='notify'>You [hacked ? "disable" : "enable"] the lock on \the [src].</span>")
		return 1

	. = ..()
