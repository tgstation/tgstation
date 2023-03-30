/obj/item/mcobject/synthcomp
	name = "sound synthesizer component"
	base_icon_state = "comp_synth"
	icon_state = "comp_synth"

	COOLDOWN_DECLARE(cd)

/obj/item/mcobject/synthcomp/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("input", talk)

/obj/item/mcobject/synthcomp/proc/talk(datum/mcmessage/input)
	if(!COOLDOWN_FINISHED(src, cd))
		return

	COOLDOWN_START(src, cd, 2 SECONDS)
	say(input.cmd)
