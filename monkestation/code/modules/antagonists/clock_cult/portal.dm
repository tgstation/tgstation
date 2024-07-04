/obj/effect/portal/clockcult
	name = "dimensional anomaly"
	desc = "A dimensional anomaly. It feels warm to the touch, and has a gentle puff of steam emanating from it."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bhole3"
	mech_sized = TRUE
	density = TRUE
	force_teleport = TRUE
	///list of possible targets
	var/static/list/possible_targets

/obj/effect/portal/clockcult/Initialize(mapload, _creator, _lifespan, obj/effect/portal/_linked, automatic_link, turf/hard_target_override)
	. = ..()
	if(!possible_targets)
		possible_targets = list()
		for(var/obj/effect/landmark/late_cog_portals/portal_mark in GLOB.landmarks_list)
			possible_targets += portal_mark

	var/static/times_warned_admins //we spawn a massive amount of these normally so we dont want to warn admins for every single one if something breaks
	if(length(possible_targets))
		hard_target = get_turf(pick(possible_targets))
		return
	else if(!times_warned_admins)
		times_warned_admins = 0
	message_admins("No possible_targets for clock cult portals.")
	times_warned_admins++

/obj/effect/portal/clockcult/Bumped(atom/movable/bumper)
	. = ..()
	teleport(bumper)

/obj/effect/portal/clockcult/teleport(atom/movable/teleported_atom, pull_loop = FALSE)
	if(isliving(teleported_atom))
		if(pull_loop)
			return

		to_chat(teleported_atom, span_notice("You begin climbing into the rift."))
		if(!do_after(teleported_atom, 5 SECONDS, src))
			return

		var/mob/living/teleported_living = teleported_atom
		if(teleported_living.pulling)
			teleport(teleported_living.pulling, TRUE)

		if(teleported_living.client)
			var/client_color = teleported_living.client.color
			teleported_living.client.color = "#BE8700"
			animate(teleported_living.client, color = client_color, time = 2.5 SECONDS)
		var/prev_alpha = teleported_atom.alpha
		teleported_atom.alpha = 0
		animate(teleported_atom, alpha = prev_alpha, time = 1 SECONDS)
	. = ..()
