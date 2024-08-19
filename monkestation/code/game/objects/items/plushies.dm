/obj/item/toy/plush/duckyplush
	name = "ducky plushie"
	desc = "Manufactured in the Russ Sector"
	icon = 'monkestation/icons/obj/plushes.dmi'
	icon_state = "russducky"
	squeak_override = list('sound/items/bikehorn.ogg'=1)

/obj/item/toy/plush/lubeplush
	name = "living lube plushie"
	desc = "It feels... moist."
	icon = 'monkestation/icons/obj/plushes.dmi'
	icon_state = "living_lube"
	squeak_override = list('sound/items/bikehorn.ogg'=1)
	var/last_lubed = 0  //so you can't spam the floor with their lube

/obj/item/toy/plush/lubeplush/dropped(mob/user, silent)
	. = ..()
	if((last_lubed + 30 SECONDS) < world.time)
		var/turf/open/OT = get_turf(src)
		if(isopenturf(OT))
			OT.MakeSlippery(TURF_WET_WATER, 100)
			last_lubed = world.time


/obj/item/toy/plush/moth/ookplush
	name = "ook plushie"
	desc = "What's under the bag, anyway?"
	icon = 'monkestation/icons/obj/plushes.dmi'
	icon_state = "ook"
	squeak_override = list('monkestation/sound/voice/laugh/simian/monkey_laugh_1.ogg'=1)
	suicide_text = "is overcome with curiosity and tries to pull the bag off of"
	creepy_plush_type = "monkey"
	has_creepy_icons = TRUE

/obj/item/toy/plush/moth/tyriaplush
	name = "tyria plushie"
	desc = "Tyria plushie isn't real.  Tyria plushie can't hurt you."
	icon = 'monkestation/icons/obj/plushes.dmi'
	icon_state = "tyria"
	attack_verb_simple = list("fluttered", "flapped")
	squeak_override = list('monkestation/sound/voice/laugh/moth/mothlaugh.ogg'=1)
	has_creepy_icons = TRUE


/obj/item/toy/plush/sammiplush
	name = "sammi plush"
	desc = "Voted cutest monke 2023"
	icon = 'monkestation/icons/obj/plushes.dmi'
	icon_state = "sammi"
	squeak_override = list('monkestation/sound/voice/laugh/simian/monkey_laugh_1.ogg'=1)

/obj/item/toy/plush/knightplush
	name = "knight plush"
	desc = "D'aww he's gonna save the world, yes he is!"
	icon = 'monkestation/icons/obj/plushes.dmi'
	icon_state = "knight"

/obj/item/toy/plush/durrcell // https://www.twitch.tv/durrhurrdurr
	name = "durrcell plush"
	desc = "''Behold, Man''"
	icon = 'monkestation/icons/obj/plushes.dmi'
	icon_state = "durrcell"
	squeak_override = list('monkestation/sound/voice/durrcell-squeak.ogg'=1)
