// Fluff for the Syndicate outpost which appears on tramstation's z-levels

/obj/item/paper/fluff/ruins/tram_syndicate/initiation
	name = "Initiation Paperwork"
	default_raw_text = {"<h1>Congratulations, Agent <i>INSERT NAME HERE</i>!</h1>
	You have been assigned reconnaissance duty among the orbiting rocks of Indecipheres! Since this location was previously scouted as a potential build site for a Nanotrasen facility, one of our benefactors has taken the opportunity to pre-emptively construct a listening outpost! You have been tasked with monitoring the potential future crew and logging all events onboard. If you are a Nanotrasen employee who has stumbled upon this outpost before it could be properly established: <b>IGNORE THIS PAPER</b>."}

/obj/item/paper/fluff/ruins/tram_syndicate/blueprints
	name = "Station Layout"
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "blueprints"
	inhand_icon_state = "blueprints"
	default_raw_text = {"A crude mapping of the station layout based on leaked internal documents and orbital snapshots taken during construction.
	<br><i>You're not sure how up-to-date this is anymore...</i>"}
	show_written_words = FALSE // Blueprints don't have a "blueprints_words" icon state.
