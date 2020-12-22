
/datum/chemical_reaction/quaprotium	// Check this out
	results = list(/datum/reagent/quaprotium = 1)
	required_reagents = list(/datum/reagent/bluespace = 2, /datum/reagent/stable_plasma = 1, /datum/reagent/acetone = 1, /datum/reagent/carbon = 3)
	required_catalysts = list(/datum/reagent/toxin/acid = 5)

	required_temp = 670
	can_mix = FALSE
	explode = TRUE
	fuckup_temp = 720
	required_pH_max = 13
	required_pH_min = 12
	heat_per_u = 10
	mob_react = FALSE

/datum/chemical_reaction/quaprotium/minor_fuckup(var/datum/reagents/holder, var/obj/item/reagent_containers/beaker, var/mob/choomist)
	. = ..()
	if(ishuman(choomist))
		var/mob/living/carbon/human/chemist = choomist
		var/obj/item/bodypart/arm = chemist.get_active_hand()
		to_chat(chemist,"<span class='userdanger'>Your [arm] suddenly gets caught into a bluespace pocket and atomized!</span>")
		arm.dismember()
		qdel(arm)
	holder.chem_temp += 60 //Heats up violently for any mistakes.

/datum/chemical_reaction/quaprotium/major_fuckup(var/datum/reagents/holder, var/obj/item/reagent_containers/beaker, var/mob/choomist)
	. = ..()
	if(beaker && istype(beaker))
		var/obj/item/beacon/chosen
		var/list/possible = list()
		for(var/obj/item/beacon/W in GLOB.teleportbeacons)
			possible += W

		if(possible.len > 0)
			chosen = pick(possible)

		if(chosen)
			var/turf/TO = get_turf(chosen)
			var/turf/FROM = get_turf(beaker)
			playsound(TO, 'sound/effects/phasein.ogg', 100, TRUE)

			var/list/flashers = list()
			for(var/mob/living/carbon/C in viewers(TO, null))
				if(C.flash_act())
					flashers += C

			for(var/atom/movable/A in range(3, FROM))
				if(istype(A, /obj/item/beacon))
					continue // don't teleport beacons because that's just insanely stupid
				if(A.anchored)
					continue

				var/turf/newloc = locate(A.x + TO.x - FROM.x, A.y + TO.y - FROM.y, TO.z)

				if(!A.Move(newloc) && newloc) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
					A.forceMove(newloc)

				if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
					var/mob/M = A
					if(M.client)
						INVOKE_ASYNC(src, .proc/blue_effect, M)

/datum/chemical_reaction/quaprotium/proc/blue_effect(mob/M)
	var/obj/blueeffect = new /obj(src)
	blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
	blueeffect.icon = 'icons/effects/effects.dmi'
	blueeffect.icon_state = "shieldsparkles"
	blueeffect.layer = FLASH_LAYER
	blueeffect.plane = FULLSCREEN_PLANE
	blueeffect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	M.client.screen += blueeffect
	sleep(20)
	M.client.screen -= blueeffect
	qdel(blueeffect)

/datum/chemical_reaction/zeolites
	results = list(/datum/reagent/zeolites = 3)
	required_reagents = list(/datum/reagent/medicine/potass_iodide = 1, /datum/reagent/aluminium = 1, /datum/reagent/silicon = 1, /datum/reagent/oxygen = 1)
	required_catalysts = list(/datum/reagent/uranium = 5)

	can_mix = FALSE
	heat_per_u = 1
	required_pH_max = 9
	required_pH_min = 5

/datum/chemical_reaction/nanite_b_gone
	results = list(/datum/reagent/nanite_b_gone = 4)
	required_reagents = list(/datum/reagent/medicine/c2/synthflesh = 1, /datum/reagent/uranium = 1, /datum/reagent/iron = 1, /datum/reagent/medicine/salglu_solution = 1)
	mix_message = "the reaction gurgles, encapsulating the reagents in flesh before the emp can be set off."
	required_temp = 450
	heat_per_u = -5

	required_pH_max = 7
	required_pH_min = 1
	can_mix = FALSE
	mob_react = FALSE

/datum/chemical_reaction/nanite_b_gone/minor_fuckup(var/datum/reagents/holder, var/obj/item/reagent_containers/beaker, var/mob/choomist)
	. = ..()
	beaker.visible_message("<span class='danger'>The EMP goes off too soon and synthetical tissue can't contain it!</span>")
	empulse(get_turf(beaker), 1, 3) //A small EMP to punish the chemist

/datum/chemical_reaction/quaprotium/major_fuckup(var/datum/reagents/holder, var/obj/item/reagent_containers/beaker, var/mob/choomist) //OOF
	tesla_zap(src, 3, holder.get_reagent_amount(/datum/reagent/iron) * 10, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN | ZAP_ALLOW_DUPLICATES)
	. = ..()

/datum/chemical_reaction/noxagenium
	results = list(/datum/reagent/toxin/noxagenium = 3)
	required_reagents = list(/datum/reagent/medicine/salbutamol = 1, /datum/reagent/oxygen = 3, /datum/reagent/acetone = 1, /datum/reagent/bromine = 2)
	mob_react = FALSE
	can_mix = FALSE
	required_temp = 720
	heat_per_u = -3

/datum/chemical_reaction/noxagenium/minor_fuckup(var/datum/reagents/holder, var/obj/item/reagent_containers/beaker, var/mob/choomist)
	. = ..()
	beaker.visible_message("<span class='warning'>The mixture starts to bubble and all the liquid disappears!</span>")

/datum/chemical_reaction/noxagenium/major_fuckup(var/datum/reagents/holder, var/obj/item/reagent_containers/beaker, var/mob/choomist)
	beaker.visible_message("<span class='danger'>The mixture starts to bubble and all the liquid evaporates, forming a cloud of toxic gas!</span>")
	var/turf/open/floor/T = get_turf(beaker)
	if(!T.air)
		. = ..()
		return
	var/datum/gas_mixture/air_contents = T.air
	if(air_contents)
		air_contents.assert_gas(/datum/gas/carbon_dioxide)
		air_contents.assert_gas(/datum/gas/nitryl)
		var/volume = holder.get_reagent_amount(/datum/reagent/bromine)
		air_contents.gases[/datum/gas/carbon_dioxide][MOLES] = (ONE_ATMOSPHERE * volume / (R_IDEAL_GAS_EQUATION * T20C))
		air_contents.gases[/datum/gas/nitryl][MOLES] = (ONE_ATMOSPHERE * volume / (R_IDEAL_GAS_EQUATION * T20C))
	. = ..()