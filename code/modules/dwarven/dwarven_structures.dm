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
	. += "<span class='notice'>It requires [recharge_points_max-recharge_points] points to reactivate </span>"

/obj/structure/destructible/dwarven/dwarven_sarcophagus/attackby(obj/item/stack/ore/I, mob/living/user, params)
	recharge_points += I.amount * I.points
	qdel(I)
	check_requirements()
	return

/obj/structure/destructible/dwarven/dwarven_sarcophagus/proc/check_requirements()
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

obj/structure/destructible/dwarven/mythril_press
	name = "Ancient Mythril Press"
	icon_state = "mythril_press"
	var/list/obj/item/stack/sheet/mineral/loaded_mats = list()
	var/list/obj/item/stack/sheet/mineral/needed_mats = list("diamond","uranium")

obj/structure/destructible/dwarven/mythril_press/attacked_by(obj/item/I, mob/living/user)
	if(istype(I,/obj/item/stack/sheet/mineral))
		var/obj/item/stack/sheet/mineral/M = I
		var/list/obj/item/stack/sheet/mineral/mat_list = list()
		mat_list = loaded_mats & needed_mats
		if(!(M in mat_list))
			loaded_mats += "[M.name]"
			M.amount--
			to_chat(user, "<span class='notice'>You load [M.name] deep into the machine. There is no getting that sheet back.</span>")
			if(M.amount == 0)
				qdel(M)
			return
		to_chat(user, "<span class='notice'>[M.name] is already loaded into the machine!</span>")
		return
	. = ..()

obj/structure/destructible/dwarven/mythril_press/attack_hand(mob/user)
	var/list/obj/item/stack/sheet/mineral/mat_list = list()
	mat_list = needed_mats & needed_mats
	if(mat_list ~= needed_mats)
		new /obj/item/stack/sheet/mineral/mythril(get_turf(src), 1)
		loaded_mats = list()
		return
	to_chat(user, "<span class='notice'>There aren't enough materials loaded into the mythril press!</span>")
	. = ..()



