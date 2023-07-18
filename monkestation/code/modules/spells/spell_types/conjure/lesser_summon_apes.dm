/datum/action/cooldown/spell/conjure/lesser_summonapes
	name = "Lesser Summon Apes"
	desc = "This spell conjures a group of hostile apes, they WILL be hostile to you."
	invocation = "MON'KE"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "monkey_down"
	invocation_type = INVOCATION_SHOUT
	summon_radius = 2
	sound = 'sound/creatures/monkey/monkey_screech_1.ogg'
	cooldown_time = 2 MINUTES
	cooldown_reduction_per_rank = 15 SECONDS

	summon_type = list(/mob/living/carbon/human/species/monkey/angry, /mob/living/simple_animal/hostile/gorilla)

	summon_lifespan = 90 SECONDS
	summon_amount = 4
