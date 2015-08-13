/obj/item/clothing/tie
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "bluetie"
	item_state = ""	//no inhands
	item_color = "bluetie"
	slot_flags = 0
	w_class = 2.0

/obj/item/clothing/tie/blue
	name = "blue tie"
	icon_state = "bluetie"
	item_color = "bluetie"

/obj/item/clothing/tie/red
	name = "red tie"
	icon_state = "redtie"
	item_color = "redtie"

/obj/item/clothing/tie/black
	name = "black tie"
	icon_state = "blacktie"
	item_color = "blacktie"

/obj/item/clothing/tie/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"
	item_color = "horribletie"

/obj/item/clothing/tie/waistcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "waistcoat"
	item_state = "waistcoat"
	item_color = "waistcoat"

/obj/item/clothing/tie/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"
	item_color = "stethoscope"

/obj/item/clothing/tie/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		if(user.a_intent == "help")
			var/body_part = parse_zone(user.zone_sel.selecting)
			if(body_part)
				var/their = "their"
				switch(M.gender)
					if(MALE)	their = "his"
					if(FEMALE)	their = "her"

				var/sound = "pulse"
				var/sound_strength

				if(M.stat == DEAD || (M.status_flags&FAKEDEATH))
					sound_strength = "cannot hear"
					sound = "anything"
				else
					sound_strength = "hear a weak"
					switch(body_part)
						if("chest")
							if(M.oxyloss < 50)
								sound_strength = "hear a healthy"
							sound = "pulse and respiration"
						if("eyes","mouth")
							sound_strength = "cannot hear"
							sound = "anything"
						else
							sound_strength = "hear a weak"

				user.visible_message("[user] places [src] against [M]'s [body_part] and listens attentively.", "You place [src] against [their] [body_part]. You [sound_strength] [sound].")
				return
	return ..(M,user)

//////////
//Medals//
//////////

/obj/item/clothing/tie/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	item_color = "bronze"
	burn_state = -1 //Won't burn in fires

//Pinning medals on people
/obj/item/clothing/tie/medal/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && (user.a_intent == "help"))

		if(M.wear_suit)
			if((M.wear_suit.flags_inv & HIDEJUMPSUIT)) //Check if the jumpsuit is covered
				user << "<span class='warning'>Medals can only be pinned on jumpsuits.</span>"
				return

		if(M.w_uniform)
			var/obj/item/clothing/under/U = M.w_uniform
			if(U.attachTie(src, user, 0)) //Attach it, do not notify the user of the attachment
				if(user == M)
					user << "<span class='notice'>You attach [src] to [U].</span>"
				else
					user.visible_message("[user] pins \the [src] on [M]'s chest.", \
										 "<span class='notice'>You pin \the [src] on [M]'s chest.</span>")

		else user << "<span class='warning'>Medals can only be pinned on jumpsuits!</span>"
	else ..()

/obj/item/clothing/tie/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is most basic award given by Nanotrasen. It is often awarded by a captain to a member of his crew."

/obj/item/clothing/tie/medal/bronze_heart
	name = "bronze heart medal"
	desc = "A bronze heart-shaped medal awarded for sacrifice. It is often awarded posthumously or for severe injury in the line of duty."
	icon_state = "bronze_heart"

/obj/item/clothing/tie/medal/nobel_science
	name = "nobel sciences award"
	desc = "A bronze medal which represents significant contributions to the field of science or engineering."

/obj/item/clothing/tie/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	item_color = "silver"

/obj/item/clothing/tie/medal/silver/valor
	name = "medal of valor"
	desc = "A silver medal awarded for acts of exceptional valor."

/obj/item/clothing/tie/medal/silver/security
	name = "robust security award"
	desc = "An award for distinguished combat and sacrifice in defence of Nanotrasen's commercial interests. Often awarded to security staff."

/obj/item/clothing/tie/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	item_color = "gold"

/obj/item/clothing/tie/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."

/obj/item/clothing/tie/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by Centcom. To receive such a medal is the highest honor and as such, very few exist. This medal is almost never awarded to anybody but commanders."

////////////
//Armbands//
////////////

/obj/item/clothing/tie/armband
	name = "red armband"
	desc = "An fancy red armband!"
	icon_state = "redband"
	item_color = "redband"

/obj/item/clothing/tie/armband/deputy
	name = "security deputy armband"
	desc = "An armband, worn by personnel authorized to act as a deputy of station security."

/obj/item/clothing/tie/armband/cargo
	name = "cargo bay guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is brown."
	icon_state = "cargoband"
	item_color = "cargoband"

/obj/item/clothing/tie/armband/engine
	name = "engineering guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is orange with a reflective strip!"
	icon_state = "engieband"
	item_color = "engieband"

/obj/item/clothing/tie/armband/science
	name = "science guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is purple."
	icon_state = "rndband"
	item_color = "rndband"

/obj/item/clothing/tie/armband/hydro
	name = "hydroponics guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is green and blue."
	icon_state = "hydroband"
	item_color = "hydroband"

/obj/item/clothing/tie/armband/med
	name = "medical guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is white."
	icon_state = "medband"
	item_color = "medband"

/obj/item/clothing/tie/armband/medblue
	name = "medical guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is white and blue."
	icon_state = "medblueband"
	item_color = "medblueband"

///////////
//SCARVES//
///////////

/obj/item/clothing/tie/scarf
	name = "scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."

/obj/item/clothing/tie/scarf/red
	name = "red scarf"
	icon_state = "redscarf"
	item_color = "redscarf"

/obj/item/clothing/tie/scarf/green
	name = "green scarf"
	icon_state = "greenscarf"
	item_color = "greenscarf"

/obj/item/clothing/tie/scarf/darkblue
	name = "dark blue scarf"
	icon_state = "darkbluescarf"
	item_color = "darkbluescarf"

/obj/item/clothing/tie/scarf/purple
	name = "purple scarf"
	icon_state = "purplescarf"
	item_color = "purplescarf"

/obj/item/clothing/tie/scarf/yellow
	name = "yellow scarf"
	icon_state = "yellowscarf"
	item_color = "yellowscarf"

/obj/item/clothing/tie/scarf/orange
	name = "orange scarf"
	icon_state = "orangescarf"
	item_color = "orangescarf"

/obj/item/clothing/tie/scarf/lightblue
	name = "light blue scarf"
	icon_state = "lightbluescarf"
	item_color = "lightbluescarf"

/obj/item/clothing/tie/scarf/white
	name = "white scarf"
	icon_state = "whitescarf"
	item_color = "whitescarf"

/obj/item/clothing/tie/scarf/black
	name = "black scarf"
	icon_state = "blackscarf"
	item_color = "blackscarf"

/obj/item/clothing/tie/scarf/zebra
	name = "zebra scarf"
	icon_state = "zebrascarf"
	item_color = "zebrascarf"

/obj/item/clothing/tie/scarf/christmas
	name = "christmas scarf"
	icon_state = "christmasscarf"
	item_color = "christmasscarf"

//The three following scarves don't have the scarf subtype
//This is because Ian can equip anything from that subtype
//However, these 3 don't have corgi versions of their sprites
/obj/item/clothing/tie/stripedredscarf
	name = "striped red scarf"
	icon_state = "stripedredscarf"
	item_color = "stripedredscarf"

/obj/item/clothing/tie/stripedgreenscarf
	name = "striped green scarf"
	icon_state = "stripedgreenscarf"
	item_color = "stripedgreenscarf"

/obj/item/clothing/tie/stripedbluescarf
	name = "striped blue scarf"
	icon_state = "stripedbluescarf"
	item_color = "stripedbluescarf"

/obj/item/clothing/tie/petcollar //don't really wear this though please c'mon seriously guys
	name = "pet collar"
	desc = "It's for pets. Though you probably could wear it yourself, you'd doubtless be the subject of ridicule."
	icon_state = "petcollar"
	item_color = "petcollar"
	var/tagname = null

/obj/item/clothing/tie/petcollar/attack_self(mob/user)
	tagname = copytext(sanitize(input(user, "Would you like to change the name on the tag?", "Name your new pet", "Spot") as null|text),1,MAX_NAME_LEN)
	name = "[initial(name)] - [tagname]"