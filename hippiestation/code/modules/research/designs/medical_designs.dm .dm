
/datum/design/implant_adrenalin //This should overwrite the adrenal implant in the Protolathe
	name = "Combat Stimulant Implant"
	desc = "A glass case containing an implant."
	id = "implant_adrenalin"
	req_tech = list("biotech" = 6, "combat" = 6, "syndicate" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_GOLD = 500, MAT_URANIUM = 600, MAT_DIAMOND = 600)
	build_path = /obj/item/weapon/implantcase/comstimm
	category = list("Medical Designs")