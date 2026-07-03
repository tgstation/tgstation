[blank_header
id = NT-LD-00;
name = Бланк заявления;
station = [station_name];
category = Юридический отдел
]

# === Основная информация ===

Имя заявителя: [input_field autofill_type=name]
-# Полностью и без ошибок
Номер аккаунта заявителя: [input_field autofill_type=bank_id]
-# Эта информация есть в ваших заметках
Должность заявителя: [input_field autofill_type=job]
-# Указано на ID карте

# === Заявление ===

[input_field]

# === Подписи и штампы ===

! Время: [input_field autofill_type=time]
! Подпись заявителя: [input_field autofill_type=sign]
! Подпись главы персонала: [input_field autofill_type=sign]
! Подпись (дополнительная): [input_field autofill_type=sign]

[blank_footer
content = Подписи главы являются доказательством их согласия.
Данный документ является недействительным при отсутствии релевантной печати.
]
