
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

/obj/machinery/spawner/Initialize()
	. = ..()
	reinforce()


/obj/machinery/spawner/proc/reinforce(var/repeat = TRUE)
	if(!QDELETED(src))
		light_color = LIGHT_COLOR_RED
		update_light()
		var/list/mob/dead/observer/finalists = pollGhostCandidates("Would you like to be a Syndicate reinforcement?", ROLE_TRAITOR, null, ROLE_TRAITOR, 100, POLL_IGNORE_SYNDICATE)
		if(LAZYLEN(finalists) && !QDELETED(src))
			var/mob/living/simple_animal/S
			var/mob/dead/observer/winner = pick(finalists)
			if(prob(50))
				if(prob(4))
					S = new /mob/living/simple_animal/hostile/syndicate/ranged/smg(get_turf(src))
				else
					S = new /mob/living/simple_animal/hostile/syndicate/ranged(get_turf(src))
			else
				if(prob(10))
					S = new /mob/living/simple_animal/hostile/syndicate/melee/sword(get_turf(src))
				else
					S = new /mob/living/simple_animal/hostile/syndicate/melee(get_turf(src))
			S.key = winner.key
			do_sparks(4, TRUE, src)
		if(repeat)
			light_color = LIGHT_COLOR_CYAN
			update_light()
			cooldown = max(600, cooldown - 300)
			addtimer(CALLBACK(src, .proc/reinforce), cooldown, TIMER_UNIQUE)



