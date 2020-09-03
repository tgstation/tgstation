/** A component added by [/datum/reagent/metalgen] when it's applied to an atom.
  *
  * Injects extra materials into the affecting materials list.
  *
  */
/datum/component/metalgen
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	/// The list of materials that we apply to the parent atom.
	var/list/materials
	/// The material bitflags we apply to the parent atom.
	var/material_flags

/datum/component/metalgen/Initialize(list/_materials, _multiplier=1, _flags=NONE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if((_multiplier <= 0) || !length(_materials))
		return COMPONENT_INCOMPATIBLE

	material_flags = _flags
	materials = SSmaterials.FindOrCreateMaterialCombo(_materials, _multiplier)

	var/atom/parent_atom = parent
	RegisterSignal(parent_atom, COMSIG_ATOM_UPDATE_AFFECTING_MATERIALS, .proc/on_material_update)
	parent_atom.update_affecting_materials()

/datum/component/metalgen/Destroy()
	materials = null

	var/atom/parent_atom = parent
	UnregisterSignal(parent_atom, COMSIG_ATOM_UPDATE_AFFECTING_MATERIALS)
	parent_atom.update_affecting_materials()
	return ..()

/datum/component/metalgen/InheritComponent(datum/component/C, i_am_original, list/_materials, _multiplier=1, _flags=NONE)
	if(!length(_materials))
		return

	var/list/cached_materials = materials.Copy()
	for(var/mat in _materials)
		var/mat_ref = SSmaterials.GetMaterialRef(mat)
		cached_materials[mat_ref] += _materials[mat] * _multiplier
		if(cached_materials[mat_ref] <= 0)
			cached_materials -= mat_ref

	if(!length(cached_materials))
		qdel(src)
		return

	var/atom/parent_atom = parent
	material_flags |= _flags
	materials = SSmaterials.FindOrCreateMaterialCombo(cached_materials, 1)
	parent_atom.update_affecting_materials()


/// Injects some additional materials into the affecting materials list.
/datum/component/metalgen/proc/on_material_update(atom/parent_atom, list/applying_materials, multiplier, flags)
	SIGNAL_HANDLER

	var/list/cached_materials = materials
	for(var/mat in cached_materials)
		applying_materials[mat] += cached_materials[mat]
	return material_flags
