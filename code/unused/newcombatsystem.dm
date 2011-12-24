//It's not a very big change, but I think melee will benefit from it.
//Currently will only be restricted to special training weapons to test the balancedness of the system.
//1)Knockdown, stun and weaken chances are separate and dependant on the part of the body you're aiming at
//eg a mop will be better applied to legs since it has a higher base knockdown chance than the other disabling states
//while an energy gun would be better applied to the chest because of the stunning chance.
//2)Weapons also have a parry chance which is checked every time the one wielding the weapon is attacked in melee
//in the area is currently aiming at and is able to defend himself.
//More ideas to come.

//NOTES: doesn't work with armor yet

/obj/item/weapon/training //subclass of weapons that is currently the only one that uses the alternate combat system
	name = "training weapon"
	desc = "A weapon for training the advanced fighting technicues"
	var/chance_parry = 0
	var/chance_weaken = 0
	var/chance_stun = 0
	var/chance_knockdown = 0
	var/chance_knockout = 0
	var/chance_disarm = 0

//chances - 5 is low, 10 is medium, 15 is good

/obj/item/weapon/training/axe //hard-hitting, but doesn't have much in terms of disabling people (except by killing)
	name = "training axe"
	icon_state = "training_axe"
	/*combat stats*/
	force = 15
	chance_parry = 5
	chance_weaken = 10
	chance_stun = 5
	chance_knockdown = 5
	chance_knockout = 5
	chance_disarm = 0

/obj/item/weapon/training/sword //not bad attack, good at parrying and disarming
	name = "training sword"
	icon_state = "training_sword"
	/*combat stats*/
	force = 10
	chance_parry = 15
	chance_weaken = 5
	chance_stun = 0
	chance_knockdown = 5
	chance_knockout = 0
	chance_disarm = 15

/obj/item/weapon/training/staff //not bad attack either, good at tripping and parrying
	name = "training staff"
	icon_state = "training_staff"
	/*combat stats*/
	force = 10
	chance_parry = 15
	chance_weaken = 5
	chance_stun = 0
	chance_knockdown = 15
	chance_knockout = 0
	chance_disarm = 5

/obj/item/weapon/training/mace //worst attack, but has a good chance of stun, knockout or weaken
	name = "training mace"
	icon_state = "training_mace"
	/*combat stats*/
	force = 5
	chance_parry = 0
	chance_weaken = 15
	chance_stun = 10
	chance_knockdown = 0
	chance_knockout = 10
	chance_disarm = 0

/obj/item/weapon/training/attack(target as mob, mob/user as mob)
	var/target_area = attack_location(user.zone_sel.selecting)
	for(var/mob/O in viewers(src,7))
		O << "\red \b [user.name] attacks [target.name] in the [target_area] with [src.name]!"
	if(!target.stat && target.zone_sel.selecting == target_area) //parrying occurs here
		if(istype(target.r_hand,/obj/item/weapon/training)
			if(prob(target.r_hand:chance_parry))
				for(var/mob/O in viewers(src,7))
					O << "\red \b [target.name] deftly parries the attack with [target.r_hand.name]!"
					return
		if(istype(target.l_hand,/obj/item/weapon/training)
			if(prob(target.l_hand:chance_parry))
				for(var/mob/O in viewers(src,7))
					O << "\red \b [target.name] deftly parries the attack with [target.l_hand.name]!"
					return
	target.adjustBruteLoss(-src.force)

	var/modifier_knockdown = 1.0
	var/modifier_knockout = 1.0
	var/modifier_stun = 1.0
	var/modifier_weaken = 1.0
	var/modifier_disarm = 0.0

	switch(target_area)
		if("eyes")
			modifier_weaken = 2.0
			modifier_stun = 0.5
			modifier_knockdown = 0.0
		if("head")
			modifier_stun = 0.8
			modifier_knockout = 1.5
			modifier_weaken = 1.2
			modifier_knockdown = 0.0
		if("chest")
		if("right arm","r_arm")
		if("left arm","l_arm")
		if("right hand","r_hand")
		if("left hand","l_hand")
		if("groin")
		if("right leg","r_leg")
		if("left leg","l_leg")
		if("right foot","r_foot")
		if("left foot","l_foot")


/proc/attack_location(var/initloc = "chest") //proc to randomise actual hit loc based on where you're aiming at
	var/resultloc = "chest" //also forgot hands/feet. bleh
	var/percentage = rand(1,100)
	switch(initloc)
		if("eyes")
			switch(percentage)
				if(1 to 10)
					resultloc = "eyes"
				if(11 to 30)
					resultloc = "head"
				if(31 to 100)
					resultloc = "chest"
		if("head")
			switch(percentage)
				if(1 to 5)
					resultloc = "eyes"
				if(6 to 40)
					resultloc = "head"
				if(41 to 100)
					resultloc = "chest"
		if("chest")
			switch(percentage)
				if(1 to 80)
					resultloc = "chest"
				if(81 to 84)
					resultloc = "right arm"
				if(85 to 88)
					resultloc = "left arm"
				if(89 to 92)
					resultloc = "right leg"
				if(93 to 96)
					resultloc = "left leg"
				if(97 to 98)
					resultloc = "groin"
				if(99 to 100)
					resultloc = "head"
		if("l_arm")
			switch(percentage)
				if(1 to 60)
					resultloc = "left arm"
				if(61 to 100)
					resultloc = "chest"
		if("r_arm")
			switch(percentage)
				if(1 to 60)
					resultloc = "right arm"
				if(61 to 100)
					resultloc = "chest"
		if("groin")
			switch(percentage)
				if(1 to 35)
					resultloc = "groin"
				if(36 to 50)
					resultloc = "left leg"
				if(51 to 65)
					resultloc = "right leg"
				if(66 to 100)
					resultloc = "chest"
		if("l_leg")
			switch(percentage)
				if(1 to 60)
					resultloc = "left leg"
				if(61 to 70)
					resultloc = "groin"
				if(71 to 100)
					resultloc = "chest"
		if("r_leg")
			switch(percentage)
				if(1 to 60)
					resultloc = "right leg"
				if(61 to 70)
					resultloc = "groin"
				if(71 to 100)
					resultloc = "chest"
	return resultloc