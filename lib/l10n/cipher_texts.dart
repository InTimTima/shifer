/// Long-form cipher descriptions and help texts (RU / EN).
class CipherTexts {
  static Map<String, String> map(bool isRu) => isRu ? _ru : _en;

  static const _ru = {
    'navCiphers': 'Шифры',
    'navDetector': 'Детектор',
    'navStudio': 'Свой шифр',
    'detectorTitle': 'Определитель шифра',
    'detectorSubtitle':
        'Вставьте шифротекст — Shifer переберёт простые схемы и частые ключи, затем покажет наиболее правдоподобные расшифровки.',
    'detectorHint': 'Вставьте зашифрованное сообщение…',
    'detectorAnalyze': 'Анализировать',
    'detectorNote':
        'Это эвристика, не криптоанализ. Для Цезаря/ROT/рельсов — полный перебор; для ключевых шифров — короткий словарь ключей. На телефоне это быстро для коротких текстов.',
    'detectorEmpty': 'Результатов пока нет — вставьте текст и нажмите «Анализировать».',
    'customStudioTitle': 'Конструктор шифра',
    'customStudioSubtitle':
        'Соберите свой шифр из цепочки операций: сдвиг, зеркало, ключевое слово и др. Применяются по порядку сверху вниз. Сохраните и пользуйтесь как обычным шифром.',
    'customCipherName': 'Название шифра',
    'customCipherKeyword': 'Ключ для перемешивания алфавита',
    'customCipherKeywordHelp':
        'Уникальные буквы ключа идут первыми, затем оставшиеся буквы алфавита.',
    'customCipherPreview': 'Предпросмотр шифралфавита',
    'customCipherList': 'Сохранённые шифры',
    'customCipherEmpty': 'Пока нет своих шифров — создайте первый выше.',
    'customCipherError': 'Укажите название и ключ с буквами алфавита',
    'customCipherSaved': 'Шифр сохранён',
    'customCipherSavedDesc': 'Пользовательская моноалфавитная подстановка',
    'cipherCustomDesc': 'Ваш сохранённый шифр подстановки',
    'cipherCustomHelp':
        'Это ваш личный моноалфавитный шифр. Алфавит подстановки задан при создании. Пробелы сохраняются.',
    'diameter': 'Диаметр (число колонн)',
    'navMixer': 'Миксер',
    'mixerTitle': 'Миксер шифров',
    'mixerSubtitle':
        'Соедините несколько шифров в цепочку: вывод одного становится вводом для следующего.',
    'mixerBaseAlphabet': 'Базовый алфавит',
    'mixerAddHint': 'Нажмите на шифр из списка, чтобы добавить его в цепочку.',
    'mixerCannotAdd': 'Этот шифр нельзя добавить к текущему выходу',
    'mixerEmpty': 'Пока пусто — добавьте шифр из списка, чтобы собрать цепочку',
    'mixerClear': 'Очистить',
    'mixerInput': 'Ввод',
    'mixerOutput': 'Выход',
    'mixerAlphabetIn': 'Входной алфавит',
    'mixerAlphabetOut': 'Выходной алфавит',
    'constructorRule': 'Тип шифра',
    'constructorSteps': 'Операции (по порядку)',
    'constructorAddStep': 'Добавить шаг',
    'constructorNoSteps': 'Добавьте хотя бы один шаг',
    'constructorNoParams': 'Параметры не нужны',
    'constructorExample': 'Проверка: шифрование и расшифровка',
    'constructorMoveUp': 'Вверх',
    'constructorMoveDown': 'Вниз',
    'ruleShift': 'Сдвиг',
    'ruleMirror': 'Зеркало (Атбаш)',
    'ruleKeyword': 'Ключевое слово',
    'ruleCustom': 'Своя подстановка',
    'ruleAffine': 'Аффинный (a·x+b)',
    'ruleRotHalf': 'ROT (половина алфавита)',
    'ruleOddEven': 'Чёт-нечет',
    'shiftAmount': 'Величина сдвига',
    'customLettersLabel': 'Новый алфавит',
    'customLettersHelp':
        'Все символы выбранного алфавита в новом порядке, без повторов',
    'customLengthError': 'Новый алфавит должен быть той же длины и без повторов',
    'categoryEncoding': 'Коды и азбуки',
    'spaceModeLabel': 'Пробелы',
    'spaceKeep': 'Целиком (сохранять)',
    'spacePerWord': 'Пословно',
    'spaceUnsupported': 'Пробелы недоступны для этого шифра',
    'spaceKeepHint':
        'Пробелы остаются на месте, шифруются только символы алфавита.',
    'spacePerWordHint':
        'Каждое слово шифруется отдельно, пробелы — только разделители.',
    'clickAlphabetHint': 'Нажмите символ, чтобы вставить в поле',
    'exampleWord': 'привет',
    'cipherMirrorDesc':
        'Классический Атбаш: алфавит «отражается» — первая буква меняется с последней, вторая с предпоследней и т.д.',
    'cipherMirrorHelp':
        'Как работает\n'
        'Берётся выбранный алфавит и полностью разворачивается. Каждая буква открытого текста заменяется буквой с той же позиции в перевёрнутом алфавите.\n\n'
        'Пример (русский): А↔Я, Б↔Ю, …\n'
        'Пример (английский): A↔Z, B↔Y, …\n\n'
        'Пробелы\n'
        'Сохраняются на месте и не шифруются.\n\n'
        'Как пользоваться\n'
        '1) Выберите алфавит.\n'
        '2) Введите текст сверху — снизу появится шифр.\n'
        '3) Или введите шифр снизу — сверху восстановится текст.\n'
        '4) Буквы алфавита на панели кликабельны — удобно вводить редкие символы.',
    'cipherCaesarDesc':
        'Сдвиг каждой буквы на фиксированное число позиций (ключ). Один из самых известных античных шифров.',
    'cipherCaesarHelp':
        'Как работает\n'
        'Буква с индексом x переходит в (x + k) mod n, где k — ключ, n — длина алфавита. Дешифрование: (x − k) mod n.\n\n'
        'Пример: ключ 3, английский: A→D, B→E, X→A.\n\n'
        'Пробелы сохраняются. Ключ может быть любым целым (в том числе отрицательным).\n\n'
        'Совет: на панели виден весь сдвинутый алфавит — так проще понять подстановку.',
    'cipherRotHalfDesc':
        'Фиксированный сдвиг на половину алфавита (для английского это знаменитый ROT13).',
    'cipherRotHalfHelp':
        'Как работает\n'
        'Сдвиг всегда равен n/2, где n — длина алфавита. Поэтому алфавит должен быть чётной длины: иначе половина не целое число.\n\n'
        'Особенность: повторное применение возвращает исходный текст (шифрование = дешифрование).\n\n'
        'Для английского (26 букв) это классический ROT13. Для других алфавитов — обобщение той же идеи.',
    'cipherKeywordCaesarDesc':
        'Моноалфавитная подстановка: сначала уникальные буквы ключа, затем оставшиеся буквы алфавита по порядку.',
    'cipherKeywordCaesarHelp':
        'Как строится алфавит\n'
        '1) Из ключевого слова берутся буквы без повторов.\n'
        '2) Затем дописываются все оставшиеся буквы выбранного алфавита.\n'
        '3) Полученный порядок — шифралфавит: 1-я буква оригинала → 1-я буква нового и т.д.\n\n'
        'Пример: ключ KEY, английский → KEYABCD…Z (без повторов K,E,Y).\n\n'
        'Пробелы сохраняются. Ключ фильтруется по текущему алфавиту.',
    'cipherAffineDesc':
        'Математическая подстановка (a·x + b) mod n. Надёжнее простого Цезаря, если a взаимно просто с n.',
    'cipherAffineHelp':
        'Формула\n'
        'Шифрование: y = (a·x + b) mod n\n'
        'Дешифрование: x = a⁻¹·(y − b) mod n\n\n'
        'Важно: a и n должны быть взаимно простыми (gcd(a, n) = 1), иначе разные буквы сожмутся в одну и расшифровать нельзя. Если a «плохой», приложение временно использует безопасный коэффициент.\n\n'
        'Пробелы сохраняются.',
    'cipherOddEvenDesc':
        'Перестановка алфавита: сначала символы с чётных позиций, затем с нечётных.',
    'cipherOddEvenHelp':
        'Индексы считаются с нуля. Получается новый порядок букв, и дальше идёт обычная моноалфавитная подстановка.\n\n'
        'Ключ не нужен. Пробелы сохраняются.',
    'cipherQwertyDesc':
        'Алфавит ABC… заменяется порядком клавиш QWERTY (латиница).',
    'cipherQwertyHelp':
        'Строится шифралфавит из раскладки QWERTYUIOPASDFGHJKLZXCVBNM, затем недостающие буквы (если есть) дописываются. Работает только для латинских алфавитов приложения.\n\n'
        'Пробелы сохраняются. Удобно набивать буквы кликами по панели.',
    'cipherYcukenDesc':
        'То же для русской раскладки ЙЦУКЕН.',
    'cipherYcukenHelp':
        'Шифралфавит строится из порядка клавиш русской раскладки. Доступен только с русским алфавитом.\n\n'
        'Пробелы сохраняются.',
    'cipherVigenereDesc':
        'Полиалфавитный шифр: сдвиг меняется по буквам ключа. Сильнее Цезаря при длинном ключе.',
    'cipherVigenereHelp':
        'Как работает\n'
        'Для i-й буквы текста берётся i-я буква ключа (ключ циклически повторяется). Сдвиг равен позиции буквы ключа в алфавите.\n'
        'C = (P + K) mod n,  P = (C − K) mod n.\n\n'
        'Пробелы не расходуют ключ и остаются на месте.\n'
        'Панель «изменённый алфавит» показывает сдвиг по первой букве ключа (предпросмотр).',
    'cipherBeaufortDesc':
        'Вариант Виженера: C = (K − P) mod n. Шифрование совпадает с дешифрованием.',
    'cipherBeaufortHelp':
        'Тот же полиалфавитный принцип, но формула другая. Повторный прогон с тем же ключом восстанавливает текст.\n\n'
        'Пробелы сохраняются и не двигают ключ.',
    'cipherVariantBeaufortDesc':
        'Ещё одна вариация: C = (P − K) mod n.',
    'cipherVariantBeaufortHelp':
        'Похож на Виженер, но вычитание идёт в другую сторону. Нужен ключ из букв алфавита. Пробелы сохраняются.',
    'cipherAutokeyDesc':
        'Виженер, у которого после праймера ключом становится сам открытый текст.',
    'cipherAutokeyHelp':
        'Сначала используется введённый праймер (короткий ключ), затем очередные сдвиги берутся из уже обработанных букв открытого текста. Это убирает цикличность короткого ключа.\n\n'
        'Пробелы сохраняются и не входят в автоключ.',
    'cipherGronsfeldDesc':
        'Как Виженер, но ключ — цифры (величины сдвига), а не буквы.',
    'cipherGronsfeldHelp':
        'Каждая цифра ключа — сдвиг для очередной буквы. Ключ циклически повторяется. Пример ключа: 31415.\n\n'
        'Пробелы сохраняются.',
    'cipherTrithemiusDesc':
        'Прогрессивный Цезарь: сдвиги 0, 1, 2, 3… без отдельного ключа.',
    'cipherTrithemiusHelp':
        'Первая буква сдвигается на 0, вторая на 1, третья на 2 и т.д. (по модулю длины алфавита). Исторически — таблица Тритемия, предок Виженера.\n\n'
        'Пробелы не увеличивают счётчик сдвига.',
    'cipherPortaDesc':
        'Полиалфавитный шифр Порты по таблице пар половин алфавита. Нужна чётная длина.',
    'cipherPortaHelp':
        'Алфавит делится пополам. Буква ключа выбирает «строку» таблицы, которая задаёт взаимную замену между половинами. Шифрование обратно самому себе.\n\n'
        'Несовместим с алфавитами нечётной длины (они скрыты в списке).\n'
        'Пробелы сохраняются.',
    'cipherRailFenceDesc':
        'Перестановка: буквы пишутся зигзагом по «рельсам» и считываются построчно.',
    'cipherRailFenceHelp':
        'Как работает\n'
        'Текст укладывается вниз-вверх по R рельсам, затем читается слева направо по каждому рельсу.\n\n'
        'Пробелы\n'
        '• «Целиком» — пробел участвует в зигзаге как обычный символ.\n'
        '• «Пословно» — каждое слово шифруется отдельно (часто удобнее для фраз).\n\n'
        'Алфавит не подменяется — меняется только порядок.',
    'cipherColumnarDesc':
        'Текст в таблицу по строкам, чтение по столбцам в порядке букв ключа.',
    'cipherColumnarHelp':
        'Ширина таблицы = длина ключа. Столбцы упорядочиваются по алфавитному порядку букв ключа (при равенстве — по порядку появления).\n\n'
        'Режимы пробелов те же, что у рельсового: целиком или пословно.\n'
        'Подстановки букв нет — только перестановка.',
    'cipherMorse': 'Азбука Морзе',
    'cipherBraille': 'Шрифт Брайля',
    'cipherA1z26': 'A1Z26 (номера букв)',
    'cipherNato': 'Фонетический НАТО',
    'cipherReverse': 'Реверс текста',
    'cipherReverseDesc':
        'Переворачивает строку задом наперёд. Режим «пословно» переворачивает каждое слово отдельно.',
    'cipherReverseHelp':
        'Как работает\n'
        'Все символы (включая пробелы в режиме «целиком») читаются в обратном порядке. Повторное применение возвращает исходный текст.\n\n'
        'Режимы пробелов\n'
        '• Целиком — переворачивается вся фраза.\n'
        '• Пословно — «привет мир» → «тевирп рим».',
    'cipherBacon': 'Шифр Бекона',
    'cipherBaconDesc':
        'Каждая буква кодируется пятизначной комбинацией a/b (или 0/1).',
    'cipherBaconHelp':
        'Классический двуалфавитный код Бекона. Буквы разделяются пробелом, слова — «/». Можно вводить a/b или 0/1.',
    'cipherPolybius': 'Квадрат Полибия',
    'cipherPolybiusDesc':
        'Буква → координаты строки и столбца в квадратной таблице.',
    'cipherPolybiusHelp':
        'Размер квадрата подбирается под длину алфавита. В шифре — пары цифр через пробел, слова через «/».',
    'cipherBinary': 'Двоичный код',
    'cipherBinaryDesc':
        'Индекс буквы в алфавите в двоичном виде.',
    'cipherBinaryHelp':
        'Ширина бит подбирается под размер алфавита. Слова разделяются «/».',
    'cipherHex': 'HEX-код',
    'cipherHexDesc':
        'Индекс буквы в шестнадцатеричном виде.',
    'cipherHexHelp':
        'Удобно для компактной записи. Слова через «/», числа через пробел.',
    'cipherBase64': 'Base64',
    'cipherBase64Desc':
        'Стандартное Base64-кодирование текста (UTF-8).',
    'cipherBase64Help':
        'Кодирует отфильтрованный текст в Base64. Декодирование обратно в UTF-8. Пробелы в коде игнорируются.',
    'cipherXor': 'XOR с ключом',
    'cipherXorDesc':
        'Побитовый XOR индексов букв текста и ключа (циклически).',
    'cipherXorHelp':
        'C = P ⊕ K. Шифрование и дешифрование совпадают. Нужен ключ из букв алфавита. Пробелы сохраняются.',
    'cipherRot47': 'ROT47',
    'cipherRot47Desc':
        'Сдвиг на 47 позиций по печатным ASCII-символам (!…~).',
    'cipherRot47Help':
        'Работает по таблице ASCII 33–126, а не по выбранному алфавиту. Повтор даёт исходный текст. Пробелы сохраняются.',
    'cipherTapCode': 'Тюремный код (tap)',
    'cipherTapCodeDesc':
        'Буква → два «стука» (ряды точек) по квадрату 5×5.',
    'cipherTapCodeHelp':
        'Формат: ряд точек, пробел, ряд точек. Пары разделяются двумя пробелами, слова — «/».',
    'cipherPlayfair': 'Плейфер',
    'cipherPlayfairDesc':
        'Биграммный шифр: пары букв шифруются по квадрату с ключевым словом.',
    'cipherPlayfairHelp':
        'Текст бьётся на пары. Одинаковые буквы в паре разбиваются заполнителем. Нужен ключ. Пробелы при шифровании убираются из потока букв.',
    'cipherScytale': 'Скитала',
    'cipherScytaleDesc':
        'Античная перестановка: текст пишется по колоннам «стержня» заданного диаметра.',
    'cipherScytaleHelp':
        'Диаметр = число колонн. Можно выбрать режим пробелов «целиком» или «пословно».',
    'cipherMorseDesc':
        'Азбука Морзе: буквы → точки и тире. Пробел в тексте становится разделителем слов « / ».',
    'cipherMorseHelp':
        'Формат\n'
        '• Буквы разделяются пробелом: .- -...\n'
        '• Слова разделяются « / ».\n\n'
        'Для русского/украинского используется русская азбука Морзе, для латиницы — международная.\n\n'
        'Ввод\n'
        'Кликайте по панели изменённого алфавита: точки, тире и готовые коды букв. Сверху кликайте обычные буквы.',
    'cipherBrailleDesc':
        'Шрифт Брайля: каждая буква → одна брайлевская ячейка Unicode.',
    'cipherBrailleHelp':
        'Используется литературный (grade 1) Брайль. Для русского и украинского — русская таблица, для английского и близких — латинская.\n\n'
        'Пробелы сохраняются. Ячейки удобно вставлять кликом по нижней/правой панели — на обычной клавиатуре их нет.',
    'cipherA1z26Desc':
        'Буква → её номер в алфавите (A=1…). Буквы в слове через дефис, слова через пробел.',
    'cipherA1z26Help':
        'Пример (английский): hello → 8-5-12-12-15\n'
        'Номера считаются по выбранному алфавиту, не только латиница.\n\n'
        'При дешифровании вводите числа и дефисы; пробел разделяет слова. Кнопка «-» на панели кодов вставляет разделитель.',
    'cipherNatoDesc':
        'Фонетический алфавит НАТО: A→Alpha, B→Bravo… Слова разделяются « | ».',
    'cipherNatoHelp':
        'Только латиница. Пробел в открытом тексте делит группы; в коде группы разделяются вертикальной чертой.\n\n'
        'Кликайте кодовые слова на панели, чтобы не набирать их вручную.',
  };

  static const _en = {
    'navCiphers': 'Ciphers',
    'navDetector': 'Detector',
    'navStudio': 'Custom',
    'detectorTitle': 'Cipher detector',
    'detectorSubtitle':
        'Paste ciphertext — Shifer tries simple schemes and common keys, then lists the most plausible plaintexts.',
    'detectorHint': 'Paste an encrypted message…',
    'detectorAnalyze': 'Analyze',
    'detectorNote':
        'Heuristic, not full cryptanalysis. Caesar/ROT/rails are brute-forced; keyed ciphers use a short key dictionary. Fast on phones for short texts.',
    'detectorEmpty': 'No results yet — paste text and tap Analyze.',
    'customStudioTitle': 'Cipher studio',
    'customStudioSubtitle':
        'Build your own cipher from a chain of operations: shift, mirror, keyword, etc. They apply top to bottom. Save it and use it like any built-in cipher.',
    'customCipherName': 'Cipher name',
    'customCipherKeyword': 'Keyword to shuffle the alphabet',
    'customCipherKeywordHelp':
        'Unique keyword letters come first, then the rest of the alphabet.',
    'customCipherPreview': 'Cipher alphabet preview',
    'customCipherList': 'Saved ciphers',
    'customCipherEmpty': 'No custom ciphers yet — create one above.',
    'customCipherError': 'Enter a name and a keyword with alphabet letters',
    'customCipherSaved': 'Cipher saved',
    'customCipherSavedDesc': 'Custom monoalphabetic substitution',
    'cipherCustomDesc': 'Your saved substitution cipher',
    'cipherCustomHelp':
        'Your personal monoalphabetic cipher. The substitution alphabet was set at creation. Spaces are preserved.',
    'diameter': 'Diameter (columns)',
    'navMixer': 'Mixer',
    'mixerTitle': 'Cipher mixer',
    'mixerSubtitle':
        'Chain several ciphers together: one cipher’s output feeds the next one’s input.',
    'mixerBaseAlphabet': 'Base alphabet',
    'mixerAddHint': 'Tap a cipher from the list to append it to the chain.',
    'mixerCannotAdd': 'This cipher cannot be appended to the current output',
    'mixerEmpty': 'Empty — pick a cipher from the list to build a chain',
    'mixerClear': 'Clear',
    'mixerInput': 'Input',
    'mixerOutput': 'Output',
    'mixerAlphabetIn': 'Input alphabet',
    'mixerAlphabetOut': 'Output alphabet',
    'constructorRule': 'Cipher type',
    'constructorSteps': 'Operations (in order)',
    'constructorAddStep': 'Add step',
    'constructorNoSteps': 'Add at least one step',
    'constructorNoParams': 'No parameters needed',
    'constructorExample': 'Test: encryption & decryption',
    'constructorMoveUp': 'Move up',
    'constructorMoveDown': 'Move down',
    'ruleShift': 'Shift',
    'ruleMirror': 'Mirror (Atbash)',
    'ruleKeyword': 'Keyword',
    'ruleCustom': 'Custom substitution',
    'ruleAffine': 'Affine (a·x+b)',
    'ruleRotHalf': 'ROT (half alphabet)',
    'ruleOddEven': 'Odd-even',
    'shiftAmount': 'Shift amount',
    'customLettersLabel': 'Cipher alphabet',
    'customLettersHelp':
        'All symbols of the selected alphabet in a new order, no repeats',
    'customLengthError':
        'The cipher alphabet must match the length and have no repeats',
    'categoryEncoding': 'Codes & alphabets',
    'spaceModeLabel': 'Spaces',
    'spaceKeep': 'Whole text (keep)',
    'spacePerWord': 'Word by word',
    'spaceUnsupported': 'Spaces are not available for this cipher',
    'spaceKeepHint':
        'Spaces stay in place; only alphabet symbols are transformed.',
    'spacePerWordHint':
        'Each word is transformed separately; spaces are separators only.',
    'clickAlphabetHint': 'Tap a symbol to insert it into the field',
    'exampleWord': 'hello',
    'cipherMirrorDesc':
        'Classic Atbash: the alphabet is mirrored — first letter swaps with last, and so on.',
    'cipherMirrorHelp':
        'How it works\n'
        'The selected alphabet is reversed. Each plaintext letter is replaced by the letter at the same index in the reversed alphabet.\n\n'
        'Example (English): A↔Z, B↔Y, …\n\n'
        'Spaces\n'
        'Kept in place and not encrypted.\n\n'
        'How to use\n'
        '1) Choose an alphabet.\n'
        '2) Type above to encrypt, or below to decrypt.\n'
        '3) Alphabet chips are clickable — handy for rare symbols.',
    'cipherCaesarDesc':
        'Each letter shifts by a fixed key. One of the oldest known ciphers.',
    'cipherCaesarHelp':
        'How it works\n'
        'Index x becomes (x + k) mod n. Decrypt with (x − k) mod n.\n\n'
        'Example: key 3, English: A→D, B→E, X→A.\n\n'
        'Spaces are preserved. The key may be any integer (including negative).\n\n'
        'The panel shows the full shifted alphabet.',
    'cipherRotHalfDesc':
        'Fixed shift by half the alphabet (ROT13 for English).',
    'cipherRotHalfHelp':
        'Shift is always n/2, so alphabet length must be even.\n\n'
        'Applying twice restores the original text (encrypt = decrypt).\n\n'
        'For English (26 letters) this is classic ROT13.',
    'cipherKeywordCaesarDesc':
        'Monoalphabetic cipher: unique keyword letters first, then the rest of the alphabet.',
    'cipherKeywordCaesarHelp':
        'Building the cipher alphabet\n'
        '1) Take unique letters from the keyword.\n'
        '2) Append remaining alphabet letters.\n'
        '3) Map original[i] → cipher[i].\n\n'
        'Example: KEY → KEYABCD…Z.\n\n'
        'Spaces are preserved.',
    'cipherAffineDesc':
        'Mathematical substitution (a·x + b) mod n. Stronger than Caesar when a is coprime to n.',
    'cipherAffineHelp':
        'Encrypt: y = (a·x + b) mod n\n'
        'Decrypt: x = a⁻¹·(y − b) mod n\n\n'
        'a must be coprime with n (gcd = 1). Otherwise the map is not reversible; the app falls back safely.\n\n'
        'Spaces are preserved.',
    'cipherOddEvenDesc':
        'Reorder alphabet: even indices first, then odd indices.',
    'cipherOddEvenHelp':
        'Zero-based indices. Then a normal monoalphabetic substitution is applied.\n\n'
        'No key. Spaces are preserved.',
    'cipherQwertyDesc':
        'ABC… alphabet remapped to QWERTY key order (Latin only).',
    'cipherQwertyHelp':
        'Builds a cipher alphabet from QWERTYUIOPASDFGHJKLZXCVBNM. Latin alphabets only.\n\n'
        'Spaces are preserved. Click chips to type.',
    'cipherYcukenDesc':
        'Same idea for the Russian ЙЦУКЕН layout.',
    'cipherYcukenHelp':
        'Russian keyboard order as cipher alphabet. Russian alphabet only.\n\n'
        'Spaces are preserved.',
    'cipherVigenereDesc':
        'Polyalphabetic cipher: shift follows the keyword. Stronger than Caesar with a long key.',
    'cipherVigenereHelp':
        'For the i-th letter, use the i-th key letter (key repeats).\n'
        'C = (P + K) mod n,  P = (C − K) mod n.\n\n'
        'Spaces do not consume key letters and stay in place.\n'
        'The “modified alphabet” preview uses the first key letter’s shift.',
    'cipherBeaufortDesc':
        'Vigenère variant: C = (K − P) mod n. Encrypt equals decrypt.',
    'cipherBeaufortHelp':
        'Same polyalphabetic idea with a different formula. Running again with the same key restores plaintext.\n\n'
        'Spaces are preserved and do not advance the key.',
    'cipherVariantBeaufortDesc':
        'Another variant: C = (P − K) mod n.',
    'cipherVariantBeaufortHelp':
        'Like Vigenère with subtraction the other way. Spaces are preserved.',
    'cipherAutokeyDesc':
        'Vigenère whose key continues with the plaintext after a primer.',
    'cipherAutokeyHelp':
        'First use the primer, then take shifts from already processed plaintext letters. This avoids a short repeating key.\n\n'
        'Spaces are preserved and are not part of the autokey.',
    'cipherGronsfeldDesc':
        'Like Vigenère, but the key is digits (shift amounts).',
    'cipherGronsfeldHelp':
        'Each digit is a shift for the next letter. The key repeats. Example: 31415.\n\n'
        'Spaces are preserved.',
    'cipherTrithemiusDesc':
        'Progressive Caesar: shifts 0, 1, 2, 3… with no separate key.',
    'cipherTrithemiusHelp':
        'First letter shifts by 0, second by 1, and so on (mod n). Historically the Trithemius table, ancestor of Vigenère.\n\n'
        'Spaces do not increase the shift counter.',
    'cipherPortaDesc':
        'Porta polyalphabetic cipher using paired alphabet halves. Even length required.',
    'cipherPortaHelp':
        'The alphabet is split in half. A key letter selects a table row that swaps between halves. Encryption is reciprocal.\n\n'
        'Odd-length alphabets are hidden from the list.\n'
        'Spaces are preserved.',
    'cipherRailFenceDesc':
        'Transposition: write text in a zigzag across rails, read row by row.',
    'cipherRailFenceHelp':
        'How it works\n'
        'Characters go down and up across R rails, then each rail is read left to right.\n\n'
        'Spaces\n'
        '• Whole text — spaces participate in the zigzag.\n'
        '• Word by word — each word is enciphered separately.\n\n'
        'No letter substitution — only order changes.',
    'cipherColumnarDesc':
        'Write text row-wise into a table; read columns in keyword order.',
    'cipherColumnarHelp':
        'Table width = keyword length. Columns are ordered by keyword letters (ties keep original order).\n\n'
        'Space modes match Rail Fence: whole text or per word.\n'
        'Permutation only — no substitution.',
    'cipherMorse': 'Morse code',
    'cipherBraille': 'Braille',
    'cipherA1z26': 'A1Z26 (letter numbers)',
    'cipherNato': 'NATO phonetic',
    'cipherReverse': 'Reverse text',
    'cipherReverseDesc':
        'Reverses the string. Word mode reverses each word separately.',
    'cipherReverseHelp':
        'How it works\n'
        'Characters are read backwards. Applying twice restores the original.\n\n'
        'Space modes\n'
        '• Whole text — reverse the entire phrase.\n'
        '• Word by word — “hello world” → “olleh dlrow”.',
    'cipherBacon': 'Bacon cipher',
    'cipherBaconDesc':
        'Each letter becomes a 5-symbol a/b (or 0/1) pattern.',
    'cipherBaconHelp':
        'Classic biliteral Bacon code. Letters separated by spaces, words by “/”. Accepts a/b or 0/1.',
    'cipherPolybius': 'Polybius square',
    'cipherPolybiusDesc':
        'Letter → row/column coordinates in a square table.',
    'cipherPolybiusHelp':
        'Square size fits the alphabet length. Ciphertext is digit pairs, words via “/”.',
    'cipherBinary': 'Binary code',
    'cipherBinaryDesc':
        'Alphabet index encoded in binary.',
    'cipherBinaryHelp':
        'Bit width fits alphabet size. Words separated by “/”.',
    'cipherHex': 'HEX code',
    'cipherHexDesc':
        'Alphabet index in hexadecimal.',
    'cipherHexHelp':
        'Compact numeric form. Words via “/”, values via spaces.',
    'cipherBase64': 'Base64',
    'cipherBase64Desc':
        'Standard Base64 encoding of the text (UTF-8).',
    'cipherBase64Help':
        'Encodes filtered text as Base64 and decodes back to UTF-8. Spaces in code are ignored.',
    'cipherXor': 'XOR with key',
    'cipherXorDesc':
        'Bitwise XOR of letter indices with a cycling key.',
    'cipherXorHelp':
        'C = P ⊕ K. Encrypt equals decrypt. Needs a keyword. Spaces are preserved.',
    'cipherRot47': 'ROT47',
    'cipherRot47Desc':
        'Shift by 47 across printable ASCII (!…~).',
    'cipherRot47Help':
        'Uses ASCII 33–126, not the selected alphabet. Applying twice restores text. Spaces kept.',
    'cipherTapCode': 'Tap code',
    'cipherTapCodeDesc':
        'Letter → two tap groups (dots) on a 5×5 square.',
    'cipherTapCodeHelp':
        'Format: dots, space, dots. Pairs separated by two spaces; words by “/”.',
    'cipherPlayfair': 'Playfair',
    'cipherPlayfairDesc':
        'Digraph cipher: letter pairs transformed via a keyword square.',
    'cipherPlayfairHelp':
        'Text is split into pairs; doubles get a filler. Needs a keyword. Spaces are stripped from the letter stream.',
    'cipherScytale': 'Scytale',
    'cipherScytaleDesc':
        'Ancient transposition: write down columns of a rod with given diameter.',
    'cipherScytaleHelp':
        'Diameter = number of columns. Supports whole-text or per-word space modes.',
    'cipherMorseDesc':
        'Morse code: letters → dots and dashes. A text space becomes the word separator “ / ”.',
    'cipherMorseHelp':
        'Format\n'
        '• Letters separated by spaces: .- -...\n'
        '• Words separated by “ / ”.\n\n'
        'Russian/Ukrainian use Russian Morse; Latin alphabets use International Morse.\n\n'
        'Input\n'
        'Click the cipher panel for dots, dashes, and letter codes. Click the original panel for letters.',
    'cipherBrailleDesc':
        'Braille: each letter → one Unicode Braille cell.',
    'cipherBrailleHelp':
        'Grade-1 literary Braille. Russian/Ukrainian use the Russian table; English-like alphabets use Latin.\n\n'
        'Spaces are preserved. Click cells on the panel — they are hard to type on a normal keyboard.',
    'cipherA1z26Desc':
        'Letter → its 1-based index. Letters in a word joined by hyphens; words by spaces.',
    'cipherA1z26Help':
        'Example (English): hello → 8-5-12-12-15\n'
        'Indices follow the selected alphabet.\n\n'
        'When decrypting, type numbers and hyphens; space separates words. Use the “-” chip to insert separators.',
    'cipherNatoDesc':
        'NATO phonetic alphabet: A→Alpha, B→Bravo… Word groups separated by “ | ”.',
    'cipherNatoHelp':
        'Latin letters only. A plaintext space starts a new group; groups in code are split by a vertical bar.\n\n'
        'Click codewords on the panel instead of typing them.',
  };
}
