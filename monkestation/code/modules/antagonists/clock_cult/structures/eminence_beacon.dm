/obj/structure/destructible/clockwork/eminence_beacon
	name = "Eminence Spire"
	desc = "An ancient, brass spire which holds the spirit of a powerful entity conceived by Rat'var to oversee his faithful servants."
	icon_state = "tinkerers_daemon"
	resistance_flags = INDESTRUCTIBLE
	///are we currently holding a vote for an eminence
	var/vote_active = FALSE
	///weakref to our vote timer
	var/datum/weakref/vote_timer

/obj/structure/destructible/clockwork/eminence_beacon/attack_hand(mob/user)
	. = ..()
	if(!IS_CLOCK(user))
		return
	if(vote_active)
		if(vote_timer)
			deltimer(vote_timer?.resolve())
			vote_timer = null
		vote_active = FALSE
		send_clock_message(null, "[user] has cancelled the Eminence vote.")
		return
	if(GLOB.current_eminence)
		to_chat(user, span_brass("The Eminence has already been released."))
		return

	var/option = tgui_alert(user, "Becoming the Eminence is not an easy task, be sure you will be able to lead the servants. \
								   If you choose to do so, your old form with be destroyed.", "Who shall control the Eminence?", list("Yourself", "A ghost", "Cancel"))
	if(option == "Yourself")
		send_clock_message(null, span_bigbrass("[user] has elected themselves to become the Eminence. Interact with \the [src] to object."))
		vote_timer = WEAKREF(addtimer(CALLBACK(src, PROC_REF(vote_succeed), user), 60 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE))
	else if(option == "A ghost")
		send_clock_message(null, span_bigbrass("[user] has elected for a ghost to become the Eminence. Interact with \the [src] to object."))
		vote_timer = WEAKREF(addtimer(CALLBACK(src, PROC_REF(vote_succeed)), 60 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE))
	else
		return
	vote_active = TRUE

/obj/structure/destructible/clockwork/eminence_beacon/proc/vote_succeed(mob/living/eminence) //if we select a ghost then we dont call any living procs so this is fine
	vote_active = FALSE
	if(GLOB.current_eminence)
		message_admins("[type] calling vote_succeed() with a set GLOB.current_eminence, this should not be happening.")
		return

	if(!eminence)
		var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
			"Do you want to play as the eminence",
			check_jobban = ROLE_CLOCK_CULTIST,
			role = ROLE_CLOCK_CULTIST,
			poll_time = 10 SECONDS,
			alert_pic = /mob/living/eminence,
			role_name_text = "eminence"
		)
		if(length(candidates))
			eminence = pick(candidates)

	if(!(eminence?.client))
		send_clock_message(null, "The Eminence remains in slumber, for now, try waking it again soon.")
		return

	var/mob/living/eminence/new_mob = new /mob/living/eminence(get_turf(src))
	if(isobserver(eminence))
		new_mob.key = eminence.key
	else
		var/datum/antagonist/clock_cultist/servant_datum = eminence.mind.has_antag_datum(/datum/antagonist/clock_cultist)
		if(servant_datum)
			servant_datum.silent = TRUE
			servant_datum.on_removal()
		eminence.mind.transfer_to(new_mob, TRUE)
		eminence.dust(TRUE, TRUE)
	new_mob.mind.add_antag_datum(/datum/antagonist/clock_cultist/eminence)
	send_clock_message(null, span_bigbrass("The Eminence has risen!"))
