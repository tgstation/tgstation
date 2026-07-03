[blank_header
id = NT-REQ-01;
name = Запрос на поставку;
category = Отдел снабжения;
station = [station_name];
]

# === Сторона запроса ===

Имя запросившего: [input_field autofill_type=name]
-# Полностью и без ошибок
Номер аккаунта: [input_field autofill_type=bank_id]
-# Эта информация есть в ваших заметках
Текущая должность: [input_field autofill_type=job]
-# Указано на ID карте
Способ получения: [input_field]
-# Предпочитаемый способ
<br>

Причина запроса:
[input_field]
<br>

Список запроса:
[input_field]
<br>

---

# === Сторона поставки ===

Имя поставщика: [input_field autofill_type=name]
-# Полностью и без ошибок
Номер аккаунта: [input_field autofill_type=bank_id]
-# Эта информация есть в ваших заметках
Текущая должность: [input_field autofill_type=job]
-# Указано на ID карте
Способ доставки: [input_field]
-# Утверждённый способ
<br>

Комментарии:
[input_field]
<br>

Список поставки и цены:
[input_field]
<br>

Итоговая стоимость: [input_field]
-# Пропустите, если бесплатно

---

# === Подписи и штампы ===

! Время: [input_field autofill_type=time]
! Подпись стороны запроса: [input_field autofill_type=sign]
! Подпись стороны поставки: [input_field autofill_type=sign]
! Подпись главы (если требуется): [input_field autofill_type=sign]

[blank_footer
content = Подписи глав являются доказательством их согласия.
Данный документ является недействительным при отсутствии релевантной печати.
]
