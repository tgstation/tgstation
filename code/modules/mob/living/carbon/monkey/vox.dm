// Tiny green chickens from outer space

/mob/living/carbon/monkey/vox
	name = "chicken"
	voice_name = "chicken"
	icon_state = "chickengreen"
	speak_emote = list("clucks","croons")
	attack_text = "pecks"
	species_type = /mob/living/carbon/monkey/vox
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken
	canWearClothes = 0
	canWearGlasses = 0
	var/eggsleft
	var/eggcost = 250

/mob/living/carbon/monkey/vox/attack_hand(mob/living/carbon/human/M as mob)


	if((M.a_intent == I_HELP) && !(locked_to) && (isturf(src.loc)) && (M.get_active_hand() == null)) //Unless their location isn't a turf!
		scoop_up(M)

	..()


/mob/living/carbon/monkey/vox/New()

	..()
	setGender(NEUTER)
	dna.mutantrace = "vox"
	greaterform = "Vox"
	alien = 1
	add_language("Vox-pidgin")
	default_language = all_languages["Vox-pidgin"]
	eggsleft = rand(1,6)

/mob/living/carbon/monkey/vox/put_in_hand_check(var/obj/item/W) //Silly chicken, you don't have hands
	return 0


//Cant believe I'm doing this
/mob/living/carbon/monkey/vox/proc/lay_egg()
	if(!stat && nutrition > 250)
		visible_message("[src] [pick("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")]")
		nutrition -= eggcost
		eggsleft--
		var/obj/item/weapon/reagent_containers/food/snacks/egg/vox/E = new(get_turf(src))
		E.pixel_x = rand(-6,6)
		E.pixel_y = rand(-6,6)
		if(prob(25))
			processing_objects.Add(E)

/mob/living/carbon/monkey/vox/verb/layegg()
	set name = "Lay egg"
	set category = "IC"
	lay_egg()
	return

/mob/living/carbon/monkey/vox/proc/eggstats()
	stat(null, "Nutrition level - [nutrition]")
	stat(null, "Eggs left - [eggsleft]")

/mob/living/carbon/monkey/vox/Stat()
	..()
	if(statpanel("Status"))
		eggstats()