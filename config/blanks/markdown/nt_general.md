[blank_header
id = NT_GENERAL;
name = Пустой бланк для любых целей;
station = [station_name];
category = Общие формы
]

# === Основная информация ===

Имя заявителя: [input_field autofill_type=name]
-# Полностью и без ошибок
Номер аккаунта заявителя: [input_field autofill_type=bank_id]
-# Эта информация есть в ваших заметках
Текущая должность: [input_field autofill_type=job]
-# Указано на ID карте

---

# === Заявление ===

[input_field]

---

# === Подписи и штампы ===

! Время: [input_field autofill_type=time]
! Подпись заявителя: [input_field autofill_type=sign]
! Подпись главы персонала: [input_field autofill_type=sign]
! Подпись (дополнительная): [input_field autofill_type=sign]
