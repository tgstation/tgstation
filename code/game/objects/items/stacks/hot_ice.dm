/obj/item/stack/hot_ice
	name = "hot ice"
	icon_state = "hot-ice"
	item_state = "hot-ice"
	singular_name = "hot ice"
	icon = 'icons/obj/stack_objects.dmi'
	custom_materials = list(/datum/material/hot_ice=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/toxin/plasma = 200)
	material_type = /datum/material/hot_ice

/obj/item/stack/hot_ice/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins licking \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return FIRELOSS//dont you kids know that stuff is toxic?

/obj/item/stack/hot_ice/attackby(obj/item/W as obj, mob/user as mob, params)
	if(W.get_temperature() > 300)//If the temperature of the object is over 300, then ignite
		var/turf/T = get_turf(src)
		message_admins("Hot ice ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(T)]")
		log_game("Hot ice ignited by [key_name(user)] in [AREACOORD(T)]")
		fire_act(W.get_temperature())
	else
		return ..()

/obj/item/stack/hot_ice/fire_act(exposed_temperature, exposed_volume)
	atmos_spawn_air("plasma=[amount*50];TEMP=[exposed_temperature]*2")
	qdel(src)
