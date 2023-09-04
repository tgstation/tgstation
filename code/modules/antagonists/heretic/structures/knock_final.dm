/obj/structure/knock_tear
	name = "???"
	desc = "It stares back. Theres no reason to remain. Run."
	max_integrity = INFINITE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/obj/anomaly.dmi'
	icon_state = "bhole3"
	color = "#53277E"
	light_color = "#53277E" //cooler purple
	light_range = 20
	anchored = TRUE
	density = FALSE
	layer = HIGH_PIPE_LAYER //0.01 above sigil layer used by heretic runes
	var/datum/mind/ascendee
	///a static list of heretic summons, this shouldnt even matter enough to be static but whatever
	var/static/list/monster_types

/obj/structure/knock_tear/Initialize(mapload, ascendant)
	. = ..()
	transform *= 3
	if(!monster_types)
		monster_types = subtypesof(/mob/living/simple_animal/hostile/heretic_summon) - /mob/living/simple_animal/hostile/heretic_summon/armsy/prime
	if(ascendant)
		ascendee = ascendant
		RegisterSignal(ascendee.current, COMSIG_ATOM_EXAMINE, PROC_REF(master_examine))
	INVOKE_ASYNC(src, PROC_REF(poll_ghosts))

/obj/structure/knock_tear/proc/poll_ghosts()
	var/list/candidates = poll_ghost_candidates("Would you like to be a random eldritch monster attacking the crew?", ROLE_SENTIENCE, ROLE_SENTIENCE, 10 SECONDS, POLL_IGNORE_HERETIC_MONSTER)
	while(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick_n_take(candidates)
		ghost_to_monster(C, FALSE)

/obj/structure/knock_tear/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	ghost_to_monster(user)

/obj/structure/knock_tear/proc/ghost_to_monster(mob/dead/observer/user, should_ask = TRUE)
	if(should_ask)
		var/ask = tgui_alert(user, "Become a monster?", "Ascended Rift", list("Yes", "No"))
		if(ask != "Yes" || QDELETED(src) || QDELETED(user))
			return FALSE
	var/monster_type = pick(monster_types)
	var/mob/living/monster = new monster_type(loc)
	monster.key = user.key
	monster.set_name()
	var/datum/antagonist/heretic_monster/woohoo_free_antag = new(src)
	monster.mind.add_antag_datum(woohoo_free_antag)
	if(ascendee)
		monster.faction = ascendee.current.faction
		woohoo_free_antag.set_owner(ascendee)
	var/datum/objective/kill_all_your_friends = new()
	kill_all_your_friends.owner = monster.mind
	kill_all_your_friends.explanation_text = "The station's crew must be culled."
	kill_all_your_friends.completed = TRUE
	woohoo_free_antag.objectives += kill_all_your_friends

/obj/structure/knock_tear/proc/master_examine(datum/source, mob/examinee, list/text) //if we ascended it should be obvious that the ascendee is the heretic but some people are brainlets
	SIGNAL_HANDLER
	var/datum/antagonist/heretic_monster/monster = IS_HERETIC_MONSTER(examinee)
	if(monster && monster.master == ascendee)
		text += span_hypnophrase("This is your master!")

/obj/structure/knock_tear/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/obj/structure/knock_tear/Destroy(force) //this shouldnt happen but hey
	if(ascendee)
		UnregisterSignal(ascendee.current, COMSIG_ATOM_EXAMINE)
		ascendee = null
	return ..()
