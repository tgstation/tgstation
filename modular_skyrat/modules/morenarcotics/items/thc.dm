/obj/item/reagent_containers/hash
	name = "hash"
	desc = "Concentrated cannabis extract. Delivers a much better high when used in a bong."
	icon = 'modular_skyrat/modules/morenarcotics/icons/crack.dmi'
	icon_state = "hash"
	volume = 20
	possible_transfer_amounts = list()
	list_reagents = list(/datum/reagent/drug/thc = 15, /datum/reagent/toxin/lipolicide = 5)

/obj/item/reagent_containers/hash/dabs
	name = "dab"
	desc = "Oil extract from cannabis plants. Just delivers a different type of hit."
	icon = 'modular_skyrat/modules/morenarcotics/icons/crack.dmi'
	icon_state = "dab"
	volume = 40
	possible_transfer_amounts = list()
	list_reagents = list(/datum/reagent/drug/thc = 40) //horrendously powerful

/obj/item/reagent_containers/hashbrick
	name = "hash brick"
	desc = "A brick of hash. Good for transport!"
	icon = 'modular_skyrat/modules/morenarcotics/icons/crack.dmi'
	icon_state = "hashbrick"
	volume = 25
	possible_transfer_amounts = list()
	list_reagents = list(/datum/reagent/drug/cocaine = 60, /datum/reagent/toxin/lipolicide = 20)


/obj/item/reagent_containers/hashbrick/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user] starts breaking up the [src].</span>")
	if(do_after(user,10))
		to_chat(user, "<span class='notice'>You finish breaking up the [src].</span>")
		for(var/i = 1 to 4)
			new /obj/item/reagent_containers/hash(user.loc)
		qdel(src)

/datum/crafting_recipe/hashbrick
	name = "Hash brick"
	result = /obj/item/reagent_containers/hashbrick
	reqs = list(/obj/item/reagent_containers/hash = 4)
	parts = list(/obj/item/reagent_containers/hash = 4)
	time = 20
	category = CAT_CHEMISTRY

//export values
/datum/export/hash
	cost = CARGO_CRATE_VALUE * 0.35
	unit_name = "hash"
	export_types = list(/obj/item/reagent_containers/hash)
	include_subtypes = FALSE

/datum/export/crack/hashbrick
	cost = CARGO_CRATE_VALUE * 2
	unit_name = "hash brick"
	export_types = list(/obj/item/reagent_containers/hashbrick)
	include_subtypes = FALSE

/datum/export/dab
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "dab"
	export_types = list(/obj/item/reagent_containers/hash/dabs)
	include_subtypes = FALSE
