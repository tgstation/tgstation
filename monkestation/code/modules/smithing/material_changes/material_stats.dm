/atom/var/datum/material_stats/material_stats

/atom/proc/create_random_mineral_stats(upper_limit = 100, lower_limit = 1)
	material_stats = new(src)

	material_stats.conductivity = rand(lower_limit, upper_limit)
	material_stats.hardness = rand(lower_limit, upper_limit)
	material_stats.density = rand(lower_limit, upper_limit)
	material_stats.thermal = rand(lower_limit, upper_limit)
	material_stats.flammability = rand(lower_limit, upper_limit)
	material_stats.radioactivity = rand(lower_limit, upper_limit)
	material_stats.liquid_flow = rand(lower_limit, upper_limit)
	material_stats.refractiveness = rand(lower_limit, upper_limit)
	material_stats.material_name = "???" // you should set this yourself after
	material_stats.merged_color = random_color()
	material_stats.apply_color()

/atom/proc/combine_material_stats(atom/other_atom)
	if((!other_atom.material_stats) || !material_stats)
		return
	var/datum/material_stats/other_stats = other_atom.material_stats
	material_stats.merge_names(other_stats)
	material_stats.merge_stats(other_stats)

/atom/proc/create_stats_from_material_stats(datum/material_stats/material)
	material_stats = new(src)

	material_stats.conductivity = material.conductivity
	material_stats.hardness = material.hardness
	material_stats.density = material.density
	material_stats.thermal = material.thermal
	material_stats.flammability = material.flammability
	material_stats.radioactivity = material.radioactivity
	material_stats.liquid_flow = material.liquid_flow
	material_stats.refractiveness = material.refractiveness
	material_stats.material_name = material.material_name
	material_stats.merged_color = material.merged_color
	material_stats.apply_color()

	for(var/datum/material_trait/trait as anything in material.material_traits)
		var/datum/material_trait/new_trait = new trait.type
		new_trait.on_trait_add(material_stats.parent)
		material_stats.material_traits |= new_trait

/atom/proc/create_stats_from_material(datum/material/material_type, colors = TRUE)
	if(!material_type)
		return
	if(material_stats)
		return

	var/datum/material/material = GET_MATERIAL_REF(material_type)
	material_stats = new(src)

	material_stats.colors = colors
	material_stats.conductivity = material.conductivity
	material_stats.hardness = material.hardness
	material_stats.density = material.density
	material_stats.thermal = material.thermal
	material_stats.flammability = material.flammability
	material_stats.radioactivity = material.radioactivity
	material_stats.liquid_flow = material.liquid_flow
	material_stats.refractiveness = material.refractiveness
	material_stats.material_name = material.name
	material_stats.merged_color = material.greyscale_colors
	material_stats.apply_color()

	for(var/datum/material_trait/trait as anything in material.material_traits)
		var/datum/material_trait/new_trait = new trait
		new_trait.on_trait_add(material_stats.parent)
		material_stats.material_traits |= new_trait
		material_stats.material_traits[new_trait] = material.material_traits[trait]


/datum/material_stats
	///material conductivity [0 no conductivity - 100 no loss in energy]
	var/conductivity = 0
	///material hardness [0 super soft - 100 hard as steel]
	var/hardness = 0
	///material density [0 is light - 100 is super dense]
	var/density = 0
	///materials thermal transfer [0 means no thermal energy is transfered - 100 means all of it is]
	var/thermal = 0
	///flammability (basically incase you splice plasma) [0 not flammable - 100 will instantly ignite]
	var/flammability = 0
	///our radioactivity (from splicing uranium) [0 not radioactive - 100 god help me my skin is melting]
	var/radioactivity = 0
	///snowflake chemical transferrence for use with infusions [0 blocks all transfer - 100 is a pure stream]
	var/liquid_flow = 0
	///our refractiveness
	var/refractiveness = 0

	///list of material traits to work with
	var/list/material_traits = list()

	///our coolass color
	var/merged_color
	///do we color
	var/colors = TRUE

	///our combined material_name
	var/material_name
	///datum bitflags (used in some traits when we try to process)
	var/material_bitflags = NONE
	///our parent mob
	var/atom/parent

/datum/material_stats/New(atom/parent)
	. = ..()
	src.parent = parent
	if(parent)
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))
	START_PROCESSING(SSobj, src)

/datum/material_stats/Destroy(force, ...)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	for(var/datum/material_trait/trait as anything in material_traits)
		trait.on_remove(parent)
		qdel(trait)
	material_traits = null
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)
	parent = null

/datum/material_stats/proc/on_attack(datum/source, atom/target, mob/user)
	for(var/datum/material_trait/trait as anything in material_traits)
		trait.on_mob_attack(parent, src, target, user)

/datum/material_stats/process(seconds_per_tick)
	for(var/datum/material_trait/trait as anything in material_traits)
		if((trait.trait_flags & MATERIAL_TRACK_NO_STACK_PROCESS) && (material_bitflags & MATERIAL_STACK))
			continue
		trait.on_process(parent, src)

/datum/material_stats/proc/merge_names(datum/material_stats/other)
	var/name_1 = ""
	var/name_2 = ""
	name_1 = copytext(material_name, 1, round((length(material_name) * 0.5) + 0.5))
	name_2 = copytext(other.material_name, round((length(other.material_name) * 0.5) + 0.5), 0)
	material_name = "[name_1][name_2]"

/datum/material_stats/proc/merge_stats(datum/material_stats/material)
	merged_color = BlendRGB(merged_color, material.merged_color)

	if(material.conductivity)
		conductivity += material.conductivity
		conductivity *= 0.5
	if(material.hardness)
		hardness += material.hardness
		hardness *= 0.5
	if(material.density)
		density += material.density
		density *= 0.5
	if(material.thermal)
		thermal += material.thermal
		thermal *= 0.5
	if(material.flammability)
		flammability += material.flammability
		flammability *= 0.5
	if(material.radioactivity)
		radioactivity += material.radioactivity
		radioactivity *= 0.5
	if(material.liquid_flow)
		liquid_flow += material.liquid_flow
		liquid_flow *= 0.5
	if(material.refractiveness)
		refractiveness += material.refractiveness
		refractiveness *= 0.5


	for(var/datum/material_trait/trait as anything in material_traits)
		material_traits[trait]--
		if(material_traits[trait] <= 0)
			trait.on_remove(parent)
			material_traits -= trait
			qdel(trait)

	for(var/datum/material_trait/trait as anything in material.material_traits)
		var/passed = TRUE
		for(var/datum/material_trait/owned_traits as anything in material_traits)
			if(owned_traits.type != trait.type)
				continue
			passed = FALSE
			break
		if(!passed)
			continue
		var/datum/material_trait/new_trait = new trait.type
		material_traits |= new_trait
		material_traits[new_trait] = material.material_traits[trait]
		new_trait.on_trait_add(parent)

	apply_color()

/datum/material_stats/proc/apply_color()
	if((!colors) || (!ismovable(parent)))
		return
	var/atom/movable/movable = parent
	movable.color = merged_color

/datum/material_stats/proc/add_trait(datum/material_trait/new_trait)
	if(!new_trait)
		return
	var/datum/material_trait/trait = new new_trait.type
	trait.on_trait_add(parent)
	material_traits |= trait
	material_traits[trait] = trait.reforges

/datum/material_stats/proc/apply_traits_from(datum/material_stats/incoming)
	for(var/datum/material_trait/trait as anything in incoming.material_traits)
		var/datum/material_trait/new_trait = new trait.type
		new_trait.on_trait_add(parent)
		material_traits |= new_trait
		material_traits[new_trait] = incoming.material_traits[trait]
