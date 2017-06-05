/obj/item/weapon/cartridge/virus
	name = "Generic Virus PDA cart"
	desc = "If you see this, let a coder know that there is a generic PDA virus cart."
	var/charges = 5

obj/item/weapon/cartridge/virus/proc/send_virus(obj/item/device/pda/target, mob/living/U)
	return

/obj/item/weapon/cartridge/virus/syndicate
	name = "\improper Detomatix cartridge"
	icon_state = "cart"
	access_remote_door = 1
	remote_door_id = "smindicate" //Make sure this matches the syndicate shuttle's shield/door id!!	//don't ask about the name, testing.
	charges = 4

/obj/item/weapon/cartridge/virus/syndicate/send_virus(obj/item/device/pda/target, mob/living/U)
	if(charges <= 0)
		to_chat(U, "<span class='notice'>Out of charges.</span>")
		return
	if(!isnull(target) && !target.toff)
		charges--
		var/difficulty = 0
		if(target.cartridge)
			difficulty += target.cartridge.access_medical
			difficulty += target.cartridge.access_security
			difficulty += target.cartridge.access_engine
			difficulty += target.cartridge.access_clown
			difficulty += target.cartridge.access_janitor
			difficulty += target.cartridge.access_manifest * 2
		else
			difficulty += 2
		if(prob(difficulty * 15) || (target.hidden_uplink))
			U.show_message("<span class='danger'>An error flashes on your [src].</span>", 1)
		else
			U.show_message("<span class='notice'>Success!</span>", 1)
			target.explode()
	else
		to_chat(U, "PDA not found.")

/obj/item/weapon/cartridge/virus/clown
	name = "\improper Honkworks 5.0 cartridge"
	icon_state = "cart-clown"
	desc = "A data cartridge for portable microcomputers. It smells vaguely of banannas"
	access_clown = 1

/obj/item/weapon/cartridge/virus/clown/send_virus(obj/item/device/pda/target, mob/living/U)
	if(charges <= 0)
		to_chat(U, "<span class='notice'>Out of charges.</span>")
		return
	if(!isnull(target) && !target.toff)
		charges--
		to_chat(U, "<span class='notice'>Virus Sent!</span>")
		target.honkamt = (rand(15,20))
	else
		to_chat(U, "PDA not found.")

/obj/item/weapon/cartridge/virus/mime
	name = "\improper Gestur-O 1000 cartridge"
	icon_state = "cart-mi"
	access_mime = 1

/obj/item/weapon/cartridge/virus/mime/send_virus(obj/item/device/pda/target, mob/living/U)
	if(charges <= 0)
		to_chat(U, "<span class='notice'>Out of charges.</span>")
		return
	if(!isnull(target) && !target.toff)
		charges--
		to_chat(U, "<span class='notice'>Virus Sent!</span>")
		target.silent = 1
		target.ttone = "silence"
	else
		to_chat(U, "PDA not found.")