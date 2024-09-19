/*----- Template for ruins, prevents needing to re-type the filepath prefix -----*/
/datum/map_template/ruin/icemoon/underground/doppler/
	prefix = "_maps/RandomRuins/IceRuins/doppler/"

/datum/map_template/ruin/icemoon/doppler/
	prefix = "_maps/RandomRuins/IceRuins/doppler/"

/*----- Underground -----*/

/datum/map_template/ruin/icemoon/underground/doppler/magic_hotsprings
	name = "Magic Hotsprings"
	id = "magic-hotsprings"
	description = "A beautiful hot springs spot, surrounded by unnatural fairy grass and exotic trees."
	prefix = "_maps/RandomRuins/IceRuins/doppler/"
	suffix = "icemoon_underground_magical_hotsprings.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/icemoon/underground/doppler/abandoned_hearth
	name = "Abandoned Hearth"
	id = "abandoned-hearth"
	description = "Something went terribly wrong in this hearth, if the signs of struggle are anything to go by."
	prefix = "_maps/RandomRuins/IceRuins/doppler/"
	suffix = "icemoon_underground_abandoned_icewalker_den.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/icemoon/underground/doppler/abandoned_sacred_temple
	name = "Sacred Temple"
	id = "abandoned-sacred-temple"
	description = "The dusty remains of a temple, sacred in nature."
	prefix = "_maps/RandomRuins/IceRuins/doppler/"
	suffix = "icemoon_underground_abandoned_sacred_temple.dmm"
	allow_duplicates = FALSE

//Code for the Abandoned Sacred Temple
/obj/structure/statue/hearthkin/odin
	name = "statue of Óðinn"
	desc = "A gold statue, representing the All-Father Óðinn. It is strangely in good state."
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/gods_statue.dmi'
	icon_state = "odin_statue"

/obj/item/paper/crumpled/bloody/fluff/stations/lavaland/sacred_temple/
	name = "moon 34, of the year 2283"
	desc = "A note written in Ættmál. It seems to have been ripped from a diary of some sort."
	default_raw_text = "<i>I refuse to believe we're reduced to this- to sacrifice our own in hopes of our gods taking pity and rescuing us. We've lost too many already... I regret not joining with the rest. But I won't sit here and wait for my turn to be sacrificed, moping about like some sort of useless bastard. Me, my husband, and my sibling Halko will soon make our move, once the grand priest goes to sleep.</i>"

/obj/item/paper/crumpled/bloody/fluff/stations/lavaland/sacred_temple/ui_status(mob/user, datum/ui_state/state)
    if(!user.has_language(/datum/language/primitive_catgirl))
        to_chat(user, span_warning("This seems to be in a language you do not understand!"))
        return UI_CLOSE

    . = ..()
