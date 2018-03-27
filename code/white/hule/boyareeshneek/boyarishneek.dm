/obj/machinery/vending/boyarka
	name = "Boyarishnik vending machine"
	desc = "Высококачественный напиток для высокопоставленных господ! Всего 49 русских грывней! Сдачу не возвращаем!"
	density = FALSE
	use_power = NO_POWER_USE  //ну будем считать что он механический
	icon = 'code/white/hule/boyareeshneek/boyarishneek.dmi'
	icon_state = "boyarka"
	icon_vend = "boyarka"
	product_ads = "Покупайте-покупайте!;Космическое искушение!;Всего за 49 русских грывней!"
	product_slogans = "Боярышник или смерть!"

	products = list(/obj/item/reagent_containers/food/drinks/boyarishnik = 3)

	contraband = list(/obj/item/reagent_containers/food/drinks/boyarishnik = 5)

	premium = list(/obj/item/reagent_containers/food/drinks/boyarishnik = 50, /obj/item/seeds/berry/boyarishneek = 1)

	refill_canister = null

	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/boyarka/New()
	name = "[pick("Boyarka24","Boyarin24","Boyarishneek24", "BoyarkaPlus", "BoyarinPlus", "BoyarishneekPlus", "BoyarkaForte", "BoyarinForte", "BoyarishneekForte")]"

/datum/reagent/consumable/ethanol/boyarka
	name = "Boyarka"
	id = "boyarka"
	description = "Number one drink AND fueling choice for Russians worldwide."
	color = "#0064C8"
	boozepwr = 100
	taste_description = "berry alcohol"
	glass_icon_state = "wineglass"
	glass_name = "boyarishnik glass"
	glass_desc = "Царский напиток в царской рюмке."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/consumable/ethanol/boyarka/on_mob_life(mob/living/M)
	if(prob(5))
		M.adjustToxLoss(2*REM, 0)
		M.blur_eyes(35)
		M.set_eye_damage(50)
		. = 1
	..()

	if(prob(2))
		M.set_drugginess(50)
		M.adjustBrainLoss(2*REM, 50)
	..()

	if(prob(2))
		M.hallucination += 4
		M.adjustToxLoss(5*REM, 0)
		M.Sleeping(40, 0)
	 ..()

	if(prob(2))
		M.set_eye_damage(100)
		M.Sleeping(300, 0)
	 ..()

	if(prob(1.5))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.undergoing_cardiac_arrest() && H.can_heartattack())
				H.set_heartattack(TRUE)
				if(H.stat == CONSCIOUS)
					H.visible_message("<span class='userdanger'>[H] clutches at [H.p_their()] chest as if [H.p_their()] heart stopped!</span>")
			else
				H.losebreath += 10
				H.adjustOxyLoss(rand(5,25), 0)
				. = 1

	if(prob(2))
		M.damageoverlaytemp = 60
		M.update_damage_hud()
		M.blur_eyes(3)
		M.Sleeping(40, 0)
		M.adjustBrainLoss(100)
	 ..()

	if(prob(0.3))
		M.gib()
	return ..()

	if(prob(1))
		M.reagents.add_reagent("sugar",300)
	..()

	if(prob(2.5))		//НАРОДНАЯ МЕДИЦИНА ХУЛЕ
		if(iscarbon(M))
			var/mob/living/carbon/N = M
			N.hal_screwyhud = SCREWYHUD_HEALTHY
		M.adjustBruteLoss(-0.25*REM, 0)
		M.adjustFireLoss(-0.25*REM, 0)
		..()
		. = 1

	if(prob(0.1))
		M.reagents.remove_all_type(/datum/reagent/toxin, 5*REM, 0, 1)
		M.setCloneLoss(0, 0)
		M.setOxyLoss(0, 0)
		M.radiation = 0
		M.heal_bodypart_damage(5,5, 0)
		M.adjustToxLoss(-5, 0)
		M.hallucination = 0
		M.setBrainLoss(0)
		M.remove_all_disabilities()
		M.set_blurriness(0)
		M.set_blindness(0)
		M.SetKnockdown(0, 0)
		M.SetStun(0, 0)
		M.SetUnconscious(0, 0)
		M.dizziness = 0
		M.drowsyness = 0
		M.stuttering = 0
		M.slurring = 0
		M.confused = 0
		M.SetSleeping(0, 0)
		M.jitteriness = 0
		..()
		. = 1

	if(prob(0.3))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.getorganslot(ORGAN_SLOT_ZOMBIE))
				var/obj/item/organ/zombie_infection/ZI = new()
				ZI.Insert(H)
	..()

	if(prob(0.2))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.set_species(/datum/species/abductor)
			H.name = "[pick("Ayy Lmao", "Boy Arishnik", "Somewhere in Nevada...", "Naruto Uzumaki", "Jebediah Cristoff")]"

	if(prob(0.2))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.set_species(/datum/species/vampire)

	if(prob(0.2))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.set_species(/datum/species/angel)

/obj/item/reagent_containers/food/drinks/boyarishnik
	name = "Boyarishnik bottle"
	desc = "Алкогольная сладкая пакость двадцать шестого века."
	icon = 'code/white/hule/boyareeshneek/boyarishneek.dmi'
	icon_state = "boyarka_bottle"
	list_reagents = list("boyarka" = 30)
	foodtype = ALCOHOL

/obj/item/storage/briefcase/boyarishneek
	name = "Boyarishnik case"
	desc = "Элитный напиток в элегантном кейсе. Ровно десять пузырьков желанного нектара."
	display_contents_with_number = TRUE
	storage_slots = 10
	can_hold = list(
		/obj/item/reagent_containers/food/drinks/boyarishnik
		)

/obj/item/storage/briefcase/boyarishneek/PopulateContents()
	new /obj/item/reagent_containers/food/drinks/boyarishnik(src)
	new /obj/item/reagent_containers/food/drinks/boyarishnik(src)
	new /obj/item/reagent_containers/food/drinks/boyarishnik(src)
	new /obj/item/reagent_containers/food/drinks/boyarishnik(src)
	new /obj/item/reagent_containers/food/drinks/boyarishnik(src)

	new /obj/item/reagent_containers/food/drinks/boyarishnik(src)
	new /obj/item/reagent_containers/food/drinks/boyarishnik(src)
	new /obj/item/reagent_containers/food/drinks/boyarishnik(src)
	new /obj/item/reagent_containers/food/drinks/boyarishnik(src)
	new /obj/item/reagent_containers/food/drinks/boyarishnik(src)

/obj/item/reagent_containers/syringe/lethal/boyarishneek
	name = "boyarka injection syringe"
	desc = "Только для самых бесстрашных. И безнадежных."
	list_reagents = list("boyarka" = 50)

/obj/item/storage/briefcase/boyarishneek
	name = "Boyarishnik injection case"
	desc = "Десять шприцов с боярышником."
	display_contents_with_number = TRUE
	storage_slots = 10
	can_hold = list(
		/obj/item/reagent_containers/syringe/lethal/boyarishneek
		)

/obj/item/storage/briefcase/boyarishneekinjections/PopulateContents()
	new /obj/item/reagent_containers/syringe/lethal/boyarishneek(src)
	new /obj/item/reagent_containers/syringe/lethal/boyarishneek(src)
	new /obj/item/reagent_containers/syringe/lethal/boyarishneek(src)
	new /obj/item/reagent_containers/syringe/lethal/boyarishneek(src)
	new /obj/item/reagent_containers/syringe/lethal/boyarishneek(src)

	new /obj/item/reagent_containers/syringe/lethal/boyarishneek(src)
	new /obj/item/reagent_containers/syringe/lethal/boyarishneek(src)
	new /obj/item/reagent_containers/syringe/lethal/boyarishneek(src)
	new /obj/item/reagent_containers/syringe/lethal/boyarishneek(src)
	new /obj/item/reagent_containers/syringe/lethal/boyarishneek(src)

/datum/supply_pack/organic/boyarka
	name = "Boyarka Case"
	cost = 1000
	contains = list(/obj/item/storage/briefcase/boyarishneek)
	crate_name = "boyarka crate"

/datum/supply_pack/organic/boyarkainjections
	name = "Boyarka Injections Case"
	cost = 5000
	contains = list(/obj/item/storage/briefcase/boyarishneekinjections)
	crate_name = "boyarka crate"