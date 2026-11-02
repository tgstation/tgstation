/// Ratwood's far travel (modular_azurepeak structures/fartravel.dm), the round's way out: one drags their own sprite onto the
/// tile, or a body that has no player in it, and after a short wait leaves the round for good. Their role and class free a
/// place again for someone else (the module's Back to Lobby, admin/rogue_admin.dm) and the body is gone with all it carried.
/obj/structure/far_travel
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// Someone is already on their way out through it.
	var/in_use = FALSE

/obj/structure/far_travel/mouse_drop_receive(atom/dropped, mob/user, params)
	. = ..()
	if(!isliving(user) || user.incapacitated || !ishuman(dropped) || in_use)
		return
	var/mob/living/carbon/human/departing = dropped
	if(departing != user && departing.client)
		to_chat(user, span_warning("This one retains their free will. It's their choice if they want to leave the round or not."))
		return
	if(departing.stat == DEAD && !departing.client)
		to_chat(user, span_warning("This one is long dead and has passed unto another place. They have already left."))
		return
	INVOKE_ASYNC(src, PROC_REF(try_send_away), departing, user)

/// The name of the land one leaves (Ratwood SSticker.realm_name): the map's own.
/obj/structure/far_travel/proc/realm_name()
	return SSmapping.current_map?.map_name || "the realm"

/// Whether the departure may still go on after a wait: both still here, near, able, and the one sent away still has no say.
/obj/structure/far_travel/proc/can_send_away(mob/living/carbon/human/departing, mob/living/user)
	if(QDELETED(src) || QDELETED(departing) || QDELETED(user) || user.incapacitated)
		return FALSE
	if(departing != user && departing.client)
		return FALSE
	var/range = rogue_value("far_travel_range")
	return get_dist(src, departing) <= range && get_dist(src, user) <= range

/obj/structure/far_travel/proc/try_send_away(mob/living/carbon/human/departing, mob/living/user)
	var/self = departing == user
	if(tgui_alert(user, "Are you sure you want to [self ? "depart the round for good (you" : "send this person away (they"] will be removed from the current round, the job slot freed)?", "Departing", list("Confirm", "Cancel")) != "Confirm")
		return
	if(in_use || !can_send_away(departing, user))
		return
	user.visible_message(span_warning("[user] [self ? "is trying to depart from [realm_name()]!" : "is trying to send [departing] away!"]"), span_notice("You [self ? "are trying to depart from [realm_name()]." : "are trying to send [departing] away."]"))
	in_use = TRUE
	var/waited = do_after(user, rogue_value("far_travel_time"), target = src)
	in_use = FALSE
	if(!waited || !can_send_away(departing, user))
		return
	send_away(departing, user)

/// Ratwood's departure: the admins are told who left and what went with them, bounties on them are struck, and the player
/// goes to the lobby while the body is deleted.
/obj/structure/far_travel/proc/send_away(mob/living/carbon/human/departing, mob/living/user)
	var/list/carried = list()
	for(var/atom/movable/thing as anything in departing.contents)
		if(!isbodypart(thing) && !isorgan(thing))
			carried += thing.name
	var/report = "[key_name(user)] has despawned [departing == user ? "themselves" : key_name(departing)], job [departing.job], at [AREACOORD(src)]. Contents despawned along: [length(carried) ? "[jointext(carried, ", ")]." : "none."]"
	message_admins(report)
	log_admin(report)
	for(var/datum/rogue_bounty/bounty as anything in GLOB.rogue_head_bounties)
		if(bounty.target == departing.real_name)
			GLOB.rogue_head_bounties -= bounty
	if(departing.stat == DEAD)
		departing.visible_message(span_notice("[user] sends the body of [departing] away. They're someone else's problem now."))
	else
		departing.visible_message(span_notice("[departing == user ? "Out of their own volition, " : "Ushered by [user], "][departing] leaves [realm_name()]."))
	if(departing.ckey)
		rogue_send_back_to_lobby(departing, delete_body = TRUE)
		return
	// A body its player left as a ghost keeps its mind: the role is freed all the same, as Ratwood does.
	free_role(departing)
	qdel(departing)

/// The place in the round that the body's role and class held, given back (rogue_send_back_to_lobby() for a body with no player).
/obj/structure/far_travel/proc/free_role(mob/living/carbon/human/departing)
	if(!departing.mind)
		return
	var/datum/job/job = departing.mind.assigned_role
	if(job && !istype(job, /datum/job/unassigned))
		job.current_positions = max(0, job.current_positions - 1)
	if(departing.rockhill_advclass)
		departing.rockhill_advclass.taken = max(0, departing.rockhill_advclass.taken - 1)
	GLOB.manifest.remove(departing.real_name)
	departing.mind.rogue_leave_acquaintances()
