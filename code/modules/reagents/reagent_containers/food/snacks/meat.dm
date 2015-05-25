//The one and only meat, king of foods

/obj/item/weapon/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/weapon/reagent_containers/food/snacks/meat/human
	name = " meat" //Griffon McDumbass meat
	var/subjectname = ""
	var/subjectjob = null

/obj/item/weapon/reagent_containers/food/snacks/meat/monkey
	//Same as plain meat

/obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."
	
/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken
	name = "raw chicken"
	desc = "This better be delicious."
	icon_state = "raw_chicken"

/obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/New()
	..()
	reagents.add_reagent("nutriment", 3)
	bitesize = 1
	
/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat"
	icon_state = "fishfillet"
	New()
		..()
		eatverb = pick("bite","chew","choke down","gnaw","swallow","chomp")
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("carpotoxin", 3)
		bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/meat/carpmeat/imitation
	name = "imitation carp fillet"
	desc = "Almost just like the real thing, kinda."
	
/obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
	name = "xenomeat"
	desc = "A slab of xeno meat"
	icon_state = "xenomeat"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		src.bitesize = 6
		
/obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat
	name = "spider meat"
	desc = "A slab of spider meat."
	icon_state = "spidermeat"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("toxin", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	New()
		..()
		reagents.add_reagent("nutriment", 12)
		reagents.add_reagent("hyperzine", 5)
		src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"

/obj/item/weapon/reagent_containers/food/snacks/meat/egg/New()
		..()
		reagents.add_reagent("nutriment", 1)

/obj/item/weapon/reagent_containers/food/snacks/meat/egg/throw_impact(atom/hit_atom)
		..()
		new/obj/effect/decal/cleanable/egg_smudge(src.loc)
		src.reagents.reaction(hit_atom, TOUCH)
		src.visible_message("<span class='warning'>[src.name] has been squashed.</span>","<span class='warning'>You hear a smack.</span>")
		del(src)

/obj/item/weapon/reagent_containers/food/snacks/meat/egg/blue
	icon_state = "egg-blue"
	_color = "blue"

/obj/item/weapon/reagent_containers/food/snacks/meat/egg/green
	icon_state = "egg-green"
	_color = "green"

/obj/item/weapon/reagent_containers/food/snacks/meat/egg/mime
	icon_state = "egg-mime"
	_color = "mime"

/obj/item/weapon/reagent_containers/food/snacks/meat/egg/orange
	icon_state = "egg-orange"
	_color = "orange"

/obj/item/weapon/reagent_containers/food/snacks/meat/egg/purple
	icon_state = "egg-purple"
	_color = "purple"

/obj/item/weapon/reagent_containers/food/snacks/meat/egg/rainbow
	icon_state = "egg-rainbow"
	_color = "rainbow"

/obj/item/weapon/reagent_containers/food/snacks/meat/egg/red
	icon_state = "egg-red"
	_color = "red"

/obj/item/weapon/reagent_containers/food/snacks/meat/egg/yellow
	icon_state = "egg-yellow"
	_color = "yellow"

/obj/item/weapon/reagent_containers/food/snacks/meat/egg/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/reagent_containers))
		if(W.reagents.amount_cache.len == 1 && W.reagents.has_reagent("flour", 5))
			W.reagents.remove_reagent("flour",5)
			new /obj/item/weapon/reagent_containers/food/snacks/dough(src)
			user << "You make some dough."
			qdel(src)
			return 1
	else if (istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		var/clr = C.colourName

		if(!(clr in list("blue", "green", "mime", "orange", "purple", "rainbow", "red", "yellow")))
			user << "<span class='notice'>[src] refuses to take on this colour!</span>"
			return

		user << "<span class='notice'>You colour [src] [clr].</span>"
		icon_state = "egg-[clr]"
		_color = clr
	else
		..()
