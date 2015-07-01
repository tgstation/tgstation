#define LEG_SWEEP "HD"
#define QUICK_CHOKE "DG"
#define HEAD_ELBOW "HHD"
#define NECK_CHOP "DDH"
/datum/martial_art/krav_maga
	name = "Krav Maga"
	counter_prob = 25

/datum/martial_art/krav_maga/on_hit(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(prob(counter_prob))
		if(prob(50))
			A.visible_message("<span class='warning'>[A] counters [D]'s hit!</span>", \
						 	"<span class='userdanger'>You counter the hit!</span>")
			sleep(5)
			playsound(get_turf(A), 'sound/effects/hit_block.ogg', 50, 1, -1)
			D.apply_damage(10, BRUTE)
			return 1

		else
			A.visible_message("<span class='warning'>[A] blocks [D]'s hit!</span>", \
						 	"<span class='userdanger'>You block the hit!</span>")
			playsound(get_turf(A), 'sound/effects/hit_block.ogg', 50, 1, -1)
			return 1
	return 0


/datum/martial_art/krav_maga/teach(var/mob/living/carbon/human/H,var/make_temporary=0)
	..()
	H << "<span class = 'userdanger'>You know the arts of Krav Maga!</span>"
	H << "<span class = 'danger'>Recall your teachings using the Access Tutorial verb in the Krav Maga menu, in your verbs menu.</span>"

/datum/martial_art/krav_maga/proc/check_streak(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(findtext(streak,NECK_CHOP))
		streak = ""
		neck_chop(A,D)
		return 1
	if(findtext(streak,HEAD_ELBOW))
		streak = ""
		head_elbow(A,D)
		return 1
	if(findtext(streak,LEG_SWEEP))
		streak = ""
		leg_sweep(A,D)
		return 1
	if(findtext(streak,QUICK_CHOKE))
		streak = ""
		quick_choke(A,D)
		return 1
	return 0

/datum/martial_art/krav_maga/proc/leg_sweep(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] leg sweeps [D]!</span>", \
					  	"<span class='userdanger'>[A] leg sweeps you!</span>")
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	D.apply_damage(5, BRUTE)
	D.Weaken(6)
	return 1

/datum/martial_art/krav_maga/proc/quick_choke(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] grabs and chokes [D]!</span>", \
				  	"<span class='userdanger'>[A] grabs and chokes you!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.losebreath += 5
	D.adjustOxyLoss(10)
	D.Stun(2)
	return 1

/datum/martial_art/krav_maga/proc/head_elbow(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] elbows [D] in the face, stunning them!</span>", \
				  	"<span class='userdanger'>[A] elbows you in the face, stunning you!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.apply_damage(10, BRUTE)
	D.Stun(3)
	return 1

/datum/martial_art/krav_maga/proc/neck_chop(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] karate chops [D]'s neck!</span>", \
				  	"<span class='userdanger'>[A] karate chops your neck, rendering you unable to speak for a short time!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.apply_damage(5, BRUTE)
	D.silent += 10
	return 1

datum/martial_art/krav_maga/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_to_streak("G")
	if(check_streak(A,D))
		return 1
	..()

/datum/martial_art/krav_maga/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_to_streak("H")
	if(check_streak(A,D))
		return 1
	add_logs(A, D, "punched")
	A.do_attack_animation(D)
	if(D.martial_art)
		var/datum/martial_art/MA = D.martial_art
		if(MA.on_hit(D,A)) // they countered with something
			add_logs(A, D, "countered or blocked")
			return 1
	var/picked_hit_type = pick("punches", "kicks")
	if(picked_hit_type == "kicks")
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	else
		playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] hits you!</span>")
	var/bonus_damage = 10
	if(D.weakened)
		bonus_damage += 5
	D.apply_damage(bonus_damage, BRUTE)
	return 1


/datum/martial_art/krav_maga/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_to_streak("D")
	if(check_streak(A,D))
		return 1
	if(prob(60))
		if(D.hand)
			if(istype(D.l_hand, /obj/item))
				var/obj/item/I = D.l_hand
				D.drop_item()
				A.put_in_hands(I)
		else
			if(istype(D.r_hand, /obj/item))
				var/obj/item/I = D.r_hand
				D.drop_item()
				A.put_in_hands(I)
		D.visible_message("<span class='danger'>[A] has disarmed [D]!</span>", \
							"<span class='userdanger'>[A] has disarmed [D]!</span>")
		playsound(D, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	else
		D.visible_message("<span class='danger'>[A] attempted to disarm [D]!</span>", \
							"<span class='userdanger'>[A] attempted to disarm [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	return 1

/mob/living/carbon/human/proc/krav_maga_help()
	set name = "Access Tutorial"
	set desc = "Access the Krav Maga tutorial."
	set category = "Krav Maga"

	usr << "<b><i>You access the Krav Maga tutorial section of your glove's chip...</i></b>"
	usr << "<span class='notice'>Leg Sweep</span>: Harm Disarm. Performs a leg sweep, knocking down the target and making him vulnerable to attack."
	usr << "<span class='notice'>Quick Choke</span>: Disarm Grab. Grabs and chokes the target, briefly stunning them while they catch their breath."
	usr << "<span class='notice'>Head Elbow</span>: Harm Harm Disarm. Elbows the opponent in the face, stunning them, leaving them vulnerable to attacks."
	usr << "<span class='notice'>Neck Chop</span>: Disarm Disarm Harm.  Karate chops the opponent's neck, rendering them unable to speak for a short period of time."

/obj/item/clothing/gloves/krav_maga
	desc = "These gloves can teach you to perform Krav Maga using nanochips."
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	var/datum/martial_art/krav_maga/style = new

/obj/item/clothing/gloves/krav_maga/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_gloves)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
		user.verbs += /mob/living/carbon/human/proc/krav_maga_help
	return

/obj/item/clothing/gloves/krav_maga/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_gloves) == src)
		style.remove(H)
		H.verbs -= /mob/living/carbon/human/proc/krav_maga_help
	return

