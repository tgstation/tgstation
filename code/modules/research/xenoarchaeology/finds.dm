//original code and idea from Alfie275 (luna era) and ISaidNo (goonservers) - with thanks




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// samples

/obj/item/weapon/rocksliver
	name = "rock sliver"
	desc = "It looks extremely delicate."
	icon = 'mining.dmi'
	icon_state = "sliver0"	//0-4
	w_class = 1
	//item_state = "electronic"
	var/source_rock = "/turf/simulated/mineral/archaeo"
	item_state = ""
	var/datum/geosample/geological_data

/obj/item/weapon/rocksliver/New()
	icon_state = "ore2"//"sliver[rand(0,4)]"




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// strange rocks

/obj/item/weapon/ore/strangerock/New()
	..()
	//var/datum/reagents/r = new/datum/reagents(50)
	//src.reagents = r
	if(rand(3))
		method = 0 // 0 = fire, 1+ = acid
	else
		method = 0 //currently always fire
		//	method = 1 //removed due to acid melting strange rocks to gooey grey -Mij
	inside = pick(150;"", 50;"/obj/item/weapon/crystal", 25;"/obj/item/weapon/talkingcrystal", "/obj/item/weapon/fossil/base")

/obj/item/weapon/ore/strangerock/bullet_act(var/obj/item/projectile/P)

/obj/item/weapon/ore/strangerock/ex_act(var/severity)
	src.visible_message("The [src] crumbles away, leaving some dust and gravel behind.")

/obj/item/weapon/ore/strangerock/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W,/obj/item/weapon/weldingtool/))
		var/obj/item/weapon/weldingtool/w = W
		if(w.isOn() && (w.get_fuel() > 3))
			if(!src.method) //0 = fire, 1+ = acid
				if(inside)
					var/obj/A = new src.inside(get_turf(src))
					for(var/mob/M in viewers(world.view, user))
						M.show_message("\blue The rock burns away revealing a [A.name].",1)
				else
					for(var/mob/M in viewers(world.view, user))
						M.show_message("\blue The rock burns away into nothing.",1)
				del src
			else
				for(var/mob/M in viewers(world.view, user))
					M.show_message("\blue A few sparks fly off the rock, but otherwise nothing else happens.",1)
		w.remove_fuel(4)

	else if(istype(W,/obj/item/device/core_sampler/))
		var/obj/item/device/core_sampler/S = W
		S.sample_item(src, user)

/*Code does not work, likely due to removal/change of acid_act proc
//Strange rocks currently melt to gooey grey w/ acid application (see reactions)
//will fix when I get a chance to fiddle with it -Mij
/obj/item/weapon/ore/strangerock/acid_act(var/datum/reagent/R)
	if(src.method)
		if(inside)
			var/obj/A = new src.inside(get_turf(src))
			for(var/mob/M in viewers(world.view, get_turf(src)))
				M.show_message("\blue The rock fizzes away revealing a [A.name].",1)
		else
			for(var/mob/M in viewers(world.view, get_turf(src)))
				M.show_message("\blue The rock fizzes away into nothing.",1)
		del src
	else
		for(var/mob/M in viewers(world.view, get_turf(src)))
			M.show_message("\blue The acid splashes harmlessly off the rock, nothing else interesting happens.",1)
	return 1
*/
