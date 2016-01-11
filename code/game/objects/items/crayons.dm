//List of all drawable graffitis. Their icon states are associated with icon states (so for example "Chaos Undivided" = "chaos")
var/global/list/all_graffitis = list(
	"Left arrow"="left",
	"Right arrow"="right",
	"Up arrow"="up",
	"Down arrow"="down",
	"Heart"="heart",
	"Lambda"="lambda",
	"50 blessings"="50bless",
	"Engineer"="engie",
	"Guy"="guy",
	"The end is nigh"="end",
	"Amy + Jon"="amyjon",
	"Matt was here"="matt",
	"Revolution"="revolution",
	"Face"="face",
	"Dwarf"="dwarf",
	"Uboa"="uboa",
	"Rogue cyborgs"="borgsrogue",
	"Shitcurity"="shitcurity",
	"Catbeast here"="catbeast",
	"Vox are pox"="voxpox",
	"Hieroglyphs 1"="hieroglyphs1",
	"Hieroglyphs 2"="hieroglyphs2",
	"Hieroglyphs 3"="hieroglyphs3",
	"Securites eunt domus"="security",
	"Nanotrasen logo"="nanotrasen",
	"Syndicate logo 1"="syndicate1",
	"Syndicate logo 2"="syndicate2",
	"Don't believe these lies"="lie",
	"Chaos Undivided"="chaos"
)

/obj/item/toy/crayon/red
	icon_state = "crayonred"
	colour = "#DA0000"
	shadeColour = "#810C0C"
	colourName = "red"

/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	colour = "#FF9300"
	shadeColour = "#A55403"
	colourName = "orange"

/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	colour = "#FFF200"
	shadeColour = "#886422"
	colourName = "yellow"

/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	colour = "#A8E61D"
	shadeColour = "#61840F"
	colourName = "green"

/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	colour = "#00B7EF"
	shadeColour = "#0082A8"
	colourName = "blue"

/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	colour = "#DA00FF"
	shadeColour = "#810CFF"
	colourName = "purple"

/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	colour = "#FFFFFF"
	shadeColour = "#000000"
	colourName = "mime"
	uses = 0

/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob) //inversion
	if(colour != "#FFFFFF" && shadeColour != "#000000")
		colour = "#FFFFFF"
		shadeColour = "#000000"
		to_chat(user, "You will now draw in white and black with this crayon.")
	else
		colour = "#000000"
		shadeColour = "#FFFFFF"
		to_chat(user, "You will now draw in black and white with this crayon.")
	return

/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	colour = "#FFF000"
	shadeColour = "#000FFF"
	colourName = "rainbow"
	uses = 0

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	colour = input(user, "Please select the main colour.", "Crayon colour") as color
	shadeColour = input(user, "Please select the shade colour.", "Crayon colour") as color
	return

/obj/item/toy/crayon/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return

	if(istype(target, /turf/simulated))
		var/drawtype = input("Choose what you'd like to draw.", "Crayon scribbles") in list("graffiti","rune","letter")
		var/preference
		switch(drawtype)
			if("letter")
				drawtype = input("Choose the letter.", "Crayon scribbles") in list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
				to_chat(user, "You start drawing a letter on the [target.name].")
			if("graffiti")
				var/list/graffitis = list("Random" = "graffiti") + all_graffitis
				if(istype(user,/mob/living/carbon/human))
					var/mob/living/carbon/human/M=user
					if(M.getBrainLoss() >= 60)
						graffitis = list(
							"Cancel"="cancel",
							"Dick"="dick[rand(1,3)]",
							"Valids"="valid"
							)
				preference = input("Choose the graffiti.", "Crayon scribbles") as null|anything in graffitis

				if(!preference) return

				drawtype=graffitis[preference]
				to_chat(user, "You start drawing graffiti on the [target.name].")
			if("rune")
				to_chat(user, "You start drawing a rune on the [target.name].")

		if(!user.Adjacent(target)) return
		if(target.density && !cardinal.Find(get_dir(user, target))) //Drawing on a wall and not standing in a cardinal direction - don't draw
			to_chat(user, "<span class='warning'>You can't reach \the [target] from here!</span>")
			return

		if(instant || do_after(user,target, 50))
			var/obj/effect/decal/cleanable/C = new /obj/effect/decal/cleanable/crayon(target,colour,shadeColour,drawtype)

			if(target.density && (C.loc != get_turf(user))) //Drawn on a wall (while standing on a floor)
				C.forceMove(get_turf(user))

				var/angle = dir2angle_t(get_dir(C, target))

				C.pixel_x = 32 * cos(angle)
				C.pixel_y = 32 * sin(angle) //Offset the graffiti to make it appear on the wall
				C.on_wall = target

			to_chat(user, "You finish drawing.")
			target.add_fingerprint(user)		// Adds their fingerprints to the floor the crayon is drawn on.
			if(uses)
				uses--
				if(!uses)
					to_chat(user, "<span class='warning'>You used up your crayon!</span>")
					qdel(src)
	return

/obj/item/toy/crayon/attack(mob/M as mob, mob/user as mob)
	if(M == user)
		to_chat(user, "You take a bite of the crayon. Delicious!")
		user.nutrition += 5
		if(uses)
			uses -= 5
			if(uses <= 0)
				to_chat(user, "<span class='warning'>You ate your crayon!</span>")
				qdel(src)
	else
		..()
