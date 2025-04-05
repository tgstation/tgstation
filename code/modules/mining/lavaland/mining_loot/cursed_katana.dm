#define ATTACK_STRIKE "Hilt Strike"
#define ATTACK_SLICE "Wide Slice"
#define ATTACK_DASH "Dash Attack"
#define ATTACK_CUT "Tendon Cut"
#define ATTACK_CLOAK "Dark Cloak"
#define ATTACK_SHATTER "Shatter"

/obj/item/organ/cyberimp/arm/shard
	name = "dark spoon shard"
	desc = "An eerie metal shard surrounded by dark energies...of soup drinking. You probably don't think you should have been able to find this."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "cursed_katana_organ"
	organ_flags = ORGAN_ORGANIC | ORGAN_FROZEN | ORGAN_UNREMOVABLE
	items_to_create = list(/obj/item/kitchen/spoon)
	extend_sound = 'sound/items/unsheath.ogg'
	retract_sound = 'sound/items/sheath.ogg'

/obj/item/organ/cyberimp/arm/shard/attack_self(mob/user, modifiers)
	. = ..()
	to_chat(user, span_userdanger("The mass goes up your arm and goes inside it!"))
	playsound(user, 'sound/effects/magic/demon_consume.ogg', 50, TRUE)
	var/index = user.get_held_index_of_item(src)
	swap_zone(IS_LEFT_INDEX(index) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)

/obj/item/organ/cyberimp/arm/shard/screwdriver_act(mob/living/user, obj/item/screwtool)
	return

/obj/item/organ/cyberimp/arm/shard/katana
	name = "dark shard"
	desc = "An eerie metal shard surrounded by dark energies."
	items_to_create = list(/obj/item/cursed_katana)

/obj/item/organ/cyberimp/arm/shard/katana/Retract()
	var/obj/item/cursed_katana/katana = active_item
	if(!katana || katana.shattered)
		return FALSE
	if(!katana.drew_blood)
		to_chat(owner, span_userdanger("[katana] lashes out at you in hunger!"))
		playsound(owner, 'sound/effects/magic/demon_attack1.ogg', 50, TRUE)
		owner.apply_damage(25, BRUTE, hand, wound_bonus = 10, sharpness = SHARP_EDGED)
	katana.drew_blood = FALSE
	katana.wash(CLEAN_TYPE_BLOOD)
	return ..()

/obj/item/cursed_katana
	name = "cursed katana"
	desc = "A katana used to seal something vile away long ago. \
	Even with the weapon destroyed, all the pieces containing the creature have coagulated back together to find a new host."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "cursed_katana"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 15
	armour_penetration = 30
	block_chance = 30
	block_sound = 'sound/items/weapons/parry.ogg'
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_HUGE
	attack_verb_continuous = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "cut")
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | FREEZE_PROOF
	var/shattered = FALSE
	var/drew_blood = FALSE
	var/static/list/combo_list = list(
		ATTACK_STRIKE = list(COMBO_STEPS = list(LEFT_ATTACK, LEFT_ATTACK, RIGHT_ATTACK), COMBO_PROC = PROC_REF(strike)),
		ATTACK_SLICE = list(COMBO_STEPS = list(RIGHT_ATTACK, LEFT_ATTACK, LEFT_ATTACK), COMBO_PROC = PROC_REF(slice)),
		ATTACK_DASH = list(COMBO_STEPS = list(LEFT_ATTACK, RIGHT_ATTACK, RIGHT_ATTACK), COMBO_PROC = PROC_REF(dash)),
		ATTACK_CUT = list(COMBO_STEPS = list(RIGHT_ATTACK, RIGHT_ATTACK, LEFT_ATTACK), COMBO_PROC = PROC_REF(cut)),
		ATTACK_CLOAK = list(COMBO_STEPS = list(LEFT_ATTACK, RIGHT_ATTACK, LEFT_ATTACK, RIGHT_ATTACK), COMBO_PROC = PROC_REF(cloak)),
		ATTACK_SHATTER = list(COMBO_STEPS = list(RIGHT_ATTACK, LEFT_ATTACK, RIGHT_ATTACK, LEFT_ATTACK), COMBO_PROC = PROC_REF(shatter)),
	)
	var/list/alt_continuous = list("stabs", "pierces", "impales")
	var/list/alt_simple = list("stab", "pierce", "impale")

/obj/item/cursed_katana/Initialize(mapload)
	. = ..()
	alt_continuous = string_list(alt_continuous)
	alt_simple = string_list(alt_simple)
	AddComponent(/datum/component/alternative_sharpness, SHARP_POINTY, alt_continuous, alt_simple)
	AddComponent( \
		/datum/component/combo_attacks, \
		combos = combo_list, \
		max_combo_length = 4, \
		examine_message = span_notice("<i>There seem to be inscriptions on it... you could examine them closer?</i>"), \
		reset_message = "you return to neutral stance", \
		can_attack_callback = CALLBACK(src, PROC_REF(can_combo_attack)) \
	)

/obj/item/cursed_katana/examine(mob/user)
	. = ..()
	. += drew_blood ? span_nicegreen("It's sated... for now.") : span_danger("It will not be sated until it tastes blood.")

/obj/item/cursed_katana/dropped(mob/user)
	. = ..()
	if(isturf(loc))
		qdel(src)

/obj/item/cursed_katana/attack(mob/living/target, mob/user, click_parameters)
	if(target.stat < DEAD && target != user)
		drew_blood = TRUE
		if(ismining(target))
			user.changeNext_move(CLICK_CD_RAPID)
	return ..()

/obj/item/cursed_katana/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == PROJECTILE_ATTACK || attack_type == LEAP_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight, and also you aren't going to really block someone full body tackling you with a sword
	return ..()

/obj/item/cursed_katana/proc/can_combo_attack(mob/user, mob/living/target)
	return target.stat != DEAD && target != user

/obj/item/cursed_katana/proc/strike(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] strikes [target] with [src]'s hilt!"),
		span_notice("You hilt strike [target]!"))
	to_chat(target, span_userdanger("You've been struck by [user]!"))
	playsound(src, 'sound/items/weapons/genhit3.ogg', 50, TRUE)
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(strike_throw_impact))
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	target.throw_at(throw_target, 5, 3, user, FALSE, gentle = TRUE)
	target.apply_damage(damage = 17, bare_wound_bonus = 10)
	to_chat(target, span_userdanger("You've been struck by [user]!"))
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)

/obj/item/cursed_katana/proc/strike_throw_impact(mob/living/source, atom/hit_atom, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(isclosedturf(hit_atom))
		source.apply_damage(damage = 5)
		if(ishostile(source))
			var/mob/living/simple_animal/hostile/target = source
			target.ranged_cooldown += 5 SECONDS
		else if(iscarbon(source))
			var/mob/living/carbon/target = source
			target.set_confusion_if_lower(8 SECONDS)
	return NONE

/obj/item/cursed_katana/proc/slice(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] does a wide slice!"),
		span_notice("You do a wide slice!"))
	playsound(src, 'sound/items/weapons/bladeslice.ogg', 50, TRUE)
	user.do_item_attack_animation(target, used_item = src, animation_type = ATTACK_ANIMATION_SLASH)
	var/turf/user_turf = get_turf(user)
	var/dir_to_target = get_dir(user_turf, get_turf(target))
	var/static/list/cursed_katana_slice_angles = list(0, -45, 45, -90, 90) //so that the animation animates towards the target clicked and not towards a side target
	for(var/iteration in cursed_katana_slice_angles)
		var/turf/turf = get_step(user_turf, turn(dir_to_target, iteration))
		user.do_attack_animation(turf, ATTACK_EFFECT_SLASH)
		for(var/mob/living/additional_target in turf)
			if(user.Adjacent(additional_target) && additional_target.density)
				additional_target.apply_damage(damage = 15, sharpness = SHARP_EDGED, bare_wound_bonus = 10)
				to_chat(additional_target, span_userdanger("You've been sliced by [user]!"))
	target.apply_damage(damage = 5, sharpness = SHARP_EDGED, wound_bonus = 10)

/obj/item/cursed_katana/proc/cloak(mob/living/target, mob/user)
	user.alpha = 150
	user.SetInvisibility(INVISIBILITY_OBSERVER, id=type) // so hostile mobs cant see us or target us
	user.add_sight(SEE_SELF) // so we can see us
	user.visible_message(span_warning("[user] vanishes into thin air!"),
		span_notice("You enter the dark cloak."))
	new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/effects/magic/smoke.ogg', 50, TRUE)
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/hostile_target = target
		if(hostile_target.target == user)
			hostile_target.LoseTarget()
	addtimer(CALLBACK(src, PROC_REF(uncloak), user), 5 SECONDS, TIMER_UNIQUE)

/obj/item/cursed_katana/proc/uncloak(mob/user)
	user.alpha = 255
	user.RemoveInvisibility(type)
	user.clear_sight(SEE_SELF)
	user.visible_message(span_warning("[user] appears from thin air!"),
		span_notice("You exit the dark cloak."))
	playsound(src, 'sound/effects/magic/summonitems_generic.ogg', 50, TRUE)
	new /obj/effect/temp_visual/mook_dust(get_turf(src))

/obj/item/cursed_katana/proc/cut(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] cuts [target]'s tendons!"),
		span_notice("You tendon cut [target]!"))
	to_chat(target, span_userdanger("Your tendons have been cut by [user]!"))
	user.do_item_attack_animation(target, used_item = src, animation_type = ATTACK_ANIMATION_SLASH)
	target.apply_damage(damage = 15, sharpness = SHARP_EDGED, wound_bonus = 15)
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(src, 'sound/items/weapons/rapierhit.ogg', 50, TRUE)
	var/datum/status_effect/stacking/saw_bleed/bloodletting/status = target.has_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting)
	if(!status)
		target.apply_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting, 6)
	else
		status.add_stacks(6)

/obj/item/cursed_katana/proc/dash(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] dashes through [target]!"),
		span_notice("You dash through [target]!"))
	to_chat(target, span_userdanger("[user] dashes through you!"))
	playsound(src, 'sound/effects/magic/blink.ogg', 50, TRUE)
	target.apply_damage(damage = 17, sharpness = SHARP_POINTY, bare_wound_bonus = 10)
	var/turf/dash_target = get_turf(target)
	for(var/distance in 0 to 8)
		var/turf/current_dash_target = dash_target
		current_dash_target = get_step(current_dash_target, user.dir)
		if(!current_dash_target.is_blocked_turf(TRUE))
			dash_target = current_dash_target
		else
			break
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(user))
	new /obj/effect/temp_visual/guardian/phase(dash_target)
	do_teleport(user, dash_target, channel = TELEPORT_CHANNEL_MAGIC)

/obj/item/cursed_katana/proc/shatter(mob/living/target, mob/user)
	user.visible_message(span_warning("[user] shatters [src] over [target]!"),
		span_notice("You shatter [src] over [target]!"))
	to_chat(target, span_userdanger("[user] shatters [src] over you!"))
	target.apply_damage(damage = ismining(target) ? 75 : 35, wound_bonus = 20)
	user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(src, 'sound/effects/glass/glassbr3.ogg', 100, TRUE)
	shattered = TRUE
	moveToNullspace()
	balloon_alert(user, "katana shattered")
	addtimer(CALLBACK(src, PROC_REF(coagulate), user), 45 SECONDS)

/obj/item/cursed_katana/proc/coagulate(mob/user)
	balloon_alert(user, "katana coagulated")
	shattered = FALSE
	playsound(src, 'sound/effects/magic/demon_consume.ogg', 50, TRUE)

#undef ATTACK_STRIKE
#undef ATTACK_SLICE
#undef ATTACK_DASH
#undef ATTACK_CUT
#undef ATTACK_CLOAK
#undef ATTACK_SHATTER
