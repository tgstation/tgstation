
/obj/structure/window/reinforced/fulltile/indestructible
	name = "robust window"
	move_resist = MOVE_FORCE_OVERPOWERING
	flags_1 = PREVENT_CLICK_UNDER_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


/obj/structure/grille/indestructible
	desc = "A STRONG framework of hardened plasteel rods, that you cannot possibly get through. If you were an engineer you would be drooling over its construction right now."
	move_resist = MOVE_FORCE_OVERPOWERING
	obj_flags = CONDUCTS_ELECTRICITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/grille/indestructible/screwdriver_act(mob/living/user, obj/item/tool)
	return NONE

/obj/structure/grille/indestructible/wirecutter_act(mob/living/user, obj/item/tool)
	return NONE

/obj/effect/spawner/structure/window/reinforced/indestructible
	spawn_list = list(/obj/structure/grille/indestructible, /obj/structure/window/reinforced/fulltile/indestructible)

/obj/structure/barricade/security/murderdome
	name = "respawnable barrier"
	desc = "A barrier. Provides cover in firefights."

/obj/structure/barricade/security/murderdome/make_debris()
	new /obj/effect/murderdome/dead_barricade(get_turf(src))

/obj/effect/murderdome/dead_barricade
	name = "dead barrier"
	desc = "It provided cover in fire fights. And now it's gone."
	icon = 'icons/obj/structures.dmi'
	icon_state = "barrier0"
	alpha = 100

/obj/effect/murderdome/dead_barricade/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(respawn)), 3 MINUTES)

/obj/effect/murderdome/dead_barricade/proc/respawn()
	if(!QDELETED(src))
		new /obj/structure/barricade/security/murderdome(get_turf(src))
		qdel(src)
