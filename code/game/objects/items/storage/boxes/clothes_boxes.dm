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

//it needs to be linked, hence a kit.
/obj/item/storage/box/rxglasses/spyglasskit
	name = "spyglass kit"
	desc = "this box contains <i>cool</i> nerd glasses; with built-in displays to view a linked camera."

/obj/item/storage/box/rxglasses/spyglasskit/PopulateContents()
	var/obj/item/clothing/accessory/spy_bug/newbug = new(src)
	var/obj/item/clothing/glasses/sunglasses/spy/newglasses = new(src)
	newbug.linked_glasses = newglasses
	newglasses.linked_bug = newbug
	new /obj/item/paper/fluff/nerddocs(src)

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

/obj/item/storage/box/hero
	name = "Courageous Tomb Raider - 1940's."
	desc = "This legendary figure of still dubious historical accuracy is thought to have been a world-famous archeologist who embarked on countless adventures in far away lands, along with his trademark whip and fedora hat."

/obj/item/storage/box/hero/PopulateContents()
	new /obj/item/clothing/head/fedora/curator(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/suit/jacket/curator(src)
	new /obj/item/clothing/under/rank/civilian/curator/treasure_hunter(src)
	new /obj/item/melee/curator_whip(src)

/obj/item/storage/box/hero/astronaut
	name = "First Man on the Moon - 1960's."
	desc = "One small step for a man, one giant leap for mankind. Relive the beginnings of space exploration with this fully functional set of vintage EVA equipment."

/obj/item/storage/box/hero/astronaut/PopulateContents()
	new /obj/item/clothing/suit/space/nasavoid(src)
	new /obj/item/clothing/head/helmet/space/nasavoid(src)
	new /obj/item/tank/internals/oxygen(src)
	new /obj/item/gps(src)

/obj/item/storage/box/hero/scottish
	name = "Braveheart, the Scottish rebel - 1300's."
	desc = "Seemingly a legendary figure in the battle for Scottish independence, this historical figure is closely associated with blue facepaint, big swords, strange man skirts, and his ever enduring catchphrase: 'FREEDOM!!'"

/obj/item/storage/box/hero/scottish/PopulateContents()
	new /obj/item/claymore/weak/ceremonial(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/under/costume/kilt(src)
	new /obj/item/toy/crayon/spraycan(src)

/obj/item/storage/box/hero/carphunter
	name = "Carp Hunter, Wildlife Expert - 2506."
	desc = "Despite his nickname, this wildlife expert was mainly known as a passionate environmentalist and conservationist, often coming in contact with dangerous wildlife to teach about the beauty of nature."

/obj/item/storage/box/hero/carphunter/PopulateContents()
	new /obj/item/clothing/mask/gas/carp(src)
	new /obj/item/clothing/suit/hooded/carp_costume/spaceproof/old(src)
	new /obj/item/knife/hunting(src)
	new /obj/item/storage/box/papersack/meat(src)

/obj/item/storage/box/hero/mothpioneer
	name = "Mothic Fleet Pioneer - 2429."
	desc = "Some claim that the fleet engineers are directly responsible for most modern advancements in spacefaring designs. Although the exact details of their past contributions are somewhat fuzzy, their ingenuity remains unmatched and unquestioned to this day."

/obj/item/storage/box/hero/mothpioneer/PopulateContents()
	new /obj/item/clothing/head/mothcap/original(src)
	new /obj/item/clothing/suit/mothcoat/original(src)
	new /obj/item/crowbar(src)
	new /obj/item/flashlight/lantern(src)
	new /obj/item/screwdriver(src)
	new /obj/item/stack/sheet/glass/fifty(src)
	new /obj/item/stack/sheet/iron/fifty(src)
	new /obj/item/wrench(src)

/obj/item/storage/box/hero/etherealwarden
	name = "Ethereal Trailwarden - 2450's."
	desc = "Many fantastical stories are told of valiant trail wardens, even by offworlders who, thanks to their guidance, avoided an untimely demise while traveling the sometimes treacherous roads of Sprout. In truth their job entails far more walking and fixing roads than slaying dragons, but it is no less important and well respected: keeping the roads and trails safe and well maintained is for many settlements a matter of survival."

/obj/item/storage/box/hero/etherealwarden/PopulateContents()
	new /obj/item/clothing/suit/hooded/ethereal_raincoat/trailwarden(src)
	new /obj/item/clothing/under/ethereal_tunic/trailwarden(src)
	new /obj/item/storage/backpack/saddlepack(src)

/obj/item/storage/box/hero/journalist
	name = "Assassinated by CIA - 1984." // Literally
	desc = "Many courageous individuals risked their lives to report on events the government sought to keep hidden from the public, ensuring that the truth remained buried and unheard. These garments are replicas of the clothing worn by one such 'journalist,' a silent sentinel in the fight for truth."

/obj/item/storage/box/hero/journalist/PopulateContents()
	new /obj/item/clothing/under/costume/buttondown/slacks(src)
	new /obj/item/clothing/suit/toggle/suspenders(src)
	new /obj/item/clothing/neck/tie/red(src)
	new /obj/item/clothing/head/fedora/beige/press(src)
	new /obj/item/clothing/accessory/press_badge(src)
	new /obj/item/clothing/suit/hazardvest/press(src)
	new /obj/item/radio/entertainment/microphone/physical(src)
	new /obj/item/radio/entertainment/speakers/physical(src)
	new /obj/item/clipboard(src)
	new /obj/item/taperecorder(src)
	new /obj/item/camera(src)
	new /obj/item/wallframe/telescreen/entertainment(src)

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
	new /obj/item/clothing/gloves/bracer(src)

/obj/item/storage/box/holy/follower
	name = "Followers of the Chaplain Kit"
	typepath_for_preview = /obj/item/clothing/suit/hooded/chaplain_hoodie/leader

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

/obj/item/storage/box/itemset/crusader/blue/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/crusader/blue(src)
	new /obj/item/clothing/head/helmet/plate/crusader/blue(src)
	new /obj/item/clothing/gloves/plate/blue(src)
	new /obj/item/clothing/shoes/plate/blue(src)

/obj/item/storage/box/itemset/crusader/red/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/crusader/red(src)
	new /obj/item/clothing/head/helmet/plate/crusader/red(src)
	new /obj/item/clothing/gloves/plate/red(src)
	new /obj/item/clothing/shoes/plate/red(src)

/obj/item/storage/box/wizard_kit
	name = "Generic Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/PopulateContents()
	new /obj/item/clothing/head/wizard(src)
	new /obj/item/clothing/suit/wizrobe(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/red
	name = "Evocation Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/red/PopulateContents()
	new /obj/item/clothing/head/wizard/red(src)
	new /obj/item/clothing/suit/wizrobe/red(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/yellow
	name = "Translocation Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/yellow/PopulateContents()
	new /obj/item/clothing/head/wizard/yellow(src)
	new /obj/item/clothing/suit/wizrobe/yellow(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/magusred
	name = "Conjuration Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/yellow/PopulateContents()
	new /obj/item/clothing/head/wizard/magus(src)
	new /obj/item/clothing/suit/wizrobe/magusred(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/magusblue
	name = "Transmutation Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/yellow/PopulateContents()
	new /obj/item/clothing/head/wizard/magus(src)
	new /obj/item/clothing/suit/wizrobe/magusblue(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/wizard_kit/black
	name = "Necromancy Wizard Cosplay Kit"

/obj/item/storage/box/wizard_kit/black/PopulateContents()
	new /obj/item/clothing/head/wizard/black(src)
	new /obj/item/clothing/suit/wizrobe/black(src)
	new /obj/item/clothing/shoes/sandal(src)
