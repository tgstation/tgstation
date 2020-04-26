
/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "Plain black gloves without fingertips for the hard working."
	icon_state = "fingerless"
	item_state = "fingerless"
	transfer_prints = TRUE
	strip_delay = 40
	equip_delay_other = 20
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	custom_price = 75
	undyeable = TRUE

/obj/item/clothing/gloves/botanic_leather
	name = "botanist's leather gloves"
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin.  They're also quite warm."
	icon_state = "leather"
	item_state = "ggloves"
	permeability_coefficient = 0.9
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 30)

/obj/item/clothing/gloves/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and electrically insulated."
	icon_state = "black"
	item_state = "blackgloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)

/obj/item/clothing/gloves/bracer
	name = "bone bracers"
	desc = "For when you're expecting to get slapped on the wrist. Offers modest protection to your arms."
	icon_state = "bracers"
	item_state = "bracers"
	transfer_prints = TRUE
	strip_delay = 40
	equip_delay_other = 20
	body_parts_covered = ARMS
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list("melee" = 15, "bullet" = 25, "laser" = 15, "energy" = 15, "bomb" = 20, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/gloves/rapid
	name = "Gloves of the North Star"
	desc = "Just looking at these fills you with an urge to beat the shit out of people."
	icon_state = "rapid"
	item_state = "rapid"
	transfer_prints = TRUE

/obj/item/clothing/gloves/rapid/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/wearertargeting/punchcooldown)


/obj/item/clothing/gloves/color/plasmaman
	desc = "Covers up those scandalous boney hands."
	name = "plasma envirogloves"
	icon_state = "plasmaman"
	item_state = "plasmaman"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	permeability_coefficient = 0.05
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 95, "acid" = 95)

/obj/item/clothing/gloves/color/plasmaman/black
	name = "black envirogloves"
	icon_state = "blackplasma"
	item_state = "blackplasma"

/obj/item/clothing/gloves/color/plasmaman/white
	name = "white envirogloves"
	icon_state = "whiteplasma"
	item_state = "whiteplasma"

/obj/item/clothing/gloves/color/plasmaman/robot
	name = "roboticist envirogloves"
	icon_state = "robotplasma"
	item_state = "robotplasma"

/obj/item/clothing/gloves/color/plasmaman/janny
	name = "janitor envirogloves"
	icon_state = "jannyplasma"
	item_state = "jannyplasma"

/obj/item/clothing/gloves/color/plasmaman/cargo
	name = "cargo envirogloves"
	icon_state = "cargoplasma"
	item_state = "cargoplasma"

/obj/item/clothing/gloves/color/plasmaman/engineer
	name = "engineering envirogloves"
	icon_state = "engieplasma"
	item_state = "engieplasma"
	siemens_coefficient = 0

/obj/item/clothing/gloves/color/plasmaman/atmos
	name = "atmos envirogloves"
	icon_state = "atmosplasma"
	item_state = "atmosplasma"
	siemens_coefficient = 0

/obj/item/clothing/gloves/color/plasmaman/explorer
	name = "explorer envirogloves"
	icon_state = "explorerplasma"
	item_state = "explorerplasma"

/obj/item/clothing/gloves/color/botanic_leather/plasmaman
	name = "botany envirogloves"
	desc = "Covers up those scandalous boney hands."
	icon_state = "botanyplasma"
	item_state = "botanyplasma"
	permeability_coefficient = 0.05
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 95, "acid" = 95)

/obj/item/clothing/gloves/color/plasmaman/prototype
	name = "prototype envirogloves"
	icon_state = "protoplasma"
	item_state = "protoplasma"

/obj/item/clothing/gloves/color/plasmaman/clown
	name = "clown envirogloves"
	icon_state = "clownplasma"
	item_state = "clownplasma"

/obj/item/clothing/gloves/combat/wizard
	name = "enchanted gloves"
	desc = "These gloves have been enchanted with a spell that makes them electrically insulated and fireproof."
	icon_state = "wizard"
	item_state = "purplegloves"
