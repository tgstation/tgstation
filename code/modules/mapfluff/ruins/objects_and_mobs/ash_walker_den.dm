#define ASH_WALKER_SPAWN_THRESHOLD 2
//The ash walker den consumes corpses or unconscious mobs to create ash walker eggs. For more info on those, check ghost_role_spawners.dm
/obj/structure/lavaland/ash_walker
	name = "necropolis tendril nest"
	desc = "A vile tendril of corruption. It's surrounded by a nest of rapidly growing eggs..."
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	icon_state = "ash_walker_nest"

	move_resist=INFINITY // just killing it tears a massive hole in the ground, let's not move it
	anchored = TRUE
	density = TRUE

	resistance_flags = FIRE_PROOF | LAVA_PROOF
	max_integrity = 200

	faction = list(FACTION_ASHWALKER)

	var/meat_counter = 6
	var/datum/team/ashwalkers/ashies
	var/datum/linked_objective

/obj/structure/lavaland/ash_walker/Initialize(mapload)
	.=..()
	ashies = new /datum/team/ashwalkers()
	var/datum/objective/protect_object/objective = new
	objective.set_target(src)
	objective.team = ashies
	linked_objective = objective
	ashies.objectives += objective
	START_PROCESSING(SSprocessing, src)

/obj/structure/lavaland/ash_walker/Destroy()
	ashies = null
	linked_objective = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/lavaland/ash_walker/atom_deconstruct(disassembled)
	var/core_to_drop = pick(subtypesof(/obj/item/assembly/signaler/anomaly))
	new core_to_drop (get_step(loc, pick(GLOB.alldirs)))
	new /obj/effect/collapse(loc)

/obj/structure/lavaland/ash_walker/process()
	consume()
	spawn_mob()

/obj/structure/lavaland/ash_walker/proc/consume()
	for(var/mob/living/offeredmob in view(src, 1)) //Only for corpse right next to/on same tile
		if(offeredmob.loc == src)
			continue //Ashwalker Revive in Progress...
		if(offeredmob.stat)
			offeredmob.unequip_everything()

			if(issilicon(offeredmob)) //no advantage to sacrificing borgs...
				offeredmob.investigate_log("has been gibbed by the necropolis tendril.", INVESTIGATE_DEATHS)
				visible_message(span_notice("Serrated tendrils eagerly pull [offeredmob] apart, but find nothing of interest."))
				offeredmob.gib()
				return

			if(offeredmob.mind?.has_antag_datum(/datum/antagonist/ashwalker) && (offeredmob.ckey || offeredmob.get_ghost(FALSE, TRUE))) //special interactions for dead lava lizards with ghosts attached
				visible_message(span_warning("Serrated tendrils carefully pull [offeredmob] to [src], absorbing the body and creating it anew."))
				var/datum/mind/deadmind
				if(offeredmob.ckey)
					deadmind = offeredmob
				else
					deadmind = offeredmob.get_ghost(FALSE, TRUE)
				to_chat(deadmind, "Your body has been returned to the nest. You are being remade anew, and will awaken shortly. </br><b>Your memories will remain intact in your new body, as your soul is being salvaged</b>")
				SEND_SOUND(deadmind, sound('sound/effects/magic/enter_blood.ogg',volume=100))
				addtimer(CALLBACK(src, PROC_REF(remake_walker), offeredmob), 20 SECONDS)
				offeredmob.forceMove(src)
				return

			if(ismegafauna(offeredmob))
				meat_counter += 20
			else
				meat_counter++
			visible_message(span_warning("Serrated tendrils eagerly pull [offeredmob] to [src], tearing the body apart as its blood seeps over the eggs."))
			playsound(get_turf(src),'sound/effects/magic/demon_consume.ogg', 100, TRUE)
			var/deliverykey = offeredmob.fingerprintslast //ckey of whoever brought the body
			var/mob/living/deliverymob = get_mob_by_key(deliverykey) //mob of said ckey
			//there is a 40% chance that the Lava Lizard unlocks their respawn with each sacrifice
			if(deliverymob && (deliverymob.mind?.has_antag_datum(/datum/antagonist/ashwalker)) && (deliverykey in ashies.players_spawned) && (prob(40)))
				to_chat(deliverymob, span_warning("<b>The Necropolis is pleased with your sacrifice. You feel confident your existence after death is secure.</b>"))
				ashies.players_spawned -= deliverykey
			offeredmob.investigate_log("has been gibbed by the necropolis tendril.", INVESTIGATE_DEATHS)
			offeredmob.gib(DROP_ALL_REMAINS)
			atom_integrity = min(atom_integrity + max_integrity*0.05,max_integrity)//restores 5% hp of tendril
			for(var/mob/living/L in view(src, 5))
				if(L.mind?.has_antag_datum(/datum/antagonist/ashwalker))
					L.add_mood_event("oogabooga", /datum/mood_event/sacrifice_good)
				else
					L.add_mood_event("oogabooga", /datum/mood_event/sacrifice_bad)
			ashies.sacrifices_made++

/obj/structure/lavaland/ash_walker/proc/remake_walker(mob/living/carbon/oldmob)
	var/mob/living/carbon/human/newwalker = new /mob/living/carbon/human(get_step(loc, pick(GLOB.alldirs)))
	newwalker.set_species(/datum/species/lizard/ashwalker)
	newwalker.real_name = oldmob.real_name
	newwalker.undershirt = "Nude"
	newwalker.underwear = "Nude"
	newwalker.update_body()
	newwalker.remove_language(/datum/language/common)
	oldmob.mind.transfer_to(newwalker)
	newwalker.mind.grab_ghost()
	to_chat(newwalker, "<b>You have been pulled back from beyond the grave, with a new body and renewed purpose. Glory to the Necropolis!</b>")
	playsound(get_turf(newwalker),'sound/effects/magic/exit_blood.ogg', 100, TRUE)
	qdel(oldmob)

/obj/structure/lavaland/ash_walker/proc/spawn_mob()
	if(meat_counter >= ASH_WALKER_SPAWN_THRESHOLD)
		new /obj/effect/mob_spawn/ghost_role/human/ash_walker(get_step(loc, pick(GLOB.alldirs)), ashies)
		visible_message(span_danger("One of the eggs swells to an unnatural size and tumbles free. It's ready to hatch!"))
		meat_counter -= ASH_WALKER_SPAWN_THRESHOLD
		ashies.eggs_created++

/obj/structure/lavaland/ash_walker_fake
	name = "necropolis tendril nest"
	desc = "A vile tendril of corruption. It's surrounded by a nest of rapidly growing eggs..."
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	icon_state = "ash_walker_nest"
	move_resist = INFINITY
	anchored = TRUE
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	max_integrity = 200

#undef ASH_WALKER_SPAWN_THRESHOLD
