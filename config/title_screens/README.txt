The enclosed /images folder holds the image files used as the title screen for the game.

Specification:
Formats: PNG, JPG, GIF, DMI*
Dimensions: 608x480
	*Byond's DMI format is also supported, but if you use a DMI only include one image per file and do not give it an icon_state (the text label below the image).

The game won't scale these images for you, so smaller images will not fill the screen and larger ones will be cut off.

Using unnecessarily huge images can cause client side lag and should be avoided. Extremely large GIFs should preferentially be converted to DMIs.
Placing non-image files in the images folder can cause errors.

You may add as many title screens as you like, if there is more than one a random screen is chosen (see name conventions for specifics).

---

Naming Conventions:

Every title screen you add must have a unique name. It is allowed to name two things the same if they have different file types, but this should be discouraged.
Avoid using the plus sign "+" and the period "." in names, as these are used internally to classify images.


Common Titles:

Common titles are in the rotation to be displayed all the time. Any name that does not include the character "+" is considered a common title.

An example of a common title name is "clown".

The common title screen named "default" is special. It is only used if no other titles are available. Because default only runs in the
absence of other titles, if you want it to also appear in the general rotation you must name it something else.


Map Titles:

Map titles are tied to a specific in game map. To make a map title you format the name like this "(name of a map)+(name of your title)"

The spelling of the map name is important. It must match exactly the define MAP_NAME found in the relevant .JSON file in the /_maps folder in
the root directory. It can also be seen in game in the status menu. Note that there are no spaces between the two names.

It is absolutely fine to have more than one title tied to the same map.

An example of a map title name is "Omegastation+splash".


Rare Titles:

Rare titles are a just for fun feature where they will only have a 1% chance of appear in in the title screen pool of a given round.
Add the phrase "rare+" to the beginning of the name. Again note there are no spaces. A title cannot be rare title and a map title at the same time.

An example of a rare title name is "rare+explosion"

###

В прилагаемой папке /images хранятся файлы изображений, использованные в качестве титульного экрана для игры.

Спецификация:
Форматы: PNG, JPG, GIF, DMI*
Размеры: 608x480
 * Формат DMI от Byond также поддерживается, но если вы используете DMI, включайте только одно изображение в файл и не присваивайте ему icon_state (текстовую метку под изображением).

Игра не будет масштабировать эти изображения для вас, поэтому изображения меньшего размера не будут заполнять экран, а изображения большего размера будут обрезаны.

Использование чрезмерно больших изображений может привести к задержке работы на стороне клиента, и этого следует избегать. Очень большие GIF-файлы предпочтительно конвертировать в DMI.
Размещение файлов, не содержащих изображений, в папке "Изображения" может привести к ошибкам.

Вы можете добавить столько титульных экранов, сколько захотите, если их несколько, то выбирается случайный экран (подробности смотрите в разделе "Правила именования").

---

Правила именования:

Каждый добавляемый вами титульный экран должен иметь уникальное имя. Допускается присвоение двум объектам одинаковых имен, если они имеют разные типы файлов, но это не рекомендуется.
Избегайте использования знака "+".

Примером обычного названия заголовка является "клоун".

Экран общего названия с именем "по умолчанию" является специальным. Он используется только в том случае, если другие названия недоступны. Поскольку по умолчанию он запускается только при
отсутствии других названий, если вы хотите, чтобы он также отображался в общей ротации, вы должны дать ему другое название.


Названия карт:

Названия карт привязаны к определенной игровой карте. Чтобы создать название карты, вы форматируете его следующим образом "(название карты)+(название вашего названия)"

Важно правильно написать название карты. Оно должно в точности совпадать с именем define MAP_NAME, которое находится в соответствующем JSON-файле в папке /_maps в
корневом каталоге. Его также можно увидеть в игре в меню статуса. Обратите внимание, что между двумя названиями нет пробелов.

Абсолютно нормально, если к одной и той же карте привязано несколько названий.

Примером названия карты может служить "Omegastation+splash".


Редкие названия:

Редкие титулы - это функция "просто для развлечения", в которой вероятность их появления на титульном экране в данном раунде составляет всего 1%.
Добавьте phr
