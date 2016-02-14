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
		user << "<span class='notice'>The sharpening block is too worn to use again.</span>"
		return
	if(I.force >= max || I.throwforce >= max)
		user << "<span class='notice'>[I] is much too powerful to sharpen further.</span>"
		return
	if(I.block_chance > 0)
		user << "<span class='notice'>Sharpening [I] would make it completely ineffective at blocking. You decide against it.</span>"//blame zilenan
		return
	if(istype(I, /obj/item/weapon))
		user.visible_message("<span class='notice'>[user] sharpens [I] with [src]!</span>", "<span class='notice'>You sharpen [I], making it much more deadly than before.</span>")
		I.sharpness = IS_SHARP
		I.force = Clamp(I.force + increment, 0, max)
		I.throwforce = Clamp(I.throwforce + increment, 0, max)
		I.name = "[prefix] [I.name]"
		name = "worn out [name]"
		desc = "[desc] At least, it used to."
		used = 1

/obj/item/weapon/sharpener/super
	name = "super sharpening block"
	desc = "A block that will make your weapon sharper than Einstein on adderall."
	increment = 200
	max = 200
	prefix = "super-sharpened"