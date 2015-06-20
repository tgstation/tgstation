/datum/martial_art
	var/name = "Martial Art"
	var/streak = ""
	var/max_streak_length = 6
	var/current_target = null
	var/temporary = 0
	var/datum/martial_art/base = null // The permanent style

/datum/martial_art/proc/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/add_to_streak(var/element,var/mob/living/carbon/human/D)
	if(D != current_target)
		current_target = D
		streak = ""
	streak = streak+element
	if(length(streak) > max_streak_length)
		streak = copytext(streak,2)
	return

/datum/martial_art/proc/basic_hit(var/mob/living/carbon/human/A,var/mob/living/carbon/human/D)
	add_logs(A, D, "punched")
	A.do_attack_animation(D)
	var/damage = rand(0,9)

	var/atk_verb = "punch"
	if(D.lying)
		atk_verb = "kick"
	else if(A.dna)
		atk_verb = A.dna.species.attack_verb

	if(A.dna)
		damage += A.dna.species.punchmod

	if(!damage)
		if(A.dna)
			playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		else
			playsound(D.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			D.visible_message("<span class='warning'>[A] has attempted to [atk_verb] [D]!</span>")
			return 0

	var/obj/item/organ/limb/affecting = D.get_organ(ran_zone(A.zone_sel.selecting))
	var/armor_block = D.run_armor_check(affecting, "melee")

	if(A.dna)
		playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)
	else
		playsound(D.loc, 'sound/weapons/punch1.ogg', 25, 1, -1)

	D.visible_message("<span class='danger'>[A] has [atk_verb]ed [D]!</span>", \
								"<span class='userdanger'>[A] has [atk_verb]ed [D]!</span>")

	D.apply_damage(damage, BRUTE, affecting, armor_block)
	if((D.stat != DEAD) && damage >= 9)
		D.visible_message("<span class='danger'>[A] has weakened [D]!!</span>", \
								"<span class='userdanger'>[A] has weakened [D]!</span>")
		D.apply_effect(4, WEAKEN, armor_block)
		D.forcesay(hit_appends)
	else if(D.lying)
		D.forcesay(hit_appends)
	return 1

/datum/martial_art/proc/teach(var/mob/living/carbon/human/H,var/make_temporary=0)
	if(make_temporary)
		temporary = 1
	if(H.martial_art && H.martial_art.temporary)
		if(temporary)
			base = H.martial_art.base
		else
			H.martial_art.base = src //temporary styles have priority
			return
	H.martial_art = src

/datum/martial_art/proc/remove(var/mob/living/carbon/human/H)
	if(H.martial_art != src)
		return
	H.martial_art = base

/datum/martial_art/boxing
	name = "Boxing"

/datum/martial_art/boxing/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	A << "<span class='warning'>Can't disarm while boxing!</span>"
	return 1

/datum/martial_art/boxing/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	A << "<span class='warning'>Can't grab while boxing!</span>"
	return 1

/datum/martial_art/boxing/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_logs(A, D, "punched")
	A.do_attack_animation(D)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = rand(5,8)
	if(A.dna)
		damage += A.dna.species.punchmod
	if(!damage)
		if(A.dna)
			playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		else
			playsound(D.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			D.visible_message("<span class='warning'>[A] has attempted to hit [D] with a [atk_verb]!</span>")
			return 0


	var/obj/item/organ/limb/affecting = D.get_organ(ran_zone(A.zone_sel.selecting))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, 'sound/weapons/punch1.ogg', 25, 1, -1)


	D.visible_message("<span class='danger'>[A] has hit [D] with a [atk_verb]!</span>", \
								"<span class='userdanger'>[A] has hit [D] with a [atk_verb]!</span>")

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	if(D.getStaminaLoss() > 50)
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message("<span class='danger'>[A] has knocked [D] out with a haymaker!</span>", \
								"<span class='userdanger'>[A] has knocked [D] out with a haymaker!</span>")
			D.apply_effect(10,WEAKEN,armor_block)
			D.SetSleeping(5)
			D.forcesay(hit_appends)
		else if(D.lying)
			D.forcesay(hit_appends)
	return 1

/datum/martial_art/wrestling
	name = "Wrestling"

/datum/martial_art/wrestling/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.grabbedby(A,1)
	var/obj/item/weapon/grab/G = A.get_active_hand()
	if(G && prob(50))
		G.state = GRAB_AGGRESSIVE
		D.visible_message("<span class='danger'>[A] has [D] in a clinch!</span>", \
								"<span class='userdanger'>[A] has [D] in a clinch!</span>")
	else
		D.visible_message("<span class='danger'>[A] fails to get [D] in a clinch!</span>", \
								"<span class='userdanger'>[A] fails to get [D] in a clinch!</span>")
	return 1


/datum/martial_art/wrestling/proc/Suplex(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_logs(A, D, "suplexed")
	D.visible_message("<span class='danger'>[A] suplexes [D]!</span>", \
								"<span class='userdanger'>[A] suplexes [D]!</span>")
	D.forceMove(A.loc)
	var/armor_block = D.run_armor_check(null, "melee")
	D.apply_damage(30, BRUTE, null, armor_block)
	D.apply_effect(6, WEAKEN, armor_block)
	A.SpinAnimation(10,1)

	D.SpinAnimation(10,1)
	spawn(3)
		armor_block = A.run_armor_check(null, "melee")
		A.apply_effect(4, WEAKEN, armor_block)
	return

/datum/martial_art/wrestling/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(istype(A.get_inactive_hand(),/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = A.get_inactive_hand()
		if(G.affecting == D)
			Suplex(A,D)
			return 1
	harm_act(A,D)
	return 1

/datum/martial_art/wrestling/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.grabbedby(A,1)
	D.visible_message("<span class='danger'>[A] holds [D] down!</span>", \
								"<span class='userdanger'>[A] holds [D] down!</span>")
	var/obj/item/organ/limb/affecting = D.get_organ(ran_zone(A.zone_sel.selecting))
	var/armor_block = D.run_armor_check(affecting, "melee")
	D.apply_damage(10, STAMINA, affecting, armor_block)
	return 1

#define TORNADO_COMBO "HHD"
#define THROWBACK_COMBO "DHD"
#define PLASMA_COMBO "HDDDH"

/datum/martial_art/plasma_fist
	name = "Plasma Fist"

/datum/martial_art/plasma_fist/proc/check_streak(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(findtext(streak,TORNADO_COMBO))
		streak = ""
		Tornado(A,D)
		return 1
	if(findtext(streak,THROWBACK_COMBO))
		streak = ""
		Throwback(A,D)
		return 1
	if(findtext(streak,PLASMA_COMBO))
		streak = ""
		Plasma(A,D)
		return 1
	return 0

/datum/martial_art/plasma_fist/proc/Tornado(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	A.say("TORNADO SWEEP!")
	spawn(0)
		for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
			A.dir = i
			playsound(A.loc, 'sound/weapons/punch1.ogg', 15, 1, -1)
			sleep(1)
	var/obj/effect/proc_holder/spell/aoe_turf/repulse/R = new(null)
	var/list/turfs = list()
	for(var/turf/T in range(1,A))
		turfs.Add(T)
	R.cast(turfs)
	return

/datum/martial_art/plasma_fist/proc/Throwback(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='danger'>[A] has hit [D] with Plasma Punch!</span>", \
								"<span class='userdanger'>[A] has hit [D] with Plasma Punch!</span>")
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	var/atom/throw_target = get_edge_target_turf(D, get_dir(D, get_step_away(D, A)))
	D.throw_at(throw_target, 200, 4)
	A.say("HYAH!")
	return

/datum/martial_art/plasma_fist/proc/Plasma(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	A.do_attack_animation(D)
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	A.say("PLASMA FIST!")
	D.visible_message("<span class='danger'>[A] has hit [D] with THE PLASMA FIST TECHNIQUE!</span>", \
								"<span class='userdanger'>[A] has hit [D] with THE PLASMA FIST TECHNIQUE!</span>")
	var/obj/item/organ/brain/B = D.getorgan(/obj/item/organ/brain)
	if(B)
		B.loc = get_turf(D)
		B.transfer_identity(D)
		D.internal_organs -= B
	D.gib()
	return

/datum/martial_art/plasma_fist/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_to_streak("H")
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/datum/martial_art/plasma_fist/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_to_streak("D")
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/datum/martial_art/plasma_fist/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_to_streak("G")
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1


//ITEMS
/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_gloves)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
	return

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_gloves) == src)
		style.remove(H)
	return

/obj/item/weapon/storage/belt/champion/wrestling
	name = "Wrestling Belt"
	var/datum/martial_art/wrestling/style = new

/obj/item/weapon/storage/belt/champion/wrestling/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_belt)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
	return

/obj/item/weapon/storage/belt/champion/wrestling/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_belt) == src)
		style.remove(H)
	return

/obj/item/weapon/plasma_fist_scroll
	name = "Plasma Fist Scroll"
	desc = "Teaches the traditional wizard martial art."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	var/used = 0

/obj/item/weapon/plasma_fist_scroll/attack_self(mob/user as mob)
	if(!ishuman(user))
		return
	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/plasma_fist/F = new/datum/martial_art/plasma_fist(null)
		F.teach(H)
		H << "<span class='notice'>You learn the PLASMA FIST style</span>"
		used = 1
		desc += "It looks like it's magic was used up."
