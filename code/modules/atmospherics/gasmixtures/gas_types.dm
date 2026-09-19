/proc/meta_gas_list()
	var/list/gas_info = new (META_GAS_LENGTH)
	for (var/array_idx in 1 to gas_info.len)
		gas_info[array_idx] = list()

	var/list/gas_types = subtypesof(/datum/gas)
	ASSERT(GAS_TYPE_COUNT == length(gas_types),\
		"GAS_TYPE_COUNT != length(subtypesof(gas_types)), if you added new gas please increment GAS_TYPE_COUNT")
	for(var/datum/gas/gas_path as anything in gas_types)
		gas_info[META_GAS_SPECIFIC_HEAT][gas_path] = initial(gas_path.specific_heat)
		gas_info[META_GAS_NAME][gas_path] = initial(gas_path.name)
		gas_info[META_GAS_MOLES_VISIBLE][gas_path] = initial(gas_path.moles_visible)
		if (gas_info[META_GAS_MOLES_VISIBLE][gas_path])
			gas_info[META_GAS_OVERLAY][gas_path] += generate_gas_overlays(0, SSmapping.max_plane_offset, gas_path)
		gas_info[META_GAS_FUSION_POWER][gas_path] = initial(gas_path.fusion_power)
		gas_info[META_GAS_DANGER][gas_path] = initial(gas_path.cargo_flags) & GAS_DANGEROUS
		gas_info[META_GAS_ID][gas_path] = initial(gas_path.id)
		gas_info[META_GAS_DESC][gas_path] = initial(gas_path.desc)

	/datum/gas_mixture::gas_meta = gas_info // save the reference to the list
	return gas_info

/proc/generate_gas_overlays(old_offset, new_offset, datum/gas/gas_type)
	var/list/to_return = list()
	for(var/i in old_offset to new_offset)
		var/fill = list()
		to_return += list(fill)
		for(var/j in 1 to TOTAL_VISIBLE_STATES)
			var/obj/effect/overlay/gas/gas = new (initial(gas_type.gas_overlay), log(4, (j+0.4*TOTAL_VISIBLE_STATES) / (0.35*TOTAL_VISIBLE_STATES)) * 255, i)
			fill += gas
	return to_return

/proc/gas_id2path(id)
	var/list/meta_gas_id = GLOB.meta_gas_info[META_GAS_ID]
	if(id in meta_gas_id)
		return id
	for(var/path, meta_id in meta_gas_id)
		if(meta_id == id)
			return path
	return ""

/**
 * # Gas datums
 *
 * These are never and should never be instantiated,
 * they just exist to hold data which is passed into the gas metadata list.
 *
 * They are templates for how gases should generally act.
 */
/datum/gas
	var/id = ""
	var/specific_heat = 0
	var/name = ""
	var/desc
	///icon_state in icons/effects/atmospherics.dmi
	var/gas_overlay = ""
	var/moles_visible = null
	///How much the gas accelerates a fusion reaction
	var/fusion_power = 0
	/// relative rarity compared to other gases, used when setting up the reactions list.
	var/rarity = 0
	/// Flags that relate to how the gas is handled in cargo
	/// GAS_PURCHASABLE - Can be purchased in cargo
	/// GAS_EXPORTABLE - Can be sold in cargo
	/// GAS_DANGEROUS - Is considered dangerous, requires elevated access to purchase
	var/cargo_flags = NONE
	/// How does a single mole of this gas buy/sell for?
	/// Formula to calculate maximum value is in [code\modules\cargo\exports\large_objects.dm].
	/// Only necessary for exportable or purchasable gases, otherwise meaningless.
	var/base_value = 0
	/// RGB code for use when a generic color representing the gas is needed. Colors taken from contants.ts
	var/primary_color

/datum/gas/oxygen
	id = GAS_O2
	specific_heat = 20
	name = "Oxygen"
	rarity = 900
	cargo_flags = GAS_PURCHASABLE
	base_value = 0.2
	desc = "The gas most life forms need to be able to survive. Also an oxidizer."
	primary_color = "#0000ff"

/datum/gas/nitrogen
	id = GAS_N2
	specific_heat = 20
	name = "Nitrogen"
	rarity = 1000
	cargo_flags = GAS_PURCHASABLE
	base_value = 0.1
	desc = "A very common gas that used to pad artificial atmospheres to habitable pressure."
	primary_color = "#ffff00"

/datum/gas/carbon_dioxide //what the fuck is this?
	id = GAS_CO2
	specific_heat = 30
	name = "Carbon Dioxide"
	rarity = 700
	cargo_flags = GAS_PURCHASABLE | GAS_DANGEROUS
	base_value = 0.2
	desc = "What the fuck is Carbon Dioxide?"
	// desc = "A colorless, odorless gas commonly produced by respiration and combustion. Potentially dangerous when inhaled in high concentrations."
	primary_color = COLOR_GRAY

/datum/gas/plasma
	id = GAS_PLASMA
	specific_heat = 200
	name = "Plasma"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE
	cargo_flags = GAS_DANGEROUS
	rarity = 800
	base_value = 1.5
	desc = "A flammable gas with many curious properties. Its research is one of Nanotrasen's primary objectives."
	primary_color = "#ffc0cb"

/datum/gas/water_vapor
	id = GAS_WATER_VAPOR
	specific_heat = 40
	name = "Water Vapor"
	gas_overlay = "water_vapor"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 8
	rarity = 500
	cargo_flags = GAS_PURCHASABLE
	base_value = 0.5
	desc = "Water, in gas form. Makes floors slippery and washes items on them."
	primary_color = "#b0c4de"

/datum/gas/hypernoblium
	id = GAS_HYPER_NOBLIUM
	specific_heat = 2000
	name = "Hyper-Noblium"
	gas_overlay = "freon"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 10
	rarity = 50
	cargo_flags = GAS_EXPORTABLE
	base_value = 2.5
	desc = "The most noble gas of them all. High quantities actively prevents reactions from occurring."
	primary_color = COLOR_TEAL

/datum/gas/nitrous_oxide
	id = GAS_N2O
	specific_heat = 40
	name = "Nitrous Oxide"
	gas_overlay = "nitrous_oxide"
	moles_visible = MOLES_GAS_VISIBLE * 2
	fusion_power = 10
	rarity = 600
	cargo_flags = GAS_PURCHASABLE | GAS_DANGEROUS
	base_value = 1.5
	desc = "A gas known to causes drowsiness, euphoria, and eventually unconsciousness. \
		Commonly used as an anesthetic for surgical procedures, and occasionally, as a recreational drug."
	primary_color = "#ffe4c4"

/datum/gas/nitrium
	id = GAS_NITRIUM
	specific_heat = 10
	name = "Nitrium"
	fusion_power = 7
	gas_overlay = "nitrium"
	moles_visible = MOLES_GAS_VISIBLE
	cargo_flags = GAS_PURCHASABLE | GAS_DANGEROUS
	rarity = 1
	base_value = 6
	desc = "An experimental (and slightly toxic) performance enhancing gas that increases speed and alertness when inhaled."
	primary_color = "#a52a2a"

/datum/gas/tritium
	id = GAS_TRITIUM
	specific_heat = 10
	name = "Tritium"
	gas_overlay = "tritium"
	moles_visible = MOLES_GAS_VISIBLE
	cargo_flags = GAS_DANGEROUS | GAS_EXPORTABLE
	fusion_power = 5
	rarity = 300
	base_value = 2.5
	desc = "A highly flammable and radioactive gas."
	primary_color = "#32cd32"

/datum/gas/bz
	id = GAS_BZ
	specific_heat = 20
	name = "BZ"
	fusion_power = 8
	rarity = 400
	cargo_flags = GAS_PURCHASABLE | GAS_EXPORTABLE | GAS_DANGEROUS
	base_value = 1.5
	desc = "A powerful hallucinogenic nerve agent able to induce cognitive damage."
	primary_color = "#9370db"

/datum/gas/pluoxium
	id = GAS_PLUOXIUM
	specific_heat = 80
	name = "Pluoxium"
	fusion_power = -10
	rarity = 200
	cargo_flags = GAS_EXPORTABLE
	base_value = 2.5
	desc = "An alternative to oxygen that is eight times more efficient at lung diffusion \
		and even has minor healing properties - while itself not being an oxidizer."
	primary_color = "#7b68ee"

/datum/gas/miasma
	id = GAS_MIASMA
	specific_heat = 20
	name = "Miasma"
	cargo_flags = GAS_DANGEROUS | GAS_EXPORTABLE
	gas_overlay = "miasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	base_value = 1
	desc = "Miasma is not necessarily a gas, but more broadly refers to biological pollutants \
		found in the atmosphere known to cause disease and nausea."
	primary_color = COLOR_OLIVE

/datum/gas/freon
	id = GAS_FREON
	specific_heat = 600
	name = "Freon"
	cargo_flags = GAS_DANGEROUS | GAS_EXPORTABLE
	gas_overlay = "freon"
	moles_visible = MOLES_GAS_VISIBLE *30
	fusion_power = -5
	rarity = 10
	base_value = 5
	desc = "A coolant gas. Primarily used for its endothermic reaction with oxygen."
	primary_color = "#afeeee"

/datum/gas/hydrogen
	id = GAS_HYDROGEN
	specific_heat = 15
	name = "Hydrogen"
	cargo_flags = GAS_DANGEROUS | GAS_EXPORTABLE
	fusion_power = 2
	rarity = 600
	base_value = 1
	desc = "A highly flammable gas."
	primary_color = "#ffffff"

/datum/gas/healium
	id = GAS_HEALIUM
	specific_heat = 10
	name = "Healium"
	cargo_flags = GAS_DANGEROUS | GAS_EXPORTABLE
	gas_overlay = "healium"
	moles_visible = MOLES_GAS_VISIBLE
	rarity = 300
	base_value = 5.5
	desc = "An experimental alternative to anesthetic that induces a state of unconsciousness \
		that accelerates healing and regeneration when inhaled."
	primary_color = "#fa8072"

/datum/gas/proto_nitrate
	id = GAS_PROTO_NITRATE
	specific_heat = 30
	name = "Proto-Nitrate"
	cargo_flags = GAS_DANGEROUS | GAS_EXPORTABLE
	gas_overlay = "proto_nitrate"
	moles_visible = MOLES_GAS_VISIBLE
	rarity = 200
	base_value = 2.5
	desc = "A volatile gas that has wildly different reactions with other gases."
	primary_color = "#adff2f"

/datum/gas/zauker
	id = GAS_ZAUKER
	specific_heat = 350
	name = "Zauker"
	cargo_flags = GAS_DANGEROUS | GAS_EXPORTABLE
	gas_overlay = "zauker"
	moles_visible = MOLES_GAS_VISIBLE
	rarity = 1
	base_value = 7
	desc = "A highly toxic gas and difficult to produce gas. \
		It breaks down when in contact with Nitrogen, making it relatively safe in Earth-like atmospheres."
	primary_color = "#006400"

/datum/gas/halon
	id = GAS_HALON
	specific_heat = 175
	name = "Halon"
	cargo_flags = GAS_DANGEROUS | GAS_EXPORTABLE
	gas_overlay = "halon"
	moles_visible = MOLES_GAS_VISIBLE
	rarity = 300
	base_value = 4
	desc = "A potent fire suppressant. It removes Oxygen from high temperature fires and cools down the area."
	primary_color = COLOR_PURPLE

/datum/gas/helium
	id = GAS_HELIUM
	specific_heat = 15
	name = "Helium"
	fusion_power = 7
	rarity = 50
	cargo_flags = GAS_EXPORTABLE
	base_value = 3.5
	desc = "An inert noble gas produced by the fusion of Hydrogen and its derivatives. \
		Commonly known for being lighter than air and its ability to raise voice pitch when inhaled."
	primary_color = "#f0f8ff"

/datum/gas/antinoblium
	id = GAS_ANTINOBLIUM
	specific_heat = 1
	name = "Anti-Noblium"
	cargo_flags = GAS_DANGEROUS | GAS_EXPORTABLE
	gas_overlay = "antinoblium"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 20
	rarity = 1
	base_value = 10
	desc = "A mysterious and highly reactive gas known to replicate itself. \
		It is highly sought after due to its rarity, and will export for a high price."
	primary_color = COLOR_MAROON

/obj/effect/overlay/gas
	icon = 'icons/effects/atmospherics.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	appearance_flags = TILE_BOUND
	vis_flags = NONE
	// The visual offset we are "on".
	// Can't use the traditional loc because we are stored in nullspace, and we can't set plane before init because of the helping that SET_PLANE_EXPLICIT does IN init
	var/plane_offset = 0

/obj/effect/overlay/gas/New(state, alph, offset)
	. = ..()
	icon_state = state
	alpha = alph
	plane_offset = offset

/obj/effect/overlay/gas/Initialize(mapload)
	. = ..()
	SET_PLANE_W_SCALAR(src, initial(plane), plane_offset)
