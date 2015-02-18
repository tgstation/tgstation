/obj/item/voucher
	name = "vendor's voucher"
	desc = "A slip of electropaper used for accessing special features of brand vending machines."
	icon = 'icons/obj/vouchers.dmi'
	icon_state = "voucher"
	w_class = 1
	force = 0
	throwforce = 0

	var/shred_on_use = 1

/obj/item/voucher/free_item
	name = "free products voucher"
	desc = "A slip of electropaper redeemable for any brand product from a particular brand of vending machines."
	var/list/freebies = list() //what we will actually spawn - types
	var/single_items = 0 //if we can only vend each one once
	var/vend_amount = 0 //how many items we make the machine spit out

//Test case
/obj/item/voucher/free_item/hot_drink
	name = "free hot drink voucher"
	desc = "Perk Up Your Day, with this handy free hot drink from your trusted name-brand vending machines."

	freebies = list(/obj/item/weapon/reagent_containers/food/drinks/coffee, /obj/item/weapon/reagent_containers/food/drinks/tea, /obj/item/weapon/reagent_containers/food/drinks/h_chocolate)
	vend_amount = 1
	shred_on_use = 0