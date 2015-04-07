/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "s-ninja"
	item_state = "s-ninja"
	siemens_coefficient = 0.2
	var/draining = 0
	var/candrain = 0
	var/mindrain = 200
	var/maxdrain = 400
	species_fit = list("Vox")

/obj/item/clothing/gloves/captain
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	item_state = "egloves"
	siemens_coefficient = 0
	_color = "captain"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list("Vox")

/obj/item/clothing/gloves/cyborg
	desc = "beep boop borp"
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "r_hands"
	siemens_coefficient = 1.0
	species_fit = list("Vox")

/obj/item/clothing/gloves/swat
	desc = "These tactical gloves are somewhat fire and impact-resistant."
	name = "\improper SWAT Gloves"
	icon_state = "black"
	item_state = "swat_gl"
	siemens_coefficient = 0.6
	permeability_coefficient = 0.05

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list("Vox")

/obj/item/clothing/gloves/combat //Combined effect of SWAT gloves and insulated gloves
	desc = "These tactical gloves are somewhat fire and impact resistant."
	name = "combat gloves"
	icon_state = "black"
	item_state = "swat_gl"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list("Vox")

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	desc = "Sterile latex gloves."
	icon_state = "latex"
	item_state = "lgloves"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	_color="medical"				//matches cmo stamp
	species_fit = list("Vox")

/obj/item/clothing/gloves/botanic_leather
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	name = "botanist's leather gloves"
	icon_state = "leather"
	item_state = "ggloves"
	permeability_coefficient = 0.9
	siemens_coefficient = 0.9
	species_fit = list("Vox")

/obj/item/clothing/gloves/batmangloves
	desc = "Used for handling all things bat related."
	name = "batgloves"
	icon_state = "bmgloves"
	item_state = "bmgloves"
	_color="bmgloves"
	species_fit = list("Vox")

/obj/item/clothing/gloves/bikergloves
	name = "Biker's Gloves"
	icon_state = "biker-gloves"
	item_state = "biker-gloves"
	_color = "bikergloves"

/obj/item/clothing/gloves/megagloves
	desc = "Uncomfortably bulky armored gloves."
	name = "DRN-001 Gloves"
	icon_state = "megagloves"
	item_state = "megagloves"
	species_fit = list("Vox")

/obj/item/clothing/gloves/protogloves
	desc = "Funcionally identical to the DRN-001 model's, but in red!"
	name = "Prototype Gloves"
	icon_state = "protogloves"
	item_state = "protogloves"
	species_fit = list("Vox")

/obj/item/clothing/gloves/megaxgloves
	desc = "An upgrade to the DRN-001's gauntlets, retains the uncomfortable armor, but comes with white gloves!"
	name = "Maverick Hunter gloves"
	icon_state = "megaxgloves"
	item_state = "megaxgloves"
	species_fit = list("Vox")

/obj/item/clothing/gloves/joegloves
	desc = "Large grey gloves, very similar to the Prototype's."
	name = "Sniper Gloves"
	icon_state = "joegloves"
	item_state = "joegloves"
	species_fit = list("Vox")