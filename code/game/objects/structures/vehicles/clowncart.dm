/obj/structure/stool/bed/chair/vehicle/clowncart
	name = "clowncart"
	desc = "A goofy-looking cart, commonly used by space clowns for entertainment. There appears to be a coin slot on its side."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "clowncart0"
	anchored = 1
	density = 1
	nick = "honkin' ride" //For fucks sake, well then
	flags = OPENCONTAINER
	var/activated = 0 //Honk to activate, it stays active while you sit in it, and will deactivate when you unbuckle
	var/mode = 0 	//0 - normal, 1 - leave grafitti behind, 2 - leave banana peels behind
					//Modes 1 and 2 consume extra fuel
					//Use bananium coins to cycle between modes
	var/max_health = 100 //Bananium sheets increases maximum health by 20
	var/max_health_top = 1000 //That's 45 sheets of Bananium, as much as four tens and five, and that's terrible
	var/printing_text = "nothing"	//What is printed on the ground in mode 1
	var/printing_pos				//'Rune' draws runes and 'graffiti' draws graffiti, other draws text
	var/trail //Trail from banana pie
	var/colour1 = "#000000" //Change it by using stamps
	var/colour2 = "#3D3D3D" //Default is boring black
	var/emagged = 0			//Does something maybe
	var/honk				//Timer to prevent spamming honk
/obj/structure/stool/bed/chair/vehicle/clowncart/process()
	icon_state = "clowncart0"
	if(empstun > 0)
		empstun--
	if(empstun < 0)
		empstun = 0
	if(activated) //activated and nobody sits in it
		icon_state = "clowncart1"
		if(!buckled_mob)
			activated = 0
			icon_state = "clowncart0"
	if(trail < 0)
		trail = 0

/obj/structure/stool/bed/chair/vehicle/clowncart/New()
	. = ..()
	create_reagents(5000)
	reagents.add_reagent("banana", 175)

	processing_objects |= src
	handle_rotation()

/obj/structure/stool/bed/chair/vehicle/clowncart/examine(mob/user)
	..()
	if(max_health > 100)
		user << "<span class='info'>It is reinforced with [(max_health-100)/20] bananium sheets.</span>"
	switch(health)
		if(max_health*0.5 to max_health)
			user << "<span class='notice'>It appears slightly dented.</span>"
		if(1 to max_health*0.5)
			user << "<span class='warning'>It appears heavily dented.</span>"
		if((INFINITY * -1) to 0)
			user << "<span class='danger'>It appears completely unsalvageable.</span>"

/obj/structure/stool/bed/chair/vehicle/clowncart/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/bikehorn))
		if(destroyed)
			user << "<span class='danger'>[src] is completely wrecked, it's over.</span>"
			return
		if(honk + 20 > world.timeofday)
			return
		add_fingerprint(user)
		user.visible_message("<span class='notice'>[user] honks at [src].</span>", \
		"<span class='notice'>You honk at [src].</span>", \
		"<span class='notice'>You hear honking</span>")
		playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
		if(reagents.get_reagent_amount("banana") <= 5)
			if(activated)
				visible_message("<span class='warning'>[nick] lets out a last honk before running out of fuel and activating its ejection seat.</span>")
				if(ishuman(user)) //This shouldn't be needed, but fucks sakes
					user.Weaken(5)
				playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
				activated = 0
				reagents.remove_reagent("banana", 5)
			else
				user << "<span class='warning'>[src] doesn't have enough banana juice!</span>"
		else
			spawn(5)
				activated = 1
				src.visible_message("<span class='notice'>[nick] honks back happily.</span>")
				playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
		honk = world.timeofday
	//Banana type items add fuel to the ride, can't add fuel over limit for obvious reasons
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/bananabreadslice)) //Sliced banana bread
		if(reagents.total_volume > 5000 - 75) //You shouldn't be able to have more reagent than the container can hold, but this is mostly for fluff
			user << "<span class='warning'>You try to cram [W] inside, but you decide against it as banana essence starts spilling out of the fuel hatch</span>"
			return
		visible_message("<span class='notice'>[user] puts [W] into [src].</span>", "<span class='notice'>You put [W] into [src].</span>")
		reagents.add_reagent("banana", 75)
		del(W)
	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/banana)) //A banana
		if(reagents.total_volume > 5000 - 100)
			user << "<span class='warning'>You try to cram [W] inside, but you decide against it as banana essence starts spilling out of the fuel hatch</span>"
			return
		visible_message("<span class='notice'>[user] puts [W] into [src].</span>", "<span class='notice'>You put [W] into [src].</span>")
		reagents.add_reagent("banana", 100)
		del(W)
	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread)) //Unsliced banana bread
		if(reagents.total_volume > 5000 - 375)
			user << "<span class='warning'>You try to cram [W] inside, but you decide against it as banana essence starts spilling out of the fuel hatch</span>"
			return
		visible_message("<span class='notice'>[user] puts [W] into [src].</span>", "<span class='notice'>You put [W] into [src].</span>")
		reagents.add_reagent("banana", 375)
		del(W)
	else if(istype(W, /obj/item/weapon/bananapeel)) //Banana peels
		if(reagents.total_volume > 5000 - 10)
			user << "<span class='warning'>You try to cram [W] inside, but you decide against it as banana essence starts spilling out of the fuel hatch</span>"
			return
		visible_message("<span class='notice'>[user] puts [W] into [src].</span>", "<span class='notice'>You put [W] into [src].</span>")
		reagents.add_reagent("banana", 10)
		if(health >= max_health)
			health = max_health
			user << "<span class='notice'>You fail to repair [src] any further.</span>"
			return
		health += 5 //Banana peels repair some damage
		empstun -= 1 //And help remove EMP stun
		del(W)
	else if(istype(W, /obj/item/seeds/bananaseed)) //Banana seeds
		if(health >= max_health)
			health = max_health
			user << "<span class='notice'>You fail to repair [src] any further.</span>"
			return

		visible_message("<span class='notice'>[user] repairs [src] with [W].", "<span class='notice'>You repair [src] with [W].")
		health += 50 //Banana seeds repair a lot of damage
		empstun = 0 //And neutralize EMP stun
		del(W)
	else if(istype(W, /obj/item/stack/sheet/mineral/clown)) //Bananium sheets
		if(max_health >= max_health_top) //There's a point where the magic doesn't work anymore, sadly
			user << "<span class='notice'>You fail to reinforce [src] any further.</span>"
			return

		visible_message("<span class='notice'>[user] reinforces [src] with [W].</span>", "<span class='notice'>You reinforce [src] with [W].</span>")
		max_health += 20
		health += 20
		var/obj/item/stack/ST = W
		ST.use(1)

	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/pie)) //Banana pie
		if(reagents.total_volume > 5000 - 175)
			user << "<span class='warning'>You try to cram [W] inside, but you decide against it as banana essence starts spilling out of the fuel hatch</span>"
			return
		visible_message("<span class='notice'>[user] puts [W] into [src], it starts boiling inside the fuel container.</span>", \
		"<span class='notice'>You put [W] into [src], it starts boiling inside the fuel container.</span>")
		playsound(get_turf(src), 'sound/effects/bubbles.ogg', 50, 1)
		usr << "<span class='warning'>[W] starts boiling inside [src]!</span>"
		reagents.add_reagent("banana", 175)
		trail += 5
		del(W)
	else if(istype(W, /obj/item/weapon/coin/clown)) //Bananium coin
		user.visible_message("<span class='warning'>[user] inserts a bananium coin into [src].</span>", "<span class='notice'>You insert a bananium coin into [src].</span>")
		playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1)
		mode += 1
		if(mode > 2) //only 3 modes, so when it raises above 2 reset to 0
			mode = 0
		switch(mode)
			if(0)
				spawn(5)
					visible_message("<span class='warning'>[src]'s SynthPeel Generator turns off with a buzz.</span>")
					playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
			if(1)
				visible_message("<span class='notice'>[src]'s SmartCrayon Mk.II deploys, ready to draw!</span>")
				user << {"<span class='notice'>Use a crayon to decide what you want to draw.<br>
				Use stamps to change the colour of SmartCrayon Mk.II.</span>"}
			if(2)
				visible_message("<span class='warning'>[src]'s SmartCrayon Mk.II disappears in a puff of art!</span>")
				spawn(5)
					playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1)
					visible_message("<span class='notice'>You hear a ping as [src]'s SynthPeel Generator starts transforming banana juice into slippery peels.</span>")
					playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1)
		del(W)
	else if(istype(W, /obj/item/toy/crayon/)) //Any crayon
		if(mode == 1)
			printing_text = lowertext(input(user, "Enter a message to print. Possible options: 'rune', 'graffiti', 'paint', 'nothing'", "Message", printing_text))
			printing_pos = 0
			switch(printing_text)
				if("graffiti")
					user << "<span class='notice'>Set to draw graffiti!</span>"
				if("rune")
					user << "<span class='notice'>Set to draw runes!</span>"
				if("" || "nothing")
					user << "<span class='warning'>No longer drawing anything.</span>"
				if("paint")
					user << "<span class='notice'>Set to paint the floor!</span>"
				else
					user << "<span class='notice'>Set to print the following text: [printing_text].</span>"
	else if(istype(W, /obj/item/toy/waterflower)) //Water flower
		user << "<span class='notice'>You plug [W] into [src]!</span>"//Using it on the clown cart will transfer anything in the fuel tank (other than banana juice) into the flower
		if(max_health >= 150)
			if(do_after(user, 5))
				W.reagents.remove_any(10)
				var/tmp/bananas = reagents.get_reagent_amount("banana")
				reagents.remove_reagent("banana", bananas) //removing banan so it doesn't get transferred into the water flower
				if(reagents.total_volume >= 10)
					visible_message("<span class='notice'>The HONKTech pump starts recharging [W].</span>")
					reagents.trans_to(W, 10)
				else
					user << "<span class='warning'>There doesn't seem to be anything other than banana juice in [src]!</span>"
				reagents.add_reagent("banana", bananas) //adding banan back
		else
			user << "<span class='warning'>The HONKTech pump is not strong enough to do that yet. Reinforce it with more bananium sheets first.</span>"
	else if(istype(W, /obj/item/weapon/card/emag)) //emag
		if(!emagged)
			emagged = 1
			visible_message("<span class='warning'>[src]'s eyes glow eerily red for a second.</span>")
	else if(istype(W, /obj/item/weapon/stamp/))
		if(mode == 1)
			if(istype(W, /obj/item/weapon/stamp/captain))
				colour1 = "#004B8F"
				colour2 = "#0060B8"
				user << "Selected color: Condom Blue"
			else if(istype(W, /obj/item/weapon/stamp/ce))
				colour1 = "#FF6A00"
				colour2 = "#FF8432"
				user << "Selected color: Powerful Orange"
			else if(istype(W, /obj/item/weapon/stamp/clown))
				colour1 = "#FFFF00"
				colour2 = "#FFD000"
				user << "Selected color: Banana Yellow"
			else if(istype(W, /obj/item/weapon/stamp/cmo))
				colour1 = "#FFFFFF"
				colour2 = "#ECECEC"
				user << "Selected color: Sanitary White"
			else if(istype(W, /obj/item/weapon/stamp/denied))
				colour1 = "#FF0000"
				colour2 = "#E22C00"
				user << "Selected color: Red Denial"
			else if(istype(W, /obj/item/weapon/stamp/hop))
				colour1 = "#1CA800"
				colour2 = "#238E0E"
				user << "Selected color: Green Access"
			else if(istype(W, /obj/item/weapon/stamp/hos))
				colour1 = "#7F4D21"
				colour2 = "#B24611"
				user << "Selected color: Shitcurity Brown"
			else if(istype(W, /obj/item/weapon/stamp/rd))
				colour1 = "#D22EF7"
				colour2 = "#D312E5"
				user << "Selected color: Plasma Purple"
			else
				colour1 = "#000000"
				colour2 = "#6D6D6D"
				user << "Selected color: Boring Black"
/obj/structure/stool/bed/chair/vehicle/clowncart/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis  || destroyed)
		unbuckle()
		return
	if(empstun > 0)
		if(user)
			user << "<span class='warning'>[src]'s banana essence battery has shorted out.</span>"
		return
	if(reagents.total_volume <= 0) //No fuel
		if(user)
			user << "<span class='warning'>[src] has no fuel, it activates its ejection seat as soon as you jam down the pedal!</span>"
			activated = 0
			user.Weaken(5)
		return
	if(activated)
		var/old_pos = get_turf(src)
		step(src, direction)
		update_mob()
		handle_rotation()
		if(get_turf(src) <> old_pos) //if we actually moved
			if(max_health < 300)
				reagents.remove_reagent("banana", 1) //10 sheets of bananium required to drive without using fuel
			if(trail > 0)
				new /obj/effect/decal/cleanable/pie_smudge/(old_pos)
				trail--

			if(mode == 1) //graffiti
				var/graffiti_amount = 0//built-in safety measures allow only 3 drawings on the floor at same time
				for(var/obj/effect/decal/cleanable/crayon/C in old_pos)
					graffiti_amount++
				if(graffiti_amount > 3+(3*emagged)) //limit is upped to 6 if emagged
					if(printing_text != "paint") //still allow to paint the floor
						return
				if(!istype(old_pos,/turf/simulated/floor)) //no drawing in open space
					return
				if(printing_text != "nothing" && printing_text != "")	//"nothing" and "" won't draw anything
					reagents.remove_reagent("banana", 2)											//"graffiti" and "rune" will draw graffiti and runes
					if(printing_text == "graffiti" || printing_text == "rune") //"paint" will paint floor tiles with selected colour
						new /obj/effect/decal/cleanable/crayon(old_pos, colour1, colour2, printing_text)
					else
						if(printing_text == "paint")
							var/tmp/turf/T = old_pos
							var/ind = "[initial(T.icon)][colour1]"
							if(!cached_icons[ind]) //shamelessly copied from paint.dm
								var/icon/overlay = new/icon(initial(T.icon))
								overlay.Blend(colour1,ICON_ADD)
								overlay.SetIntensity(0.45)
								T.icon = overlay
								cached_icons[ind] = T.icon
							else
								T.icon = cached_icons[ind]
								return
						else
							if(dir == WEST || dir == NORTH) //if going left or up
								if(printing_pos >= 0)
									printing_pos = -length(printing_text)-1 //indian code magic
							printing_pos++
							new /obj/effect/decal/cleanable/crayon(old_pos, colour1, colour2, copytext(printing_text, abs(printing_pos), 1+abs(printing_pos)))
							if(printing_pos > length(printing_text) - 1 || printing_pos == - 1)
								printing_text = ""
								printing_pos = 0
			if(mode == 2) //peel
				if(!emagged)
					new /obj/item/weapon/bananapeel/(old_pos)
					reagents.remove_reagent("banana",4)
				else
					new /obj/item/weapon/bananapeel/traitorpeel/(old_pos)
					reagents.remove_reagent("banana",2)
	else
		user << "<span class='notice'>You have to honk to be able to ride [src].</span>"

/obj/structure/stool/bed/chair/vehicle/clowncart/die()
	destroyed = 1
	density = 0
	if(buckled_mob)
		unbuckle()
	visible_message("<span class='warning'>[nick] explodes in a puff of pure potassium!</span>")
	playsound(get_turf(src), 'sound/items/bikehorn.ogg', 75, 1)
	explosion(src.loc, -1, 0, 3, 7, 10)
	for(var/a = 0, a < round(reagents.total_volume*0.25), a++) //Spawn banana peels in place of the cart
		new /obj/item/weapon/bananapeel(get_turf(src)) // WHAT STUPID ASSHOLE MADE THESE TATORPEELS
	del(src)
