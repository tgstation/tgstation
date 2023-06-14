/datum/component/infective
	var/list/datum/disease/diseases //make sure these are the static, non-processing versions!
	var/expire_time
	var/required_clean_types = CLEAN_TYPE_DISEASE

/datum/component/infective/Initialize(list/datum/disease/diseases, expire_in)
	if(islist(diseases))
		src.diseases = diseases
	else
		src.diseases = list(diseases)
	if(expire_in)
		expire_time = world.time + expire_in
		QDEL_IN(src, expire_in)

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/static/list/disease_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(try_infect_entered),
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
		if(istype(parent, /obj/item/reagent_containers/cup))
			RegisterSignal(parent, COMSIG_GLASS_DRANK, PROC_REF(try_infect_drink))
	else if(istype(parent, /obj/effect/decal/cleanable/blood/gibs))
		RegisterSignal(parent, COMSIG_GIBS_STREAK, PROC_REF(try_infect_streak))

/datum/component/infective/proc/try_infect_eat(datum/source, mob/living/eater, mob/living/feeder)
	SIGNAL_HANDLER

	for(var/disease in diseases)
		eater.ForceContractDisease(disease)
	var/active_hand_zone = (!(feeder.active_hand_index % RIGHT_HANDS) ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND)
	try_infect(feeder, active_hand_zone)

/datum/component/infective/proc/try_infect_drink(datum/source, mob/living/drinker, mob/living/feeder)
	SIGNAL_HANDLER

	for(var/disease in diseases)
		drinker.ForceContractDisease(disease)
	var/active_hand_zone = (!(feeder.active_hand_index % RIGHT_HANDS) ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND)
	try_infect(feeder, active_hand_zone)

/datum/component/infective/proc/clean(datum/source, clean_types)
	SIGNAL_HANDLER

	. = NONE
	if(clean_types & required_clean_types)
		qdel(src)
		return COMPONENT_CLEANED

/datum/component/infective/proc/try_infect_buckle(datum/source, mob/living/buckled, force)
	SIGNAL_HANDLER

	try_infect(buckled)

/datum/component/infective/proc/try_infect_collide(datum/source, atom/collided)
	SIGNAL_HANDLER

	var/atom/movable/movable_parent = parent
	if(movable_parent.throwing)
		//this will be handled by try_infect_impact_zone()
		return
	if(isliving(collided))
		try_infect(collided)

/datum/component/infective/proc/try_infect_impact_zone(datum/source, mob/living/target, hit_zone)
	SIGNAL_HANDLER

	try_infect(target, hit_zone)

/datum/component/infective/proc/try_infect_attack_zone(datum/source, mob/living/carbon/target, mob/living/user, hit_zone)
	SIGNAL_HANDLER

	var/active_hand_zone = (!(user.active_hand_index % RIGHT_HANDS) ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND)
	try_infect(user, active_hand_zone)
	try_infect(target, hit_zone)

/datum/component/infective/proc/try_infect_attack(datum/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	if(!iscarbon(target)) //this case will be handled by try_infect_attack_zone
		try_infect(target)
	var/active_hand_zone = (!(user.active_hand_index % RIGHT_HANDS) ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND)
	try_infect(user, active_hand_zone)

/datum/component/infective/proc/try_infect_equipped(datum/source, mob/living/equipper, slot)
	SIGNAL_HANDLER

	var/old_bio_armor
	if(isitem(parent))
		//if you are putting an infective item on, it obviously will not protect you, so set its bio armor low enough that it will never block ContactContractDisease()
		var/obj/item/equipped_item = parent
		old_bio_armor = equipped_item.get_armor_rating(BIO)
		equipped_item.set_armor_rating(BIO, 0)

	try_infect(equipper, slot2body_zone(slot))

	if(isitem(parent))
		var/obj/item/equipped_item = parent
		equipped_item.set_armor_rating(BIO, old_bio_armor)

/datum/component/infective/proc/try_infect_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isliving(arrived))
		try_infect(arrived, pick(BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT))

/datum/component/infective/proc/try_infect_streak(datum/source, list/directions, list/output_diseases)
	SIGNAL_HANDLER

	// This blood is not infectable / does not have a diseases list
	if(!islist(output_diseases))
		return

	output_diseases |= diseases

/datum/component/infective/proc/try_infect(mob/living/infected, target_zone)
	for(var/disease in diseases)
		infected.ContactContractDisease(disease, target_zone)
