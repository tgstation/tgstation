//Beam
/obj/effect/ebeam/chain
	name = "lightning chain"
	layer = LYING_MOB_LAYER

/mob/living/simple_animal/hostile/sutando/beam
	playstyle_string = "<span class='holoparasite'>As a <b>lightning</b> type, you will apply lightning chains to targets on attack and have a lightning chain to your summoner. Lightning chains will shock anyone near them.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Tesla, a shocking, lethal source of power.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Lightning modules active. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! Caught one! It's a lightning carp! Everyone else goes zap zap.</span>"
	abilities = list(/datum/sutando_abilities/lightning)
