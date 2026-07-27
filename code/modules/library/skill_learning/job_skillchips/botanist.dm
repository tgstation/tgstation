/obj/item/skillchip/job/botanist
	name = "Bi.o Ware skillchip"
	desc = "This biochip contains a catalog of standard edible and functional chemicals that the average farm-to-table botanist may need to recall.\
		 Nowhere as deep as science goggles, however."
	custom_premium_price = PAYCHECK_CREW * 2.3
	auto_traits = list(TRAIT_REAGENT_SCANNER_WEAK)
	skill_name = "Basic Reagent Knowledge"
	skill_description = "Be able to examine and identify many basic reagents with just your eyes alone."
	skill_icon = "flask-vial"
	activate_message = span_notice("You blink, and suddenly you can pick out the individual chemicals in the environment around you. The easy ones, you mean.")
	deactivate_message = span_notice("You notice many tiny huds blink out of existance as you can no longer see basic reagents in the environment.")

