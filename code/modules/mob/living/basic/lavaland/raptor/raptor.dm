/mob/living/basic/mining/raptor
	name = "raptor"
	desc = "A trusty powerful stead. Taming it might prove difficult..."
	icon = 'icons/mob/simple/lavaland/raptor.dmi'
	speed = 2
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	maxHealth = 400
	health = 400
	melee_damage_lower = 25
	melee_damage_upper = 30
	attack_verb_continuous = "pecks"
	attack_verb_simple = "chomps"
	attack_sound = 'sound/weapons/punch1.ogg'
	speak_emote = list("screeches")
	ai_controller = /datum/ai_controller/basic_controller/sheep
	///can this mob breed
	var/can_breed = TRUE
	///can we ride this mob
	var/can_ride = TRUE
	//pet commands when we tame the grub
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/point_targeting/attack,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/fetch,
	)
	///things we inherited from our parent
	var/datum/raptor_inheritance/inherited_stats
	///our color
	var/raptor_color
	///the description that appears in the dex
	var/dex_description

/mob/living/basic/mining/raptor/Initialize(mapload)
	. = ..()
	inherited_stats = new
	AddComponent(/datum/component/happiness)
	if(can_breed)
		AddComponent(\
			/datum/component/breed,\
			can_breed_with = typecacheof(list(/mob/living/basic/mining/raptor)),\
			baby_path = /obj/item/food/egg/raptor_egg,\
			post_birth = CALLBACK(src, PROC_REF(egg_inherit)),\
			breed_timer = 3 MINUTES,\
		)

///pass down our inheritance to the egg
/mob/living/basic/mining/raptor/proc/egg_inherit(obj/item/food/egg/raptor_egg/baby_egg, mob/living/basic/mining/raptor/partner)
	var/datum/raptor_inheritance/inherit = new
	inherit.set_parents(inherited_stats, partner.inherited_stats)
	baby_egg.inherited_stats = inherit
	baby_egg.determine_growth_path(src, partner)

/mob/living/basic/mining/raptor/proc/inherit_properties()
	if(isnull(inherited_stats))
		return
	for(var/trait in GLOB.raptor_inherit_traits) // done this way to allow overriding of traits when assigned new inherit datum
		var/should_inherit = (GLOB.raptor_inherit_traits in inherited_stats.inherit_traits)
		ai_controller?.set_blackboard_key(trait, should_inherit)
	melee_damage_lower += inherited_stats.attack_modifier
	melee_damage_upper += melee_damage_lower + 5
	maxHealth += inherited_stats.health_modifier
	heal_overall_damage(maxHealth)

/mob/living/basic/mining/raptor/Destroy()
	QDEL_NULL(inherited_stats)
	return ..()

/mob/living/basic/mining/raptor/red
	name = "red raptor"
	icon_state = "raptor_red"
	icon_living = "raptor_red"
	icon_dead = "raptor_red_dead"
	melee_damage_lower = 28
	melee_damage_upper = 33
	raptor_color = RAPTOR_RED
	dex_description = "A resilient breed of raptors, battle-tested and bred for the purpose of humbling its foes in combat, \
		This breed demonstrates higher combat capabilities than its peers and oozes rutheless aggression."

/mob/living/basic/mining/raptor/purple
	name = "purple raptor"
	icon_state = "raptor_purple"
	icon_living = "raptor_purple"
	icon_dead = "raptor_purple_dead"
	raptor_color = RAPTOR_PURPLE
	dex_description = "A dependable mount, bred for the purpose of long distance pilgrimages. This breed is also able to store its rider's possessions."

/mob/living/basic/mining/raptor/green
	name = "green raptor"
	icon_state = "raptor_green"
	icon_living = "raptor_green"
	icon_dead = "raptor_green_dead"
	maxHealth = 450
	health = 450
	raptor_color = RAPTOR_GREEN
	dex_description = "A tough breed of raptor, made to withstand the harshest of punishment and to laugh in the face of pain, \
		This breed is able to withstand more beating than its peers."

/mob/living/basic/mining/raptor/green/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/proficient_miner)

/mob/living/basic/mining/raptor/white
	name = "white raptor"
	icon_state = "raptor_white"
	icon_living = "raptor_white"
	icon_dead = "raptor_white_dead"
	raptor_color = RAPTOR_WHITE
	dex_description = "A loving sort, it cares for it peers and rushes to their aid with reckless abandon. It is able to heal any raptors' ailments."

/mob/living/basic/mining/raptor/white/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/healing_touch,\
		heal_brute = melee_damage_upper,\
		heal_burn = melee_damage_upper,\
		heal_time = 0,\
		valid_targets_typecache = typecacheof(list(/mob/living/basic/mining/raptor)),\
	)

/mob/living/basic/mining/raptor/black
	name = "black raptor"
	icon_state = "raptor_black"
	icon_living = "raptor_black"
	icon_dead = "raptor_black_dead"
	maxHealth = 450
	health = 450
	speed = 1
	melee_damage_lower = 28
	melee_damage_upper = 33
	raptor_color = RAPTOR_BLACK
	dex_description = "An ultra rare breed. Due to its sparse nature, not much is known about this sort. However it is said to possess many of its peers' abilities."

/mob/living/basic/mining/raptor/yellow
	name = "yellow raptor"
	icon_state = "raptor_yellow"
	icon_living = "raptor_yellow"
	icon_dead = "raptor_yellow_dead"
	speed = 1
	raptor_color = RAPTOR_YELLOW
	dex_description = "This breed possesses greasy fast speed, DEMON speed, making light work of long pilgrimages. It's said that a thunderclap could be heard when this breed reaches its maximum speed."

/obj/item/food/egg/raptor_egg
	icon = 'icons/mob/simple/lavaland/raptor.dmi'
	icon_state = "raptor_egg"
	///inheritance datum to pass on to the child
	var/datum/raptor_inheritance/inherited_stats

/obj/item/food/egg/raptor_egg/proc/determine_growth_path(mob/living/basic/mining/raptor/dad, mob/living/basic/mining/raptor/mom)
	if(dad.type == mom.type)
		add_growth_component(dad.type)
		return
	var/dad_color = dad.raptor_color
	var/mom_color = mom.raptor_color
	var/list/my_colors = list(dad_color, mom_color)
	sortTim(my_colors, GLOBAL_PROC_REF(cmp_text_asc))
	for(var/path in GLOB.raptor_growth_paths) //guaranteed spawns
		var/list/required_colors = GLOB.raptor_growth_paths[path]
		if(!compare_list(my_colors, required_colors))
			continue
		add_growth_component(path)
		return
	var/list/valid_subtypes = list()
	var/static/list/all_subtypes = subtypesof(/mob/living/basic/mining/raptor/baby_raptor)
	for(var/path in all_subtypes)
		var/mob/living/basic/mining/raptor/baby_raptor/raptor_path = path
		if(!prob(initial(raptor_path.roll_rate)))
			continue
		valid_subtypes += raptor_path
	add_growth_component(pick(valid_subtypes))

/obj/item/food/egg/raptor_egg/proc/add_growth_component(growth_path)
	AddComponent(\
		/datum/component/fertile_egg,\
		embryo_type = growth_path,\
		minimum_growth_rate = 1,\
		maximum_growth_rate = 2,\
		total_growth_required = 50,\
		current_growth = 0,\
		location_allowlist = typecacheof(list(/turf)),\
		post_hatch = CALLBACK(src, PROC_REF(post_hatch)),\
	)

/obj/item/food/egg/raptor_egg/proc/post_hatch(mob/living/basic/mining/raptor/baby)
	if(!istype(baby))
		return
	if(!isnull(baby.inherited_stats))
		QDEL_NULL(baby.inherited_stats)
	baby.inherited_stats = inherited_stats
	inherited_stats = null

/obj/item/food/egg/raptor_egg/Destroy()
	QDEL_NULL(inherited_stats)
	return ..()

#define RANDOM_INHERIT_AMOUNT 2
/datum/raptor_inheritance
	///list of traits we inherit
	var/list/inherit_traits = list()
	///attack modifier
	var/attack_modifier
	///health_modifier
	var/health_modifier

/datum/raptor_inheritance/New(datum/raptor_inheritance/father, datum/raptor_inheritance/mother)
	. = ..()
	randomize_stats()

/datum/raptor_inheritance/proc/randomize_stats()
	attack_modifier = rand(0, RAPTOR_INHERIT_MAX_ATTACK)
	health_modifier = rand(0, RAPTOR_INHERIT_MAX_HEALTH)
	var/list/traits_to_pick = GLOB.raptor_inherit_traits.Copy()
	for(var/i in 1 to RANDOM_INHERIT_AMOUNT)
		inherit_traits += pick_n_take(traits_to_pick)

/datum/raptor_inheritance/proc/set_parents(datum/raptor_inheritance/father, datum/raptor_inheritance/mother)
	if(isnull(father) || isnull(mother))
		return
	if(length(father.inherit_traits))
		inherit_traits += pick(father.inherit_traits)
	if(length(mother.inherit_traits))
		inherit_traits += pick(mother.inherit_traits)
	attack_modifier = rand(min(father.attack_modifier, mother.attack_modifier), max(father.attack_modifier, mother.attack_modifier))
	health_modifier = rand(min(father.health_modifier, mother.health_modifier), min(father.health_modifier, mother.health_modifier))

/datum/raptor_inheritance/proc/clone_inheritance()
	var/datum/raptor_inheritance/new_clone = new
	new_clone.attack_modifier = attack_modifier
	new_clone.health_modifier = health_modifier
	new_clone.inherit_traits += inherit_traits
	return new_clone

#undef RANDOM_INHERIT_AMOUNT
