
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// fossils

/obj/item/weapon/fossil
	name = "Fossil"
	icon = 'fossil.dmi'
	icon_state = "bone"
	desc = "It's a fossil."

/obj/item/weapon/fossil/base/New()
	spawn(0)
		var/list/l = list("/obj/item/weapon/fossil/bone"=8,"/obj/item/weapon/fossil/skull"=2,
		"/obj/item/weapon/fossil/skull/horned"=2,"/obj/item/weapon/fossil/shell"=1)
		var/t = pickweight(l)
		new t(src.loc)
		del src

/obj/item/weapon/fossil/bone
	name = "Fossilised bone"
	icon_state = "bone"
	desc = "It's a fossilised bone."

/obj/item/weapon/fossil/shell
	name = "Fossilised shell"
	icon_state = "shell"
	desc = "It's a fossilised shell."

/obj/item/weapon/fossil/skull/horned
	icon_state = "hskull"
	desc = "It's a fossilised, horned skull."

/obj/item/weapon/fossil/skull
	name = "Fossilised skull"
	icon_state = "skull"
	desc = "It's a fossilised skull."

/obj/item/weapon/fossil/skull/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/fossil/bone))
		var/obj/o = new /obj/skeleton(get_turf(src))
		var/a = new /obj/item/weapon/fossil/bone
		var/b = new src.type
		o.contents.Add(a)
		o.contents.Add(b)
		del W
		del src

/obj/skeleton
	name = "Incomplete skeleton"
	icon = 'fossil.dmi'
	icon_state = "uskel"
	desc = "Incomplete skeleton."
	var/bnum = 1
	var/breq
	var/bstate = 0

/obj/skeleton/New()
	src.breq = rand(6)+3
	src.desc = "An incomplete skeleton, looks like it could use [src.breq-src.bnum] more bones."

/obj/skeleton/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/fossil/bone))
		if(!bstate)
			bnum++
			src.contents.Add(new/obj/item/weapon/fossil/bone)
			del W
			if(bnum==breq)
				usr = user
				icon_state = "skel"
				var/creaturename = input("Input a name for your discovery:","Name your discovery","Spaceosaurus")
				src.bstate = 1
				src.density = 1
				src.name = "[creaturename] skeleton"
				if(src.contents.Find(/obj/item/weapon/fossil/skull/horned))
					src.desc = "A creature made of [src.contents.len-1] assorted bones and a horned skull, the plaque reads [creaturename]."
				else
					src.desc = "A creature made of [src.contents.len-1] assorted bones and a skull, the plaque reads [creaturename]."
			else
				src.desc = "Incomplete skeleton, looks like it could use [src.breq-src.bnum] more bones."
				user << "Looks like it could use [src.breq-src.bnum] more bones."
		else
			..()
	else
		..()
