/obj/item/organ/internal
	origin_tech = "biotech=2"
	force = 1
	w_class = 2
	throwforce = 0
	var/zone = "chest"
	var/slot
	// DO NOT add slots with matching names to different zones - it will break internal_organs_slot list!
	var/vital = 0


/obj/item/organ/internal/proc/Insert(mob/living/carbon/M, special = 0)
	if(!iscarbon(M) || owner == M)
		return

	var/obj/item/organ/internal/replaced = M.getorganslot(slot)
	if(replaced)
		replaced.Remove(M, special = 1)

	owner = M
	M.internal_organs |= src
	M.internal_organs_slot[slot] = src
	loc = null
	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(M)


/obj/item/organ/internal/proc/Remove(mob/living/carbon/M, special = 0)
	owner = null
	if(M)
		M.internal_organs -= src
		if(M.internal_organs_slot[slot] == src)
			M.internal_organs_slot.Remove(slot)
		if(vital && !special)
			M.death()
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(M)


/obj/item/organ/internal/proc/on_find(mob/living/finder)
	return

/obj/item/organ/internal/proc/on_life()
	return

/obj/item/organ/internal/examine(mob/user)
	..()
	if(status == ORGAN_ROBOTIC && crit_fail)
		user << "<span class='warning'>[src] seems to be broken!</span>"


/obj/item/organ/internal/proc/prepare_eat()
	var/obj/item/weapon/reagent_containers/food/snacks/organ/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.origin_tech = origin_tech
	S.w_class = w_class

	return S

/obj/item/weapon/reagent_containers/food/snacks/organ
	name = "appendix"
	icon_state = "appendix"
	icon = 'icons/obj/surgery.dmi'
	list_reagents = list("nutriment" = 5)


/obj/item/organ/internal/Destroy()
	if(owner)
		Remove(owner, 1)
	return ..()

/obj/item/organ/internal/attack(mob/living/carbon/M, mob/user)
	if(M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(status == ORGAN_ORGANIC)
			var/obj/item/weapon/reagent_containers/food/snacks/S = prepare_eat()
			if(S)
				H.drop_item()
				H.put_in_active_hand(S)
				S.attack(H, H)
				qdel(src)
	else
		..()

/obj/item/organ/internal/item_action_slot_check(slot,mob/user)
	return //so we don't grant the organ's action to mobs who pick up the organ.

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm



/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	zone = "chest"
	slot = "heart"
	origin_tech = "biotech=3"
	var/beating = 1
	var/icon_base = "heart"

/obj/item/organ/internal/heart/update_icon()
	if(beating)
		icon_state = "[icon_base]-on"
	else
		icon_state = "[icon_base]-off"

/obj/item/organ/internal/heart/Remove(mob/living/carbon/M, special = 0)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.stat == DEAD || H.heart_attack)
			Stop()
			return
		if(!special)
			H.heart_attack = 1

	spawn(120)
		if(!owner)
			Stop()

/obj/item/organ/internal/heart/attack_self(mob/user)
	..()
	if(!beating)
		Restart()
		spawn(80)
			if(!owner)
				Stop()


/obj/item/organ/internal/heart/Insert(mob/living/carbon/M, special = 0)
	..()
	if(ishuman(M) && beating)
		var/mob/living/carbon/human/H = M
		if(H.heart_attack)
			H.heart_attack = 0
			return

/obj/item/organ/internal/heart/proc/Stop()
	beating = 0
	update_icon()
	return 1

/obj/item/organ/internal/heart/proc/Restart()
	beating = 1
	update_icon()
	return 1

/obj/item/organ/internal/heart/prepare_eat()
	var/obj/S = ..()
	S.icon_state = "heart-off"
	return S


/obj/item/organ/internal/heart/cursed
	name = "cursed heart"
	desc = "it needs to be pumped..."
	icon_state = "cursedheart-off"
	icon_base = "cursedheart"
	origin_tech = "biotech=5"
	actions_types = list(/datum/action/item_action/organ_action/cursed_heart)
	var/last_pump = 0
	var/pump_delay = 30 //you can pump 1 second early, for lag, but no more (otherwise you could spam heal)
	var/blood_loss = 100 //600 blood is human default, so 5 failures (below 122 blood is where humans die because reasons?)

	//How much to heal per pump, negative numbers would HURT the player
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_oxy = 0


/obj/item/organ/internal/heart/cursed/attack(mob/living/carbon/human/H, mob/living/carbon/human/user, obj/target)
	if(H == user && istype(H))
		playsound(user,'sound/effects/singlebeat.ogg',40,1)
		user.drop_item()
		Insert(user)
	else
		return ..()

/obj/item/organ/internal/heart/cursed/on_life()
	if(world.time > (last_pump + pump_delay))
		if(ishuman(owner) && owner.client) //While this entire item exists to make people suffer, they can't control disconnects.
			var/mob/living/carbon/human/H = owner
			H.vessel.remove_reagent("blood",blood_loss)
			H << "<span class = 'userdanger'>You have to keep pumping your blood!</span>"
			if(H.client)
				H.client.color = "red" //bloody screen so real
		else
			last_pump = world.time //lets be extra fair *sigh*

/obj/item/organ/internal/heart/cursed/Insert(mob/living/carbon/M, special = 0)
	..()
	if(owner)
		owner << "<span class ='userdanger'>Your heart has been replaced with a cursed one, you have to pump this one manually otherwise you'll die!</span>"

/datum/action/item_action/organ_action/cursed_heart
	name = "pump your blood"

//You are now brea- pumping blood manually
/datum/action/item_action/organ_action/cursed_heart/Trigger()
	. = ..()
	if(. && istype(target,/obj/item/organ/internal/heart/cursed))
		var/obj/item/organ/internal/heart/cursed/cursed_heart = target

		if(world.time < (cursed_heart.last_pump + (cursed_heart.pump_delay-10))) //no spam
			owner << "<span class='userdanger'>Too soon!</span>"
			return

		cursed_heart.last_pump = world.time
		playsound(owner,'sound/effects/singlebeat.ogg',40,1)
		owner << "<span class = 'notice'>Your heart beats.</span>"

		var/mob/living/carbon/human/H = owner
		if(istype(H))
			H.vessel.add_reagent("blood",(cursed_heart.blood_loss*0.5))//gain half the blood back from a failure
			if(owner.client)
				owner.client.color = ""

			H.adjustBruteLoss(-cursed_heart.heal_brute)
			H.adjustFireLoss(-cursed_heart.heal_burn)
			H.adjustOxyLoss(-cursed_heart.heal_oxy)


/obj/item/organ/internal/lungs
	name = "lungs"
	icon_state = "lungs"
	zone = "chest"
	slot = "lungs"
	gender = PLURAL
	w_class = 3

/obj/item/organ/internal/lungs/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("salbutamol", 5)
	return S


/obj/item/organ/internal/appendix
	name = "appendix"
	icon_state = "appendix"
	zone = "groin"
	slot = "appendix"
	var/inflamed = 0

/obj/item/organ/internal/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
		name = "inflamed appendix"
	else
		icon_state = "appendix"
		name = "appendix"

/obj/item/organ/internal/appendix/Remove(mob/living/carbon/M, special = 0)
	for(var/datum/disease/appendicitis/A in M.viruses)
		A.cure()
		inflamed = 1
	update_icon()
	..()

/obj/item/organ/internal/appendix/Insert(mob/living/carbon/M, special = 0)
	..()
	if(inflamed)
		M.AddDisease(new /datum/disease/appendicitis)

/obj/item/organ/internal/appendix/prepare_eat()
	var/obj/S = ..()
	if(inflamed)
		S.reagents.add_reagent("????", 5)
	return S

/obj/item/organ/internal/shadowtumor
	name = "black tumor"
	desc = "A tiny black mass with red tendrils trailing from it. It seems to shrivel in the light."
	icon_state = "blacktumor"
	origin_tech = "biotech=4"
	w_class = 1
	zone = "head"
	slot = "brain_tumor"
	var/health = 3

/obj/item/organ/internal/shadowtumor/New()
	..()
	SSobj.processing |= src

/obj/item/organ/internal/shadowtumor/Destroy()
	SSobj.processing.Remove(src)
	..()

/obj/item/organ/internal/shadowtumor/process()
	if(isturf(loc))
		var/turf/T = loc
		var/light_count = T.get_lumcount()
		if(light_count > LIGHT_DAM_THRESHOLD && health > 0) //Die in the light
			health--
		else if(light_count < LIGHT_HEAL_THRESHOLD && health < 3) //Heal in the dark
			health++
		if(health <= 0)
			visible_message("<span class='warning'>[src] collapses in on itself!</span>")
			qdel(src)