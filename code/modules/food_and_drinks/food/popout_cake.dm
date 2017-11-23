//This is in it's own file because of the awful amount of extra shitcode it has compared to normal cake

/obj/item/reagent_containers/food/snacks/store/cake/popout
	name = "large cake"
	desc = "An enormous multi-tiered cake."
	icon_state = "popoutcake"
	w_class = WEIGHT_CLASS_GIGANTIC
	bonus_reagents = list("nutriment" = 15, "vitamin" = 5)
	tastes = list("vanilla" = 1, "sweetness" = 2,"cake" = 5)
	foodtype = GRAIN | DAIRY | SUGAR
	slices_num = 16
	var/current_slices = 16
	var/atom/movable/thing_inside

/obj/item/reagent_containers/food/snacks/store/cake/popout/Destroy()
	. = ..()
	thing_inside.forceMove(loc)

/obj/item/reagent_containers/food/snacks/store/cake/popout/slice(accuracy, obj/item/W, mob/user)
	if(current_slices > 0)
		var/obj/item/reagent_containers/food/snacks/cakeslice/plain/slice = new(loc)
		initialize_slice(slice, reagents.total_volume/slices_num)
		current_slices--
	else
		visible_message("<span class='notice'>[user] cuts off the last slice of \the [src].</span>")
		qdel(src)

/obj/item/reagent_containers/food/snacks/store/cake/popout/MouseDrop_T(atom/movable/O, mob/living/user)
	if(!QDELETED(thing_inside) && istype(thing_inside))
		return
	if(O == user)
		visible_message("<span class='notice'>[user] begins climbing into \the [src]</span>")
	else
		visible_message("<span class='notice'>[user] begins putting \the [O] into \the [src]</span>")
	if(do_after_mob(user, list(O, src), 50))
		O.forceMove(src)
		thing_inside = O

/obj/item/reagent_containers/food/snacks/store/cake/popout/proc/emerge()
	playsound(get_turf(src), 'sound/effects/party_horn.ogg', 50, 1)
	visible_message("<span class='notice'>All of a sudden, something emerges from \the [src]!</span>")
	thing_inside.forceMove(loc)
	thing_inside = null

/obj/item/reagent_containers/food/snacks/store/cake/popout/proc/pull_string()
	set name = "Pull Party String"
	set desc = "Activate a simple mechanism that lifts you out of the cake."
	set category = "Object"
	set src = usr.loc

	if(!isturf(loc))
		return

	var/mob/living/L = usr
	if(!istype(L))
		return

	if(L.incapacitated())
		return

	if(string_pulled)
		to_chat(L, "<span class='info'>The string has already been pulled!</span>")
		return

	to_chat(L, "<span class='info'>You pull on the party string!</span>")

	emerge()