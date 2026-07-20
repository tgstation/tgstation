/obj/effect/spawner/random/biome_mob
	name = "random biome mob"
	desc = "Spawns a random mob from a biome"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	spawn_scatter_radius = 1
	spawn_loot_double = FALSE // no duplicates
	loot = list()

/obj/effect/spawner/random/biome_mob/make_item(spawn_loc, type_path_to_make)
	var/mob/living/mob_to_spawn = ..()

	// special behavior for mobs that spawn on the escape shuttle so they don't kill each other
	if(isliving(mob_to_spawn) && istype(get_area(spawn_loc), /area/shuttle/escape))
		mob_to_spawn.add_faction(FACTION_SHUTTLE)
		REMOVE_TRAIT(mob_to_spawn, TRAIT_MOVE_FLYING, ELEMENT_TRAIT(/datum/element/simple_flying)) // no flying out of biome containment pens
		mob_to_spawn.ai_controller.set_ai_status(AI_STATUS_OFF) // when shuttle moves z-level they will automatically wake up

	return mob_to_spawn

/obj/effect/spawner/random/biome_mob/get_spawn_locations(radius, ignore_groundless = FALSE)
	if(istype(get_area(src), /area/shuttle/escape))
		// escape shuttle mob spawners need to be able to spawn in water/lava for unique shuttles
		return ..(radius, ignore_groundless=TRUE)
	else
		return ..(radius, ignore_groundless=FALSE)

/obj/effect/spawner/random/biome_mob/grass
	loot = list(
		/mob/living/basic/cow,
		/mob/living/basic/chick/permanent,
		/mob/living/basic/chicken,
		/mob/living/basic/goat,
		/mob/living/basic/sheep,
		/mob/living/basic/pony,
		/mob/living/basic/rabbit,
		/mob/living/basic/deer,
		/mob/living/basic/goose,
		/mob/living/basic/pig,
		/mob/living/basic/stoat,
		/mob/living/basic/pet/cat,
		/mob/living/basic/pet/dog/corgi,
		/mob/living/basic/pet/dog/pug,
		/mob/living/basic/pet/dog/bullterrier,
		/mob/living/basic/pet/fox,
	)

/obj/effect/spawner/random/biome_mob/fairy
	loot = list(
		/mob/living/basic/lightgeist,
		/mob/living/basic/pet/gondola,
		/mob/living/basic/butterfly,
		/mob/living/basic/mushroom,
		/mob/living/basic/seedling,
		/mob/living/basic/garden_gnome,
		/mob/living/basic/cow/moonicorn,
	)

/obj/effect/spawner/random/biome_mob/snow
	loot = list(
		/mob/living/basic/pet/penguin/baby/permanent,
		/mob/living/basic/pet/penguin/emperor,
		/mob/living/basic/pet/penguin/emperor/shamebrero,
		/mob/living/basic/statue/frosty,
		/mob/living/basic/bear/snow,
		/mob/living/basic/mining/wolf,
		/mob/living/basic/mining/lobstrosity/juvenile,
		/mob/living/basic/mining/lobstrosity,
		/mob/living/basic/mining/basilisk,
		/mob/living/basic/mining/legion/snow,
		/mob/living/basic/tree,
		/mob/living/basic/festivus,
	)

/obj/effect/spawner/random/biome_mob/jungle
	loot = list(
		/mob/living/carbon/human/species/monkey,
		/mob/living/basic/gorilla/lesser,
		/mob/living/basic/sloth,
		/mob/living/basic/lizard,
	)

/obj/effect/spawner/random/biome_mob/lavaland
	loot = list(
		/mob/living/basic/mining/bileworm,
		/mob/living/basic/mining/brimdemon,
		/mob/living/basic/mining/goldgrub,
		/mob/living/basic/mining/goldgrub/baby,
		/mob/living/basic/mining/goliath,
		/mob/living/basic/mining/legion,
		/mob/living/basic/mining/lobstrosity/lava,
		/mob/living/basic/mining/lobstrosity/juvenile/lava,
		/mob/living/basic/mining/watcher,
		/mob/living/basic/mining/gutlunch,
		/mob/living/basic/mining/gutlunch/milk,
		/mob/living/basic/mining/hivelord,
	)

/obj/effect/spawner/random/biome_mob/beach
	loot = list(
		/mob/living/basic/parrot,
		/mob/living/basic/crab,
		/mob/living/basic/crab/kreb,
		/mob/living/basic/turtle,
		/mob/living/basic/carp/passive,
	)

/obj/effect/spawner/random/biome_mob/maint
	loot = list(
		/mob/living/basic/snake,
		/mob/living/basic/spider/maintenance,
		/mob/living/basic/regal_rat,
		/mob/living/basic/mothroach,
		/mob/living/basic/mouse,
		/mob/living/basic/bat,
		/mob/living/basic/ant,
		/mob/living/basic/bear,
		/mob/living/basic/snail,
		/mob/living/basic/frog,
		/mob/living/basic/cockroach,
		/mob/living/basic/cockroach/bloodroach,
		/mob/living/basic/axolotl,
	)

/obj/effect/spawner/random/biome_mob/hostile
	loot = list(
		/mob/living/basic/spider/giant/tangle,
		/mob/living/basic/spider/giant/breacher,
		/mob/living/basic/spider/giant/tank,
		/mob/living/basic/spider/giant/ambush,
		/mob/living/basic/flesh_spider,
		/mob/living/basic/lizard/space,
		/mob/living/basic/rabbit/easter,
		/mob/living/basic/rabbit/easter/space,
		/mob/living/basic/pet/cat/cak,
		/mob/living/basic/pet/dog/breaddog,
		/mob/living/basic/pet/dog/corgi/exoticcorgi,
		/mob/living/basic/pet/dog/corgi/narsie,
		/mob/living/basic/frog/rare,
		/mob/living/basic/crab/evil,
		/mob/living/basic/crab/evil/kreb,
		/mob/living/basic/bear/butter,
		/mob/living/basic/stickman,
		/mob/living/basic/stickman/dog,
		/mob/living/basic/stickman/ranged,
		/mob/living/basic/living_limb_flesh,
		/mob/living/basic/headslug,
		/mob/living/basic/killer_tomato,
		/mob/living/basic/mining/mook,
		/mob/living/basic/bear/russian,
		/mob/living/basic/wumborian_fugu,
		/mob/living/basic/venus_human_trap,
		/mob/living/basic/statue,
		/mob/living/basic/statue/mannequin,
		/mob/living/basic/slime/random,
		/mob/living/basic/shade,
		/mob/living/basic/ghost,
		/mob/living/basic/ghost/swarm,
		/mob/living/basic/pony/dangerous,
		/mob/living/basic/mimic/crate,
		/mob/living/basic/roro,
		/mob/living/basic/seedling/meanie,
		/mob/living/basic/migo,
		/mob/living/basic/migo/hatsune,
		/mob/living/basic/headslug,
		/mob/living/basic/fleshblob,
		/mob/living/basic/faithless,
		/mob/living/basic/eyeball,
		/mob/living/basic/creature,
		/mob/living/basic/cockroach/glockroach,
		/mob/living/basic/cockroach/glockroach/mobroach,
		/mob/living/basic/cockroach/hauberoach,
		/mob/living/basic/blob_minion/spore/independent,
		/mob/living/basic/blob_minion/blobbernaut/independent,
		/mob/living/basic/blankbody,
		/mob/living/basic/alien/queen,
		/mob/living/basic/alien/maid,
		/mob/living/basic/alien/drone,
		/mob/living/basic/alien/sentinel,
		/mob/living/basic/alien,
	)

/obj/effect/spawner/random/biome_mob/clown
	spawn_loot_count = 3
	loot = list(
		/mob/living/basic/clown/fleshclown,
		/mob/living/basic/clown/clownhulk,
		/mob/living/basic/clown/longface,
		/mob/living/basic/clown/clownhulk/chlown,
		/mob/living/basic/clown/clownhulk/honkmunculus,
		/mob/living/basic/clown/mutant/glutton,
		/mob/living/basic/clown/banana,
		/mob/living/basic/clown/honkling,
		/mob/living/basic/clown/lube,
	)

// we need to make special escape shuttle subtypes that use global lists to avoid duplicates

GLOBAL_LIST_INIT(mob_spawner_biome_grass, /obj/effect/spawner/random/biome_mob/grass::loot.Copy())
/obj/effect/spawner/random/biome_mob/grass/shuttle_only/Initialize(mapload)
	loot = GLOB.mob_spawner_biome_grass
	return ..()

GLOBAL_LIST_INIT(mob_spawner_biome_fairy, /obj/effect/spawner/random/biome_mob/fairy::loot.Copy())
/obj/effect/spawner/random/biome_mob/fairy/shuttle_only/Initialize(mapload)
	loot = GLOB.mob_spawner_biome_fairy
	return ..()

GLOBAL_LIST_INIT(mob_spawner_biome_jungle, /obj/effect/spawner/random/biome_mob/jungle::loot.Copy())
/obj/effect/spawner/random/biome_mob/jungle/shuttle_only/Initialize(mapload)
	loot = GLOB.mob_spawner_biome_jungle
	return ..()

GLOBAL_LIST_INIT(mob_spawner_biome_snow, /obj/effect/spawner/random/biome_mob/snow::loot.Copy())
/obj/effect/spawner/random/biome_mob/snow/shuttle_only/Initialize(mapload)
	loot = GLOB.mob_spawner_biome_snow
	return ..()

GLOBAL_LIST_INIT(mob_spawner_biome_lavaland, /obj/effect/spawner/random/biome_mob/lavaland::loot.Copy())
/obj/effect/spawner/random/biome_mob/lavaland/shuttle_only/Initialize(mapload)
	loot = GLOB.mob_spawner_biome_lavaland
	return ..()

GLOBAL_LIST_INIT(mob_spawner_biome_beach, /obj/effect/spawner/random/biome_mob/beach::loot.Copy())
/obj/effect/spawner/random/biome_mob/beach/shuttle_only/Initialize(mapload)
	loot = GLOB.mob_spawner_biome_beach
	return ..()

GLOBAL_LIST_INIT(mob_spawner_biome_maint, /obj/effect/spawner/random/biome_mob/maint::loot.Copy())
/obj/effect/spawner/random/biome_mob/maint/shuttle_only/Initialize(mapload)
	loot = GLOB.mob_spawner_biome_maint
	return ..()

GLOBAL_LIST_INIT(mob_spawner_biome_hostile, /obj/effect/spawner/random/biome_mob/hostile::loot.Copy())
/obj/effect/spawner/random/biome_mob/hostile/shuttle_only/Initialize(mapload)
	loot = GLOB.mob_spawner_biome_hostile
	return ..()
