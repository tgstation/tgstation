///gary is gonna have nothing to do with other crows because of how much unique code it has
/mob/living/basic/chicken/gary
	desc = "Gary the Crow. An inquisitive, yet cruel barterer."
	breed_name_female = "Gary"
	breed_name_male = "Gary"

	icon_suffix = "crow_gary"
	icon_state = "crow_gary"

	ai_controller = /datum/ai_controller/chicken/gary

	mutation_list = list()

	///birb can hold smoll item
	var/obj/item/held_item

	///read our memories for setting up
	var/fully_setup = FALSE
	///have we saved our memory
	var/memory_saved = FALSE
	///rounds since last death
	var/rounds_survived = 0
	///largest concurrent rounds survived
	var/longest_survival = 0
	///largest concurrent rounds died
	var/longest_deathstreak = 0
	///list of held shinies
	var/list/held_shinies = list()

/mob/living/basic/chicken/gary/Initialize(mapload)
	. = ..()
	Read_Memory()

/mob/living/basic/chicken/gary/death(gibbed)
	. = ..()
	Write_Memory(TRUE)

/mob/living/basic/chicken/gary/proc/Read_Memory()
	if(fexists("data/npc_saves/Gary.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Gary.sav")
		S["roundssurvived"]		>> rounds_survived
		S["longestsurvival"]	>> longest_survival
		S["longestdeathstreak"] >> longest_deathstreak
		S["heldshines"] 			>> held_shinies
		fdel("data/npc_saves/Gary.sav")
	else
		var/json_file = file("data/npc_saves/Gary.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		rounds_survived = json["roundssurvived"]
		longest_survival = json["longestsurvival"]
		longest_deathstreak = json["longestdeathstreak"]
		held_shinies = json["heldshines"]
		sanitize_shinies()

/mob/living/basic/chicken/gary/Write_Memory(dead)
	. = ..()
	var/json_file = file("data/npc_saves/Gary.json")
	var/list/file_data = list()
	if(dead)
		file_data["roundssurvived"] = min(rounds_survived - 1, 0)
		file_data["longestsurvival"] = longest_survival
		file_data["heldshines"] = list() //punished for killing
		if(rounds_survived - 1 < longest_deathstreak)
			file_data["longestdeathstreak"] = rounds_survived - 1
		else
			file_data["longestdeathstreak"] = longest_deathstreak
	else
		file_data["roundssurvived"] = rounds_survived + 1
		if(rounds_survived + 1 > longest_survival)
			file_data["longestsurvival"] = rounds_survived + 1
		else
			file_data["longestsurvival"] = longest_survival
		file_data["longestdeathstreak"] = longest_deathstreak
	file_data["heldshines"] = held_shinies + file_data["heldshines"]
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/mob/living/basic/chicken/gary/proc/sanitize_shinies()
	var/list/uncleaned = held_shinies
	held_shinies = list()
	for(var/dirty in uncleaned)
		held_shinies += text2path(dirty)

/mob/living/basic/chicken/gary/proc/return_stored_items()
	if(!fully_setup)
		Read_Memory()
	return held_shinies

/mob/living/basic/chicken/gary/attacked_by(obj/item/attacking_item, mob/living/user)
	if(attacking_item.w_class <= WEIGHT_CLASS_SMALL)
		if(held_item)
			. = ..()
			return
		if(istype(attacking_item, /obj/item/knife))
			held_item = attacking_item //put knife in hand
			attack_sound = 'sound/weapons/bladeslice.ogg'
			melee_damage_upper = attacking_item.force //attack dmg inherits knife dmg
			melee_damage_lower = attacking_item.force
			icon_state = "crow_gary_knife"
			qdel(attacking_item)
			return
		else
			held_item = attacking_item
			attacking_item.forceMove(src)
			ai_controller.blackboard[BB_GARY_COME_HOME] = TRUE
			ai_controller.blackboard[BB_GARY_HAS_SHINY] = TRUE
			return
	. = ..()
