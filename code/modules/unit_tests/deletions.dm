/// This is for regression tests of deletions that used to runtime.
/// This would ideally be replaced by Del The World, unit testing every single deletion.
/datum/unit_test/deletion_regressions

/datum/unit_test/deletion_regressions/Run()
	qdel(new /obj/item/gun/energy/kinetic_accelerator/crossbow)
	qdel(new /obj/item/gun/syringe/syndicate)
