/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom
	name = "mushroom"
	bitesize_mod = 2


// Reishi
/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi
	seed = /obj/item/seeds/reishimycelium
	name = "reishi"
	desc = "<I>Ganoderma lucidum</I>: A special fungus known for its medicinal and stress relieving properties."
	icon_state = "reishi"
	filling_color = "#FF4500"
	reagents_add = list("morphine" = 0.35, "charcoal" = 0.35, "nutriment" = 0)


// Fly Amanita
/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	seed = /obj/item/seeds/amanitamycelium
	name = "fly amanita"
	desc = "<I>Amanita Muscaria</I>: Learn poisonous mushrooms by heart. Only pick mushrooms you know."
	icon_state = "amanita"
	filling_color = "#FF0000"
	reagents_add = list("mushroomhallucinogen" = 0.04, "amatoxin" = 0.35, "nutriment" = 0)


// Destroying Angel
/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel
	seed = /obj/item/seeds/angelmycelium
	name = "destroying angel"
	desc = "<I>Amanita Virosa</I>: Deadly poisonous basidiomycete fungus filled with alpha amatoxins."
	icon_state = "angel"
	filling_color = "#C0C0C0"
	reagents_add = list("mushroomhallucinogen" = 0.04, "amatoxin" = 0.8, "nutriment" = 0)


// Liberty Cap
/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap
	seed = /obj/item/seeds/libertymycelium
	name = "liberty-cap"
	desc = "<I>Psilocybe Semilanceata</I>: Liberate yourself!"
	icon_state = "libertycap"
	filling_color = "#DAA520"
	reagents_add = list("mushroomhallucinogen" = 0.25, "nutriment" = 0.02)


// Plump Helmet
/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	seed = /obj/item/seeds/plumpmycelium
	name = "plump-helmet"
	desc = "<I>Plumus Hellmus</I>: Plump, soft and s-so inviting~"
	icon_state = "plumphelmet"
	filling_color = "#9370DB"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)


// Walking Mushroom
/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	seed = /obj/item/seeds/walkingmushroommycelium
	name = "walking mushroom"
	desc = "<I>Plumus Locomotus</I>: The beginning of the great walk."
	icon_state = "walkingmushroom"
	filling_color = "#9370DB"
	reagents_add = list("vitamin" = 0.05, "nutriment" = 0.12)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom/attack_self(mob/user)
	if(istype(user.loc,/turf/space))
		return
	var/mob/living/simple_animal/hostile/mushroom/M = new /mob/living/simple_animal/hostile/mushroom(user.loc)
	M.maxHealth += round(endurance / 4)
	M.melee_damage_lower += round(potency / 20)
	M.melee_damage_upper += round(potency / 20)
	M.move_to_delay -= round(production / 50)
	M.health = M.maxHealth
	qdel(src)
	user << "<span class='notice'>You plant the walking mushroom.</span>"


// Chanterelle
/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle
	seed = /obj/item/seeds/chantermycelium
	name = "chanterelle cluster"
	desc = "<I>Cantharellus Cibarius</I>: These jolly yellow little shrooms sure look tasty!"
	icon_state = "chanterelle"
	filling_color = "#FFA500"
	reagents_add = list("nutriment" = 0.1)


// Glowshroom
/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom
	seed = /obj/item/seeds/glowshroom
	name = "glowshroom cluster"
	desc = "<I>Mycena Bregprox</I>: This species of mushroom glows in the dark."
	icon_state = "glowshroom"
	filling_color = "#00FA9A"
	var/effect_path = /obj/effect/glowshroom
	reagents_add = list("radium" = 0.05, "nutriment" = 0.04)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/New(var/loc, var/new_potency = 10)
	..()
	if(lifespan == 0) //basically, if you're spawning these via admin or on the map, then set up some default stats.
		lifespan = 120
		endurance = 30
		maturation = 15
		production = 1
		yield = 3
		potency = 30
		plant_type = 2
	if(istype(src.loc,/mob))
		pickup(src.loc)//adjusts the lighting on the mob
	else
		src.SetLuminosity(round(potency / 10,1))

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/attack_self(mob/user)
	if(istype(user.loc,/turf/space))
		return
	var/obj/effect/glowshroom/planted = new effect_path(user.loc)
	planted.delay = planted.delay - production * 100 //So the delay goes DOWN with better stats instead of up. :I
	planted.endurance = endurance
	planted.yield = yield
	planted.potency = potency
	user << "<span class='notice'>You plant [src].</span>"
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/Destroy()
	if(istype(loc,/mob))
		loc.AddLuminosity(round(-potency / 10,1))
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/pickup(mob/user)
	..()
	SetLuminosity(0)
	user.AddLuminosity(round(potency / 10,1))

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/dropped(mob/user)
	..()
	user.AddLuminosity(round(-potency / 10,1))
	SetLuminosity(round(potency / 10,1))


// Glowcap
/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/glowcap
	seed = /obj/item/seeds/glowcap
	name = "glowcap cluster"
	desc = "<I>Mycena Ruthenia</I>: This species of mushroom glows in the dark, but aren't bioluminescent. They're warm to the touch..."
	icon_state = "glowcap"
	filling_color = "#00FA9A"
	effect_path = /obj/effect/glowshroom/glowcap
	reagents_add = list("teslium" = 0.02, "nutriment" = 0.04)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/glowcap/On_Consume()
	if(!reagents.total_volume)
		var/batteries_recharged = 0
		for(var/obj/item/weapon/stock_parts/cell/C in usr.GetAllContents())
			var/newcharge = (potency*0.01)*C.maxcharge
			if(C.charge < newcharge)
				C.charge = newcharge
				if(isobj(C.loc))
					var/obj/O = C.loc
					O.update_icon() //update power meters and such
				batteries_recharged = 1
		if(batteries_recharged)
			usr << "<span class='notice'>Battery has recovered.</span>"
	..()