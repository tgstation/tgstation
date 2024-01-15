#define MAX_HANDOUT_CHOICES 3
#define FAILED_INTEREST 1
#define PASSED_INTEREST 2
#define HIGH_INTEREST 3
#define INTEREST_HIGH_MULT 10
#define INTEREST_CAP 75
#define INTEREST_LOWER_RAND 5
#define INTEREST_HIGHER_RAND 25
#define BASE_COST_MINIMUM 1000
#define BASE_COST_MAXIMUM 75000
#define INTEREST_LOW_MAG_COST 0.1
#define INTEREST_MED_MAG_COST 0.11
#define INTEREST_HIGH_MAG_COST 0.125

SUBSYSTEM_DEF(gun_companies)
	name = "Gun Companies"
	wait = 20 MINUTES
	runlevels = RUNLEVEL_GAME
	/// Assoc list of companies that the subsystem has initialized, `"NAME" = datum_reference`
	var/list/companies = list()
	/// Assoc list of unpurchased companies
	var/list/unpurchased_companies = list()
	/// Assoc list of purchased companies
	var/list/purchased_companies = list()
	/// List of chosen handout company datums, for the user to pick 1
	var/list/chosen_handouts = list()
	/// Picked a free company yet?
	var/handout_picked = FALSE

/datum/controller/subsystem/gun_companies/Initialize(start_timeofday)
	// Adds the company refs to the unchanging companies list and the changing unpurchased_companies list
	for(var/datum/gun_company/company as anything in subtypesof(/datum/gun_company))
		var/datum/gun_company/new_company = new company
		companies[new_company.name] = new_company
		unpurchased_companies[new_company.name] = new_company

	// Cargo gets to pick one company from several for free
	var/list/potential_handouts = list()
	for(var/company_name in unpurchased_companies)
		var/datum/gun_company/picked_company = unpurchased_companies[company_name]
		if(!picked_company.can_roundstart_pick)
			continue
		potential_handouts += picked_company
	for(var/i in 1 to MAX_HANDOUT_CHOICES)
		chosen_handouts += pick_n_take(potential_handouts)
	fire() //Gotta get the prices randomized to start
	return ..()

/datum/controller/subsystem/gun_companies/Destroy()
	for(var/company in companies)
		QDEL_NULL(company)
	for(var/company_unbought in unpurchased_companies)
		QDEL_NULL(unpurchased_companies)
	for(var/company_bought in purchased_companies)
		QDEL_NULL(purchased_companies)
	. = ..()

/datum/controller/subsystem/gun_companies/Recover()
	companies = SSgun_companies.companies
	unpurchased_companies = SSgun_companies.unpurchased_companies
	purchased_companies = SSgun_companies.purchased_companies

/datum/controller/subsystem/gun_companies/fire(resumed)
	var/list/passed_interest_tier = list()
	// Company handling
	for(var/company in companies)
		var/datum/gun_company/company_datum = companies[company]

		// Set the prices of the companies, is intended to slowly scale up over time
		company_datum.base_cost += max(rand(company_datum.cost_change_lower, company_datum.cost_change_upper), 0)
		company_datum.base_cost = clamp(company_datum.base_cost, BASE_COST_MINIMUM, BASE_COST_MAXIMUM)
		company_datum.base_cost = company_datum.base_cost <= BASE_COST_MINIMUM ? BASE_COST_MINIMUM : company_datum.base_cost
		company_datum.cost = round(company_datum.base_cost * company_datum.cost_mult)
		// knocking down the interest of all companies
		var/interest_threshold = rand(INTEREST_LOWER_RAND, INTEREST_HIGHER_RAND)
		var/interest_knockdown = 0.5 * interest_threshold

		if(company_datum in unpurchased_companies)
			interest_knockdown *= 0.5

		company_datum.interest = max(company_datum.interest - interest_knockdown, 0)

		// determining what heirarchy of interest the company falls in
		if(company_datum.interest < interest_threshold)
			passed_interest_tier[company_datum] = FAILED_INTEREST

		else
			var/non_zero_threshold = interest_threshold ? interest_threshold : 1
			var/calc_threshold = non_zero_threshold * INTEREST_HIGH_MULT
			if(calc_threshold > INTEREST_CAP)
				calc_threshold = INTEREST_CAP
			if(company_datum.interest < calc_threshold)
				passed_interest_tier[company_datum] = PASSED_INTEREST

			else
				passed_interest_tier[company_datum] = HIGH_INTEREST


	var/list/products = subtypesof(/datum/armament_entry/cargo_gun)
	// Setting cost and stock of armament entries
	for(var/armament_category as anything in GLOB.armament_entries)
		for(var/subcategory as anything in GLOB.armament_entries[armament_category][CATEGORY_ENTRY])
			for(var/datum/armament_entry/armament_entry as anything in GLOB.armament_entries[armament_category][CATEGORY_ENTRY][subcategory])
				if(products && !(armament_entry.type in products))
					continue

				var/datum/armament_entry/cargo_gun/entry_typecast = armament_entry

				for(var/company_gun in companies)
					var/datum/gun_company/the_datum = companies[company_gun]

					if(the_datum.company_flag != entry_typecast.company_bitflag)
						continue

					switch(passed_interest_tier[the_datum])

						if(FAILED_INTEREST)
							var/stock_failed = rand(0, 2)
							entry_typecast.stock = max((round(stock_failed * entry_typecast.stock_mult)), 0)
							var/gun_cost_failed = rand(entry_typecast.lower_cost, entry_typecast.upper_cost)
							var/compound_cost = round(entry_typecast.cost * 0.1)
							entry_typecast.cost = max((round((gun_cost_failed + (compound_cost + CARGO_CRATE_VALUE)) - (0.25 * entry_typecast.lower_cost)) ), 0)
							entry_typecast.magazine_cost = round((entry_typecast.cost * INTEREST_LOW_MAG_COST) * the_datum.magazine_cost_mult)

						if(PASSED_INTEREST)
							var/stock_passed = rand(0, 4)
							entry_typecast.stock = max((round(stock_passed * entry_typecast.stock_mult) + 1), 0)
							var/gun_cost_passed = rand(entry_typecast.lower_cost, entry_typecast.upper_cost)
							var/compound_cost = round(entry_typecast.cost * 0.1)
							entry_typecast.cost = max((round(gun_cost_passed + compound_cost) + CARGO_CRATE_VALUE), 0)
							entry_typecast.magazine_cost = round((entry_typecast.cost * INTEREST_MED_MAG_COST) * the_datum.magazine_cost_mult)

						if(HIGH_INTEREST)
							var/stock_interested = rand(0, 6)
							entry_typecast.stock = max((round(stock_interested * entry_typecast.stock_mult) + 2), 0)
							var/gun_cost_high = rand(entry_typecast.lower_cost, entry_typecast.upper_cost)
							var/compound_cost = round(entry_typecast.cost * 0.1)
							entry_typecast.cost = max(round(gun_cost_high + (compound_cost + CARGO_CRATE_VALUE)) , 0)
							entry_typecast.magazine_cost = round((entry_typecast.cost * INTEREST_HIGH_MAG_COST) * the_datum.magazine_cost_mult)

#undef MAX_HANDOUT_CHOICES
#undef INTEREST_HIGH_MULT
#undef INTEREST_CAP
#undef INTEREST_LOWER_RAND
#undef INTEREST_HIGHER_RAND
#undef BASE_COST_MINIMUM
#undef BASE_COST_MAXIMUM
#undef INTEREST_LOW_MAG_COST
#undef INTEREST_MED_MAG_COST
#undef INTEREST_HIGH_MAG_COST
