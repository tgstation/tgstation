/datum/experiment/scanning/random
	name = "Эксперимент со случайным сканированием"
	description = "Содержание этого эксперимента будет рандомизировано. Удачи!"
	///list of types which that can be included in the experiment. Randomly picked from on New
	var/list/possible_types = list()
	/// The total desired number of atoms to have scanned
	var/total_requirement = 0
	/// Max amount of a requirement per type
	var/max_requirement_per_type = 100

/datum/experiment/scanning/random/New(datum/techweb/techweb)
	// Generate random contents
	if (possible_types.len)
		var/picked = 0
		while (picked < total_requirement)
			var/randum = min(rand(1, total_requirement - picked), max_requirement_per_type) //Short for "random num" and not "this is dum that I have to rename 100 different variable names"
			required_atoms[pick(possible_types)] += randum
			picked += randum

	// Fill the experiment as per usual
	..()

/datum/experiment/scanning/random/mecha_damage_scan/New(datum/techweb/techweb)
	. = ..()
	damage_percent = rand(15, 95)
	//updating the description with the damage_percent var set
	description = "Ваши фабрикаторы мехов позволяют быстро производить их в небольших масштабах, но структурная целостность созданных деталей уступает тем, что изготовлены более традиционно. Повредите пару мехов до целостности около [damage_percent]% и просканируйте их, чтобы помочь нам определить, как броня выходит из строя под нагрузкой."

/datum/experiment/scanning/random/mecha_damage_scan/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	var/found_percent = round((target.get_integrity() / target.max_integrity) * 100)
	return ..() && ISINRANGE(found_percent, damage_percent - 5, damage_percent + 5)

/datum/experiment/scanning/random/mecha_equipped_scan/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	var/obj/vehicle/sealed/mecha/stompy = target
	if(!istype(stompy))
		return FALSE //Not a mech
	if(!HAS_TRAIT(stompy,TRAIT_MECHA_CREATED_NORMALLY))
		experiment_handler.announce_message("Отсканированный мех не был сделан экипажем. Здесь нечему учиться.")
		return FALSE //Not hand-crafted
	if(!(stompy.equip_by_category[MECHA_L_ARM] && stompy.equip_by_category[MECHA_R_ARM]))
		experiment_handler.announce_message("Отсканированный мех не имеет оборудования, необходимого для проведения эксперимента.")
		return FALSE //Both arms need be filled
	return ..()
