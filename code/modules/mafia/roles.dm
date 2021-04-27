/datum/mafia_role
	var/name = "Assistant"
	var/desc = "You are a crewmember without any special abilities."
	var/win_condition = "kill all mafia and solo killing roles."
	var/team = MAFIA_TEAM_TOWN
	///how the random setup chooses which roles get put in
	var/role_type = TOWN_OVERFLOW

	var/player_key
	var/mob/living/carbon/human/body
	var/obj/effect/landmark/mafia/assigned_landmark

	///role flags (special status of roles like detection immune)
	var/role_flags = NONE
	///how many votes submitted when you vote. used in voting, but not victory
	var/vote_power = 1
	///how many votes your role COULD count for, now or later. used in checking victory
	var/vote_potential = 1
	///what they get equipped with when they are revealed
	var/datum/outfit/revealed_outfit = /datum/outfit/mafia/assistant
	///action = uses
	var/list/actions = list()
	var/list/targeted_actions = list()
	///what the role gets when it wins a game
	var/winner_award = /datum/award/achievement/mafia/assistant

	///so mafia have to also kill them to have a majority
	var/game_status = MAFIA_ALIVE

	///icon state in the mafia dmi of the hud of the role, used in the mafia ui
	var/hud_icon = "hudassistant"
	///icon state in the mafia dmi of the hud of the role, used in the mafia ui
	var/revealed_icon = "assistant"
	///set this to something cool for antagonists and their window will look different
	var/special_theme

	var/list/role_notes = list()


/datum/mafia_role/New(datum/mafia_controller/game)
	. = ..()

/**
 * Tests if a visitor can actually perform an action on this role. Verbose on purpose!
 *
 * Will return false if: Your visit is roleblocked, they have perished, or your visit was interrupted
 */
/datum/mafia_role/proc/can_action(datum/mafia_controller/game, datum/mafia_role/visitor, action)
	if(role_flags & ROLE_ROLEBLOCKED)
		to_chat(visitor,"<span class='danger'>Your [action] was blocked!</span>")
		return FALSE
	if(game_status != MAFIA_ALIVE) //They're already dead
		to_chat(visitor,"<span class='danger'>[body.real_name] perished before you could visit!</span>")
		return FALSE
	if(SEND_SIGNAL(src,COMSIG_MAFIA_ON_VISIT,game,visitor) & MAFIA_VISIT_INTERRUPTED) //visited a warden. something that prevents you by visiting that person
		to_chat(visitor,"<span class='danger'>Your [action] was interrupted!</span>")
		return FALSE
	return TRUE

/**
 * Tests kill immunities, if nothing prevents the kill, kills this role.
 *
 * Does not count as visiting, see visit proc.
 */
/datum/mafia_role/proc/kill(datum/mafia_controller/game, datum/mafia_role/attacker, lynch=FALSE)
	if(SEND_SIGNAL(src,COMSIG_MAFIA_ON_KILL,game,attacker,lynch) & MAFIA_PREVENT_KILL)
		return FALSE
	game_status = MAFIA_DEAD
	body.death()
	if(lynch)
		reveal_role(game, verbose = TRUE)
	if(!(player_key in game.spectators)) //people who played will want to see the end of the game more often than not
		game.spectators += player_key
	return TRUE

/datum/mafia_role/Destroy(force, ...)
	QDEL_NULL(body)
	. = ..()

/datum/mafia_role/proc/greet()
	SEND_SOUND(body, 'sound/ambience/ambifailure.ogg')
	to_chat(body,"<span class='danger'>You are the [name].</span>")
	to_chat(body,"<span class='danger'>[desc]</span>")
	switch(team)
		if(MAFIA_TEAM_MAFIA)
			to_chat(body,"<span class='danger'>You and your co-conspirators win if you outnumber crewmembers.</span>")
		if(MAFIA_TEAM_TOWN)
			to_chat(body,"<span class='danger'>You are a crewmember. Find out and lynch the changelings!</span>")
		if(MAFIA_TEAM_SOLO)
			to_chat(body,"<span class='danger'>You are not aligned to town or mafia. Accomplish your own objectives!</span>")
	to_chat(body, "<b>Be sure to read <a href=\"https://tgstation13.org/wiki/Mafia\">the wiki page</a> to learn more, if you have no idea what's going on.</b>")

/datum/mafia_role/proc/reveal_role(datum/mafia_controller/game, verbose = FALSE)
	if((role_flags & ROLE_REVEALED))
		return
	if(verbose)
		game.send_message("<span class='big bold notice'>It is revealed that the true role of [body] [game_status == MAFIA_ALIVE ? "is" : "was"] [name]!</span>")
	var/list/oldoutfit = body.get_equipped_items()
	for(var/thing in oldoutfit)
		qdel(thing)
	special_reveal_equip(game)
	body.equipOutfit(revealed_outfit)
	role_flags |= ROLE_REVEALED

/datum/mafia_role/proc/special_reveal_equip(datum/mafia_controller/game)
	return

/datum/mafia_role/proc/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	return

/datum/mafia_role/proc/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	if((role_flags & ROLE_ROLEBLOCKED))
		return FALSE
	return TRUE

/datum/mafia_role/proc/add_note(note)
	role_notes += note

/datum/mafia_role/proc/check_total_victory(alive_town, alive_mafia) //solo antags can win... solo.
	return FALSE

/datum/mafia_role/proc/block_team_victory(alive_town, alive_mafia) //solo antags can also block team wins.
	return FALSE

/datum/mafia_role/proc/show_help(clueless)
	var/list/result = list()
	var/team_desc = ""
	var/team_span = ""
	var/the = TRUE
	switch(team)
		if(MAFIA_TEAM_TOWN)
			team_desc = "Town"
			team_span = "nicegreen"
		if(MAFIA_TEAM_MAFIA)
			team_desc = "Mafia"
			team_span = "red"
		if(MAFIA_TEAM_SOLO)
			team_desc = "Nobody"
			team_span = "comradio"
			the = FALSE
	result += "<span class='notice'>The <span class='bold'>[name]</span> is aligned with [the ? "the " : ""]<span class='[team_span]'>[team_desc]</span></span>"
	result += "<span class='bold notice'>\"[desc]\"</span>"
	result += "<span class='notice'>[name] wins when they [win_condition]</span>"
	to_chat(clueless, result.Join("</br>"))

/datum/mafia_role/detective
	name = "Detective"
	desc = "You can investigate a single person each night to learn their team."
	revealed_outfit = /datum/outfit/mafia/detective
	role_type = TOWN_INVEST
	winner_award = /datum/award/achievement/mafia/detective

	hud_icon = "huddetective"
	revealed_icon = "detective"

	targeted_actions = list("Investigate")

	var/datum/mafia_role/current_investigation

/datum/mafia_role/detective/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,.proc/investigate)

/datum/mafia_role/detective/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/detective/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	if(!target || target.game_status != MAFIA_ALIVE)
		to_chat(body,"<span class='warning'>You can only investigate alive people.</span>")
		return
	to_chat(body,"<span class='warning'>You will investigate [target.body.real_name] tonight.</span>")
	current_investigation = target

/datum/mafia_role/detective/proc/investigate(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_investigation)
		return

	var/datum/mafia_role/target = current_investigation
	current_investigation = null
	if(!target.can_action(game, src, "investigation"))
		return
	if((target.role_flags & ROLE_UNDETECTABLE))
		to_chat(body,"<span class='warning'>Your investigations reveal that [target.body.real_name] is a true member of the station.</span>")
		add_note("N[game.turn] - [target.body.real_name] - Town")
	else
		var/team_text
		var/fluff
		switch(target.team)
			if(MAFIA_TEAM_TOWN)
				team_text = "Town"
				fluff = "a true member of the station."
			if(MAFIA_TEAM_MAFIA)
				team_text = "Mafia"
				fluff = "an unfeeling, hideous changeling!"
			if(MAFIA_TEAM_SOLO)
				team_text = "Solo"
				fluff = "a rogue, with their own objectives..."
		to_chat(body,"<span class='warning'>Your investigations reveal that [target.body.real_name] is [fluff]</span>")
		add_note("N[game.turn] - [target.body.real_name] - [team_text]")

/datum/mafia_role/psychologist
	name = "Psychologist"
	desc = "You can visit someone ONCE PER GAME to reveal their true role in the morning!"
	revealed_outfit = /datum/outfit/mafia/psychologist
	role_type = TOWN_INVEST
	winner_award = /datum/award/achievement/mafia/psychologist

	hud_icon = "hudpsychologist"
	revealed_icon = "psychologist"

	targeted_actions = list("Reveal")
	var/datum/mafia_role/current_target
	var/can_use = TRUE

/datum/mafia_role/psychologist/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,.proc/therapy_reveal)

/datum/mafia_role/psychologist/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!. || !can_use || game.phase == MAFIA_PHASE_NIGHT || target.game_status != MAFIA_ALIVE || (target.role_flags & ROLE_REVEALED) || target == src)
		return FALSE

/datum/mafia_role/psychologist/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	to_chat(body,"<span class='warning'>You will reveal [target.body.real_name] tonight.</span>")
	current_target = target

/datum/mafia_role/psychologist/proc/therapy_reveal(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_target)
		return
	var/datum/mafia_role/target = current_target
	current_target = null
	if(!target.can_action(game, src, "role reveal"))
		return
	add_note("N[game.turn] - [current_target.body.real_name] - Revealed true identity")
	to_chat(body,"<span class='warning'>You have revealed the true nature of the [current_target]!</span>")
	target.reveal_role(game, verbose = TRUE)
	can_use = FALSE

/datum/mafia_role/chaplain
	name = "Chaplain"
	desc = "You can communicate with spirits of the dead each night to discover dead crewmember roles."
	revealed_outfit = /datum/outfit/mafia/chaplain
	role_type = TOWN_INVEST
	hud_icon = "hudchaplain"
	revealed_icon = "chaplain"
	winner_award = /datum/award/achievement/mafia/chaplain

	targeted_actions = list("Pray")
	var/datum/mafia_role/current_target

/datum/mafia_role/chaplain/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,.proc/commune)

/datum/mafia_role/chaplain/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_DEAD && target != src && !(target.role_flags & ROLE_REVEALED)

/datum/mafia_role/chaplain/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	to_chat(body,"<span class='warning'>You will commune with the spirit of [target.body.real_name] tonight.</span>")
	current_target = target

/datum/mafia_role/chaplain/proc/commune(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_target)
		return
	var/datum/mafia_role/target = current_target
	current_target = null
	if(!target.can_action(game, src, "communion"))
		return
	if(target)
		to_chat(body,"<span class='warning'>You invoke spirit of [target.body.real_name] and learn their role was <b>[target.name]<b>.</span>")
		add_note("N[game.turn] - [target.body.real_name] - [target.name]")

/datum/mafia_role/md
	name = "Medical Doctor"
	desc = "You can protect a single person each night from killing."
	revealed_outfit = /datum/outfit/mafia/md
	role_type = TOWN_PROTECT
	hud_icon = "hudmedicaldoctor"
	revealed_icon = "medicaldoctor"
	winner_award = /datum/award/achievement/mafia/md

	targeted_actions = list("Protect")
	var/datum/mafia_role/current_protected

/datum/mafia_role/md/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,.proc/protect)
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,.proc/end_protection)

/datum/mafia_role/md/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	if((target.role_flags & ROLE_VULNERABLE) && (target.role_flags & ROLE_REVEALED)) //do not give the option to protect roles that your protection will fail on
		return FALSE
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/md/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	if(!target || target.game_status != MAFIA_ALIVE)
		to_chat(body,"<span class='warning'>You can only protect alive people.</span>")
		return
	to_chat(body,"<span class='warning'>You will protect [target.body.real_name] tonight.</span>")
	current_protected = target

/datum/mafia_role/md/proc/protect(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_protected)
		return
	var/datum/mafia_role/target = current_protected
	//current protected is unset at the end, as this action ends at a different phase
	if(!target.can_action(game, src, "medical assistance"))
		return

	RegisterSignal(target,COMSIG_MAFIA_ON_KILL,.proc/prevent_kill)
	add_note("N[game.turn] - Protected [target.body.real_name]")

/datum/mafia_role/md/proc/prevent_kill(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	if((current_protected.role_flags & ROLE_VULNERABLE))
		to_chat(body,"<span class='warning'>The person you protected could not be saved.</span>")
		return
	to_chat(body,"<span class='warning'>The person you protected tonight was attacked!</span>")
	to_chat(current_protected.body,"<span class='greentext'>You were attacked last night, but someone nursed you back to life!</span>")
	return MAFIA_PREVENT_KILL

/datum/mafia_role/md/proc/end_protection(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(current_protected)
		UnregisterSignal(current_protected,COMSIG_MAFIA_ON_KILL)
		current_protected = null

/datum/mafia_role/officer
	name = "Security Officer"
	desc = "You can protect a single person each night. If they are attacked, you will retaliate, killing yourself and the attacker."
	revealed_outfit = /datum/outfit/mafia/security
	revealed_icon = "securityofficer"
	hud_icon = "hudsecurityofficer"
	role_type = TOWN_PROTECT
	role_flags = ROLE_CAN_KILL
	winner_award = /datum/award/achievement/mafia/officer

	targeted_actions = list("Defend")
	var/datum/mafia_role/current_defended

/datum/mafia_role/officer/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,.proc/defend)
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,.proc/end_defense)

/datum/mafia_role/officer/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	if((role_flags & ROLE_VULNERABLE) && (target.role_flags & ROLE_REVEALED)) //do not give the option to protect roles that your protection will fail on
		return FALSE
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/officer/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	if(!target || target.game_status != MAFIA_ALIVE)
		to_chat(body,"<span class='warning'>You can only defend alive people.</span>")
		return
	to_chat(body,"<span class='warning'>You will defend [target.body.real_name] tonight.</span>")
	current_defended = target

/datum/mafia_role/officer/proc/defend(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_defended)
		return
	var/datum/mafia_role/target = current_defended
	//current defended is unset at the end, as this action ends at a different phase
	if(!target.can_action(game, src, "security patrol"))
		return
	if(target)
		RegisterSignal(target,COMSIG_MAFIA_ON_KILL,.proc/retaliate)
		add_note("N[game.turn] - Defended [target.body.real_name]")

/datum/mafia_role/officer/proc/retaliate(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	if((current_defended.role_flags & ROLE_VULNERABLE))
		to_chat(body,"<span class='warning'>The person you defended could not be saved. You could not attack the killer.</span>")
		return
	to_chat(body,"<span class='userdanger'>The person you defended tonight was attacked!</span>")
	to_chat(current_defended.body,"<span class='userdanger'>You were attacked last night, but security fought off the attacker!</span>")
	if(attacker.kill(game,src,FALSE)) //you attack the attacker
		to_chat(attacker.body, "<span class='userdanger'>You have been ambushed by Security!</span>")
	kill(game,attacker,FALSE) //the attacker attacks you, they were able to attack the target so they can attack you.
	return MAFIA_PREVENT_KILL

/datum/mafia_role/officer/proc/end_defense(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(current_defended)
		UnregisterSignal(current_defended,COMSIG_MAFIA_ON_KILL)
		current_defended = null

/datum/mafia_role/lawyer
	name = "Lawyer"
	desc = "You can choose a person during the day to provide extensive legal advice to during the night, preventing night actions."
	revealed_outfit = /datum/outfit/mafia/lawyer
	role_type = TOWN_SUPPORT
	hud_icon = "hudlawyer"
	revealed_icon = "lawyer"
	winner_award = /datum/award/achievement/mafia/lawyer

	targeted_actions = list("Advise")
	var/datum/mafia_role/current_target

/datum/mafia_role/lawyer/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_SUNDOWN,.proc/roleblock)
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,.proc/release)

/datum/mafia_role/lawyer/proc/roleblock(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_target)
		return

	var/datum/mafia_role/target = current_target
	if(!target.can_action(game, src, "roleblock")) //roleblocking a warden moment
		current_target = null
		return

	to_chat(target.body,"<span class='big bold red'>YOU HAVE BEEN BLOCKED! YOU CANNOT PERFORM ANY ACTIONS TONIGHT.</span>")
	add_note("N[game.turn] - [target.body.real_name] - Blocked")
	target.role_flags |= ROLE_ROLEBLOCKED

/datum/mafia_role/lawyer/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!.)
		return FALSE
	if(target == src)
		return FALSE
	if(game.phase == MAFIA_PHASE_NIGHT)
		return FALSE
	if(target.game_status != MAFIA_ALIVE)
		return FALSE

/datum/mafia_role/lawyer/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(target == current_target)
		current_target = null
		to_chat(body,"<span class='warning'>You have decided against blocking anyone tonight.</span>")
	else
		current_target = target
		to_chat(body,"<span class='warning'>You will block [target.body.real_name] tonight.</span>")

/datum/mafia_role/lawyer/proc/release(datum/mafia_controller/game)
	SIGNAL_HANDLER

	. = ..()
	if(current_target)
		current_target.role_flags &= ROLE_ROLEBLOCKED
		current_target = null

/datum/mafia_role/hop
	name = "Head of Personnel"
	desc = "You can reveal yourself once per game, tripling your vote power but becoming unable to be protected!"
	role_type = TOWN_SUPPORT
	role_flags = ROLE_UNIQUE
	hud_icon = "hudheadofpersonnel"
	revealed_icon = "headofpersonnel"
	revealed_outfit = /datum/outfit/mafia/hop
	winner_award = /datum/award/achievement/mafia/hop

	targeted_actions = list("Reveal")
	vote_potential = 3

/datum/mafia_role/hop/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!. || game.phase == MAFIA_PHASE_NIGHT || game.turn == 1 || target.game_status != MAFIA_ALIVE || target != src || (role_flags & ROLE_REVEALED))
		return FALSE

/datum/mafia_role/hop/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	reveal_role(game, TRUE)
	role_flags |= ROLE_VULNERABLE
	vote_power = 3

/datum/mafia_role/hos
	name = "Head of Security"
	desc = "You can decide to execute during the night, visiting someone killing, and revealing them. If they are innocent, you will die at the start of the next night."
	role_type = TOWN_KILLING
	role_flags = ROLE_CAN_KILL | ROLE_UNIQUE
	revealed_outfit = /datum/outfit/mafia/hos
	revealed_icon = "headofsecurity"
	hud_icon = "hudheadofsecurity"
	winner_award = /datum/award/achievement/mafia/hos

	targeted_actions = list("Execute")
	var/datum/mafia_role/execute_target

/datum/mafia_role/hos/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,.proc/execute)

/datum/mafia_role/hos/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/hos/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	if(execute_target == target)
		to_chat(body,"<span class='warning'>You have decided against executing tonight.</span>")
	to_chat(body,"<span class='warning'>You have decided to execute [target.body.real_name] tonight.</span>")
	execute_target = target

/datum/mafia_role/hos/proc/execute(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!execute_target)
		return
	var/datum/mafia_role/target = execute_target
	execute_target = null
	if(!target.can_action(game, src, "execution")) //roleblocking a warden moment
		return
	if(!target.kill(game,src,FALSE))//protection
		to_chat(body,"<span class='danger'>Your attempt at executing [target.body.real_name] was prevented, or [target.body.real_name] is immune!</span>")
	else
		to_chat(target.body, "<span class='userdanger'>You have been executed by the Head of Security!</span>")
		target.reveal_role(game, verbose = TRUE)
		if(target.team == MAFIA_TEAM_TOWN)
			to_chat(body,"<span class='userdanger'>You have killed an innocent crewmember. You will die tomorrow night.</span>")
			RegisterSignal(game,COMSIG_MAFIA_SUNDOWN,.proc/internal_affairs)
			role_flags |= ROLE_VULNERABLE

/datum/mafia_role/hos/proc/internal_affairs(datum/mafia_controller/game)
	to_chat(body,"<span class='userdanger'>You have been killed by Nanotrasen Internal Affairs!</span>")
	reveal_role(game, verbose = TRUE)
	kill(game,src,FALSE) //you technically kill yourself but that shouldn't matter


//just helps read better
#define WARDEN_NOT_LOCKDOWN 0//will NOT kill visitors tonight
#define WARDEN_WILL_LOCKDOWN 1 //will kill visitors tonight

/datum/mafia_role/warden
	name = "Warden"
	desc = "You can lockdown during the night once, killing any visitors. WARNING: This kills fellow town members, too!"

	role_type = TOWN_KILLING
	role_flags = ROLE_CAN_KILL
	revealed_outfit = /datum/outfit/mafia/warden
	revealed_icon = "warden"
	hud_icon = "hudwarden"
	winner_award = /datum/award/achievement/mafia/warden

	actions = list("Lockdown")
	var/charges = 1
	var/protection_status = WARDEN_NOT_LOCKDOWN


/datum/mafia_role/warden/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_SUNDOWN,.proc/night_start)
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,.proc/night_end)

/datum/mafia_role/warden/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!charges)
		to_chat(body,"<span class='danger'>You've already locked down this game!</span>")
		return
	if(game.phase == MAFIA_PHASE_NIGHT)
		to_chat(body,"<span class='danger'>You don't have time to lockdown, night has already arrived.</span>")
		return
	if(protection_status == WARDEN_WILL_LOCKDOWN)
		to_chat(body,"<span class='danger'>You decide to not lockdown tonight.</span>")
	else
		to_chat(body,"<span class='danger'>You decide to lockdown, killing any visitors.</span>")
	protection_status = !protection_status

/datum/mafia_role/warden/proc/night_start(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(protection_status == WARDEN_WILL_LOCKDOWN)
		to_chat(body,"<span class='danger'>Any and all visitors are going to eat buckshot tonight.</span>")
		RegisterSignal(src,COMSIG_MAFIA_ON_VISIT,.proc/self_defense)

/datum/mafia_role/warden/proc/night_end(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(protection_status == WARDEN_WILL_LOCKDOWN)
		charges--
		UnregisterSignal(src,COMSIG_MAFIA_ON_KILL)
		to_chat(body,"<span class='danger'>You are no longer protected. You have used up your power.</span>")
		protection_status = WARDEN_NOT_LOCKDOWN

/datum/mafia_role/warden/proc/self_defense(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	to_chat(body,"<span class='userdanger'>You have shot a visitor!</span>")
	to_chat(attacker,"<span class='userdanger'>You have visited the warden!</span>")
	attacker.kill(game, src, lynch = FALSE)
	return MAFIA_VISIT_INTERRUPTED

#undef WARDEN_NOT_LOCKDOWN
#undef WARDEN_WILL_LOCKDOWN

///MAFIA ROLES/// they're the "anti-town" working to kill off townies to win

/datum/mafia_role/mafia
	name = "Changeling"
	desc = "You're a member of the changeling hive. Use ':j' talk prefix to talk to your fellow lings."
	team = MAFIA_TEAM_MAFIA
	role_type = MAFIA_REGULAR
	hud_icon = "hudchangeling"
	revealed_icon = "changeling"
	winner_award = /datum/award/achievement/mafia/changeling

	revealed_outfit = /datum/outfit/mafia/changeling
	special_theme = "syndicate"
	win_condition = "become majority over the town and no solo killing role can stop them."

/datum/mafia_role/mafia/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_SUNDOWN,.proc/mafia_text)

/datum/mafia_role/mafia/proc/mafia_text(datum/mafia_controller/source)
	SIGNAL_HANDLER

	to_chat(body,"<b>Vote for who to kill tonight. The killer will be chosen randomly from voters.</b>")

//better detective for mafia
/datum/mafia_role/mafia/thoughtfeeder
	name = "Thoughtfeeder"
	desc = "You're a changeling variant that feeds on the memories of others. Use ':j' talk prefix to talk to your fellow lings, and visit people at night to learn their role."
	role_type = MAFIA_SPECIAL
	hud_icon = "hudthoughtfeeder"
	revealed_icon = "thoughtfeeder"
	winner_award = /datum/award/achievement/mafia/thoughtfeeder

	targeted_actions = list("Learn Role")
	var/datum/mafia_role/current_investigation

/datum/mafia_role/mafia/thoughtfeeder/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_ACTION_PHASE,.proc/investigate)

/datum/mafia_role/mafia/thoughtfeeder/validate_action_target(datum/mafia_controller/game,action,datum/mafia_role/target)
	. = ..()
	if(!.)
		return
	return game.phase == MAFIA_PHASE_NIGHT && target.game_status == MAFIA_ALIVE && target != src

/datum/mafia_role/mafia/thoughtfeeder/handle_action(datum/mafia_controller/game,action,datum/mafia_role/target)
	to_chat(body,"<span class='warning'>You will feast on the memories of [target.body.real_name] tonight.</span>")
	current_investigation = target

/datum/mafia_role/mafia/thoughtfeeder/proc/investigate(datum/mafia_controller/game)
	SIGNAL_HANDLER

	var/datum/mafia_role/target = current_investigation
	current_investigation = null
	if(!target.can_action(game, src, "thought feeding"))
		add_note("N[game.turn] - [target.body.real_name] - Unable to investigate")
		return
	if((target.role_flags & ROLE_UNDETECTABLE))
		to_chat(body,"<span class='warning'>[target.body.real_name]'s memories reveal that they are the Assistant.</span>")
		add_note("N[game.turn] - [target.body.real_name] - Assistant")
	else
		to_chat(body,"<span class='warning'>[target.body.real_name]'s memories reveal that they are the [target.name].</span>")
		add_note("N[game.turn] - [target.body.real_name] - [target.name]")

///SOLO ROLES/// they range from anomalous factors to deranged killers that try to win alone.

/datum/mafia_role/traitor
	name = "Traitor"
	desc = "You're a solo traitor. You are immune to night kills, can kill every night and you win by outnumbering everyone else."
	win_condition = "kill everyone."
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_KILL
	role_flags = ROLE_CAN_KILL
	winner_award = /datum/award/achievement/mafia/traitor
	revealed_outfit = /datum/outfit/mafia/traitor
	revealed_icon = "traitor"
	hud_icon = "hudtraitor"
	special_theme = "neutral"

	targeted_actions = list("Night Kill")
	var/datum/mafia_role/current_victim

/datum/mafia_role/traitor/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(src,COMSIG_MAFIA_ON_KILL,.proc/nightkill_immunity)
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_KILL_PHASE,.proc/try_to_kill)

/datum/mafia_role/traitor/check_total_victory(alive_town, alive_mafia) //serial killers just want teams dead, they cannot be stopped by killing roles anyways
	return alive_town + alive_mafia <= 1

/datum/mafia_role/traitor/block_team_victory(alive_town, alive_mafia) //no team can win until they're dead
	return TRUE //while alive, town AND mafia cannot win (though since mafia know who is who it's pretty easy to win from that point)

/datum/mafia_role/traitor/proc/nightkill_immunity(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	if(game.phase == MAFIA_PHASE_NIGHT && !lynch)
		to_chat(body,"<span class='userdanger'>You were attacked, but they'll have to try harder than that to put you down.</span>")
		return MAFIA_PREVENT_KILL

/datum/mafia_role/traitor/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!.)
		return FALSE
	if(game.phase != MAFIA_PHASE_NIGHT || target.game_status != MAFIA_ALIVE || target == src)
		return FALSE

/datum/mafia_role/traitor/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	current_victim = target
	to_chat(body,"<span class='warning'>You will attempt to kill [target.body.real_name] tonight.</span>")

/datum/mafia_role/traitor/proc/try_to_kill(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!current_victim)
		return
	var/datum/mafia_role/target = current_victim
	current_victim = null
	if(!target.can_action(game, src, "flickering")) //flickering a warden
		return
	if(game_status == MAFIA_ALIVE)
		if(!target.kill(game,src,FALSE))
			to_chat(body,"<span class='danger'>Your attempt at killing [target.body.real_name] was prevented!</span>")
		else
			to_chat(target.body, "<span class='userdanger'>You have been killed by a Traitor!</span>")

/datum/mafia_role/nightmare
	name = "Nightmare"
	desc = "You're a solo monster that cannot be detected by detective roles. You can flicker lights of another room each night, becoming immune to attacks from those roles. You can instead decide to hunt, killing everyone in a flickering room. Kill everyone to win."
	win_condition = "kill everyone."
	revealed_outfit = /datum/outfit/mafia/nightmare
	role_flags = ROLE_UNDETECTABLE | ROLE_CAN_KILL
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_KILL
	special_theme = "neutral"
	hud_icon = "hudnightmare"
	revealed_icon = "nightmare"
	winner_award = /datum/award/achievement/mafia/nightmare

	targeted_actions = list("Flicker", "Hunt")
	var/list/flickering = list()
	var/datum/mafia_role/flicker_target

/datum/mafia_role/nightmare/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(src,COMSIG_MAFIA_ON_KILL,.proc/flickering_immunity)
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_KILL_PHASE,.proc/flicker_or_hunt)

/datum/mafia_role/nightmare/check_total_victory(alive_town, alive_mafia) //nightmares just want teams dead
	return alive_town + alive_mafia <= 1

/datum/mafia_role/nightmare/block_team_victory(alive_town, alive_mafia) //no team can win until they're dead
	return TRUE //while alive, town AND mafia cannot win (though since mafia know who is who it's pretty easy to win from that point)

/datum/mafia_role/nightmare/special_reveal_equip()
	body.underwear = "Nude"
	body.undershirt = "Nude"
	body.socks = "Nude"
	body.set_species(/datum/species/shadow)
	body.update_body()

/datum/mafia_role/nightmare/validate_action_target(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!. || game.phase != MAFIA_PHASE_NIGHT || target.game_status != MAFIA_ALIVE)
		return FALSE
	if(action == "Flicker")
		return target != src && !(target in flickering)
	return target == src

/datum/mafia_role/nightmare/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(target == flicker_target)
		to_chat(body,"<span class='warning'>You will do nothing tonight.</span>")
		flicker_target = null
	flicker_target = target
	if(action == "Flicker")
		to_chat(body,"<span class='warning'>You will attempt to flicker [target.body.real_name]'s room tonight.</span>")
	else
		to_chat(body,"<span class='danger'>You will hunt everyone in a flickering room down tonight.</span>")

/datum/mafia_role/nightmare/proc/flickering_immunity(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER
	if(!attacker)
		return //no chance man, that's a town lynch

	if(attacker in flickering)
		to_chat(body,"<span class='userdanger'>You were attacked by someone in a flickering room. You have danced in the shadows, evading them.</span>")
		return MAFIA_PREVENT_KILL

/datum/mafia_role/nightmare/proc/flicker_or_hunt(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(!flicker_target)
		return
	var/datum/mafia_role/target = flicker_target
	flicker_target = null
	if(!target.can_action(game, src, "flickering")) //flickering a warden
		return

	if(target != src) //flicker instead of hunt
		to_chat(target.body, "<span class='userdanger'>The lights begin to flicker and dim. You're in danger.</span>")
		flickering += target
		return
	for(var/r in flickering)
		var/datum/mafia_role/role = r
		if(role && role.game_status == MAFIA_ALIVE)
			to_chat(role.body, "<span class='userdanger'>A shadowy figure appears out of the darkness!</span>")
			role.kill(game,src,FALSE)
		flickering -= role

//just helps read better
#define FUGITIVE_NOT_PRESERVING 0//will not become night immune tonight
#define FUGITIVE_WILL_PRESERVE 1 //will become night immune tonight

/datum/mafia_role/fugitive
	name = "Fugitive"
	desc = "You're on the run. You can become immune to night kills exactly twice, and you win by surviving to the end of the game with anyone."
	win_condition = "survive to the end of the game, with anyone"
	revealed_outfit = /datum/outfit/mafia/fugitive
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_DISRUPT
	special_theme = "neutral"
	hud_icon = "hudfugitive"
	revealed_icon = "fugitive"
	winner_award = /datum/award/achievement/mafia/fugitive

	actions = list("Self Preservation")
	var/charges = 2
	var/protection_status = FUGITIVE_NOT_PRESERVING


/datum/mafia_role/fugitive/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_SUNDOWN,.proc/night_start)
	RegisterSignal(game,COMSIG_MAFIA_NIGHT_END,.proc/night_end)
	RegisterSignal(game,COMSIG_MAFIA_GAME_END,.proc/survived)

/datum/mafia_role/fugitive/handle_action(datum/mafia_controller/game, action, datum/mafia_role/target)
	. = ..()
	if(!charges)
		to_chat(body,"<span class='danger'>You're out of supplies and cannot protect yourself anymore.</span>")
		return
	if(game.phase == MAFIA_PHASE_NIGHT)
		to_chat(body,"<span class='danger'>You don't have time to prepare, night has already arrived.</span>")
		return
	if(protection_status == FUGITIVE_WILL_PRESERVE)
		to_chat(body,"<span class='danger'>You decide to not prepare tonight.</span>")
	else
		to_chat(body,"<span class='danger'>You decide to prepare for a horrible night.</span>")
	protection_status = !protection_status

/datum/mafia_role/fugitive/proc/night_start(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(protection_status == FUGITIVE_WILL_PRESERVE)
		to_chat(body,"<span class='danger'>Your preparations are complete. Nothing could kill you tonight!</span>")
		RegisterSignal(src,COMSIG_MAFIA_ON_KILL,.proc/prevent_death)

/datum/mafia_role/fugitive/proc/night_end(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(protection_status == FUGITIVE_WILL_PRESERVE)
		charges--
		UnregisterSignal(src,COMSIG_MAFIA_ON_KILL)
		to_chat(body,"<span class='danger'>You are no longer protected. You have [charges] use[charges == 1 ? "" : "s"] left of your power.</span>")
		protection_status = FUGITIVE_NOT_PRESERVING

/datum/mafia_role/fugitive/proc/prevent_death(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	to_chat(body,"<span class='userdanger'>You were attacked! Luckily, you were ready for this!</span>")
	return MAFIA_PREVENT_KILL

/datum/mafia_role/fugitive/proc/survived(datum/mafia_controller/game)
	SIGNAL_HANDLER

	if(game_status == MAFIA_ALIVE)
		game.award_role(winner_award, src)
		game.send_message("<span class='big comradio'>!! FUGITIVE VICTORY !!</span>")

#undef FUGITIVE_NOT_PRESERVING
#undef FUGITIVE_WILL_PRESERVE

/datum/mafia_role/obsessed
	name = "Obsessed"
	desc = "You're completely lost in your own mind. You win by lynching your obsession before you get killed in this mess. Obsession assigned on the first night!"
	win_condition = "lynch their obsession."
	revealed_outfit = /datum/outfit/mafia/obsessed
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_DISRUPT
	special_theme = "neutral"
	hud_icon = "hudobsessed"
	revealed_icon = "obsessed"

	winner_award = /datum/award/achievement/mafia/obsessed
	var/datum/mafia_role/obsession
	var/lynched_target = FALSE

/datum/mafia_role/obsessed/New(datum/mafia_controller/game) //note: obsession is always a townie
	. = ..()
	RegisterSignal(game,COMSIG_MAFIA_SUNDOWN,.proc/find_obsession)

/datum/mafia_role/obsessed/proc/find_obsession(datum/mafia_controller/game)
	SIGNAL_HANDLER

	var/list/all_roles_shuffle = shuffle(game.all_roles)
	for(var/role in all_roles_shuffle)
		var/datum/mafia_role/possible = role
		if(possible.team == MAFIA_TEAM_TOWN && possible.game_status != MAFIA_DEAD)
			obsession = possible
			break
	if(!obsession)
		obsession = pick(all_roles_shuffle) //okay no town just pick anyone here
	//if you still don't have an obsession you're playing a single player game like i can't help your dumb ass
	to_chat(body, "<span class='userdanger'>Your obsession is [obsession.body.real_name]! Get them lynched to win!</span>")
	add_note("N[game.turn] - I vowed to watch my obsession, [obsession.body.real_name], hang!") //it'll always be N1 but whatever
	RegisterSignal(obsession,COMSIG_MAFIA_ON_KILL,.proc/check_victory)
	UnregisterSignal(game,COMSIG_MAFIA_SUNDOWN)

/datum/mafia_role/obsessed/proc/check_victory(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	UnregisterSignal(source,COMSIG_MAFIA_ON_KILL)
	if(game_status == MAFIA_DEAD)
		return
	if(lynch)
		game.send_message("<span class='big comradio'>!! OBSESSED VICTORY !!</span>")
		game.award_role(winner_award, src)
		reveal_role(game, FALSE)
	else
		to_chat(body, "<span class='userdanger'>You have failed your objective to lynch [obsession.body.real_name]!</span>")

/datum/mafia_role/clown
	name = "Clown"
	desc = "If you are lynched you take down one of your voters (guilty or abstain) with you and win. HONK!"
	win_condition = "get themselves lynched!"
	revealed_outfit = /datum/outfit/mafia/clown
	team = MAFIA_TEAM_SOLO
	role_type = NEUTRAL_DISRUPT
	special_theme = "neutral"
	hud_icon = "hudclown"
	revealed_icon = "clown"
	winner_award = /datum/award/achievement/mafia/clown

/datum/mafia_role/clown/New(datum/mafia_controller/game)
	. = ..()
	RegisterSignal(src,COMSIG_MAFIA_ON_KILL,.proc/prank)

/datum/mafia_role/clown/proc/prank(datum/source,datum/mafia_controller/game,datum/mafia_role/attacker,lynch)
	SIGNAL_HANDLER

	if(lynch)
		var/datum/mafia_role/victim = pick(game.judgement_guilty_votes + game.judgement_abstain_votes)
		game.send_message("<span class='big clown'>[body.real_name] WAS A CLOWN! HONK! They take down [victim.body.real_name] with their last prank.</span>")
		game.send_message("<span class='big clown'>!! CLOWN VICTORY !!</span>")
		game.award_role(winner_award, src)
		victim.kill(game,FALSE)
