/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'

/obj/structure/cult/talisman
	name = "Altar"
	desc = "A bloodstained altar dedicated to Nar-Sie"
	icon_state = "talismanaltar"


/obj/structure/cult/forge
	name = "Daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie"
	icon_state = "forge"

/obj/structure/cult/pylon
	name = "Pylon"
	desc = "A floating crystal that hums with an unearthly energy"
	icon_state = "pylon"
	var/isbroken = 0
	luminosity = 5
	l_color = "#B40000"
	var/obj/item/wepon = null

/obj/structure/cult/pylon/attack_hand(mob/M as mob)
	wepon = new /obj/item
	wepon.force = 5
	attackby(wepon, M)
	wepon = null

/obj/structure/cult/pylon/attack_animal(mob/living/simple_animal/user as mob)
	if(user.environment_smash)
		wepon = new /obj/item
		wepon.force = user.melee_damage_upper
		attackby(wepon, user)
		wepon = null

/obj/structure/cult/pylon/attackby(obj/item/W as obj, mob/user as mob)
	if(!isbroken)
		if(prob(1+W.force * 5))
			user << "You hit the pylon, and its crystal breaks apart!"
			for(var/mob/M in viewers(src))
				if(M == user)
					continue
				M.show_message("[user.name] smashed the pylon!", 3, "You hear a tinkle of crystal shards", 2)
			playsound(get_turf(src), 'sound/effects/Glassbr3.ogg', 75, 1)
			isbroken = 1
			density = 0
			icon_state = "pylon-broken"
			SetLuminosity(0)
		else
			user << "You hit the pylon!"
			playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
	else
		if(prob(W.force * 2))
			user << "You pulverize what was left of the pylon!"
			qdel(src)
		else
			user << "You hit the pylon!"
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)

/obj/structure/cult/pylon/proc/repair(mob/user as mob)
	if(isbroken)
		user << "You repair the pylon."
		isbroken = 0
		density = 1
		icon_state = "pylon"
		SetLuminosity(5)

/obj/structure/cult/tome
	name = "Desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl"
	icon_state = "tomealtar"
//	luminosity = 5

//sprites for this no longer exist	-Pete
//(they were stolen from another game anyway)
/*
/obj/structure/cult/pillar
	name = "Pillar"
	desc = "This should not exist"
	icon_state = "pillar"
	icon = 'magic_pillar.dmi'
*/

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back"
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1.0
	var/spawnable = null

/obj/effect/gateway/Bumped(mob/M as mob|obj)
	spawn(0)
		return
	return

/obj/effect/gateway/Crossed(AM as mob|obj)
	spawn(0)
		return
	return

/obj/effect/gateway/active
	luminosity=5
	l_color="#ff0000"
	spawnable=list(
		/mob/living/simple_animal/hostile/scarybat,
		/mob/living/simple_animal/hostile/creature,
		/mob/living/simple_animal/hostile/faithless
	)

/obj/effect/gateway/active/cult
	luminosity=5
	l_color="#ff0000"
	spawnable=list(
		/mob/living/simple_animal/hostile/scarybat/cult,
		/mob/living/simple_animal/hostile/creature/cult,
		/mob/living/simple_animal/hostile/faithless/cult
	)

/obj/effect/gateway/active/New()
	spawn(rand(30,60) SECONDS)
		var/t = pick(spawnable)
		new t(src.loc)
		qdel(src)

/obj/effect/gateway/active/Crossed(var/atom/A)
	if(!istype(A, /mob/living))
		return

	var/mob/living/M = A

	if(M.stat != DEAD)
		if(M.monkeyizing)
			return
		if(M.has_brain_worms())
			return //Borer stuff - RR

		if(iscultist(M)) return
		if(!ishuman(M) && !isrobot(M)) return

		M.monkeyizing = 1
		M.canmove = 0
		M.icon = null
		M.overlays.Cut()
		M.invisibility = 101

		if(istype(M, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/Robot = M
			if(Robot.mmi)
				del(Robot.mmi)
		else
			for(var/obj/item/W in M)
				if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
					del(W)
					continue
				W.layer = initial(W.layer)
				W.loc = M.loc
				W.dropped(M)

		var/mob/living/new_mob = new /mob/living/simple_animal/hostile/retaliate/cluwne(A.loc)
		new_mob.universal_speak = 1
		new_mob.gender=src.gender
		new_mob.name = pick(clown_names)
		new_mob.real_name = new_mob.name
		new_mob.mutations += M_CLUMSY
		new_mob.mutations += M_FAT
		new_mob.setBrainLoss(100)


		new_mob.a_intent = "hurt"
		if(M.mind)
			M.mind.transfer_to(new_mob)
		else
			new_mob.key = M.key

		new_mob << "<B>Your form morphs into that of a cluwne.</B>"
