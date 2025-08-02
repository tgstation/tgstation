/datum/action/cooldown/spell/conjure/cheese
	name = "Summon Cheese"
	desc = "This spell conjures a bunch of cheese wheels. What the hell?"
	sound = 'sound/effects/magic/summonitems_generic.ogg'
	button_icon_state = "cheese"

	school = SCHOOL_CONJURATION
	cooldown_time = 1 MINUTES
	spell_requirements = null

	invocation = "PL'YR DOT PL'CTM' OOO'B'ABEE G!" //player.placeatme 00064B33 9
	invocation_type = INVOCATION_SHOUT
	garbled_invocation_prob = 0 //i'd rather it remain like this

	summon_radius = 1
	summon_amount = 9
	summon_type = list(/obj/item/food/cheese/wheel)

/datum/action/cooldown/spell/conjure/cheese/New(Target, original)
	. = ..()
	if(prob(50))
		return
	var/cheese_hex_path = uppertext(copytext(REF(/obj/item/food/cheese/wheel), 4, -1))
	var/list/replacements = list(
		"0" = "O",
		"1" = "L",
		"2" = "Z",
		"3" = "'E",
		"4" = "'A",
		"5" = "S",
		"6" = "'B",
		"7" = "T",
		"8" = "-B",
		"9" = "G",
	)
	for(var/digit in replacements)
		cheese_hex_path = replacetext(cheese_hex_path, digit, replacements[digit])
	invocation = "PL'YR DOT PL'CTM' [cheese_hex_path] G!"
