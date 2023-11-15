/datum/smite/ghost_control
	name = "Ghost Control"

/datum/smite/ghost_control/effect(client/user, mob/living/target)
	target.AddComponent(/datum/component/deadchat_control/cardinal_movement, ANARCHY_MODE, list(
		"clap" = CALLBACK(target, TYPE_PROC_REF(/mob, emote), "clap"),
		"cry" = CALLBACK(target, TYPE_PROC_REF(/mob, emote), "cry"),
		"flip" = CALLBACK(target, TYPE_PROC_REF(/mob, emote), "flip"),
		"laugh" = CALLBACK(target, TYPE_PROC_REF(/mob, emote), "laugh"),
		"scream" = CALLBACK(target, TYPE_PROC_REF(/mob, emote), "scream"),
		"spin" = CALLBACK(target, TYPE_PROC_REF(/mob, emote), "spin"),
		"swear" = CALLBACK(target, TYPE_PROC_REF(/mob, emote), "swear"),
		"drop" = CALLBACK(target, TYPE_PROC_REF(/mob, drop_all_held_items)),
		"fall" = CALLBACK(target, TYPE_PROC_REF(/mob/living, Knockdown), 1 SECONDS),
		"stand" = CALLBACK(target, TYPE_PROC_REF(/mob/living, resist_buckle)),
		"throw" = CALLBACK(target, TYPE_PROC_REF(/mob, throw_item), get_edge_target_turf(target, pick(GLOB.alldirs))),
		"shove" = CALLBACK(src, PROC_REF(ghost_shove), target),
		"sit" = CALLBACK(src, PROC_REF(ghost_sit), target),
		"run" = CALLBACK(src, PROC_REF(ghost_speed), target, MOVE_INTENT_RUN),
		"walk" = CALLBACK(src, PROC_REF(ghost_speed), target, MOVE_INTENT_WALK),
		), 7 SECONDS)

	to_chat(target, span_revenwarning("You feel a ghastly presence!!!"))


/datum/smite/ghost_control/proc/ghost_shove(mob/living/carbon/target)
	if(!istype(target) || target.get_active_held_item())
		return
	var/list/shoveables = list()
	for(var/mob/living/victim in orange(1, target))
		shoveables += victim
	if(!length(shoveables))
		return
	var/mob/living/shove_me = pick(shoveables)
	target.UnarmedAttack(shove_me, proximity_flag = TRUE, modifiers = list("right" = TRUE))

/datum/smite/ghost_control/proc/ghost_sit(mob/living/target)
	if(HAS_TRAIT(target, TRAIT_IMMOBILIZED))
		return
	var/list/chairs = list()
	for(var/obj/structure/chair/possible_chair in range(1, target))
		chairs += possible_chair
	if(!length(chairs))
		return
	var/obj/structure/chair/sitting_chair = pick(chairs)
	sitting_chair.buckle_mob(target, check_loc = FALSE)

/datum/smite/ghost_control/proc/ghost_speed(mob/living/target, new_speed)
	if(target.move_intent == new_speed)
		return
	target.toggle_move_intent()
