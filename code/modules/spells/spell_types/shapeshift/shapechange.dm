/datum/action/cooldown/spell/shapeshift/wizard
	name = "Wild Shapeshift"
	desc = "Take on the shape of another for a time to use their natural abilities. \
		Once you've made your choice, it cannot be changed."

	cooldown_time = 20 SECONDS
	cooldown_reduction_per_rank = 8 SECONDS
	spell_max_level = 3

	invocation = "RAC'WA NO!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	possible_shapes = list(
		/mob/living/basic/carp/magic/chaos,
		/mob/living/basic/construct/juggernaut/mystic,
		/mob/living/basic/mouse,
		/mob/living/basic/pet/dog/corgi,
		/mob/living/basic/spider/giant/viper/wizard,
		/mob/living/simple_animal/bot/secbot/ed209,
	)
