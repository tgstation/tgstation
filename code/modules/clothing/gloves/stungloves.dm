//Brought back as an adminspawn only item... for now

/obj/item/clothing/gloves/stungloves
	desc = "On closer inspection, these are yellow gloves with some kind of device attached to them..."
	name = "budget insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 1.5
	item_color = "yellow"
	var/atk_verb = "stunned"
	var/stunforce = 15 //Stun baton stunforce is 21
	var/energyCost = 100
	var/cell_type = /obj/item/weapon/stock_parts/cell //Contains 1000 charge.
	var/obj/item/weapon/stock_parts/cell/power_supply

/obj/item/clothing/gloves/stungloves/New()
	..()
	overlays += "gloves_wire"
	overlays += "gloves_cell"
	if(cell_type)
		power_supply = new cell_type(src)
	else
		return
	power_supply.give(power_supply.maxcharge)

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/stungloves/Touch(var/atom/A, var/proximity)
	var/mob/living/carbon/human/M = loc
	if(!istype(M)) return 0
	if(proximity && ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.w_uniform)
			H.w_uniform.add_fingerprint(M) //Unless they're wearing something other than stun gloves the prints won't transfer.
		if(!src.power_supply || src.power_supply.charge >= src.energyCost)
			add_logs(M, H, "stunned", object="stun gloves")
			M.do_attack_animation(H)
			if(src.atk_verb)
				H.visible_message("<span class='danger'>[M] has [src.atk_verb] [H]!</span>", \
								"<span class='userdanger'>[M] has [src.atk_verb] [H]!</span>")
			H.Stun(src.stunforce/2)
			H.Weaken(src.stunforce)
			H.apply_effect(STUTTER, src.stunforce)
			if(src.power_supply)
				src.power_supply.use(src.energyCost)
		else if(src.power_supply.charge < src.energyCost)
			add_logs(M, H, "attempted to stun")
			M << "<span class='warning'>Out of charge!</span>"
			H.visible_message("<span class='notice'>[M] has touched [H].</span>", \
							"<span class='notice'>[M] has touched [H].</span>")
		return 1
	return 0