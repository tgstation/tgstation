///A simple component that manages raising things from aquarium fish.
/datum/component/fish_growth
	dupe_mode = COMPONENT_DUPE_SELECTIVE
	///the type of the movable that's spawned when the fish grows up.
	var/result_type
	///The progress, from 0 to 100
	var/maturation
	///How much maturation is gained per tick
	var/growth_rate
	///Is the result moved on the nearest drop location?
	var/use_drop_loc
	///Is the parent deleted once the result is spawned?
	var/del_on_grow
	///Will the result inherit the name of the fish if that was changed from the initial name.
	var/inherit_name

/datum/component/fish_growth/Initialize(result_type, growth_time, use_drop_loc = TRUE, del_on_grow = TRUE, inherit_name = TRUE)
	. = ..()
	if(!isfish(parent))
		return COMPONENT_INCOMPATIBLE
	src.result_type = result_type
	growth_rate = 100 / growth_time
	src.use_drop_loc = use_drop_loc
	src.del_on_grow = del_on_grow
	src.inherit_name = inherit_name

/datum/component/fish_growth/CheckDupeComponent(
	datum/component/fish_growth/new_growth, // will be null
	result_type,
	growth_time,
	use_drop_loc = TRUE,
	del_on_grow = TRUE,
	inherit_name = TRUE,
)
	if(result_type == src.result_type)
		growth_rate = 100 / growth_time
		return TRUE //copy the growth rate and kill the new component
	return FALSE

/datum/component/fish_growth/RegisterWithParent()
	var/evo_growth = ispath(result_type, /datum/fish_evolution)
	RegisterSignal(parent, COMSIG_FISH_LIFE, PROC_REF(on_fish_life))
	if(!evo_growth)
		return
	var/datum/fish_evolution/evolution = GLOB.fish_evolutions[result_type]
	evolution.RegisterSignal(parent, COMSIG_FISH_BEFORE_GROWING, TYPE_PROC_REF(/datum/fish_evolution, growth_checks))

/datum/component/fish_growth/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_FISH_LIFE, COMSIG_FISH_BEFORE_GROWING))

/datum/component/fish_growth/proc/on_fish_life(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(source.status == FISH_DEAD) //It died just now.
		return
	var/deciseconds_elapsed = seconds_per_tick * 10
	var/growth = growth_rate * deciseconds_elapsed
	if(HAS_TRAIT(source, TRAIT_FISH_QUICK_GROWTH))
		growth *= 2
	if(SEND_SIGNAL(source, COMSIG_FISH_BEFORE_GROWING, seconds_per_tick, growth, result_type) & COMPONENT_DONT_GROW)
		return
	maturation += growth
	if(maturation >= 100)
		finish_growing(source)

/datum/component/fish_growth/proc/finish_growing(obj/item/fish/source)
	var/atom/location = use_drop_loc ? source.drop_location() : source.loc
	var/is_evo = ispath(result_type, /datum/fish_evolution)
	var/atom/movable/result
	if(is_evo)
		var/datum/fish_evolution/evolution = GLOB.fish_evolutions[result_type]
		result = source.create_offspring(evolution.new_fish_type, evolution = evolution)
		var/obj/item/fish/fishie = result
		fishie.breeding_wait = source.breeding_wait
		fishie.last_feeding = source.last_feeding
		var/health_percent = source.health / initial(source.health)
		fishie.adjust_health(fishie.health * health_percent)
	else
		result = new result_type (location)
		if(location != source.loc)
			result.visible_message(span_boldnotice("\A [result] jumps out of [source.loc]!"))
			playsound(result, 'sound/effects/fish_splash.ogg', 60)
		if(isbasicmob(result))
			for(var/trait_type in source.fish_traits)
				var/datum/fish_trait/trait = GLOB.fish_traits[trait_type]
				trait.apply_to_mob(result)

			addtimer(CALLBACK(result, TYPE_PROC_REF(/mob/living/basic, hop_on_nearby_turf)), 0.1 SECONDS)

	if(is_evo || location == source.loc)
		var/message_verb = del_on_grow ? "grows into" : "lays"
		location.visible_message(span_notice("[source] [message_verb] \a [result]."), vision_distance = 3)

	if(inherit_name && HAS_TRAIT(source, TRAIT_WAS_RENAMED))
		if(ismob(result))
			var/mob/mob = result
			mob.fully_replace_character_name(mob.name, source.name)
		else
			result.AddComponent(/datum/component/rename, source.name, result.desc)

	SEND_SIGNAL(source, COMSIG_FISH_FINISH_GROWING, result)

	if(del_on_grow)
		qdel(parent)
	else
		maturation = 0
