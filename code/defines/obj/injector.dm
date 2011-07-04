/obj/item/weapon/dnainjector
	name = "DNA-Injector"
	desc = "This injects the person with DNA."
	icon = 'items.dmi'
	icon_state = "dnainjector"
	var/dnatype = null
	var/dna = null
	var/block = null
	var/owner = null
	var/ue = null
	var/s_time = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/uses = 1
	var/nofail
	var/is_bullet = 0

/obj/item/weapon/dnainjector/antihulk
	name = "DNA-Injector (Anti-Hulk)"
	desc = "Cures green skin."
	dnatype = "se"
	dna = "708"
	//block = 2
	New()
		..()
		block = HULKBLOCK

/obj/item/weapon/dnainjector/hulkmut
	name = "DNA-Injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	dnatype = "se"
	dna = "FED"
	//block = 2
	New()
		..()
		block = HULKBLOCK

/obj/item/weapon/dnainjector/xraymut
	name = "DNA-Injector (Xray)"
	desc = "Finally you can see what the Captain does."
	dnatype = "se"
	dna = "FED"
	//block = 8
	New()
		..()
		block = XRAYBLOCK

/obj/item/weapon/dnainjector/antixray
	name = "DNA-Injector (Anti-Xray)"
	desc = "It will make you see harder."
	dnatype = "se"
	dna = "708"
	//block = 8
	New()
		..()
		block = XRAYBLOCK

/////////////////////////////////////
/obj/item/weapon/dnainjector/antiglasses
	name = "DNA-Injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	dnatype = "se"
	dna = "708"
	block = 1

/obj/item/weapon/dnainjector/glassesmut
	name = "DNA-Injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	dnatype = "se"
	dna = "BD6"
	block = 1

/obj/item/weapon/dnainjector/epimut
	name = "DNA-Injector (Epi.)"
	desc = "Shake shake shake the room!"
	dnatype = "se"
	dna = "FA0"
	block = 3

/obj/item/weapon/dnainjector/antiepi
	name = "DNA-Injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	dnatype = "se"
	dna = "708"
	block = 3
////////////////////////////////////
/obj/item/weapon/dnainjector/anticough
	name = "DNA-Injector (Anti-Cough)"
	desc = "Will stop that aweful noise."
	dnatype = "se"
	dna = "708"
	block = 5

/obj/item/weapon/dnainjector/coughmut
	name = "DNA-Injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	dnatype = "se"
	dna = "BD6"
	block = 5

/obj/item/weapon/dnainjector/clumsymut
	name = "DNA-Injector (Clumsy)"
	desc = "Makes clown minions."
	dnatype = "se"
	dna = "FA0"
	//block = 6
	New()
		..()
		block = CLUMSYBLOCK

/obj/item/weapon/dnainjector/anticlumsy
	name = "DNA-Injector (Anti-Clumy)"
	desc = "Apply this for Security Clown."
	dnatype = "se"
	dna = "708"
	//block = 6
	New()
		..()
		block = CLUMSYBLOCK

/obj/item/weapon/dnainjector/antitour
	name = "DNA-Injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	dnatype = "se"
	dna = "708"
	block = 7

/obj/item/weapon/dnainjector/tourmut
	name = "DNA-Injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	dnatype = "se"
	dna = "BD6"
	block = 7

/obj/item/weapon/dnainjector/stuttmut
	name = "DNA-Injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"
	dnatype = "se"
	dna = "FA0"
	block = 9

/obj/item/weapon/dnainjector/antistutt
	name = "DNA-Injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	dnatype = "se"
	dna = "708"
	block = 9

/obj/item/weapon/dnainjector/antifire
	name = "DNA-Injector (Anti-Fire)"
	desc = "Cures fire."
	dnatype = "se"
	dna = "708"
	//block = 10
	New()
		..()
		block = FIREBLOCK

/obj/item/weapon/dnainjector/firemut
	name = "DNA-Injector (Fire)"
	desc = "Gives you fire."
	dnatype = "se"
	dna = "FED"
	//block = 10
	New()
		..()
		block = FIREBLOCK

/obj/item/weapon/dnainjector/blindmut
	name = "DNA-Injector (Blind)"
	desc = "Makes you not see anything."
	dnatype = "se"
	dna = "FA0"
	//block = 11
	New()
		..()
		block = BLINDBLOCK

/obj/item/weapon/dnainjector/antiblind
	name = "DNA-Injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	dnatype = "se"
	dna = "708"
	//block = 11
	New()
		..()
		block = BLINDBLOCK

/obj/item/weapon/dnainjector/antitele
	name = "DNA-Injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	dnatype = "se"
	dna = "708"
	//block = 12
	New()
		..()
		block = TELEBLOCK

/obj/item/weapon/dnainjector/telemut
	name = "DNA-Injector (Tele.)"
	desc = "Super brain man!"
	dnatype = "se"
	dna = "FED"
	//block = 12
	New()
		..()
		block = TELEBLOCK

/obj/item/weapon/dnainjector/deafmut
	name = "DNA-Injector (Deaf)"
	desc = "Sorry, what did you say?"
	dnatype = "se"
	dna = "FA0"
	//block = 13
	New()
		..()
		block = DEAFBLOCK

/obj/item/weapon/dnainjector/antideaf
	name = "DNA-Injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	dnatype = "se"
	dna = "708"
	//block = 13
	New()
		..()
		block = DEAFBLOCK

/obj/item/weapon/dnainjector/h2m
	name = "DNA-Injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	dnatype = "se"
	dna = "FA0"
	block = 14

/obj/item/weapon/dnainjector/m2h
	name = "DNA-Injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	dnatype = "se"
	dna = "708"
	block = 14