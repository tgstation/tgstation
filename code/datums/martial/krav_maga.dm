/datum/martial_art/krav_maga
	name = "Cheesed Krav Maga" //you can use this version anywhere; the warden version is a subtype
	id = MARTIALART_KRAVMAGA
	var/datum/action/neck_chop/neckchop = new/datum/action/neck_chop()
	var/datum/action/leg_sweep/legsweep = new/datum/action/leg_sweep()
	var/datum/action/lung_punch/lungpunch = new/datum/action/lung_punch()

/datum/action/neck_chop
	name = "Neck Chop - Injures the neck, stopping the victim from speaking for a while."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "neckchop"

/datum/action/neck_chop/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use [name] while you're incapacitated.</span>")
		return
	var/mob/living/carbon/human/H = owner
	if (H.mind.martial_art.streak == "neck_chop")
		owner.visible_message("<span class='danger'>[owner] assumes a neutral stance.</span>", "<b><i>Your next attack is cleared.</i></b>")
		H.mind.martial_art.streak = ""
	else
		owner.visible_message("<span class='danger'>[owner] assumes the Neck Chop stance!</span>", "<b><i>Your next attack will be a Neck Chop.</i></b>")
		H.mind.martial_art.streak = "neck_chop"

/datum/action/leg_sweep
	name = "Leg Sweep - Trips the victim, knocking them down for a brief moment."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "legsweep"

/datum/action/leg_sweep/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use [name] while you're incapacitated.</span>")
		return
	var/mob/living/carbon/human/H = owner
	if (H.mind.martial_art.streak == "leg_sweep")
		owner.visible_message("<span class='danger'>[owner] assumes a neutral stance.</span>", "<b><i>Your next attack is cleared.</i></b>")
		H.mind.martial_art.streak = ""
	else
		owner.visible_message("<span class='danger'>[owner] assumes the Leg Sweep stance!</span>", "<b><i>Your next attack will be a Leg Sweep.</i></b>")
		H.mind.martial_art.streak = "leg_sweep"

/datum/action/lung_punch//referred to internally as 'quick choke'
	name = "Lung Punch - Delivers a strong punch just above the victim's abdomen, constraining the lungs. The victim will be unable to breathe for a short time."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "lungpunch"

/datum/action/lung_punch/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use [name] while you're incapacitated.</span>")
		return
	var/mob/living/carbon/human/H = owner
	if (H.mind.martial_art.streak == "quick_choke")
		owner.visible_message("<span class='danger'>[owner] assumes a neutral stance.</span>", "<b><i>Your next attack is cleared.</i></b>")
		H.mind.martial_art.streak = ""
	else
		owner.visible_message("<span class='danger'>[owner] assumes the Lung Punch stance!</span>", "<b><i>Your next attack will be a Lung Punch.</i></b>")
		H.mind.martial_art.streak = "quick_choke"//internal name for lung punch

/datum/martial_art/krav_maga/teach(mob/living/carbon/human/H,make_temporary=0)
	if(..())
		to_chat(H, "<span class='userdanger'>You know the arts of [name]!</span>")
		to_chat(H, "<span class='danger'>Place your cursor over a move at the top of the screen to see what it does.</span>")
		neckchop.Grant(H)
		legsweep.Grant(H)
		lungpunch.Grant(H)

/datum/martial_art/krav_maga/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class='userdanger'>You suddenly forget the arts of [name]...</span>")
	neckchop.Remove(H)
	legsweep.Remove(H)
	lungpunch.Remove(H)

/datum/martial_art/krav_maga/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	switch(streak)
		if("neck_chop")
			streak = ""
			neck_chop(A,D)
			return 1
		if("leg_sweep")
			streak = ""
			leg_sweep(A,D)
			return 1
		if("quick_choke")//is actually lung punch
			streak = ""
			quick_choke(A,D)
			return 1
	return 0

/datum/martial_art/krav_maga/proc/leg_sweep(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(D.stat || D.IsParalyzed())
		return 0
	D.visible_message("<span class='warning'>[A] leg sweeps [D]!</span>", \
					"<span class='userdanger'>Your legs are sweeped by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", null, A)
	to_chat(A, "<span class='danger'>You leg sweep [D]!</span>")
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	D.apply_damage(5, BRUTE)
	D.Paralyze(40)
	log_combat(A, D, "leg sweeped")
	return 1

/datum/martial_art/krav_maga/proc/quick_choke(mob/living/carbon/human/A, mob/living/carbon/human/D)//is actually lung punch
	D.visible_message("<span class='warning'>[A] pounds [D] on the chest!</span>", \
					"<span class='userdanger'>Your chest is slammed by [A]! You can't breathe!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	to_chat(A, "<span class='danger'>You pound [D] on the chest!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	if(D.losebreath <= 10)
		D.losebreath = CLAMP(D.losebreath + 5, 0, 10)
	D.adjustOxyLoss(10)
	log_combat(A, D, "quickchoked")
	return 1

/datum/martial_art/krav_maga/proc/neck_chop(mob/living/carbon/human/A, mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] karate chops [D]'s neck!</span>", \
					"<span class='userdanger'>Your neck is karate chopped by [A], rendering you unable to speak!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	to_chat(A, "<span class='danger'>You karate chop [D]'s neck, rendering [D.p_them()] unable to speak!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	D.apply_damage(5, A.dna.species.attack_type)
	if(D.silent <= 10)
		D.silent = CLAMP(D.silent + 10, 0, 10)
	log_combat(A, D, "neck chopped")
	return 1

/datum/martial_art/krav_maga/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "grabbed (Krav Maga)")
	..()

/datum/martial_art/krav_maga/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "punched")
	var/picked_hit_type = pick("punch", "kick")
	var/bonus_damage = 10
	if(!(D.mobility_flags & MOBILITY_STAND))
		bonus_damage += 5
		picked_hit_type = "stomp"
	D.apply_damage(bonus_damage, A.dna.species.attack_type)
	if(picked_hit_type == "kick" || picked_hit_type == "stomp")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	else
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type]s [D]!</span>", \
					"<span class='userdanger'>You're [picked_hit_type]ed by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	to_chat(A, "<span class='danger'>You [picked_hit_type] [D]!</span>")
	log_combat(A, D, "[picked_hit_type] with [name]")
	return 1

/datum/martial_art/krav_maga/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "shoved (Krav Maga)")
	..()

//The warden's special version of krav maga that only works while they're in a sec
/datum/martial_art/krav_maga/warden
	name = "Krav Maga"

//Prevents use if the cook is not in the kitchen.
/datum/martial_art/krav_maga/warden/can_use(mob/living/carbon/human/H) //STAY IN THE FUCKING BRIG
	if(!istype(get_area(H), /area/security)) //or at least in a sec outpost (any subtype of /area/security counts)
		return FALSE
	return ..()

//Krav Maga Gloves

/obj/item/clothing/gloves/krav_maga
	var/datum/martial_art/krav_maga/style = new

/obj/item/clothing/gloves/krav_maga/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)

/obj/item/clothing/gloves/krav_maga/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(H)

/obj/item/clothing/gloves/krav_maga/sec//more obviously named, given to sec
	name = "krav maga gloves"
	desc = "The interiors of these gloves have been officially declared to be a part of Sec by a drunk Chief Engineer. A warden who wears them can use Krav Maga anywhere, as their hands are technically inside of Sec at all times. Nanochips embedded in the gloves allow even those who haven't been trained in channelling the Sec Force to use Krav Maga while wearing them." //the Sec Force is like the Speed Force, but for being a warden, using Krav Maga, etc. instead of going fast
	icon_state = "fightgloves"
	item_state = "fightgloves"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/gloves/krav_maga/combatglovesplus
	name = "combat gloves plus"
	desc = "These tactical gloves are fireproof and electrically insulated. Microscopic runes engraved in the threads of these gloves forcibly siphon power from the Sec Force, causing long-term damage to the Sec Force in an area if they are kept in one place for too long. Nanochips embedded in the gloves allow even those who haven't been trained in channelling stolen Sec Force energy to use Krav Maga while wearing them." //shut up, my lore isn't dumb, YOU JUST AREN'T SMART ENOUGH TO COMPREHEND MY GENIUS
	icon_state = "black"
	item_state = "blackgloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)
