
/obj/item/clothing/suit/space/space_ninja/proc/ninja_sword_recall()
	set name = "Recall Energy Katana (Variable Cost)"
	set desc = "Teleports the Energy Katana linked to this suit to it's wearer, cost based on distance."
	set category = "Ninja Ability"
	set popup_menu = 0

	var/mob/living/carbon/human/H = affecting

	var/cost = 0
	var/inview = 1

	if(!energyKatana)
		H << "<span class='warning'>Could not locate Energy Katana!</span>"
		return

	if(energyKatana in H)
		return

	var/distance = get_dist(H,energyKatana)

	if(!(energyKatana in view(H)))
		cost = distance //Actual cost is cost x 10, so 5 turfs is 50 cost.
		inview = 0

	if(!ninjacost(cost))
		var/turf/T = get_turf(get_step(H,get_dir(energyKatana,H))) //turf between us and the katana, so we don't hit ourselves (unless we move)

		if(istype(energyKatana.loc, /mob/living/carbon))
			var/mob/living/carbon/C = energyKatana.loc
			C.unEquip(energyKatana)

			//Somebody swollowed my sword, probably the clown doing a circus act.
			if(energyKatana in C.stomach_contents)
				C.stomach_contents -= energyKatana

			if(energyKatana in C.internal_organs)
				C.internal_organs -= energyKatana

		energyKatana.loc = get_turf(energyKatana)

		if(inview) //If we can see the katana, throw it towards ourselves, damaging people as we go.
			energyKatana.spark_system.start()
			energyKatana.throw_at(T, distance+1, energyKatana.throw_speed)
			playsound(H, "sparks", 50, 1)
			H.visible_message("<span class='danger'>\the [energyKatana] flies towards [H]!</span>","<span class='warning'>You hold out your hand and \the [energyKatana] flies towards you!</span>")

			//This adds to the ~cool~ factor by having the ninja grab the katana once it reaches them.
			spawn(distance)//Rough guess at whether the katana has reached us.
				if(energyKatana && H) //A lot can happen in about 5 ticks, honk
					if(energyKatana.loc != H && H.Adjacent(get_turf(energyKatana)))//We don't have it equipped, and it's only 1 tile away.
						energyKatana.returnToOwner(H,0,1) //Equip it.

		else //Else just TP it to us.
			energyKatana.returnToOwner(H,1)

