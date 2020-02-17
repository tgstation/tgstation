/obj/structure/destructible/dwarven
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/dwarven.dmi'
	light_power = 1
	var/cooldowntime = 0
	//break_sound = 'sound/hallucinations/veryfar_noise.ogg' //to do: find a suitable noise
	//debris = list(/obj/item/stack/sheet/runed_metal = 1) //to do : make a dwarven metal datum

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
	var/efficiency = user?.mind.get_skill_modifier(/datum/skill/furnacing, SKILL_EFFICIENCY_MODIFIER)
	if(prob(efficiency))
		to_chat(user, "<span class='nicegreen'>You succeed in smelting [O]!</span>")
		O.use(1)
		new refined_result(drop_location())
		user?.mind.adjust_experience(/datum/skill/furnacing, O.mine_experience * 2) //Get double because smelting is more effort than mining in my honest opinion ok? ok.
		if(O.amount > 0) //Only try going recursive if we still have ore
			try_forge(user, O, refined_result, TRUE)
	else
		O.use(1)
		user?.mind.adjust_experience(/datum/skill/furnacing, O.mine_experience * 0.5)
		to_chat(user, "<span class='warning'>You fail smelting [O] and destroy it!</span>")
		if(O.amount > 0) //Only try going recursive if we still have ore
			try_forge(user, O, refined_result, TRUE)


/obj/structure/destructible/dwarven/blood_pool
	name = "Blood infuser"
	icon_state = "blood_fountain"
	var/charge_amount = 30


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
	name = "Ancient Mythril Press"
	icon_state = "mythril_press"

/obj/structure/destructible/dwarven/mythril_press/Initialize()
	AddComponent(/datum/component/material_container,
	list(
	/datum/material/diamond,
	/datum/material/uranium,
	/datum/material/mythril,
	), 20000, TRUE, /obj/item/stack/sheet/mineral, null,  null, FALSE)
	. = ..()

/obj/structure/destructible/dwarven/mythril_press/attack_hand(mob/user)
	press_mythril(user)
	. = ..()

/obj/structure/destructible/dwarven/mythril_press/proc/press_mythril(mob/user)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(materials.has_materials(list(/datum/material/diamond = 1000, /datum/material/uranium = 1000)))
		materials.use_materials(list(/datum/material/diamond = 1000, /datum/material/uranium = 1000))
		materials.insert_amount_mat(materials.sheet2amount(1),/datum/material/mythril)
		materials.retrieve_all(get_turf(src))
		to_chat(user, "<span class='notice'>You hear a loud crank as materials are compressed into mythril!</span>")
		return
	materials.retrieve_all(get_turf(src))
	to_chat(user, "<span class='notice'>The machine makes a loud crank sound, but no mythril falls out!</span>")

/obj/structure/destructible/dwarven/mythril_anvil
	name = "Ancient Mythril Anvil"
	icon_state = "mythril_anvil"
	var/loaded_mold


/obj/structure/destructible/dwarven/mythril_anvil/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Load with iron to create a mold</span>"
	. += "<span class='notice'>Use with mold and another material to create armor</span>"
/*
/obj/structure/destructible/dwarven/mythril_anvil/attacked_by(obj/item/I, mob/living/user)
	if(loaded_mold == null && istype(I,/obj/item/stack/sheet/metal))
		var/choice
		choice = alert(user,"Choose the mold",,"Platemail mold","Chainmail mold","Helmet mold","Warhammer mold","Waraxe mold","Javelin mold")
		switch(choice)
			if("Platemail mold")

	. = ..()
*/

/obj/structure/destructible/dwarven/mythril_anvil/debug/attack_hand(mob/user)
	var/choice
	choice = alert(user,"Choose an item",,"Warhammer","Waraxe","Javelin")
	switch(choice)
		if("Warhammer")
			var/obj/item/twohanded/war_hammer/debug = new /obj/item/twohanded/war_hammer(get_turf(src))
			debug.add_creator(user)
		if("Waraxe")
			var/obj/item/hatchet/dwarven/axe/debug = new /obj/item/hatchet/dwarven/axe(get_turf(src))
			debug.add_creator(user)
		if("Javelin")
			var/obj/item/hatchet/dwarven/javelin/debug = new /obj/item/hatchet/dwarven/javelin(get_turf(src))
			debug.add_creator(user)

