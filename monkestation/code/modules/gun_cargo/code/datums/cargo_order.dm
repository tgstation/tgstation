/datum/supply_order/armament
	/// The armament entry used to fill the supply order
	var/datum/armament_entry/cargo_gun/selected_entry
	/// The component used to create the order
	var/datum/component/armament/cargo_gun/used_component
	/// How much it'll add to a company's interest on-buy
	var/interest_addition

/datum/supply_order/armament/Destroy(force, ...)
	selected_entry = null
	used_component = null
	. = ..()

/datum/supply_order/armament/proc/reimburse_armament()
	if(!selected_entry || !used_component)
		return
	used_component.purchased_items[selected_entry]--
	selected_entry.stock++

/// A proc to be overriden if you want custom code to happen when SSshuttle spawns the order
/datum/supply_order/proc/on_spawn()
	return

/datum/supply_order/armament/on_spawn()
	for(var/company in SSgun_companies.companies)
		var/datum/gun_company/comp_datum = SSgun_companies.companies[company]
		if(comp_datum.company_flag == selected_entry?.company_bitflag)
			comp_datum.interest += interest_addition
			break
