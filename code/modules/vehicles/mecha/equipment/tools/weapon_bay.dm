/obj/item/mecha_parts/concealed_weapon_bay
	name = "concealed weapon bay"
	desc = "A compartment that allows a non-combat mecha to equip one weapon while hiding the weapon from plain sight."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_weapon_bay"

/obj/item/mecha_parts/concealed_weapon_bay/try_attach_part(mob/user, obj/vehicle/sealed/mecha/M)
	if(istype(M, /obj/vehicle/sealed/mecha/combat))
		to_chat(user, span_warning("[M] can already hold weapons!"))
		return
	if(locate(/obj/item/mecha_parts/concealed_weapon_bay) in M.contents)
		to_chat(user, span_warning("[M] already has a concealed weapon bay!"))
		return
	return ..()
