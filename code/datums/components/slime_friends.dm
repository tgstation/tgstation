/datum/component/slime_friends
	/// Slime maker timer.
	var/timer
	/// List to pick from when we need slime colour.
	var/static/colours = list(
		/datum/slime_type/adamantine,
		/datum/slime_type/black,
		/datum/slime_type/blue,
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
		/datum/slime_type/orange,
		/datum/slime_type/pink,
		/datum/slime_type/purple,
		/datum/slime_type/pyrite,
		/datum/slime_type/rainbow,
		/datum/slime_type/red,
		/datum/slime_type/sepia,
		/datum/slime_type/silver,
		/datum/slime_type/yellow,
	)

/datum/component/slime_friends/Initialize(...)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/living_parent = parent
	living_parent.faction |= FACTION_SLIME
	RegisterSignal(living_parent, COMSIG_ENTER_AREA, PROC_REF(start_slime_prodaction))

/datum/component/slime_friends/Destroy(force)
	. = ..()
	var/mob/living/living_parent = parent
	living_parent.faction -= FACTION_SLIME
	timer = null

/// Start slime prodaction when we leave wizden.
/datum/component/slime_friends/proc/start_slime_prodaction(mob/living/friend, area/new_area)
	if(new_area == GLOB.areas_by_type[/area/centcom/wizard_station])
		return
	timer = addtimer(CALLBACK(src, PROC_REF(make_slime_friend), friend), 20 SECONDS)
	UnregisterSignal(friend, COMSIG_ENTER_AREA)

/// Slime prodactor proc.
/datum/component/slime_friends/proc/make_slime_friend(mob/living/friend)
	timer = addtimer(CALLBACK(src, PROC_REF(make_slime_friend), friend), 20 SECONDS)
	if(get_area(friend) == GLOB.areas_by_type[/area/centcom/wizard_station])
		return
	var/turf/where = get_turf(friend)
	var/new_colour = pick(colours)
	var/mob/living/basic/slime/new_friend = new(where, new_colour, SLIME_LIFE_STAGE_ADULT)
	new_friend.faction = friend.faction.Copy()
	new_friend.set_enraged_behaviour()
	friend.nutrition -= 50
