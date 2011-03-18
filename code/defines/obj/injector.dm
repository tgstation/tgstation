/obj/item/weapon/dnainjector
	name = "DNA-Injector"
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
	dnatype = "se"
	dna = "708"
	//block = 2
	New()
		..()
		block = HULKBLOCK

/obj/item/weapon/dnainjector/hulkmut
	name = "DNA-Injector (Hulk)"
	dnatype = "se"
	dna = "FED"
	//block = 2
	New()
		..()
		block = HULKBLOCK

/obj/item/weapon/dnainjector/xraymut
	name = "DNA-Injector (Xray)"
	dnatype = "se"
	dna = "FED"
	//block = 8
	New()
		..()
		block = XRAYBLOCK

/obj/item/weapon/dnainjector/antixray
	name = "DNA-Injector (Anti-Xray)"
	dnatype = "se"
	dna = "708"
	//block = 8
	New()
		..()
		block = XRAYBLOCK

/////////////////////////////////////
/obj/item/weapon/dnainjector/antiglasses
	name = "DNA-Injector (Anti-Glasses)"
	dnatype = "se"
	dna = "708"
	block = 1

/obj/item/weapon/dnainjector/glassesmut
	name = "DNA-Injector (Glasses)"
	dnatype = "se"
	dna = "BD6"
	block = 1

/obj/item/weapon/dnainjector/epimut
	name = "DNA-Injector (Epi.)"
	dnatype = "se"
	dna = "FA0"
	block = 3

/obj/item/weapon/dnainjector/antiepi
	name = "DNA-Injector (Anti-Epi.)"
	dnatype = "se"
	dna = "708"
	block = 3
////////////////////////////////////
/obj/item/weapon/dnainjector/anticough
	name = "DNA-Injector (Anti-Cough)"
	dnatype = "se"
	dna = "708"
	block = 5

/obj/item/weapon/dnainjector/coughmut
	name = "DNA-Injector (Cough)"
	dnatype = "se"
	dna = "BD6"
	block = 5

/obj/item/weapon/dnainjector/clumsymut
	name = "DNA-Injector (Clumsy)"
	dnatype = "se"
	dna = "FA0"
	//block = 6
	New()
		..()
		block = CLUMSYBLOCK

/obj/item/weapon/dnainjector/anticlumsy
	name = "DNA-Injector (Anti-Clumy)"
	dnatype = "se"
	dna = "708"
	//block = 6
	New()
		..()
		block = CLUMSYBLOCK

/obj/item/weapon/dnainjector/antitour
	name = "DNA-Injector (Anti-Tour.)"
	dnatype = "se"
	dna = "708"
	block = 7

/obj/item/weapon/dnainjector/tourmut
	name = "DNA-Injector (Tour.)"
	dnatype = "se"
	dna = "BD6"
	block = 7

/obj/item/weapon/dnainjector/stuttmut
	name = "DNA-Injector (Stutt.)"
	dnatype = "se"
	dna = "FA0"
	block = 9

/obj/item/weapon/dnainjector/antistutt
	name = "DNA-Injector (Anti-Stutt.)"
	dnatype = "se"
	dna = "708"
	block = 9

/obj/item/weapon/dnainjector/antifire
	name = "DNA-Injector (Anti-Fire)"
	dnatype = "se"
	dna = "708"
	//block = 10
	New()
		..()
		block = FIREBLOCK

/obj/item/weapon/dnainjector/firemut
	name = "DNA-Injector (Fire)"
	dnatype = "se"
	dna = "FED"
	//block = 10
	New()
		..()
		block = FIREBLOCK

/obj/item/weapon/dnainjector/blindmut
	name = "DNA-Injector (Blind)"
	dnatype = "se"
	dna = "FA0"
	//block = 11
	New()
		..()
		block = BLINDBLOCK

/obj/item/weapon/dnainjector/antiblind
	name = "DNA-Injector (Anti-Blind)"
	dnatype = "se"
	dna = "708"
	//block = 11
	New()
		..()
		block = BLINDBLOCK

/obj/item/weapon/dnainjector/antitele
	name = "DNA-Injector (Anti-Tele.)"
	dnatype = "se"
	dna = "708"
	//block = 12
	New()
		..()
		block = TELEBLOCK

/obj/item/weapon/dnainjector/telemut
	name = "DNA-Injector (Tele.)"
	dnatype = "se"
	dna = "FED"
	//block = 12
	New()
		..()
		block = TELEBLOCK

/obj/item/weapon/dnainjector/deafmut
	name = "DNA-Injector (Deaf)"
	dnatype = "se"
	dna = "FA0"
	//block = 13
	New()
		..()
		block = DEAFBLOCK

/obj/item/weapon/dnainjector/antideaf
	name = "DNA-Injector (Anti-Deaf)"
	dnatype = "se"
	dna = "708"
	//block = 13
	New()
		..()
		block = DEAFBLOCK

/obj/item/weapon/dnainjector/h2m
	name = "DNA-Injector (Human > Monkey)"
	dnatype = "se"
	dna = "FA0"
	block = 14

/obj/item/weapon/dnainjector/m2h
	name = "DNA-Injector (Monkey > Human)"
	dnatype = "se"
	dna = "708"
	block = 14