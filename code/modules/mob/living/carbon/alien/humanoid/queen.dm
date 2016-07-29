<<<<<<< HEAD
/mob/living/carbon/alien/humanoid/royal
	//Common stuffs for Praetorian and Queen
	icon = 'icons/mob/alienqueen.dmi'
	status_flags = 0
	ventcrawler = 0 //pull over that ass too fat
	unique_name = 0
	pixel_x = -16
	bubble_icon = "alienroyal"
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER //above most mobs, but below speechbubbles
	pressure_resistance = 200 //Because big, stompy xenos should not be blown around like paper.
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno = 20, /obj/item/stack/sheet/animalhide/xeno = 3)

	var/alt_inhands_file = 'icons/mob/alienqueen.dmi'

/mob/living/carbon/alien/humanoid/royal/can_inject()
	return 0

/mob/living/carbon/alien/humanoid/royal/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 400
	health = 400
	icon_state = "alienq"


/mob/living/carbon/alien/humanoid/royal/queen/New()
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/royal/queen/Q in living_mob_list)
		if(Q == src)
			continue
		if(Q.stat == DEAD)
			continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name

	internal_organs += new /obj/item/organ/alien/plasmavessel/large/queen
	internal_organs += new /obj/item/organ/alien/resinspinner
	internal_organs += new /obj/item/organ/alien/acid
	internal_organs += new /obj/item/organ/alien/neurotoxin
	internal_organs += new /obj/item/organ/alien/eggsac
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/repulse/xeno(src))
	AddAbility(new/obj/effect/proc_holder/alien/royal/queen/promote())
	..()

/mob/living/carbon/alien/humanoid/royal/queen/movement_delay()
	. = ..()
	. += 5

//Queen verbs
/obj/effect/proc_holder/alien/lay_egg
	name = "Lay Egg"
	desc = "Lay an egg to produce huggers to impregnate prey with."
	plasma_cost = 75
	check_turf = 1
	action_icon_state = "alien_egg"

/obj/effect/proc_holder/alien/lay_egg/fire(mob/living/carbon/user)
	if(locate(/obj/structure/alien/egg) in get_turf(user))
		user << "There's already an egg here."
		return 0
	user.visible_message("<span class='alertalien'>[user] has laid an egg!</span>")
	new /obj/structure/alien/egg(user.loc)
	return 1

//Button to let queen choose her praetorian.
/obj/effect/proc_holder/alien/royal/queen/promote
	name = "Create Royal Parasite"
	desc = "Produce a royal parasite to grant one of your children the honor of being your Praetorian."
	plasma_cost = 500 //Plasma cost used on promotion, not spawning the parasite.

	action_icon_state = "alien_queen_promote"



/obj/effect/proc_holder/alien/royal/queen/promote/fire(mob/living/carbon/alien/user)
	var/obj/item/queenpromote/prom
	if(get_alien_type(/mob/living/carbon/alien/humanoid/royal/praetorian/))
		user << "<span class='noticealien'>You already have a Praetorian!</span>"
		return 0
	else
		for(prom in user)
			user << "<span class='noticealien'>You discard [prom].</span>"
			qdel(prom)
			return 0

		prom = new (user.loc)
		if(!user.put_in_active_hand(prom, 1))
			user << "<span class='warning'>You must empty your hands before preparing the parasite.</span>"
			return 0
		else //Just in case telling the player only once is not enough!
			user << "<span class='noticealien'>Use the royal parasite on one of your children to promote her to Praetorian!</span>"
	return 0

/obj/item/queenpromote
	name = "\improper royal parasite"
	desc = "Inject this into one of your grown children to promote her to a Praetorian!"
	icon_state = "alien_medal"
	flags = ABSTRACT|NODROP|DROPDEL
	icon = 'icons/mob/alien.dmi'

/obj/item/queenpromote/attack(mob/living/M, mob/living/carbon/alien/humanoid/user)
	if(!isalienadult(M) || istype(M, /mob/living/carbon/alien/humanoid/royal))
		user << "<span class='noticealien'>You may only use this with your adult, non-royal children!</span>"
		return
	if(get_alien_type(/mob/living/carbon/alien/humanoid/royal/praetorian/))
		user << "<span class='noticealien'>You already have a Praetorian!</span>"
		return

	var/mob/living/carbon/alien/humanoid/A = M
	if(A.stat == CONSCIOUS && A.mind && A.key)
		if(!user.usePlasma(500))
			user << "<span class='noticealien'>You must have 500 plasma stored to use this!</span>"
			return

		A << "<span class='noticealien'>The queen has granted you a promotion to Praetorian!</span>"
		user.visible_message("<span class='alertalien'>[A] begins to expand, twist and contort!</span>")
		var/mob/living/carbon/alien/humanoid/royal/praetorian/new_prae = new (A.loc)
		A.mind.transfer_to(new_prae)
		qdel(A)
		qdel(src)
		return
	else
		user << "<span class='warning'>This child must be alert and responsive to become a Praetorian!</span>"

/obj/item/queenpromote/attack_self(mob/user)
	user << "<span class='noticealien'>You discard [src].</span>"
	qdel(src)

//:^)
/datum/action/innate/maid
	name = "Maidify"
	button_icon_state = "alien_queen_maidify"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS|AB_CHECK_LYING
	background_icon_state = "bg_alien"

/datum/action/innate/maid/Activate()
	var/mob/living/carbon/alien/humanoid/royal/queen/A = owner
	A.maidify()
	active = TRUE

/datum/action/innate/maid/Deactivate()
	var/mob/living/carbon/alien/humanoid/royal/queen/A = owner
	A.unmaidify()
	active = FALSE



/mob/living/carbon/alien/humanoid/royal/queen/proc/maidify()
	name = "alien queen maid"
	desc = "Lusty, Sexy"
	icon_state = "alienqmaid"
	caste = "qmaid"
	update_icons()

/mob/living/carbon/alien/humanoid/royal/queen/proc/unmaidify()
	name = "alien queen"
	desc = ""
	icon_state = "alienq"
	caste = "q"
	update_icons()
=======
/mob/living/carbon/alien/humanoid/queen
	name = "alien queen" //The alien queen, not Alien Queen. Even if there's only one at a time
	caste = "q"
	maxHealth = 300
	health = 300
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	heal_rate = 5
	plasma_rate = 20

/mob/living/carbon/alien/humanoid/queen/movement_delay()
	var/tally = 5 + move_delay_add + config.alien_delay //Queens are slow as fuck

	var/turf/T = loc
	if(istype(T))
		tally = T.adjust_slowdown(src, tally)

	return tally

/mob/living/carbon/alien/humanoid/queen/New()
	create_reagents(100)

	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
		if(Q == src)
			continue
		if(Q.stat == DEAD)
			continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid,/mob/living/carbon/alien/humanoid/proc/neurotoxin,/mob/living/carbon/alien/humanoid/proc/resin)
	..()
	add_language(LANGUAGE_XENO)
	default_language = all_languages[LANGUAGE_XENO]
	verbs -= /mob/living/carbon/alien/verb/ventcrawl


/mob/living/carbon/alien/humanoid/queen

	handle_regular_hud_updates()

		..() //-Yvarov

		if(src.healths)
			if(src.stat != 2)
				switch(health)
					if(300 to INFINITY)
						src.healths.icon_state = "health0"
					if(200 to 300)
						src.healths.icon_state = "health1"
					if(125 to 200)
						src.healths.icon_state = "health2"
					if(75 to 125)
						src.healths.icon_state = "health3"
					if(0 to 75)
						src.healths.icon_state = "health4"
					else
						src.healths.icon_state = "health5"
			else
				src.healths.icon_state = "health6"


//Queen verbs
/mob/living/carbon/alien/humanoid/queen/verb/lay_egg()


	set name = "Lay Egg (75)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"

	if(locate(/obj/effect/alien/egg) in get_turf(src))
		to_chat(src, "<span class='warning'>There's already an egg here.</span>")
		return

	if(powerc(75, 1))//Can't plant eggs on spess tiles. That's silly.
		adjustToxLoss(-75)
		visible_message("<span class='alien'>[src] has laid an egg!</span>")
		stat_collection.xeno.eggs_laid++
		new /obj/effect/alien/egg(loc)
	return


/mob/living/carbon/alien/humanoid/queen/large
	icon = 'icons/mob/giantmobs.dmi'
	icon_state = "queen_s"
	pixel_x = -16

/mob/living/carbon/alien/humanoid/queen/large/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays.len = 0
	if(lying)
		if(resting)					icon_state = "queen_sleep"
		else						icon_state = "queen_l"
		for(var/image/I in overlays_lying)
			overlays += I
	else
		icon_state = "queen_s"
		for(var/image/I in overlays_standing)
			overlays += I
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
