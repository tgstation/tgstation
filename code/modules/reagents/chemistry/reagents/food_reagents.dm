///////////////////////////////////////////////////////////////////
					//Food Reagents
//////////////////////////////////////////////////////////////////


// Part of the food code. Also is where all the food
// 	condiments, additives, and such go.


/datum/reagent/consumable
	name = "Consumable"
	id = "consumable"
	taste_description = "generic food"
	taste_mult = 4
	var/nutriment_factor = 1 * REAGENTS_METABOLISM

/datum/reagent/consumable/on_mob_life(mob/living/M)
	current_cycle++
	M.nutrition += nutriment_factor
	holder.remove_reagent(src.id, metabolization_rate)

/datum/reagent/consumable/nutriment
	name = "Nutriment"
	id = "nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48

	var/brute_heal = 1
	var/burn_heal = 0

/datum/reagent/consumable/nutriment/on_mob_life(mob/living/M)
	if(prob(50))
		M.heal_bodypart_damage(brute_heal,burn_heal, 0)
		. = 1
	..()

/datum/reagent/consumable/nutriment/on_new(list/supplied_data)
	// taste data can sometimes be ("salt" = 3, "chips" = 1)
	// and we want it to be in the form ("salt" = 0.75, "chips" = 0.25)
	// which is called "normalizing"
	if(!supplied_data)
		supplied_data = data

	// if data isn't an associative list, this has some WEIRD side effects
	// TODO probably check for assoc list?

	data = counterlist_normalise(supplied_data)

/datum/reagent/consumable/nutriment/on_merge(list/newdata, newvolume)
	if(!islist(newdata) || !newdata.len)
		return

	// data for nutriment is one or more (flavour -> ratio)
	// where all the ratio values adds up to 1

	var/list/taste_amounts = list()
	if(data)
		taste_amounts = data.Copy()

	counterlist_scale(taste_amounts, volume)

	var/list/other_taste_amounts = newdata.Copy()
	counterlist_scale(other_taste_amounts, newvolume)

	counterlist_combine(taste_amounts, other_taste_amounts)

	counterlist_normalise(taste_amounts)

	data = taste_amounts

/datum/reagent/consumable/nutriment/vitamin
	name = "Vitamin"
	id = "vitamin"
	description = "All the best vitamins, minerals, and carbohydrates the body needs in pure form."

	brute_heal = 1
	burn_heal = 1

/datum/reagent/consumable/nutriment/vitamin/on_mob_life(mob/living/M)
	if(M.satiety < 600)
		M.satiety += 30
	. = ..()

/datum/reagent/consumable/sugar
	name = "Sugar"
	id = "sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255
	taste_mult = 1.5 // stop sugar drowning out other flavours
	nutriment_factor = 10 * REAGENTS_METABOLISM
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 200 // Hyperglycaemic shock
	taste_description = "sweetness"

/datum/reagent/consumable/sugar/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>You go into hyperglycaemic shock! Lay off the twinkies!</span>")
	M.AdjustSleeping(30, 0)
	. = 1

/datum/reagent/consumable/sugar/overdose_process(mob/living/M)
	M.AdjustSleeping(3, 0)
	..()
	. = 1

/datum/reagent/consumable/virus_food
	name = "Virus Food"
	id = "virusfood"
	description = "A mixture of water and milk. Virus cells can use this mixture to reproduce."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" // rgb: 137, 150, 19
	taste_description = "watery milk"

/datum/reagent/consumable/soysauce
	name = "Soysauce"
	id = "soysauce"
	description = "A salty sauce made from the soy plant."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" // rgb: 121, 35, 0
	taste_description = "umami"

/datum/reagent/consumable/ketchup
	name = "Ketchup"
	id = "ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "ketchup"


/datum/reagent/consumable/capsaicin
	name = "Capsaicin Oil"
	id = "capsaicin"
	description = "This is what makes chilis hot."
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "hot peppers"
	taste_mult = 1.5

/datum/reagent/consumable/capsaicin/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 15)
			M.bodytemperature += 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("cryostylane"))
				holder.remove_reagent("cryostylane", 5)
			if(isslime(M))
				M.bodytemperature += rand(5,20)
		if(15 to 25)
			M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(10,20)
		if(25 to 35)
			M.bodytemperature += 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(15,20)
		if(35 to INFINITY)
			M.bodytemperature += 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(20,25)
	..()

/datum/reagent/consumable/frostoil
	name = "Frost Oil"
	id = "frostoil"
	description = "A special oil that noticably chills the body. Extracted from Icepeppers and slimes."
	color = "#8BA6E9" // rgb: 139, 166, 233
	taste_description = "mint"

/datum/reagent/consumable/frostoil/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 15)
			M.bodytemperature -= 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 5)
			if(isslime(M))
				M.bodytemperature -= rand(5,20)
		if(15 to 25)
			M.bodytemperature -= 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature -= rand(10,20)
		if(25 to 35)
			M.bodytemperature -= 30 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				M.bodytemperature -= rand(15,20)
		if(35 to INFINITY)
			M.bodytemperature -= 40 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(5))
				M.emote("shiver")
			if(isslime(M))
				M.bodytemperature -= rand(20,25)
	..()

/datum/reagent/consumable/frostoil/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 5)
		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(15,30))
	if(reac_volume >= 1) // Make Freezy Foam and anti-fire grenades!
		if(isopenturf(T))
			var/turf/open/OT = T
			OT.MakeSlippery(wet_setting=TURF_WET_ICE, min_wet_time=10, wet_time_to_add=reac_volume) // Is less effective in high pressure/high heat capacity environments. More effective in low pressure.
			OT.air.temperature -= MOLES_CELLSTANDARD*100*reac_volume/OT.air.heat_capacity() // reduces environment temperature by 5K per unit.

/datum/reagent/consumable/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	description = "A chemical agent used for self-defense and in police work."
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "scorching agony"

/datum/reagent/consumable/condensedcapsaicin/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!ishuman(M) && !ismonkey(M))
		return

	var/mob/living/carbon/victim = M
	if(method == TOUCH || method == VAPOR)
		//check for protection
		var/mouth_covered = 0
		var/eyes_covered = 0
		var/obj/item/safe_thing = null

		//monkeys and humans can have masks
		if( victim.wear_mask )
			if ( victim.wear_mask.flags_cover & MASKCOVERSEYES )
				eyes_covered = 1
				safe_thing = victim.wear_mask
			if ( victim.wear_mask.flags_cover & MASKCOVERSMOUTH )
				mouth_covered = 1
				safe_thing = victim.wear_mask

		//only humans can have helmets and glasses
		if(ishuman(victim))
			var/mob/living/carbon/human/H = victim
			if( H.head )
				if ( H.head.flags_cover & MASKCOVERSEYES )
					eyes_covered = 1
					safe_thing = H.head
				if ( H.head.flags_cover & MASKCOVERSMOUTH )
					mouth_covered = 1
					safe_thing = H.head
			if(H.glasses)
				eyes_covered = 1
				if ( !safe_thing )
					safe_thing = H.glasses

		//actually handle the pepperspray effects
		if ( eyes_covered && mouth_covered )
			return
		else if ( mouth_covered )	// Reduced effects if partially protected
			if(prob(5))
				victim.emote("scream")
			victim.blur_eyes(3)
			victim.blind_eyes(2)
			victim.confused = max(M.confused, 3)
			victim.damageoverlaytemp = 60
			victim.Weaken(3)
			victim.drop_item()
			return
		else if ( eyes_covered ) // Eye cover is better than mouth cover
			victim.blur_eyes(3)
			victim.damageoverlaytemp = 30
			return
		else // Oh dear :D
			if(prob(5))
				victim.emote("scream")
			victim.blur_eyes(5)
			victim.blind_eyes(3)
			victim.confused = max(M.confused, 6)
			victim.damageoverlaytemp = 75
			victim.Weaken(5)
			victim.drop_item()
		victim.update_damage_hud()

/datum/reagent/consumable/condensedcapsaicin/on_mob_life(mob/living/M)
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
	..()

/datum/reagent/consumable/sodiumchloride
	name = "Table Salt"
	id = "sodiumchloride"
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255,255,255
	taste_description = "salt"

/datum/reagent/consumable/sodiumchloride/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!istype(M))
		return
	if(M.has_bane(BANE_SALT))
		M.mind.disrupt_spells(-200)

/datum/reagent/consumable/sodiumchloride/reaction_turf(turf/T, reac_volume) //Creates an umbra-blocking salt pile
	if(!istype(T))
		return
	if(reac_volume < 1)
		return
	new/obj/effect/decal/cleanable/salt(T)

/datum/reagent/consumable/blackpepper
	name = "Black Pepper"
	id = "blackpepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = SOLID
	// no color (ie, black)
	taste_description = "pepper"

/datum/reagent/consumable/coco
	name = "Coco Powder"
	id = "cocoa"
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "bitterness"

/datum/reagent/consumable/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And coco beans."
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16
	taste_description = "creamy chocolate"
	glass_icon_state  = "chocolateglass"
	glass_name = "glass of chocolate"
	glass_desc = "Tasty."

/datum/reagent/consumable/hot_coco/on_mob_life(mob/living/M)
	if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()

/datum/reagent/mushroomhallucinogen
	name = "Mushroom Hallucinogen"
	id = "mushroomhallucinogen"
	description = "A strong hallucinogenic drug derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	taste_description = "mushroom"

/datum/reagent/mushroomhallucinogen/on_mob_life(mob/living/M)
	if(!M.slurring)
		M.slurring = 1
	switch(current_cycle)
		if(1 to 5)
			M.Dizzy(5)
			M.set_drugginess(30)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Jitter(10)
			M.Dizzy(10)
			M.set_drugginess(35)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if (10 to INFINITY)
			M.Jitter(20)
			M.Dizzy(20)
			M.set_drugginess(40)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	..()

/datum/reagent/consumable/sprinkles
	name = "Sprinkles"
	id = "sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	color = "#FF00FF" // rgb: 255, 0, 255
	taste_description = "childhood whimsy"

/datum/reagent/consumable/sprinkles/on_mob_life(mob/living/M)
	if(ishuman(M) && M.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
		M.heal_bodypart_damage(1,1, 0)
		. = 1
	..()

/datum/reagent/consumable/cornoil
	name = "Corn Oil"
	id = "cornoil"
	description = "An oil derived from various types of corn."
	nutriment_factor = 20 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "slime"

/datum/reagent/consumable/cornoil/reaction_turf(turf/open/T, reac_volume)
	if (!istype(T))
		return
	T.MakeSlippery(min_wet_time = 10, wet_time_to_add = reac_volume*2)
	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/consumable/enzyme
	name = "Universal Enzyme"
	id = "enzyme"
	description = "A universal enzyme used in the preperation of certain chemicals and foods."
	color = "#365E30" // rgb: 54, 94, 48
	taste_description = "sweetness"

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	id = "dry_ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	reagent_state = SOLID
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "dry and cheap noodles"

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "wet and cheap noodles"

/datum/reagent/consumable/hot_ramen/on_mob_life(mob/living/M)
	if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()

/datum/reagent/consumable/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "wet and cheap noodles on fire"

/datum/reagent/consumable/hell_ramen/on_mob_life(mob/living/M)
	M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
	..()

/datum/reagent/consumable/flour
	name = "Flour"
	id = "flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 0, 0, 0
	taste_description = "chalky wheat"

/datum/reagent/consumable/flour/reaction_turf(turf/T, reac_volume)
	if(!isspaceturf(T))
		var/obj/effect/decal/cleanable/reagentdecal = new/obj/effect/decal/cleanable/flour(T)
		reagentdecal.reagents.add_reagent("flour", reac_volume)

/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	id = "cherryjelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	color = "#801E28" // rgb: 128, 30, 40
	taste_description = "cherry"

/datum/reagent/consumable/bluecherryjelly
	name = "Blue Cherry Jelly"
	id = "bluecherryjelly"
	description = "Blue and tastier kind of cherry jelly."
	color = "#00F0FF"
	taste_description = "blue cherry"

/datum/reagent/consumable/rice
	name = "Rice"
	id = "rice"
	description = "tiny nutritious grains"
	reagent_state = SOLID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0
	taste_description = "rice"

/datum/reagent/consumable/vanilla
	name = "Vanilla Powder"
	id = "vanilla"
	description = "A fatty, bitter paste made from vanilla pods."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#FFFACD"
	taste_description = "vanilla"

/datum/reagent/consumable/eggyolk
	name = "Egg Yolk"
	id = "eggyolk"
	description = "It's full of protein."
	color = "#FFB500"
	taste_description = "egg"

/datum/reagent/consumable/corn_starch
	name = "Corn Starch"
	id = "corn_starch"
	description = "A slippery solution."
	color = "#C8A5DC"
	taste_description = "slime"

/datum/reagent/consumable/corn_syrup
	name = "Corn Syrup"
	id = "corn_syrup"
	description = "Decays into sugar."
	color = "#C8A5DC"
	metabolization_rate = 3 * REAGENTS_METABOLISM
	taste_description = "sweet slime"

/datum/reagent/consumable/corn_syrup/on_mob_life(mob/living/M)
	holder.add_reagent("sugar", 3)
	..()

/datum/reagent/consumable/honey
	name = "honey"
	id = "honey"
	description = "Sweet sweet honey, decays into sugar and has natural healing properties."
	color = "#d3a308"
	nutriment_factor = 15 * REAGENTS_METABOLISM
	metabolization_rate = 1 * REAGENTS_METABOLISM
	taste_description = "sweetness"

/datum/reagent/consumable/honey/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar",3)
	if(prob(55))
		M.adjustBruteLoss(-1*REM, 0)
		M.adjustFireLoss(-1*REM, 0)
		M.adjustOxyLoss(-1*REM, 0)
		M.adjustToxLoss(-1*REM, 0)
	..()

/datum/reagent/consumable/mayonnaise
	name = "Mayonnaise"
	id = "mayonnaise"
	description = "An white and oily mixture of mixed egg yolks."
	color = "#DFDFDF"
	taste_description = "mayonnaise"

////Lavaland Flora Reagents////


/datum/reagent/consumable/entpoly
	name = "Entropic Polypnium"
	id = "entpoly"
	description = "An ichor, derived from a certain mushroom, makes for a bad time."
	color = "#1d043d"
	taste_description = "bitter mushroom"

/datum/reagent/consumable/entpoly/on_mob_life(mob/living/M)
	if(current_cycle >= 10)
		M.Paralyse(2, 0)
		. = 1
	if(prob(20))
		M.losebreath += 4
		M.adjustBrainLoss(2*REM)
		M.adjustToxLoss(3*REM,0)
		M.adjustStaminaLoss(10*REM,0)
		M.blur_eyes(5)
		. = TRUE
	..()

/datum/reagent/consumable/tinlux
	name = "Tinea Luxor"
	id = "tinlux"
	description = "A stimulating ichor which causes luminescent fungi to grow on the skin. "
	color = "#b5a213"
	taste_description = "tingling mushroom"

/datum/reagent/consumable/tinlux/reaction_mob(mob/living/M)
	M.set_light(2)

/datum/reagent/consumable/tinlux/on_mob_delete(mob/living/M)
	M.set_light(-2)

/datum/reagent/consumable/vitfro
	name = "Vitrium Froth"
	id = "vitfro"
	description = "A bubbly paste that heals wounds of the skin."
	color = "#d3a308"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "fruity mushroom"

/datum/reagent/consumable/vitfro/on_mob_life(mob/living/M)
	if(prob(80))
		M.adjustBruteLoss(-1*REM, 0)
		M.adjustFireLoss(-1*REM, 0)
		. = TRUE
	..()
