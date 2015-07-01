#define TATSUMAKI_SENPUKYAKU "DDHH"
#define SHORYUKEN "GDDG"
#define HADOUKEN "DDGG"
#define SHAKUNETSU_HADOUKEN "HDHDDG"
/datum/martial_art/hallway_brawler
	name = "Hallway Brawler"
	counter_prob = 50

/datum/martial_art/hallway_brawler/on_hit(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
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

/datum/martial_art/hallway_brawler/proc/check_streak(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(findtext(streak,TATSUMAKI_SENPUKYAKU))
		streak = ""
		whirlwind_kick(A,D)
		return 1
	if(findtext(streak,SHORYUKEN))
		streak = ""
		shoryuken(A,D)
		return 1
	if(findtext(streak,HADOUKEN))
		streak = ""
		hadouken(A,D)
		return 1
	if(findtext(streak,SHAKUNETSU_HADOUKEN))
		streak = ""
		shakunetsu_hadouken(A,D)
		return 1
	return 0

/datum/martial_art/hallway_brawler/proc/whirlwind_kick(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(!D.stat && !D.weakened)
		A.say("TATSUMAKI SENPUKYAKU!")
		for(var/i = 0; i < 4; i++)
			D.visible_message("<span class='warning'>[A] kicks [D] in the chest!</span>", \
						  	"<span class='userdanger'>[A] kicks you in the chest!</span>")
			playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
			D.apply_damage(5, BRUTE, "chest")
			D.dir = A.dir
			step(D, D.dir)
			step(A, A.dir)
			D.Stun(1)
			sleep(5)
		return 1
	return harm_act(A,D)

/datum/martial_art/hallway_brawler/proc/shoryuken(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(!D.stat && !D.weakened)
		A.say("SHORYUKEN!")
		D.visible_message("<span class='warning'>[A] uppercuts [D]!</span>", \
						  "<span class='userdanger'>[A] uppercuts you!</span>")
		D.apply_damage(15, BRUTE, "head")
		D.Weaken(4)
		playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
		return 1
	return harm_act(A,D)

/datum/martial_art/hallway_brawler/proc/hadouken(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(!D.stat && !D.weakened)
		A.say("HADOUKEN!")
		D.visible_message("<span class='warning'>[A] punches [D] with a burning force!</span>", \
						  "<span class'userdanger'>[A] punches you with a burning force!</span>")
		D.apply_damage(15, BURN, "chest")
		D.adjust_fire_stacks(2)
		D.IgniteMob()
		D.Weaken(3)
		playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
		return 1
	return harm_act(A,D)

/datum/martial_art/hallway_brawler/proc/shakunetsu_hadouken(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(!D.stat && !D.weakened)
		A.say("SHAKUNETSU HADOUKEN!")
		for(var/i = 0; i < 3; i++)
			D.visible_message("<span class='warning'>[A] punches [D] with a burning force!</span>", \
							  "<span class'userdanger'>[A] punches you with a burning force!</span>")
			D.apply_damage(10, BURN, "chest")
			D.adjust_fire_stacks(2)
			D.IgniteMob()
			D.Weaken(3)
			playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
			sleep(5)
		return 1
	return harm_act(A,D)


/datum/martial_art/hallway_brawler/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_to_streak("G")
	if(check_streak(A,D))
		return 1
	..()

/datum/martial_art/hallway_brawler/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(D.stat)
		A << "It is dishonorable to attack an opponent who is unable to fight back."
		return 1
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
	D.apply_damage(10, BRUTE)
	return 1


/datum/martial_art/hallway_brawler/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_to_streak("D")
	if(check_streak(A,D))
		return 1
	return ..()

// DOWN = disarm
// BACK = harm
// FORWARD = grab
/mob/living/carbon/human/proc/hallway_brawler_help()
	set name = "Recall Skills"
	set desc = "Remember your hallway brawling skills."
	set category = "Hallway Brawler"

	usr << "<b><i>You retreat inward and recall the teachings of the Hallway Brawler...</i></b>"
	usr << "<span class='notice'>Tatsumaki Senpukyaku</span>: Disarm Disarm Harm Harm. Hits 4 times in a row, knocking them down and moving you 4 tiles forward."
	usr << "<span class='notice'>Shoryuken</span>: Grab Disarm Disarm Grab. Deliver a powerful uppercut, stunning the opponent."
	usr << "<span class='notice'>Hadouken</span>: Disarm Disarm Grab Grab. Hits the opponent with a firey blast and stuns."
	usr << "<span class='notice'>Shakunetsu Hadouken</span>: Harm Disarm Harm Disarm Disarm Grab. Like the Hadouken, but hits multiple times for more."

/obj/item/clothing/gloves/hallway_brawler
	desc = "These gloves will teach you the ways of the hallway brawler."
	name = "fighting gloves"
	icon_state = "fightgloves"
	item_state = "fightgloves"
	var/datum/martial_art/hallway_brawler/style = new

/obj/item/clothing/gloves/hallway_brawler/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_gloves)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
		user.verbs += /mob/living/carbon/human/proc/hallway_brawler_help
	return

/obj/item/clothing/gloves/hallway_brawler/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_gloves) == src)
		style.remove(H)
		H.verbs -= /mob/living/carbon/human/proc/hallway_brawler_help
	return

