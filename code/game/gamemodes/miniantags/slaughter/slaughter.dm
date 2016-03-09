//////////////////The Monster

/mob/living/simple_animal/slaughter
	name = "slaughter demon"
	real_name = "slaughter demon"
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	speed = 1
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list("slaughter")
	attacktext = "wildly tears into"
	maxHealth = 200
	health = 200
	healable = 0
	environment_smash = 1
	melee_damage_lower = 30
	melee_damage_upper = 30
	see_in_dark = 8
	var/boost = 0
	bloodcrawl = BLOODCRAWL_EAT
	see_invisible = SEE_INVISIBLE_MINIMUM
	var/list/consumed_mobs = list()
	var/playstyle_string = "<B><font size=3 color='red'>You are a slaughter demon,</font> a terrible creature from another realm. You have a single desire: To kill.  \
							You may use the \"Blood Crawl\" ability near blood pools to travel through them, appearing and dissaapearing from the station at will. \
							Pulling a dead or unconscious mob while you enter a pool will pull them in with you, allowing you to feast and regain your health. \
							You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish. </B>"

/mob/living/simple_animal/slaughter/New()
	..()
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/slaughter))
		bloodspell.phased = 1

/mob/living/simple_animal/slaughter/Life()
	..()
	if(boost<world.time)
		speed = 1
	else
		speed = 0

/mob/living/simple_animal/slaughter/death()
	..(1)
	new /obj/effect/decal/cleanable/blood (get_turf(src))
	var/obj/effect/decal/cleanable/blood/innards = new (get_turf(src))
	innards.icon = 'icons/obj/surgery.dmi'
	innards.icon_state = "innards"
	innards.name = "pile of viscera"
	innards.desc = "A repulsive pile of guts and gore."
	new /obj/item/organ/internal/heart/demon (src.loc)
	playsound(get_turf(src),'sound/magic/demon_dies.ogg', 200, 1)
	visible_message("<span class='danger'>[src] screams in anger as it collapses into a puddle of viscera, its most recent meals spilling out of it.</span>")
	for(var/mob/living/M in consumed_mobs)
		M.loc = get_turf(src)
	ghostize()
	qdel(src)
	return


/mob/living/simple_animal/slaughter/phasein()
	. = ..()
	speed = 0
	boost = world.time + 60


//The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl
/obj/item/organ/internal/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart"
	origin_tech = "combat=5;biotech=8"

/obj/item/organ/internal/heart/demon/update_icon()
	return //always beating visually

/obj/item/organ/internal/heart/demon/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message("<span class='warning'>[user] raises [src] to their mouth and tears into it with their teeth!</span>", \
						 "<span class='danger'>An unnatural hunger consumes you. You raise [src] your mouth and devour it!</span>")
	playsound(user, 'sound/magic/Demon_consume.ogg', 50, 1)
	for(var/obj/effect/proc_holder/spell/knownspell in user.mind.spell_list)
		if(knownspell.type == /obj/effect/proc_holder/spell/bloodcrawl)
			user <<"<span class='warning'>...and you don't feel any different.</span>"
			qdel(src)
			return
	user.visible_message("<span class='warning'>[user]'s eyes flare a deep crimson!</span>", \
						 "<span class='userdanger'>You feel a strange power seep into your body... you have absorbed the demon's blood-travelling powers!</span>")
	user.drop_item()
	src.Insert(user) //Consuming the heart literally replaces your heart with a demon heart. H A R D C O R E

/obj/item/organ/internal/heart/demon/Insert(mob/living/carbon/M, special = 0)
	..()
	if(M.mind)
		M.mind.AddSpell(new /obj/effect/proc_holder/spell/bloodcrawl(null))

/obj/item/organ/internal/heart/demon/Remove(mob/living/carbon/M, special = 0)
	..()
	if(M.mind)
		M.mind.RemoveSpell(/obj/effect/proc_holder/spell/bloodcrawl)

/obj/item/organ/internal/heart/demon/Stop()
	return 0 // Always beating.
