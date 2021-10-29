/obj/item/clothing/mask/cigarette/pipe/crackpipe
	name = "crack pipe"
	desc = "A slick glass pipe made for smoking one thing: crack."
	icon = 'modular_skyrat/modules/morenarcotics/icons/crack.dmi'
	worn_icon = 'modular_skyrat/modules/morenarcotics/icons/mask.dmi'
	icon_state = "glass_pipeoff" //it seems like theres some unused crack pipe sprite in masks.dmi, sweet!
	inhand_icon_state = "glass_pipeoff"
	icon_on = "glass_pipeon"
	icon_off = "glass_pipeoff"
	chem_volume = 20

/obj/item/clothing/mask/cigarette/pipe/crackpipe/process(delta_time)
	smoketime -= delta_time
	if(smoketime <= 0)
		if(ismob(loc))
			var/mob/living/smoking_mob = loc
			to_chat(smoking_mob, "<span class='notice'>Your [name] goes out.</span>")
			lit = FALSE
			icon_state = icon_off
			inhand_icon_state = icon_off
			smoking_mob.update_inv_wear_mask()
			packeditem = FALSE
			name = "empty [initial(name)]"
		STOP_PROCESSING(SSobj, src)
		return
	open_flame()
	if(reagents?.total_volume) // check if it has any reagents at all
		handle_reagents()


/obj/item/clothing/mask/cigarette/pipe/crackpipe/attackby(obj/item/used_item, mob/user, params)
	if(is_type_in_list(used_item, list(/obj/item/reagent_containers/crack,/obj/item/reagent_containers/blacktar)))
		to_chat(user, "<span class='notice'>You stuff [used_item] into [src].</span>")
		smoketime = 2 * 60
		name = "[used_item.name]-packed [initial(name)]"
		if(used_item.reagents)
			used_item.reagents.trans_to(src, used_item.reagents.total_volume, transfered_by = user)
		qdel(used_item)
	else
		var/lighting_text = used_item.ignition_effect(src,user)
		if(lighting_text)
			if(smoketime > 0)
				light(lighting_text)
			else
				to_chat(user, "<span class='warning'>There is nothing to smoke!</span>")
		else
			return ..()

/datum/crafting_recipe/crackpipe
	name = "Crack pipe"
	result = /obj/item/clothing/mask/cigarette/pipe/crackpipe
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/shard = 1,
				/obj/item/stack/rods = 10)
	parts = list(/obj/item/shard = 1)
	time = 20
	category = CAT_CHEMISTRY
