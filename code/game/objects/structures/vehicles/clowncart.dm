#define HEALTH_FOR_70X_MODIFIER 200
#define HEALTH_FOR_80X_MODIFIER 400
#define HEALTH_FOR_FLOWER_RECHARGE 120

#define HEALTH_FOR_FREE_MOVEMENT 300

#define BANANA_FOR_NORMAL_PEEL 4
#define BANANA_FOR_TRAITOR_PEEL 8
#define BANANA_FOR_DRAWING 2
#define BANANA_FOR_MOVEMENT 1

#define MODE_NORMAL 0
#define MODE_DRAWING 1
#define MODE_PEELS 2

/obj/structure/bed/chair/vehicle/clowncart
	name = "clowncart"
	desc = "A goofy-looking cart, commonly used by space clowns for entertainment. There appears to be a coin slot on its side."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "clowncart0"
	anchored = 1
	density = 1
	nick = "honkin' ride" //For fucks sake, well then
	flags = OPENCONTAINER

	max_health = 100 //Bananium sheets increases maximum health by 20
	var/activated = 0 //Honk to activate, it stays active while you sit in it, and will deactivate when you unbuckle
	var/mode = MODE_NORMAL
					//Modes 1 and 2 consume extra fuel
					//Use bananium coins to cycle between modes
	var/max_health_top = 1000 //That's 45 sheets of Bananium, as much as four tens and five, and that's terrible
	var/printing_text = "nothing"	//What is printed on the ground in mode 1
	var/printing_pos				//'Rune' draws runes and 'graffiti' draws graffiti, other draws text
	var/trail //Trail from banana pie
	var/colour1 = "#000000" //Change it by using stamps
	var/colour2 = "#3D3D3D" //Default is boring black
	var/emagged = 0			//Does something maybe
	var/honk				//Timer to prevent spamming honk
/obj/structure/bed/chair/vehicle/clowncart/process()
	icon_state = "clowncart0"
	if(empstun > 0)
		empstun--
	if(empstun < 0)
		empstun = 0
	if(activated) //activated and nobody sits in it
		icon_state = "clowncart1"
		if(!occupant)
			activated = 0
			icon_state = "clowncart0"
	if(trail < 0)
		trail = 0

/obj/structure/bed/chair/vehicle/clowncart/New()
	. = ..()
	create_reagents(5000)
	reagents.add_reagent("banana", 175)

	processing_objects |= src

/obj/structure/bed/chair/vehicle/clowncart/examine(mob/user)
	..()
	if(max_health > 100)
		user << "<span class='info'>It is reinforced with [(max_health-100)/20] bananium sheets.</span>"
	switch(mode)
		if(MODE_DRAWING)
			user << "Currently in drawing mode."
		if(MODE_PEELS)
			user << "Currently in banana mode."
	switch(health)
		if(max_health*0.5 to max_health)
			user << "<span class='notice'>It appears slightly dented.</span>"
		if(1 to max_health*0.5)
			user << "<span class='warning'>It appears heavily dented.</span>"
		if((INFINITY * -1) to 0)
			user << "<span class='danger'>It appears completely unsalvageable.</span>"

/obj/structure/bed/chair/vehicle/clowncart/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/bikehorn))
		if(destroyed)
			user << "<span class='danger'>[src] is completely wrecked, it's over.</span>"
			return
		if(honk + 20 > world.timeofday)
			return
		add_fingerprint(user)
		user.visible_message("<span class='notice'>[user] honks at [src].</span>", \
		"<span class='notice'>You honk at [src].</span>", \
		"<span class='notice'>You hear honking.</span>")
		playsound(get_turf(src), W.hitsound, 50, 1)
		if(reagents.get_reagent_amount("banana") <= 5)
			if(activated)
				visible_message("<span class='warning'>[nick] lets out a last honk before running out of fuel and activating its ejection seat.</span>")
				if(ishuman(user)) //This shouldn't be needed, but fucks sakes
					user.Weaken(5)
				playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
				activated = 0
				reagents.remove_reagent("banana", 5)
			else
				user << "<span class='warning'>[src] doesn't have enough banana essence!</span>"
		else
			spawn(5)
				activated = 1
				src.visible_message("<span class='notice'>[nick] honks back happily.</span>")
				playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
		honk = world.timeofday
	else if(istype(W, /obj/item/weapon/reagent_containers))
		if(feed(W,user))
			visible_message("<span class='notice'>[user] puts [W] into [src].</span>")
			qdel(W)
	else if(istype(W, /obj/item/weapon/storage/bag/plants))
		var/ate_anything = 0
		var/obj/item/weapon/storage/bag/B = W
		for(var/obj/item/I in W.contents)
			if(feed(I,user))
				ate_anything+=1
				B.remove_from_storage(I,null)
				qdel(I)
		if(ate_anything)
			visible_message("<span class='notice'>[user] empties \the [W] into [src].</span>")
			user << "Added [ate_anything] item\s to \the [src]."
	else if(istype(W, /obj/item/weapon/bananapeel)) //Banana peels
		visible_message("<span class='notice'>[user] applies [W] to \the [src].</span>")
		health += 10 //Banana peels repair some damage
		empstun -= 1 //And help remove EMP stun
		if(health > max_health) health = max_health
		if(empstun ==0) visible_message("<span class='danger'>\The [src] comes back to life!</span>")
		if(empstun < 0) empstun = 0
		qdel(W)
	else if(istype(W, /obj/item/seeds/bananaseed))
		visible_message("<span class='notice'>[user] applies [W] to \the [src].</span>")
		health += 50
		if(health > max_health) health = max_health
		if(empstun!=0)
			empstun=0
			visible_message("<span class='danger'>\The [src] comes back to life!</span>")
		qdel(W)
	else if(istype(W, /obj/item/stack/sheet/mineral/clown)) //Bananium sheets
		if(max_health >= max_health_top) //There's a point where the magic doesn't work anymore, sadly
			user << "<span class='notice'>You fail to reinforce [src] any further.</span>"
			return

		visible_message("<span class='notice'>[user] reinforces [src] with [W].</span>")
		max_health += 20
		health += 20

		switch(max_health)
			if(HEALTH_FOR_FLOWER_RECHARGE)
				user << "You can now recharge your water flower using [src]'s HONKTech pump."
			if(HEALTH_FOR_70X_MODIFIER)
				user << "\The [src] will now convert food into banana essence a bit more effectively."
			if(HEALTH_FOR_80X_MODIFIER)
				user << "\The [src] will now convert food into banana essence much more effectively."
			if(HEALTH_FOR_FREE_MOVEMENT)
				user << "\The [src] will no longer use banana essence for powering its engine."

		var/obj/item/stack/ST = W
		ST.use(1)
	else if(istype(W, /obj/item/weapon/coin/clown)) //Bananium coin
		user.visible_message("<span class='warning'>[user] inserts a bananium coin into [src].</span>", "<span class='notice'>You insert a bananium coin into [src].</span>")
		playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1)
		mode += 1
		if(mode > 2) //only 3 modes, so when it raises above 2 reset to 0
			mode = 0
		switch(mode)
			if(MODE_NORMAL)
				spawn(5)
					visible_message("<span class='warning'>[src]'s SynthPeel Generator turns off with a buzz.</span>")
					playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
			if(MODE_DRAWING)
				visible_message("<span class='notice'>[src]'s SmartCrayon Mk.II deploys, ready to draw!</span>")
				user << {"<span class='notice'>Use a crayon to decide what you want to draw.<br>
				Use stamps to change the colour of SmartCrayon Mk.II.</span>"}
			if(MODE_PEELS)
				visible_message("<span class='warning'>[src]'s SmartCrayon Mk.II disappears in a puff of art!</span>")
				spawn(5)
					playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1)
					visible_message("<span class='notice'>You hear a ping as [src]'s SynthPeel Generator starts transforming banana juice into slippery peels.</span>")
					playsound(get_turf(src), 'sound/machines/ping.ogg', 50, 1)
		del(W)
	else if(istype(W, /obj/item/toy/crayon/)) //Any crayon
		if(mode == MODE_DRAWING)
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
		if(max_health >= HEALTH_FOR_FLOWER_RECHARGE)
			if(do_after(user, src, 5))
				W.reagents.remove_any(10)
				var/tmp/bananas = reagents.get_reagent_amount("banana")
				reagents.remove_reagent("banana", bananas) //removing banan so it doesn't get transferred into the water flower
				if(reagents.total_volume >= 10)
					visible_message("<span class='notice'>The HONKTech pump has recharged [W].</span>")
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
		if(mode == MODE_DRAWING)
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

/obj/structure/bed/chair/vehicle/clowncart/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis  || destroyed)
		unlock_atom(user)
		return
	if(empstun > 0)
		if(user)
			user << "<span class='warning'>[src]'s banana essence battery has been shorted out.</span>"
		return
	if(reagents.total_volume <= 0) //No fuel
		if(user)
			user << "<span class='warning'>[src] has no fuel, it activates its ejection seat as soon as you jam down the pedal!</span>"
			unlock_atom(user)
			activated = 0
			user.Weaken(5) //Only Weaken after unbuckling
		return
	if(activated)
		var/old_pos = get_turf(src)
		step(src, direction)
		if(get_turf(src) == old_pos)
			return

		if(max_health < HEALTH_FOR_FREE_MOVEMENT)
			reagents.remove_reagent("banana", BANANA_FOR_MOVEMENT) //10 sheets of bananium required to drive without using fuel
		if(trail > 0)
			new /obj/effect/decal/cleanable/pie_smudge/(old_pos)
			trail--

		if(mode == MODE_DRAWING)
			draw_graffiti(old_pos)
		else if(mode == MODE_PEELS)
			if(!emagged)
				new /obj/item/weapon/bananapeel/(old_pos)
				reagents.remove_reagent("banana",BANANA_FOR_NORMAL_PEEL)
			else
				new /obj/item/weapon/bananapeel/traitorpeel/(old_pos)
				reagents.remove_reagent("banana",BANANA_FOR_TRAITOR_PEEL)
	else
		user << "<span class='notice'>You have to honk to be able to ride [src].</span>"

/obj/structure/bed/chair/vehicle/clowncart/die()
	destroyed = 1
	density = 0
	visible_message("<span class='warning'>[nick] explodes in a puff of pure potassium!</span>")
	playsound(get_turf(src), 'sound/items/bikehorn.ogg', 75, 1)
	explosion(src.loc, -1, 0, 3, 7, 10)
	for(var/a = 0, a < round(reagents.total_volume*0.25), a++) //Spawn banana peels in place of the cart
		new /obj/item/weapon/bananapeel(get_turf(src)) // WHAT STUPID ASSHOLE MADE THESE TATORPEELS
	qdel(src)

/obj/structure/bed/chair/vehicle/clowncart/proc/draw_graffiti(var/pos)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/structure/stool/bed/chair/vehicle/clowncart/proc/draw_graffiti() called tick#: [world.time]")
	var/graffiti_amount = 0//built-in safety measures allow only 3 drawings on the floor at same time
	for(var/obj/effect/decal/cleanable/crayon/C in pos)
		graffiti_amount++
		if(graffiti_amount > 3+(3*emagged)) //limit is upped to 6 if emagged
			if(printing_text != "paint") //still allow to paint the floor
				return
	if(!istype(pos,/turf/simulated/floor)) //no drawing in open space
		return
	if(printing_text == "nothing" || printing_text == "")	//"nothing" and "" won't draw anything
		return
	reagents.remove_reagent("banana", BANANA_FOR_DRAWING)//"graffiti" and "rune" will draw graffiti and runes
	if(printing_text == "graffiti" || printing_text == "rune") //"paint" will paint floor tiles with selected colour
		new /obj/effect/decal/cleanable/crayon(pos, colour1, colour2, printing_text)
	else
		if(printing_text == "paint")
			var/tmp/turf/T = pos
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
			new /obj/effect/decal/cleanable/crayon(pos, colour1, colour2, copytext(printing_text, abs(printing_pos), 1+abs(printing_pos)))
			if(printing_pos > length(printing_text) - 1 || printing_pos == - 1)
				printing_text = ""
				printing_pos = 0

/obj/structure/bed/chair/vehicle/clowncart/proc/feed(obj/item/W, mob/living/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/structure/stool/bed/chair/vehicle/clowncart/proc/feed() called tick#: [world.time]")
	var/datum/reagents/R=W.reagents
	if(!R) return
	if(R.has_reagent("banana"))
		var/added_banana=R.get_reagent_amount("banana")
		if(reagents.total_volume + added_banana > 5000)
			user << "<span class='notice'>\The [src] can't hold any more banana essence!</span>"
			return 0
		var/modifier=50

		if(max_health>=HEALTH_FOR_70X_MODIFIER) //Should be 200, i.e. 5 bananium (cart starts at 100, bananium adds 20)
			modifier=75
			if(max_health>=HEALTH_FOR_80X_MODIFIER) //Should be 500, i.e. 20 bananium
				modifier=100

		reagents.add_reagent("banana", added_banana*modifier)
		if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/pie))
			playsound(get_turf(src), 'sound/effects/bubbles.ogg', 50, 1)
			user << "<span class='warning'>[W] starts boiling inside \the [src]!</span>"
			trail+=5
		return added_banana*modifier
	else
		user << "<span class='notice'>\The [W] doesn't contain any banana essence!</span>"
		return 0

#undef HEALTH_FOR_70X_MODIFIER
#undef HEALTH_FOR_80X_MODIFIER
#undef HEALTH_FOR_FLOWER_RECHARGE

#undef HEALTH_FOR_FREE_MOVEMENT

#undef BANANA_FOR_NORMAL_PEEL
#undef BANANA_FOR_TRAITOR_PEEL
#undef BANANA_FOR_DRAWING
#undef BANANA_FOR_MOVEMENT

#undef MODE_NORMAL
#undef MODE_DRAWING
#undef MODE_PEELS
