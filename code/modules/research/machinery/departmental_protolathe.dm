/obj/machinery/rnd/production/protolathe/department
	name = "department protolathe"
	desc = "A special protolathe with a built in interface meant for departmental usage, with built in ExoSync receivers allowing it to print designs researched that match its ROM-encoded department type."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/protolathe/department

/obj/machinery/rnd/production/protolathe/department/engineering
	name = "department protolathe (Engineering)"
	allowed_department_flags = DEPARTMENT_BITFLAG_ENGINEERING
	department_tag = "Engineering"
	circuit = /obj/item/circuitboard/machine/protolathe/department/engineering
	stripe_color = "#EFB341"
	payment_department = ACCOUNT_ENG

/obj/machinery/rnd/production/protolathe/department/engineering/no_tax
	circuit = /obj/item/circuitboard/machine/protolathe/department/engineering/no_tax
	charges_tax = FALSE

/obj/machinery/rnd/production/protolathe/department/service
	name = "department protolathe (Service)"
	allowed_department_flags = DEPARTMENT_BITFLAG_SERVICE
	department_tag = "Service"
	circuit = /obj/item/circuitboard/machine/protolathe/department/service
	stripe_color = "#83ca41"
	payment_department = ACCOUNT_SRV

/obj/machinery/rnd/production/protolathe/department/medical
	name = "department protolathe (Medical)"
	allowed_department_flags = DEPARTMENT_BITFLAG_MEDICAL
	department_tag = "Medical"
	circuit = /obj/item/circuitboard/machine/protolathe/department/medical
	stripe_color = "#52B4E9"
	payment_department = ACCOUNT_MED

/obj/machinery/rnd/production/protolathe/department/cargo
	name = "department protolathe (Cargo)"
	allowed_department_flags = DEPARTMENT_BITFLAG_CARGO
	department_tag = "Cargo"
	circuit = /obj/item/circuitboard/machine/protolathe/department/cargo
	stripe_color = "#956929"
	payment_department = ACCOUNT_CAR

/obj/machinery/rnd/production/protolathe/department/science
	name = "department protolathe (Science)"
	allowed_department_flags = DEPARTMENT_BITFLAG_SCIENCE
	department_tag = "Science"
	circuit = /obj/item/circuitboard/machine/protolathe/department/science
	stripe_color = "#D381C9"
	payment_department = ACCOUNT_SCI

/obj/machinery/rnd/production/protolathe/department/security
	name = "department protolathe (Security)"
	allowed_department_flags = DEPARTMENT_BITFLAG_SECURITY
	department_tag = "Security"
	circuit = /obj/item/circuitboard/machine/protolathe/department/security
	stripe_color = "#DE3A3A"
	payment_department = ACCOUNT_SEC
