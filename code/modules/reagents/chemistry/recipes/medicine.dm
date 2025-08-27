
/datum/chemical_reaction/medicine
	required_reagents = null //Don't add this to master list
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	purity_min = 0.1
	rate_up_lim = 35
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_EASY

/datum/chemical_reaction/medicine/leporazine
	results = list(/datum/reagent/medicine/leporazine = 2)
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/copper = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/rezadone
	results = list(/datum/reagent/medicine/rezadone = 3)
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 1, /datum/reagent/cryptobiolin = 1, /datum/reagent/copper = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING

/datum/chemical_reaction/medicine/spaceacillin
	results = list(/datum/reagent/medicine/spaceacillin = 2)
	required_reagents = list(/datum/reagent/cryptobiolin = 1, /datum/reagent/medicine/epinephrine = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/oculine
	results = list(/datum/reagent/medicine/oculine = 3)
	required_reagents = list(/datum/reagent/medicine/c2/multiver = 1, /datum/reagent/carbon = 1, /datum/reagent/hydrogen = 1)
	mix_message = "The mixture bubbles noticeably and becomes a dark grey color!"
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN
	//Fermichem vars
	required_temp = 200
	optimal_temp = 400
	overheat_temp = 600
	optimal_ph_min = 4.8
	optimal_ph_max = 8.5
	determin_ph_range = 5
	temp_exponent_factor = 0.4
	ph_exponent_factor = 1.7
	thermic_constant = 1
	H_ion_release = 0.01
	rate_up_lim = 14.5
	purity_min = 0.3

/datum/chemical_reaction/medicine/oculine/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	. = ..()
	explode_flash(holder, equilibrium, round(equilibrium.reacted_vol / 10), 10)

/datum/chemical_reaction/medicine/oculine/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	. = ..()
	explode_flash(holder, equilibrium, 3, 30)


/datum/chemical_reaction/medicine/inacusiate
	results = list(/datum/reagent/medicine/inacusiate = 2)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/carbon = 1, /datum/reagent/medicine/c2/multiver = 1)
	mix_message = "The mixture sputters loudly and becomes a light grey color!"
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN
	//Fermichem vars
	required_temp = 300
	optimal_temp = 400
	overheat_temp = 500
	optimal_ph_min = 5
	optimal_ph_max = 10
	determin_ph_range = 4
	temp_exponent_factor = 0.35
	ph_exponent_factor = 1
	thermic_constant = 20
	H_ion_release = 1.5
	rate_up_lim = 3
	purity_min = 0.25

///Calls it over and over
/datum/chemical_reaction/medicine/inacusiate/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	holder.my_atom.audible_message(span_notice("[icon2html(holder.my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))]The [holder.my_atom] suddenly gives out a loud bang!"))
	explode_deafen(holder, equilibrium, 0.5, 10, 3)

/datum/chemical_reaction/medicine/inacusiate/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	var/power = equilibrium.reacted_vol/10
	holder.my_atom.audible_message(span_notice("[icon2html(holder.my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))]The [holder.my_atom] suddenly gives out an ear-crushingly loud bang!"))
	explode_deafen(holder, equilibrium, power/2, power*2, max(power/2, 3))
	clear_products(holder)

/datum/chemical_reaction/medicine/synaptizine
	results = list(/datum/reagent/medicine/synaptizine = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/lithium = 1, /datum/reagent/water = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/salglu_solution
	results = list(/datum/reagent/medicine/salglu_solution = 3)
	required_reagents = list(/datum/reagent/water/salt = 2, /datum/reagent/consumable/sugar = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/medicine/mine_salve
	results = list(/datum/reagent/medicine/mine_salve = 3)
	required_reagents = list(/datum/reagent/fuel/oil = 1, /datum/reagent/water = 1, /datum/reagent/iron = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN

/datum/chemical_reaction/medicine/mine_salve2
	results = list(/datum/reagent/medicine/mine_salve = 15)
	required_reagents = list(/datum/reagent/toxin/plasma = 5, /datum/reagent/iron = 5, /datum/reagent/consumable/sugar = 1) // A sheet of plasma, a twinkie and a sheet of metal makes four of these
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN

/datum/chemical_reaction/medicine/synthflesh
	results = list(/datum/reagent/medicine/c2/synthflesh = 3)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/carbon = 1, /datum/reagent/medicine/c2/libital = 1)
	required_temp = 250
	optimal_temp = 310
	overheat_temp = 325
	optimal_ph_min = 5.5
	optimal_ph_max = 9.5
	determin_ph_range = 3
	temp_exponent_factor = 1
	ph_exponent_factor = 2
	thermic_constant = 10
	H_ion_release = -3.5
	rate_up_lim = 20 //affected by pH too
	purity_min = 0.3
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN

/datum/chemical_reaction/medicine/calomel
	results = list(/datum/reagent/medicine/calomel = 2)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/chlorine = 1)
	required_temp = 374
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/ammoniated_mercury
	results = list(/datum/reagent/medicine/ammoniated_mercury = 3)
	required_reagents = list(/datum/reagent/medicine/calomel = 1, /datum/reagent/ammonia = 2)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/potass_iodide
	results = list(/datum/reagent/medicine/potass_iodide = 2)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/iodine = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/pen_acid
	results = list(/datum/reagent/medicine/pen_acid = 5)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/ammonia = 1, /datum/reagent/toxin/formaldehyde = 1, /datum/reagent/consumable/salt = 1, /datum/reagent/toxin/cyanide = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/sal_acid
	results = list(/datum/reagent/medicine/sal_acid = 5)
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/phenol = 1, /datum/reagent/carbon = 1, /datum/reagent/oxygen = 1, /datum/reagent/toxin/acid = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE

/datum/chemical_reaction/medicine/oxandrolone
	results = list(/datum/reagent/medicine/oxandrolone = 6)
	required_reagents = list(/datum/reagent/carbon = 3, /datum/reagent/phenol = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BURN

/datum/chemical_reaction/medicine/salbutamol
	results = list(/datum/reagent/medicine/salbutamol = 5)
	required_reagents = list(/datum/reagent/medicine/sal_acid = 1, /datum/reagent/lithium = 1, /datum/reagent/aluminium = 1, /datum/reagent/bromine = 1, /datum/reagent/ammonia = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OXY

/datum/chemical_reaction/medicine/albuterol_creation
	results = list(/datum/reagent/medicine/albuterol = 15)
	required_reagents = list(/datum/reagent/lithium = 3, /datum/reagent/aluminium = 3, /datum/reagent/bromine = 3, /datum/reagent/inverse/healing/convermol = 1)
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_ORGAN | REACTION_TAG_OTHER
	required_temp = 400
	optimal_temp = 600
	overheat_temp = 900

/datum/chemical_reaction/medicine/salbutamol_to_albuterol
	results = list(/datum/reagent/medicine/albuterol = 4, /datum/reagent/medicine/sal_acid = 0.5, /datum/reagent/ammonia = 0.5)
	required_catalysts = list(/datum/reagent/toxin/acid = 1)
	required_reagents = list(/datum/reagent/medicine/salbutamol = 5, /datum/reagent/medicine/c2/convermol = 1)
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_ORGAN | REACTION_TAG_OTHER
	required_temp = 500
	optimal_temp = 610
	overheat_temp = 980
	thermic_constant = 75
	rate_up_lim = 10
	mix_message = "The solution rapidly changes colors, boiling into a pale blue."

/datum/chemical_reaction/medicine/albuterol_to_salbutamol
	results = list(/datum/reagent/medicine/salbutamol = 2, /datum/reagent/ammonia = 1)
	required_catalysts = list(/datum/reagent/toxin/acid = 1)
	required_reagents = list(/datum/reagent/medicine/albuterol = 3, /datum/reagent/oxygen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_ORGAN | REACTION_TAG_OTHER
	required_temp = 300
	optimal_temp = 500
	overheat_temp = 800
	mix_message = "The solution breaks apart, turning a deeper blue."

/datum/chemical_reaction/medicine/albuterol_to_inverse_convermol
	results = list(/datum/reagent/inverse/healing/convermol = 1, /datum/reagent/lithium = 3, /datum/reagent/aluminium = 3, /datum/reagent/bromine = 3)
	required_catalysts = list(/datum/reagent/toxin/acid/fluacid = 1)
	required_reagents = list(/datum/reagent/medicine/albuterol = 5)
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_ORGAN | REACTION_TAG_OTHER
	required_temp = 900
	optimal_temp = 920
	overheat_temp = 990
	thermic_constant = 25
	mix_message = "The solution rapidly breaks apart, turning a mix of colors."

/datum/chemical_reaction/medicine/albuterol_to_inverse_convermol/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, impure = FALSE)
	var/bonus = impure ? 2 : 1
	explode_smoke(holder, equilibrium, 7.5 * bonus, TRUE, TRUE)

/datum/chemical_reaction/medicine/ephedrine
	results = list(/datum/reagent/medicine/ephedrine = 4)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/fuel/oil = 1, /datum/reagent/hydrogen = 1, /datum/reagent/diethylamine = 1)
	mix_message = "The solution fizzes and gives off toxic fumes."
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DANGEROUS
	//FermiChem vars:
	required_temp = 200
	optimal_temp = 300
	overheat_temp = 500
	optimal_ph_min = 7
	optimal_ph_max = 9
	determin_ph_range = 3
	temp_exponent_factor = 0.1
	ph_exponent_factor = 0.8
	thermic_constant = -0.25
	H_ion_release = -0.02
	rate_up_lim = 15
	purity_min = 0.32

/datum/chemical_reaction/medicine/ephedrine/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	default_explode(holder, equilibrium.reacted_vol, 0, 25)

/datum/chemical_reaction/medicine/ephedrine/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	default_explode(holder, equilibrium.reacted_vol, 0, 20)

/datum/chemical_reaction/medicine/diphenhydramine
	results = list(/datum/reagent/medicine/diphenhydramine = 4)
	required_reagents = list(/datum/reagent/fuel/oil = 1, /datum/reagent/carbon = 1, /datum/reagent/bromine = 1, /datum/reagent/diethylamine = 1, /datum/reagent/consumable/ethanol = 1)
	mix_message = "The mixture dries into a pale blue powder."
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/atropine
	results = list(/datum/reagent/medicine/atropine = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/acetone = 1, /datum/reagent/diethylamine = 1, /datum/reagent/phenol = 1, /datum/reagent/toxin/acid = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/medicine/epinephrine
	results = list(/datum/reagent/medicine/epinephrine = 6)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/acetone = 1, /datum/reagent/diethylamine = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1, /datum/reagent/hydrogen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/strange_reagent
	results = list(/datum/reagent/medicine/strange_reagent = 3)
	required_reagents = list(/datum/reagent/medicine/omnizine = 1, /datum/reagent/water/holywater = 1, /datum/reagent/toxin/mutagen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/strange_reagent/alt
	results = list(/datum/reagent/medicine/strange_reagent = 2)
	required_reagents = list(/datum/reagent/medicine/omnizine/protozine = 1, /datum/reagent/water/holywater = 1, /datum/reagent/toxin/mutagen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_PLANT | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/fishy_reagent
	results = list(/datum/reagent/medicine/strange_reagent/fishy_reagent = 3)
	required_reagents = list(/datum/reagent/medicine/omnizine = 1, /datum/reagent/water/salt = 1, /datum/reagent/toxin/carpotoxin = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/fishy_reagent/alt
	results = list(/datum/reagent/medicine/strange_reagent/fishy_reagent = 6)
	required_reagents = list(/datum/reagent/medicine/omnizine = 1, /datum/reagent/water/salt = 1, /datum/reagent/toxin/tetrodotoxin = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/mannitol
	results = list(/datum/reagent/medicine/mannitol = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/hydrogen = 1, /datum/reagent/water = 1)
	mix_message = "The solution slightly bubbles, becoming thicker."
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN
	//FermiChem vars:
	required_temp = 50
	optimal_temp = 300
	overheat_temp = 650
	optimal_ph_min = 5
	optimal_ph_max = 7.5
	determin_ph_range = 3
	temp_exponent_factor = 1
	ph_exponent_factor = 1
	thermic_constant = 100
	H_ion_release = 0
	rate_up_lim = 10
	purity_min = 0.4

/datum/chemical_reaction/medicine/mannitol/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	if(off_cooldown(holder, equilibrium, 10, "mannitol"))
		explode_attack_chem(holder, equilibrium, /datum/reagent/impurity/mannitol, 5)
		explode_invert_smoke(holder, equilibrium)

/datum/chemical_reaction/medicine/mannitol/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	overheated(holder, equilibrium, vol_added)

/datum/chemical_reaction/medicine/neurine
	results = list(/datum/reagent/medicine/neurine = 3)
	required_reagents = list(/datum/reagent/medicine/mannitol = 1, /datum/reagent/acetone = 1, /datum/reagent/oxygen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN
	//FermiChem vars:
	required_temp = 100
	optimal_temp = 500
	overheat_temp = 700
	optimal_ph_min = 6.8
	optimal_ph_max = 10
	determin_ph_range = 8
	temp_exponent_factor = 0.8
	ph_exponent_factor = 2
	thermic_constant = 87
	H_ion_release = -0.05
	rate_up_lim = 15
	purity_min = 0.4

/datum/chemical_reaction/medicine/neurine/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	if(off_cooldown(holder, equilibrium, 10, "neurine"))
		explode_invert_smoke(holder, equilibrium, clear_products = FALSE, clear_reactants = FALSE)
		explode_attack_chem(holder, equilibrium, /datum/reagent/inverse/neurine, 10)
		clear_products(holder, 5)

/datum/chemical_reaction/medicine/neurine/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	overheated(holder, equilibrium, vol_added)

/datum/chemical_reaction/medicine/mutadone
	results = list(/datum/reagent/medicine/mutadone = 3)
	required_reagents = list(/datum/reagent/toxin/mutagen = 1, /datum/reagent/acetone = 1, /datum/reagent/bromine = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/antihol
	results = list(/datum/reagent/medicine/antihol = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/medicine/c2/multiver = 1, /datum/reagent/copper = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER
	//FermiChem vars:
	required_temp = 1
	optimal_temp = 300
	overheat_temp = 550
	optimal_ph_min = 3.5
	optimal_ph_max = 8.5
	determin_ph_range = 5
	temp_exponent_factor = 2
	ph_exponent_factor = 2
	thermic_constant = -100
	H_ion_release = 0.09
	rate_up_lim = 25
	purity_min = 0.15
	reaction_flags = REACTION_CLEAR_INVERSE

/datum/chemical_reaction/medicine/antihol/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	explode_smoke(holder, equilibrium)

/datum/chemical_reaction/medicine/antihol/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	explode_smoke(holder, equilibrium)


/datum/chemical_reaction/medicine/cryoxadone
	results = list(/datum/reagent/medicine/cryoxadone = 3)
	required_reagents = list(/datum/reagent/stable_plasma = 1, /datum/reagent/acetone = 1, /datum/reagent/toxin/mutagen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_PLANT | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/medicine/pyroxadone
	results = list(/datum/reagent/medicine/pyroxadone = 2)
	required_reagents = list(/datum/reagent/medicine/cryoxadone = 1, /datum/reagent/toxin/slimejelly = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/medicine/haloperidol
	results = list(/datum/reagent/medicine/haloperidol = 5)
	required_reagents = list(/datum/reagent/chlorine = 1, /datum/reagent/fluorine = 1, /datum/reagent/aluminium = 1, /datum/reagent/medicine/potass_iodide = 1, /datum/reagent/fuel/oil = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/regen_jelly
	results = list(/datum/reagent/medicine/regen_jelly = 2)
	required_reagents = list(/datum/reagent/medicine/omnizine = 1, /datum/reagent/toxin/slimejelly = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/medicine/higadrite
	results = list(/datum/reagent/medicine/higadrite = 3)
	required_reagents = list(/datum/reagent/phenol = 2, /datum/reagent/lithium = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/medicine/morphine
	results = list(/datum/reagent/medicine/morphine = 2)
	required_reagents = list(/datum/reagent/carbon = 2, /datum/reagent/hydrogen = 2, /datum/reagent/consumable/ethanol = 1, /datum/reagent/oxygen = 1)
	required_temp = 480
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

/datum/chemical_reaction/medicine/modafinil
	results = list(/datum/reagent/medicine/modafinil = 5)
	required_reagents = list(/datum/reagent/diethylamine = 1, /datum/reagent/ammonia = 1, /datum/reagent/phenol = 1, /datum/reagent/acetone = 1, /datum/reagent/toxin/acid = 1)
	required_catalysts = list(/datum/reagent/bromine = 1) // as close to the real world synthesis as possible
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/psicodine
	results = list(/datum/reagent/medicine/psicodine = 5)
	required_reagents = list( /datum/reagent/medicine/mannitol = 2, /datum/reagent/water = 2, /datum/reagent/impedrezene = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/granibitaluri
	results = list(/datum/reagent/medicine/granibitaluri = 3)
	required_reagents = list(/datum/reagent/consumable/salt = 1, /datum/reagent/carbon = 1, /datum/reagent/toxin/acid = 1)
	required_catalysts = list(/datum/reagent/iron = 5)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN

///medical stacks

/datum/chemical_reaction/medicine/medsuture
	required_reagents = list(/datum/reagent/cellulose = 2, /datum/reagent/toxin/formaldehyde = 4, /datum/reagent/medicine/polypyr = 3) //This might be a bit much, reagent cost should be reviewed after implementation.
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE

/datum/chemical_reaction/medicine/medsuture/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/stack/medical/suture/medicated(get_turf(holder.my_atom), round(created_volume * 4))

/datum/chemical_reaction/medicine/medmesh
	required_reagents = list(/datum/reagent/cellulose = 2, /datum/reagent/consumable/aloejuice = 4, /datum/reagent/space_cleaner/sterilizine = 2)
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BURN

/datum/chemical_reaction/medicine/medmesh/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/stack/medical/mesh/advanced(get_turf(holder.my_atom), round(created_volume * 3))

/datum/chemical_reaction/medicine/poultice
	required_reagents = list(/datum/reagent/toxin/bungotoxin = 4, /datum/reagent/cellulose = 4, /datum/reagent/consumable/aloejuice = 4	)
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN

/datum/chemical_reaction/medicine/poultice/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	new /obj/item/stack/medical/poultice(get_turf(holder.my_atom), round(created_volume * 3))

/datum/chemical_reaction/medicine/seraka_destroy //seraka extract is destroyed by sodium hydroxide
	results = list(/datum/reagent/consumable/sugar = 1)
	required_reagents = list(/datum/reagent/medicine/coagulant/seraka_extract = 1, /datum/reagent/lye = 1)
	reaction_tags = REACTION_TAG_EASY

/datum/chemical_reaction/medicine/ondansetron
	results = list(/datum/reagent/medicine/ondansetron = 3)
	required_reagents = list(/datum/reagent/fuel/oil = 1, /datum/reagent/nitrogen = 1, /datum/reagent/oxygen = 1)
	required_catalysts = list(/datum/reagent/consumable/ethanol = 3)
	optimal_ph_max = 11
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

/datum/chemical_reaction/medicine/naloxone
	results = list(/datum/reagent/medicine/naloxone = 4)
	required_reagents = list(/datum/reagent/medicine/morphine = 1, /datum/reagent/hydrogen_peroxide = 1, /datum/reagent/bromine = 1, /datum/reagent/consumable/ethanol = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER
