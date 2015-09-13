/obj/machinery/media/holojukebox
	name = "Holojukebox"
	desc = "A bastion of goodwill, peace, and hope."
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "jukebox2"
	density = 1

	anchored = 1
	luminosity = 4

	var/html = {"
 <html>
 <head>
 <title>Jukebox</title>
 </head>
 <body bgcolor="black">

 <iframe width="560" height="315" src="https:\\www.youtube.com/embed/XTgFtxHhCQ0" frameborder="0" allowfullscreen></iframe>

 </body>
 </html>

 "}


/obj/machinery/media/holojukebox/attack_hand(var/mob/user)
	var/datum/browser/popup = new(user, "Jukebox", name, 400, 500)
	var/t = html

	popup.set_content(t)
	popup.open()
