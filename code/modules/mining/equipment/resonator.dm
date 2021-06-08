#define RESONATOR_MODE_AUTO   1
#define RESONATOR_MODE_MANUAL 2
#define RESONATOR_MODE_MATRIX 3

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

	var/mode = RESONATOR_MODE_AUTO
	/// How efficient it is in manual mode. Yes, we lower the damage cuz it's gonna be used for mobhunt
	var/quick_burst_mod = 0.8
	var/fieldlimit = 4
	var/list/fields = list()

/obj/item/resonator/attack_self(mob/user)
	if(mode == RESONATOR_MODE_AUTO)
		to_chat(user, "<span class='info'>You set the resonator's fields to detonate only after you hit one with it.</span>")
		mode = RESONATOR_MODE_MANUAL
	else
		to_chat(user, "<span class='info'>You set the resonator's fields to automatically detonate after 2 seconds.</span>")
		mode = RESONATOR_MODE_AUTO

/obj/item/resonator/proc/CreateResonance(target, mob/user)
	var/turf/T = get_turf(target)
	var/obj/effect/temp_visual/resonance/R = locate(/obj/effect/temp_visual/resonance) in T
	if(R)
		R.damage_multiplier = quick_burst_mod
		R.burst()
		return
	if(LAZYLEN(fields) < fieldlimit)
		new /obj/effect/temp_visual/resonance(T, user, src, mode)
		user.changeNext_move(CLICK_CD_MELEE)

/obj/item/resonator/pre_attack(atom/target, mob/user, params)
	if(check_allowed_items(target, 1))
		CreateResonance(target, user)
	. = ..()

//resonance field, crushes rock, damages mobs
/obj/effect/temp_visual/resonance
	name = "resonance field"
	desc = "A resonating field that significantly damages anything inside of it when the field eventually ruptures. More damaging in low pressure environments."
	icon_state = "shield1"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 60 SECONDS
	var/resonance_damage = 20
	var/damage_multiplier = 1
	var/creator
	var/obj/item/resonator/res
	var/rupturing = FALSE //So it won't recurse

/obj/effect/temp_visual/resonance/Initialize(mapload, set_creator, set_resonator, mode)
	if(mode == RESONATOR_MODE_AUTO)
		duration = 2 SECONDS
	if(mode == RESONATOR_MODE_MATRIX)
		icon_state = "shield2"
		name = "resonance matrix"
		RegisterSignal(src, COMSIG_ATOM_ENTERED, .proc/burst)
		var/static/list/loc_connections = list(
			COMSIG_ATOM_ENTERED = .proc/burst,
		)
		AddElement(/datum/element/connect_loc, src, loc_connections)
	. = ..()
	creator = set_creator
	res = set_resonator
	if(res)
		res.fields += src
	playsound(src,'sound/weapons/resonator_fire.ogg',50,TRUE)
	if(mode == RESONATOR_MODE_AUTO)
		transform = matrix()*0.75
		animate(src, transform = matrix()*1.5, time = duration)
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, .proc/burst), duration, TIMER_STOPPABLE)

/obj/effect/temp_visual/resonance/Destroy()
	if(res)
		res.fields -= src
		res = null
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
	rupturing = TRUE
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/resonance_crush(T)
	if(ismineralturf(T))
		var/turf/closed/mineral/M = T
		M.gets_drilled(creator)
	check_pressure(T)
	playsound(T,'sound/weapons/resonator_blast.ogg',50,TRUE)
	for(var/mob/living/L in T)
		if(creator)
			log_combat(creator, L, "used a resonator field on", "resonator")
		to_chat(L, "<span class='userdanger'>[src] ruptured with you in it!</span>")
		L.apply_damage(resonance_damage, BRUTE)
		L.add_movespeed_modifier(/datum/movespeed_modifier/resonance)
		addtimer(CALLBACK(L, /mob/proc/remove_movespeed_modifier, /datum/movespeed_modifier/resonance), 10 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	for(var/obj/effect/temp_visual/resonance/field in range(1, src))
		if(field != src && !field.rupturing)
			field.burst()
	qdel(src)

/obj/effect/temp_visual/resonance_crush
	icon_state = "shield1"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 4

/obj/effect/temp_visual/resonance_crush/Initialize()
	. = ..()
	transform = matrix()*1.5
	animate(src, transform = matrix()*0.1, alpha = 50, time = 4)

/obj/item/resonator/upgraded
	name = "upgraded resonator"
	desc = "An upgraded version of the resonator that can produce more fields at once, as well as having no damage penalty for bursting a resonance field early. It also allows you to set 'Resonance matrixes', that detonate after someone(or something) walks over it."
	icon_state = "resonator_u"
	inhand_icon_state = "resonator_u"
	fieldlimit = 6
	quick_burst_mod = 1

/obj/item/resonator/upgraded/attack_self(mob/user)
	if(mode == RESONATOR_MODE_AUTO)
		to_chat(user, "<span class='info'>You set the resonator's fields to detonate only after you hit one with it.</span>")
		mode = RESONATOR_MODE_MANUAL
	else if(mode == RESONATOR_MODE_MANUAL)
		to_chat(user, "<span class='info'>You set the resonator's fields to work as matrix traps.</span>")
		mode = RESONATOR_MODE_MATRIX
	else
		to_chat(user, "<span class='info'>You set the resonator's fields to automatically detonate after 2 seconds.</span>")
		mode = RESONATOR_MODE_AUTO

#undef RESONATOR_MODE_AUTO
#undef RESONATOR_MODE_MANUAL
#undef RESONATOR_MODE_MATRIX
