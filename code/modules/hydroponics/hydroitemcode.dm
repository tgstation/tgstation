/* Hydroponic Item Procs and Stuff
 * Contains:
 * Sunflowers Novaflowers Nettle Deathnettle Corncob
 */

//Sun/Novaflower
/obj/item/weapon/grown/sunflower/attack(mob/M as mob, mob/user as mob)
	M << "<font color='green'><b> [user] smacks you with a sunflower!</font><font color='yellow'><b>FLOWER POWER<b></font>"
	user << "<font color='green'> Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>"

/obj/item/weapon/grown/novaflower/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!..()) return
	if(istype(M, /mob/living))
		M << "\red You are heated by the warmth of the of the [name]!"
		M.bodytemperature += potency / 2 * TEMPERATURE_DAMAGE_COEFFICIENT

/obj/item/weapon/grown/novaflower/afterattack(atom/A as mob|obj, mob/user as mob,proximity)
	if(!proximity) return
	if(endurance > 0)
		endurance -= rand(1, (endurance / 3) + 1)
	else
		usr << "All the petals have fallen off the [name] from violent whacking."
		usr.unEquip(src)
		qdel(src)

/obj/item/weapon/grown/novaflower/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		user << "\red The [name] burns your bare hand!"
		user.adjustFireLoss(rand(1, 5))

//Nettle
/obj/item/weapon/grown/nettle/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		user << "\red The nettle burns your bare hand!"
		if(istype(user, /mob/living/carbon/human))
			var/organ = ((user.hand ? "l_":"r_") + "arm")
			var/obj/item/organ/limb/affecting = user.get_organ(organ)
			if(affecting.take_damage(0, force))
				user.update_damage_overlays(0)
		else
			user.take_organ_damage(0,force)

/obj/item/weapon/grown/nettle/afterattack(atom/A as mob|obj, mob/user as mob,proximity)
	if(!proximity) return
	if(force > 0)
		force -= rand(1, (force / 3) + 1) // When you whack someone with it, leaves fall off
	else
		usr << "All the leaves have fallen off the nettle from violent whacking."
		usr.unEquip(src)
		qdel(src)

/obj/item/weapon/grown/nettle/changePotency(newValue) //-QualityVan
	..()
	force = round((5 + potency / 5), 1)

//Deathnettle
/obj/item/weapon/grown/deathnettle/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		if(istype(user, /mob/living/carbon/human))
			var/organ = ((user.hand ? "l_":"r_") + "arm")
			var/obj/item/organ/limb/affecting = user.get_organ(organ)
			if(affecting.take_damage(0, force))
				user.update_damage_overlays(0)
		else
			user.take_organ_damage(0, force)
		if(prob(50))
			user.Paralyse(5)
			user << "\red You are stunned by the Deathnettle when you try picking it up!"

/obj/item/weapon/grown/deathnettle/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!..()) return
	if(istype(M, /mob/living))
		M << "\red You are stunned by the powerful acid of the Deathnettle!"
		add_logs(user, M, "attacked", object= "[src.name]")

		M.eye_blurry += force/7
		if(prob(20))
			M.Paralyse(force / 6)
			M.Weaken(force / 15)
		M.drop_item()

/obj/item/weapon/grown/deathnettle/afterattack(atom/A as mob|obj, mob/user as mob,proximity)
	if(!proximity) return
	if (force > 0)
		force -= rand(1,(force / 3) + 1) // When you whack someone with it, leaves fall off

	else
		usr << "All the leaves have fallen off the deathnettle from violent whacking."
		usr.unEquip(src)
		qdel(src)

/obj/item/weapon/grown/deathnettle/changePotency(newValue) //-QualityVan
	..()
	force = round((5 + potency / 2.5), 1)


//Corncob
/obj/item/weapon/grown/corncob/attackby(obj/item/weapon/grown/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || istype(W, /obj/item/weapon/kitchen/utensil/knife))
		user << "<span class='notice'>You use [W] to fashion a pipe out of the corn cob!</span>"
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		usr.unEquip(src)
		qdel(src)
		return