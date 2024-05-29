///Telekinesis lets you interact with objects from range, and gives you a light blue halo around your head.
/datum/mutation/human/telekinesis
	name = "Telekinesis"
	desc = "A strange mutation that allows the holder to interact with objects through thought."
	quality = POSITIVE
	difficulty = 18
	text_gain_indication = "<span class='notice'>You feel smarter!</span>"
	limb_req = BODY_ZONE_HEAD
	instability = 30
	///Typecache of atoms that TK shouldn't interact with
	var/static/list/blacklisted_atoms = typecacheof(list(/atom/movable/screen))

/datum/mutation/human/telekinesis/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/mob/effects/genetics.dmi', "telekinesishead", -MUTATIONS_LAYER))

/datum/mutation/human/telekinesis/on_acquiring(mob/living/carbon/human/H)
	. = ..()
	if(.)
		return
	RegisterSignal(H, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_ranged_attack))

/datum/mutation/human/telekinesis/on_losing(mob/living/carbon/human/H)
	. = ..()
	if(.)
		return
	UnregisterSignal(H, COMSIG_MOB_ATTACK_RANGED)

/datum/mutation/human/telekinesis/get_visual_indicator()
	return visual_indicators[type][1]

///Triggers on COMSIG_MOB_ATTACK_RANGED. Usually handles stuff like picking up items at range.
/datum/mutation/human/telekinesis/proc/on_ranged_attack(mob/source, atom/target)
	SIGNAL_HANDLER
	if(is_type_in_typecache(target, blacklisted_atoms))
		return
	if(!tkMaxRangeCheck(source, target) || source.z != target.z)
		return
	return target.attack_tk(source)

/datum/mutation/human/elastic_arms
	name = "Elastic Arms"
	desc = "Subject's arms have become elastic, allowing them to stretch up to a meter away. However, this elasticity makes it difficult to wear gloves or handle complex tasks."
	quality = POSITIVE
	instability = 30
	text_gain_indication = "<span class='warning'>You feel armstrong!.</span>"
	text_lose_indication = "<span class='notice'>Your arms stop being so saggy all the time.</span>"
	difficulty = 32

/datum/mutation/human/elastic_arms/on_acquiring(mob/living/carbon/human/H)
	. = ..()
	if(.)
		return
	RegisterSignal(H, COMSIG_ATOM_CANREACH, PROC_REF(on_canreach))

/datum/mutation/human/elastic_arms/on_losing(mob/living/carbon/human/H)
	. = ..()
	if(.)
		return
	UnregisterSignal(H, COMSIG_ATOM_CANREACH)

/datum/mutation/human/elastic_arms/proc/on_canreach(mob/source, atom/target)
	SIGNAL_HANDLER

	var/distance = get_dist(target, source)

	if(distance > 2 || source.z != target.z)
		return

	if(distance < 2)
		return COMPONENT_ALLOW_REACH

	var/direction = get_dir(source, target)
	if(!direction)
		return
	var/turf/open/adjacent_turf = get_step(source, direction)

	if(!istype(adjacent_turf))
		return

	for(var/atom/thing in adjacent_turf)
		if(thing.density)
			return

	return COMPONENT_ALLOW_REACH
