/// Butchering (Ratwood simple_animal.dm MiddleClick(), butcher() and butcher_summary(); roguetown/meathook.dm). A dead beast is cut
/// up with a short sharp blade or with shears: Alt+click on the carcass (Ratwood's middle click is the module's kick). The butcher
/// works it open first - a while unskilled, at once with any Butchering, on a meathook or with shears - then takes off its yield kind by
/// kind, the lists the porter brings as rogue_butcher_results, rogue_botched_butcher_results and rogue_perfect_butcher_results
/// (rockhill/port_data.dm, kept out of TG's butcher_results so that TG's gib() does not spill them). Every cut takes a while, shorter
/// for a better butcher and on a meathook; below Journeyman a cut may be botched (the botched yield of that kind, or none), from
/// Journeyman on it may be perfect (the perfect yield); every cut teaches Butchering by intelligence. Meat of a beast dead for long
/// comes off rotten. The work stops when the butcher does and goes on later where it stopped; the last cut leaves nothing of the
/// carcass but its tack. A beast hung on a meathook yields a piece more of every food.

#define BUTCHERING_SKILL /datum/attribute/skill/labor/butchering
#define BUTCHER_SOUND 'modular_redtard/husbandry/sound/gross.ogg'
#define MEATHOOK_SOUND 'modular_redtard/husbandry/sound/butcher.ogg'
/// What became of a cut.
#define BUTCHER_CUT_BOTCHED "botched"
#define BUTCHER_CUT_NORMAL "normal"
#define BUTCHER_CUT_PERFECT "perfect"

/// Numbers of the mechanics registry (config/redtard/mechanics/values/husbandry.txt).
#define BUTCHER_START_TIME rogue_value("butcher_start_time")
#define BUTCHER_START_TIME_PER_RANK rogue_value("butcher_start_time_per_rank")
#define BUTCHER_CUT_TIME rogue_value("butcher_cut_time")
#define BUTCHER_CUT_TIME_PER_RANK rogue_value("butcher_cut_time_per_rank")
#define BUTCHER_CUT_TIME_MIN rogue_value("butcher_cut_time_min")
#define BUTCHER_MEATHOOK_FACTOR rogue_value("butcher_meathook_factor")
#define BUTCHER_BOTCH_CHANCE rogue_value("butcher_botch_chance")
#define BUTCHER_BOTCH_PER_RANK rogue_value("butcher_botch_per_rank")
#define BUTCHER_BOTCH_RANK rogue_value("butcher_botch_rank")
#define BUTCHER_PERFECT_JOURNEYMAN rogue_value("butcher_perfect_journeyman")
#define BUTCHER_PERFECT_EXPERT rogue_value("butcher_perfect_expert")
#define BUTCHER_PERFECT_MASTER rogue_value("butcher_perfect_master")
#define BUTCHER_ROT_TIME rogue_value("butcher_rot_time")
#define BUTCHER_XP_PER_INTELLIGENCE rogue_value("butcher_xp_per_intelligence")
#define MEATHOOK_HANG_TIME rogue_value("meathook_hang_time")
#define MEATHOOK_UNHOOK_TIME rogue_value("meathook_unhook_time")
#define MEATHOOK_STRUGGLE_TIME rogue_value("meathook_struggle_time")
#define MEATHOOK_DAMAGE rogue_value("meathook_damage")
#define MEATHOOK_FALL_TIME rogue_value("meathook_fall_time")
#define MEATHOOK_MEAT_BONUS rogue_value("meathook_meat_bonus")

/mob/living/basic/rockhill
	/// Someone is cutting the carcass up right now; a second butcher waits for the first.
	var/rogue_butcher_busy = FALSE

/// Ratwood MiddleClick() on a dead beast: with a short sharp blade or shears in hand, the butcher cuts it up.
/mob/living/basic/rockhill/click_alt(mob/user)
	if(stat != DEAD || !length(rogue_butcher_results) || !isliving(user) || !rogue_husbandry_enabled())
		return NONE
	var/mob/living/butcher = user
	var/obj/item/tool = butcher.get_active_held_item()
	if(!rogue_butchers_with(tool))
		return NONE
	if(rogue_butcher_busy)
		to_chat(butcher, span_warning("Someone is already butchering [src]."))
		return CLICK_ACTION_BLOCKING
	INVOKE_ASYNC(src, PROC_REF(rogue_start_butchering), butcher, tool)
	return CLICK_ACTION_SUCCESS

/// Ratwood MiddleClick(): what cuts a carcass up - a short blade with a sharp grip, or shears.
/proc/rogue_butchers_with(obj/item/tool)
	if(!tool)
		return FALSE
	return istype(tool, /obj/item/contraption/shears) || (tool.get_sharpness() && tool.wlength == WLENGTH_SHORT)

/// Ratwood MiddleClick(): the butcher works the carcass open - a while unskilled, at once with any Butchering, on a meathook or with
/// shears - and cuts it up.
/mob/living/basic/rockhill/proc/rogue_start_butchering(mob/living/butcher, obj/item/tool)
	var/quick = istype(buckled, /obj/structure/meathook) || istype(tool, /obj/item/contraption/shears)
	var/opening = quick ? 0 : BUTCHER_START_TIME - butcher.rogue_learned_rank(BUTCHERING_SKILL) * BUTCHER_START_TIME_PER_RANK
	visible_message(span_notice("[butcher] begins to [quick ? "efficiently " : ""]butcher [src]..."))
	playsound(src, BUTCHER_SOUND, 100, FALSE)
	rogue_butcher_busy = TRUE
	if(opening <= 0 || do_after(butcher, opening, target = src))
		rogue_butcher(butcher, quick)
	if(!QDELETED(src))
		rogue_butcher_busy = FALSE

/// Ratwood butcher(): cut by cut, every kind of the carcass's yield comes off, each cut a while long; the work stops when the butcher
/// stops, with a word on how it went, and the last cut leaves nothing of the carcass.
/mob/living/basic/rockhill/proc/rogue_butcher(mob/living/butcher, quick = FALSE)
	var/rank = butcher.rogue_learned_rank(BUTCHERING_SKILL)
	var/cut_time = max(BUTCHER_CUT_TIME - rank * BUTCHER_CUT_TIME_PER_RANK, BUTCHER_CUT_TIME_MIN)
	if(quick)
		cut_time *= BUTCHER_MEATHOOK_FACTOR
	var/botch_chance = length(rogue_botched_butcher_results) ? rogue_butcher_botch_chance(rank) : 0
	var/perfect_chance = length(rogue_perfect_butcher_results) ? rogue_butcher_perfect_chance(rank) : 0
	var/rotten = world.time - timeofdeath >= BUTCHER_ROT_TIME
	var/list/cuts = list(BUTCHER_CUT_BOTCHED = 0, BUTCHER_CUT_NORMAL = 0, BUTCHER_CUT_PERFECT = 0)
	for(var/path in rogue_butcher_results)
		if(!do_after(butcher, cut_time, target = src) || QDELETED(src) || stat != DEAD)
			if(QDELETED(src))
				return
			var/done = rogue_butcher_summary(cuts, botch_chance, perfect_chance)
			var/stop_message = done ? "I stop butchering: [done]." : "I stop butchering for now."
			to_chat(butcher, span_notice(stop_message))
			return
		cuts[rogue_cut_off(path, botch_chance, perfect_chance, rotten)] += 1
		butcher.rogue_craft_experience(BUTCHERING_SKILL, butcher.rogue_stat(ROGUE_STAT_INTELLIGENCE) * BUTCHER_XP_PER_INTELLIGENCE)
		playsound(src, BUTCHER_SOUND, 100, FALSE)
	if(length(rogue_butcher_results))
		return
	to_chat(butcher, span_notice("I finish butchering: [rogue_butcher_summary(cuts, botch_chance, perfect_chance)]."))
	gib()

/// Ratwood butcher(), one cut: a botch yields the botched amount of the kind (or none, if the botched yield lacks it), a perfect cut the
/// perfect amount, any other the usual one. The pieces come off bloodied, the meat of a beast dead too long rotten. Returns what became
/// of the cut (BUTCHER_CUT_*).
/mob/living/basic/rockhill/proc/rogue_cut_off(path, botch_chance, perfect_chance, rotten = FALSE)
	var/amount = rogue_butcher_results[path]
	. = BUTCHER_CUT_NORMAL
	if(prob(botch_chance))
		. = BUTCHER_CUT_BOTCHED
		amount = LAZYACCESS(rogue_botched_butcher_results, path) || 0
	else if(perfect_chance && LAZYFIND(rogue_perfect_butcher_results, path) && prob(perfect_chance))
		. = BUTCHER_CUT_PERFECT
		amount = rogue_perfect_butcher_results[path]
	rogue_butcher_results -= path
	var/atom/spot = drop_location()
	for(var/piece in 1 to amount)
		var/atom/movable/cut = new path(spot)
		if(!isitem(cut))
			continue
		var/obj/item/meat = cut
		meat.add_mob_blood(src)
		if(rotten && istype(meat, /obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/food = meat
			food.become_rotten()

/// Ratwood butcher(): the chance in percent that a cut is botched, by Butchering rank - none from Journeyman on.
/proc/rogue_butcher_botch_chance(rank)
	if(rank >= BUTCHER_BOTCH_RANK)
		return 0
	return max(BUTCHER_BOTCH_CHANCE - BUTCHER_BOTCH_PER_RANK * rank, 0)

/// Ratwood butcher(): the chance in percent that a cut is perfect, by Butchering rank - none below Journeyman.
/proc/rogue_butcher_perfect_chance(rank)
	if(rank >= ROGUE_RANK_MASTER)
		return BUTCHER_PERFECT_MASTER
	if(rank >= ROGUE_RANK_EXPERT)
		return BUTCHER_PERFECT_EXPERT
	if(rank >= ROGUE_RANK_JOURNEYMAN)
		return BUTCHER_PERFECT_JOURNEYMAN
	return 0

/// Ratwood butcher_summary(): "2 botched (70%), 3 normal, 1 perfect (10%)"; empty if nothing was cut.
/proc/rogue_butcher_summary(list/cuts, botch_chance, perfect_chance)
	var/list/parts = list()
	if(cuts[BUTCHER_CUT_BOTCHED])
		parts += "[cuts[BUTCHER_CUT_BOTCHED]] botched ([botch_chance]%)"
	if(cuts[BUTCHER_CUT_NORMAL])
		parts += "[cuts[BUTCHER_CUT_NORMAL]] normal"
	if(cuts[BUTCHER_CUT_PERFECT])
		parts += "[cuts[BUTCHER_CUT_PERFECT]] perfect ([perfect_chance]%)"
	return jointext(parts, ", ")

/// Ratwood meathook: a beast on the hook gives a piece more of every food still to come off it, and a piece less once taken down.
/mob/living/basic/rockhill/proc/rogue_meathook_bonus(amount)
	for(var/path in rogue_butcher_results)
		if(ispath(path, /obj/item/reagent_containers/food/snacks))
			rogue_butcher_results[path] = max(rogue_butcher_results[path] + amount, 0)

/// Ratwood's meathook (roguetown/meathook.dm): a beast dragged up to it is hung on it for butchering - a piece more of every food, every
/// cut a quarter faster and no working it open. Pulling it down takes a long while; a living beast hung on it is hurt, and falls off
/// hurt. Ratwood also hangs people on it; here only beasts.
/obj/structure/meathook
	can_buckle = TRUE
	buckle_prevents_pull = TRUE
	max_buckled_mobs = 1

/obj/structure/meathook/examine(mob/user)
	. = ..()
	. += span_notice("Improves the yield of butchering. Also increases speed by 25%.")

/// Ratwood attack_hand(): with a beast in tow, a hand on the hook hangs it.
/obj/structure/meathook/attack_hand(mob/user, list/modifiers)
	if(!isliving(user) || has_buckled_mobs() || !istype(user.pulling, /mob/living/basic/rockhill) || !rogue_husbandry_enabled())
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rogue_hang), user, user.pulling)
	return TRUE

/// The hand that holds the beast (the module's grip) hangs it as well.
/obj/structure/meathook/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/hand_item/rogue_grab) || has_buckled_mobs() || !istype(user.pulling, /mob/living/basic/rockhill) || !rogue_husbandry_enabled())
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rogue_hang), user, user.pulling)
	return ITEM_INTERACT_SUCCESS

/// Ratwood attack_hand(): the beast is hung on the hook after a moment's work.
/obj/structure/meathook/proc/rogue_hang(mob/living/user, mob/living/basic/rockhill/beast)
	beast.visible_message(span_danger("[user] starts hanging [beast] on [src]!"), span_danger("[user] starts hanging me on [src]!"))
	if(!do_after(user, MEATHOOK_HANG_TIME, target = src))
		return
	if(QDELETED(beast) || has_buckled_mobs() || beast.buckled || user.pulling != beast)
		return
	beast.forceMove(drop_location())
	if(!buckle_mob(beast, force = TRUE))
		return
	playsound(src, MEATHOOK_SOUND, 25, TRUE)
	beast.visible_message(span_danger("[user] hangs [beast] on [src]!"), span_danger("[user] hangs me on [src]!"))
	beast.add_splatter_floor()
	if(beast.stat != DEAD)
		beast.adjust_brute_loss(MEATHOOK_DAMAGE)

/// Nobody climbs onto the hook (Ratwood user_buckle_mob()).
/obj/structure/meathook/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	return FALSE

/// Ratwood user_unbuckle_mob(): pulling a beast down takes a long while, and so does a beast's struggle to break free, which hurts it;
/// it falls off hurt and stunned.
/obj/structure/meathook/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(buckled_mob != user)
		buckled_mob.visible_message(span_notice("[user] is trying to pull [buckled_mob] free of [src]!"), span_notice("[user] is trying to pull me off [src]! It hurts!"))
		if(!do_after(user, MEATHOOK_UNHOOK_TIME, target = src))
			if(buckled_mob.buckled == src)
				buckled_mob.visible_message(span_notice("[user] fails to free [buckled_mob]!"), span_notice("[user] fails to pull me off of [src]!"))
			return null
	else
		buckled_mob.visible_message(span_warning("[buckled_mob] struggles to break free from [src]!"), span_notice("I struggle to break free from [src]!"))
		buckled_mob.adjust_brute_loss(MEATHOOK_DAMAGE)
		if(!do_after(buckled_mob, MEATHOOK_STRUGGLE_TIME, target = src))
			if(buckled_mob.buckled == src)
				to_chat(buckled_mob, span_warning("I fail to free myself!"))
			return null
	if(buckled_mob.buckled != src)
		return null
	. = unbuckle_mob(buckled_mob, force = TRUE)
	buckled_mob.visible_message(span_danger("[buckled_mob] falls free of [src]!"))
	if(buckled_mob.stat != DEAD)
		buckled_mob.adjust_brute_loss(MEATHOOK_DAMAGE)
		buckled_mob.AdjustParalyzed(MEATHOOK_FALL_TIME)

/// Hung: the beast turns head down and gives more meat.
/obj/structure/meathook/post_buckle_mob(mob/living/hung)
	. = ..()
	var/mob/living/basic/rockhill/beast = hung
	if(istype(beast))
		beast.rogue_meathook_bonus(MEATHOOK_MEAT_BONUS)
	hung.setDir(SOUTH)
	var/matrix/head_down = matrix(hung.transform)
	head_down.Turn(90)
	animate(hung, transform = head_down, time = 0.3 SECONDS)

/// Taken down, by hand, by its struggle or with the hook gone: the beast turns back and the extra meat is gone with the hook.
/obj/structure/meathook/post_unbuckle_mob(mob/living/hung)
	. = ..()
	var/mob/living/basic/rockhill/beast = hung
	if(istype(beast))
		beast.rogue_meathook_bonus(-MEATHOOK_MEAT_BONUS)
	var/matrix/upright = matrix(hung.transform)
	upright.Turn(-90)
	animate(hung, transform = upright, time = 0.3 SECONDS)

#undef BUTCHERING_SKILL
#undef BUTCHER_SOUND
#undef MEATHOOK_SOUND
#undef BUTCHER_CUT_BOTCHED
#undef BUTCHER_CUT_NORMAL
#undef BUTCHER_CUT_PERFECT
#undef BUTCHER_START_TIME
#undef BUTCHER_START_TIME_PER_RANK
#undef BUTCHER_CUT_TIME
#undef BUTCHER_CUT_TIME_PER_RANK
#undef BUTCHER_CUT_TIME_MIN
#undef BUTCHER_MEATHOOK_FACTOR
#undef BUTCHER_BOTCH_CHANCE
#undef BUTCHER_BOTCH_PER_RANK
#undef BUTCHER_BOTCH_RANK
#undef BUTCHER_PERFECT_JOURNEYMAN
#undef BUTCHER_PERFECT_EXPERT
#undef BUTCHER_PERFECT_MASTER
#undef BUTCHER_ROT_TIME
#undef BUTCHER_XP_PER_INTELLIGENCE
#undef MEATHOOK_HANG_TIME
#undef MEATHOOK_UNHOOK_TIME
#undef MEATHOOK_STRUGGLE_TIME
#undef MEATHOOK_DAMAGE
#undef MEATHOOK_FALL_TIME
#undef MEATHOOK_MEAT_BONUS
