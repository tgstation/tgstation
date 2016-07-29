<<<<<<< HEAD
/obj/item/weapon/implant/uplink
	name = "uplink implant"
	desc = "Sneeki breeki."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	origin_tech = "materials=4;magnets=4;programming=4;biotech=4;syndicate=5;bluespace=5"

/obj/item/weapon/implant/uplink/New()
	hidden_uplink = new(src)
	hidden_uplink.telecrystals = 10
	..()

/obj/item/weapon/implant/uplink/implant(mob/user)
	var/obj/item/weapon/implant/imp_e = locate(src.type) in user
	if(imp_e && imp_e != src)
		imp_e.hidden_uplink.telecrystals += hidden_uplink.telecrystals
		qdel(src)
		return 1

	if(..())
		hidden_uplink.owner = "[user.key]"
		return 1
	return 0

/obj/item/weapon/implant/uplink/activate()
	if(hidden_uplink)
		hidden_uplink.interact(usr)

/obj/item/weapon/implanter/uplink
	name = "implanter (uplink)"

/obj/item/weapon/implanter/uplink/New()
	imp = new /obj/item/weapon/implant/uplink(src)
	..()
=======
/obj/item/weapon/implant/uplink
	name = "uplink"
	desc = "Summon things."
	var/activation_emote = "chuckle"

/obj/item/weapon/implant/uplink/New()
	activation_emote = pick("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	hidden_uplink = new(src)
	hidden_uplink.uses = 5
	..()
	return

/obj/item/weapon/implant/uplink/implanted(mob/source)
	activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	source.mind.store_memory("Uplink implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
	to_chat(source, "The implanted uplink implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")
	return 1


/obj/item/weapon/implant/uplink/trigger(emote, mob/source as mob)
	if(hidden_uplink && usr == source) // Let's not have another people activate our uplink
		hidden_uplink.check_trigger(source, emote, activation_emote)
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
