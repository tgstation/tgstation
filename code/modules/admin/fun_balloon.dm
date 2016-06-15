/obj/effect/fun_balloon
	name = "fun balloon"
	desc = "This is going to be a laugh riot."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	anchored = TRUE

/obj/effect/fun_balloon/New()
	. = ..()
	SSobj.processing |= src

/obj/effect/fun_balloon/Destroy()
	SSobj.processing -= src
	. = ..()

/obj/effect/fun_balloon/process()
	if(check())
		pop()
		visible_message("[src] pops!")
		playsound(get_turf(src), 'sound/items/party_horn.ogg', 50, 1, -1)
		qdel(src)

/obj/effect/fun_balloon/proc/check()
	return TRUE

/obj/effect/fun_balloon/proc/pop()
	return

/obj/effect/fun_balloon/sentience
	name = "sentience fun balloon"
	desc = "When this pops, things are gonna get more aware around here."
	var/effect_range = 3
	var/group_name = "a bunch of giant spiders"

/obj/effect/fun_balloon/sentience/pop()
	var/list/bodies = list()
	for(var/mob/living/M in range(effect_range, get_turf(src)))
		bodies += M

	var/question = "Would you like to be [group_name]?"
	var/list/candidates = pollCandidates(question, "pAI", null, FALSE, 100)
	while(candidates.len && bodies.len)
		var/mob/dead/observer/ghost = pick_n_take(candidates)
		var/mob/living/body = pick_n_take(bodies)

		body << "Your mob has been taken over by a ghost!"
		message_admins("[key_name_admin(ghost)] has taken control \
			of ([key_name_admin(body)])")
		body.ghostize(0)
		body.key = ghost.key
		new /obj/effect/overlay/sparkle(null, body)

/obj/effect/fun_balloon/sentience/emergency_shuttle
	name = "shuttle sentience fun balloon"
	var/trigger_time = 60

/obj/effect/fun_balloon/sentience/emergency_shuttle/check()
	. = FALSE
	if(SSshuttle.emergency && (SSshuttle.emergency.timeLeft() <= trigger_time) && (SSshuttle.emergency.mode == SHUTTLE_CALL))
		. = TRUE

/obj/effect/overlay/sparkle
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	mouse_opacity = 0
	density = 0
	var/lifetime = 10

/obj/effect/overlay/sparkle/New(atom/movable/AM)
	. = ..(null)
	AM.overlays += src
	addtimer(src, "expire", lifetime, FALSE, AM)

/obj/effect/overlay/sparkle/proc/expire(atom/movable/AM)
	AM.overlays -= src
	qdel(src)

/obj/effect/overlay/sparkle/tailsweep
	icon_state = "tailsweep"
