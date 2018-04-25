/datum/component/bluespace_hand
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/range = 7 //Default human vision range.
	var/list/hand_indices = list()

/datum/component/bluespace_hand/Initialize()
	if(!ishuman(parent))
		. = COMPONENT_INCOMPATIBLE
		CRASH("Bluespace hand component attempted to be applied to a nonhuman!")
	RegisterSignal(COMSIG_HUMAN_RANGED_ATTACK, .proc/Pickup)
	RegisterSignal(COMSIG_CARBON_THROW_ITEM, .proc/Place)

/datum/component/bluespace_hand/proc/Pickup(atom/target)
	var/mob/living/carbon/human/H = parent
	if(!(H.active_hand_index in hand_indices))
		return
	var/obj/item/I = target
	if(!istype(I))
		return
	if(get_dist(H, I) > range)
		return
	if(H.can_put_in_hand(I, H.active_hand_index) && !I.anchored)
		playsound(H, 'sound/items/pshoom.ogg', 40, 1)
		H.Beam(I,icon_state = "rped_upgrade", time=5)
		H.put_in_active_hand(I)

/datum/component/bluespace_hand/proc/Place(obj/item/I, atom/target)
	var/mob/living/carbon/human/H = parent
	if(!(H.active_hand_index in hand_indices))
		return
	if(get_dist(H, target) > range)
		return
	if(!H.dropItemToGround(I))
		return
	I.forceMove(get_turf(target))
	playsound(H, 'sound/items/pshoom.ogg', 40, 1)
	H.Beam(I, icon_state = "rped_upgrade", time=5)
	return COMPONENT_STOP_THROW
