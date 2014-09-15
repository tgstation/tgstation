


/obj/structure/statue
	name = "Statue"
	desc = "Placeholder. Yell at Firecage if you SOMEHOW see this."
	icon = 'icons/obj/statue.dmi'
	icon_state = ""
	density = 1
	anchored = 1
	var/hardness = 1
	var/oreAmount = 7
	var/mineralType = "metal"
	var/last_event = 0
	var/active = null
	var/spam_flag = 0

/obj/structure/statue/Destroy()
	density = 0
	..()

/obj/structure/statue/attackby(obj/item/weapon/W, mob/user)
	hardness -= W.force/100
	user << "You hit the [name] with your [W.name]!"
	CheckHardness()

/obj/structure/statue/attack_hand(mob/user)
	visible_message("<span class='danger'>[user] rubs some dust off from the [name]'s surface.</span>")

/obj/structure/statue/CanAtmosPass()
	return !density

/obj/structure/statue/bullet_act(obj/item/projectile/Proj)
	hardness -= Proj.damage
	..()
	CheckHardness()
	return

/obj/structure/statue/proc/CheckHardness()
	if(hardness <= 0)
		Dismantle(1)

/obj/structure/statue/proc/Dismantle(devastated = 0)
	if(!devastated)
		if (mineralType == "metal")
			var/ore = /obj/item/stack/sheet/metal
			for(var/i = 1, i <= oreAmount, i++)
				new ore(get_turf(src))
		else
			var/ore = text2path("/obj/item/stack/sheet/mineral/[mineralType]")
			for(var/i = 1, i <= oreAmount, i++)
				new ore(get_turf(src))
	else
		if (mineralType == "metal")
			var/ore = /obj/item/stack/sheet/metal
			for(var/i = 3, i <= oreAmount, i++)
				new ore(get_turf(src))
		else
			var/ore = text2path("/obj/item/stack/sheet/mineral/[mineralType]")
			for(var/i = 3, i <= oreAmount, i++)
				new ore(get_turf(src))
	qdel(src)

/obj/structure/statue/ex_act(severity = 1)
	switch(severity)
		if(1)
			Dismantle(1)
		if(2)
			if(prob(20))
				Dismantle(1)
			else
				hardness--
				CheckHardness()
		if(3)
			hardness -= 0.1
			CheckHardness()
	return

//////////////////////////////////////STATUES/////////////////////////////////////////////////////////////
////////////////////////uranium///////////////////////////////////

/obj/structure/statue/uranium
	hardness = 3
	luminosity = 2
	mineralType = "uranium"

/obj/structure/statue/uranium/nuke
	name = "Statue of a Nuclear Fission Explosive"
	desc = "This is a grand statue of a Nuclear Explosive. It has a sickening green colour."
	icon_state = "nuke"

/obj/structure/statue/uranium/eng
	name = "Statue of an engineer"
	desc = "This statue has a sickening green colour."
	icon_state = "eng"

/obj/structure/statue/uranium/attackby(obj/item/weapon/W, mob/user)
	radiate()
	..()

/obj/structure/statue/uranium/Bumped(atom/user)
	radiate()

/obj/structure/statue/uranium/attack_hand(mob/user)
	radiate()
	..()

/obj/structure/statue/uranium/attack_paw(mob/user)
	radiate()

/obj/structure/statue/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			last_event = world.time
			active = null
			return
	return

////////////////////////////plasma///////////////////////////////////////////////////////////////////////

/obj/structure/statue/plasma
	hardness = 2
	mineralType = "plasma"
	desc = "This statue is suitably made from plasma."

/obj/structure/statue/plasma/scientist
	name = "Statue of a Scientist"
	icon_state = "sci"

/obj/structure/statue/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)


/obj/structure/statue/plasma/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj,/obj/item/projectile/beam))
		PlasmaBurn(2500)
	else if(istype(Proj,/obj/item/projectile/ion))
		PlasmaBurn(500)
	..()

/obj/structure/statue/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma statue ignited by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma statue ignited by [user.ckey]([user]) in ([x],[y],[z])")
		ignite(is_hot(W))
		return
	..()

/obj/structure/statue/plasma/proc/PlasmaBurn(temperature)
	Dismantle(1)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 400)

/obj/structure/statue/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

//////////////////////gold///////////////////////////////////////

/obj/structure/statue/gold
	hardness = 3
	mineralType = "gold"
	desc = "This is a highly valuable statue made from gold."

/obj/structure/statue/gold/hos
	name = "Statue of the Head of Security"
	icon_state = "hos"

/obj/structure/statue/gold/hop
	name = "Statue of the Head of Personnel"
	icon_state = "hop"

/obj/structure/statue/gold/cmo
	name = "Statue of the Chief Medical Officer"
	icon_state = "cmo"

/obj/structure/statue/gold/ce
	name = "Statue of the Chief Engineer"
	icon_state = "ce"

/obj/structure/statue/gold/rd
	name = "Statue of the Research Director"
	icon_state = "rd"

//////////////////////////silver///////////////////////////////////////

/obj/structure/statue/silver
	hardness = 3
	mineralType = "silver"
	desc = "This is a valuable statue made from silver."

/obj/structure/statue/silver/md
	name = "Statue of a Medical Officer"
	icon_state = "md"

/obj/structure/statue/silver/janitor
	name = "Statue of a Janitor"
	icon_state = "jani"

/obj/structure/statue/silver/sec
	name = "Statue of a Security Officer"
	icon_state = "sec"

/obj/structure/statue/silver/secborg
	name = "Statue of a Security Cyborg"
	icon_state = "secborg"

/obj/structure/statue/silver/medborg
	name = "Statue of a Medical Cyborg"
	icon_state = "medborg"

/////////////////////////diamond/////////////////////////////////////////

/obj/structure/statue/diamond
	hardness = 10
	mineralType = "diamond"
	desc = "This is a very expensive diamond statue"

/obj/structure/statue/diamond/captain
	name = "Statue of THE Captain."
	icon_state = "cap"

/obj/structure/statue/diamond/ai1
	name = "Statue of the AI hologram."
	icon_state = "ai1"

/obj/structure/statue/diamond/ai2
	name = "Statue of the AI core."
	icon_state = "ai2"

////////////////////////bananium///////////////////////////////////////

/obj/structure/statue/bananium
	hardness = 3
	mineralType = "clown"
	desc = "A bananium statue with a small engraving:'HOOOOOOONK'."

/obj/structure/statue/bananium/clown
	name = "Statue of a clown"
	icon_state = "clown"

/obj/structure/statue/bananium/Bumped(atom/user)
	honk()

/obj/structure/statue/bananium/attackby(obj/item/weapon/W, mob/user)
	honk()
	..()

/obj/structure/statue/bananium/attack_hand(mob/user)
	honk()
	..()

/obj/structure/statue/bananium/attack_paw(mob/user)
	honk()

/obj/structure/statue/bananium/proc/honk()
	if(spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		spawn(20)
			spam_flag = 0

/////////////////////sandstone/////////////////////////////////////////

/obj/structure/statue/sandstone
	hardness = 0.5
	mineralType = "sandstone"

/obj/structure/statue/sandstone/assistant
	name = "Statue of an assistant"
	desc = "A cheap statue of sandstone for a greyshirt."
	icon_state = "assist"
