/obj/item/knife/poison
	name = "venom knife"
	icon = 'icons/obj/weapons/stabby.dmi'
	icon_state = "buckknife"
	worn_icon_state = "buckknife"
	force = 12
	throwforce = 15
	throw_speed = 5
	throw_range = 7
	var/amount_per_transfer_from_this = 10
	var/list/possible_transfer_amounts
	desc = "An infamous knife of syndicate design, \
	it has a tiny hole going through the blade to the handle which stores toxins. \
	Use in-hand to to increase or decrease its transfer amount. \
	Each hit has a 40% chance to transfer reagents from knife's internal storage to your victim"


/obj/item/knife/poison/Initialize(mapload)
	. = ..()
	create_reagents(40,OPENCONTAINER)
	possible_transfer_amounts = list(5, 10)

/obj/item/knife/poison/attack_self(mob/user)
	if(possible_transfer_amounts.len)
		var/i=0
		for(var/A in possible_transfer_amounts)
			i++
			if(A == amount_per_transfer_from_this)
				if(i<possible_transfer_amounts.len)
					amount_per_transfer_from_this = possible_transfer_amounts[i+1]
				else
					amount_per_transfer_from_this = possible_transfer_amounts[1]
				balloon_alert(user, "Transferring [amount_per_transfer_from_this]u.")
				to_chat(user, "<span class='notice'>[src]'s transfer amount is now [amount_per_transfer_from_this] units.</span>")
				return

/obj/item/knife/poison/afterattack(mob/living/M, mob/user)
	if(!istype(M))
		return
	if(reagents?.total_volume && M.reagents && prob(40))
		reagents.trans_to(M, amount_per_transfer_from_this)
	else
		return ..()
