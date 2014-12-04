var/global/list/datum/stack_recipe/rod_recipes = list ( \
	new/datum/stack_recipe("grille", /obj/structure/grille, 2, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("table frame", /obj/structure/table_frame, 2, time = 10, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	flags = CONDUCT
	w_class = 3.0
	force = 9.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	m_amt = 1000
	max_amount = 60
	attack_verb = list("hit", "bludgeoned", "whacked")
	hitsound = 'sound/weapons/grenadelaunch.ogg'

/obj/item/stack/rods/New(var/loc, var/amount=null)
	recipes = rod_recipes
	return ..()

/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(get_amount() < 2)
			user << "<span class='warning'>You need at least two rods to do this.</span>"
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/new_item = new(usr.loc)
			new_item.add_to_stacks(usr)
			user.visible_message("<span class='warning'>[user.name] shaped [src] into metal with the weldingtool.</span>", \
						 "<span class='notice'>You shaped [src] into metal with the weldingtool.</span>", \
						 "<span class='warning'>You hear welding.</span>")
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_hand()==R)
			R.use(2)
			if (!R && replace)
				user.put_in_hands(new_item)
		return
	..()

/obj/item/stack/rods/cyborg/
	m_amt = 0
	is_cyborg = 1
	cost = 250