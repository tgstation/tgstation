/obj/item/assembly/shock_kit
	name = "electrohelmet assembly"
	desc = "This appears to be made from both an electropack and a helmet."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "shock_kit"
	var/obj/item/clothing/head/helmet/helmet_part = null
	var/obj/item/electropack/electropack_part = null
	atom_size = ITEM_SIZE_HUGE
	flags_1 = CONDUCT_1

/obj/item/assembly/shock_kit/Destroy()
	QDEL_NULL(helmet_part)
	QDEL_NULL(electropack_part)
	return ..()

/obj/item/assembly/shock_kit/Initialize(mapload)
	. = ..()
	if(!helmet_part)
		helmet_part = new(src)
		helmet_part.master = src
	if(!electropack_part)
		electropack_part = new(src)
		electropack_part.master = src

/obj/item/assembly/shock_kit/wrench_act(mob/living/user, obj/item/I)
	..()
	to_chat(user, span_notice("You disassemble [src]."))
	if(helmet_part)
		helmet_part.forceMove(drop_location())
		helmet_part.master = null
		helmet_part = null
	if(electropack_part)
		electropack_part.forceMove(drop_location())
		electropack_part.master = null
		electropack_part = null
	qdel(src)
	return TRUE

/obj/item/assembly/shock_kit/attack_self(mob/user)
	helmet_part.attack_self(user)
	electropack_part.attack_self(user)
	add_fingerprint(user)
	return
