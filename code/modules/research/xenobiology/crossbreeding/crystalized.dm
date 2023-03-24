/obj/item/slimecross/crystalized
	name = "crystalized extract"
	desc = "It's crystalline,"
	effect = "adamantine"
	icon_state = "crystalline"
	var/obj/structure/slime_crystal/crystal_type

/obj/item/slimecross/crystalized/attack_self(mob/user)
	. = ..()
	var/obj/structure/slime_crystal/C = locate() in range(6,get_turf(user))

	if(C)
		to_chat(user,"<span class='notice'>You can't build crystals that close to each other!</span>")
		return

	var/user_turf = get_turf(user)

	if(!do_after(user,15 SECONDS,FALSE,user_turf))
		return

	new crystal_type(user_turf)
	qdel(src)

/obj/item/slimecross/crystalized/grey
	crystal_type = /obj/structure/slime_crystal/grey
	colour = "grey"

/obj/item/slimecross/crystalized/purple
	crystal_type = /obj/structure/slime_crystal/purple
	colour = "purple"

/obj/item/slimecross/crystalized/metal
	crystal_type = /obj/structure/slime_crystal/metal
	colour = "metal"

/obj/item/slimecross/crystalized/yellow
	crystal_type = /obj/structure/slime_crystal/yellow
	colour = "yellow"

/obj/item/slimecross/crystalized/darkblue
	crystal_type = /obj/structure/slime_crystal/darkblue
	colour = "dark blue"

/obj/item/slimecross/crystalized/silver
	crystal_type = /obj/structure/slime_crystal/silver
	colour = "silver"

/obj/item/slimecross/crystalized/bluespace
	crystal_type = /obj/structure/slime_crystal/bluespace
	colour = "bluespace"

/obj/item/slimecross/crystalized/sepia
	crystal_type = /obj/structure/slime_crystal/sepia
	colour = "sepia"

/obj/item/slimecross/crystalized/cerulean
	crystal_type = /obj/structure/slime_crystal/cerulean
	colour = "cerulean"

/obj/item/slimecross/crystalized/pyrite
	crystal_type = /obj/structure/slime_crystal/pyrite
	colour = "pyrite"

/obj/item/slimecross/crystalized/red
	crystal_type = /obj/structure/slime_crystal/red
	colour = "red"

/obj/item/slimecross/crystalized/green
	crystal_type = /obj/structure/slime_crystal/green
	colour = "green"

/obj/item/slimecross/crystalized/pink
	crystal_type = /obj/structure/slime_crystal/pink
	colour = "pink"

/obj/item/slimecross/crystalized/gold
	crystal_type = /obj/structure/slime_crystal/gold
	colour = "gold"

/obj/item/slimecross/crystalized/oil
	crystal_type = /obj/structure/slime_crystal/oil
	colour = "oil"

/obj/item/slimecross/crystalized/black
	crystal_type = /obj/structure/slime_crystal/black
	colour = "black"

/obj/item/slimecross/crystalized/lightpink
	crystal_type = /obj/structure/slime_crystal/lightpink
	colour = "light pink"

/obj/item/slimecross/crystalized/adamantine
	crystal_type = /obj/structure/slime_crystal/adamantine
	colour = "adamantine"

/obj/item/slimecross/crystalized/rainbow
	crystal_type = /obj/structure/slime_crystal/rainbow
	colour = "rainbow"
