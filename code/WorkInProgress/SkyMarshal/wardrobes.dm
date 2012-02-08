/obj/item/wardrobe
	name = "wardrobe"
	desc = "A standard-issue bag for clothing and equipment. Usually comes sealed, stocked with everything you need for a particular job."
	icon = 'suits.dmi'
	icon_state = "wardrobe_sealed"
	item_state = "wardrobe"
	w_class = 4
	layer = 2.9
	var
		descriptor = "various clothing"
		seal_torn = 0

	attack_self(mob/user)
		if(!contents.len)
			user << "It's empty!"
		else
			user.visible_message("\blue [user] unwraps the clothing from the [src][seal_torn ? "" : ", tearing the seal"].")
			seal_torn = 1

			for(var/obj/item/I in src)
				I.loc = get_turf(src)
			update_icon()
		return

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		if(istype(I, /obj/item/wardrobe))
			return
		if(contents.len < 20)
			if(istype(I, /obj/item/weapon/grab))
				return
			user.drop_item()

			if(I)
				I.loc = src

			update_icon()
		else
			user << "\red There's not enough space to fit that!"
		return

	examine()
		set src in usr
		..()
		usr << "It claims to contain [contents.len ? descriptor : descriptor + "... but it looks empty"]."
		if(seal_torn && !contents.len)
			usr << "The seal on the bag is broken."
		else
			usr << "The seal on the bag is[seal_torn ? ", however, not intact" : " intact"]."
		return

	update_icon()
		if(contents.len)
			icon_state = "wardrobe"
		else
			icon_state = "wardrobe_empty"
		return

	New()
		..()
		pixel_x = rand(0,4) -2
		pixel_y = rand(0,4) -2

/obj/item/wardrobe/assistant
	name = "assistant wardrobe"
	descriptor = "clothing and basic equipment for an assistant"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda(src)
		new /obj/item/device/radio/headset(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/under/color/grey(src)

/obj/item/wardrobe/chief_engineer
	name = "Chief Engineer wardrobe"
	descriptor = "clothing and basic equipment for a Chief Engineer"

	New()
		..()
		var/obj/item/weapon/storage/backpack/industrial/BPK = new /obj/item/weapon/storage/backpack/industrial(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/heads/ce(src)
		new /obj/item/device/multitool(src)
		new /obj/item/device/flash(src)
		new /obj/item/clothing/head/helmet/hardhat/white(src)
		new /obj/item/clothing/head/helmet/welding(src)
		new /obj/item/weapon/storage/belt/utility/full(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/clothing/suit/hazardvest(src)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/clothing/glasses/meson(src)
		new /obj/item/device/radio/headset/heads/ce(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/clothing/under/rank/chief_engineer(src)

/obj/item/wardrobe/engineer
	name = "Station Engineer wardrobe"
	descriptor = "clothing and basic equipment for a Station Engineer"

	New()
		..()
		var/obj/item/weapon/storage/backpack/industrial/BPK = new /obj/item/weapon/storage/backpack/industrial(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/engineering(src)
		new /obj/item/device/t_scanner(src)
		new /obj/item/clothing/suit/hazardvest(src)
		new /obj/item/weapon/storage/belt/utility/full(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/clothing/head/helmet/hardhat(src)
		new /obj/item/clothing/glasses/meson(src)
		new /obj/item/device/radio/headset/headset_eng(src)
		new /obj/item/clothing/shoes/orange(src)
		new /obj/item/clothing/under/rank/engineer(src)

/obj/item/wardrobe/atmos
	name = "Atmospheric Technician wardrobe"
	descriptor = "clothing and basic equipment for an Atmospheric Technician"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/engineering(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/device/radio/headset/headset_eng(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/under/rank/atmospheric_technician(src)

/obj/item/wardrobe/roboticist
	name = "Roboticist wardrobe"
	descriptor = "clothing and basic equipment for a Roboticist"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/engineering(src)
		new /obj/item/weapon/storage/toolbox/mechanical(src)
		new /obj/item/clothing/suit/storage/labcoat(src)
		new /obj/item/clothing/gloves/black(src)
		new /obj/item/device/radio/headset/headset_eng(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/under/rank/roboticist(src)

/obj/item/wardrobe/chaplain
	name = "Chaplain wardrobe"
	descriptor = "clothing and basic equipment for a Chaplain"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/weapon/storage/bible/booze(src)
		new /obj/item/device/pda/chaplain(src)
		new /obj/item/device/radio/headset(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/under/rank/chaplain(src)

/obj/item/wardrobe/captain
	name = "Captain wardrobe"
	descriptor = "clothing and basic equipment for a Captain"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/captain(src)
		new /obj/item/weapon/storage/id_kit(src)
		new /obj/item/weapon/reagent_containers/food/drinks/flask(src)
		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/clothing/suit/storage/captunic(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/head/caphat(src)
		new /obj/item/clothing/gloves/captain(src)
		new /obj/item/clothing/head/helmet/swat(src)
		new /obj/item/device/radio/headset/heads/captain(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/clothing/under/rank/captain(src)

/obj/item/wardrobe/hop
	name = "Head of Personnel wardrobe"
	descriptor = "clothing and basic equipment for a Head of Personnel"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/heads/hop(src)
		new /obj/item/weapon/storage/id_kit(src)
		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/device/flash(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/head/helmet(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/clothing/gloves/blue(src)
		new /obj/item/device/radio/headset/heads/hop(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/clothing/under/rank/head_of_personnel(src)

/obj/item/wardrobe/cmo
	name = "Chief Medical Officer wardrobe"
	descriptor = "clothing and basic equipment for a Chief Medical Officer"

	New()
		..()
		var/obj/item/weapon/storage/backpack/medic/BPK = new /obj/item/weapon/storage/backpack/medic(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/heads/cmo(src)
		new /obj/item/weapon/storage/firstaid/regular(src)
		new /obj/item/device/flashlight/pen(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/suit/bio_suit/cmo(src)
		new /obj/item/clothing/head/bio_hood/general(src)
		new /obj/item/clothing/suit/storage/labcoat/cmo(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/device/radio/headset/heads/cmo(src)
		new /obj/item/clothing/under/rank/chief_medical_officer(src)

/obj/item/wardrobe/doctor
	name = "Medical Doctor wardrobe"
	descriptor = "clothing and basic equipment for a Medical Doctor"

	New()
		..()
		var/obj/item/weapon/storage/backpack/medic/BPK = new /obj/item/weapon/storage/backpack/medic(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/medical(src)
		new /obj/item/weapon/storage/firstaid/regular(src)
		new /obj/item/device/flashlight/pen(src)
		new /obj/item/clothing/suit/storage/labcoat(src)
		new /obj/item/clothing/head/nursehat (src)
		new /obj/item/weapon/storage/belt/medical(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/device/radio/headset/headset_med(src)
		new /obj/item/clothing/under/rank/nursesuit (src)
		new /obj/item/clothing/under/rank/medical(src)

/obj/item/wardrobe/geneticist
	name = "Geneticist wardrobe"
	descriptor = "clothing and basic equipment for a Geneticist"

	New()
		..()
		var/obj/item/weapon/storage/backpack/medic/BPK = new /obj/item/weapon/storage/backpack/medic(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/medical(src)
		new /obj/item/device/flashlight/pen(src)
		new /obj/item/clothing/suit/storage/labcoat/genetics(src)
		new /obj/item/device/radio/headset/headset_medsci(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/clothing/under/rank/geneticist(src)

/obj/item/wardrobe/virologist
	name = "Virologist wardrobe"
	descriptor = "clothing and basic equipment for a Virologist"

	New()
		..()
		var/obj/item/weapon/storage/backpack/medic/BPK = new /obj/item/weapon/storage/backpack/medic(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/flashlight/pen(src)
		new /obj/item/device/pda/medical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/suit/storage/labcoat/virologist(src)
		new /obj/item/device/radio/headset/headset_med(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/clothing/under/rank/medical(src)

/obj/item/wardrobe/rd
	name = "Research Director wardrobe"
	descriptor = "clothing and basic equipment for a Research Director"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/device/pda/heads/rd(src)
		new /obj/item/weapon/clipboard(src)
		new /obj/item/weapon/tank/air(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/device/flash(src)
		new /obj/item/clothing/suit/bio_suit/scientist(src)
		new /obj/item/clothing/head/bio_hood/scientist(src)
		new /obj/item/clothing/suit/storage/labcoat(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/device/radio/headset/heads/rd(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/clothing/under/rank/research_director(src)

/obj/item/wardrobe/scientist
	name = "Scientist wardrobe"
	descriptor = "clothing and basic equipment for a Scientist"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/toxins(src)
		new /obj/item/weapon/tank/oxygen(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/clothing/suit/storage/labcoat/science(src)
		new /obj/item/device/radio/headset/headset_sci(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/clothing/under/rank/scientist(src)

/obj/item/wardrobe/chemist
	name = "Chemist wardrobe"
	descriptor = "clothing and basic equipment for a Chemist"

	New()
		..()
		var/obj/item/weapon/storage/backpack/medic/BPK = new /obj/item/weapon/storage/backpack/medic(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/radio/headset/headset_medsci(src)
		new /obj/item/clothing/under/rank/chemist(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/device/pda/toxins(src)
		new /obj/item/clothing/suit/storage/labcoat/chemist(src)

/obj/item/wardrobe/hos
	name = "Head of Security wardrobe"
	descriptor = "clothing and basic equipment for a Head of Security"

	New()
		..()
		var/obj/item/weapon/storage/backpack/security/BPK = new /obj/item/weapon/storage/backpack/security(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/weapon/melee/baton(src)
		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/device/flash(src)
		new /obj/item/device/pda/heads/hos(src)
		new /obj/item/clothing/suit/storage/armourrigvest(src)
		new /obj/item/clothing/suit/armor/hos(src)
		new /obj/item/clothing/head/helmet/HoS(src)
		new /obj/item/weapon/storage/belt/security(src)
		new /obj/item/clothing/gloves/hos(src)
		new /obj/item/clothing/glasses/sunglasses/sechud(src)
		new /obj/item/device/radio/headset/heads/hos(src)
		new /obj/item/clothing/shoes/jackboots(src)
		new /obj/item/clothing/under/rank/head_of_security(src)

/obj/item/wardrobe/warden
	name = "Warden wardrobe"
	descriptor = "clothing and basic equipment for a Warden"

	New()
		..()
		var/obj/item/weapon/storage/backpack/security/BPK = new /obj/item/weapon/storage/backpack/security(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/flash(src)
		new /obj/item/weapon/melee/baton(src)
		new /obj/item/weapon/gun/energy/taser(src)
		new /obj/item/device/pda/security(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/suit/storage/gearharness(src)
		new /obj/item/clothing/head/helmet/warden(src)
		new /obj/item/clothing/gloves/red(src)
		new /obj/item/weapon/storage/belt/security(src)
		new /obj/item/clothing/glasses/sunglasses/sechud(src)
		new /obj/item/device/radio/headset/headset_sec(src)
		new /obj/item/clothing/shoes/jackboots(src)
		new /obj/item/clothing/under/rank/warden(src)

/obj/item/wardrobe/detective
	name = "Detective wardrobe"
	descriptor = "clothing and basic equipment for a Detective"

	New()
		..()
		var/obj/item/weapon/storage/backpack/security/BPK = new /obj/item/weapon/storage/backpack/security(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/fcardholder(src)
		new /obj/item/weapon/clipboard(src)
		new /obj/item/device/detective_scanner(src)
		new /obj/item/policetaperoll(src)
		new /obj/item/weapon/storage/box/evidence(src)
		new /obj/item/device/pda/detective(src)
		new /obj/item/clothing/suit/det_suit/armor(src)
		new /obj/item/clothing/suit/storage/det_suit(src)
		new /obj/item/clothing/gloves/detective(src)
		new /obj/item/clothing/head/det_hat(src)
		new /obj/item/device/radio/headset/headset_sec(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/clothing/under/det(src)

/obj/item/wardrobe/officer
	name = "Security Officer wardrobe"
	descriptor = "clothing and basic equipment for a Security Officer"

	New()
		..()
		var/obj/item/weapon/storage/backpack/security/BPK = new /obj/item/weapon/storage/backpack/security(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/weapon/pepperspray(src)
		new /obj/item/device/flash(src)
		new /obj/item/weapon/melee/baton(src)
		new /obj/item/policetaperoll(src)
		new /obj/item/weapon/flashbang(src)
		new /obj/item/device/pda/security(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/suit/storage/gearharness(src)
		new /obj/item/clothing/glasses/sunglasses/sechud(src)
		new /obj/item/weapon/storage/belt/security(src)
		new /obj/item/clothing/head/helmet(src)
		new /obj/item/clothing/head/secsoft(src)
		new /obj/item/clothing/gloves/red(src)
		new /obj/item/device/radio/headset/headset_sec(src)
		new /obj/item/clothing/shoes/jackboots(src)
		new /obj/item/clothing/under/rank/security(src)



/obj/item/wardrobe/bartender
	name = "Bartender wardrobe"
	descriptor = "clothing and basic equipment for a Bartender"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/ammo_casing/shotgun/beanbag(BPK)
		new /obj/item/ammo_casing/shotgun/beanbag(BPK)
		new /obj/item/ammo_casing/shotgun/beanbag(BPK)
		new /obj/item/ammo_casing/shotgun/beanbag(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/radio/headset(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/under/rank/bartender(src)

/obj/item/wardrobe/chef
	name = "Chef wardrobe"
	descriptor = "clothing and basic equipment for a Chef"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/clothing/suit/storage/chef(src)
		new /obj/item/clothing/head/chefhat(src)
		new /obj/item/device/radio/headset(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/under/rank/chef(src)

/obj/item/wardrobe/hydro
	name = "Botanist wardrobe"
	descriptor = "clothing and basic equipment for a Botanist"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/analyzer/plant_analyzer(src)
		new /obj/item/clothing/suit/storage/apron(src)
		new /obj/item/clothing/gloves/botanic_leather(src)
		new /obj/item/device/radio/headset(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/under/rank/hydroponics(src)

/obj/item/wardrobe/qm
	name = "Quartermaster wardrobe"
	descriptor = "clothing and basic equipment for a Quartermaster"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/weapon/clipboard(src)
		new /obj/item/device/pda/quartermaster(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/device/radio/headset/heads/qm(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/under/rank/cargo(src)

/obj/item/wardrobe/cargo_tech
	name = "Cargo Technician wardrobe"
	descriptor = "clothing and basic equipment for a Cargo Technician"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/quartermaster(src)
		new /obj/item/device/radio/headset/headset_cargo(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/under/rank/cargo(src)

/obj/item/wardrobe/mining
	name = "Shaft Miner wardrobe"
	descriptor = "clothing and basic equipment for a Shaft Miner"

	New()
		..()
		var/obj/item/weapon/storage/backpack/industrial/BPK = new /obj/item/weapon/storage/backpack/industrial(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/analyzer(src)
		new /obj/item/weapon/satchel(src)
		new /obj/item/device/flashlight/lantern(src)
		new /obj/item/weapon/shovel(src)
		new /obj/item/weapon/pickaxe(src)
		new /obj/item/weapon/crowbar(src)
		new /obj/item/clothing/glasses/meson(src)
		new /obj/item/device/radio/headset/headset_mine(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/under/rank/miner(src)

/obj/item/wardrobe/janitor
	name = "Janitor wardrobe"
	descriptor = "clothing and basic equipment for a Janitor"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/janitor(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/under/rank/janitor(src)

/obj/item/wardrobe/librarian
	name = "Librarian wardrobe"
	descriptor = "clothing and basic equipment for a Librarian"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/weapon/barcodescanner(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/under/suit_jacket/red(src)

/obj/item/wardrobe/lawyer
	name = "Lawyer wardrobe"
	descriptor = "clothing and basic equipment for a Lawyer"

	New()
		..()
		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		new /obj/item/weapon/storage/box(BPK)
		new /obj/item/weapon/pen(src)
		new /obj/item/device/pda/lawyer(src)
		new /obj/item/device/detective_scanner(src)
		new /obj/item/weapon/storage/briefcase(src)
		new /obj/item/clothing/shoes/brown(src)
		if(prob(50))
			new /obj/item/clothing/under/lawyer/bluesuit(src)
			new /obj/item/clothing/suit/lawyer/bluejacket(src)
		else
			new /obj/item/clothing/under/lawyer/purpsuit(src)
			new /obj/item/clothing/suit/lawyer/purpjacket(src)


