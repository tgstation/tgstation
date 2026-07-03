/datum/customer_data/american/New()
	orderable_objects[VENUE_BAR] |= list(
		/datum/reagent/consumable/ethanol/soundhand = 5,
		/datum/reagent/consumable/ethanol/silverhand = 6,
	)
	. = ..()

/datum/customer_data/british/gent/New()
	orderable_objects[VENUE_BAR] |= list(
		/datum/reagent/consumable/ethanol/pegu_club = 5,
	)
	. = ..()

/datum/customer_data/british/New()
	orderable_objects[VENUE_BAR] |= list(
		/datum/reagent/consumable/ethanol/brandy_crusta = 6,
	)
	. = ..()

/datum/customer_data/french/New()
	orderable_objects[VENUE_BAR] |= list(
		/datum/reagent/consumable/ethanol/vampiro = 4,
	)
	. = ..()

/datum/customer_data/japanese/New()
	orderable_objects[VENUE_BAR] |= list(
		/datum/reagent/consumable/ethanol/rainbow_sky = 2,
		/datum/reagent/consumable/ethanol/innocent_erp = 4,
	)
	. = ..()

/datum/customer_data/mexican/New()
	orderable_objects[VENUE_BAR] |= list(
		/datum/reagent/consumable/ethanol/black_blood = 5,
	)
	. = ..()

