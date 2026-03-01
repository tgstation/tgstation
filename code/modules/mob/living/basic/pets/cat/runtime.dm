#define RUNTIME_SAVE_DATA "data/npc_saves/Runtime.sav"
#define RUNTIME_JSON_DATA "data/npc_saves/Runtime.json"
#define MAX_CAT_DEPLOY 50

/mob/living/basic/pet/cat/runtime
	name = "Runtime"
	desc = "GCAT"
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	///the family we will bring in when a round starts
	var/list/family = null
	///saved list of kids
	var/list/children = null
	/// have we deployed the cats?
	var/cats_deployed = FALSE
	/// have we saved memory?
	var/memory_saved = FALSE
	///callback we use to register our family
	var/datum/callback/register_family

/mob/living/basic/pet/cat/runtime/Initialize(mapload)
	. = ..()
	register_family = CALLBACK(src, PROC_REF(Write_Memory))
	SSticker.OnRoundend(register_family)
	if(mapload)
		read_memory()
		deploy_the_cats()

	if(prob(5))
		icon_state = "original"
		icon_living = "original"
		icon_dead = "original_dead"
		update_appearance()

	post_birth_callback = CALLBACK(src, PROC_REF(after_birth))

/mob/living/basic/pet/cat/runtime/proc/after_birth(mob/living/baby)
	if(isnull(baby))
		return
	LAZYADD(children, baby)

/mob/living/basic/pet/cat/runtime/proc/read_memory()
	if(fexists(RUNTIME_SAVE_DATA))
		var/savefile/save_data = new(RUNTIME_SAVE_DATA)
		save_data["family"] >> family
		fdel(RUNTIME_SAVE_DATA)
		return
	var/json_file = file(RUNTIME_JSON_DATA)
	if(!fexists(json_file))
		return
	var/list/json_list = json_decode(file2text(json_file))
	family = json_list["family"]

/mob/living/basic/pet/cat/runtime/Destroy()
	LAZYREMOVE(SSticker.round_end_events, register_family)
	register_family = null
	post_birth_callback = null
	return ..()

/mob/living/basic/pet/cat/runtime/Write_Memory(dead, gibbed)
	. = ..()
	if(!.)
		return
	var/json_file = file(RUNTIME_JSON_DATA)
	var/list/file_data = list()
	if(!dead)
		for(var/mob/living/basic/pet/cat/kitten/kitten in children)
			if(kitten.stat == DEAD)
				continue
			if(kitten.type in family)
				family[kitten.type] += 1
				continue
			family[kitten.type] = 1
	file_data["family"] = family
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data, JSON_PRETTY_PRINT))

/mob/living/basic/pet/cat/runtime/proc/deploy_the_cats()
	cats_deployed = TRUE
	for(var/cat_type in family)
		if(isnull(family[cat_type]))
			return
		for(var/index in 1 to min(family[cat_type], MAX_CAT_DEPLOY))
			new cat_type(loc)

#undef RUNTIME_SAVE_DATA
#undef RUNTIME_JSON_DATA
#undef MAX_CAT_DEPLOY
