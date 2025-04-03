/datum/action/cooldown/spell/conjure/cheese
	name = "Summon Cheese"
	desc = "This spell conjures a bunch of cheese wheels. What the hell?"
	sound = 'sound/effects/magic/summonitems_generic.ogg'
	button_icon_state = "cheese"

	school = SCHOOL_CONJURATION
	cooldown_time = 1 MINUTES
	spell_requirements = null

	invocation = "PL'YR DOT PL'CTM' OOO'BEE G!" //player.placeatme 00064B33 9
	invocation_type = INVOCATION_SHOUT
	garbled_invocation_prob = 0 //i'd rather it remain like this

	summon_radius = 1
	summon_amount = 9
	summon_type = list(/obj/item/food/cheese/wheel)
