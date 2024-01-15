/datum/armament_entry/cargo_gun
	max_purchase = 10
	category_item_limit = 10
	cost = 1
	/// Bitflag of the company
	var/company_bitflag
	/// How much stock of this item is left
	var/stock = 10
	/// Lower bound of random pricing
	var/lower_cost = 100
	/// Upper bound of random pricing
	var/upper_cost = 200
	/// How much the stock is multiplied by
	var/stock_mult = 1
	/// How much will be added to a company's reputation on-buy
	var/interest_addition = COMPANY_INTEREST_GUN
	/// What interest level is needed to purchase the armament, set to 0 for none
	var/interest_required = 0
	/// If this requires a multitooled console to be visible
	var/contraband = FALSE
