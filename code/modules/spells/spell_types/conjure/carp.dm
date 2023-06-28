/datum/action/cooldown/spell/conjure/carp
	name = "Summon Carp"
	desc = "This spell conjures a simple carp."
	sound = 'sound/magic/summon_karp.ogg'

	school = SCHOOL_CONJURATION
	cooldown_time = 2 MINUTES

	invocation = "NOUK FHUNMM SACP RISSKA"
	invocation_type = INVOCATION_SHOUT

	summon_radius = 1
	summon_type = list(/mob/living/basic/carp)
