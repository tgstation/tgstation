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

	///Base color of the material, is used for greyscale. Item isn't changed in color if this is null.
	var/color
	///Base alpha of the material, is used for greyscale icons.
	var/alpha = 255
	///Bitflags that influence how SSmaterials handles this material.
	var/init_flags = MATERIAL_INIT_MAPLOAD
	///Materials "Traits". its a map of key = category | Value = Bool. Used to define what it can be used for
	var/list/categories = list()
	///The type of sheet this material creates. This should be replaced as soon as possible by greyscale sheets
	var/sheet_type
	///This is a modifier for force, and resembles the strength of the material
	var/strength_modifier = 1
	///This is a modifier for integrity, and resembles the strength of the material
	var/integrity_modifier = 1
	///This is the amount of value per 1 unit of the material
	var/value_per_unit = 0
	///Armor modifiers, multiplies an items normal armor vars by these amounts.
	var/armor_modifiers = list(MELEE = 1, BULLET = 1, LASER = 1, ENERGY = 1, BOMB = 1, BIO = 1, RAD = 1, FIRE = 1, ACID = 1)
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

/** Handles initializing the material.
 *
 * Arugments:
 * - _id: The ID the material should use. Overrides the existing ID.
 */
/datum/material/proc/Initialize(_id, ...)
	if(_id)
		id = _id
	else if(isnull(id))
		id = type

	if(texture_layer_icon_state)
		cached_texture_filter_icon = icon('icons/materials/composite.dmi', texture_layer_icon_state)

	return TRUE

///This proc is called when the material is added to an object.
/datum/material/proc/on_applied(atom/source, amount, material_flags)
	if(material_flags & MATERIAL_COLOR) //Prevent changing things with pre-set colors, to keep colored toolboxes their looks for example
		if(color) //Do we have a custom color?
			source.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
		if(alpha)
			source.alpha = alpha
		if(texture_layer_icon_state)
			ADD_KEEP_TOGETHER(source, MATERIAL_SOURCE(src))
			source.add_filter("material_texture_[name]",1,layering_filter(icon=cached_texture_filter_icon,blend_mode=BLEND_INSET_OVERLAY))

	if(alpha < 255)
		source.opacity = FALSE
	if(material_flags & MATERIAL_ADD_PREFIX)
		source.name = "[name] [source.name]"

	if(beauty_modifier)
		source.AddElement(/datum/element/beauty, beauty_modifier * amount)

	if(istype(source, /obj)) //objs
		on_applied_obj(source, amount, material_flags)

	if(istype(source, /turf)) //turfs
		on_applied_turf(source, amount, material_flags)

	source.mat_update_desc(src)

///This proc is called when a material updates an object's description
/atom/proc/mat_update_desc(/datum/material/mat)
	return

///This proc is called when the material is added to an object specifically.
/datum/material/proc/on_applied_obj(obj/o, amount, material_flags)
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/new_max_integrity = CEILING(o.max_integrity * integrity_modifier, 1)
		o.modify_max_integrity(new_max_integrity)
		o.force *= strength_modifier
		o.throwforce *= strength_modifier

		var/list/temp_armor_list = list() //Time to add armor modifiers!

		if(!istype(o.armor))
			return
		var/list/current_armor = o.armor?.getList()

		for(var/i in current_armor)
			temp_armor_list[i] = current_armor[i] * armor_modifiers[i]
		o.armor = getArmor(arglist(temp_armor_list))
	if(!isitem(o))
		return
	var/obj/item/I = o
	if(!item_sound_override)
		return
	I.hitsound = item_sound_override
	I.usesound = item_sound_override
	I.mob_throw_hit_sound = item_sound_override
	I.equip_sound = item_sound_override
	I.pickup_sound = item_sound_override
	I.drop_sound = item_sound_override

/datum/material/proc/on_applied_turf(turf/T, amount, material_flags)
	if(isopenturf(T))
		if(turf_sound_override)
			var/turf/open/O = T
			O.footstep = turf_sound_override
			O.barefootstep = turf_sound_override
			O.clawfootstep = turf_sound_override
			O.heavyfootstep = turf_sound_override
	if(alpha < 255)
		T.AddElement(/datum/element/turf_z_transparency, TRUE)
	return

///This proc is called when the material is removed from an object.
/datum/material/proc/on_removed(atom/source, amount, material_flags)
	if(material_flags & MATERIAL_COLOR) //Prevent changing things with pre-set colors, to keep colored toolboxes their looks for example
		if(color)
			source.remove_atom_colour(FIXED_COLOUR_PRIORITY, color)
		if(texture_layer_icon_state)
			source.remove_filter("material_texture_[name]")
			REMOVE_KEEP_TOGETHER(source, MATERIAL_SOURCE(src))
		source.alpha = initial(source.alpha)

	if(material_flags & MATERIAL_ADD_PREFIX)
		source.name = initial(source.name)

	if(beauty_modifier)
		source.RemoveElement(/datum/element/beauty, beauty_modifier * amount)

	if(istype(source, /obj)) //objs
		on_removed_obj(source, amount, material_flags)

	if(istype(source, /turf)) //turfs
		on_removed_turf(source, amount, material_flags)

///This proc is called when the material is removed from an object specifically.
/datum/material/proc/on_removed_obj(obj/o, amount, material_flags)
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/new_max_integrity = initial(o.max_integrity)
		o.modify_max_integrity(new_max_integrity)
		o.force = initial(o.force)
		o.throwforce = initial(o.throwforce)

/datum/material/proc/on_removed_turf(turf/T, amount, material_flags)
	if(alpha < 255)
		T.RemoveElement(/datum/element/turf_z_transparency, FALSE)

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
 * - breakdown_flags: Some flags dictating how exactly this material is being broken down.
 */
/datum/material/proc/return_composition(amount=1, breakdown_flags=NONE)
	return list((src) = amount) // Yes we need the parenthesis, without them BYOND stringifies src into "src" and things break.
