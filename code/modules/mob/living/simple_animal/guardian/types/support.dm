//Healer
/mob/living/simple_animal/hostile/guardian/healer
	playstyle_string = "<span class='holoparasite'>As a <b>support</b> type, you may toggle your basic attacks to a healing mode. In addition, Alt-Clicking on an adjacent object or mob will warp them to your bluespace beacon after a short delay.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the CMO, a potent force of life... and death.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! You caught a support carp. It's a kleptocarp!</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Support modules active. Holoparasite swarm online.</span>"
	abilities = list(/datum/guardian_abilities/heal)

/obj/structure/recieving_pad
	name = "bluespace recieving pad"
	icon = 'icons/turf/floors.dmi'
	desc = "A recieving zone for bluespace teleportations."
	icon_state = "light_on-w"
	luminosity = 1
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER

/obj/structure/recieving_pad/New(loc, mob/living/simple_animal/hostile/guardian/healer/G)
	. = ..()
	if(G.namedatum)
		add_atom_colour(G.namedatum.colour, FIXED_COLOUR_PRIORITY)

/obj/structure/recieving_pad/proc/disappear()
	visible_message("[src] vanishes!")
	qdel(src)
