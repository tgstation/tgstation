/datum/action/cooldown/spell/conjure/creature
	name = "Summon Creature Swarm"
	desc = "This spell tears the fabric of reality, allowing horrific daemons to spill forth."
	sound = 'sound/effects/magic/summonitems_generic.ogg'

	school = SCHOOL_CONJURATION
	cooldown_time = 2 MINUTES

	invocation = "IA IA"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	summon_radius = 3
	summon_type = list(/mob/living/basic/creature)
	summon_amount = 10
