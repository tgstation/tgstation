/obj/item/ammo_casing/glockroach
	name = "1.6180339887mm bullet casing"
	desc = "Biosynth refuse. Smells like shit, because it is."
	color = COLOR_VERY_DARK_LIME_GREEN

/mob/living/basic/cockroach/glockroach
	name = "synthroach"
	desc = "Level-two biosynth pests, originating from an old border-skirmish. Once dog-sized, heavily-plated beasts, now grounded by evolutionarily purposeless march of cytosine to uracil to thymine over hundreds of years."
	icon = 'modular_doppler/modular_mobs/simple_animal/synthroach.dmi'
	icon_state = "synthroach"
	icon_dead = "synthroach_no_animation"

/mob/living/basic/cockroach/glockroach/emp_act(severity) //emp's were killing them for some reason i just can not explain. idfk.
	. = ..()
	return FALSE

/mob/living/basic/cockroach/hauberoach
	name = "spikeroach"
	desc = "Synthroach. Sacrificial idiot. Practically trying to run under your boots. Beeps ominously. Its entire body is a crumple zone containing very fun mixtures of small-scale ordinance. Feels, generally, like a bad idea."
	icon = 'modular_doppler/modular_mobs/simple_animal/synthroach.dmi'
	icon_state = "spikeroach"
	icon_dead = "synthroach_no_animation"

/mob/living/basic/cockroach/hauberoach/emp_act(severity)
	. = ..()
	return FALSE

/mob/living/basic/cockroach/glockroach/mobroach
	name = "gunroach"
	desc = "Primordial biosynth-weaponry trapped in a cylinder of frenetically-firing silicon tetrachlorides. Purposeless once-weapon for a battle that ended a long time ago. No reparations were paid to it. More pressingly; literally frothing at the mouth to shoot you."
	icon = 'modular_doppler/modular_mobs/simple_animal/synthroach.dmi'
	icon_state = "gunroach"

/mob/living/basic/cockroach/glockroach/mobroach/emp_act(severity)
	. = ..()
	return FALSE
