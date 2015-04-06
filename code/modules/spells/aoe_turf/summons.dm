/spell/aoe_turf/conjure/summonEdSwarm //test purposes
	name = "Dispense Wizard Justice"
	desc = "This spell dispenses wizard justice."

	summon_type = list(/obj/machinery/bot/ed209)
	summon_amt = 10
	range = 3
	newVars = list("emagged" = 1,"name" = "Wizard's Justicebot")

	hud_state = "wiz_ed"

/spell/aoe_turf/conjure/carp
	name = "Summon Carp"
	desc = "This spell conjures a simple carp."

	school = "conjuration"
	charge_max = 1200
	spell_flags = NEEDSCLOTHES
	invocation = "NOUK FHUNMM SACP RISSKA"
	invocation_type = SpI_SHOUT
	range = 1

	summon_type = list(/mob/living/simple_animal/hostile/carp)

	hud_state = "wiz_carp"

/spell/aoe_turf/conjure/creature
	name = "Summon Creature Swarm"
	desc = "This spell tears the fabric of reality, allowing horrific daemons to spill forth"

	school = "conjuration"
	charge_max = 1200
	spell_flags = 0
	invocation = "IA IA"
	invocation_type = SpI_SHOUT
	summon_amt = 10
	range = 3

	summon_type = list(/mob/living/simple_animal/hostile/creature)

	hud_state = "wiz_creature"