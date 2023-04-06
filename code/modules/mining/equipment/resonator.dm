/**********************Resonator**********************/

/obj/item/resonator
	name = "resonator"
	icon = 'icons/obj/mining.dmi'
	icon_state = "resonator"
	inhand_icon_state = "resonator"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	desc = "A handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It does increased damage in low pressure. It has two modes: Automatic and manual detonation."
	w_class = WEIGHT_CLASS_NORMAL
	force = 15
	throwforce = 10

	/// the mode of the resonator; has three modes: auto (1), manual (2), and matrix (3)
	var/mode = RESONATOR_MODE_AUTO
	/// How efficient it is in manual mode. Yes, we lower the damage cuz it's gonna be used for mobhunt
	var/quick_burst_mod = 0.8
	/// the number of fields the resonator is allowed to have at once
	var/fieldlimit = 4
	/// the list of currently active fields from this resonator
	var/list/fields = list()
	/// the number that is added to the failure_prob, which is the probability of whether it will spread or not
	var/adding_failure = 50

/obj/item/resonator/attack_self(mob/user)
	if(mode == RESONATOR_MODE_AUTO)
		to_chat(user, span_info("You set the resonator's fields to detonate only after you hit one with it."))
		mode = RESONATOR_MODE_MANUAL
	else
		to_chat(user, span_info("You set the resonator's fields to automatically detonate after 2 seconds."))
		mode = RESONATOR_MODE_AUTO

/obj/item/resonator/proc/create_resonance(target, mob/user)
	var/turf/target_turf = get_turf(target)
	var/obj/effect/temp_visual/resonance/resonance_field = locate(/obj/effect/temp_visual/resonance) in target_turf
	if(resonance_field)
		resonance_field.damage_multiplier = quick_burst_mod
		resonance_field.burst()
		return
	if(LAZYLEN(fields) < fieldlimit)
		new /obj/effect/temp_visual/resonance(target_turf, user, src, mode, adding_failure)
		user.changeNext_move(CLICK_CD_MELEE)

/obj/item/resonator/pre_attack(atom/target, mob/user, params)
	if(check_allowed_items(target, not_inside = TRUE))
		create_resonance(target, user)
	return ..()

//resonance field, crushes rock, damages mobs
/obj/effect/temp_visual/resonance
	name = "resonance field"
	desc = "A resonating field that significantly damages anything inside of it when the field eventually ruptures. More damaging in low pressure environments."
	icon_state = "shield1"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	duration = 60 SECONDS
	/// the amount of damage living beings will take whilst inside the field during its burst
	var/resonance_damage = 20
	/// the modifier to resonance_damage; affected by the quick_burst_mod from the resonator
	var/damage_multiplier = 1
	/// the parent creator (user) of this field
	var/creator
	/// the parent resonator of this field
	var/obj/item/resonator/parent_resonator
	/// whether the field is rupturing currently or not (to prevent recursion)
	var/rupturing = FALSE
	/// the probability that the field will not be able to spread
	var/failure_prob = 0
	/// the number that is added to the failure_prob. Will default to 50
	var/adding_failure

/obj/effect/temp_visual/resonance/Initialize(mapload, set_creator, set_resonator, mode, set_failure = 50)
	if(mode == RESONATOR_MODE_AUTO)
		duration = 2 SECONDS
	if(mode == RESONATOR_MODE_MATRIX)
		icon_state = "shield2"
		name = "resonance matrix"
		RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(burst))
		var/static/list/loc_connections = list(
			COMSIG_ATOM_ENTERED = PROC_REF(burst),
		)
		AddElement(/datum/element/connect_loc, loc_connections)
	. = ..()
	creator = set_creator
	parent_resonator = set_resonator
	if(parent_resonator)
		parent_resonator.fields += src
	adding_failure = set_failure
	playsound(src,'sound/weapons/resonator_fire.ogg',50,TRUE)
	if(mode == RESONATOR_MODE_AUTO)
		transform = matrix()*0.75
		animate(src, transform = matrix()*1.5, time = duration)
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, PROC_REF(burst)), duration, TIMER_STOPPABLE)

/obj/effect/temp_visual/resonance/Destroy()
	if(parent_resonator)
		parent_resonator.fields -= src
		parent_resonator = null
	creator = null
	. = ..()

/obj/effect/temp_visual/resonance/proc/check_pressure(turf/proj_turf)
	if(!proj_turf)
		proj_turf = get_turf(src)
	resonance_damage = initial(resonance_damage)
	if(lavaland_equipment_pressure_check(proj_turf))
		name = "strong [initial(name)]"
		resonance_damage *= 3
	else
		name = initial(name)
	resonance_damage *= damage_multiplier

/obj/effect/temp_visual/resonance/proc/burst()
	SIGNAL_HANDLER
	if(rupturing)
		return
	rupturing = TRUE
	var/turf/src_turf = get_turf(src)
	new /obj/effect/temp_visual/resonance_crush(src_turf)
	if(ismineralturf(src_turf))
		var/turf/closed/mineral/mineral_turf = src_turf
		mineral_turf.gets_drilled(creator)
	check_pressure(src_turf)
	playsound(src_turf, 'sound/weapons/resonator_blast.ogg', 50, TRUE)
	for(var/mob/living/attacked_living in src_turf)
		if(creator)
			log_combat(creator, attacked_living, "used a resonator field on", "resonator")
		to_chat(attacked_living, span_userdanger("[src] ruptured with you in it!"))
		attacked_living.apply_damage(resonance_damage, BRUTE)
		attacked_living.add_movespeed_modifier(/datum/movespeed_modifier/resonance)
		addtimer(CALLBACK(attacked_living, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/resonance), 10 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	for(var/obj/effect/temp_visual/resonance/field in orange(1, src))
		if(field.rupturing)
			continue
		field.burst()
	if(!prob(failure_prob) && parent_resonator)
		for(var/turf/closed/mineral/mineral_spread in orange(1, src))
			if(locate(/obj/effect/temp_visual/resonance) in mineral_spread)
				continue
			var/obj/effect/temp_visual/resonance/new_field = new(mineral_spread, creator, parent_resonator, parent_resonator.mode)
			new_field.failure_prob = failure_prob + adding_failure
	qdel(src)

/obj/effect/temp_visual/resonance_crush
	icon_state = "shield1"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	duration = 4

/obj/effect/temp_visual/resonance_crush/Initialize(mapload)
	. = ..()
	transform = matrix() * 1.5
	animate(src, transform = matrix() * 0.1, alpha = 50, time = 4)

/obj/item/resonator/upgraded
	name = "upgraded resonator"
	desc = "An upgraded version of the resonator that can produce more fields at once, as well as having no damage penalty for bursting a resonance field early. It also allows you to set 'Resonance matrixes', that detonate after someone(or something) walks over it."
	icon_state = "resonator_u"
	inhand_icon_state = "resonator_u"
	fieldlimit = 6
	quick_burst_mod = 1
	adding_failure = 30

/obj/item/resonator/upgraded/attack_self(mob/user)
	if(mode == RESONATOR_MODE_AUTO)
		to_chat(user, span_info("You set the resonator's fields to detonate only after you hit one with it."))
		mode = RESONATOR_MODE_MANUAL
	else if(mode == RESONATOR_MODE_MANUAL)
		to_chat(user, span_info("You set the resonator's fields to work as matrix traps."))
		mode = RESONATOR_MODE_MATRIX
	else
		to_chat(user, span_info("You set the resonator's fields to automatically detonate after 2 seconds."))
		mode = RESONATOR_MODE_AUTO
