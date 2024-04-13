/////////// cleric's den items.

//Primary reward: the cleric's mace design disk.
/obj/item/disk/design_disk/cleric_mace
	name = "Enshrined Disc of Smiting"

/obj/item/disk/design_disk/cleric_mace/Initialize(mapload)
	. = ..()
	blueprints += new /datum/design/cleric_mace

/obj/item/paper/fluff/ruins/clericsden/contact
	default_raw_text = "Father Aurellion, the ritual is complete, and soon our brothers at the bastion will see the error of our ways. After all, a god of clockwork or blood? Preposterous. Only the TRUE GOD should have so much power. Signed, Father Odivallus."

/obj/item/paper/fluff/ruins/clericsden/warning
	default_raw_text = "FATHER ODIVALLUS DO NOT GO FORWARD WITH THE RITUAL. THE ASTEROID WE'RE ANCHORED TO IS UNSTABLE, YOU WILL DESTROY THE STATION. I HOPE THIS REACHES YOU IN TIME. FATHER AURELLION."
