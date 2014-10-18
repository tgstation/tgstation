
//Apprenticeship contract - moved to antag_spawner.dm

///////////////////////////Veil Render//////////////////////

/obj/item/weapon/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 15
	throwforce = 10
	w_class = 3
	var/charged = 1
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = 1
	unacidable = 1
	anchored = 1.0

/obj/effect/rend/New()
	spawn(50)
		new /obj/machinery/singularity/narsie/wizard(get_turf(src))
		del(src)
		return
	return

/obj/item/weapon/veilrender/attack_self(mob/user as mob)
	if(charged == 1)
		new /obj/effect/rend(get_turf(usr))
		charged = 0
		visible_message("<span class='warning'><B>[src] hums with power as [usr] deals a blow to reality itself!</B></span>")
	else
		user << "<span class='warning'>The unearthly energies that powered the blade are now dormant.</span>"



/obj/item/weapon/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."

/obj/item/weapon/veilrender/vealrender/attack_self(mob/user as mob)
	if(charged)
		new /obj/effect/rend/cow(get_turf(usr))
		charged = 0
		visible_message("<span class='warning'><B>[src] hums with power as [usr] deals a blow to hunger itself!</B></span>")
	else
		user << "<span class='warning'>The unearthly energies that powered the blade are now dormant.</span>"

/obj/effect/rend/cow
	desc = "Reverberates with the sound of ten thousand moos."
	var/cowsleft = 20

/obj/effect/rend/cow/New()
	processing_objects.Add(src)
	return

/obj/effect/rend/cow/process()
	if(locate(/mob) in loc) return
	new /mob/living/simple_animal/cow(loc)
	cowsleft--
	if(cowsleft <= 0)
		del src

/obj/effect/rend/cow/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/nullrod))
		visible_message("<span class='warning'><b>[I] strikes a blow against \the [src], banishing it!</b></span>")
		spawn(1)
			del src
		return
	..()


/////////////////////////////////////////Scrying///////////////////

/obj/item/weapon/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 7
	throw_range = 15
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'

/obj/item/weapon/scrying/attack_self(mob/user as mob)
	user << "<span class='notice'>You can see...everything!</span>"
	visible_message("<span class='warning'><B>[usr] stares into [src], their eyes glazing over.</B></span>")
	user.ghostize(1)
	return


////////////////////Necromancy//////////////////////
#define ZOMBIE 0
#define SKELETON 1
//#define FAITHLESS 2
/obj/item/weapon/staff/necro
	name = "staff of necromancy"
	desc = "A wicked looking staff that pulses with evil energy."
	icon_state = "necrostaff"
	item_state = "necrostaff"
	var/charge_tick = 0
	var/charges = 3
	var/raisetype = 0
	var/next_change = 0
/obj/item/weapon/staff/necro/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/staff/necro/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/staff/necro/process()
	charge_tick++
	if(charge_tick < 4) return 0
	charge_tick = 0
	charges++
	return 1

/obj/item/weapon/staff/necro/attack_self(mob/user)
	if(next_change > world.timeofday)
		user << "<span class='warning'>You must wait longer to decide on a minion type.</span>"
		return
	/*if(raisetype < FAITHLESS)
		raisetype = !raisetype
	else
		raisetype = ZOMBIE*/
	raisetype = !raisetype

	user << "<span class='notice'>You will now raise [raisetype < 2 ? (raisetype ? "skeletal" : "zombified") : "unknown"] minions from corpses.</span>"
	next_change = world.timeofday + 30

/obj/item/weapon/staff/necro/afterattack(atom/target, mob/user, proximity)
	if(!ishuman(target) || !charges || get_dist(target, user) > 7)
		return 0
	var/mob/living/carbon/human/H = target
	if(!H.stat || H.health > config.health_threshold_crit)
		return 0
	switch(raisetype)
		if(ZOMBIE)
			new /mob/living/simple_animal/hostile/necro/zombie(get_turf(target), user, H.mind)
		if(SKELETON)
			new /mob/living/simple_animal/hostile/necro/skeleton(get_turf(target), user, H.mind)

	H.gib()
	charges--



/obj/item/weapon/staff/necro/attack(mob/living/target as mob, mob/living/user as mob)
	afterattack(target,user,1)

#undef ZOMBIE
#undef SKELETON
//#undef FAITHLESS