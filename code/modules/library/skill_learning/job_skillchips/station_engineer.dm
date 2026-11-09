/obj/item/skillchip/job/engineer
	name = "Engineering C1-RCU-1T skillchip"
	desc = "Endorsed by Poly."
	auto_traits = list(TRAIT_KNOW_ENGI_WIRES)
	skill_name = "Engineering Circuitry"
	skill_description = "Recognise airlock and APC wire layouts and understand their functionality at a glance."
	skill_icon = "sitemap"
	activate_message = span_notice("You suddenly comprehend the secrets behind airlock and APC circuitry.")
	deactivate_message = span_notice("Airlock and APC circuitry stops making sense as images of coloured wires fade from your mind.")

/obj/item/skillchip/job/engineer/atmos
	name = "Atmospherics C1-RCU-1T skillchip"
	desc = "Smells faintly of plasma."
	auto_traits = list(TRAIT_KNOW_ATMOS_WIRES)
	skill_name = "Atmospherics Circuitry"
	skill_description = "Recognise air alarm and fire alarm wire layouts and understand their functionality at a glance."
	activate_message = span_notice("You suddenly comprehend the secrets behind air alarm and fire alarm circuitry.")
	deactivate_message = span_notice("Air alarm and fire alarm circuitry stops making sense as images of coloured wires fade from your mind.")
