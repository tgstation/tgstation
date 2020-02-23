/obj/structure/destructible/dwarven
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/dwarven.dmi'
	light_power = 1
	var/cooldowntime = 0
	custom_materials = list()
	//break_sound = 'sound/hallucinations/veryfar_noise.ogg' //to do: find a suitable noise

/obj/structure/destructible/dwarven/New()
	START_PROCESSING(SSfastprocess, src)
	..()

/obj/structure/destructible/dwarven/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()


/obj/structure/destructible/dwarven/dwarven_sarcophagus
	name = "Ancient Sarcophagus"
	icon_state = "sarcophagus_open"

	var/recharge = TRUE
	var/recharge_points = 0
	var/recharge_points_max = 500

/obj/structure/destructible/dwarven/dwarven_sarcophagus/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is [(recharge_points*100)/recharge_points_max]% powered </span>"

/obj/structure/destructible/dwarven/dwarven_sarcophagus/attackby(obj/item/stack/ore/I, mob/living/user, params)
	recharge_points += I.amount * I.points
	qdel(I)
	try_to_activate()
	return

/obj/structure/destructible/dwarven/dwarven_sarcophagus/proc/try_to_activate()
	if(recharge_points_max <= recharge_points)
		for(var/mob/M in viewers(src,5))
			to_chat(M, "<span class='notice'>The sarcophagus reignites with ancient fire, ready to birth another dwarf!</span>")
			new  /obj/effect/mob_spawn/human/dwarven_sarcophagus(get_turf(src))
			qdel(src)
	else
		for(var/mob/M in viewers(src,5))
			to_chat(M, "<span class='notice'>The sarcophagus is set ablaze for a second, but ancient powers die down. It requires more minerals!</span>")

/obj/structure/destructible/dwarven/lava_forge
	name = "Ancient Forge"
	icon_state = "dwarven_forge"
	custom_materials = list(/datum/material/iron = 20000)

/obj/structure/destructible/dwarven/lava_forge/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/stack/ore))
		return ..()
	var/obj/item/stack/ore/O = I
	var/obj/item/refined = O.refined_type
	if(isnull(refined))
		return
	try_forge(user, O, refined)

/obj/structure/destructible/dwarven/lava_forge/proc/try_forge(mob/user, obj/item/stack/ore/O, obj/item/refined_result, recursive = FALSE)
	if(!recursive) //Only say this the first time
		to_chat(user, "<span class='notice'>You start smelting [O] into [initial(refined_result.name)].</span>")
	if(!do_after(user, 30, target = src))
		return FALSE
	var/efficiency = user?.mind.get_skill_modifier(/datum/skill/operating, SKILL_EFFICIENCY_MODIFIER)
	if(prob(efficiency))
		to_chat(user, "<span class='nicegreen'>You succeed in smelting [O]!</span>")
		O.use(1)
		new refined_result(drop_location())
		user?.mind.adjust_experience(/datum/skill/operating, O.mine_experience * 2) //Get double because smelting is more effort than mining in my honest opinion ok? ok.
		if(O.amount > 0) //Only try going recursive if we still have ore
			try_forge(user, O, refined_result, TRUE)
	else
		O.use(1)
		user?.mind.adjust_experience(/datum/skill/operating, O.mine_experience * 0.5)
		to_chat(user, "<span class='warning'>You fail smelting [O] and destroy it!</span>")
		if(O.amount > 0) //Only try going recursive if we still have ore
			try_forge(user, O, refined_result, TRUE)


/obj/structure/destructible/dwarven/blood_pool
	name = "Blood infuser"
	icon_state = "blood_fountain"
	var/charge_amount = 30
	custom_materials  = list(/datum/material/gold = 20000)

/obj/structure/destructible/dwarven/blood_pool/attacked_by(obj/item/I, mob/living/user)
	if(!istype(user,/mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = user
	if(!H.has_language(/datum/language/dwarven))
		to_chat(H, "<span class='notice'>You don't understand the instructions written in that ancient tongue</span>")
		return
	if(isbodypart(I))
		to_chat(H, "<span class='notice'>The [I.name] turns to ash as you impale it on the bone. Infuser brightly flashes and blood pool swells.</span>")
		charge_amount++
		qdel(I)
		return
	. = ..()

/obj/structure/destructible/dwarven/blood_pool/attack_hand(mob/user)
	if(!istype(user,/mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = user
	if(!H.has_language(/datum/language/dwarven))
		to_chat(H, "<span class='notice'>You don't understand the instructions written in that ancient tongue</span>")
		return

	if(charge_amount >= 30)
		to_chat(H, "<span class='notice'>You hear a faint whisper telling you to choose wiselty </span>")
		var/choice
		choice = alert(user,"You study the schematics etched into the stone...",,"Blitz rune","Air rune","Earth rune")
		switch(choice)
			if("Blitz rune")
				new /obj/item/dwarven/rune_stone/blitz(get_turf(src))
			if("Air rune")
				new /obj/item/dwarven/rune_stone/air(get_turf(src))
			if("Earth rune")
				new /obj/item/dwarven/rune_stone/earth(get_turf(src))
		to_chat(H, "<span class='notice'>You hear a whisper telling you you have chosen wisely.</span>")
		charge_amount -= 20
		return

	. = ..()

/obj/structure/destructible/dwarven/mythril_press
	name = "Ancient Alloy Press"
	icon_state = "mythril_press"
	custom_materials  = list(/datum/material/silver = 20000)

/obj/structure/destructible/dwarven/mythril_press/Initialize()
	AddComponent(/datum/component/material_container,list(/datum/material/gold,/datum/material/silver,/datum/material/titanium,/datum/material/dwarven,), 20000, TRUE, /obj/item/stack/sheet/mineral)
	. = ..()

/obj/structure/destructible/dwarven/mythril_press/attack_hand(mob/user)
	press_mythril(user)
	. = ..()

/obj/structure/destructible/dwarven/mythril_press/proc/press_mythril(mob/user)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(materials.has_materials(list(/datum/material/gold= 1000, /datum/material/silver = 1000, /datum/material/titanium = 1000)))
		materials.use_materials(list(/datum/material/gold= 1000, /datum/material/silver = 1000, /datum/material/titanium = 1000))
		materials.insert_amount_mat(materials.sheet2amount(1),/datum/material/dwarven)
		materials.retrieve_all(get_turf(src))
		to_chat(user, "<span class='notice'>You hear a loud crank as materials are compressed into dwarven alloy!</span>")
		return
	materials.retrieve_all(get_turf(src))
	to_chat(user, "<span class='notice'>The machine makes a loud crank sound, but no alloy falls out!</span>")

/obj/structure/destructible/dwarven/workshop
	name = "Dwarven workshop"
	icon_state = "workshop"
	var/state = 0
	custom_materials = list(/datum/material/wood = 20000)
	var/static/list/allowed_types = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/gold,
		/datum/material/silver,
		/datum/material/diamond,
		/datum/material/uranium,
		/datum/material/plasma,
		/datum/material/bluespace,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/runite,
		/datum/material/plastic,
		/datum/material/adamantine,
		/datum/material/mythril,
		/datum/material/wood,
		/datum/material/dwarven,
		)
	var/obj/item/loaded_item

/obj/structure/destructible/dwarven/workshop/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container,allowed_types, 20000, TRUE, /obj/item/stack)

/obj/structure/destructible/dwarven/workshop/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt click to change the function</span>"
	. += "<span class='notice'>Click with mats to put them inside of the workshop</span>"
	. += "<span class='notice'>Click with a hand to retrieve all mats</span>"
	. += "<span class='notice'>Click with a mallet to activate the function</span>"
	switch(state)
		if(0)
			. += "<span class='notice'>Currently it can produce upgrade kits. </span>"
		if(1)
			. += "<span class='notice'>Currently it can produce structure prints for creation of new structures. </span>"
		if(2)
			. += "<span class='notice'>Current it can produce quality pickaxes </span>"


/obj/structure/destructible/dwarven/workshop/AltClick(mob/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return

	if(state == 2)
		state = 0
	else
		state++

/obj/structure/destructible/dwarven/workshop/attack_hand(mob/user)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()
	. = ..()


/obj/structure/destructible/dwarven/workshop/attacked_by(obj/item/I, mob/living/user)
	if(istype(I,/obj/item/dwarven/mallet))
		handle_mallet(user)
		return
	. = ..()

/obj/structure/destructible/dwarven/workshop/proc/handle_mallet(mob/user)
	var/efficiency = user?.mind.get_skill_modifier(/datum/skill/operating, SKILL_EFFICIENCY_MODIFIER)
	to_chat(user,"<span class='notice'>You start looking through design notes...</span>")
	if(!do_after(user, 15, target = src))
		return FALSE
	if(!prob(efficiency))
		user?.mind.adjust_experience(/datum/skill/operating, 1)
		to_chat(user,"<span class='notice'>You cannot find anything of value.</span>")
		return

	to_chat(user,"<span class='notice'>You find something useful!</span>")
	switch(state)
		if(1)
			handle_create_blueprints(user)
		if(2)
			handle_create_pickaxe(user)
		if(0)
			handle_upgrades(user)

	return
///Handles the choosing and creation of dwarven blueprints
/obj/structure/destructible/dwarven/workshop/proc/handle_create_blueprints(mob/user)
	var/obj/structure/destructible/dwarven/wanted_structure
	var/choice
	choice = alert("What structure do you wish to design?",,"Lava forge","Workbench","Dwarven Anvil","Dwarven Gringer")
	switch(choice)
		if("Lava forge")
			wanted_structure = /obj/structure/destructible/dwarven/lava_forge
		if("Workbench")
			wanted_structure = /obj/structure/destructible/dwarven/workshop
		if("Dwarven press")
			wanted_structure = /obj/structure/destructible/dwarven/mythril_press //todo
		if("Dwarven anvil")
			wanted_structure = /obj/structure/destructible/dwarven/workshop // todo

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/i in initial(wanted_structure.custom_materials))
		var/datum/material/M = i
		if(!materials.has_enough_of_material(M,initial(wanted_structure.custom_materials[M])))
			return
	materials.use_materials(initial(wanted_structure.custom_materials))
	new /obj/item/dwarven/blueprint(drop_location(),wanted_structure)
	user?.mind.adjust_experience(/datum/skill/operating, 4)

///Handles the choosing and creation of pickaxes
/obj/structure/destructible/dwarven/workshop/proc/handle_create_pickaxe(mob/user)
	var/obj/item/pickaxe/wanted_pickaxe
	var/choice
	choice = alert("What pickaxe do you wish to create?",,"Iron","Silver","Diamond")
	switch(choice)
		if("Iron")
			wanted_pickaxe = /obj/item/pickaxe
		if("Silver")
			wanted_pickaxe = /obj/item/pickaxe/silver
		if("Diamond")
			wanted_pickaxe = /obj/item/pickaxe/diamond

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/i in initial(wanted_pickaxe.custom_materials))
		var/datum/material/M = i
		if(!materials.has_enough_of_material(M,initial(wanted_pickaxe.custom_materials[M])))
			return
	materials.use_materials(initial(wanted_pickaxe.custom_materials))
	new wanted_pickaxe(drop_location())
	user?.mind.adjust_experience(/datum/skill/operating, 4)

///Handles the choosing and creation of upgrade kits
/obj/structure/destructible/dwarven/workshop/proc/handle_upgrades(mob/user)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	if(!materials.has_enough_of_material(10000,/datum/material/dwarven))
		return
	materials.use_materials(list(/datum/material/dwarven = 10000))
	new /obj/item/dwarven/upgrade_kit(drop_location())
	user?.mind.adjust_experience(/datum/skill/operating, 4)


/obj/structure/destructible/dwarven/anvil
	name = "Dwarven anvil"
	icon_state = "anvil"
	var/state = 0
	var/list/obj/item/crafting_list = list(
		/obj/item/clothing/suit/armor/vest/dwarven_platemail = 20000,
		/obj/item/clothing/suit/armor/vest/dwarven_chainmail  = 10000,
		/obj/item/clothing/head/helmet/dwarven_helmet  = 10000,
		/obj/item/twohanded/war_hammer = 20000,
		/obj/item/hatchet/dwarven/axe = 10000,
		/obj/item/hatchet/dwarven/javelin = 10000
		)
	custom_materials = list(/datum/material/dwarven = 20000)
	var/static/list/allowed_types = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/gold,
		/datum/material/silver,
		/datum/material/diamond,
		/datum/material/uranium,
		/datum/material/plasma,
		/datum/material/bluespace,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/runite,
		/datum/material/plastic,
		/datum/material/adamantine,
		/datum/material/mythril,
		/datum/material/wood,
		/datum/material/dwarven,
		)
	//temporary solution til alloys become its own datum.
	var/static/list/banned_alloys = list(
		/obj/item/stack/sheet/mineral/plastitanium,
		/obj/item/stack/sheet/plasteel,
		/obj/item/stack/sheet/plasmaglass,
		/obj/item/stack/sheet/rglass,
		/obj/item/stack/sheet/plasmarglass,
		/obj/item/stack/sheet/titaniumglass,
		/obj/item/stack/sheet/plastitaniumglass
		)
	var/datum/material/current_mat

/obj/structure/destructible/dwarven/anvil/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container,allowed_types, 200000, TRUE, /obj/item/stack, banned_alloys ,null, _after_insert=CALLBACK(src, .proc/AfterMaterialInsert))

/obj/structure/destructible/dwarven/anvil/AltClick(mob/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	if(state == 5)
		state = 0
	else
		state++

/obj/structure/destructible/dwarven/anvil/proc/AfterMaterialInsert(_item_inserted, id_inserted, amount_inserted)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/datum/material/M in materials.materials)
		if(M != id_inserted)
			materials.retrieve_sheets(materials.materials[M],M,drop_location())

	current_mat = id_inserted

/obj/structure/destructible/dwarven/anvil/attack_hand(mob/user)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()

	. = ..()


/obj/structure/destructible/dwarven/anvil/attacked_by(obj/item/I, mob/living/user)
	if(istype(I,/obj/item/dwarven/mallet) && current_mat != null)
		handle_mallet(user,current_mat)
		return
	. = ..()

/obj/structure/destructible/dwarven/anvil/proc/handle_mallet(mob/living/user,datum/material/S)
	var/list/materials_used = list()

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	if(!do_after(user, 60, target = src))
		return

	var/obj/item/item_built = crafting_list[state+1]
	if(!materials.has_enough_of_material(S,crafting_list[item_built]))
		to_chat(user, "<span class='alert'>Not enough materials for this operation.</span>")
		return

	materials_used[S] += crafting_list[item_built]
	var/efficiency = user?.mind.get_skill_modifier(/datum/skill/operating, SKILL_EFFICIENCY_MODIFIER)*2 //*2 because it is hard as fuck to get it and even then the result is most often shoddy

	if(!prob(efficiency))
		materials.use_materials(materials_used,0.2)
		user?.mind.adjust_experience(/datum/skill/operating, 2)
		to_chat(user,"<span class='notice'>You fail to create anything of value</span>")
		return

	user?.mind.adjust_experience(/datum/skill/operating, 20)
	materials.use_materials(materials_used)
	var/obj/item/new_item = new item_built(drop_location())
	new_item.set_custom_materials(materials_used)
	new_item.add_creator(user)



