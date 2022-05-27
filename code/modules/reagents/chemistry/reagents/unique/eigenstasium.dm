
/*eigenstate themed Chem
 *Teleports you to the creation location on consumption and back when the reagent is removed from you
 *OD teleports you randomly around the Station and gives you a status effect
 *The status effect slowly send you on a wild ride and replaces you with an alternative reality version of yourself unless you consume eigenstasium/bluespace dust/stabilising agent.
 *During the process you get really hungry,
 *Then some of your items slowly start teleport around you,
 *then alternative versions of yourself are brought in from a different universe and they yell at you.
 *and finally you yourself get teleported to an alternative universe, and character your playing is replaced with said alternative
 *Spraying this on lockers allows you to create eigenlinked lockers - see the eigenstate subsystem for using this to create your own links
*/
/datum/reagent/eigenstate
	name = "Eigenstasium"
	description = "A strange mixture formed from a controlled reaction of bluespace with plasma, that causes localised eigenstate fluxuations within the patient"
	taste_description = "wiggly cosmic dust."
	color = "#5020F4"
	overdose_threshold = 15
	metabolization_rate = 1 * REAGENTS_METABOLISM
	ph = 3.7
	purity = 0.5
	creation_purity = 0.5
	impure_chem = /datum/reagent/impurity/eigenswap
	inverse_chem = null
	inverse_chem_val = 0
	failed_chem = /datum/reagent/bluespace //crashes out
	chemical_flags = REAGENT_DEAD_PROCESS //So if you die with it in your body, you still get teleported back to the location as a corpse
	data = list("location_created" = null, "ingested" = FALSE)//So we retain the target location and creator between reagent instances
	///The creation point assigned during the reaction
	var/turf/location_created
	///The return point indicator
	var/obj/effect/overlay/holo_pad_hologram/eigenstate
	///The point you're returning to after the reagent is removed
	var/turf/open/location_return = null

/datum/reagent/eigenstate/on_new(list/data)
	. = ..()
	if(!data)
		return
	location_created = data["location_created"]

/datum/reagent/eigenstate/expose_mob(mob/living/living_mob, methods, reac_volume, show_message, touch_protection)
	. = ..()
	if(!(methods & INGEST) || !iscarbon(living_mob))
		return
	//This looks rediculous, but expose is usually called from the donor reagents datum - we want to edit the post exposure version present in the mob.
	var/mob/living/carbon/carby = living_mob
	//But because carbon mobs have stomachs we have to search in there because we're ingested
	var/obj/item/organ/stomach/stomach = carby.getorganslot(ORGAN_SLOT_STOMACH)
	var/datum/reagent/eigenstate/eigen
	if(stomach)
		eigen = stomach.reagents.has_reagent(/datum/reagent/eigenstate)
	if(!eigen)//But what if they have no stomach! I want to get off expose_mob's wild ride
		eigen = carby.reagents.has_reagent(/datum/reagent/eigenstate)
	//Because expose_mob and on_mob_add() across all of the different things call them in different orders, so I want to make sure whatever is the first one to call it sets up the location correctly.
	eigen.data["ingested"] = TRUE

//Main functions
/datum/reagent/eigenstate/on_mob_add(mob/living/living_mob, amount)
	//make hologram at return point to indicate where someone will go back to
	eigenstate = new (living_mob.loc)
	eigenstate.appearance = living_mob.appearance
	eigenstate.alpha = 170
	eigenstate.add_atom_colour(LIGHT_COLOR_LIGHT_CYAN, FIXED_COLOUR_PRIORITY)
	eigenstate.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
	eigenstate.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
	eigenstate.set_anchored(TRUE) //So space wind cannot drag it.
	eigenstate.name = "[living_mob.name]'s Eigenstate"//If someone decides to right click.
	eigenstate.set_light(2)	//hologram lighting

	location_return = get_turf(living_mob)	//sets up return point
	to_chat(living_mob, span_userdanger("You feel like part of yourself has split off!"))

	//Teleports you home if it's pure enough
	if(creation_purity > 0.9 && location_created && data["ingested"])
		do_sparks(5,FALSE,living_mob)
		do_teleport(living_mob, location_created, 0, asoundin = 'sound/effects/phasein.ogg')
		do_sparks(5,FALSE,living_mob)

	return ..()

/datum/reagent/eigenstate/on_mob_life(mob/living/carbon/living_mob)
	if(prob(20))
		do_sparks(5,FALSE,living_mob)

	return ..()

/datum/reagent/eigenstate/on_mob_delete(mob/living/living_mob) //returns back to original location
	do_sparks(5,FALSE,living_mob)
	to_chat(living_mob, span_userdanger("You feel strangely whole again."))
	if(!living_mob.reagents.has_reagent(/datum/reagent/stabilizing_agent))
		do_teleport(living_mob, location_return, 0, asoundin = 'sound/effects/phasein.ogg') //Teleports home
		do_sparks(5,FALSE,living_mob)
	qdel(eigenstate)
	return ..()

/datum/reagent/eigenstate/overdose_start(mob/living/living_mob) //Overdose, makes you teleport randomly
	to_chat(living_mob, span_userdanger("You feel like your perspective is being ripped apart as you begin flitting in and out of reality!"))
	living_mob.set_timed_status_effect(40 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	metabolization_rate += 0.5 //So you're not stuck forever teleporting.
	if(iscarbon(living_mob))
		var/mob/living/carbon/carbon_mob = living_mob
		carbon_mob.apply_status_effect(/datum/status_effect/eigenstasium)
	return ..()

/datum/reagent/eigenstate/overdose_process(mob/living/living_mob) //Overdose, makes you teleport randomly
	do_sparks(5, FALSE, living_mob)
	do_teleport(living_mob, get_turf(living_mob), 10, asoundin = 'sound/effects/phasein.ogg')
	do_sparks(5, FALSE, living_mob)
	return ..()

//FOR ADDICTION-LIKE EFFECTS, SEE datum/status_effect/eigenstasium

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
