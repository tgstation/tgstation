/obj/item/weapon/sharpener
	name = "sharpening block"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	desc = "A block that makes things sharp."
	var/used = 0
	var/increment = 5
	var/max = 15
	var/prefix = "sharpened"


/obj/item/weapon/sharpener/attackby(obj/item/I, mob/user, params)
	if(used)
		user << "<span class='notice'>The sharpening block is too dull to use again.</span>"
		return
	if(I.force >= max || I.throwforce >= max)
		user << "<span class='notice'>[I] is much too powerful to sharpen further.</span>"
		return
	if(istype(I, /obj/item/weapon))
		user << "<span class='notice'>You sharpen [I] with [src], making it much more deadly than before.</span>"
		I.sharpness = IS_SHARP
		I.force = (I.force + increment)
		I.throwforce = (I.throwforce + increment)
		I.name = "[prefix] [I.name]"
		src.name = "dull [src.name]"
		src.desc = "[src.desc] At least, it used to."
		used = 1
		if(I.force > max)//if the item's force exceeds 15 after 5 force is added,
			I.force = max//set it back to 15
		if(I.throwforce > max)//do this again for throwforce
			I.throwforce = max

/obj/item/weapon/sharpener/super
	name = "super sharpening block"
	desc = "A block that will make your weapon sharper than Einstein on adderol."
	increment = 200
	max = 200
	prefix = "super-sharpened"