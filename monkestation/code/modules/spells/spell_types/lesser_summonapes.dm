/obj/effect/proc_holder/spell/aoe_turf/conjure/lesser_summonapes
	name = "Lesser Summon Apes"
	desc = "This spell conjures a large amount of hostile apes, they WILL be hostile to you."
	invocation = "MON'KE"
	action_icon = 'icons/mob/actions/actions_silicon.dmi'
	action_icon_state = "monkey_down"
	invocation_type = "shout"
	charge_max = 120 SECONDS
	range = 2
	cooldown_min = 20 SECONDS

	summon_type = list(/mob/living/carbon/monkey/angry, /mob/living/simple_animal/hostile/gorilla)

	summon_lifespan = 180 SECONDS
	summon_amt = 4

	newVars = list(name = "Angry Ape")
	cast_sound = 'sound/creatures/monkey/monkey_screech_1.ogg'
