/datum/action/cooldown/spell/conjure/bee
	name = "Lesser Summon Bees"
	desc = "This spell magically kicks a transdimensional beehive, \
		instantly summoning a swarm of bees to your location. \
		These bees are NOT friendly to anyone."
	button_icon_state = "bee"
	sound = 'sound/voice/moth/scream_moth.ogg'

	school = SCHOOL_CONJURATION
	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 10 SECONDS

	invocation = "NOT THE BEES"
	invocation_type = INVOCATION_SHOUT

	summon_radius = 3
	summon_type = list(/mob/living/simple_animal/hostile/bee/toxin)
	summon_amount = 9
