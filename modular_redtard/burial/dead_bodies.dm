/// Ratwood's dead bodies of the map (structures/roguetown/deadbodies.dm): each lies in one of its kind's poses and can be
/// searched once, five seconds with a hand. The unlucky (fortune under 10) come up empty two times in five; the rest pull
/// out one thing, two from fortune 13, three from 16, and from fortune 14 a body with a lucky table gives from it. The kinds
/// of the dead, their poses and their tables are Ratwood's and come from the porter (rockhill/ported/structures.dm:
/// rockhill_loot, rockhill_loot_lucky, rockhill_poses from loot_table, loot_table_lucky, pose_states).

/// Ratwood CLICK_CD_INTENTCAP: the pause before a search begins.
#define ROGUE_SEARCH_CLICK_CD 6

/obj/structure/deadbody
	/// What a search may turn up, by weight (Ratwood loot_table).
	var/list/rockhill_loot
	/// What a lucky search turns up instead, by weight (Ratwood loot_table_lucky); none for some kinds.
	var/list/rockhill_loot_lucky
	/// The poses its kind lies in (Ratwood pose_states).
	var/list/rockhill_poses
	/// The one pose it always lies in, if set (Ratwood forced_pose).
	var/rockhill_forced_pose
	/// Searched already (Ratwood body_looted).
	var/rogue_looted = FALSE

/obj/structure/deadbody/Initialize(mapload)
	. = ..()
	if(rockhill_forced_pose)
		icon_state = rockhill_forced_pose
	else if(length(rockhill_poses))
		icon_state = pick(rockhill_poses)

/obj/structure/deadbody/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	if(rogue_looted)
		to_chat(user, span_warning("There's nothing left worth taking."))
		return TRUE
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(rogue_search), user)
	return TRUE

/// Ratwood deadbody attack_hand(): five seconds of rummaging through the body.
/obj/structure/deadbody/proc/rogue_search(mob/living/user)
	user.changeNext_move(ROGUE_SEARCH_CLICK_CD)
	user.visible_message(span_notice("[user] begins searching the body."), span_notice("You begin searching the body."))
	if(!do_after(user, rogue_value("body_search_time"), target = src))
		return
	if(rogue_looted)
		to_chat(user, span_warning("There's nothing left worth taking."))
		return
	playsound(src, pick('modular_redtard/burial/sound/rummaging-01.ogg', 'modular_redtard/burial/sound/rummaging-02.ogg', 'modular_redtard/burial/sound/rummaging-03.ogg'), 50, FALSE)
	rogue_loot_body(user)
	user.visible_message(span_notice("[user] finishes searching [src]."), span_notice("You finish searching [src]."))

/// What the search turns up, into the searcher's hands (or at their feet); the body is looted after. Returns how many
/// things were found.
/obj/structure/deadbody/proc/rogue_loot_body(mob/living/user)
	rogue_looted = TRUE
	var/fortune = user.rogue_stat(ROGUE_STAT_FORTUNE)
	if(fortune < rogue_value("body_unlucky_fortune") && prob(rogue_value("body_unlucky_empty_chance")))
		to_chat(user, span_warning("You come up empty. Nothing but dust and bad luck."))
		return 0
	var/finds = 1
	if(fortune >= rogue_value("body_three_finds_fortune"))
		finds = 3
	else if(fortune >= rogue_value("body_two_finds_fortune"))
		finds = 2
	var/lucky = fortune >= rogue_value("body_lucky_fortune") && length(rockhill_loot_lucky)
	var/list/table = lucky ? rockhill_loot_lucky : rockhill_loot
	if(!length(table))
		return 0
	var/found_count = 0
	for(var/i in 1 to finds)
		var/item_type = pick_weight(table)
		if(!ispath(item_type, /obj/item))
			continue
		var/obj/item/found = new item_type(user.loc)
		user.put_in_hands(found)
		found_count++
		if(lucky)
			to_chat(user, span_notice("A lucky find! You pull out [found]."))
		else
			to_chat(user, span_notice("You pull out [found]."))
	return found_count

#undef ROGUE_SEARCH_CLICK_CD
