#define OCULAR_WARDEN_PLACE_RANGE 4
#define OCULAR_WARDEN_RANGE 3

/datum/clockcult/scripture/create_structure/ocular_warden
	name = "Окулярный страж"
	desc = "Глазная турель, которая будет стрелять по ближайшим целям. Требуется 2 вызывающих."
	tip = "Разместите их вокруг, чтобы экипаж не пробежал мимо вашей защиты."
	button_icon_state = "Ocular Warden"
	power_cost = 400
	invokation_time = 50
	invokation_text = list("Призовись на защиту нашего храма")
	summoned_structure = /obj/structure/destructible/clockwork/ocular_warden
	cogs_required = 3
	invokers_required = 2
	category = SPELLTYPE_STRUCTURES

/datum/clockcult/scripture/create_structure/ocular_warden/check_special_requirements()
	if(!..())
		return FALSE
	for(var/obj/structure/destructible/clockwork/structure in get_turf(invoker))
		to_chat(invoker, span_brass("Здесь уже есть [structure]."))
		return FALSE
	for(var/obj/structure/destructible/clockwork/ocular_warden/AC in range(OCULAR_WARDEN_PLACE_RANGE))
		to_chat(invoker, span_nezbere("Рядом есть еще один окулярный страж, размещение их слишком близко заставит их драться!"))
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/ocular_warden
	name = "окулярный страж"
	desc = "Широко открытый глаз, пристально смотрящий в вашу душу. Кажется, он устойчив к энергетическому оружию."
	clockwork_desc = "Защитное устройство, которое будет бороться с любыми злоумышленниками поблизости."
	break_message = span_warning("Черная слизь вытекает из окулярного стража, медленно вытекая на землю.")
	icon_state = "ocular_warden"
	max_integrity = 60
	armor = list("melee" = -80, "bullet" = -50, "laser" = 40, "energy" = 40, "bomb" = 20, "bio" = 0, "rad" = 0)
	var/cooldown

/obj/structure/destructible/clockwork/ocular_warden/process()
	//Can we fire?
	if(world.time < cooldown)
		return
	//Check hostiles in range
	var/list/valid_targets = list()
	for(var/mob/living/potential in hearers(OCULAR_WARDEN_RANGE, src))
		if(!is_servant_of_ratvar(potential) && !potential.stat)
			valid_targets += potential
	if(!LAZYLEN(valid_targets))
		return
	var/mob/living/target = pick(valid_targets)
	playsound(get_turf(src), 'sound/machines/clockcult/ocularwarden-target.ogg', 60, TRUE)
	if(!target)
		return
	dir = get_dir(get_turf(src), get_turf(target))
	target.apply_damage(max(20 - (get_dist(src, target)*5), 10), BURN)
	new /obj/effect/temp_visual/ratvar/ocular_warden(get_turf(target))
	new /obj/effect/temp_visual/ratvar/ocular_warden(get_turf(src))
	playsound(get_turf(target), 'sound/machines/clockcult/ocularwarden-dot1.ogg', 60, TRUE)
	cooldown = world.time + 20

/obj/structure/destructible/clockwork/ocular_warden/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/ocular_warden/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

#undef OCULAR_WARDEN_PLACE_RANGE
