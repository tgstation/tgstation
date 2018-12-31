/datum/component/grief
	var/mood_event = /datum/mood_event/someone_died
	var/mood_id = "grief"
	var/needs_client = TRUE
	var/grim_ignores = TRUE

/datum/component/grief/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, list(COMSIG_MOB_DEATH), .proc/upset_onlookers)
	RegisterSignal(parent, list(COMSIG_MOB_EMOTE), .proc/check_deathgasp)

/datum/component/grief/proc/check_deathgasp(mob/living/user, datum/emote/E, params, type_override, intentional)
	if(!istype(E, /datum/emote/living/deathgasp))
		return

	var/mob/living/L = parent
	if(L.InCritical())
		upset_onlookers()

/datum/component/grief/proc/upset_onlookers()
	var/mob/living/L = parent
	if(needs_client && !L.client)
		return

	var/list/onlookers = viewers(parent)
	for(var/mob/M in onlookers)
		if(grim_ignores && M.has_trait(TRAIT_GRIM))
			continue
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, mood_id, mood_event)

/datum/component/grief/pet
	needs_client = FALSE
	mood_id = "pet_grief"
	mood_event = /datum/mood_event/pet_died
	grim_ignores = FALSE // Pets are obviously precious to everyone.
