/datum/reagent/consumable/berryjuice/on_mob_life(mob/living/M)
	if(prob(25))
		M.reagents.add_reagent("vitamin",0.8)
	..()
	
/datum/reagent/consumable/watermelonjuice/on_mob_life(mob/living/M)
	M.adjustCloneLoss(-0.4, 0) //pretty slow, you're really better off using cryox/clonex
	. = 1
	..()
	
/datum/reagent/consumable/potato_juice/on_mob_life(mob/living/M)
	M.adjustStaminaLoss(-0.5*REM, 0)
	..()
	
/datum/reagent/consumable/cherryshake/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar",1.2)
	..()
	
/datum/reagent/consumable/bluecherryshake/reaction_mob(mob/living/M)
	M.reagents.add_reagent("sugar",2)
	..()
	
/datum/reagent/consumable/gibbfloats/on_mob_life(mob/living/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (8 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()
	. = 1
	
/datum/reagent/consumable/triple_citrus/on_mob_life(mob/living/M)
	if(M.getOxyLoss() && prob(75))
		M.adjustOxyLoss(-1, 0)
	if(M.getFireLoss() && prob(75))
		M.adjustFireLoss(-1, 0)
	if(M.getBruteLoss() && prob(75))
		M.adjustBruteLoss(-1, 0)
	. = 1
	..()
	
/datum/reagent/consumable/lean
    name = "Lean"
    id = "lean"
    description = "A bubbly, neon purple antitussive syrup"
    color = "#de72f9" //rgb: rgb(222, 103, 252)
    taste_description = "purple"
    glass_icon_state = "lean"
    glass_desc = "A huge cup full of drank."
    glass_name = "lean cup"
	 var/list/leanTalk = list("Sipping on some sizzurp, sip, sipping on some, sip..", "I'M LEANIN!!", "Drop some syrup in it, get on my waffle house!", "Dat purple stuff..", "We wuz.. sippin...", "Bup-bup-bup-bup...", "ME AND MY DRANK, ME AND MY DRANK!!!", "Pour you a glass, mane..", "...purple...", "Can't nobody sip mo' than me!")


/datum/reagent/consumable/lean/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		M.adjustBruteLoss(-1)
		M.set_drugginess(5)
		if(prob(2))
			playsound(get_turf(H), 'hippiestation/sound/misc/syrupSippin.ogg', 50, 1)
		if(prob(8))
			H.say(pick(leanTalk))
		if(prob(1))
			var/syrup_message = pick("You feel relaxed.", "You feel calmed.","You feel like melting into the floor.","The world moves slowly..")
			to_chat(H,"<span class='notice'>[syrup_message]</span>")
		if(prob(3))
			H.skin_tone = "african1"
			H.hair_style = "Big Afro"

	..()
