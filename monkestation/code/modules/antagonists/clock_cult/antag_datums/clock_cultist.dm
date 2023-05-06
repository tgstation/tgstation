/datum/antagonist/clock_cultist
	name = "\improper Clock Cultist"
	antagpanel_category = "Clock Cultist"
	preview_outfit = /datum/outfit/clock/preview
	job_rank = ROLE_CLOCK_CULTIST
	antag_moodlet = /datum/mood_event/cult
	suicide_cry = ",r For Ratvar!!!"
	ui_name = "AntagInfoClock"
	/// If this one has access to conversion scriptures
	var/can_convert = TRUE
	/// Ref to the cultist's communication ability
	var/datum/action/innate/clockcult/comm/communicate = new
	/// Ref to the cultist's slab recall ability
	var/datum/action/innate/clockcult/recall_slab/recall = new


/datum/antagonist/clock_cultist/Destroy()
	QDEL_NULL(communicate)
	return ..()


/datum/antagonist/clock_cultist/on_gain()
	. = ..()
	owner.current.playsound_local(get_turf(owner.current), 'sound/magic/clockwork/scripture_tier_up.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)


/datum/antagonist/clock_cultist/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	current.faction |= FACTION_CLOCK
	current.grant_language(/datum/language/ratvar, TRUE, TRUE, LANGUAGE_CULTIST)
	communicate.Grant(current)
	recall.Grant(current)
	RegisterSignal(current, COMSIG_CLOCKWORK_SLAB_USED, PROC_REF(switch_recall_slab))
	current.AddComponent(/datum/component/turf_healing, healing_types = list(TOX = 5), healing_turfs = list(/turf/open/floor/bronze, /turf/open/indestructible/reebe_flooring))


/datum/antagonist/clock_cultist/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	current.faction -= FACTION_CLOCK
	current.remove_language(/datum/language/ratvar, TRUE, TRUE, LANGUAGE_CULTIST)
	communicate.Remove(current)
	recall.Remove(current)
	UnregisterSignal(current, COMSIG_CLOCKWORK_SLAB_USED)
	current.TakeComponent(/datum/component/turf_healing) //I think this is the correct thing to call


/// Change the slab in the recall ability, if it's different from the last one.
/datum/antagonist/clock_cultist/proc/switch_recall_slab(datum/source, obj/item/clockwork/clockwork_slab/slab)
	if(slab == recall.marked_slab)
		return

	recall.unmark_item()
	recall.mark_item(slab)
	to_chat(owner.current, span_brass("You re-attune yourself to a new Clockwork Slab."))


/datum/outfit/clock/preview
	name = "Clock Cultist (Preview only)"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/clockwork
	head = /obj/item/clothing/head/helmet/clockwork
	l_hand = /obj/item/clockwork/weapon/brass_sword


/datum/antagonist/clock_cultist/solo
	name = "Clock Cultist (Solo)"
	can_convert = FALSE
