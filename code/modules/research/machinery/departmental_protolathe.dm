/obj/machinery/rnd/production/protolathe/department
	name = "department protolathe"
	desc = "A special protolathe with a built in interface meant for departmental usage, with built in ExoSync receivers allowing it to print designs researched that match its ROM-encoded department type."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/protolathe/department

/obj/machinery/rnd/production/protolathe/department/engineering
	name = "department protolathe (Engineering)"
	allowed_department_flags = DEPARTMENTAL_FLAG_ENGINEERING
	department_tag = "Engineering"
	circuit = /obj/item/circuitboard/machine/protolathe/department/engineering
	stripe_color = "#EFB341"

/obj/machinery/rnd/production/protolathe/department/service
	name = "department protolathe (Service)"
	allowed_department_flags = DEPARTMENTAL_FLAG_SERVICE
	department_tag = "Service"
	circuit = /obj/item/circuitboard/machine/protolathe/department/service
	stripe_color = "#83ca41"

/obj/machinery/rnd/production/protolathe/department/medical
	name = "department protolathe (Medical)"
	allowed_department_flags = DEPARTMENTAL_FLAG_MEDICAL
	department_tag = "Medical"
	circuit = /obj/item/circuitboard/machine/protolathe/department/medical
	stripe_color = "#52B4E9"

/obj/machinery/rnd/production/protolathe/department/cargo
	name = "department protolathe (Cargo)"
	allowed_department_flags = DEPARTMENTAL_FLAG_CARGO
	department_tag = "Cargo"
	circuit = /obj/item/circuitboard/machine/protolathe/department/cargo
	stripe_color = "#956929"

/obj/machinery/rnd/production/protolathe/department/science
	name = "department protolathe (Science)"
	allowed_department_flags = DEPARTMENTAL_FLAG_SCIENCE
	department_tag = "Science"
	circuit = /obj/item/circuitboard/machine/protolathe/department/science
	stripe_color = "#D381C9"

/obj/machinery/rnd/production/protolathe/department/security
	name = "department protolathe (Security)"
	allowed_department_flags = DEPARTMENTAL_FLAG_SECURITY
	department_tag = "Security"
	circuit = /obj/item/circuitboard/machine/protolathe/department/security
	stripe_color = "#DE3A3A"
