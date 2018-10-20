
/obj/machinery/spawner
	name = "Syndicate reinforcements gateway"
	desc = "A gateway used by the Syndicate to bring in extra muscle."
	anchored = TRUE
	density = TRUE
	icon = 'icons/obj/machines/teleporter.dmi'
	icon_state = "mob_teleporter_on"
	light_range = 5
	light_color = LIGHT_COLOR_CYAN
	max_integrity = 200
	obj_integrity = 200
	var/cooldown = 3000
	var/datum/team/custom/Team
	var/password = ""

/obj/machinery/spawner/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/reinforce), 50)
	password = num2text(rand(1000,9999))
	visible_message("<span class='boldwarning'>The password is [password]. Your allies may enter this number to identify as friendly to your reinforcements!</span>")

/obj/machinery/spawner/ui_interact(mob/living/user)
	if(Team)
		var/on_team = FALSE
		var/datum/mind/M = user.mind
		for(var/datum/antagonist/A in M.antag_datums)
			if(A.get_team() == Team)
				on_team = TRUE
		if(!on_team)
			var/guess = stripped_input(user,"Enter the password:", "Password", "")
			if(guess == password)
				Team.add_member(user.mind)
				playsound(src, 'sound/machines/chime.ogg', 30, 1)
			else
				playsound(src, 'sound/machines/buzz-sigh.ogg', 30, 1)

/obj/machinery/spawner/proc/reinforce(var/repeat = TRUE)
	if(!QDELETED(src))
		light_color = LIGHT_COLOR_RED
		icon_state = "mob_teleporter_active"
		update_light()
		var/list/mob/dead/observer/finalists = pollGhostCandidates("Would you like to be a Syndicate reinforcement?", ROLE_TRAITOR, null, ROLE_TRAITOR, 100, POLL_IGNORE_SYNDICATE)
		if(LAZYLEN(finalists) && !QDELETED(src))
			var/mob/living/simple_animal/S
			var/mob/dead/observer/winner = pick(finalists)
			if(prob(50))
				if(prob(4))
					S = new /mob/living/simple_animal/hostile/syndicate/ranged/smg(get_turf(src))
				else
					S = new /mob/living/simple_animal/hostile/syndicate/ranged/reinforcement(get_turf(src))
			else
				if(prob(10))
					S = new /mob/living/simple_animal/hostile/syndicate/melee/sword(get_turf(src))
				else
					S = new /mob/living/simple_animal/hostile/syndicate/melee/reinforcement(get_turf(src))
			S.key = winner.key
			if(Team)
				Team.add_member(S.mind)
			do_sparks(4, TRUE, src)
		if(repeat)
			light_color = LIGHT_COLOR_CYAN
			icon_state = "mob_teleporter_on"
			update_light()
			cooldown = max(600, cooldown - 300)
			addtimer(CALLBACK(src, .proc/reinforce), cooldown, TIMER_UNIQUE)