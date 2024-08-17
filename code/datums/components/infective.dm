/datum/component/infective
	var/list/datum/disease/diseases //make sure these are the static, non-processing versions!
	var/expire_time
	var/required_clean_types = CLEAN_TYPE_DISEASE
	/// The infection is weak and can only infect on consumption with small chance
	var/is_weak = FALSE
	/// Chance of weak infection on consumption
	var/weak_infection_chance = 10


/datum/component/infective/Initialize(list/datum/disease/_diseases, expire_in, weak = FALSE)
	if(islist(_diseases))
		diseases = _diseases
	else
		diseases = list(_diseases)
	if(expire_in)
		expire_time = world.time + expire_in
		QDEL_IN(src, expire_in)

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	is_weak = weak

	if(is_weak && isitem(parent))
		RegisterSignal(parent, COMSIG_FOOD_EATEN, PROC_REF(try_infect_eat))
		RegisterSignal(parent, COMSIG_PILL_CONSUMED, PROC_REF(try_infect_eat))
	else
		var/static/list/disease_connections = list(
			COMSIG_ATOM_ENTERED = PROC_REF(try_infect_crossed),
		)
		AddComponent(/datum/component/connect_loc_behalf, parent, disease_connections)

		RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean))
		RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, PROC_REF(try_infect_buckle))
		RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(try_infect_collide))
		RegisterSignal(parent, COMSIG_MOVABLE_IMPACT_ZONE, PROC_REF(try_infect_impact_zone))
		if(isitem(parent))
			RegisterSignal(parent, COMSIG_ITEM_ATTACK_ZONE, PROC_REF(try_infect_attack_zone))
			RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(try_infect_attack))
			RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(try_infect_equipped))
			RegisterSignal(parent, COMSIG_FOOD_EATEN, PROC_REF(try_infect_eat))
			RegisterSignal(parent, COMSIG_PILL_CONSUMED, PROC_REF(try_infect_eat))
			if(istype(parent, /obj/item/reagent_containers/cup))
				RegisterSignal(parent, COMSIG_GLASS_DRANK, PROC_REF(try_infect_drink))
			if(isorgan(parent))
				RegisterSignal(parent, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_insertion))

/datum/component/infective/proc/on_organ_insertion(obj/item/organ/target, mob/living/carbon/receiver)
	SIGNAL_HANDLER

	for(var/datum/disease/disease in diseases)
		receiver.ForceContractDisease(disease)

	qdel(src) // once organ is implanted delete the infective component

/datum/component/infective/proc/try_infect_eat(datum/source, mob/living/eater, mob/living/feeder)
	SIGNAL_HANDLER

	if(HAS_TRAIT(eater, TRAIT_STRONG_STOMACH))
		return

	eater.add_mood_event("disgust", /datum/mood_event/disgust/dirty_food)

	if(is_weak && !prob(weak_infection_chance))
		return

	for(var/datum/disease/disease in diseases)
		if(!disease.has_required_infectious_organ(eater, ORGAN_SLOT_STOMACH))
			continue

		eater.ForceContractDisease(disease)

	try_infect(feeder, BODY_ZONE_L_ARM)

/datum/component/infective/proc/try_infect_drink(datum/source, mob/living/drinker, mob/living/feeder)
	SIGNAL_HANDLER

	if(HAS_TRAIT(drinker, TRAIT_STRONG_STOMACH))
		return

	var/appendage_zone = feeder.held_items.Find(source)
	appendage_zone = appendage_zone == 0 ? BODY_ZONE_CHEST : appendage_zone % 2 ? BODY_ZONE_R_ARM : BODY_ZONE_L_ARM
	try_infect(feeder, appendage_zone)

	for(var/datum/disease/disease in diseases)
		if(!disease.has_required_infectious_organ(drinker, ORGAN_SLOT_STOMACH))
			continue

		drinker.ForceContractDisease(disease)

/datum/component/infective/proc/clean(datum/source, clean_types)
	SIGNAL_HANDLER

	. = NONE
	if(clean_types & required_clean_types)
		qdel(src)
		return COMPONENT_CLEANED

/datum/component/infective/proc/try_infect_buckle(datum/source, mob/M, force)
	SIGNAL_HANDLER

	if(isliving(M))
		try_infect(M)

/datum/component/infective/proc/try_infect_collide(datum/source, atom/A)
	SIGNAL_HANDLER

	var/atom/movable/P = parent
	if(P.throwing)
		//this will be handled by try_infect_impact_zone()
		return
	if(isliving(A))
		try_infect(A)

/datum/component/infective/proc/try_infect_impact_zone(datum/source, mob/living/target, hit_zone)
	SIGNAL_HANDLER

	try_infect(target, hit_zone)

/datum/component/infective/proc/try_infect_attack_zone(obj/item/source, mob/living/carbon/target, mob/living/user, hit_zone)
	SIGNAL_HANDLER

	try_infect(target, hit_zone)

/datum/component/infective/proc/try_infect_attack(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	if(source.loc == user)
		var/obj/item/bodypart/hand = user.get_active_hand()
		try_infect(user, hand.body_zone)

/datum/component/infective/proc/try_infect_equipped(datum/source, mob/living/L, slot)
	SIGNAL_HANDLER

	var/old_bio_armor
	if(isitem(parent))
		//if you are putting an infective item on, it obviously will not protect you, so set its bio armor low enough that it will never block ContactContractDisease()
		var/obj/item/equipped_item = parent
		old_bio_armor = equipped_item.get_armor_rating(BIO)
		equipped_item.set_armor_rating(BIO, 0)

	try_infect(L, slot2body_zone(slot))

	if(isitem(parent))
		var/obj/item/equipped_item = parent
		equipped_item.set_armor_rating(BIO, old_bio_armor)

/datum/component/infective/proc/try_infect_crossed(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isliving(arrived))
		try_infect(arrived, BODY_ZONE_PRECISE_L_FOOT)

/datum/component/infective/proc/try_infect_streak(datum/source, list/directions, list/output_diseases)
	SIGNAL_HANDLER

	// This blood is not infectable / does not have a diseases list
	if(!islist(output_diseases))
		return

	output_diseases |= diseases

/datum/component/infective/proc/try_infect(mob/living/L, target_zone)
	for(var/V in diseases)
		L.ContactContractDisease(V, target_zone)

/datum/component/infective/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_FOOD_EATEN,
		COMSIG_PILL_CONSUMED,
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_MOVABLE_BUMP,
		COMSIG_MOVABLE_IMPACT_ZONE,
		COMSIG_ITEM_ATTACK_ZONE,
		COMSIG_ITEM_ATTACK,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_GLASS_DRANK,
		COMSIG_ORGAN_IMPLANTED,
	))
	qdel(GetComponent(/datum/component/connect_loc_behalf))
