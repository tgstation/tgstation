[blank_header
id = NT-SUP-01;
name = Регистрационная форма для подтверждения заказа;
category = Отдел снабжения;
station = [station_name];
]

Имя заявителя: [input_field autofill_type=name]
Должность заявителя: [input_field autofill_type=job]
Подробное объяснение о необходимости заказа: [input_field]

---

# === Подписи и штампы ===

! Время: [input_field autofill_type=time]
! Подпись заявителя: [input_field autofill_type=sign]
! Подпись руководителя: [input_field autofill_type=sign]
! Подпись сотрудника отдела снабжения: [input_field autofill_type=sign]

[blank_footer
content = Данная форма является приложением для оригинального автоматического документа, полученного с рук заявителя. Для подтверждения заказа заявителя необходимы указанные подписи и соответствующие печати отдела по заказу.
]
