/obj/item/reagent_containers/food/whipped_canister // For when you want your cakes and pies to have a little extra something (bath salts)
	name = "Whipped Cream Canister"
	desc = "An advanced form of condiment spreading, allowing for the foaming of a reagent over a dish."
	icon = 'icons/obj/food/containers.dmi'
	amount_per_transfer_from_this = 2
	volume = 10
	icon_state = "cream_bottle"
	inhand_icon_state = "cream_bottle"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	possible_transfer_amounts = list()
	custom_materials = list(/datum/material/iron=15, /datum/material/glass=15)
	reagent_flags = TRANSPARENT | OPENCONTAINER // Just slap a beaker against it until it's full
	custom_price = 100
	var/whippedcolor = null // Used for changing the whipped pile on top of the food
	var/list/blacklist = list(/obj/item/extinguisher, /obj/item/reagent_containers/syringe) 

/obj/item/reagent_containers/food/whipped_canister/Initialize()
	. = ..()
	create_reagents(volume, OPENCONTAINER)
	if(list_reagents)
		update_icon()

/obj/item/reagent_containers/food/whipped_canister/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/reagent_containers/food/whipped_canister/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/food/whipped_canister/pickup(mob/user)
	. = ..()
	update_icon()

/obj/item/reagent_containers/food/whipped_canister/dropped(mob/user)
	. = ..()
	update_icon()

/obj/item/reagent_containers/food/whipped_canister/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!target.reagents)
		return
	if(isliving(target)) //Sorry fellas, no getting high off pressurized reagents (yet)
		return
	if(is_type_in_list(target, blacklist)) //To make sure nobody can fill fire extinguishers or epipens with bath salts
		return
	whippedcolor = mix_color_from_reagents(reagents.reagent_list) // The color check needs to be here, or the last whipped pile created from a canister will be completely white
	// Always log attemped injections for admins
	var/contained = reagents.log_list()
	log_combat(user, target, "attempted to inject", src, addition="which had [contained]")

	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(target.reagents.total_volume >= target.reagents.maximum_volume)
		to_chat(user, "<span class='notice'>[target] is full.</span>")
		return

	reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user, methods = INJECT)
	to_chat(user, "<span class='notice'>You spray [amount_per_transfer_from_this] units of the solution. The canister now contains [reagents.total_volume] units.</span>")
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6) // pshhhhhhh
	var/obj/item/food/not_container = target
	var/obj/item/reagent_containers/food/snacks/container = target // Some food items are still reagent containers, so this is just in case
	if(istype(not_container) || istype(container))
		var/mutable_appearance/whipped_overlay = mutable_appearance('icons/obj/reagentfillings.dmi', "whipped")
		whipped_overlay.color = whippedcolor // Applies the color of the reagent to the cream pile
		target.add_overlay(whipped_overlay)
	if (reagents.total_volume <= 0)
		update_icon()


/obj/item/reagent_containers/food/whipped_canister/update_overlays()
	. = ..()
	if(reagents)
		var/mutable_appearance/filling_overlay = mutable_appearance('icons/obj/reagentfillings.dmi', "whippedbottle")
		filling_overlay.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling_overlay
		add_overlay(filling_overlay)
