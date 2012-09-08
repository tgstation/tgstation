/obj/effect/sign/barsign
	icon = 'barsigns.dmi'
	icon_state = "empty"
	anchored = 1

	New()
		var/list/valid_states = list("pinkflamingo", "magmasea", "limbo", "rustyaxe", "armokbar", "brokendrum", "meadbay", "thedamnwall", "thecavern", "cindikate", "theorchard", "thesaucyclown", "theclownshead")
		src.icon_state = "[pick(valid_states)]"
