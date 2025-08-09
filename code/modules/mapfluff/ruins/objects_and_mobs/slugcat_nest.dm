#define wild_slugcat_nest_SPAWN_THRESHOLD 2
//The ash walker den consumes corpses or unconscious mobs to create ash walker eggs. For more info on those, check ghost_role_spawners.dm
/obj/structure/lavaland/wild_slugcat_nest
	name = "nest"
	desc = "Nest."
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	icon_state = "hole"

	move_resist=INFINITY // just killing it tears a massive hole in the ground, let's not move it
	anchored = TRUE
	density = TRUE

	resistance_flags = FIRE_PROOF | LAVA_PROOF
	max_integrity = 200

	faction = list(FACTION_ASHWALKER)

	var/meat_counter = 6
	var/datum/team/wild_slugcat/wild_slugcat_team
	var/datum/linked_objective

/obj/structure/lavaland/wild_slugcat_nest/Initialize(mapload)
	.=..()
	wild_slugcat_team = new /datum/team/wild_slugcat()
	var/datum/objective/protect_object/objective = new
	objective.set_target(src)
	objective.team = wild_slugcat_team
	linked_objective = objective
	wild_slugcat_team.objectives += objective
	START_PROCESSING(SSprocessing, src)

/obj/structure/lavaland/wild_slugcat_nest/Destroy()
	wild_slugcat_team = null
	linked_objective = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/lavaland/wild_slugcat_nest/atom_deconstruct(disassembled)
	var/core_to_drop = pick(subtypesof(/obj/item/assembly/signaler/anomaly))
	new core_to_drop (get_step(loc, pick(GLOB.alldirs)))
	new /obj/effect/collapse(loc)

/obj/structure/lavaland/wild_slugcat_nest/process()
	consume()
	spawn_mob()

/obj/structure/lavaland/wild_slugcat_nest/proc/consume()
	for(var/mob/living/offeredmob in view(src, 1)) //Only for corpse right next to/on same tile
		if(offeredmob.loc == src)
			continue
		if(offeredmob.stat)
			offeredmob.unequip_everything()

			if(issilicon(offeredmob)) //no advantage to sacrificing borgs...
				offeredmob.investigate_log("has been gibbed by the necropolis tendril.", INVESTIGATE_DEATHS)
				visible_message(span_notice("[offeredmob] is pulled into [src], doesn't appear to be useful."))
				offeredmob.gib()
				return

			if(offeredmob.mind?.has_antag_datum(/datum/antagonist/wild_slugcat) && (offeredmob.ckey || offeredmob.get_ghost(FALSE, TRUE))) //special interactions for dead lava lizards with ghosts attached
				visible_message(span_warning("The [offeredmob] is pulled into [src]."))
				var/mob/deadmob
				if(offeredmob.ckey)
					deadmob = offeredmob
				else
					deadmob = offeredmob.get_ghost(FALSE, TRUE)
				to_chat(deadmob, "Your body has been returned to the nest. You are being remade anew, and will awaken shortly. </br><b>Your memories will remain intact in your new body, as your soul is being salvaged</b>")
				SEND_SOUND(deadmob, sound('sound/effects/magic/enter_blood.ogg',volume=100))
				addtimer(CALLBACK(src, PROC_REF(remake_walker), offeredmob), 20 SECONDS)
				offeredmob.forceMove(src)
				return

			if(ismegafauna(offeredmob))
				meat_counter += 20
			else
				meat_counter++
			visible_message(span_warning("[offeredmob] is pulled into [src]"))
			playsound(get_turf(src),'sound/effects/magic/demon_consume.ogg', 100, TRUE)
			offeredmob.investigate_log("has been gibbed by the necropolis tendril.", INVESTIGATE_DEATHS)
			offeredmob.gib(DROP_ALL_REMAINS)
			atom_integrity = min(atom_integrity + max_integrity*0.05,max_integrity)
			wild_slugcat_team.sacrifices_made++

/obj/structure/lavaland/wild_slugcat_nest/proc/remake_walker(mob/living/oldmob)
	var/mob/living/basic/slugcat/rivulet/newwalker = new /mob/living/basic/slugcat/rivulet(get_step(loc, pick(GLOB.alldirs)))
	newwalker.remove_language(/datum/language/common)
	newwalker.grant_language(/datum/language/slugtongue)
	oldmob.mind.transfer_to(newwalker)
	newwalker.mind.grab_ghost()
	to_chat(newwalker, "<b>You have been pulled back from beyond the grave.</b>")
	playsound(get_turf(newwalker),'sound/effects/magic/exit_blood.ogg', 100, TRUE)
	qdel(oldmob)

/obj/structure/lavaland/wild_slugcat_nest/proc/spawn_mob()
	if(meat_counter >= wild_slugcat_nest_SPAWN_THRESHOLD)
		new /obj/effect/mob_spawn/ghost_role/wild_slugcat(get_step(loc, pick(GLOB.alldirs)), wild_slugcat_team)
		visible_message(span_danger("A new slugcat scurries out and quickly falls asleep."))
		meat_counter -= wild_slugcat_nest_SPAWN_THRESHOLD

#undef wild_slugcat_nest_SPAWN_THRESHOLD
