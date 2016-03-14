#define DEMON_HANDS_LAYER 1
#define DEMON_HEAD_LAYER 2
#define DEMON_TOTAL_LAYERS 2


/mob/living/simple_animal/true_demon
	name = "True Demon"
	desc = "A pile of infernal energy, taking a vaguely humanoid form."
	icon = 'icons/mob/32x64.dmi'
	icon_state = "true_demon"
	gender = NEUTER
	health = 350
	maxHealth = 350
	unsuitable_atmos_damage = 0
	wander = 0
	speed = 0
	ventcrawler = 0
	density = 0
	pass_flags =  0
	sight = (SEE_TURFS | SEE_OBJS)
	status_flags = CANPUSH
	languages = ALL //The devil speaks all languages meme
	mob_size = MOB_SIZE_LARGE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 0, STAMINA = 0, OXY = 0)
	var/mob/oldform


/mob/living/simple_animal/true_demon/New()
	..()
	name = mind.demoninfo.truename
	real_name = name

/mob/living/simple_animal/true_demon/Destroy()
	// TODO LORDPIDEY: Make banishment rituals work here.
	return ..()

/mob/living/simple_animal/true_demon/Login()
	..()
	mind.announceDemonLaws()


/mob/living/simple_animal/true_demon/death(gibbed)
	..(gibbed)
	drop_l_hand()
	drop_r_hand()


/mob/living/simple_animal/true_demon/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is \icon[src] <b>[src]</b>!\n"

	//Left hand items
	if(l_hand && !(l_hand.flags&ABSTRACT))
		if(l_hand.blood_DNA)
			msg += "<span class='warning'>It is holding \icon[l_hand] [l_hand.gender==PLURAL?"some":"a"] blood-stained [l_hand.name] in its left hand!</span>\n"
		else
			msg += "It is holding \icon[l_hand] \a [l_hand] in its left hand.\n"

	//Right hand items
	if(r_hand && !(r_hand.flags&ABSTRACT))
		if(r_hand.blood_DNA)
			msg += "<span class='warning'>It is holding \icon[r_hand] [r_hand.gender==PLURAL?"some":"a"] blood-stained [r_hand.name] in its right hand!</span>\n"
		else
			msg += "It is holding \icon[r_hand] \a [r_hand] in its right hand.\n"

	//Braindead
	if(!client && stat != DEAD)
		msg += "The demon seems to be in deep contemplation.\n"

	//Damaged
	if(stat == DEAD)
		msg += "<span class='deadsay'>The hellfire seems to have been extinguished, for now at least.</span>\n"		
	else if(health < (maxHealth/10))
		msg += "<span class='warning'>You can see hellfire inside of it's gaping wounds.</span>\n"
	else if(health < (maxHealth/2)) //Between 9 and 0
		msg += "<span class='warning'>You can see hellfire inside of it's wounds.</span>\n"

	//Dead
	if(stat == DEAD)
		msg += "<span class='deadsay'>The hellfire seems to have</span>\n"
	msg += "*---------*</span>"
	user << msg


/mob/living/simple_animal/true_demon/IsAdvancedToolUser()
	return 1


/mob/living/simple_animal/true_demon/canUseTopic()
	if(stat)
		return
	return 1


/mob/living/simple_animal/true_demon/assess_threat()
	return 666

/mob/living/simple_animal/true_demon/handle_temperature_damage()
	return

/mob/living/simple_animal/true_demon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0)
	if(mind && mind.demoninfo.bane == BANE_LIGHT)
		if(has_bane(BANE_LIGHT))
			mind.disrupt_spells(-500)
			return ..() //flashes don't stop demons UNLESS it's their bane.
	return


/mob/living/simple_animal/true_demon/attacked_by(obj/item/I, mob/living/user, def_zone)
	var/weakness = check_weakness(I, user)
	apply_damage(I.force * weakness, I.damtype, def_zone)
	var/message_verb = ""
	if(I.attack_verb && I.attack_verb.len)
		message_verb = "[pick(I.attack_verb)]"
	else if(I.force)
		message_verb = "attacked"

	var/attack_message = "[src] has been [message_verb] with [I]."
	if(user)
		user.do_attack_animation(src)
		if(user in viewers(src, null))
			attack_message = "[user] has [message_verb] [src] with [I]!"
	if(message_verb)
		visible_message("<span class='danger'>[attack_message]</span>",
		"<span class='userdanger'>[attack_message]</span>")

/mob/living/simple_animal/true_demon/UnarmedAttack(atom/A, proximity)
	A.attack_hand(src)


