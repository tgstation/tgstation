/datum/bounty/reagent
	var/required_volume = 10
	var/shipped_volume = 0
	var/datum/reagent/wanted_reagent

/datum/bounty/reagent/can_claim()
	return ..() && shipped_volume >= required_volume

/datum/bounty/reagent/applies_to(obj/shipped)
	if(!is_reagent_container(shipped))
		return FALSE
	if(!shipped.reagents || !shipped.reagents.has_reagent(wanted_reagent.type))
		return FALSE
	if(shipped.flags_1 & HOLOGRAM_1)
		return FALSE
	return shipped_volume < required_volume

/datum/bounty/reagent/ship(obj/shipped)
	if(!applies_to(shipped))
		return FALSE
	shipped_volume += shipped.reagents.get_reagent_amount(wanted_reagent.type)
	if(shipped_volume > required_volume)
		shipped_volume = required_volume
	return TRUE

/datum/bounty/reagent/simple_drink
	name = "Simple Drink"
	reward = CARGO_CRATE_VALUE * 3

/datum/bounty/reagent/simple_drink/New()
	// Don't worry about making this comprehensive. It doesn't matter if some drinks are skipped.
	var/static/list/possible_reagents = list(\
		/datum/reagent/consumable/ethanol/antifreeze,\
		/datum/reagent/consumable/ethanol/andalusia,\
		/datum/reagent/consumable/tea/arnold_palmer,\
		/datum/reagent/consumable/ethanol/b52,\
		/datum/reagent/consumable/ethanol/bananahonk,\
		/datum/reagent/consumable/ethanol/beepsky_smash,\
		/datum/reagent/consumable/ethanol/between_the_sheets,\
		/datum/reagent/consumable/ethanol/bilk,\
		/datum/reagent/consumable/ethanol/black_russian,\
		/datum/reagent/consumable/ethanol/bloody_mary,\
		/datum/reagent/consumable/ethanol/brave_bull,\
		/datum/reagent/consumable/ethanol/martini,\
		/datum/reagent/consumable/ethanol/cuba_libre,\
		/datum/reagent/consumable/ethanol/eggnog,\
		/datum/reagent/consumable/ethanol/erikasurprise,\
		/datum/reagent/consumable/ethanol/ginfizz,\
		/datum/reagent/consumable/ethanol/gintonic,\
		/datum/reagent/consumable/ethanol/grappa,\
		/datum/reagent/consumable/ethanol/grog,\
		/datum/reagent/consumable/ethanol/hooch,\
		/datum/reagent/consumable/ethanol/iced_beer,\
		/datum/reagent/consumable/ethanol/irishcarbomb,\
		/datum/reagent/consumable/ethanol/manhattan,\
		/datum/reagent/consumable/ethanol/margarita,\
		/datum/reagent/consumable/ethanol/gargle_blaster,\
		/datum/reagent/consumable/ethanol/rum_coke,\
		/datum/reagent/consumable/ethanol/screwdrivercocktail,\
		/datum/reagent/consumable/ethanol/snowwhite,\
		/datum/reagent/consumable/soy_latte,\
		/datum/reagent/consumable/cafe_latte,\
		/datum/reagent/consumable/ethanol/syndicatebomb,\
		/datum/reagent/consumable/ethanol/tequila_sunrise,\
		/datum/reagent/consumable/ethanol/manly_dorf,\
		/datum/reagent/consumable/ethanol/thirteenloko,\
		/datum/reagent/consumable/triple_citrus,\
		/datum/reagent/consumable/ethanol/vodkamartini,\
		/datum/reagent/consumable/ethanol/whiskeysoda,\
		/datum/reagent/consumable/ethanol/beer/green,\
		/datum/reagent/consumable/ethanol/demonsblood,\
		/datum/reagent/consumable/ethanol/crevice_spike,\
		/datum/reagent/consumable/ethanol/singulo,\
		/datum/reagent/consumable/ethanol/whiskey_sour,\
		/datum/reagent/consumable/ethanol/boston_sour,\
		/datum/reagent/consumable/ethanol/old_fashioned,\
		/datum/reagent/consumable/ethanol/sazerac,\
		/datum/reagent/consumable/ethanol/hot_toddy,\
		/datum/reagent/consumable/ethanol/daiquiri,\
		/datum/reagent/consumable/ethanol/blue_blazer,\
		/datum/reagent/consumable/ethanol/flip_cocktail,\
		/datum/reagent/consumable/ethanol/bitters_soda,\
		/datum/chemical_reaction/drink/star)

	var/reagent_type = pick(possible_reagents)
	wanted_reagent = new reagent_type
	name = wanted_reagent.name
	description = "CentCom is thirsty! Send a shipment of [name] to CentCom to quench the company's thirst."
	reward += rand(0, 2) * 500

/datum/bounty/reagent/complex_drink
	name = "Complex Drink"
	reward = CARGO_CRATE_VALUE * 8

/datum/bounty/reagent/complex_drink/New()
	// Don't worry about making this comprehensive. It doesn't matter if some drinks are skipped.
	var/static/list/possible_reagents = list(\
		/datum/reagent/consumable/ethanol/atomicbomb,\
		/datum/reagent/consumable/ethanol/bacchus_blessing,\
		/datum/reagent/consumable/ethanol/bastion_bourbon,\
		/datum/reagent/consumable/ethanol/booger,\
		/datum/reagent/consumable/ethanol/hippies_delight,\
		/datum/reagent/consumable/ethanol/drunkenblumpkin,\
		/datum/reagent/consumable/ethanol/fetching_fizz,\
		/datum/reagent/consumable/ethanol/goldschlager,\
		/datum/reagent/consumable/ethanol/manhattan_proj,\
		/datum/reagent/consumable/ethanol/narsour,\
		/datum/reagent/consumable/ethanol/neurotoxin,\
		/datum/reagent/consumable/ethanol/patron,\
		/datum/reagent/consumable/ethanol/quadruple_sec,\
		/datum/reagent/consumable/bluecherryshake,\
		/datum/reagent/consumable/doctor_delight,\
		/datum/reagent/consumable/ethanol/silencer,\
		/datum/reagent/consumable/ethanol/peppermint_patty,\
		/datum/reagent/consumable/ethanol/aloe,\
		/datum/reagent/consumable/pumpkin_latte,\
		/datum/reagent/consumable/ethanol/ramos_gin_fizz,\
		/datum/reagent/consumable/ethanol/sangria,\
		/datum/reagent/consumable/ethanol/tizirian_sour,\
		/datum/chemical_reaction/drink/suffering_bastard)

	var/reagent_type = pick(possible_reagents)
	wanted_reagent = new reagent_type
	name = wanted_reagent.name
	description = "CentCom is offering a reward for talented mixologists. Ship a container of [name] to claim the prize."
	reward += rand(0, 4) * 500

/datum/bounty/reagent/chemical_simple
	name = "Simple Chemical"
	reward = CARGO_CRATE_VALUE * 8
	required_volume = 30

/datum/bounty/reagent/chemical_simple/New()
	// Chemicals that can be mixed by a single skilled Chemist.
	var/static/list/possible_reagents = list(\
		/datum/reagent/medicine/leporazine,\
		/datum/reagent/medicine/mine_salve,\
		/datum/reagent/medicine/c2/convermol,\
		/datum/reagent/medicine/ephedrine,\
		/datum/reagent/medicine/diphenhydramine,\
		/datum/reagent/drug/space_drugs,\
		/datum/reagent/drug/blastoff,\
		/datum/reagent/gunpowder,\
		/datum/reagent/napalm,\
		/datum/reagent/firefighting_foam,\
		/datum/reagent/consumable/mayonnaise,\
		/datum/reagent/toxin/itching_powder,\
		/datum/reagent/toxin/cyanide,\
		/datum/reagent/toxin/heparin,\
		/datum/reagent/medicine/pen_acid,\
		/datum/reagent/medicine/atropine,\
		/datum/reagent/drug/aranesp,\
		/datum/reagent/drug/krokodil,\
		/datum/reagent/drug/methamphetamine,\
		/datum/reagent/teslium,\
		/datum/reagent/toxin/anacea,\
		/datum/reagent/pax)

	var/reagent_type = pick(possible_reagents)
	wanted_reagent = new reagent_type
	name = wanted_reagent.name
	description = "CentCom is in desperate need of the chemical [name]. Ship a container of it to be rewarded."
	reward += rand(0, 4) * 500 //4000 to 6000 credits

/datum/bounty/reagent/chemical_complex
	name = "Rare Chemical"
	reward = CARGO_CRATE_VALUE * 12
	required_volume = 20

/datum/bounty/reagent/chemical_complex/New()
	// Reagents that require interaction with multiple departments or are a pain to mix. Lower required_volume since acquiring 30u of some is unrealistic
	var/static/list/possible_reagents = list(\
		/datum/reagent/medicine/pyroxadone,\
		/datum/reagent/medicine/rezadone,\
		/datum/reagent/medicine/regen_jelly,\
		/datum/reagent/drug/bath_salts,\
		/datum/reagent/hair_dye,\
		/datum/reagent/consumable/honey,\
		/datum/reagent/consumable/frostoil,\
		/datum/reagent/toxin/slimejelly,\
		/datum/reagent/teslium/energized_jelly,\
		/datum/reagent/toxin/mimesbane,\
		/datum/reagent/medicine/strange_reagent,\
		/datum/reagent/nitroglycerin,\
		/datum/reagent/medicine/rezadone,\
		/datum/reagent/toxin/zombiepowder,\
		/datum/reagent/toxin/ghoulpowder,\
		/datum/reagent/mulligan)

	var/reagent_type = pick(possible_reagents)
	wanted_reagent = new reagent_type
	name = wanted_reagent.name
	description = "CentCom is paying premium for the chemical [name]. Ship a container of it to be rewarded."
	reward += rand(0, 5) * 750 //6000 to 9750 credits

/datum/bounty/pill
	/// quantity of the pills needed, this value acts as minimum, gets randomized on new()
	var/required_ammount = 80
	/// counter for pills sent
	var/shipped_ammount = 0
	/// reagent requested
	var/datum/reagent/wanted_reagent
	/// minimum volume of chemical needed, gets randomized on new()
	var/wanted_vol = 30

/datum/bounty/pill/can_claim()
	return ..() && shipped_ammount >= required_ammount

/datum/bounty/pill/applies_to(obj/shipped)
	if(!istype(shipped, /obj/item/reagent_containers/applicator/pill))
		return FALSE
	if(shipped?.reagents.get_reagent_amount(wanted_reagent.type) >= wanted_vol)
		return TRUE
	return FALSE

/datum/bounty/pill/ship(obj/shipped)
	if(!applies_to(shipped))
		return FALSE
	shipped_ammount += 1
	if(shipped_ammount > required_ammount)
		shipped_ammount = required_ammount
	return TRUE

/datum/bounty/pill/simple_pill
	name = "Simple Pill"
	reward = CARGO_CRATE_VALUE * 20

/datum/bounty/pill/simple_pill/New()
	//reagent that are possible to be chem factory'd
	var/static/list/possible_reagents = list(\
		/datum/reagent/medicine/spaceacillin,\
		/datum/reagent/medicine/c2/synthflesh,\
		/datum/reagent/medicine/pen_acid,\
		/datum/reagent/medicine/atropine,\
		/datum/reagent/medicine/cryoxadone,\
		/datum/reagent/medicine/salbutamol,\
		/datum/reagent/medicine/c2/hercuri,\
		/datum/reagent/medicine/c2/probital,\
		/datum/reagent/drug/methamphetamine,\
		/datum/reagent/nitrous_oxide,\
		/datum/reagent/barbers_aid,\
		/datum/reagent/pax,\
		/datum/reagent/flash_powder,\
		/datum/reagent/phlogiston,\
		/datum/reagent/firefighting_foam)

	var/datum/reagent/reagent_type = pick(possible_reagents)
	wanted_reagent = new reagent_type
	name = "[wanted_reagent.name] pills"
	required_ammount += rand(1,60)
	wanted_vol += rand(1,20)
	description = "CentCom requires [required_ammount] of [name] containing at least [wanted_vol] each. Ship a container of it to be rewarded."
	reward += rand(1, 5) * (CARGO_CRATE_VALUE * 6)
