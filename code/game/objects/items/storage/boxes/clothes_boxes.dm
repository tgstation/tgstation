// This contains all boxes that will possess something wearable, like an outfit or something similar.area

/obj/item/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains sterile latex gloves."
	illustration = "latex"

/obj/item/storage/box/gloves/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/gloves/latex(src)

/obj/item/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains sterile medical masks."
	illustration = "sterile"

/obj/item/storage/box/masks/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/mask/surgical(src)

/obj/item/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	illustration = "glasses"

/obj/item/storage/box/rxglasses/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/glasses/regular(src)

/obj/item/storage/box/tape_wizard
	name = "Tape Wizard - Episode 23"
	desc = "A box containing the costume used by legendary entertainment icon 'Super Tape Wizard'. It got a little stuck on its way out."

/obj/item/storage/box/tape_wizard/PopulateContents()
	new /obj/item/clothing/head/wizard/tape/fake(src)
	new /obj/item/clothing/suit/wizrobe/tape/fake(src)
	new /obj/item/staff/tape(src)
	new /obj/item/stack/sticky_tape(src)

/obj/item/storage/box/fakesyndiesuit
	name = "boxed replica space suit and helmet"
	desc = "A sleek, sturdy box used to hold toy spacesuits."
	icon_state = "syndiebox"
	illustration = "syndiesuit"

/obj/item/storage/box/fakesyndiesuit/PopulateContents()
	new /obj/item/clothing/head/syndicatefake(src)
	new /obj/item/clothing/suit/syndicatefake(src)

/obj/item/storage/box/syndie_kit/battle_royale
	name = "rumble royale broadcast kit"
	desc = "Contains everything you need to host the galaxy's greatest show; Rumble Royale."

/obj/item/storage/box/syndie_kit/battle_royale/PopulateContents()
	var/obj/item/royale_implanter/implanter = new(src)
	var/obj/item/royale_remote/remote = new(src)
	remote.link_implanter(implanter)

/obj/item/storage/box/deputy
	name = "box of deputy armbands"
	desc = "To be issued to those authorized to act as deputy of security."
	icon_state = "secbox"
	illustration = "depband"

/obj/item/storage/box/deputy/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/accessory/armband/deputy(src)

/obj/item/storage/box/holy
	name = "Templar Kit"
	/// This item is used to generate a preview image for this set.
	/// It could be any item, doesn't even necessarily need to be something in the kit
	var/obj/item/typepath_for_preview = /obj/item/clothing/suit/chaplainsuit/armor/templar

/obj/item/storage/box/holy/PopulateContents()
	new /obj/item/clothing/head/helmet/chaplain(src)
	new /obj/item/clothing/suit/chaplainsuit/armor/templar(src)

/obj/item/storage/box/holy/clock
	name = "Forgotten kit"
	typepath_for_preview = /obj/item/clothing/suit/chaplainsuit/armor/clock

/obj/item/storage/box/holy/clock/PopulateContents()
	new /obj/item/clothing/head/helmet/chaplain/clock(src)
	new /obj/item/clothing/suit/chaplainsuit/armor/clock(src)

/obj/item/storage/box/holy/student
	name = "Profane Scholar Kit"
	typepath_for_preview = /obj/item/clothing/suit/chaplainsuit/armor/studentuni

/obj/item/storage/box/holy/student/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/studentuni(src)
	new /obj/item/clothing/head/helmet/chaplain/cage(src)

/obj/item/storage/box/holy/sentinel
	name = "Stone Sentinel Kit"
	typepath_for_preview = /obj/item/clothing/suit/chaplainsuit/armor/ancient

/obj/item/storage/box/holy/sentinel/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/ancient(src)
	new /obj/item/clothing/head/helmet/chaplain/ancient(src)

/obj/item/storage/box/holy/witchhunter
	name = "Witchhunter Kit"
	typepath_for_preview = /obj/item/clothing/suit/chaplainsuit/armor/witchhunter

/obj/item/storage/box/holy/witchhunter/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/witchhunter(src)
	new /obj/item/clothing/head/helmet/chaplain/witchunter_hat(src)

/obj/item/storage/box/holy/adept
	name = "Divine Adept Kit"
	typepath_for_preview = /obj/item/clothing/suit/chaplainsuit/armor/adept

/obj/item/storage/box/holy/adept/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/adept(src)
	new /obj/item/clothing/head/helmet/chaplain/adept(src)

/obj/item/storage/box/holy/follower
	name = "Followers of the Chaplain Kit"
	typepath_for_preview = /obj/item/clothing/suit/hooded/chaplain_hoodie/leader

/obj/item/storage/box/holy/follower/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 16
	atom_storage.set_holdable(/obj/item/clothing/suit/hooded/chaplain_hoodie)

/obj/item/storage/box/holy/follower/PopulateContents()
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/leader(src)

/obj/item/storage/box/holy/divine_archer
	name = "Divine Archer Kit"
	typepath_for_preview = /obj/item/clothing/suit/hooded/chaplain_hoodie/divine_archer

/obj/item/storage/box/holy/divine_archer/PopulateContents()
	new /obj/item/clothing/under/rank/civilian/chaplain/divine_archer(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/divine_archer(src)
	new /obj/item/clothing/gloves/divine_archer(src)
	new /obj/item/clothing/shoes/divine_archer(src)

/obj/item/storage/box/floor_camo
	name = "floor tile camo box"
	desc = "Thank you for shopping from Camo-J's, our uniquely designed \
		floor-tile 'NT scum' styled camouflage fatigues is the ultimate \
		espionage uniform used by the very best. Providing the best \
		flexibility, with our latest Camo-tech threads. Perfect for \
		risky-espionage hallway operations. Enjoy our product!"

/obj/item/storage/box/floor_camo/PopulateContents()
	new /obj/item/clothing/under/syndicate/floortilecamo(src)
	new /obj/item/clothing/mask/floortilebalaclava(src)
	new /obj/item/clothing/gloves/combat/floortile(src)
	new /obj/item/clothing/shoes/jackboots/floortile(src)
	new /obj/item/storage/backpack/floortile(src)

/obj/item/storage/box/collar_bomb
	name = "collar bomb box"
	desc = "A small print on the back reads 'For research purposes only. Handle with care. In case of emergency, call the following number:'... the rest is scratched out with a marker..."

/obj/item/storage/box/collar_bomb/PopulateContents()
	var/obj/item/collar_bomb_button/button = new(src)
	new /obj/item/clothing/neck/collar_bomb(src, button)
