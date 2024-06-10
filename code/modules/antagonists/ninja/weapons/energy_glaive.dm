/**
 * # Energy Glaive
 *
 * The space ninja's glaive.
 *
 * The glaive that only space ninja spawns with.  Comes with 12 force and 40 throwforce, along with a throw-teleport system.
 * Throwing glaive will teleport thrower to where it arrived. Knockdown people that stay on turf where user teleport.
 * 4 charges witch 10 SECONDS cooldown.
 * Make two attack instead of one. Target will be chosen from any living mob in 3x3 aoe of user.
 * If no one in range glaive will make second attack to first target again.
 *
 */
#define GLAIVE_COOLDOWN 10 SECONDS
/obj/item/energy_glaive
	name = "energy glaive"
	desc = "Crescent blade. \
	Its razor-sharp edge slices through space, revealing unseen dimensions and unveiling new realms of combat. \
	Mastery of this weapon demands advanced skills and battle experience."
	desc_controls = "Throw it to teleport."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "glaive"
	inhand_icon_state = "glaive"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 14 // 28 becouse making double attack everytime
	throwforce = 40
	block_chance = 70
	armour_penetration = 50
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	pickup_sound = 'sound/items/unsheath.ogg'
	drop_sound = 'sound/items/sheath.ogg'
	block_sound = 'sound/weapons/block_blade.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED
	max_integrity = 200
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Making sparks effects when doing somthing
	var/datum/effect_system/spark_spread/spark_system
	/// If if double attacked other target we don't attack first target again
	var/double_attack = FALSE
	/// Throw-Teleport charges.
	var/charges = 4

/obj/item/energy_glaive/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/energy_glaive/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	var/mob/living/who_throw = throwingdatum?.get_thrower()
	if(!who_throw)
		return
	if(charges < 1)
		return
	if(isliving(hit_atom))
		if(who_throw == hit_atom)
			return
		var/mob/living/knockdown_me = hit_atom
		knockdown_me.Knockdown(5 SECONDS)
		teleport_throw(who_throw, get_turf(knockdown_me))
		return
	var/obj/machinery/door/airlock/locate_aitlock = locate() in get_turf(hit_atom)
	if(isclosedturf(hit_atom) || (locate(/obj/structure/window) in get_turf(hit_atom)) || locate_aitlock?.density)
		var/turf/not_in_wall = get_step(hit_atom, get_dir(hit_atom, who_throw))
		teleport_throw(who_throw, not_in_wall)
		return
	teleport_throw(who_throw, get_turf(hit_atom))

/obj/item/energy_glaive/proc/teleport_throw(mob/living/who, turf/where)
	who.forceMove(where)
	who.put_in_hands(src)
	charges--
	addtimer(CALLBACK(src, PROC_REF(add_charge), who), GLAIVE_COOLDOWN)

/obj/item/energy_glaive/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!(isliving(target)))
		return
	var/target_found = FALSE
	for(var/mob/living/another_target in view(1, user))
		if(another_target == user)
			continue
		if(another_target == target)
			continue
		target_found = TRUE
		addtimer(CALLBACK(src, PROC_REF(double_attack), user, another_target), 0.25 SECONDS)
		break
	if(!target_found)
		addtimer(CALLBACK(src, PROC_REF(double_attack), user, target), 0.25 SECONDS)

/obj/item/energy_glaive/proc/add_charge(mob/living/give_ballon)
	charges++
	if(!(loc == give_ballon))
		return
	balloon_alert(give_ballon, "[charges]/4 throw charges")

/obj/item/energy_glaive/proc/double_attack(mob/user, mob/living/target)
	if(!(loc == user))
		return
	if(double_attack)
		double_attack = FALSE
		return
	double_attack = TRUE
	melee_attack_chain(user, target)

/obj/item/energy_glaive/Destroy()
	QDEL_NULL(spark_system)
	return ..()

#undef GLAIVE_COOLDOWN
