/datum/component/slime_friends
	var/timer

/datum/component/slime_friends/Initialize(...)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/living_parent = parent
	living_parent.faction |= FACTION_SLIME
	timer = addtimer(CALLBACK(src, PROC_REF(make_slime_friend), living_parent), 20 SECONDS)

/datum/component/slime_friends/Destroy(force)
	. = ..()
	var/mob/living/living_parent = parent
	living_parent.faction -= FACTION_SLIME
	living_parent.mob_biotypes -= MOB_SLIME
	timer = null

/datum/component/slime_friends/proc/make_slime_friend(mob/living/friend)
	if(get_area(friend) == GLOB.areas_by_type[/area/centcom/wizard_station])
		timer = addtimer(CALLBACK(src, PROC_REF(make_slime_friend), friend), 20 SECONDS)
		return
	var/turf/where = get_turf(friend)
	var/new_colour = pick(
	/datum/slime_type/adamantine,
	/datum/slime_type/black,
	/datum/slime_type/blue,
	/datum/slime_type/red,
	/datum/slime_type/orange,
	/datum/slime_type/bluespace,
	/datum/slime_type/cerulean,
	/datum/slime_type/darkblue,
	/datum/slime_type/darkpurple,
	/datum/slime_type/gold,
	/datum/slime_type/green,
	/datum/slime_type/grey,
	/datum/slime_type/lightpink,
	/datum/slime_type/metal,
	/datum/slime_type/oil,
	/datum/slime_type/pink,
	/datum/slime_type/purple,
	/datum/slime_type/pyrite,
	/datum/slime_type/rainbow,
	/datum/slime_type/sepia,
	/datum/slime_type/silver,
	/datum/slime_type/yellow)
	var/mob/living/basic/slime/new_friend = new(where, new_colour, SLIME_LIFE_STAGE_ADULT)
	new_friend.faction = friend.faction
	new_friend.set_enraged_behaviour()
	friend.nutrition -= 50
	timer = addtimer(CALLBACK(src, PROC_REF(make_slime_friend), friend), 20 SECONDS)
