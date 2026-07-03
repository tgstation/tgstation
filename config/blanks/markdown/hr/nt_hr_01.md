[blank_header
id = NT-HR-01;
name = Заявление о приёме на работу;
station = [station_name];
category = Отдел кадров
]

# === Заявление ===

Имя заявителя: [input_field autofill_type=name]
-# Полностью и без ошибок
Номер аккаунта заявителя: [input_field autofill_type=bank_id]
-# Эта информация есть в ваших заметках
Должность заявителя: [input_field autofill_type=job]
-# Указано на ID карте
Запрашиваемая должность: [input_field]
-# Требует наличия квалификации
Список компетенций: [input_field]

---

# === Подписи и штампы ===

! Время: [input_field autofill_type=time]
! Подпись заявителя: [input_field autofill_type=sign]
! Подпись главы персонала: [input_field autofill_type=sign]
! Подпись будущего главы: [input_field autofill_type=sign]

[blank_footer
content = Подписи главы являются доказательством их согласия.
Данный документ является недействительным при отсутствии релевантной печати.
Пожалуйста, отправьте обратно подписанную/проштампованную копию факсом.
]
