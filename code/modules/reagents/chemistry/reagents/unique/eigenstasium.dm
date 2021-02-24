////////////////////////////////////////////////////////////////////////////////////////////////////
//										EIGENSTASIUM
///////////////////////////////////////////////////////////////////////////////////////////////////
//eigenstate Chem
//Teleports you to the creation location and back
//OD teleports you randomly around the Station and gives you a status effect
//The status effect slowly send you on a wild ride and replaces you with an alternative reality version of yourself unless you consume eigenstasium/bluespace dust.
//During the process you get really hungry, then some of your items slowly start teleport around you,
//then alternative versions of yourself are brought in from a different universe and they yell at you.
//and finally you yourself get teleported to an alternative universe, and character your playing is replaced with said alternative

/datum/reagent/eigenstate
	name = "Eigenstasium"
	description = "A strange mixture formed from a controlled reaction of bluespace with plasma, that causes localised eigenstate fluxuations within the patient"
	taste_description = "wiggly cosmic dust."
	color = "#5020F4"
	overdose_threshold = 15
	metabolization_rate = 1 * REAGENTS_METABOLISM
	ph = 3.7
	impure_chem = /datum/reagent/impurity/eigenswap
	inverse_chem = null
	failed_chem = /datum/reagent/bluespace //crashes out
	chemical_flags = REAGENT_DEAD_PROCESS //So if you die with it in your body, you still get teleported back to the location as a corpse
	data = list("location_created" = null, "creator" = null)//So we retain the target location and creator between reagent instances
	///The creation point assigned during the reaction
	var/turf/location_created
	///The mob that initial teleport is linked to
	var/mob/living/carbon/creator
	///The return point indicator
	var/obj/effect/overlay/holo_pad_hologram/eigenstate
	///The point you're returning to after the reagent is removed
	var/turf/open/location_return = null

/datum/reagent/eigenstate/on_new(list/data)
	location_created = data["location_created"]
	creator = data["creator"]

/datum/reagent/eigenstate/expose_mob(mob/living/living_mob, methods, reac_volume, show_message, touch_protection)
	. = ..()
	if(!(methods & INGEST))
		return
	if(creation_purity > 0.9 && location_created) //Teleports you home if it's pure enough
		do_sparks(5,FALSE,living_mob)
		do_teleport(living_mob, location_created, 0, asoundin = 'sound/effects/phasein.ogg')
		do_sparks(5,FALSE,living_mob)

//Main functions
/datum/reagent/eigenstate/on_mob_add(mob/living/living_mob, amount)
	//make hologram at return point
	eigenstate = new (living_mob.loc)
	eigenstate.appearance = creator ? creator.appearance : living_mob.appearance //Blood lets you set your eigenstate icon
	eigenstate.alpha = 170
	eigenstate.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
	eigenstate.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
	eigenstate.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
	eigenstate.anchored = 1//So space wind cannot drag it.
	eigenstate.name = "[creator ? creator.appearance : living_mob.appearance]'s' eigenstate"//If someone decides to right click.
	eigenstate.set_light(2)	//hologram lighting

	location_return = get_turf(living_mob)	//sets up return point
	to_chat(living_mob, "<span class='userdanger'>You feel your wavefunction split!</span>")

	return ..()

/datum/reagent/eigenstate/on_mob_life(mob/living/carbon/living_mob)
	if(prob(20))
		do_sparks(5,FALSE,living_mob)

	return ..()

/datum/reagent/eigenstate/on_mob_delete(mob/living/living_mob) //returns back to original location
	do_sparks(5,FALSE,living_mob)
	to_chat(living_mob, "<span class='userdanger'>You feel your wavefunction collapse!</span>")
	if(!living_mob.reagents.has_reagent(/datum/reagent/stabilizing_agent))
		do_teleport(living_mob, location_return, 0, asoundin = 'sound/effects/phasein.ogg') //Teleports home
		do_sparks(5,FALSE,living_mob)
	qdel(eigenstate)
	return ..()

/datum/reagent/eigenstate/overdose_start(mob/living/living_mob) //Overdose, makes you teleport randomly
	to_chat(living_mob, "<span class='userdanger'>Oh god, you feel like your wavefunction is about to tear.</span>")
	living_mob.Jitter(20)
	metabolization_rate += 0.5 //So you're not stuck forever teleporting.
	if(iscarbon(living_mob))
		var/mob/living/carbon/carbon_mob = living_mob
		carbon_mob.apply_status_effect(STATUS_EFFECT_EIGEN)
	return ..()

/datum/reagent/eigenstate/overdose_process(mob/living/living_mob) //Overdose, makes you teleport randomly
	do_sparks(5, FALSE, living_mob)
	do_teleport(living_mob, get_turf(living_mob), 10, asoundin = 'sound/effects/phasein.ogg')
	do_sparks(5, FALSE, living_mob)
	return ..()

//FOR ADDICTION EFFECTS, SEE datum/status_effect/eigenstasium

///Lets you link lockers together
/datum/reagent/eigenstate/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(creation_purity < 0.8)
		return
	var/list/lockers = list()
	for(var/obj/structure/closet/closet in exposed_turf.contents)
		lockers += closet
	if(!length(lockers))
		return
	SSeigenstates.create_new_link(lockers)

//eigenstate END
