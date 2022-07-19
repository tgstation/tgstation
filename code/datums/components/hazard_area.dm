/**
 * This is a relatively simple component that attempts to deter the parent of the component away
 * from a specific area or areas. By default it simply applies a penalty where all movement is
 * four times slower than usual and any action that would affect your 'next move' has a penalty
 * multiplier of 4 attached.
 */
/datum/component/hazard_area
	/// The blacklist of areas that the parent will be penalized for entering
	var/list/area_blacklist
	/// The whitelist of areas that the parent is allowed to be in. If set this overrides the blacklist
	var/list/area_whitelist
	/// A list of areas that have been created and are considered to not be hazardous
	var/list/area_created
	/// A variable storing the typepath of the last checked area to prevent any further logic running if it has not changed
	VAR_PRIVATE/last_parent_area

/datum/component/hazard_area/Initialize(area_blacklist, area_whitelist)
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	if(!islist(area_blacklist) && !islist(area_whitelist))
		stack_trace("[type] - neither area_blacklist nor area_whitelist were provided.")
		return COMPONENT_INCOMPATIBLE
	src.area_blacklist = area_blacklist
	src.area_whitelist = area_whitelist
	area_created = new

/datum/component/hazard_area/RegisterWithParent()
	var/mob/parent_mob = parent
	parent_mob.become_area_sensitive(type)
	RegisterSignal(parent_mob, COMSIG_ENTER_AREA, .proc/handle_parent_area_change)
	RegisterSignal(parent_mob, COMSIG_LADDER_TRAVEL, .proc/reject_ladder_movement)
	RegisterSignal(parent_mob, COMSIG_VEHICLE_RIDDEN, .proc/reject_vehicle)
	RegisterSignal(SSdcs, COMSIG_AREA_CREATED, .proc/on_area_creation)

/datum/component/hazard_area/UnregisterFromParent()
	var/mob/parent_mob = parent
	UnregisterSignal(parent_mob, list(COMSIG_ENTER_AREA, COMSIG_LADDER_TRAVEL, COMSIG_VEHICLE_RIDDEN))
	UnregisterSignal(SSdcs, COMSIG_AREA_CREATED)
	parent_mob.lose_area_sensitivity(type)

/datum/component/hazard_area/Destroy(force, silent)
	. = ..()
	area_created = null

/**
 * This signal handler checks the area the target ladder is in and if hazardous prevents them from using it
 */
/datum/component/hazard_area/proc/reject_ladder_movement(mob/source, obj/entrance_ladder, exit_ladder, going_up)
	SIGNAL_HANDLER

	if(check_area_hazardous(get_area(exit_ladder)))
		entrance_ladder.balloon_alert(parent, "the path is too dangerous for you!")
		return LADDER_TRAVEL_BLOCK

/**
 * A simple signal handler that informs the parent they cannot ride a vehicle and ejects them
 */
/datum/component/hazard_area/proc/reject_vehicle(mob/source, obj/vehicle/vehicle)
	SIGNAL_HANDLER

	if(!check_area_hazardous(last_parent_area))
		return

	vehicle.balloon_alert(parent, "you slip and fall off!")
	if(isliving(parent)) // We don't know for certain if we are a mob/living subtype
		var/mob/living/parent_living = parent
		parent_living.Stun(0.5 SECONDS)
	return EJECT_FROM_VEHICLE

/**
 * Checks if the area being checked is considered hazardous
 * The whitelist is checked first if it exists, otherwise it checks if it is in the blacklist
 *
 * * checking - This should be the typepath of the area being checked, but there is a conversion handler if you pass in a reference instead
 */
/datum/component/hazard_area/proc/check_area_hazardous(area/checking)
	if(LAZYFIND(area_created, checking))
		return FALSE
	if(!ispath(checking))
		checking = checking.type
	if(area_whitelist)
		return !(checking in area_whitelist)
	return checking in area_blacklist

/**
 * This signal handler does a few house cleaning tasks when a new area is created.
 * If the created area already exists in the blacklist or whitelist it simply returns,
 * however if it isn't we check for an overwritten area and if non-hazardous setup the area to
 * allow the parent.
 * If there isnt an overwritten area it assumes it to be non-hazardous, abuse it and you will weep -ZephyrTFA
 */
/datum/component/hazard_area/proc/on_area_creation(datum/source, area/created, area/overwritten, mob/creator)
	SIGNAL_HANDLER

	if(created.type in area_whitelist)
		return // in whitelist, probably expanded an already whitelisted area

	if(created.type in area_blacklist)
		return // in blacklist, expanding a blacklisted area doesnt magically give you permission to enter

	if(overwritten)
		if(check_area_hazardous(overwritten.type))
			return // Overwrote a hazardous area, still hazardous fool
		area_created -= overwritten // While its not guaranteed to be in the area_created list it's a good idea to ensure we dont have handing refs
		area_created += created // Congrats, you are now allowed in this area
		return

	// No overwritten area, which means its a brand new area, for now we are going to be nice and assume its non-hazardous
	// If people abuse this in the future to put rooms right next to the station add an is_station_level check
	area_created += created

/**
 * This proc handles the status effect applied to the parent, most noteably applying or removing it as required
 */
/datum/component/hazard_area/proc/update_parent_status_effect()
	if(QDELETED(parent))
		return

	var/mob/living/parent_living = parent
	var/datum/status_effect/hazard_area/effect = parent_living.has_status_effect(/datum/status_effect/hazard_area)
	var/should_have_status_effect = check_area_hazardous(last_parent_area)

	if(should_have_status_effect && !effect) // Should have the status - and doesnt
		parent_living.apply_status_effect(/datum/status_effect/hazard_area)
		if(parent_living.buckled)
			parent_living.buckled.balloon_alert(parent, "you fall off!")
			parent_living.buckled.unbuckle_mob(parent_living, force=TRUE)
		return

	if(!should_have_status_effect && effect) // Shouldn't have the status - and does
		parent_living.remove_status_effect(/datum/status_effect/hazard_area)

/**
 * This signal should be called whenever our parent moves.
 */
/datum/component/hazard_area/proc/handle_parent_area_change(mob/source, area/new_area)
	SIGNAL_HANDLER

	if(new_area.type == last_parent_area)
		return
	last_parent_area = new_area.type

	INVOKE_ASYNC(src, .proc/update_parent_status_effect)

/// The dedicated status effect for the hazard_area component - use with caution and know what it does!
/datum/status_effect/hazard_area
	id = "hazard_area"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/hazard_area

/datum/status_effect/hazard_area/nextmove_modifier()
	return 4

/datum/status_effect/hazard_area/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/hazard_area, update=TRUE)
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/status_effect/hazard_area, update=TRUE)

/datum/status_effect/hazard_area/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/hazard_area, update=TRUE)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/status_effect/hazard_area, update=TRUE)

/datum/status_effect/hazard_area/get_examine_text()
	return span_notice("[owner.p_they(TRUE)] appear[owner.p_s()] to be largely immobilized through unknown means.")

/atom/movable/screen/alert/status_effect/hazard_area
	name = "Hazardous Area"
	desc = "The area you are currently within is incredibly hazardous to you. Check your surroundings and vacate as soon as possible."
	icon_state = "hazard_area"
