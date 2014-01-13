/obj/item/weapon/reagent_containers/bucket
	name = "bucket"
	desc = "It's a bucket."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	m_amt = 200
	g_amt = 0
	w_class = 3.0
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,50,100,200)
	volume = 200
	flags = OPENCONTAINER

	var/list/can_be_placed_into = list(
		/obj/structure/table,
		/obj/structure/closet,
		/obj/item/weapon/storage,
		/obj/item/weapon/storage/secure/safe,
		/obj/machinery/disposal,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/hostile/retaliate/goat
	)

	examine()
		set src in view()
		..()
		if(!(usr in view(2)) && usr != loc)
			return
		if(reagents && reagents.reagent_list.len)
			usr << "It contains:"
			for(var/datum/reagent/R in reagents.reagent_list)
				usr << "[R.volume] units of [R.name]"

	afterattack(obj/target, mob/user, proximity)
		if(!proximity) return // not adjacent
		for(var/type in can_be_placed_into)
			if(istype(target, type))
				return

		if(ismob(target) && target.reagents && reagents.total_volume)
			var/mob/M = target
			var/R
			target.visible_message("<span class='danger'>[target] has been splashed with something by [user]!</span>", \
							"<span class='userdanger'>[target] has been splashed with something by [user]!</span>")
			if(reagents)
				for(var/datum/reagent/A in reagents.reagent_list)
					R += A.id + " ("
					R += num2text(A.volume) + "),"
			add_logs(user, M, "splashed", object="[R]")
			reagents.reaction(target, TOUCH)
			spawn(5) reagents.clear_reagents()
			return

		else if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume && target.reagents)
				user << "<span class='notice'>[target] is empty.</span>"
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "<span class='notice'>[src] is full.</span>"
				return

			var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
			user << "<span class='notice'>You fill [src] with [trans] unit\s of the contents of [target].</span>"

		else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "<span class='notice'>[src] is empty.</span>"
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "<span class='notice'>[target] is full.</span>"
				return

			var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
			user << "<span class='notice'>You transfer [trans] unit\s of the solution to [target].</span>"

		//Safety for dumping stuff into a ninja suit. It handles everything through attackby() and this is unnecessary.	//gee thanks noize
		else if(istype(target, /obj/item/clothing/suit/space/space_ninja))
			return

		else if(reagents.total_volume)
			user << "<span class='notice'>You splash the solution onto [target].</span>"
			reagents.reaction(target, TOUCH)
			spawn(5)
				reagents.clear_reagents()

	attackby(var/obj/D, mob/user as mob)
		if(isprox(D))
			user << "<span class='notice'>You add [D] to [src].</span>"
			del(D)
			user.put_in_hands(new /obj/item/weapon/bucket_sensor)
			user.drop_from_inventory(src)
			del(src)
