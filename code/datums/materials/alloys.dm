/** Materials made from other materials.
  */
/datum/material/alloy
	name = "alloy"
	desc = ""
	/// The materials this alloy is made from weighted by their ratios.
	var/list/composition = null
	/// Breakdown flags required to reduce this alloy to its component materials.
	var/req_breakdown_flags = BREAKDOWN_ALLOYS

/datum/material/alloy/return_composition(amount=1, breakdown_flags)
	if(req_breakdown_flags & !(breakdown_flags & req_breakdown_flags))
		return ..()

	. = list()
	var/list/cached_comp = composition
	for(var/comp_mat in cached_comp)
		var/datum/material/component_material = SSmaterials.GetMaterialRef(comp_mat)
		var/list/component_composition = component_material.return_composition(cached_comp[comp_mat], breakdown_flags)
		for(var/comp_comp_mat in component_composition)
			.[comp_comp_mat] += component_composition[comp_comp_mat] * amount


/** Plasteel
  *
  * An alloy of iron and plasma.
  */
/datum/material/alloy/plasteel
	name = "plasteel"
	desc = "The heavy duty result of infusing iron with plasma."
	color = "#828282"
	value_per_unit = 0.135
	strength_modifier = 1.5
	integrity_modifier = 1.8 // Heavy duty.
	armor_modifiers = list(MELEE = 1.5, BULLET = 1.5, LASER = 1.3, ENERGY = 1.3, BOMB = 2, BIO = 1, RAD = 1.8, FIRE = 1.5, ACID = 1.5)
	sheet_type = /obj/item/stack/sheet/plasteel
	categories = list(MAT_CATEGORY_RIGID=TRUE, MAT_CATEGORY_BASE_RECIPES=TRUE)
	composition = list(/datum/material/iron=1, /datum/material/plasma=1)

/** Plastitanium
  *
  * An alloy of titanium and plasma.
  */
/datum/material/alloy/plastitanium
	name = "plastitanium"
	desc = "The extremely heat resistant result of infusing titanium with plasma."
	color = "#585658"
	value_per_unit = 0.225
	strength_modifier = 1.3
	integrity_modifier = 1.5
	armor_modifiers = list(MELEE = 1.2, BULLET = 1.2, LASER = 1.5, ENERGY = 1.5, BOMB = 1.3, BIO = 1, RAD = 1.3, FIRE = 2, ACID = 1.5)
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	categories = list(MAT_CATEGORY_RIGID=TRUE, MAT_CATEGORY_BASE_RECIPES=TRUE)
	composition = list(/datum/material/titanium=1, /datum/material/plasma=1)

/** Plasmaglass
  *
  * An alloy of silicate and plasma.
  */
/datum/material/alloy/plasmaglass
	name = "plasmaglass"
	desc = "Plasma-infused silicate. It is much more durable and heat resistant than either of its component materials."
	color = "#dc90eb"
	alpha = 210
	strength_modifier = 1.2
	integrity_modifier = 1.2
	armor_modifiers = list(MELEE = 1.2, BULLET = 1.2, LASER = 1.5, ENERGY = 1.5, BOMB = 1.2, BIO = 1.3, RAD = 1.2, FIRE = 2, ACID = 3)
	sheet_type = /obj/item/stack/sheet/plasmaglass
	shard_type = /obj/item/shard/plasma
	value_per_unit = 0.075
	categories = list(MAT_CATEGORY_RIGID=TRUE, MAT_CATEGORY_BASE_RECIPES=TRUE)
	composition = list(/datum/material/glass=1, /datum/material/plasma=0.5)

/** Titaniumglass
  *
  * An alloy of glass and titanium.
  */
/datum/material/alloy/titaniumglass
	name = "titanium glass"
	desc = "A specialized silicate-titanium alloy that is commonly used in shuttle windows."
	color = "#333135"
	alpha = 210
	strength_modifier = 1.2
	integrity_modifier = 1.3
	armor_modifiers = list(MELEE = 1.5, BULLET = 1.5, LASER = 1.2, ENERGY = 1.2, BOMB = 1.4, BIO = 1.3, RAD = 1.2, FIRE = 1.2, ACID = 2)
	sheet_type = /obj/item/stack/sheet/titaniumglass
	shard_type = /obj/item/shard
	value_per_unit = 0.04
	categories = list(MAT_CATEGORY_RIGID=TRUE, MAT_CATEGORY_BASE_RECIPES=TRUE)
	composition = list(/datum/material/glass=1, /datum/material/titanium=0.5)

/** Plastitanium Glass
  *
  * An alloy of plastitanium and glass.
  */
/datum/material/alloy/plastitaniumglass
	name = "plastitanium glass"
	desc = "A specialized silicate-plastitanium alloy."
	color = "#232127"
	alpha = 210
	strength_modifier = 1.2
	integrity_modifier = 1.3
	armor_modifiers = list(MELEE = 1.4, BULLET = 1.4, LASER = 1.4, ENERGY = 1.4, BOMB = 1.4, BIO = 1.3, RAD = 1.2, FIRE = 2, ACID = 2.5)
	sheet_type = /obj/item/stack/sheet/plastitaniumglass
	shard_type = /obj/item/shard/plasma
	value_per_unit = 0.125
	categories = list(MAT_CATEGORY_RIGID=TRUE, MAT_CATEGORY_BASE_RECIPES=TRUE)
	composition = list(/datum/material/glass=1, /datum/material/alloy/plastitanium=0.5)

/** Alien Alloy
  *
  * Densified plasteel.
  */
/datum/material/alloy/alien
	name = "alien alloy"
	desc = "An extremely dense alloy similar to plasteel in composition. It requires exotic metallurgical processes to create."
	color = "#313a68"
	strength_modifier = 1.8 // It's twice the density of plasteel and just as durable. Getting hit with it is going to HURT.
	integrity_modifier = 1.8
	armor_modifiers = list(MELEE = 1.6, BULLET = 1.6, LASER = 1.5, ENERGY = 1.5, BOMB = 2.5, BIO = 1.2, RAD = 2, FIRE = 1.8, ACID = 1.8)
	sheet_type = /obj/item/stack/sheet/mineral/abductor
	value_per_unit = 0.4
	categories = list(MAT_CATEGORY_RIGID=TRUE, MAT_CATEGORY_BASE_RECIPES=TRUE)
	composition = list(/datum/material/iron=2, /datum/material/plasma=2)
