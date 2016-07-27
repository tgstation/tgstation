/*
Aquaponics tanks, used to grow ocean plants. Separate from normal hydroponics due to the key differences in how it's handled. See below for details.
1. Aquaponics (obviously) don't require water.
2. Seeds typically aren't used; instead, living samples are harvested from the seafloor and replanted.
3. Weeds and pests don't show up, but plants are harder to cultivate.
4. Harvesting is delicate and takes time.
5. If a tank is ruptured, it's unusable until it's fixed.
*/

/obj/machinery/aquaponics/tank
	name = "aquaponics tank"
	desc = "A transparent, water-filled tank used for cultivating aquatic plants."
	var/datum/aquaponics_plant/plant //The plant growing in the tank
	var/health = 100 //The integrity of the tank's glass; if this reaches zero, the tank ruptures and loses all of its water and nutrients
	var/nutrients = 100 //In percentage, how well-supplied the plant is with nutrients; too few nutrients and plants can't survive
	var/water = 100 //In percentage, how much water is left in the tank; too low and it can't grow, too high and it'll rupture

/obj/machinery/aquaponics/tank/New()
	..()
	SSobj.processing |= src

/obj/machinery/aquaponics/tank/Destroy()
	SSobj.processing -= src
	..()

/obj/machinery/aquaponics/tank/process()
	if(!plant || plant.dead)
		return
	nutrients = max(0, nutrients - plant.nutrient_consumption)
	plant.growth_cycle = min(plant.growth_cycle++, plant.required_growth_cycles)
	if(!nutrients || plant.age >= plant.lifespan)
		plant.damage(rand(5, 25))

/obj/machinery/aquaponics/tank/examine(mob/user)
	..()
	if(!user.canUseTopic(src))
		return
	if(stat & BROKEN)
		user << "<span class='warning'>It's broken.</span>"
		return
	if(plant)
		if(plant.dead)
			user << "<span class='warning'>There are some dead [plant.name] in [src].</span>"
		else
			user << "<span class='notice'>It has some [plant.name] growing.</span>"
			if(plant.health != initial(plant.health))
				user << "<span class='warning'>They look unhealthy.</span>"
			if(plant.growth_cycle >= plant.required_growth_cycles)
				user << "<span class='info'>They're ready to harvest.</span>"
	else
		user << "<span class='danger'>It doesn't have anything growing.</span>"

/obj/machinery/aquaponics/tank/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/plant_sample))
		var/obj/item/plant_sample/P = I
		if(!P.usable)
			user << "<span class='warning'>[P] has decayed beyond usability!</span>"
			return
		if(plant)
			user << "<span class='warning'>[src] already has something planted!</span>"
			return
		user.visible_message("<span class='notice'>[user] prepares [P] for planting.</span>", "<span class='notice'>You put in [P] and start the replanting sequence.</span>")
		visible_message("<span class='notice'>[src] hums as it plants [P].</span>")
		playsound(src, 'sound/items/poster_being_created.ogg', 50, 1)
		plant = new P.sample(src)
		user.drop_item()
		qdel(P)
		return
	if(istype(I, /obj/item/weapon/weldingtool))
		if(user.a_intent != "harm")
			var/obj/item/weapon/weldingtool/WT = I
			if(!WT.isOn())
				user << "<span class='warning'>Turn on [WT] first!</span>"
				return
			if(!WT.remove_fuel(0, user))
				user << "<span class='warning'>Refuel [WT] first!</span>"
				return
			if(stat & BROKEN)
				user << "<span class='warning'>[src] is completely shattered!</span>"
				return
			if(health >= initial(health))
				user << "<span class='warning'>[src] isn't damaged!</span>"
				return
			user.visible_message("<span class='notice'>[user] starts repairing the cracks in [src]...</span>", "<span class='notice'>You start mending [src]'s cracks...</span>")
			playsound(src, 'sound/items/Welder.ogg', 50, 1)
			if(!do_after(user, 50, target = src) || stat & BROKEN || !WT.remove_fuel(1, user))
				return
			user.visible_message("<span class='notice'>[user] fixes up [src]!</span>", "<span class='notice'>You repair [src]'s cracks!</span>")
			playsound(src, 'sound/items/Welder2.ogg', 50, 1)
			health = initial(health)
			return
	if(I.force && user.a_intent == "harm" && !(stat & BROKEN))
		user.visible_message("<span class='danger'>[user] hits [src] with [I]!</span>", "<span class='danger'>You hit [src] with [I]!</span>")
		playsound(src, 'sound/effects/Glasshit.ogg', 50, 1)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		hit(I.force)
		return
	..()

/obj/machinery/aquaponics/tank/attack_hand(mob/living/user)
	if(!user.canUseTopic(src) || stat & BROKEN)
		return
	var/info = "<span class='boldnotice'>The display reads:</span>"
	if(plant)
		info += "<br><span class='notice'><b>Planted Sample:</b> [plant.name]</span>"
		info += "<br><span class='notice'><b>Plant Description:</b> [plant.desc]</span>"
		info += "<br><span class='notice'><b>Plant Genetic Information:</b> [plant.genetic_desc]</span>"
		info += "<br><span class='notice'><b>Additional Notes:</b> [plant.fluff_desc]</span>"
	else
		info += "<br><span class='boldannounce'>No Planted Sample</span>"
	info += "<br>- - - - - - - - - -<br><span class='notice'><b>Integrity:</b> [health]/100% - </span>"
	switch(health)
		if(0)
			info += "<span class='boldwarning'>! Integrity Compromised !</span>"
		if(1 to 25)
			info += "<span class='boldwarning'>Integrity Critical</span>"
		if(25 to 50)
			info += "<span class='warning'>Repairs Required</span>"
		if(50 to 75)
			info += "<span class='warning'>Repairs Recommended</span>"
		if(75 to 99)
			info += "<span class='danger'>Repairs Advised</span>"
		if(100)
			info += "<span class='notice'>Integrity Nominal</span>"
	info += "<br><span class='notice'><b>Nutrients:</b> [nutrients]/100% - </span>"
	switch(nutrients)
		if(0)
			info += "<span class='boldwarning'>! No Nutrients !</span>"
		if(1 to 25)
			info += "<span class='boldwarning'>Nutrient Levels Critical</span>"
		if(25 to 50)
			info += "<span class='warning'>Nutrient Levels Low</span>"
		if(50 to 75)
			info += "<span class='warning'>Nutrient Levels Below Average</span>"
		if(75 to 99)
			info += "<span class='danger'>Nutrient Levels Slightly Low</span>"
		if(100)
			info += "<span class='notice'>Nutrient Levels Nominal</span>"
	info += "<br><span class='notice'><b>Water Level:</b> [water]/100% - <span>"
	switch(water)
		if(0)
			info += "<span class='boldwarning'>! No Pressure !</span>"
		if(1 to 25)
			info += "<span class='boldwarning'>Water Levels Critical</span>"
		if(25 to 50)
			info += "<span class='warning'>Water Levels Low</span>"
		if(50 to 75)
			info += "<span class='warning'>Water Levels Below Average</span>"
		if(75 to 99)
			info += "<span class='danger'>Water Levels Slightly Low</span>"
		if(100)
			info += "<span class='notice'>Water Levels Nominal</span>"
	user << info

/obj/machinery/aquaponics/tank/proc/hit(amount)
	health = round(max(0, health - amount))
	if(health)
		return
	visible_message("<span class='warning'>[src] shatters!</span>")
	playsound(src, 'sound/effects/Glassbr2.ogg', 50, 1)
	stat |= BROKEN
	water = 0
	nutrients = 0
	return 1
