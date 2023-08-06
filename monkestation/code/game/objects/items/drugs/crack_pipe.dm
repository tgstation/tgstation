/obj/item/clothing/mask/cigarette/pipe/crackpipe
	name = "crack pipe"
	desc = "A slick glass pipe made for smoking one thing: crack."
	icon = 'monkestation/icons/obj/items/drugs.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	icon_state = "glass_pipeoff"
	icon_on = "glass_pipeon"
	icon_off = "glass_pipeoff"
	chem_volume = 20
	/// A list of drugs you can smoke
	var/list/smokable_drugs = list(
		/obj/item/reagent_containers/crack,
	)

/obj/item/clothing/mask/cigarette/pipe/crackpipe/Initialize(mapload)
	. = ..()
	name = "empty [initial(name)]"

/obj/item/clothing/mask/cigarette/pipe/crackpipe/process(seconds_per_tick)
	smoketime -= seconds_per_tick
	if(smoketime <= 0)
		if(ismob(loc))
			var/mob/living/smoking_mob = loc
			to_chat(smoking_mob, span_notice("Your [name] goes out."))
			lit = FALSE
			icon_state = icon_off
			inhand_icon_state = icon_off
			smoking_mob.update_worn_mask()
			packeditem = FALSE
			name = "empty [initial(name)]"
		STOP_PROCESSING(SSobj, src)
		return
	open_flame()
	if(reagents?.total_volume) // check if it has any reagents at all
		handle_reagents()


/obj/item/clothing/mask/cigarette/pipe/crackpipe/attackby(obj/item/used_item, mob/user, params)
	if(is_type_in_list(used_item, smokable_drugs))
		to_chat(user, span_notice("You stuff [used_item] into [src]."))
		smoketime = 120
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
				to_chat(user, span_warning("There's nothing to smoke!"))
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
