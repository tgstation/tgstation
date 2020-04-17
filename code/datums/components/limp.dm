/*
	Limping is a component to be attached to carbons for when they have a disparity in leg speed (such as when one of your legs is grievously wounded), so that one step has
	a longer delay than the other. This is handled as a component rather than being inherent in bodypart code so that we're not constantly tracking footsteps if we don't need to

	TODO: handle both legs being crippled
*/

/datum/component/limp
	dupe_mode = COMPONENT_DUPE_HIGHLANDER

	var/obj/item/bodypart/l_leg/left
	var/obj/item/bodypart/r_leg/right
	var/additional_slowdown = 0
	var/obj/item/bodypart/next_leg
	var/slowdown_left = 0
	var/slowdown_right = 0

/datum/component/limp/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/carbon/C = parent
	testing("[C] is limping")

	left = C.get_bodypart(BODY_ZONE_L_LEG)
	right = C.get_bodypart(BODY_ZONE_R_LEG)
	update_limp()

	to_chat(C, "<span class='notice'>You feel a limp!</span>")


/datum/component/limp/Destroy(force, silent)
	left = null
	right = null
	to_chat(parent, "<span class='notice'>Your walking becomes more regular.</span>")
	return ..()

/datum/component/limp/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_limp)
	//RegisterSignal(parent, COMSIG_CARBON_ADD_WOUND, .proc/suffer_wound)
	//RegisterSignal(parent, COMSIG_CARBON_REMOVE_WOUND, .proc/relieve_wound)
	//RegisterSignal(parent, COMSIG_CARBON_GAIN_BODYPART, .proc/check_added_part)
	//RegisterSignal(parent, COMSIG_CARBON_LOSE_BODYPART, .proc/check_removed_part)

/datum/component/limp/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_CARBON_ADD_WOUND, COMSIG_CARBON_REMOVE_WOUND, COMSIG_MOVABLE_MOVED))

/datum/component/limp/proc/update_limp()
	for(var/wo in left.wounds)
		var/datum/wound/W = wo
		slowdown_left += W.limp_slowdown

	for(var/wo in right.wounds)
		var/datum/wound/W = wo
		slowdown_right += W.limp_slowdown

	testing("Limp slowdowns: [slowdown_left]/[slowdown_right]")

/datum/component/limp/proc/check_limp(mob/living/carbon/owner)
	if(!owner.client)
		return
	if(next_leg == left)
		owner.client.move_delay += slowdown_left
		next_leg = right
	else
		owner.client.move_delay += slowdown_right
		next_leg = left

///datum/component/limp/proc/check_added_part(mob/living/carbon/owner, obj/item/bodypart/limb)
	//if(limb == left)

// can't limp if you only got one leg
/datum/component/limp/proc/check_removed_part(mob/living/carbon/owner, obj/item/bodypart/limb, dismembered)
	if(limb == left || limb == right)
		qdel(src)
