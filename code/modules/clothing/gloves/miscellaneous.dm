/obj/item/clothing/gloves/captain
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	item_state = "captain"
	siemens_coefficient = 0
	_color = "captain"
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	pressure_resistance = 200 * ONE_ATMOSPHERE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/cyborg
	desc = "beep boop borp"
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "black"
	siemens_coefficient = 1.0
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/swat
	desc = "These tactical gloves are somewhat fire and impact-resistant."
	name = "\improper SWAT Gloves"
	icon_state = "black"
	item_state = "black"
	siemens_coefficient = 0.6
	permeability_coefficient = 0.05
	heat_conductivity = INS_GLOVES_HEAT_CONDUCTIVITY
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/combat //Combined effect of SWAT gloves and insulated gloves
	desc = "These tactical gloves are somewhat fire and impact resistant."
	name = "combat gloves"
	icon_state = "black"
	item_state = "black"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	heat_conductivity = INS_GLOVES_HEAT_CONDUCTIVITY
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	desc = "Sterile latex gloves."
	icon_state = "latex"
	item_state = "latex"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	_color = "medical"				//matches cmo stamp
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/botanic_leather
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	name = "botanist's leather gloves"
	icon_state = "leather"
	item_state = "leather"
	permeability_coefficient = 0.9
	siemens_coefficient = 0.9
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/batmangloves
	desc = "Used for handling all things bat related."
	name = "batgloves"
	icon_state = "bmgloves"
	item_state = "bmgloves"
	_color = "bmgloves"
	species_fit = list(VOX_SHAPED)

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
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/protogloves
	desc = "Funcionally identical to the DRN-001 model's, but in red!"
	name = "Prototype Gloves"
	icon_state = "protogloves"
	item_state = "protogloves"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/megaxgloves
	desc = "An upgrade to the DRN-001's gauntlets, retains the uncomfortable armor, but comes with white gloves!"
	name = "Maverick Hunter gloves"
	icon_state = "megaxgloves"
	item_state = "megaxgloves"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/joegloves
	desc = "Large grey gloves, very similar to the Prototype's."
	name = "Sniper Gloves"
	icon_state = "joegloves"
	item_state = "joegloves"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/doomguy
	desc = ""
	name = "Doomguy's gloves"
	icon_state = "doom"
	item_state = "doom"

/obj/item/clothing/gloves/knuckles
	desc = "A pair of classic metal knuckles that are designed to increase tissue damage and bone fractures when punching."
	name = "brass knuckles"
	icon_state = "knuckles"
	item_state = "knuckles"

	attack_verb = list("punches")
	bonus_knockout = 2 //Slight knockout chance increase.
	damage_added = 3 //Add 3 damage to unarmed attacks when worn
	force = 5 //Deal 5 damage if hit with this item in hand

/obj/item/clothing/gloves/knuckles/dexterity_check()
	return 0 //Wearing these knuckles makes you less dexterious (so, for example, you can't use computers)

/obj/item/clothing/gloves/knuckles/spiked
	name = "spiked knuckles"
	desc = "A pair of metal knuckles embedded with dull, but nonetheless painful spikes."
	icon_state = "knuckles_spiked"
	item_state = "knuckles_spiked"

	bonus_knockout = 3
	damage_added = 5
	force = 7

/obj/item/clothing/gloves/anchor_arms
	name = "Anchor Arms"
	desc = "When you're a jerk, everybody loves you."
	icon_state = "anchorarms"
	item_state = "anchorarms"
	species_fit = list(VOX_SHAPED)