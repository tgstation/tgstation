/mob/living/simple_animal/beachcarp
	name = "carp"
	desc = "A passive, fang-bearing creature that resembles a fish."
	icon = 'voidcrew/icons/mob/carp.dmi'
	icon_state = "base"
	icon_living = "base"
	icon_dead = "base_dead"
	icon_gib = "carp_gib"
	speak_emote = list("glubs")
	emote_hear = list("glubs.")
	emote_see = list("glubs.")
	speak_chance = 1
	faction = list(FACTION_BEACH)
	turns_per_move = 5
	butcher_results = list(/obj/item/food/fishmeat/carp = 2)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	stop_automated_movement = 1
	friendly_verb_continuous = "nibbles"
	friendly_verb_simple = "nibble"
	turns_per_move = 2


/mob/living/simple_animal/beachcarp/Life()
	..()
	//CARP movement
	if(!ckey && !stat)
		if(isturf(loc) && !resting && !buckled) //This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				var/east_vs_west = pick(4,8)
				if(Process_Spacemove(east_vs_west))
					var/turf/step = get_step(src,east_vs_west)
					if (istype(step, /turf/open/water)) //Only allow fish to move onto water tiles
						Move(step, east_vs_west)
					turns_since_move = 0
	regenerate_icons()

/mob/living/simple_animal/beachcarp/bass
	name = "bass"
	desc = "A largemouthed green bass."
	icon = 'voidcrew/icons/mob/beach/fish.dmi'
	icon_state = "bass-swim"
	icon_dead = "bass-dead"

/mob/living/simple_animal/beachcarp/trout
	name = "trout"
	desc = "A wild steelhead trout."
	icon = 'voidcrew/icons/mob/beach/fish.dmi'
	icon_state = "trout-swim"
	icon_dead = "trout-dead"

/mob/living/simple_animal/beachcarp/salmon
	name = "salmon"
	desc = "A large blue salmon."
	icon = 'voidcrew/icons/mob/beach/fish.dmi'
	icon_state = "salmon-swim"
	icon_dead = "salmon-dead"

/mob/living/simple_animal/beachcarp/perch
	name = "perch"
	desc = "A small yellow perch."
	icon = 'voidcrew/icons/mob/beach/fish.dmi'
	icon_state = "perch-swim"
	icon_dead = "perch-dead"
