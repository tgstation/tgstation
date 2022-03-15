/datum/action/cooldown/spell/conjure/carp
	name = "Summon Carp"
	desc = "This spell conjures a simple carp."
	sound = 'sound/magic/summon_karp.ogg'

	school = SCHOOL_CONJURATION
	charge_max = 2 MINUTES

	invocation = "NOUK FHUNMM SACP RISSKA"
	invocation_type = INVOCATION_SHOUT
	range = 1

	summon_type = list(/mob/living/simple_animal/hostile/carp)
