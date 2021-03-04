
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
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_CLONE

/datum/chemical_reaction/medicine/spaceacillin
	results = list(/datum/reagent/medicine/spaceacillin = 2)
	required_reagents = list(/datum/reagent/cryptobiolin = 1, /datum/reagent/medicine/epinephrine = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/oculine
	results = list(/datum/reagent/medicine/oculine = 3)
	required_reagents = list(/datum/reagent/medicine/c2/multiver = 1, /datum/reagent/carbon = 1, /datum/reagent/hydrogen = 1)
	mix_message = "The mixture bubbles noticeably and becomes a dark grey color!"
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/medicine/inacusiate
	results = list(/datum/reagent/medicine/inacusiate = 2)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/carbon = 1, /datum/reagent/medicine/c2/multiver = 1)
	mix_message = "The mixture sputters loudly and becomes a light grey color!"
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/medicine/synaptizine
	results = list(/datum/reagent/medicine/synaptizine = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/lithium = 1, /datum/reagent/water = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/salglu_solution
	results = list(/datum/reagent/medicine/salglu_solution = 3)
	required_reagents = list(/datum/reagent/consumable/salt = 1, /datum/reagent/water = 1, /datum/reagent/consumable/sugar = 1)
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

/datum/chemical_reaction/medicine/potass_iodide
	results = list(/datum/reagent/medicine/potass_iodide = 2)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/iodine = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/pen_acid
	results = list(/datum/reagent/medicine/pen_acid = 6)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/chlorine = 1, /datum/reagent/ammonia = 1, /datum/reagent/toxin/formaldehyde = 1, /datum/reagent/sodium = 1, /datum/reagent/toxin/cyanide = 1)
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

/datum/chemical_reaction/medicine/ephedrine
	results = list(/datum/reagent/medicine/ephedrine = 4)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/fuel/oil = 1, /datum/reagent/hydrogen = 1, /datum/reagent/diethylamine = 1)
	mix_message = "The solution fizzes and gives off toxic fumes."
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

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

/datum/chemical_reaction/medicine/mannitol
	results = list(/datum/reagent/medicine/mannitol = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/hydrogen = 1, /datum/reagent/water = 1)
	mix_message = "The solution slightly bubbles, becoming thicker."
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/medicine/neurine
	results = list(/datum/reagent/medicine/neurine = 3)
	required_reagents = list(/datum/reagent/medicine/mannitol = 1, /datum/reagent/acetone = 1, /datum/reagent/oxygen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/medicine/mutadone
	results = list(/datum/reagent/medicine/mutadone = 3)
	required_reagents = list(/datum/reagent/toxin/mutagen = 1, /datum/reagent/acetone = 1, /datum/reagent/bromine = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/antihol
	results = list(/datum/reagent/medicine/antihol = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/medicine/c2/multiver = 1, /datum/reagent/copper = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/medicine/cryoxadone
	results = list(/datum/reagent/medicine/cryoxadone = 3)
	required_reagents = list(/datum/reagent/stable_plasma = 1, /datum/reagent/acetone = 1, /datum/reagent/toxin/mutagen = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_PLANT | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY | REACTION_TAG_CLONE

/datum/chemical_reaction/medicine/pyroxadone
	results = list(/datum/reagent/medicine/pyroxadone = 2)
	required_reagents = list(/datum/reagent/medicine/cryoxadone = 1, /datum/reagent/toxin/slimejelly = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY | REACTION_TAG_CLONE

/datum/chemical_reaction/medicine/clonexadone
	results = list(/datum/reagent/medicine/clonexadone = 2)
	required_reagents = list(/datum/reagent/medicine/cryoxadone = 1, /datum/reagent/sodium = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_CLONE

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
	required_reagents = list(/datum/reagent/cellulose = 10, /datum/reagent/toxin/formaldehyde = 20, /datum/reagent/medicine/polypyr = 15) //This might be a bit much, reagent cost should be reviewed after implementation.
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE

/datum/chemical_reaction/medicine/medsuture/on_reaction(datum/equilibrium/reaction, datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/medical/suture/medicated(location)

/datum/chemical_reaction/medicine/medmesh
	required_reagents = list(/datum/reagent/cellulose = 20, /datum/reagent/consumable/aloejuice = 20, /datum/reagent/space_cleaner/sterilizine = 10)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BURN

/datum/chemical_reaction/medicine/medmesh/on_reaction(datum/equilibrium/reaction, datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/stack/medical/mesh/advanced(location)

/datum/chemical_reaction/medicine/poultice
	required_reagents = list(/datum/reagent/toxin/bungotoxin = 20, /datum/reagent/cellulose = 20, /datum/reagent/consumable/aloejuice = 20)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN

/datum/chemical_reaction/medicine/poultice/on_reaction(datum/equilibrium/reaction, datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/medical/poultice(location)
