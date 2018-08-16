/*				CIVILIAN OBJECTIVES			*/

/datum/objective/crew/druglordbot //ported from old Hippie with adjustments
	var/targetchem = "none"
	var/datum/reagent/chempath
	explanation_text = "Have at least (somethin broke here) harvested plants containing (report this on the development discussion channel of citadel's discord) when the shift ends."
	jobs = "botanist"

/datum/objective/crew/druglordbot/New()
	. = ..()
	target_amount = rand(3,20)
	var/blacklist = list(/datum/reagent/drug, /datum/reagent/drug/menthol, /datum/reagent/medicine, /datum/reagent/medicine/adminordrazine, /datum/reagent/medicine/adminordrazine/nanites, /datum/reagent/medicine/mine_salve, /datum/reagent/medicine/syndicate_nanites, /datum/reagent/medicine/strange_reagent, /datum/reagent/medicine/miningnanites, /datum/reagent/medicine/changelingadrenaline, /datum/reagent/medicine/changelinghaste)
	var/drugs = typesof(/datum/reagent/drug) - blacklist
	var/meds = typesof(/datum/reagent/medicine) - blacklist
	var/chemlist = drugs + meds
	chempath = pick(chemlist)
	targetchem = initial(chempath.id)
	update_explanation_text()

/datum/objective/crew/druglordbot/update_explanation_text()
	. = ..()
	explanation_text = "Have at least [target_amount] harvested plants containing [initial(chempath.name)] when the shift ends."

/datum/objective/crew/druglordbot/check_completion()
	var/pillcount = target_amount
	if(owner && owner.current)
		if(owner.current.contents)
			for(var/obj/item/reagent_containers/food/snacks/grown/P in owner.current.get_contents())
				if(P.reagents.has_reagent(targetchem))
					pillcount--
	if(pillcount <= 0)
		return TRUE
	else
		return FALSE

/datum/objective/crew/foodhoard
	var/datum/crafting_recipe/food/targetfood
	var/obj/item/reagent_containers/food/foodpath
	explanation_text = "Personally deliver at least (yo something broke) (report this to the developer discussion channel in citadels discord)s to Centcom."
	jobs = "cook"

/datum/objective/crew/foodhoard/New()
	. = ..()
	target_amount = rand(2,10)
	var/blacklist = list(/datum/crafting_recipe/food, /datum/crafting_recipe/food/cak)
	var/possiblefoods = typesof(/datum/crafting_recipe/food) - blacklist
	targetfood = pick(possiblefoods)
	foodpath = initial(targetfood.result)
	update_explanation_text()

/datum/objective/crew/foodhoard/update_explanation_text()
	. = ..()
	explanation_text = "Personally deliver at least [target_amount] [initial(foodpath.name)]s to Centcom."

/datum/objective/crew/foodhoard/check_completion()
	if(owner && owner.current && owner.current.check_contents_for(foodpath) && SSshuttle.emergency.shuttle_areas[get_area(owner.current)])
		return TRUE
	else
		return FALSE

/datum/objective/crew/responsibility
	explanation_text = "Make sure nobody dies with alcohol poisoning."
	jobs = "bartender"

/datum/objective/crew/responsibility/check_completion()
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.stat == DEAD && H.drunkenness >= 80)
			if(H.z == SSmapping.station_start || SSshuttle.emergency.shuttle_areas[get_area(H)])
				return FALSE
	return TRUE

/datum/objective/crew/clean //ported from old Hippie
	var/list/areas = list()
	var/hardmode = FALSE
	explanation_text = "Ensure sure that (Yo, something broke. Yell about this in citadels devlopmeent discussion channel.) remain spotless at the end of the shift."
	jobs = "janitor"

/datum/objective/crew/clean/New()
	. = ..()
	if(prob(1))
		hardmode = TRUE
	var/list/blacklistnormal = list(typesof(/area/space) - typesof(/area/lavaland) - typesof(/area/mine) - typesof(/area/ai_monitored/turret_protected) - typesof(/area/tcommsat))
	var/list/blacklisthard = list(typesof(/area/lavaland) - typesof(/area/mine))
	var/list/possibleareas = list()
	if(hardmode)
		possibleareas = GLOB.teleportlocs - /area - blacklisthard
	else
		possibleareas = GLOB.teleportlocs - /area - blacklistnormal
	for(var/i in 1 to rand(1,6))
		areas |= pick_n_take(possibleareas)
	update_explanation_text()

/datum/objective/crew/clean/update_explanation_text()
	. = ..()
	explanation_text = "Ensure that the"
	for(var/i in 1 to areas.len)
		var/area/A = areas[i]
		explanation_text += " [A]"
		if(i != areas.len && areas.len >= 3)
			explanation_text += ","
		if(i == areas.len - 1)
			explanation_text += "and"
	explanation_text += " [(areas.len ==1) ? "is completely" : "are [(areas.len == 2) ? "completely" : "all"]"] clean at the end of the shift."
	if(hardmode)
		explanation_text += " Chop-chop."

/datum/objective/crew/clean/check_completion()
	for(var/area/A in areas)
		for(var/obj/effect/decal/cleanable/C in area_contents(A))
			if(C && C.alpha >= 150)
				return FALSE
	return TRUE

/datum/objective/crew/slipster //ported from old Hippie with adjustments
	explanation_text = "Slip at least (Yell on citadel's development discussion channel if you see this) different people with your PDA, and have it on you at the end of the shift."
	jobs = "clown"

/datum/objective/crew/slipster/New()
	. = ..()
	target_amount = rand(5, 20)
	update_explanation_text()

/datum/objective/crew/slipster/update_explanation_text()
	. = ..()
	explanation_text = "Slip at least [target_amount] different people with your PDA, and have it on you at the end of the shift."

/datum/objective/crew/slipster/check_completion()
	var/list/uniqueslips = list()
	if(owner && owner.current)
		for(var/obj/item/pda/clown/PDA in owner.current.get_contents())
			for(var/mob/living/carbon/human/H in PDA.slipvictims)
				uniqueslips |= H
	if(uniqueslips.len >= target_amount)
		return TRUE
	else
		return FALSE

/datum/objective/crew/vow //ported from old Hippie
	explanation_text = "Never break your vow of silence."
	jobs = "mime"

/datum/objective/crew/vow/check_completion()
	if(owner && owner.current)
		var/list/say_log = owner.current.logging[INDIVIDUAL_SAY_LOG]
		if(say_log.len > 0)
			return FALSE
	return TRUE

/datum/objective/crew/nullrod
	explanation_text = "Don't lose your holy rod."
	jobs = "chaplain"

/datum/objective/crew/nullrod/check_completion()
	if(owner && owner.current)
		for(var/nullrodtypes in typesof(/obj/item/nullrod))
			if(owner.current.check_contents_for(nullrodtypes))
				return TRUE
		if(owner.current.getorgan(/obj/item/organ/genital/penis))
			return TRUE
	return FALSE

/datum/objective/crew/reporter //ported from old hippie
	var/charcount = 100
	explanation_text = "Publish at least (Yo something broke) articles containing at least (Report this to Citadels development channel) characters."
	jobs = "curator"

/datum/objective/crew/reporter/New()
	. = ..()
	target_amount = rand(2,10)
	charcount = rand(20,250)
	update_explanation_text()

/datum/objective/crew/reporter/update_explanation_text()
	. = ..()
	explanation_text = "Publish at least [target_amount] articles containing at least [charcount] characters."

/datum/objective/crew/reporter/check_completion()
	if(owner && owner.current)
		var/ownername = "[ckey(owner.current.real_name)][ckey(owner.assigned_role)]"
		for(var/datum/newscaster/feed_channel/chan in GLOB.news_network.network_channels)
			for(var/datum/newscaster/feed_message/msg in chan.messages)
				if(ckey(msg.returnAuthor()) == ckey(ownername))
					if(length(msg.returnBody()) >= charcount)
						target_amount--
	if(target_amount <= 0)
		return TRUE
	else
		return FALSE

/datum/objective/crew/pwrgame //ported from Goon with adjustments
	var/obj/item/clothing/targettidegarb
	explanation_text = "Get your grubby hands on a (Dear god something broke. Report this to Citadel's development dicussion channel)."
	jobs = "assistant"

/datum/objective/crew/pwrgame/New()
	. = ..()
	var/list/muhvalids = list(/obj/item/clothing/mask/gas, /obj/item/clothing/head/welding, /obj/item/clothing/head/ushanka, /obj/item/clothing/gloves/color/yellow, /obj/item/clothing/mask/gas/owl_mask)
	if(prob(10))
		muhvalids += list(/obj/item/clothing/suit/space)
	targettidegarb = pick(muhvalids)
	update_explanation_text()

/datum/objective/crew/pwrgame/update_explanation_text()
	. = ..()
	explanation_text = "Get your grubby hands on a [initial(targettidegarb.name)]."
/* DM is not a sane language in any way, shape, or form. If anyone wants to try to get this bit functioning proper, I hold no responsibility for broken keyboards.
	if(owner && owner.current)
		var/mob/living/carbon/human/H = owner.current
		if(H && H.dna && H.dna.species && H.dna.species.id)
			explanation_text = "Get your "
			if(H.dna.species.id == "avian")
				explanation_text += "scratchy claws "
			else if(H.dna.species.id == "mammal")
				explanation_text += "dirty paws "
			else if(H.dna.species.id == "aquatic")
				explanation_text += "fishy hands "
			else if(H.dna.species.id == "xeno")
				explanation_text += "weird claws "
			else if(H.dna.species.id == "guilmon")
				explanation_text += "digital claws "
			else if(H.dna.species.id == "lizard")
				explanation_text += "slimy claws "
			else if(H.dna.species.id == "datashark")
				explanation_text += "glitchy hands "
			else if(H.dna.species.id == "insect")
				explanation_text += "gross grabbers "
			else
				explanation_text += "grubby hands "
			explanation_text += "on a space suit." replace this if you're making this monstrosity work	*/

/datum/objective/crew/pwrgame/check_completion()
	if(owner && owner.current)
		for(var/tidegarbtypes in typesof(targettidegarb))
			if(owner.current.check_contents_for(tidegarbtypes))
				return TRUE
	return FALSE

/datum/objective/crew/promotion //ported from Goon
	explanation_text = "Have a non-assistant ID registered to you at the end of the shift."
	jobs = "assistant"

/datum/objective/crew/promotion/check_completion()
	if(owner && owner.current)
		var/mob/living/carbon/human/H = owner.current
		var/obj/item/card/id/theID = H.get_idcard()
		if(istype(theID))
			if(!(H.get_assignment() == "Assistant") && !(H.get_assignment() == "No id") && !(H.get_assignment() == "No job"))
				return TRUE
	return FALSE
