// Ratwood's practice dummy (game/objects/structures/fluff.dm, /obj/structure/fluff/statue/tdummy attackby()): out of combat
// mode, a weapon with a skill trains on it a stroke a second until interrupted. Each stroke wears the blade and tires; with
// luck (fortune) the stroke teaches the weapon's skill by intelligence, up to Ratwood's cap (can_train_combat_skill() with
// SKILL_LEVEL_APPRENTICE), else the dummy ripostes and knocks the trainee back. Numbers in values/combat.txt, "Weapons and gear".

#define DUMMY_HIT_SOUNDS list('modular_redtard/combat/sound/hits/education1.ogg', 'modular_redtard/combat/sound/hits/education2.ogg', 'modular_redtard/combat/sound/hits/education3.ogg')
#define DUMMY_RIPOSTE_SOUND 'modular_redtard/combat/sound/hits/stomp.ogg'
#define DUMMY_TRAINED "trained"
#define DUMMY_RIPOSTED "riposted"
#define DUMMY_LEARNED_ALL "learned_all"
#define DUMMY_FELL "fell"

/obj/structure/fluff/statue/tdummy/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode || !tool.associated_skill || !user.mind)
		return ..()
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return ITEM_INTERACT_BLOCKING
	INVOKE_ASYNC(src, PROC_REF(rogue_training), user, tool)
	return ITEM_INTERACT_SUCCESS

/// Ratwood's loop: a stroke a second while the trainee stays at it.
/obj/structure/fluff/statue/tdummy/proc/rogue_training(mob/living/user, obj/item/weapon)
	user.visible_message(span_notice("[user] begins training on [src]..."))
	while(do_after(user, rogue_value("dummy_stroke_time"), target = src))
		if(QDELETED(weapon) || !user.is_holding(weapon))
			return
		var/result = rogue_training_stroke(user, weapon)
		if(result == DUMMY_FELL || result == DUMMY_LEARNED_ALL)
			return

/// One stroke on the dummy. Returns DUMMY_TRAINED, DUMMY_RIPOSTED, DUMMY_LEARNED_ALL or DUMMY_FELL.
/obj/structure/fluff/statue/tdummy/proc/rogue_training_stroke(mob/living/user, obj/item/weapon)
	if(user.body_position == LYING_DOWN)
		to_chat(user, span_warning("You are knocked down and stop training."))
		return DUMMY_FELL
	user.changeNext_move(CLICK_CD_MELEE)
	if(weapon.max_blade_int)
		weapon.rogue_dull(rogue_value("dummy_blade_wear"))
	user.adjust_stamina_loss(rand(rogue_value("dummy_stamina_min"), rogue_value("dummy_stamina_max")))
	var/skill = weapon.associated_skill
	if(user.rogue_learned_rank(skill) >= rogue_value("dummy_train_cap"))
		to_chat(user, span_warning("I've learned all I can from doing this, it's time for the real thing."))
		return DUMMY_LEARNED_ALL
	var/intelligence = user.rogue_stat(ROGUE_STAT_INTELLIGENCE)
	// Ratwood: fortune tenths of a hundred, at most 99%; no learning at all below 3 intelligence.
	var/chance = min(user.rogue_stat(ROGUE_STAT_FORTUNE) * rogue_value("dummy_chance_per_fortune"), rogue_value("dummy_chance_max"))
	if(intelligence < rogue_value("dummy_min_intelligence"))
		chance = 0
	flick(pick("p_dummy_smashed", "p_dummy_smashedalt"), src)
	if(prob(chance) && !user.buckled)
		user.visible_message(span_info("[user] trains on [src]!"))
		var/experience = intelligence * rogue_value("dummy_xp_per_int")
		if(experience > 0)
			user.rogue_adjust_experience(skill, experience)
		playsound(loc, pick(DUMMY_HIT_SOUNDS), rand(50, 100), FALSE)
		return DUMMY_TRAINED
	user.visible_message(span_danger("[user] trains on [src], but [src] ripostes!"))
	user.Knockdown(rogue_value("dummy_riposte_knockdown"))
	user.throw_at(get_step(user, get_dir(src, user)), 2, 2, user, spin = FALSE)
	playsound(loc, DUMMY_RIPOSTE_SOUND, 100, TRUE, -1)
	return DUMMY_RIPOSTED

#undef DUMMY_HIT_SOUNDS
#undef DUMMY_RIPOSTE_SOUND
#undef DUMMY_TRAINED
#undef DUMMY_RIPOSTED
#undef DUMMY_LEARNED_ALL
#undef DUMMY_FELL
