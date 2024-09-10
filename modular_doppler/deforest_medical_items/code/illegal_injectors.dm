// Twitch, because having sandevistans be implants is for losers, just inject it!
/obj/item/reagent_containers/hypospray/medipen/deforest/twitch
	name = "TWitch sensory stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with 'TWitch' among other reagents. This drug is known to make \
		those who take it 'see faster', whatever that means."
	base_icon_state = "twitch"
	icon_state = "twitch"
	list_reagents = list(
		/datum/reagent/drug/twitch = 10,
		/datum/reagent/drug/maint/tar = 5,
		/datum/reagent/medicine/silibinin = 5,
		/datum/reagent/toxin/leadacetate = 5,
	)
	custom_price = PAYCHECK_COMMAND * 3.5

// Demoneye, for when you feel the need to become "fucking invincible"
/obj/item/reagent_containers/hypospray/medipen/deforest/demoneye
	name = "DemonEye steroid injector"
	desc = "A Deforest branded autoinjector, loaded with 'DemonEye' among other reagents. This drug is known to make \
		those who take it numb to all pains and extremely difficult to kill as a result."
	base_icon_state = "demoneye"
	icon_state = "demoneye"
	list_reagents = list(
		/datum/reagent/drug/demoneye = 10,
		/datum/reagent/drug/maint/sludge = 10,
		/datum/reagent/toxin/leadacetate = 5,
	)
	custom_price = PAYCHECK_COMMAND * 3.5

// Mix of many of the stamina damage regenerating drugs to provide a cocktail no baton could hope to beat
/obj/item/reagent_containers/hypospray/medipen/deforest/aranepaine
	name = "aranepaine combat stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a cocktail of drugs to make any who take it nearly \
		immune to exhaustion while its in their system."
	base_icon_state = "aranepaine"
	icon_state = "aranepaine"
	list_reagents = list(
		/datum/reagent/drug/aranesp = 5,
		/datum/reagent/drug/kronkaine = 5,
		/datum/reagent/drug/pumpup = 5,
		/datum/reagent/medicine/diphenhydramine = 5,
		/datum/reagent/impurity = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5

// Nothing inherently illegal, just a potentially very dangerous mix of chems to be able to inject into people
/obj/item/reagent_containers/hypospray/medipen/deforest/pentibinin
	name = "pentibinin normalizant injector"
	desc = "A Deforest branded autoinjector, loaded with a cocktail of drugs to make any who take it \
		recover from many different types of damages, with many unusual or undocumented side-effects."
	base_icon_state = "pentibinin"
	icon_state = "pentibinin"
	list_reagents = list(
		/datum/reagent/medicine/c2/penthrite = 5,
		/datum/reagent/medicine/polypyr = 5,
		/datum/reagent/medicine/silibinin = 5,
		/datum/reagent/medicine/omnizine = 5,
		/datum/reagent/inverse/healing/tirimol = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5

// Combat stimulant that makes you immune to slowdowns for a bit
/obj/item/reagent_containers/hypospray/medipen/deforest/synalvipitol
	name = "synalvipitol muscle stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a cocktail of drugs to make any who take it \
		nearly immune to the slowing effects of silly things like 'being tired' or 'facing muscle failure'."
	base_icon_state = "synalvipitol"
	icon_state = "synalvipitol"
	list_reagents = list(
		/datum/reagent/medicine/mine_salve = 5,
		/datum/reagent/medicine/synaptizine = 10,
		/datum/reagent/medicine/muscle_stimulant = 5,
		/datum/reagent/impurity = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5
