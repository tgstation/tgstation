/*
* Changeling midround spawn event. Takes a ghost volunteer and stuffs them into a changeling with their own identity and a flesh space suit.
* They arrive via a meateor, which collides with the station. They are expected to find their own way into the station by whatever means necessary.
* The midround changeling experience is, by nature, more difficult than playing as a roundstart crew changeling.
*
*/

/datum/round_event_control/changeling
	name = "Changeling Meteor"
	typepath = /datum/round_event/ghost_role/changeling
	weight = 8
	max_occurrences = 3
	min_players = 20
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "A meteor containing a changeling is summoned and thrown at the exterior of the station."

/datum/round_event/ghost_role/changeling
	minimum_required = 1
	role_name = "space changeling"
	fakeable = FALSE

/datum/round_event/ghost_role/changeling/spawn_role()
	var/list/mob/dead/observer/candidate = SSpolling.poll_ghost_candidates(check_jobban = ROLE_CHANGELING, role = ROLE_CHANGELING_MIDROUND, pic_source = /obj/item/melee/arm_blade, role_name_text = role_name)

	if(!candidate.len)
		return NOT_ENOUGH_PLAYERS

	spawned_mobs += generate_changeling_meteor(pick_n_take(candidate))

	if(spawned_mobs)
		return SUCCESSFUL_SPAWN
