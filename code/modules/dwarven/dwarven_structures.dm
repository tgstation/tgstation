/obj/structure/destructible/dwarven
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/dwarven.dmi'
	light_power = 1
	var/cooldowntime = 0
	custom_materials = list()
	//break_sound = 'sound/hallucinations/veryfar_noise.ogg' //to do: find a suitable noise

/obj/structure/destructible/dwarven/New()
	START_PROCESSING(SSprocessing, src)
	..()

/obj/structure/destructible/dwarven/Destroy()
	STOP_PROCESSING(SSprocessing, src)
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
	var/mob/living/carbon/human/H = user
	if(!H.has_language(/datum/language/dwarven))
		to_chat(H, "<span class='notice'>You don't understand how to operate this ancient machinery!</span>")
		return
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
		to_chat(H, "<span class='notice'>You don't understand how to operate this ancient machinery!</span>")
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
	var/mob/living/carbon/human/H = user
	if(!H.has_language(/datum/language/dwarven))
		to_chat(H, "<span class='notice'>You don't understand how to operate this ancient machinery!</span>")
		return
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
	var/list/datum/design/dwarven/available_recipes = list()
	var/flag = DWARVEN_WORKSHOP

/obj/structure/destructible/dwarven/workshop/Initialize()
	for(var/i in subtypesof(/datum/design/dwarven))
		var/datum/design/dwarven/D = i
		if(initial(D.build_type) == flag)
			available_recipes += D
	AddComponent(/datum/component/material_container,allowed_types, 20000, TRUE, /obj/item/stack)
	. = ..()

/obj/structure/destructible/dwarven/workshop/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt click to change the function</span>"
	. += "<span class='notice'>Click with mats to put them inside of the workshop</span>"
	. += "<span class='notice'>Click with a hand to retrieve all mats</span>"
	. += "<span class='notice'>Click with a mallet to activate the function</span>"
	//for(var/datum/design/D in available_recipes)
	//	. += "<span class='notice'>This machine can build [D.name] and it costs [D.materials[D.materials[1]]] [D.materials[1] </span> "

/obj/structure/destructible/dwarven/workshop/attack_hand(mob/user)
	var/mob/living/carbon/human/H = user
	if(!H.has_language(/datum/language/dwarven))
		to_chat(H, "<span class='notice'>You don't understand how to operate this ancient machinery!</span>")
		return
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()
	. = ..()


/obj/structure/destructible/dwarven/workshop/attacked_by(obj/item/I, mob/living/user)
	var/mob/living/carbon/human/H = user
	if(!H.has_language(/datum/language/dwarven))
		to_chat(H, "<span class='notice'>You don't understand how to operate this ancient machinery!</span>")
		return
	if(istype(I,/obj/item/dwarven/mallet))
		handle_mallet(user)
		return
	. = ..()
///This proc contains everything that happens when you hit the parent with mallet hence the name handle_mallet
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
	var/list/show = list()
	for(var/i in available_recipes)
		var/datum/design/D = i
		show += initial(D.name)

	var/chosen_product  =  input("Choose a structure", "Structure") in sortList(show, /proc/cmp_typepaths_asc)
	if(!chosen_product)
		return //Didn't pick any material, so you can't build shit either.
	var/datum/design/being_built

	for(var/i in available_recipes)
		var/datum/design/D = i
		if(initial(D.name) == chosen_product)
			being_built = new D //we need an initialized datum

	var/total_amount = 0

	for(var/MAT in being_built.materials)
		total_amount += being_built.materials[MAT]


	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	var/list/materials_used = list()
	var/list/custom_materials = list() //These will apply their material effect, This should usually only be one.

	for(var/MAT in being_built.materials)
		var/datum/material/used_material = MAT
		var/amount_needed = being_built.materials[MAT]
		if(istext(used_material)) //This means its a category
			var/list/list_to_show = list()
			for(var/i in SSmaterials.materials_by_category[used_material])
				if(materials.materials[i] > 0)
					list_to_show += i

			used_material = input("Choose [used_material]", "Custom Material") as null|anything in sortList(list_to_show, /proc/cmp_typepaths_asc)
			if(!used_material)
				return //Didn't pick any material, so you can't build shit either.
			custom_materials[used_material] += amount_needed

		materials_used[used_material] = amount_needed

	if(materials.has_materials(materials_used))
		materials.use_materials(materials_used)
		make_item(materials_used,being_built,custom_materials,user)
	else
		for(var/i in materials_used)
			var/datum/material/M = i
			var/amount = materials_used[M]
			to_chat(user,"<span class='notice'>You require [amount] more [M.name]!</span>")

/obj/structure/destructible/dwarven/workshop/proc/make_item(list/materials_used,datum/design/being_built,list/custom_materials,mob/user)
	var/obj/item/new_item = new being_built.build_path(drop_location())

	if(length(custom_materials))
		new_item.set_custom_materials(custom_materials) //Ensure we get the non multiplied amount

/obj/structure/destructible/dwarven/workshop/anvil
	name = "Dwarven anvil"
	icon_state = "anvil"
	custom_materials = list(/datum/material/dwarven = 20000)
	flag = DWARVEN_ANVIL


/obj/structure/destructible/dwarven/workshop/anvil/make_item(list/materials_used,datum/design/being_built,list/custom_materials,mob/user)
	var/obj/item/new_item = new being_built.build_path(drop_location())

	if(length(custom_materials))
		new_item.set_custom_materials(custom_materials) //Ensure we get the non multiplied amount
	var/mob/living/carbon/human/H = user
	new_item.add_creator(H)
