
/obj/item/weapon/gun/energy/charge
	name = "energy cannon"
	desc = "IMMA FIRING MAH LAZOR"//swkittens pls change this
	canMouseDown = TRUE

/obj/item/weapon/gun/energy/charge/onMouseDown()
	world << "<span class='userdanger'>MouseDown</span>"

/obj/item/weapon/gun/energy/charge/onMouseUp()
	world << "<span class='userdanger'>MouseUp</span>"

/obj/item/weapon/gun/energy/charge/onMouseDrag()
	world << "<span class='userdanger'>MouseDrag</span>"
