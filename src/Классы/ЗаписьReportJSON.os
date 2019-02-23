Перем _Лог;
Перем _ФайлДжсон;


Процедура ПриСозданииОбъекта( Знач пФайлДжсон, Знач пЛог )
	
	_ФайлДжсон = пФайлДжсон;
	_Лог = пЛог;
	
КонецПроцедуры

Процедура Записать( Знач пТаблицаРезультатовПроверки ) Экспорт
	
	ошибки = Новый Массив;
	
	Для каждого цСтрока Из пТаблицаРезультатовПроверки Цикл
		
		структОшибка = Новый Структура;
		
		структОшибка.Вставить("engineId", ИсточникПроверки());
		структОшибка.Вставить("ruleId", ИдентификаторПравил(цСтрока) );
		структОшибка.Вставить("primaryLocation", МестонахождениеОшибки(цСтрока));
		структОшибка.Вставить("type", ТипОшибки(цСтрока));
		структОшибка.Вставить("severity", ВажностьОшибки(цСтрока));
		структОшибка.Вставить("effortMinutes", ЗатратыНаИсправление(цСтрока));
		структОшибка.Вставить("secondaryLocations", ВторостепенноеМестонахождение(цСтрока));
		
		ошибки.Добавить( структОшибка );

	КонецЦикла;
	
	структ = Новый Структура("issues", ошибки);
	
	ЗаписатьФайлJSON( структ );
	
КонецПроцедуры

Функция ИсточникПроверки()
	
	Возврат "edt";
	
КонецФункции

Функция ИдентификаторПравил( Знач пДанные )
	
	текстОшибки = пДанные.Описание;

	// Контекст ошибки всегда в конце, просто обрежем все, что после [

	начало = СтрНайти( текстОшибки, "[" );
	
	Если начало > 0 Тогда
		
		текстОшибки = Лев( текстОшибки, начало - 1 );
		
	КонецЕсли;
	
	текстОшибки = ЗаменитьТекстВКавычках( текстОшибки, """", "%1" );
	текстОшибки = ЗаменитьТекстВКавычках( текстОшибки, "'", "%1" );
	
	// Пояснение к ошибке нам не нужно

	начало = СтрНайти( текстОшибки, ":", НаправлениеПоиска.СКонца );
	
	Если начало > 0 Тогда
		
		текстОшибки = СокрЛП( Лев( текстОшибки, начало - 1 ) );
		
	КонецЕсли;
	
	Возврат СокрЛП( текстОшибки );
		
КонецФункции

Функция ЗаменитьТекстВКавычках( Знач пСтрока, Знач пКавычка = """", Знач пТекстЗамены = "" )
	
	ПозицияКавычки = СтрНайти( пСтрока, пКавычка );
	
	Пока ПозицияКавычки > 0 Цикл
		
		ПозицияЗакрывающейКавычки = СтрНайти( Сред( пСтрока, ПозицияКавычки + 1 ), пКавычка ) + ПозицияКавычки;
		
		Если ПозицияЗакрывающейКавычки = 0 Тогда
			
			Прервать;
			
		КонецЕсли;
		
		пСтрока = Лев( пСтрока, ПозицияКавычки - 1 ) + пТекстЗамены + Сред( пСтрока, ПозицияЗакрывающейКавычки + 1 );
		ПозицияКавычки = СтрНайти( пСтрока, пКавычка );
		
	КонецЦикла;

	Возврат пСтрока;

КонецФункции

Функция МестонахождениеОшибки( Знач пДанные )
	
	структ = Новый Структура;
	
	структ.Вставить( "message", СообщениеОбОшибке( пДанные ));
	структ.Вставить( "filePath", ПутьКФайлу( пДанные ));
	структ.Вставить( "textRange", КоординатыОшибки( пДанные ));
	
	Возврат структ;
	
КонецФункции

Функция СообщениеОбОшибке( Знач пДанные )
	
	Возврат пДанные.Описание;
	
КонецФункции

Функция ПутьКФайлу( Знач пДанные )
	
	Возврат стрЗаменить( пДанные.Путь, "\", "/" );
	
КонецФункции

Функция КоординатыОшибки( Знач пДанные )
	
	структ = Новый Структура;
	
	Попытка
		структ.Вставить( "startLine", Число( пДанные.НомерСтроки ) );
	Исключение
		_Лог.Ошибка( "Не удалось преобразовать к числу номер строки: " + пДанные.НомерСтроки );
		структ.Вставить( "startLine", 1 );
	КонецПопытки;

	
	//структ.Вставить( "endLine ", );
	//структ.Вставить( "startColumn ", );
	//структ.Вставить( "endColumn  ", );
	
	Возврат структ;
	
КонецФункции

Функция ТипОшибки( Знач пДанные )
	// BUG, VULNERABILITY, CODE_SMELL
	
	Если пДанные.Тип = "Ошибка" Тогда
		
		Возврат "BUG";
		
	Иначе
		
		Возврат "CODE_SMELL";
		
	КонецЕсли;
	
КонецФункции

Функция ВажностьОшибки( Знач пДанные )
	// BLOCKER, CRITICAL, MAJOR, MINOR, INFO
	
	Если пДанные.Тип = "Ошибка" Тогда
		
		Возврат "CRITICAL";
		
	Иначе
		
		Возврат "MINOR";
		
	КонецЕсли;
	
КонецФункции

Функция ЗатратыНаИсправление( Знач пДанные )
	
	Возврат 0;
	
КонецФункции

Функция ВторостепенноеМестонахождение( Знач пДанные )
	
	Возврат Новый Массив;
	
КонецФункции

Процедура ЗаписатьФайлJSON(Знач пЗначение)
	
	ОбщегоНазначения.ЗаписатьJSONВФайл( пЗначение, _ФайлДжсон );

	_Лог.Отладка( "Записан " + _ФайлДжсон );
	
КонецПроцедуры