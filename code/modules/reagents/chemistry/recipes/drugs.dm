/datum/chemical_reaction/space_drugs
	results = list(/datum/reagent/drug/space_drugs = 3)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/lithium = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG

/datum/chemical_reaction/krokodil
	results = list(/datum/reagent/drug/krokodil = 6)
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/medicine/morphine = 1, /datum/reagent/space_cleaner = 1, /datum/reagent/potassium = 1, /datum/reagent/phosphorus = 1, /datum/reagent/fuel = 1)
	mix_message = "The mixture dries into a pale blue powder."
	required_temp = 380
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG

/datum/chemical_reaction/methamphetamine
	results = list(/datum/reagent/drug/methamphetamine = 4)
	required_reagents = list(/datum/reagent/medicine/ephedrine = 1, /datum/reagent/iodine = 1, /datum/reagent/phosphorus = 1, /datum/reagent/hydrogen = 1)
	required_temp = 372
	optimal_temp = 376//Wow this is tight
	overheat_temp = 380
	optimal_ph_min = 6.5
	optimal_ph_max = 7.5
	determin_ph_range = 5
	temp_exponent_factor = 1
	ph_exponent_factor = 1.4
	thermic_constant = 0.1 //exothermic nature is equal to impurty
	H_ion_release = -0.025
	rate_up_lim = 12.5
	purity_min = 0.5 //100u will natrually just dip under this w/ no buffer
	reaction_flags = REACTION_HEAT_ARBITARY //Heating up is arbitary because of submechanics of this reaction.
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DRUG | REACTION_TAG_DANGEROUS

//The less pure it is, the faster it heats up. tg please don't hate me for making your meth even more dangerous
/datum/chemical_reaction/methamphetamine/reaction_step(datum/reagents/holder, datum/equilibrium/reaction, delta_t, delta_ph, step_reaction_vol)
	var/datum/reagent/meth = holder.has_reagent(/datum/reagent/drug/methamphetamine)
	if(!meth)//First step
		reaction.thermic_mod = (1-delta_ph)*5
		return
	reaction.thermic_mod = (1-meth.purity)*5

/datum/chemical_reaction/methamphetamine/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	. = ..()
	temp_meth_explosion(holder, equilibrium.reacted_vol)

/datum/chemical_reaction/methamphetamine/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	. = ..()
	temp_meth_explosion(holder, equilibrium.reacted_vol)

/datum/chemical_reaction/methamphetamine/reaction_finish(datum/reagents/holder, datum/equilibrium/reaction, react_vol)
	var/datum/reagent/meth = holder.has_reagent(/datum/reagent/drug/methamphetamine)
	if(!meth)//Other procs before this can already blow us up
		return ..()
	if(meth.purity < purity_min)
		temp_meth_explosion(holder, react_vol)
		return
	return ..()

//Refactoring of explosions is coming later, this is till then so it still explodes
/datum/chemical_reaction/methamphetamine/proc/temp_meth_explosion(datum/reagents/holder, explode_vol)
	var/power = 5 + round(explode_vol/12, 1) //meth strengthdiv is 12
	if(power <= 0)
		return
	var/turf/T = get_turf(holder.my_atom)
	var/inside_msg
	if(ismob(holder.my_atom))
		var/mob/M = holder.my_atom
		inside_msg = " inside [ADMIN_LOOKUPFLW(M)]"
		return
	var/lastkey = holder.my_atom.fingerprintslast
	var/touch_msg = "N/A"
	if(lastkey)
		var/mob/toucher = get_mob_by_key(lastkey)
		touch_msg = "[ADMIN_LOOKUPFLW(toucher)]"
	if(!istype(holder.my_atom, /obj/machinery/plumbing)) //excludes standard plumbing equipment from spamming admins with this shit
		message_admins("Reagent explosion reaction occurred at [ADMIN_VERBOSEJMP(T)][inside_msg]. Last Fingerprint: [touch_msg].")
	log_game("Reagent explosion reaction occurred at [AREACOORD(T)]. Last Fingerprint: [lastkey ? lastkey : "N/A"]." )
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(power, T, 0, 0)
	e.start(holder.my_atom)
	holder.clear_reagents()

/datum/chemical_reaction/bath_salts
	results = list(/datum/reagent/drug/bath_salts = 7)
	required_reagents = list(/datum/reagent/toxin/bad_food = 1, /datum/reagent/saltpetre = 1, /datum/reagent/consumable/nutriment = 1, /datum/reagent/space_cleaner = 1, /datum/reagent/consumable/enzyme = 1, /datum/reagent/consumable/tea = 1, /datum/reagent/mercury = 1)
	required_temp = 374
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/aranesp
	results = list(/datum/reagent/drug/aranesp = 3)
	required_reagents = list(/datum/reagent/medicine/epinephrine = 1, /datum/reagent/medicine/atropine = 1, /datum/reagent/medicine/morphine = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_TOXIN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/happiness
	results = list(/datum/reagent/drug/happiness = 4)
	required_reagents = list(/datum/reagent/nitrous_oxide = 2, /datum/reagent/medicine/epinephrine = 1, /datum/reagent/consumable/ethanol = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/pumpup
	results = list(/datum/reagent/drug/pumpup = 5)
	required_reagents = list(/datum/reagent/medicine/epinephrine = 2, /datum/reagent/consumable/coffee = 5)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_TOXIN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/maint_tar1
	results = list(/datum/reagent/toxin/acid = 1 ,/datum/reagent/drug/maint/tar = 3)
	required_reagents = list(/datum/reagent/consumable/tea = 1, /datum/reagent/yuck = 1 , /datum/reagent/fuel = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_TOXIN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/maint_tar2
	results = list(/datum/reagent/toxin/acid = 1 ,/datum/reagent/drug/maint/tar = 3)
	required_reagents = list(/datum/reagent/consumable/tea = 1, /datum/reagent/consumable/enzyme = 3 , /datum/reagent/fuel = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_TOXIN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/maint_sludge
	results = list(/datum/reagent/drug/maint/sludge = 1)
	required_reagents = list(/datum/reagent/drug/maint/tar = 3 , /datum/reagent/toxin/acid/fluacid = 1)
	required_catalysts = list(/datum/reagent/hydrogen_peroxide = 5)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_TOXIN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/maint_powder
	results = list(/datum/reagent/drug/maint/powder = 1)
	required_reagents = list(/datum/reagent/drug/maint/sludge = 6 , /datum/reagent/toxin/acid/nitracid = 1 , /datum/reagent/consumable/enzyme = 1)
	required_catalysts = list(/datum/reagent/acetone_oxide = 5)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING

//These drug item reactions should probably be converted to fermichem in the future.
/datum/chemical_reaction/moon_rock //botany is real easy so it requires a lot of kronkus_extract, make it cheaper if it doesnt get made.
	required_reagents = list(/datum/reagent/kronkus_extract = 15, /datum/reagent/fuel = 5, /datum/reagent/ammonia = 3)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/moon_rock/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		var/obj/item/food/drug/moon_rock/new_rock = new(location)
		new_rock.pixel_x = rand(-6, 6)
		new_rock.pixel_y = rand(-6, 6)

/datum/chemical_reaction/moon_rock/draintek
	required_reagents = list(/datum/reagent/kronkus_extract = 15, /datum/reagent/fuel = 5, /datum/reagent/lye = 3)

/datum/chemical_reaction/blastoff_ampoule
	required_reagents = list(/datum/reagent/silver = 10, /datum/reagent/toxin/cyanide = 10, /datum/reagent/lye = 5)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/blastoff_ampoule/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/iteration in 1 to created_volume)
		var/obj/item/reagent_containers/cup/blastoff_ampoule/new_ampoule = new(location)
		new_ampoule.pixel_x = rand(-6, 6)
		new_ampoule.pixel_y = rand(-6, 6)

/datum/chemical_reaction/saturnx_glob
	required_reagents = list(/datum/reagent/lead = 5, /datum/reagent/consumable/nothing = 5, /datum/reagent/drug/maint/tar = 10)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/saturnx_glob/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/iteration in 1 to created_volume)
		var/obj/item/food/drug/saturnx/new_glob = new(location)
		new_glob.pixel_x = rand(-6, 6)
		new_glob.pixel_y = rand(-6, 6)
