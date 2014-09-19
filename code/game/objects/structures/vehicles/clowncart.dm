/obj/structure/stool/bed/chair/vehicle/clowncart
	name = "clowncart"
	desc = "A goofy-looking cart, commonly used by space clowns for entertainment. There appears to be a coin slot on its side."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "clowncart0"
	anchored = 1
	density = 1
	nick = "honkin' ride"
	flags = OPENCONTAINER
	var/activated = 0 //honk to activate, it stays active while you sit in it, and will deactivate when you unbuckle
	//var/fuel = 0 //banana-type items add fuel, you can't ride without fuel
	var/mode = 0 	//0 - normal, 1 - leave grafitti behind, 2 - leave banana peels behind
					//modes 1 and 2 consume extra fuel
					//use bananium coins to cycle between modes
	var/maximum_health = 100 //bananium increases maximum health by 20
	var/printing_text = "nothing"	//what is printed on the ground in mode 1
	var/printing_pos				//'rune' draws runes and 'graffiti' draws graffiti, other draws text
	var/trail //trail from banana pie
	var/colour1 = "#000000" //change it by using stamps
	var/colour2 = "#3D3D3D" //default is boring black
	var/emagged = 0			//does something maybe
	var/honk				//timer to prevent spamming honk
/obj/structure/stool/bed/chair/vehicle/clowncart/process()
	icon_state = "clowncart0"
	if(empstun > 0) empstun--
	if(empstun < 0)
		empstun = 0
	if(activated) //activated and nobody sits in it
		icon_state = "clowncart1"
		if(!buckled_mob)
			activated = 0
			icon_state = "clowncart0"
	//if(fuel < 0)
	//	fuel = 0
	if(trail < 0)
		trail = 0

/obj/structure/stool/bed/chair/vehicle/clowncart/New()
	. = ..()
	//fuel = 0
	create_reagents(5000)
	reagents.add_reagent("banana", 175)

	processing_objects |= src
	handle_rotation()

/obj/structure/stool/bed/chair/vehicle/clowncart/examine()
	set src in usr
	usr << "\icon[src] [desc]"
	var/tmp/difference = reagents.total_volume - reagents.get_reagent_amount("banana")
	usr << "This [nick] contains [reagents.get_reagent_amount("banana")] unit\s of banana juice[(difference != 0 ? ", and [difference] unit\s of something else!" : "!")]" //yeah
	if(maximum_health > 100)
		usr << "It is reinforced with [(maximum_health-100)/20] bananium sheets."
	switch(health)
		if(maximum_health*0.5 to maximum_health)
			usr << "\blue It appears slightly dented."
		if(1 to maximum_health*0.5)
			usr << "\red It appears heavily dented."
		if((INFINITY * -1) to 0)
			usr << "It appears completely unsalvageable"

/obj/structure/stool/bed/chair/vehicle/clowncart/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/bikehorn))
		if(destroyed)
			user << "\red The [src.name] is destroyed beyond repair."
			return
		if(honk + 20 > world.timeofday)
			return
		add_fingerprint(user)
		user.visible_message("\blue [user] honks at the [src].", "\blue You honk at \the [src]")
		playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
		if(reagents.get_reagent_amount("banana") <= 5)
			if(activated)
				src.visible_message("\red The [nick] lets out a last honk before running out of fuel.")
				playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
				activated = 0
				reagents.remove_reagent("banana", 5)
			else
				user << "\red The [src.name] doesn't have enough banana juice!"
		else
			spawn(5)
				activated = 1
				src.visible_message("\blue The [nick] honks back happily.")
				playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
		honk = world.timeofday
	//banana type items add fuel to the ride
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/bananabreadslice))
		user.visible_message("\blue [user] puts the [W.name] in the [src].", "\blue You put the [W.name] in the [src].")
		reagents.add_reagent("banana", 75)
		del(W)
	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/banana))
		user.visible_message("\blue [user] puts the [W.name] in the [src].", "\blue You put the [W.name] in the [src].")
		reagents.add_reagent("banana", 100)
		del(W)
	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread))
		user.visible_message("\blue [user] puts the [W.name] in the [src].", "\blue You put the [W.name] in the [src].")
		reagents.add_reagent("banana", 375)
		del(W)
	else if(istype(W, /obj/item/weapon/bananapeel)) //banana peels
		user.visible_message("\blue [user] puts the [W.name] in the [src].", "\blue You put the [W.name] in the [src].")
		reagents.add_reagent("banana", 10)
		health += 5 //banana peels repair some of the damage
		if(health > maximum_health) health = maximum_health
		empstun = 0 //and disable emp stun
		del(W)
	else if(istype(W, /obj/item/seeds/bananaseed)) //banana seeds
		user.visible_message("\blue [user] repairs the [src] with the [W.name].", "\blue You repair the [src] with the [W.name].")
		health += 50 //banana seeds repair a lot of damage
		if(health > maximum_health) health = maximum_health
		del(W)
	else if(istype(W, /obj/item/stack/sheet/mineral/clown)) //bananium
		user << "\blue You reinforce the [src] with [W.name]."
		maximum_health += 20
		health += 20

		var/obj/item/stack/ST = W
		ST.use(1)
	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/pie)) //banana pie
		user.visible_message("\blue [user] puts the [W.name] in the [src].", "\blue You put the [W.name] in the [src].")
		playsound(get_turf(src), 'sound/effects/bubbles.ogg', 50, 1)
		usr << "\red The [W.name] starts boiling inside the [src]!"
		reagents.add_reagent("banana", 175)
		trail += 5
		del(W)
	else if(istype(W, /obj/item/weapon/coin/clown)) //bananium coin
		user.visible_message("\red [user] inserts a coin in the [src].", "\blue You insert a coin in the [src].")
		playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1)
		mode += 1
		if(mode > 2) //only 3 modes, so when it raises above 2 reset to 0
			mode = 0
		switch(mode)
			if(0)
				spawn(5)
					user << "\red The SynthPeel Generator turns off with a buzz."
					playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
			if(1)
				user << "\blue SmartCrayon II appears under the [src], ready to draw!"
				user << ""
				user << "Use a crayon to decide what you want to draw."
				user << "Use stamps to change the colour of SmartCrayon II."
			if(2)
				user << "\red SmartCrayon II disappears in a puff of art!"
				spawn(5)
					playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1)
					user << "\blue You hear a ping as the SynthPeel Generator starts transforming banana juice into slippery peels."
		del(W)
	else if(istype(W, /obj/item/toy/crayon/)) //any crayon
		if(mode == 1)
			printing_text = lowertext(input(user, "Enter a message to print. Possible options: 'rune', 'graffiti', 'paint', 'nothing'", "Message", printing_text))
			printing_pos = 0
			switch(printing_text)
				if("graffiti")
					user << "\blue Drawing graffiti!"
				if("rune")
					user << "\blue Drawing runes!"
				if("" || "nothing")
					user << "\red Not drawing anything."
				if("paint")
					user << "\blue Painting the floor!"
				else
					user << "\blue Printing the following text: [printing_text]."
	else if(istype(W, /obj/item/toy/waterflower)) //water flower
		user << "You plug the [W] into the [src]!"//using it on the clown cart will transfer anything in the fuel tank (other than banana juice) into the flower
		if(maximum_health >= 120)
			if(do_after(user, 5))
				W.reagents.remove_any(10)
				var/tmp/bananas = reagents.get_reagent_amount("banana")
				reagents.remove_reagent("banana", bananas) //removing banan so it doesn't get transferred into the water flower
				if(reagents.total_volume >= 10)
					user << "The HONKtechs pump starts recharging the [W]."
					reagents.trans_to(W, 10)
				else
					user << "\red There doesn't seem to be anything other than banana juice in the [src]!"
				reagents.add_reagent("banana", bananas) //adding banan back
		else
			user << "\red The HONKtechs pump is not strong enough to do that yet. Reinforce it with bananium first."
	else if(istype(W, /obj/item/weapon/card/emag)) //emag
		if(!emagged)
			emagged = 1
			src.visible_message("\red The [src.name]'s eyes glow red for a second.")
	else if(istype(W, /obj/item/weapon/stamp/))
		if(mode == 1)
			if(istype(W, /obj/item/weapon/stamp/captain))
				colour1 = "#004B8F"
				colour2 = "#0060B8"
				user << "Selected colour: Condom Blue"
			else if(istype(W, /obj/item/weapon/stamp/ce))
				colour1 = "#FF6A00"
				colour2 = "#FF8432"
				user << "Selected colour: Powerful Orange"
			else if(istype(W, /obj/item/weapon/stamp/clown))
				colour1 = "#FFFF00"
				colour2 = "#FFD000"
				user << "Selected colour: Banana Yellow"
			else if(istype(W, /obj/item/weapon/stamp/cmo))
				colour1 = "#FFFFFF"
				colour2 = "#ECECEC"
				user << "Selected colour: Sanitary White"
			else if(istype(W, /obj/item/weapon/stamp/denied))
				colour1 = "#FF0000"
				colour2 = "#E22C00"
				user << "Selected colour: Red Denial"
			else if(istype(W, /obj/item/weapon/stamp/hop))
				colour1 = "#1CA800"
				colour2 = "#238E0E"
				user << "Selected colour: Green Access"
			else if(istype(W, /obj/item/weapon/stamp/hos))
				colour1 = "#7F4D21"
				colour2 = "#B24611"
				user << "Selected colour: Shitcurity Brown"
			else if(istype(W, /obj/item/weapon/stamp/rd))
				colour1 = "#D22EF7"
				colour2 = "#D312E5"
				user << "Selected colour: Plasma Purple"
			else
				colour1 = "#000000"
				colour2 = "#6D6D6D"
				user << "Selected colour: Boring Black"
/obj/structure/stool/bed/chair/vehicle/clowncart/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis  || destroyed)
		unbuckle()
		return
	if(empstun > 0)
		if(user)
			user << "\red \the [src] is unresponsive."
		return
	if(reagents.total_volume <= 0) //no fuel
		if(user)
			user << "\red \the [src] has no fuel!"
			activated = 0
		return
	if(activated)
		var/old_pos = get_turf(src)
		step(src, direction)
		update_mob()
		handle_rotation()
		if(get_turf(src) <> old_pos) //if we actually moved
			if(maximum_health < 300) reagents.remove_reagent("banana", 1) //10 sheets of bananium required to drive without using fuel
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
		/*
		if(istype(src.loc, /turf/space) && (!src.Process_Spacemove(0, user)))
			var/turf/space/S = src.loc
			S.Entered(src)*/
	else
		user << "<span class='notice'>You have to honk to be able to ride this.</span>"

/obj/structure/stool/bed/chair/vehicle/clowncart/die()
	destroyed = 1
	density = 0
	if(buckled_mob)
		unbuckle()
	visible_message("<span class='warning'>The honkin' ride explodes in a puff of potassium!</span>")
	playsound(get_turf(src), 'sound/items/bikehorn.ogg', 75, 1)
	explosion(src.loc,-1,0,3,7,10)
	for(var/a=0, a<round(reagents.total_volume*0.25), a++) //spawn banana peels in place of the cart
		new /obj/item/weapon/bananapeel( get_turf(src) ) // WHAT STUPID ASSHOLE MADE THESE TATORPEELS
	del(src)