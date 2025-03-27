/*! Material datum

Simple datum which is instanced once per type and is used for every object of said material. It has a variety of variables that define behavior. Subtyping from this makes it easier to create your own materials.

*/


/datum/material
	/// What the material is referred to as IC.
	var/name = "material"
	/// A short description of the material. Not used anywhere, yet...
	var/desc = "its..stuff."
	/// What the material is indexed by in the SSmaterials.materials list. Defaults to the type of the material.
	var/id

	/**
	 * Base color of the material, for items that don't have greyscale configs nor are made of multiple materials. Item isn't changed in color if this is null.
	 * This can be a RGB or color matrix, but it cannot be RGBA as alpha is automatically filled in.
	 */
	var/color
	/**
	 * If the color is a color matrix and either the item uses greyscale configs or is made of multiple colored materials. This will be used instead because
	 * neither greyscale configs nor BlendRGB() support color matrices.
	 * Also this has to be RRGGBB, six characters, no alpha channel as it's automatically filled in.
	 *
	 * Basically, set this if the color is a color matrix (list)
	 */
	var/greyscale_color
	/// Base alpha of the material
	var/alpha = 255
	///Starlight color of the material
	///This is the color of light it'll emit if its turf is transparent and over space. Defaults to COLOR_STARLIGHT if not set
	var/starlight_color
	///Bitflags that influence how SSmaterials handles this material.
	var/init_flags = MATERIAL_INIT_MAPLOAD
	///Materials "Traits". its a map of key = category | Value = Bool. Used to define what it can be used for
	var/list/categories = list()
	///The type of sheet this material creates. This should be replaced as soon as possible by greyscale sheets
	var/sheet_type
	/// What type of ore is this material associated with? Used for mining, and not every material has one.
	var/obj/item/ore_type
	///This is a modifier for force, and resembles the strength of the material
	var/strength_modifier = 1
	///This is a modifier for integrity, and resembles the strength of the material
	var/integrity_modifier = 1

	///This is the amount of value per 1 unit of the material
	var/value_per_unit = 0
	///This is the minimum value of the material, used in the stock market for any mat that isn't set to null
	var/minimum_value_override = null
	///Is this material traded on the stock market?
	var/tradable = FALSE
	///If this material is tradable, what is the base quantity of the material on the stock market?
	var/tradable_base_quantity = 0

	///Armor modifiers, multiplies an items normal armor vars by these amounts.
	var/armor_modifiers = list(MELEE = 1, BULLET = 1, LASER = 1, ENERGY = 1, BOMB = 1, BIO = 1, FIRE = 1, ACID = 1)
	///How beautiful is this material per unit.
	var/beauty_modifier = 0
	///Can be used to override the sound items make, lets add some SLOSHing.
	var/item_sound_override
	///Can be used to override the stepsound a turf makes. MORE SLOOOSH
	var/turf_sound_override
	///what texture icon state to overlay
	var/texture_layer_icon_state
	///a cached icon for the texture filter
	var/cached_texture_filter_icon
	///What type of shard the material will shatter to
	var/obj/item/shard_type
	///How resistant the material is to rusting when applied to a turf
	var/mat_rust_resistance = RUST_RESISTANCE_ORGANIC
	///What type of debris the tile will leave behind when shattered.
	var/obj/effect/decal/debris_type
	/// How likely this mineral is to be found in a boulder during mining.
	var/mineral_rarity = MATERIAL_RARITY_COMMON
	/// How many points per units of ore does this grant?
	var/points_per_unit = 1
	/// The slowdown that is added to items.
	var/added_slowdown = 0

	/// Fish made of or infused with this material have their weight multiplied by this value.
	var/fish_weight_modifier = 1

	/// Additive bonus/malus to the fishing difficulty modifier of any rod made of this item. Negative is good, positive bad
	var/fishing_difficulty_modifier = 0
	/// Additive bonus/malus to the cast range of the fishing rod
	var/fishing_cast_range = 0
	/// The multiplier of how much experience is gained when using a fishing rod made of this material
	var/fishing_experience_multiplier = 1
	/// The multiplier to the completion gain of the fishing rod made of this material
	var/fishing_completion_speed = 1
	/// The multiplier of the bait/bobber speed of the fishing challenge for fishing rods made of this material
	var/fishing_bait_speed_mult = 1
	/// The multiplier of the deceleration/friction for fishing rods made of this material
	var/fishing_deceleration_mult = 1
	/// The multiplier of the bounciness of the bait/bobber upon hitting the edges of the minigame area
	var/fishing_bounciness_mult = 1
	/// The multiplier of negative velocity that pulls the bait/bobber of a fishing rod down when not holding the click
	var/fishing_gravity_mult = 1

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

	return TRUE

///This proc is called when the material is added to an object.
/datum/material/proc/on_applied(atom/source, mat_amount, multiplier)
	return

///This proc is called when the material becomes the one the object is composed of the most
/datum/material/proc/on_main_applied(atom/source, mat_amount, multiplier)
	SHOULD_CALL_PARENT(TRUE)
	if(beauty_modifier >= 0.15 && HAS_TRAIT(source, TRAIT_FISHING_BAIT))
		source.AddElement(/datum/element/shiny_bait)

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

///This proc is called when the material is removed from an object.
/datum/material/proc/on_removed(atom/source, amount, material_flags)
	return

///This proc is called when the material is no longer the one the object is composed by the most
/datum/material/proc/on_main_removed(atom/source, mat_amount, multiplier)
	SHOULD_CALL_PARENT(TRUE)
	if(beauty_modifier >= 0.15 && HAS_TRAIT(source, TRAIT_FISHING_BAIT))
		source.RemoveElement(/datum/element/shiny_bait)

/**
 * This proc is called when the mat is found in an item that's consumed by accident. see /obj/item/proc/on_accidental_consumption.
 * Arguments
 * * M - person consuming the mat
 * * S - (optional) item the mat is contained in (NOT the item with the mat itself)
 */
/datum/material/proc/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	return FALSE

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
	var/list/return_list = list()
	for(var/armor in armor_modifiers)
		return_list[armor] = return_list[armor] * multiplier
	return return_list
