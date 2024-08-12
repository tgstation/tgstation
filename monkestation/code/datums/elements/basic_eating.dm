/proc/get_drink_sound(mob/living/drinker, force_enhanced = FALSE)
	. = 'sound/items/drink.ogg'
	if (force_enhanced || (isipc(drinker) || issilicon(drinker)) && (roll(15) >= 15))
		to_chat(drinker, span_notice("Your circuits are rushed with enhanced flavor!"))
		. = 'monkestation/sound/items/drink_sparkle.ogg'
