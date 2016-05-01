
/turf/simulated/wall/invulnerable
	name = "super-reinforced wall"
	desc = "Someone spent a lot of time and money on this bullet-proof, bomb-proof wall."
	icon_state = "riveted"
	opacity = 1
	density = 1
	can_thermite = 0

	walltype = "rwall"
	hardness = 100 // Hulk can't do dick.

	explosion_block = 9999
	girder_type = /obj/structure/girder/reinforced

	penetration_dampening = 40

/turf/simulated/wall/invulnerable/attackby(obj/item/W as obj, mob/user as mob)

	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(istype(W,/obj/item/weapon/solder) && bullet_marks)
		var/obj/item/weapon/solder/S = W
		if(!S.remove_fuel(bullet_marks*2,user))
			return
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You remove the bullet marks with \the [W].</span>")
		bullet_marks = 0
		icon = initial(icon)
		return

/turf/simulated/wall/invulnerable/attack_construct(mob/user as mob)
	return 0

/turf/simulated/wall/invulnerable/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()

/turf/simulated/wall/invulnerable/dismantle_wall(devastated = 0, explode = 0)
	if(!devastated)
		getFromPool(/obj/item/stack/sheet/plasteel, src)//Reinforced girder has deconstruction steps too. If no girder, drop ONE plasteel sheet AND rods
	else
		getFromPool(/obj/item/stack/rods, src, 2)
		getFromPool(/obj/item/stack/sheet/plasteel, src)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)

	ChangeTurf(dismantle_type)

/turf/simulated/wall/invulnerable/ex_act(severity)
	return // :^)