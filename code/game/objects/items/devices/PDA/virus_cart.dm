/obj/item/weapon/cartridge/virus
	name = "Generic Virus PDA cart"
	var/charges = 5

/obj/item/weapon/cartridge/virus/proc/send_virus(obj/item/device/pda/target, mob/living/U)
	return

/obj/item/weapon/cartridge/virus/message_header()
	return "<b>[charges] viral files left.</b><HR>"
	
/obj/item/weapon/cartridge/virus/message_special(obj/item/device/pda/target)
	if (!istype(loc, /obj/item/device/pda))
		return ""  //Sanity check, this shouldn't be possible.
	return " (<a href='byond://?src=\ref[loc];choice=cart;special=virus;target=\ref[target]'>*Send Virus*</a>)"

/obj/item/weapon/cartridge/virus/special(mob/living/user, list/params)
	var/obj/item/device/pda/P = locate(params["target"])//Leaving it alone in case it may do something useful, I guess.
	send_virus(P,user)

/obj/item/weapon/cartridge/virus/clown
	name = "\improper Honkworks 5.0 cartridge"
	icon_state = "cart-clown"
	desc = "A data cartridge for portable microcomputers. It smells vaguely of banannas"
	access = CART_CLOWN

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
	access = CART_MIME

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

/obj/item/weapon/cartridge/virus/syndicate
	name = "\improper Detomatix cartridge"
	icon_state = "cart"
	access = CART_REMOTE_DOOR
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
			difficulty += BitCount(target.cartridge.access&(CART_MEDICAL | CART_SECURITY | CART_ENGINE | CART_CLOWN | CART_JANITOR | CART_MANIFEST))
		if(target.cartridge.access & CART_MANIFEST) 
			difficulty++ //if cartridge has manifest access it has extra snowflake difficulty
		else
			difficulty += 2
		if(!target.detonatable || prob(difficulty * 15) || (target.hidden_uplink))
			U.show_message("<span class='danger'>An error flashes on your [src].</span>", 1)
		else
			U.show_message("<span class='notice'>Success!</span>", 1)
			target.explode()
	else
		to_chat(U, "PDA not found.")

/obj/item/weapon/cartridge/virus/frame
	name = "\improper F.R.A.M.E. cartridge"
	icon_state = "cart"
	var/telecrystals = 0

/obj/item/weapon/cartridge/virus/frame/send_virus(obj/item/device/pda/target, mob/living/U)
	if(charges <= 0)
		to_chat(U, "<span class='notice'>Out of charges.</span>")
		return
	if(!isnull(target) && !target.toff)
		charges--
		var/lock_code = "[rand(100,999)] [pick("Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juliet","Kilo","Lima","Mike","November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X-ray","Yankee","Zulu")]"
		to_chat(U, "<span class='notice'>Virus Sent!  The unlock code to the target is: [lock_code]</span>")
		if(!target.hidden_uplink)
			var/obj/item/device/uplink/uplink = new(target)
			target.hidden_uplink = uplink
			target.lock_code = lock_code
		else
			target.hidden_uplink.hidden_crystals += target.hidden_uplink.telecrystals //Temporarially hide the PDA's crystals, so you can't steal telecrystals.
		target.hidden_uplink.telecrystals = telecrystals
		telecrystals = 0
		target.hidden_uplink.active = TRUE
	else
		to_chat(U, "PDA not found.")
