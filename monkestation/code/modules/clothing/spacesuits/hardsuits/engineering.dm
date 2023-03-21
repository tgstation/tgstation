/obj/item/clothing/head/helmet/space/hardsuit/engine
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	armor_type = /datum/armor/hardsuit/engineering
	hardsuit_type = "engineering"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/helmet/space/hardsuit/engine/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/suit/space/hardsuit/engine
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	armor_type = /datum/armor/hardsuit/engineering
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/engine/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/suit/space/hardsuit/engine/equipped(mob/user, slot)
	. = ..()
	AddComponent(/datum/component/geiger_sound)

/obj/item/clothing/suit/space/hardsuit/engine/dropped()
	. = ..()
	var/datum/component/geiger_sound/GS = GetComponent(/datum/component/geiger_sound)
	if(GS)
		qdel(GS)

/////////////////////////////////// ATMOSPHERICS /////////////////////////////////////////////

/obj/item/clothing/head/helmet/space/hardsuit/atmos
	name = "atmospherics hardsuit helmet"
	desc = "A modified engineering hardsuit for work in a hazardous, low pressure environment. The radiation shielding plates were removed to allow for improved thermal protection instead."
	icon_state = "hardsuit0-atmos"
	hardsuit_type = "atmos"
	armor_type = /datum/armor/hardsuit/atmos
	heat_protection = HEAD //Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/atmos
	name = "atmospherics hardsuit"
	desc = "A modified engineering hardsuit for work in a hazardous, low pressure environment. The radiation shielding plates were removed to allow for improved thermal protection instead."
	icon_state = "hardsuit-atmos"
	armor_type = /datum/armor/hardsuit/atmos
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS //Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/atmos

/obj/item/clothing/suit/space/hardsuit/atmos/equipped(mob/user, slot)
	. = ..()
	AddComponent(/datum/component/geiger_sound)

/obj/item/clothing/suit/space/hardsuit/atmos/dropped()
	. = ..()
	var/datum/component/geiger_sound/GS = GetComponent(/datum/component/geiger_sound)
	if(GS)
		qdel(GS)
