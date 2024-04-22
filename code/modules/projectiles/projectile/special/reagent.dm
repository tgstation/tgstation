/obj/projectile/reagent
	name = "/proper reagents"
	icon = 'icons/obj/medical/chempuff.dmi'
	icon_state = ""
	damage_type = TOX
	damage = 0
	armor_flag = BIO
	speed = 1.2 // slow projectile
	/// Reagent application methods
	var/transfer_methods = TOUCH
	var/list/reagents_list = list()

/obj/projectile/reagent/Initialize(mapload)
	. = ..()
	create_reagents(1000)

/obj/projectile/reagent/proc/update_reagents()
	if(!reagents.total_volume) // if it didn't already have reagents in it, fill it with the default reagents
		for(var/type in reagents_list)
			reagents.add_reagent(type, reagents_list[type])
	add_atom_colour(mix_color_from_reagents(reagents.reagent_list), FIXED_COLOUR_PRIORITY)

/obj/projectile/reagent/fire(angle, atom/direct_target)
	update_reagents()
	return ..()

/obj/projectile/reagent/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(blocked < 100 && BULLET_ACT_HIT)
		reagents.trans_to(target, reagents.total_volume, methods = transfer_methods)
		return ..()
	reagents.trans_to(get_turf(target), reagents.total_volume, methods = transfer_methods)
	return ..()


/// Water - for water guns! Just some harmless fun... right??
/obj/projectile/reagent/water
	name = "/proper water"
	reagents_list = list(/datum/reagent/water = 10)

/obj/projectile/reagent/water/update_reagents()
	. = ..()
	var/last_volume = 0
	for(var/datum/reagent/R as anything in reagents.reagent_list)
		if(R.volume > last_volume)
			last_volume = R.volume
			name = "[R.name]"
