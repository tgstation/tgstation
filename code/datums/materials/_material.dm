/*! Material datum

Simple datum which is instanced once per type and is used for every object of said material. It has a variety of variables that define behavior. Subtyping from this makes it easier to create your own materials.

*/


/datum/material
	abstract_type = /datum/material
	/// What the material is referred to as IC.
	var/name = "material"
	/// A short description of the material. Not used anywhere, yet...
	var/desc = "its..stuff."
	/// What the material is indexed by in the SSmaterials.materials list. Defaults to the type of the material.
	var/id = null

	/// Bitflags that influence how SSmaterials handles this material.
	var/init_flags = MATERIAL_INIT_MAPLOAD
	/// Material behaviors, controls how the material is categorized and in what recipes it can be used
	var/mat_flags = NONE
	/// List of material property IDs to their values, 0 - 10
	var/mat_properties = null

	// Color values
	/// Base color of the material, for items that don't have greyscale configs nor are made of multiple materials. Item isn't changed in color if this is null.
	/// This can be a RGB or color matrix, but it cannot be RGBA as alpha is automatically filled in.
	var/color = null
	/**
	 * If the color is a color matrix and either the item uses greyscale configs or is made of multiple colored materials. This will be used instead because
	 * neither greyscale configs nor BlendRGB() support color matrices.
	 * Also this has to be RRGGBB, six characters, no alpha channel as it's automatically filled in.
	 *
	 * Basically, set this if the color is a color matrix (list)
	 */
	var/greyscale_color = null
	/// Base alpha of the material
	var/alpha = 255
	/// Starlight color of the material
	/// This is the color of light it'll emit if its turf is transparent and over space. Defaults to GLOB.starlight_color if not set
	var/starlight_color = null

	// Trading values
	/// This is the amount of value per 1 unit of the material
	var/value_per_unit = 0
	/// This is the minimum value of the material, used in the stock market for any mat that isn't set to null
	var/minimum_value_override = null
	/// Is this material traded on the stock market?
	var/tradable = FALSE
	/// If this material is tradable, what is the base quantity of the material on the stock market?
	var/tradable_base_quantity = 0

	// Associated item types
	/// The type of sheet this material creates.
	var/sheet_type = null
	/// What type of ore is this material associated with? Used for mining, and not every material has one.
	var/obj/item/ore_type = null
	/// What type of shard the material will shatter to
	var/obj/item/shard_type = null
	/// What type of debris the tile will leave behind when shattered.
	var/obj/effect/decal/debris_type = null
	/// Reagent type(s) of this material. Can be a reagent typepath or a list.
	var/list/material_reagent = null

	// Misc stats
	/// How resistant the material is to rusting when applied to a turf
	var/mat_rust_resistance = RUST_RESISTANCE_ORGANIC
	/// How likely this mineral is to be found in a boulder during mining.
	var/mineral_rarity = MATERIAL_RARITY_COMMON
	/// How many points per units of ore does this grant?
	var/points_per_unit = 1

	// Sound/icon stats, not inherited
	/// Can be used to override the sound items make, lets add some SLOSHing.
	var/item_sound_override = null
	/// Can be used to override the stepsound a turf makes. MORE SLOOOSH
	var/turf_sound_override = null
	/// What texture icon state to overlay
	var/texture_layer_icon_state = null
	/// A cached icon for the texture filter
	var/icon/cached_texture_filter_icon = null

/** Handles initializing the material.
 *
 * Arguments:
 * - _id: The ID the material should use. Overrides the existing ID.
 */
/datum/material/proc/Initialize(_id, ...)
	if(_id)
		id = _id
	else if(isnull(id))
		id = type

	if(texture_layer_icon_state)
		cached_texture_filter_icon = icon('icons/turf/composite.dmi', texture_layer_icon_state)

	for (var/prop_id in mat_properties)
		var/datum/material_property/property = SSmaterials.properties[prop_id]
		property.attach_to(src)

	return TRUE

///This proc is called when the material is added to an object.
/datum/material/proc/on_applied(atom/source, mat_amount, multiplier)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MATERIAL_APPLIED, source, mat_amount, multiplier)

///This proc is called when the material becomes the one the object is composed of the most
/datum/material/proc/on_main_applied(atom/source, mat_amount, multiplier)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MATERIAL_MAIN_APPLIED, source, mat_amount, multiplier)

/datum/material/proc/setup_glow(turf/on)
	if(GET_TURF_PLANE_OFFSET(on) != GET_LOWEST_STACK_OFFSET(on.z)) // We ain't the bottom brother
		return
	// We assume no parallax means no space means no light
	if(SSmapping.level_trait(on.z, ZTRAIT_NOPARALLAX))
		return
	if(!starlight_color)
		on.RegisterSignal(SSdcs, COMSIG_STARLIGHT_COLOR_CHANGED, TYPE_PROC_REF(/turf, material_starlight_changed))
		RegisterSignal(on, COMSIG_QDELETING, PROC_REF(lit_turf_deleted))
	on.set_light(2, 1, starlight_color || GLOB.starlight_color, l_height = LIGHTING_HEIGHT_SPACE)

/turf/proc/material_starlight_changed(datum/source, old_star, new_star)
	if(light_color == old_star)
		set_light_color(new_star)

/datum/material/proc/lit_turf_deleted(turf/source)
	source.set_light(0, 0, null)

/// This proc is called when the material is removed from an object.
/datum/material/proc/on_removed(atom/source, amount, material_flags)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MATERIAL_REMOVED, source, amount, material_flags)

/// This proc is called when the material is no longer the one the object is composed by the most
/datum/material/proc/on_main_removed(atom/source, mat_amount, multiplier)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MATERIAL_MAIN_REMOVED, source, mat_amount, multiplier)

////Called in `/datum/component/edible/proc/on_material_effects`
/datum/material/proc/on_edible_applied(atom/source, datum/component/edible/edible)
	return

////Called in `/datum/component/edible/proc/on_remove_material_effects`
/datum/material/proc/on_edible_removed(atom/source, datum/component/edible/edible)
	return

/**
 * This proc is called when the mat is found in an item that's consumed by accident. see /obj/item/proc/on_accidental_consumption.
 * Arguments
 * * M - person consuming the mat
 * * S - (optional) item the mat is contained in (NOT the item with the mat itself)
 */
/datum/material/proc/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	SHOULD_CALL_PARENT(TRUE)

	if (!material_reagent)
		return FALSE

	var/effect_multiplier = source_item.custom_materials[type] / SHEET_MATERIAL_AMOUNT
	if (!islist(material_reagent))
		victim.reagents?.add_reagent(material_reagent, rand(6, 8) * effect_multiplier)
		source_item?.reagents?.add_reagent(material_reagent, source_item.reagents.total_volume * MATERIAL_REAGENT_CONSUMPTION_MULT * effect_multiplier)
		return TRUE

	for (var/datum/reagent/reagent_type as anything in material_reagent)
		var/amount_mult = material_reagent[reagent_type] / length(material_reagent)
		victim.reagents?.add_reagent(material_reagent, rand(6, 8) * effect_multiplier * amount_mult)
		source_item?.reagents?.add_reagent(material_reagent, source_item.reagents.total_volume * MATERIAL_REAGENT_CONSUMPTION_MULT * effect_multiplier * amount_mult)
	return TRUE

/** Returns the composition of this material.
 *
 * Mostly used for alloys when breaking down materials.
 *
 * Arguments:
 * - amount: The amount of the material to break down.
 */
/datum/material/proc/return_composition(amount = 1, flags)
	// Yes we need the parenthesis, without them BYOND stringifies src into "src" and things break.
	return list((src) = amount)

///Returns the list of armor modifiers, with each element having its assoc value multiplied by the multiplier arg
/datum/material/proc/get_armor_modifiers(multiplier)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/density = get_property(MATERIAL_DENSITY)
	var/hardness = get_property(MATERIAL_HARDNESS)
	var/flexibility = get_property(MATERIAL_FLEXIBILITY)
	var/reflectivity = get_property(MATERIAL_REFLECTIVITY)
	var/electric = get_property(MATERIAL_ELECTRICAL)
	var/thermal = get_property(MATERIAL_THERMAL)
	var/chemical = get_property(MATERIAL_CHEMICAL)
	var/flammability = get_property(MATERIAL_FLAMMABILITY) // Optional, might be not present
	// Welcome to hell
	var/list/armor_modifiers = list(
		// Based on density, with a bonus/malus for matching flexibility
		// We cap divergence at 4 (reduced by hardness above 6 for REALLY dense stuff) to make it not extremely punishing on light fabrics or heavy materials
		// Iron at a baseline of density of 6 and flexibility of 4 has divergence of 4, so (1 + 0.2) / (0.8 + 0.4) = 1
		MELEE = (1 + (density - 4) * 0.1) / (0.8 + min(4 - max(0, hardness - 6), abs(flexibility - density)) * 0.1),
		// Hardness and density, with flexibility actually being detrimental
		BULLET = (1 + (density - 4) * 0.025 + (hardness - 4) * 0.075) / (1 - max(0, flexibility - 2) * 0.1),
		// 0.6 ~ 1 for reflectivity below 4, 1 ~ 1.4 for reflectivity above 6, reduced for transparent materials
		LASER = 1 + MATERIAL_PROPERTY_DIVERGENCE(reflectivity, 4, 6) * 0.1 - (255 - alpha) / 50 * 0.2,
		// Essentially laser but with contribution split between reflectivity and inverse electric conductivity
		// Here reflectivity applies if its below 4 or above 8, and conductivity if its below 4 or above 6
		ENERGY = 1 + MATERIAL_PROPERTY_DIVERGENCE(reflectivity, 4, 8) * 0.05 - MATERIAL_PROPERTY_DIVERGENCE(electric, 4, 6) * 0.1,
		// Linearly scales from 0.2 to 1.8 with density
		BOMB = 1 + (density - 4) * 0.2,
		// Each level of flammability reduces FIRE armor by 20%, with thermal conductivity reducing it by further 20% for each level above 6 and increasing for each level below 2
		FIRE = max(0, 1 - max(0, (thermal - 6) * 0.2) + max(0, (2 - thermal) * 0.2) - flammability * 0.2),
		// Linearly scales from 0.2 to 1.8 with chemical resistance
		ACID = 1 + (chemical - 4) * 0.2,
	)

	for (var/armor_key in armor_modifiers)
		// Safety check to ensure that we don't have inverted armor values
		if (armor_modifiers[armor_key] < 0)
			armor_modifiers[armor_key] = 0
		armor_modifiers[armor_key] = GET_MATERIAL_MODIFIER(armor_modifiers[armor_key], multiplier)

	return armor_modifiers

/datum/material/proc/get_property(prop_id)
	if (!isnull(mat_properties?[prop_id]))
		return mat_properties[prop_id]

	var/datum/material_property/derived/derived_prop = SSmaterials.properties[prop_id]
	if (!istype(derived_prop))
		return null // Property was not specified on the material and wasn't a derived one
	return derived_prop.get_value(src)
