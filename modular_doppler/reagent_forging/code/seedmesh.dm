/obj/item/seed_mesh
	name = "seed mesh"
	desc = "A little mesh that, when paired with sand, has the possibility of filtering out large seeds."
	icon = 'modular_doppler/reagent_forging/icons/obj/misc_tools.dmi'
	icon_state = "mesh"
	var/list/static/seeds_blacklist = list(
		/obj/item/seeds/lavaland,
		/obj/item/seeds/gatfruit,
		/obj/item/seeds/seedling/evil,
	)

/obj/item/seed_mesh/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/ore_item = attacking_item
		if(ore_item.points == 0)
			user.balloon_alert(user, "[ore_item] is worthless!")
			return

		while(ore_item.amount >= 5)
			if(!do_after(user, 2 SECONDS, src))
				user.balloon_alert(user, "have to stand still!")
				return

			if(!ore_item.use(5))
				user.balloon_alert(user, "unable to use five of [ore_item]!")
				return

			if(prob(50))
				user.balloon_alert(user, "[ore_item] reveals nothing!")
				continue

			var/spawn_seed = pick(subtypesof(/obj/item/seeds) - seeds_blacklist)
			new spawn_seed(get_turf(src))
			user.balloon_alert(user, "[ore_item] revealed something!")

	return ..()
