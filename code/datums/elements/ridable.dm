
/datum/component/ridable
	var/last_vehicle_move = 0 //used for move delays
	var/last_move_diagonal = FALSE
	var/vehicle_move_delay = 2 //tick delay between movements, lower = faster, higher = slower
	var/keytype

	var/slowed = FALSE
	var/slowvalue = 1

	///Bool to check if you gain the ridden mob's abilities.
	var/can_use_abilities = FALSE

	var/list/riding_offsets = list()	//position_of_user = list(dir = list(px, py)), or RIDING_OFFSET_ALL for a generic one.
	var/list/directional_vehicle_layers = list()	//["[DIRECTION]"] = layer. Don't set it for a direction for default, set a direction to null for no change.
	var/list/directional_vehicle_offsets = list()	//same as above but instead of layer you have a list(px, py)
	var/list/allowed_turf_typecache
	var/list/forbid_turf_typecache					//allow typecache for only certain turfs, forbid to allow all but those. allow only certain turfs will take precedence.
	var/allow_one_away_from_valid_turf = TRUE		//allow moving one tile away from a valid turf but not more.
	var/override_allow_spacemove = FALSE
	var/drive_verb = "drive"
	/// If we should delete this component when we have nothing left buckled, used for buckling to mobs
	var/del_on_unbuckle_all = FALSE
	/// If the "vehicle" is a mob, respect MOBILITY_MOVE on said mob.
	var/respect_mob_mobility = TRUE

	/// If the rider needs hands free in order to not fall off (fails if they're incap'd or restrained)
	var/rider_holding_on = FALSE
	/// If the ridden needs a hand free to carry the rider (fails if they're incap'd or restrained)
	var/ridden_holding_rider = FALSE


/datum/component/ridable/Initialize(riding_flags, mob/living/riding_mob)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOVABLE_TRY_MOUNTING, .proc/check_mounting)
	RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, .proc/check_unmounting)


/datum/component/ridable/proc/check_unmounting(datum/source, mob/living/rider, force = FALSE)


/datum/component/ridable/proc/check_mounting(datum/source, mob/living/potential_rider, force = FALSE, riding_flags = NONE)
	SIGNAL_HANDLER

	if((riding_flags & RIDING_RIDER_HOLDING_ON) && !equip_buckle_inhands(potential_rider, 2)) // hardcode 2 hands for now
		potential_rider.visible_message("<span class='warning'>[potential_rider] can't get a grip on [parent_movable] because [potential_rider.p_their()] hands are full!</span>",
			"<span class='warning'>You can't get a grip on [parent_movable] because your hands are full!</span>")
		return MOUNTING_HALT_BUCKLE


	var/mob/living/parent_living = parent

	// need to see if !equip_buckle_inhands() checks are enough to skip any needed incapac/restrain checks
	// ridden_holding_rider shouldn't apply if the ridden isn't even a living mob
	if((riding_flags & RIDING_RIDDEN_HOLD_RIDER) && !equip_buckle_inhands(parent_living, 1, potential_rider)) // hardcode 1 hand for now
		parent_living.visible_message("<span class='warning'>[parent_living] can't get a grip on [potential_rider] because [parent_living.p_their()] hands are full!</span>",
			"<span class='warning'>You can't get a grip on [potential_rider] because your hands are full!</span>")
		return MOUNTING_HALT_BUCKLE

	parent.AddComponent(/datum/component/riding, potential_rider, force, riding_flags)
