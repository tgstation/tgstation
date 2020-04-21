/*
	Limping is a component to be attached to carbons for when they have a disparity in leg speed (such as when one of your legs is grievously wounded), so that one step has
	a longer delay than the other. This is handled as a component rather than being inherent in bodypart code so that we're not constantly tracking footsteps if we don't need to

	TODO: handle both legs being crippled
*/

/datum/component/limp
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/obj/item/bodypart/l_leg/left
	var/obj/item/bodypart/r_leg/right
	var/obj/item/bodypart/next_leg
	var/slowdown_left = 0
	var/slowdown_right = 0
	var/initialized

/datum/component/limp/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/carbon/C = parent

	left = C.get_bodypart(BODY_ZONE_L_LEG)
	right = C.get_bodypart(BODY_ZONE_R_LEG)
	update_limp()

	if(!initialized)
		to_chat(C, "<span class='notice'>You feel a limp!</span>")
		initialized = TRUE

/datum/component/limp/Destroy(force, silent)
	left = null
	right = null
	if(!silent)
		to_chat(parent, "<span class='notice'>Your walking becomes more regular.</span>")
	return ..()

/datum/component/limp/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_limp)
	RegisterSignal(parent, list(COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_LOSE_WOUND, COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB), .proc/update_limp)

/datum/component/limp/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_LOSE_WOUND, COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB, COMSIG_MOVABLE_MOVED))

/datum/component/limp/proc/update_limp()
	if(!left && !right)
		qdel(src)
		return

	slowdown_left = 0
	slowdown_right = 0

	for(var/thing in left.wounds)
		var/datum/wound/W = thing
		slowdown_left += W.limp_slowdown

	for(var/thing in right.wounds)
		var/datum/wound/W = thing
		slowdown_right += W.limp_slowdown

	testing("Limp slowdowns: [slowdown_left]/[slowdown_right]")

/// Take a step, apply limp cooldown to our move delay if that leg is gimped
/datum/component/limp/proc/check_limp(mob/living/carbon/owner)
	if(!owner.client || (owner.mobility_flags & ~MOBILITY_STAND))
		return
	if(next_leg == left)
		owner.client.move_delay += slowdown_left
		next_leg = right
	else
		owner.client.move_delay += slowdown_right
		next_leg = left

