/mob/living/carbon/monkey/punpun //except for a few special persistence features, pun pun is just a normal monkey
	name = "Pun Pun" //C A N O N
	unique_name = 0
	var/ancestor_name
	var/ancestor_chain = 1
	var/relic_hat	//Note: these two are paths
	var/relic_mask
	var/memory_saved = 0
	var/list/pet_monkey_names = list("Pun Pun", "Bubbles", "Mojo", "George", "Darwin", "Aldo", "Caeser", "Kanzi", "Kong", "Terk", "Grodd", "Mala", "Bojangles", "Coco", "Able", "Baker", "Scatter", "Norbit", "Travis")
	var/list/rare_pet_monkey_names = list("Professor Bobo", "Deempisi's Revenge", "Furious George", "King Louie", "Dr. Zaius", "Jimmy Rustles", "Dinner", "Lanky")

/mob/living/carbon/monkey/punpun/Initialize()
	Read_Memory()
	if(ancestor_name)
		name = ancestor_name
		if(ancestor_chain > 1)
			name += " \Roman[ancestor_chain]"
	else
		if(prob(5))
			name = pick(rare_pet_monkey_names)
		else
			name = pick(pet_monkey_names)
		gender = pick(MALE, FEMALE)
	..()

	//These have to be after the parent new to ensure that the monkey
	//bodyparts are actually created before we try to equip things to
	//those slots
	if(relic_hat)
		equip_to_slot_or_del(new relic_hat, slot_head)
	if(relic_mask)
		equip_to_slot_or_del(new relic_mask, slot_wear_mask)

/mob/living/carbon/monkey/punpun/Life()
	if(SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(0)
	..()

/mob/living/carbon/monkey/punpun/death(gibbed)
	if(!memory_saved || gibbed)
		Write_Memory(1,gibbed)
	..()

/mob/living/carbon/monkey/punpun/proc/Read_Memory()
	if(fexists("data/npc_saves/Punpun.sav"))
		var/savefile/S = new /savefile("data/npc_saves/Punpun.sav")
		S["ancestor_name"]	>> ancestor_name
		S["ancestor_chain"] >> ancestor_chain
		S["relic_hat"]		>> relic_hat
		S["relic_mask"]		>> relic_mask
		fdel(S)
	else
		var/json_file = file("data/npc_saves/Punpun.json")
		if(!fexists(json_file))
			return
		var/list/json = list()
		json = json_decode(file2text(json_file))
		ancestor_name = json["ancestor_name"]
		ancestor_chain = json["ancestor_chain"]
		relic_hat = json["relic_hat"]
		relic_mask = json["relic_hat"]

/mob/living/carbon/monkey/punpun/proc/Write_Memory(dead, gibbed)
	var/json_file = file("data/npc_saves/Punpun.json")
	var/list/file_data = list()
	if(gibbed)
		file_data["ancestor_name"] = null
		file_data["ancestor_chain"] = null
		file_data["relic_hat"] = null
		file_data["relic_mask"] = null
	if(dead)
		file_data["ancestor_name"] = ancestor_name
		file_data["ancestor_chain"] = ancestor_chain + 1
	file_data["relic_hat"] = head ? head.type : null
	file_data["relic_mask"] = wear_mask ? wear_mask.type : null
	if(!ancestor_name)
		file_data["ancestor_name"] = name
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json_file))
	if(!dead)
		memory_saved = 1
