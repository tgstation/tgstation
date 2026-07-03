[blank_header
id = NT-MD-02;
name = Отчёт о вскрытии;
category = Медицинский отдел;
station = [station_name];
]

# === Основная информация ===

Скончавшийся: [input_field]
Раса: [input_field]
Пол: [input_field]
Возраст: [input_field]
Группа крови: [input_field]
Должность: [input_field]

---

# === Отчёт о вскрытии ===

Тип смерти: [input_field]
Описание тела: [input_field]
Метки и раны: [input_field]
Вероятная причина смерти: [input_field]
<br>

Детали: [input_field]


---

# === Подписи и штампы ===

! Время: [input_field autofill_type=time]
! Вскрытие провёл: [input_field autofill_type=name]

[blank_footer
content = Подписи главы являются доказательством их согласия.
Данный документ является недействительным при отсутствии релевантной печати.
]
