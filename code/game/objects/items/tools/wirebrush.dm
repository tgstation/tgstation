/**
 * The wirebrush is a tool whose sole purpose is to remove rust from anything that is rusty.
 * Because of the inherent nature of hard countering rust heretics it does it very slowly.
 */
/obj/item/wirebrush
	name = "wirebrush"
	desc = "A tool that is used to scrub the rust thoroughly off walls. Not for hair!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "wirebrush"
	tool_behaviour = TOOL_RUSTSCRAPER
	toolspeed = 1
	///Does this wirebrush have tool degredation?
	var/degrade_enabled = TRUE

/obj/item/wirebrush/Initialize(mapload)
	. = ..()
	if(degrade_enabled)
		AddComponent(/datum/component/degrade)



