/obj/item/organ/genital/womb
	name 			= "womb"
	desc 			= "A female reproductive organ."
	icon			= 'modular_citadel/icons/obj/genitals/vagina.dmi'
	icon_state 		= "womb"
	zone 			= "groin"
	slot 			= "womb"
	w_class 		= 3
	internal 		= TRUE
	fluid_id 		= "femcum"
	producing		= TRUE


/obj/item/organ/genital/womb/Initialize()
	. = ..()
	reagents.add_reagent(fluid_id, fluid_max_volume)

/obj/item/organ/genital/womb/on_life()
	if(QDELETED(src))
		return
	if(reagents && producing)
		generate_femcum()

/obj/item/organ/genital/womb/proc/generate_femcum()
	reagents.maximum_volume = fluid_max_volume
	update_link()
	if(!linked_organ)
		return FALSE
	reagents.isolate_reagent(fluid_id)//remove old reagents if it changed and just clean up generally
	reagents.add_reagent(fluid_id, (fluid_mult * fluid_rate))//generate the cum

/obj/item/organ/genital/womb/update_link()
	if(owner)
		linked_organ = (owner.getorganslot("vagina"))
		if(linked_organ)
			linked_organ.linked_organ = src
	else
		if(linked_organ)
			linked_organ.linked_organ = null
		linked_organ = null

/obj/item/organ/genital/womb/Destroy()
	return ..()
