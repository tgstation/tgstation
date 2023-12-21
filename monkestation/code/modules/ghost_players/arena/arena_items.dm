//variant that grants CQC as soon as it is used
/obj/item/book/granter/martial/cqc/fast_read/attack_self(mob/living/user)
	uses--
	on_reading_finished(user)
	. = ..()
