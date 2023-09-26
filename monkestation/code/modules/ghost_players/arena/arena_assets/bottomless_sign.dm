/obj/structure/sign/bottomless
	name = "bottomless pit"
	desc = "I sure hope nobody puts a bottom in the pit."
	icon_state = "bottomlesspit1"
	icon = 'monkestation/code/modules/ghost_players/arena/arena_assets/icons/sign2.dmi'
	custom_materials = list(/datum/material/wood = 2000)

/obj/structure/sign/bottomless/examine(mob/user)
	. = ..()
	. += span_nicegreen("&gt;be me")
	. += span_nicegreen("&gt;bottomless pit supervisor")
	. += span_nicegreen("&gt;in charge of making sure the bottomless pit is, in fact, bottomless")
	. += span_nicegreen("&gt;occasionally have to go down there and check if the bottomless pit is still bottomless")
	. += span_nicegreen("&gt;one day i go down there and the bottomless pit is no longer bottomless")
	. += span_nicegreen("&gt;the bottom of the bottomless pit is now just a regular pit")
	. += span_nicegreen("&gt;distress.png")
