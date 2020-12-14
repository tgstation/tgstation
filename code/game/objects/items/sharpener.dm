/obj/item/sharpener
	name = "whetstone"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "sharpener"
	desc = "A block that makes things sharp."
	force = 5 //This is how hard the whetstone itself hits stuff
	///If zero, the whetstone can be used. If one, the whetstone is a worn whetstone.
	var/used = 0
	///How much force the whetstone can add to an item.
	var/increment = 4
	///Maximum force sharpening items with the whetstone can result in
	var/max = 30
	///The prefix a whetstone applies when an item is sharpened with it
	var/prefix = "sharpened"
	///If true, the whetstone will only sharpen already sharp items
	var/requires_sharpness = 1

/obj/item/sharpener/attackby(obj/item/I, mob/user, params)
	if(used) //You can't sharpen stuff with a worn whetstone
		to_chat(user, "<span class='warning'>The sharpening block is too worn to use again!</span>")
		return
	if(I.force >= max || I.throwforce >= max) //If we're trying to sharpen an item that already has a force higher than max, we fail
		to_chat(user, "<span class='warning'>[I] is much too powerful to sharpen further!</span>")
		return
	if(requires_sharpness && !I.get_sharpness()) //You can't sharpen an item that isn't sharp with a whetstone that requieres items to be sharp
		to_chat(user, "<span class='warning'>You can only sharpen items that are already sharp, such as knives!</span>")
		return
	if(is_type_in_list(I, list(/obj/item/melee/transforming/energy, /obj/item/dualsaber))) //You can't sharpen photons
		to_chat(user, "<span class='warning'>You don't think \the [I] will be the thing getting modified if you use it on \the [src]!</span>")
		return

	var/signal_out = SEND_SIGNAL(I, COMSIG_ITEM_SHARPEN_ACT, increment, max) //This is used to check more things if the item has a relevant component. As of December 2020, this is only used for two_handed.
	if(signal_out & COMPONENT_BLOCK_SHARPEN_MAXED) //If the item's components enforce more limits on maximum power from sharpening,  we fail
		to_chat(user, "<span class='warning'>[I] is much too powerful to sharpen further!</span>")
		return
	if(signal_out & COMPONENT_BLOCK_SHARPEN_BLOCKED) //Checks for "other" restrictions
		to_chat(user, "<span class='warning'>[I] is not able to be sharpened right now!</span>")
		return
	if((signal_out & COMPONENT_BLOCK_SHARPEN_ALREADY) || (I.force > initial(I.force) && !signal_out)) //No sharpening stuff twice
		to_chat(user, "<span class='warning'>[I] has already been refined before. It cannot be sharpened further!</span>")
		return
	if(!(signal_out & COMPONENT_BLOCK_SHARPEN_APPLIED)) //If the item has a relevant component and COMPONENT_BLOCK_SHARPEN_APPLIED is returned, the item only gets the throw force increase
		I.force = clamp(I.force + increment, 0, max) //We can't end up with a force better than max
		I.wound_bonus = I.wound_bonus + increment //wound_bonus has no cap
	user.visible_message("<span class='notice'>[user] sharpens [I] with [src]!</span>", "<span class='notice'>You sharpen [I], making it much more deadly than before.</span>")
	playsound(src, 'sound/items/unsheath.ogg', 25, TRUE)
	I.sharpness = SHARP_EDGED //When you whetstone something, it becomes an edged weapon, even if it was previously dull or pointy
	I.throwforce = clamp(I.throwforce + increment, 0, max) //We can't end up with a throw force better than max
	I.name = "[prefix] [I.name]" //We add a whetstone-type-dependent prefix to the item.
	name = "worn out [name]" //whetstone becomes used whetstone
	desc = "[desc] At least, it used to."
	used = 1
	update_icon()

/obj/item/sharpener/super //Admin-only whetstone that can turn almost anything into a 200 damage weapon. Turn people into one stab man!
	name = "super whetstone"
	desc = "A block that will make your weapon sharper than Einstein on adderall."
	increment = 200
	max = 200
	prefix = "super-sharpened"
	requires_sharpness = 0 //Super whetstones can sharpen even tooboxes
