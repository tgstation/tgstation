
/obj/structure/window/reinforced/fulltile/indestructible
	name = "robust window"
	atom_flags = PREVENT_CLICK_UNDER | NODECONSTRUCT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/grille/indestructible
	atom_flags = CONDUCT | NODECONSTRUCT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/spawner/structure/window/reinforced/indestructible
	spawn_list = list(/obj/structure/grille/indestructible, /obj/structure/window/reinforced/fulltile/indestructible)

/obj/structure/barricade/security/murderdome
	name = "respawnable barrier"
	desc = "A barrier. Provides cover in firefights."
	deploy_time = 0
	deploy_message = 0

/obj/structure/barricade/security/murderdome/make_debris()
	new /obj/effect/murderdome/dead_barricade(get_turf(src))

/obj/effect/murderdome/dead_barricade
	name = "dead barrier"
	desc = "It provided cover in fire fights. And now it's gone."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"
	alpha = 100

/obj/effect/murderdome/dead_barricade/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, .proc/respawn), 3 MINUTES)

/obj/effect/murderdome/dead_barricade/proc/respawn()
	if(!QDELETED(src))
		new /obj/structure/barricade/security/murderdome(get_turf(src))
		qdel(src)
