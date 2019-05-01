//predominantly positive traits
//this file is named weirdly so that positive traits are listed above negative ones

/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "You become drunk more slowly and suffer fewer drawbacks from alcohol."
	value = 1
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>You feel like you could drink a whole keg!</span>"
	lose_text = "<span class='danger'>You don't feel as resistant to alcohol anymore. Somehow.</span>"

/datum/quirk/apathetic
	name = "Apathetic"
	desc = "You just don't care as much as other people. That's nice to have in a place like this, I guess."
	value = 1
	mood_quirk = TRUE

/datum/quirk/apathetic/add()
	GET_COMPONENT_FROM(mood, /datum/component/mood, quirk_holder)
	if(mood)
		mood.mood_modifier -= 0.2

/datum/quirk/apathetic/remove()
	if(quirk_holder)
		GET_COMPONENT_FROM(mood, /datum/component/mood, quirk_holder)
		if(mood)
			mood.mood_modifier += 0.2

/datum/quirk/drunkhealing
	name = "Drunken Resilience"
	desc = "Nothing like a good drink to make you feel on top of the world. Whenever you're drunk, you slowly recover from injuries."
	value = 2
	mob_trait = TRAIT_DRUNK_HEALING
	gain_text = "<span class='notice'>You feel like a drink would do you good.</span>"
	lose_text = "<span class='danger'>You no longer feel like drinking would ease your pain.</span>"
	medical_record_text = "Patient has unusually efficient liver metabolism and can slowly regenerate wounds by drinking alcoholic beverages."

/datum/quirk/empath
	name = "Empath"
	desc = "Whether it's a sixth sense or careful study of body language, it only takes you a quick glance at someone to understand how they feel."
	value = 2
	mob_trait = TRAIT_EMPATH
	gain_text = "<span class='notice'>You feel in tune with those around you.</span>"
	lose_text = "<span class='danger'>You feel isolated from others.</span>"

/datum/quirk/freerunning
	name = "Freerunning"
	desc = "You're great at quick moves! You can climb tables more quickly."
	value = 2
	mob_trait = TRAIT_FREERUNNING
	gain_text = "<span class='notice'>You feel lithe on your feet!</span>"
	lose_text = "<span class='danger'>You feel clumsy again.</span>"

/datum/quirk/friendly
	name = "Friendly"
	desc = "You give the best hugs, especially when you're in the right mood."
	value = 1
	mob_trait = TRAIT_FRIENDLY
	gain_text = "<span class='notice'>You want to hug someone.</span>"
	lose_text = "<span class='danger'>You no longer feel compelled to hug others.</span>"
	mood_quirk = TRUE

/datum/quirk/jolly
	name = "Jolly"
	desc = "You sometimes just feel happy, for no reason at all."
	value = 1
	mob_trait = TRAIT_JOLLY
	mood_quirk = TRUE

/datum/quirk/light_step
	name = "Light Step"
	desc = "You walk with a gentle step; stepping on sharp objects is quieter, less painful and you won't leave footprints behind you."
	value = 1
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = "<span class='notice'>You walk with a little more litheness.</span>"
	lose_text = "<span class='danger'>You start tromping around like a barbarian.</span>"

/datum/quirk/musician
	name = "Musician"
	desc = "You can tune handheld musical instruments to play melodies that clear certain negative effects and soothe the soul."
	value = 1
	mob_trait = TRAIT_MUSICIAN
	gain_text = "<span class='notice'>You know everything about musical instruments.</span>"
	lose_text = "<span class='danger'>You forget how musical instruments work.</span>"

/datum/quirk/musician/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/choice_beacon/music/B = new(get_turf(H))
	H.put_in_hands(B)
	H.equip_to_slot(B, SLOT_IN_BACKPACK)
	H.regenerate_icons()

/datum/quirk/night_vision
	name = "Night Vision"
	desc = "You can see slightly more clearly in full darkness than most people."
	value = 1
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = "<span class='notice'>The shadows seem a little less dark.</span>"
	lose_text = "<span class='danger'>Everything seems a little darker.</span>"

/datum/quirk/night_vision/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/eyes/eyes = H.getorgan(/obj/item/organ/eyes)
	if(!eyes || eyes.lighting_alpha)
		return
	eyes.Insert(H) //refresh their eyesight and vision

/datum/quirk/photographer
	name = "Photographer"
	desc = "You know how to handle a camera, shortening the delay between each shot."
	value = 1
	mob_trait = TRAIT_PHOTOGRAPHER
	gain_text = "<span class='notice'>You know everything about photography.</span>"
	lose_text = "<span class='danger'>You forget how photo cameras work.</span>"

/datum/quirk/photographer/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/camera/camera = new(get_turf(H))
	H.put_in_hands(camera)
	H.equip_to_slot(camera, SLOT_NECK)
	H.regenerate_icons()

/datum/quirk/selfaware
	name = "Self-Aware"
	desc = "You know your body well, and can accurately assess the extent of your wounds."
	value = 2
	mob_trait = TRAIT_SELF_AWARE

/datum/quirk/skittish
	name = "Skittish"
	desc = "You can conceal yourself in danger. Ctrl-shift-click a closed locker to jump into it, as long as you have access."
	value = 2
	mob_trait = TRAIT_SKITTISH

/datum/quirk/spiritual
	name = "Spiritual"
	desc = "You hold a spiritual belief, whether in God, nature or the arcane rules of the universe. You gain comfort from the presence of holy people, and believe that your prayers are more special than others."
	value = 1
	mob_trait = TRAIT_SPIRITUAL
	gain_text = "<span class='notice'>You have faith in a higher power.</span>"
	lose_text = "<span class='danger'>You lose faith!</span>"

/datum/quirk/spiritual/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	H.equip_to_slot_or_del(new /obj/item/storage/fancy/candle_box(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), SLOT_IN_BACKPACK)

/datum/quirk/spiritual/on_process()
	var/comforted = FALSE
	for(var/mob/living/L in oview(5, quirk_holder))
		if(L.mind && L.mind.isholy && L.stat == CONSCIOUS)
			comforted = TRUE
			break
	if(comforted)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "religious_comfort", /datum/mood_event/religiously_comforted)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "religious_comfort")

/datum/quirk/tagger
	name = "Tagger"
	desc = "You're an experienced artist. While drawing graffiti, you can get twice as many uses out of drawing supplies."
	value = 1
	mob_trait = TRAIT_TAGGER
	gain_text = "<span class='notice'>You know how to tag walls efficiently.</span>"
	lose_text = "<span class='danger'>You forget how to tag walls properly.</span>"

/datum/quirk/tagger/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/toy/crayon/spraycan/spraycan = new(get_turf(H))
	H.put_in_hands(spraycan)
	H.equip_to_slot(spraycan, SLOT_IN_BACKPACK)
	H.regenerate_icons()

/datum/quirk/voracious
	name = "Voracious"
	desc = "Nothing gets between you and your food. You eat faster and can binge on junk food! Being fat suits you just fine."
	value = 1
	mob_trait = TRAIT_VORACIOUS
	gain_text = "<span class='notice'>You feel HONGRY.</span>"
	lose_text = "<span class='danger'>You no longer feel HONGRY.</span>"

/datum/quirk/neet
	name = "NEET"
	desc = "For some reason you qualified for social welfare and you don't really care about your own personal hygiene."
	value = 1
	mob_trait = TRAIT_NEET
	gain_text = "<span class='notice'>You feel useless to society.</span>"
	lose_text = "<span class='danger'>You no longer feel useless to society.</span>"
	mood_quirk = TRUE

/datum/quirk/neet/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/bank_account/D = H.get_bank_account()
	if(!D) //if their current mob doesn't have a bank account, likely due to them being a special role (ie nuke op)
		return
	D.welfare = TRUE

/datum/quirk/prepared	//thanks to the coder of "Family Heirloom!" -Len
	name = "Came Prepared"
	desc = "You knew what job you were getting at the station, and brought something helpful to your new job!"
	value = 3
	var/obj/item/prepared
	var/where

/datum/quirk/prepared/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/prepared_job
	switch(quirk_holder.mind.assigned_role)
		//Service jobs
		if("Clown")
			prepared_job = pick(/obj/item/reagent_containers/spray/waterflower/lube, /obj/item/reagent_containers/glass/bottle/fake_gbs, /obj/item/disk/nuclear/fake, /obj/item/card/emagfake/honkmag)
		if("Mime")
			prepared_job = pick(/obj/item/reagent_containers/food/snacks/baguette, /obj/item/card/emagfake/honkmag, /obj/item/disk/nuclear/fake)
		if("Janitor")
			prepared_job = pick(/obj/item/storage/bag/trash, /obj/item/reagent_containers/spray/cleaner, /obj/item/janiupgrade)
		if("Cook")
			prepared_job = pick(/obj/item/kitchen/knife/butcher, /obj/item/kitchen/rollingpin,/obj/item/reagent_containers/food/snacks/dough)
		if("Botanist")
			prepared_job = pick(/obj/item/multitool, /obj/item/reagent_containers/glass/bottle/mutagen, /obj/item/seeds/random, /obj/item/circuitboard/machine/chem_dispenser)
		if("Bartender")
			prepared_job = pick(/obj/item/storage/box/stunslug, /obj/item/storage/box/rubbershot)
		if("Curator")
			prepared_job = pick(/obj/item/stack/sheet/mineral/wood, /obj/item/pen/fourcolor, /obj/item/pen/invisible)
		if("Assistant")
			prepared_job = pick(/obj/item/stack/tile/fakepit, /obj/item/storage/box/fakesyndiesuit, /obj/item/stack/tile/fakespace)
		//Security/Command
		if("Captain")
			prepared_job = pick(/obj/item/reagent_containers/food/drinks/flask/gold, /obj/item/gun/ballistic/automatic/pistol/deagle/gold, /obj/item/gun/energy/e_gun/stun)
		if("Head of Security")
			prepared_job = pick(/obj/item/gun/energy/e_gun/stun, /obj/item/melee/baton/loaded, /obj/item/clothing/mask/gas)
		if("Warden")
			prepared_job = pick(/obj/item/gun/energy/e_gun/stun, /obj/item/melee/baton/loaded, /obj/item/clothing/mask/gas)
		if("Security Officer")
			prepared_job = pick(/obj/item/gun/energy/e_gun/stun, /obj/item/melee/baton/loaded, /obj/item/clothing/mask/gas)
		if("Detective")
			prepared_job = pick(/obj/item/reagent_containers/food/drinks/bottle/whiskey, /obj/item/gun/energy/e_gun/stun, /obj/item/reagent_containers/food/drinks/flask/gold)
		if("Lawyer")
			prepared_job = pick(/obj/item/gavelhammer, /obj/item/gun/energy/e_gun/stun, /obj/item/clothing/mask/gas)
		//RnD
		if("Research Director")
			prepared_job = pick(subtypesof(/obj/item/slime_extract), /obj/item/clothing/mask/gas/welding)
		if("Scientist")
			prepared_job = pick(/obj/item/clothing/mask/gas/welding, /obj/item/stack/sheet/mineral/plasma, /obj/item/storage/part_replacer)
		if("Roboticist")
			prepared_job = pick(/obj/item/borg/upgrade/rename, /obj/item/borg/upgrade/restart, /obj/item/borg/upgrade/selfrepair, /obj/item/stack/sheet/mineral/plasma)
		//Medical
		if("Chief Medical Officer")
			prepared_job = pick(/obj/item/reagent_containers/pill/patch/synthflesh, /obj/item/storage/pill_bottle, /obj/item/gun/syringe/rapidsyringe)
		if("Medical Doctor")
			prepared_job = pick(/obj/item/storage/pill_bottle, /obj/item/gun/syringe, /obj/item/reagent_containers/pill/patch/synthflesh)
		if("Chemist")
			prepared_job = pick(/obj/item/gun/syringe, /obj/item/stock_parts/cell/high)
		if("Virologist")
			prepared_job =  pick(/obj/item/gun/syringe,/obj/item/stack/sheet/mineral/plasma, /obj/item/stack/sheet/mineral/uranium, /obj/item/reagent_containers/glass/bottle/random_virus)
		//Engineering
		if("Chief Engineer")
			prepared_job = pick(/obj/item/reagent_containers/food/drinks/beer, /obj/item/clothing/mask/gas/welding, /obj/item/reagent_containers/food/drinks/flask/gold)
		if("Station Engineer")
			prepared_job = pick(/obj/item/clothing/suit/space/hardsuit/engine,/obj/item/reagent_containers/food/drinks/beer/light)
		if("Atmospheric Technician")
			prepared_job = pick(/obj/item/clothing/suit/space/hardsuit/engine/atmos, /obj/item/reagent_containers/food/drinks/beer/light)
		//Supply
		if("Quartermaster")
			prepared_job = pick(/obj/item/stamp, /obj/item/reagent_containers/food/drinks/beer, /obj/item/banner/cargo)
		if("Cargo Technician")
			prepared_job = pick(/obj/item/stamp, /obj/item/reagent_containers/food/drinks/beer, /obj/item/banner/cargo/mundane)
		if("Shaft Miner")
			prepared_job = pick(/obj/item/borg/upgrade/modkit/range, /obj/item/borg/upgrade/modkit/damage, /obj/item/borg/upgrade/modkit/aoe/mobs, /obj/item/storage/bag/ore/holding, /obj/item/resonator)

	prepared = new prepared_job(get_turf(quirk_holder))
	var/list/slots = list(
		"in your left pocket" = SLOT_L_STORE,
		"in your right pocket" = SLOT_R_STORE,
		"in your backpack" = SLOT_IN_BACKPACK
		)
	where = H.equip_in_one_of_slots(prepared, slots, FALSE) || "at your feet"

/datum/quirk/prepared/post_add()
	if(where == "in your backpack")
		var/mob/living/carbon/human/H = quirk_holder
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

	to_chat(quirk_holder, "<span class='boldnotice'>You thought a [prepared.name] might be useful, so you hid one [where].</span>")
