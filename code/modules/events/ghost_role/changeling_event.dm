/*
* Changeling event. Takes a ghost volunteer and stuffs them into a changeling with some randomly generated identities.
* They arrive via a meateor, which collides with the station. They are expected to find their own way into the station.
*
*/


/datum/round_event_control/changeling
	name = "Changeling Meteor"
	typepath = /datum/round_event/ghost_role/changeling
	weight = 8
	max_occurrences = 3
	min_players = 20
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_INVASION
	description = "A ghost is placed inside of a changeling meteor and hurled at the station"

/datum/round_event/ghost_role/changeling
	minimum_required = 1
	role_name = "changeling"
	fakeable = FALSE // No announcement is made, nothing to announce.

/datum/round_event/ghost_role/changeling/spawn_role()
	var/list/mob/dead/observer/candidate = get_candidates(ROLE_CHANGELING, ROLE_CHANGELING) //Change to midround changeling when you get that shit figured out

	if(!candidate.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = make_body(pick_n_take(candidate)) //Grab the selected player's mind
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/start_side = pick(GLOB.cardinals) //Select our starting turf
	var/start_z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
	var/turf/picked_start = spaceDebrisStartLoc(start_side, start_z)
	var/turf/picked_end = spaceDebrisFinishLoc(start_side, start_z)

	var/obj/effect/meteor/changeling/changeling_meteor = new/obj/effect/meteor/changeling(picked_start, picked_end)

	var/mob/living/carbon/human/new_changeling = new /mob/living/carbon/human/(picked_start)

	new_changeling.forceMove(changeling_meteor)

	player_mind.transfer_to(new_changeling)
	player_mind.special_role = ROLE_CHANGELING_MIDROUND
	player_mind.add_antag_datum(/datum/antagonist/changeling)
	SEND_SOUND(new_changeling, sound('sound/magic/mutate.ogg'))
	message_admins("[ADMIN_LOOKUPFLW(new_changeling)] has been made into a changeling by an event.")
	new_changeling.log_message("was spawned as a midround changeling by an event.", LOG_GAME)
	spawned_mobs += new_changeling
	return SUCCESSFUL_SPAWN
/obj/effect/meteor/changeling
	name = "unsettlingly meaty meteor"
	desc = "A tightly packed knit of flesh and skin. Did it just move?"
	icon = 'icons/obj/meteor.dmi' //oh you KNOW we need a sprite for this bad boy
	hits = 1 //Instant impact explosion
	hitpwr = EXPLODE_LIGHT
	meteorsound = 'sound/effects/meteorimpact.ogg' //replace with splat sfx
	threat = 100
	meteordrop = list(/obj/item/stack/ore/iron) //MEAT
	dropamt = 4
	signature = "biological lifesign"
