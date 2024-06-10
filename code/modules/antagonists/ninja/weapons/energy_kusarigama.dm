/**
 * # Energy kusarigama
 *
 * The space ninja's kusarigama.
 *
 * Kusarigama maden from 3 parts: head, chain and tail.
 * Head(kama): Large wound bonus and throw damage, but little damage with melee attack.
 * Tail(fundo): Low thorw/melee/wound damage but higth block chanse. knock out weapon from target hand in melee attack and knockdown it in throw attack.
 * Chain(chain): Chain connected between head and tail. as soon as one of the friends moves far from the other, he in turn tries to catch up with his friend
 * 				If anyone stands between friends when one of them moves towards the other, he will receive a slide effect:
 * 					Kama effect - Deal 60 damage and have 25% chanse to cut target leg off,
 * 					Fundo effect - Paralize target on 3 SECONDS.
 * Parts can't be picked up if someone else is holding another part.
 * All parts can be used in hands to pull it near owner.
 *
 */
/obj/item/energy_kusarigama_kama
	name = "energy kama"
	desc = "Shimmering scythe. \
	Harder then any ninja weapons. \
	Its curved form gainsstrength in rotation, shattering spatial barriers and clearing path for dancer of space."
	desc_controls = "Use in hands to pull fundo to you"
	icon = 'icons/obj/weapons/thrown.dmi'
	icon_state = "energy_kama"
	inhand_icon_state = "energy_kama"
	worn_icon_state = "energy_kama"
	lefthand_file = 'icons/mob/inhands/weapons/thrown_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/thrown_righthand.dmi'
	sharpness = SHARP_POINTY
	w_class = WEIGHT_CLASS_NORMAL
	force = 12
	throwforce = 40
	armour_penetration = 70
	block_chance = 40
	wound_bonus = 50
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
	/// Chain var
	var/chain
	/// Max range between two items
	var/chain_range = 3
	/// Our friend
	var/obj/item/energy_kusarigama_fundo/kusarigama_tail
	/// Player that wering kusarigama tail
	var/mob/living/living_equip_tail
	/// Player that wering kusarigama head
	var/mob/living/living_equip_head

/obj/item/energy_kusarigama_kama/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	if(kusarigama_tail)
		return
	kusarigama_tail = new /obj/item/energy_kusarigama_fundo(get_turf(src))
	kusarigama_tail.kusarigama_head = src
	chain_check()

/obj/item/energy_kusarigama_kama/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/energy_kusarigama_kama/Move(atom/newloc, direct, glide_size_override, update_dir)
	. = ..()
	if(!kusarigama_tail)
		return
	if(get_dist(src, kusarigama_tail) < chain_range)
		chain_check()
		return
	if(living_equip_tail)
		chain_check()
		return
	var/turf/move_here_turf = get_step(kusarigama_tail, direct)
	var/obj/machinery/door/airlock/locate_aitlock = locate() in move_here_turf
	if(isclosedturf(move_here_turf) || (locate(/obj/structure/window) in move_here_turf) || locate_aitlock?.density)
		move_here_turf = calculate_if_closed_turf(kusarigama_tail, src)
	if(!kusarigama_tail.forceMove(move_here_turf))
		living_equip_head.put_in_hands(kusarigama_tail)
		chain_check()
		return
	for(var/mob/living/someone_to_hit in move_here_turf)
		if(someone_to_hit == living_equip_head)
			continue
		if(someone_to_hit.mind?.has_antag_datum(/datum/antagonist/ninja))
			continue
		someone_to_hit.Paralyze(3 SECONDS)
		someone_to_hit.visible_message(span_danger("[kusarigama_tail] stumble [someone_to_hit]!"), span_userdanger("[kusarigama_tail] stumble you!"))
	chain_check()

/obj/item/energy_kusarigama_kama/dropped(mob/user, silent)
	. = ..()
	if(!kusarigama_tail)
		return
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	chain_check()

/obj/item/energy_kusarigama_kama/on_thrown(mob/living/carbon/user, atom/target)
	. = ..()
	if(!kusarigama_tail)
		return
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	chain_check()

/obj/item/energy_kusarigama_kama/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, gentle, quickstart)
	. = ..()
	if(!kusarigama_tail)
		return
	chain_check()

/obj/item/energy_kusarigama_kama/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		if(kusarigama_tail)
			chain_check()
		return ..()
	var/mob/living/we_hit_you = hit_atom
	if(we_hit_you == living_equip_tail)
		if(kusarigama_tail)
			chain_check()
		return
	. = ..()
	if(!kusarigama_tail)
		return
	chain_check()

/obj/item/energy_kusarigama_kama/equipped(mob/user, slot, initial)
	. = ..()
	if(!kusarigama_tail)
		return
	if(living_equip_tail == user)
		chain_check()
		return
	if(living_equip_tail)
		if(!(user.mind?.has_antag_datum(/datum/antagonist/ninja)))
			user.dropItemToGround(src)
			chain_check()
			return
		living_equip_tail.dropItemToGround(kusarigama_tail)
	if(slot & ITEM_SLOT_HANDS)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	chain_check()

/obj/item/energy_kusarigama_kama/attack_self(mob/user, modifiers)
	. = ..()
	if(living_equip_tail)
		return
	kusarigama_tail.throw_at(user, 3, 3)
	chain_check()

/// Check loc of our obj to make new chain between each other.
/// If obj in living mob we will make new chain between mob and other obj. Same with closets, crates and etc.
/obj/item/energy_kusarigama_kama/proc/chain_check()
	if(!kusarigama_tail)
		if(chain)
			QDEL_NULL(chain)
		return
	living_equip_head = recursive_loc_check(src, /mob/living)
	living_equip_tail = recursive_loc_check(kusarigama_tail, /mob/living)
	var/atom/movable/chain_start = living_equip_head ? living_equip_head : src
	var/atom/movable/chain_end = living_equip_tail ? living_equip_tail : kusarigama_tail
	if(!isturf(chain_start.loc))
		var/atom/start_inside = chain_start.loc
		chain_start = start_inside
	if(!isturf(chain_end.loc))
		var/atom/end_inside = chain_end.loc
		chain_end = end_inside
	if(src.loc == kusarigama_tail.loc)
		if(chain)
			QDEL_NULL(chain)
		return
	if(chain)
		QDEL_NULL(chain)
	chain = chain_start.Beam(chain_end, "kusarigama_chain", emissive = FALSE)

/// Like Move proc but register when user wear kusarigama head.
/obj/item/energy_kusarigama_kama/proc/on_move(mob/living/who_move)
	SIGNAL_HANDLER

	if(living_equip_head && living_equip_tail)
		chain_check()
		return
	if(get_dist(src, kusarigama_tail) < chain_range)
		chain_check()
		return
	if(isnull(living_equip_head))
		chain_check()
		return
	var/turf/move_here_turf = get_step(kusarigama_tail, get_dir(kusarigama_tail, who_move))
	var/obj/machinery/door/airlock/locate_aitlock = locate() in move_here_turf
	if(isclosedturf(move_here_turf) || (locate(/obj/structure/window) in move_here_turf) || locate_aitlock?.density)
		move_here_turf = calculate_if_closed_turf(kusarigama_tail, src)
	kusarigama_tail.forceMove(move_here_turf)
	for(var/mob/living/someone_to_hit in move_here_turf)
		if(someone_to_hit == living_equip_head)
			continue
		if(someone_to_hit.mind?.has_antag_datum(/datum/antagonist/ninja))
			continue
		someone_to_hit.Paralyze(3 SECONDS)
		someone_to_hit.visible_message(span_danger("[kusarigama_tail] stumble [someone_to_hit]!"), span_userdanger("[kusarigama_tail] stumble you!"))
	chain_check()

/// If turf to ForceMove kusarigama head is closed we will try to find open turf with min dist to kusarigama tail.
/obj/item/energy_kusarigama_kama/proc/calculate_if_closed_turf(atom/movable/what_moving, atom/movable/direct_to_move)
	var/turf/resolve
	var/min_dist = INFINITY
	for(var/turf/open/open_turf in range(1, what_moving))
		if(locate(/obj/structure/window) in open_turf)
			continue
		var/obj/machinery/door/airlock/locate_aitlock = locate() in open_turf
		if(locate_aitlock?.density)
			continue
		if(get_dist(open_turf, direct_to_move) < min_dist)
			resolve = open_turf
			min_dist = get_dist(open_turf, direct_to_move)
	return resolve

/obj/item/energy_kusarigama_fundo
	name = "energy fundo"
	desc = "Spherical weight at the end of the kusarigama, \
	wielded by master to seize decisive moments in battle. This is a weapon for true masters, surpassing ordinary ninja skills."
	desc_controls = "Can disarm weapons. Throw it to knockdown enemy. Use in hands to pull kama to you"
	icon = 'icons/obj/weapons/thrown.dmi'
	icon_state = "energy_fundo"
	inhand_icon_state = "energy_fundo"
	worn_icon_state = "energy_fundo"
	lefthand_file = 'icons/mob/inhands/weapons/thrown_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/thrown_righthand.dmi'
	sharpness = SHARP_POINTY
	attack_speed = CLICK_CD_RAPID
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	throwforce = 20
	armour_penetration = 30
	block_chance = 60
	wound_bonus = -100 // not blade
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
	/// Our friend
	var/obj/item/energy_kusarigama_kama/kusarigama_head

/obj/item/energy_kusarigama_fundo/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/energy_kusarigama_fundo/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/energy_kusarigama_fundo/Move(atom/newloc, direct, glide_size_override, update_dir)
	. = ..()
	if(!kusarigama_head)
		return
	if(get_dist(src, kusarigama_head) < kusarigama_head.chain_range)
		kusarigama_head.chain_check()
		return
	if(kusarigama_head.living_equip_head)
		kusarigama_head.chain_check()
		return
	var/turf/move_here_turf = get_step(kusarigama_head, direct)
	var/obj/machinery/door/airlock/locate_aitlock = locate() in move_here_turf
	if(isclosedturf(move_here_turf) || (locate(/obj/structure/window) in move_here_turf) || locate_aitlock?.density)
		move_here_turf = calculate_if_closed_turf(kusarigama_head, src)
	if(!kusarigama_head.forceMove(move_here_turf))
		kusarigama_head.living_equip_tail.put_in_hands(kusarigama_head)
		kusarigama_head.chain_check()
		return
	for(var/mob/living/someone_to_hit in move_here_turf)
		if(someone_to_hit == kusarigama_head.living_equip_tail)
			continue
		if(someone_to_hit.mind?.has_antag_datum(/datum/antagonist/ninja))
			continue
		slid_effect(someone_to_hit)
	kusarigama_head.chain_check()

/obj/item/energy_kusarigama_fundo/dropped(mob/user, silent)
	. = ..()
	if(!kusarigama_head)
		return
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	kusarigama_head.chain_check()

/obj/item/energy_kusarigama_fundo/on_thrown(mob/living/carbon/user, atom/target)
	. = ..()
	if(!kusarigama_head)
		return
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	kusarigama_head.chain_check()

/obj/item/energy_kusarigama_fundo/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, gentle, quickstart)
	. = ..()
	if(!kusarigama_head)
		return
	kusarigama_head.chain_check()

/obj/item/energy_kusarigama_fundo/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		if(kusarigama_head)
			kusarigama_head.chain_check()
		return ..()
	var/mob/living/we_hit_you = hit_atom
	if(we_hit_you == kusarigama_head.living_equip_head)
		if(kusarigama_head)
			kusarigama_head.chain_check()
		return
	. = ..()
	if(!kusarigama_head)
		return
	kusarigama_head.chain_check()
	we_hit_you.Knockdown(3 SECONDS)
	we_hit_you.visible_message(span_danger("[src] stumble [we_hit_you]!"), span_userdanger("[src] stumble you!"))

/obj/item/energy_kusarigama_fundo/equipped(mob/user, slot, initial)
	. = ..()
	if(!kusarigama_head)
		return
	if(kusarigama_head.living_equip_head == user)
		kusarigama_head.chain_check()
		return
	if(kusarigama_head.living_equip_head)
		if(!(user.mind?.has_antag_datum(/datum/antagonist/ninja)))
			user.dropItemToGround(src)
			kusarigama_head.chain_check()
			return
		kusarigama_head.living_equip_head.dropItemToGround(kusarigama_head)
	if(slot & ITEM_SLOT_HANDS)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	kusarigama_head.chain_check()

/obj/item/energy_kusarigama_fundo/attack_self(mob/user, modifiers)
	. = ..()
	if(kusarigama_head.living_equip_head)
		return
	kusarigama_head.throw_at(user, 3, 3)
	kusarigama_head.chain_check()

/obj/item/energy_kusarigama_fundo/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!(ishuman(target) && proximity_flag))
		return
	var/mob/living/carbon/human/human_target = target
	human_target.drop_all_held_items()
	human_target.visible_message(span_danger("[user] disarms [human_target]!"), span_userdanger("[user] disarmed you!"))

/// Effect calling to living mobs when we ForceMove kusarigama tail on the turf where they is.
/obj/item/energy_kusarigama_fundo/proc/slid_effect(mob/living/unsuspecting_victim)
	unsuspecting_victim.apply_damage(60, BRUTE)
	unsuspecting_victim.visible_message(span_danger("[kusarigama_head] slid across and hurt [unsuspecting_victim]!"), span_userdanger("[kusarigama_head] slid across and hurt you!"))
	if(prob(75))
		return
	var/obj/item/bodypart/cut_this = unsuspecting_victim.get_bodypart(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	if(!cut_this)
		return
	cut_this.dismember(BRUTE)

/// Like Move proc but register when user wear kusarigama tail.
/obj/item/energy_kusarigama_fundo/proc/on_move(mob/living/who_move)
	SIGNAL_HANDLER

	if(kusarigama_head.living_equip_head && kusarigama_head.living_equip_tail)
		kusarigama_head.chain_check()
		return
	if(get_dist(src, kusarigama_head) < kusarigama_head.chain_range)
		kusarigama_head.chain_check()
		return
	if(isnull(kusarigama_head.living_equip_tail))
		kusarigama_head.chain_check()
		return
	var/turf/move_here_turf = get_step(kusarigama_head, get_dir(kusarigama_head, who_move))
	var/obj/machinery/door/airlock/locate_aitlock = locate() in move_here_turf
	if(isclosedturf(move_here_turf) || (locate(/obj/structure/window) in move_here_turf) || locate_aitlock?.density)
		move_here_turf = calculate_if_closed_turf(kusarigama_head, src)
	kusarigama_head.forceMove(move_here_turf)
	for(var/mob/living/someone_to_hit in move_here_turf)
		if(someone_to_hit == kusarigama_head.living_equip_tail)
			continue
		if(someone_to_hit.mind?.has_antag_datum(/datum/antagonist/ninja))
			continue
		slid_effect(someone_to_hit)
	kusarigama_head.chain_check()

/// If turf to ForceMove kusarigama tail is closed we will try to find open turf with min dist to kusarigama head.
/obj/item/energy_kusarigama_fundo/proc/calculate_if_closed_turf(atom/movable/what_moving, atom/movable/direct_to_move)
	var/turf/resolve
	var/min_dist = INFINITY
	for(var/turf/open/open_turf in range(1, what_moving))
		if(locate(/obj/structure/window) in open_turf)
			continue
		var/obj/machinery/door/airlock/locate_aitlock = locate() in open_turf
		if(locate_aitlock?.density)
			continue
		if(get_dist(open_turf, direct_to_move) < min_dist)
			resolve = open_turf
			min_dist = get_dist(open_turf, direct_to_move)
	return resolve
