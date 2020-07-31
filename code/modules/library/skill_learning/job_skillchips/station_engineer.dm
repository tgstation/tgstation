/obj/item/skillchip/engineer
	name = "Engineering C1-RCU-1T skillchip"
	desc = "Endorsed by Poly."
	auto_trait = TRAIT_KNOW_CYBORG_WIRES
	skill_name = "Engineering Circuitry"
	skill_description = "Recognise airlock and APC wire layouts and understand their functionality at a glance."
	skill_icon = "sitemap"
	implanting_message = "<span class='notice'>You suddenly comprehend the secrets behind airlock and APC circuitry.</span>"
	removal_message = "<span class='notice'>Airlock and APC circuitry stops making sense as images of coloured wires fade from your mind.</span>"

/obj/item/skillchip/roboticist/Initialize()
	. = ..()
	skillchip_flags |= SKILLCHIP_JOB_TYPE
