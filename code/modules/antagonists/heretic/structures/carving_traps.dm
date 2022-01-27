

/obj/structure/trap/eldritch
	name = "elder carving"
	desc = "Collection of unknown symbols, they remind you of days long gone..."
	icon = 'icons/obj/eldritch.dmi'
	charges = 1
	/// Reference to trap owner mob
	var/datum/weakref/owner

/obj/structure/trap/eldritch/Initialize(mapload, new_owner)
	. = ..()
	if(new_owner)
		owner = WEAKREF(new_owner)

/obj/structure/trap/eldritch/on_entered(datum/source, atom/movable/entering_atom)
	if(!isliving(entering_atom))
		return ..()
	var/mob/living/living_mob = entering_atom
	if(WEAKREF(living_mob) == owner)
		return
	if(IS_HERETIC_OR_MONSTER(living_mob))
		return
	return ..()

/obj/structure/trap/eldritch/attacked_by(obj/item/weapon, mob/living/user)
	. = ..()
	if(istype(weapon, /obj/item/melee/rune_carver) || istype(weapon, /obj/item/nullrod))
		qdel(src)

/obj/structure/trap/eldritch/alert
	name = "alert carving"
	icon_state = "alert_rune"
	alpha = 10

/obj/structure/trap/eldritch/alert/trap_effect(mob/living/victim)
	var/mob/living/real_owner = owner?.resolve()
	if(real_owner)
		to_chat(real_owner, span_userdanger("[victim.real_name] has stepped foot on the alert rune in [get_area(src)]!"))
	return ..()

//this trap can only get destroyed by rune carving knife or nullrod
/obj/structure/trap/eldritch/alert/flare()
	return

/obj/structure/trap/eldritch/tentacle
	name = "grasping carving"
	icon_state = "tentacle_rune"

/obj/structure/trap/eldritch/tentacle/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/carbon_victim = victim
	carbon_victim.Paralyze(5 SECONDS)
	carbon_victim.apply_damage(20, BRUTE, BODY_ZONE_R_LEG)
	carbon_victim.apply_damage(20, BRUTE, BODY_ZONE_L_LEG)
	playsound(src, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	return ..()

/obj/structure/trap/eldritch/mad
	name = "mad carving"
	icon_state = "madness_rune"

/obj/structure/trap/eldritch/mad/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/carbon_victim = victim
	carbon_victim.adjustStaminaLoss(80)
	carbon_victim.silent += 10
	carbon_victim.add_confusion(5)
	carbon_victim.Jitter(10)
	carbon_victim.Dizzy(20)
	carbon_victim.blind_eyes(2)
	SEND_SIGNAL(carbon_victim, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)
	return ..()
