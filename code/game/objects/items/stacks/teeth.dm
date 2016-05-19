/obj/item/stack/teeth
	name = "teeth"
	singular_name = "tooth"
	irregular_plural = "teeth"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "tooth"
	amount = 1
	max_amount = 50
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 10

	var/animal_type

/obj/item/stack/teeth/New(loc, amount)
	.=..()
	pixel_x = rand(-24,24)
	pixel_y = rand(-24,24)

/obj/item/stack/teeth/can_stack_with(obj/item/other_stack)
	if(!istype(other_stack)) return 0

	if(src.type == other_stack.type)
		var/obj/item/stack/teeth/T = other_stack
		if(src.animal_type == T.animal_type)
			return 1
	return 0

/obj/item/stack/teeth/attackby(obj/item/W, mob/user)
	.=..()

	if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W

		if(src.amount < 10)
			to_chat(user, "<span class='info'>You need at least 10 teeth to create a necklace.</span>")
			return

		if(C.use(5))
			user.drop_item(src, force_drop = 1)

			var/obj/item/clothing/mask/necklace/teeth/X = new(get_turf(src))

			X.animal_type = src.animal_type
			X.teeth_amount = amount
			X.update_name()
			user.put_in_active_hand(X)
			to_chat(user, "<span class='info'>You create a [X.name] out of [amount] [src] and \the [C].</span>")

			qdel(src)
		else
			to_chat(user, "<span class='info'>You need at least 5 lengths of cable to do this!</span>")

/obj/item/stack/teeth/copy_evidences(obj/item/stack/from as obj)
	.=..()
	if(istype(from, /obj/item/stack/teeth))
		var/obj/item/stack/teeth/original_teeth = from
		src.animal_type = original_teeth.animal_type
		src.name = original_teeth.name
		src.singular_name = original_teeth.name

/obj/item/stack/teeth/proc/update_name(mob/parent)
	if(!parent) return

	if(isliving(parent))
		var/mob/living/L = parent
		var/mob/parent_species = L.species_type
		var/parent_species_name = initial(parent_species.name)

		if(ishuman(parent))
			var/mob/living/carbon/human/H = parent
			if(H.species)
				parent_species_name = lowertext(H.species.name)
			else
				parent_species_name = "human"

		name = "[parent_species_name] teeth"
		singular_name = "[parent_species_name] tooth"
		animal_type = parent_species
