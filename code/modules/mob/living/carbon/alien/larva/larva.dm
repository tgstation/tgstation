/mob/living/carbon/alien/larva
	name = "alien larva"
	real_name = "alien larva"
	icon_state = "larva0"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	density = 0

	maxHealth = 25
	health = 25
	storedPlasma = 50
	max_plasma = 50

	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/larva/New()
	create_reagents(100)
	if(name == "alien larva")
		name = "alien larva ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	AddAbility(new/obj/effect/proc_holder/alien/hide(null))
	AddAbility(new/obj/effect/proc_holder/alien/larva_evolve(null))
	..()

//This needs to be fixed
/mob/living/carbon/alien/larva/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Progress: [amount_grown]/[max_grown]")

/mob/living/carbon/alien/larva/adjustToxLoss(amount)
	if(stat != DEAD)
		amount_grown = min(amount_grown + 1, max_grown)
	..(amount)

//can't equip anything
/mob/living/carbon/alien/larva/attack_ui(slot_id)
	return

/mob/living/carbon/alien/larva/attack_hulk(mob/living/carbon/human/user)
	if(user.a_intent == "harm")
		..(user, 1)
		adjustBruteLoss(5 + rand(1,9))
		Paralyse(1)
		spawn()
			step_away(src,user,15)
			sleep(1)
			step_away(src,user,15)
		return 1

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M as mob)
	if(..())
		var/damage = rand(1, 9)
		if (prob(90))
			playsound(loc, "punch", 25, 1, -1)
			add_logs(M, src, "attacked", admin=0)
			visible_message("<span class='danger'>[M] has kicked [src]!</span>", \
					"<span class='userdanger'>[M] has kicked [src]!</span>")
			if ((stat != DEAD) && (damage > 4.9))
				Paralyse(rand(5,10))

			adjustBruteLoss(damage)
			updatehealth()
		else
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has attempted to kick [src]!</span>", \
					"<span class='userdanger'>[M] has attempted to kick [src]!</span>")

	return

/mob/living/carbon/alien/larva/restrained()
	return 0

// new damage icon system
// now constructs damage icon for each organ from mask * damage field


/mob/living/carbon/alien/larva/show_inv(mob/user)
	return

/mob/living/carbon/alien/larva/toggle_throw_mode()
	return

/mob/living/carbon/alien/larva/start_pulling()
	return

/mob/living/carbon/alien/larva/stripPanelUnequip(obj/item/what, mob/who)
	src << "<span class='warning'>You don't have the dexterity to do this!</span>"
	return

/mob/living/carbon/alien/larva/stripPanelEquip(obj/item/what, mob/who)
	src << "<span class='warning'>You don't have the dexterity to do this!</span>"
	return
