#Область ОписаниеПеременных

&НаКлиенте
Перем ТекущаяСтрока;

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписокТоррентов

&НаКлиенте
Процедура СписокТоррентовПриАктивизацииСтроки(Элемент)
	Если Элементы.СписокТоррентов.ТекущаяСтрока <> ТекущаяСтрока Тогда
		ТекущаяСтрока = Элементы.СписокТоррентов.ТекущаяСтрока;
		Если ЗначениеЗаполнено(Элементы.СписокТоррентов.ТекущаяСтрока) Тогда
			ПодключитьОбработчикОжидания("ПолучитьДанныеТекущегоТоррента", 0.1, Истина);	
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Обновить(Команда)
	ОбновитьНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура КонтекстноеМенюАнонсировать(Команда)
	КонтекстноеМенюАнонсироватьНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура КонтекстноеМенюЗапустить(Команда)
	КонтекстноеМенюЗапуститьНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура КонтекстноеМенюЗапуститьПринудительно(Команда)
	КонтекстноеМенюЗапуститьПринудительноНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура КонтекстноеМенюОстановить(Команда)
	КонтекстноеМенюОстановитьНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура КонтекстноеМенюПроверить(Команда)
	КонтекстноеМенюПроверитьНаСервере();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПолучитьДанныеТекущегоТоррента() Экспорт
	ПолучитьДанныеТекущегоТоррентаНаСервере(Элементы.СписокТоррентов.ТекущиеДанные.id);
КонецПроцедуры

&НаСервере
Процедура КонтекстноеМенюЗапуститьНаСервере()
	МассивИдентификаторов = ПолучитьМассивИдентификаторовВыделенныхСтрок();
	Торрент.TorrentStart(МассивИдентификаторов);
КонецПроцедуры

&НаСервере
Процедура КонтекстноеМенюЗапуститьПринудительноНаСервере()
	МассивИдентификаторов = ПолучитьМассивИдентификаторовВыделенныхСтрок();
	Торрент.TorrentStartNow(МассивИдентификаторов);
КонецПроцедуры

&НаСервере
Процедура КонтекстноеМенюОстановитьНаСервере()
	МассивИдентификаторов = ПолучитьМассивИдентификаторовВыделенныхСтрок();
	Торрент.TorrentStop(МассивИдентификаторов);
КонецПроцедуры

&НаСервере
Процедура КонтекстноеМенюПроверитьНаСервере()
	МассивИдентификаторов = ПолучитьМассивИдентификаторовВыделенныхСтрок();
	Торрент.TorrentVerify(МассивИдентификаторов);
КонецПроцедуры

&НаСервере
Процедура КонтекстноеМенюАнонсироватьНаСервере()
	МассивИдентификаторов = ПолучитьМассивИдентификаторовВыделенныхСтрок();
	Торрент.TorrentReannounce(МассивИдентификаторов);
КонецПроцедуры

&НаСервере
Функция ПолучитьМассивИдентификаторовВыделенныхСтрок()
	МассивИдентификаторов = Новый Массив;
	
	Для Каждого ИдСтроки Из Элементы.СписокТоррентов.ВыделенныеСтроки Цикл
		МассивИдентификаторов.Добавить(СписокТоррентов.НайтиПоИдентификатору(ИдСтроки).id);
	КонецЦикла;
	
	Возврат МассивИдентификаторов;
КонецФункции

&НаСервере
Процедура ОбновитьНаСервере()
	Результат = Торрент.TorrentGet();
	СписокТоррентов.Очистить();
	Для Каждого стр Из Результат Цикл
		НоваяСтрока = СписокТоррентов.Добавить();
		НоваяСтрока.id = стр["id"];
		НоваяСтрока.name = стр["name"];
		НоваяСтрока.size = ТоррентОбщегоНазначения.БайтыВЧитаемойФорме(стр["totalSize"]);
	КонецЦикла;
	
	Статистика = Торрент.SessionStats();
	UploadSpeed = Статистика["uploadSpeed"];
	DownloadSpeed = Статистика["downloadSpeed"];
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьДанныеТекущегоТоррентаНаСервере(Ид)
	Данные = Торрент.TorrentGet(Ид);
	ActivityDate = ТоррентОбщегоНазначения.TimestampВДату(Данные[0]["activityDate"]);
	UploadRatio = Данные[0]["uploadRatio"];
	Трекеры.Очистить();
	Для Каждого Трекер Из Данные[0]["trackers"] Цикл
		НоваяСтрока = Трекеры.Добавить();
		НоваяСтрока.tier = Трекер["tier"];
		НоваяСтрока.sitename = Трекер["sitename"];
		НоваяСтрока.announce = Трекер["announce"];
	КонецЦикла;
	TotalSize = ТоррентОбщегоНазначения.БайтыВЧитаемойФорме(Данные[0]["totalSize"]);
	TorrentFile = Данные[0]["torrentFile"];
	PrimaryMimeType = Данные[0]["primary-mime-type"];
	PeerLimit = Данные[0]["peer-limit"];
	Name = Данные[0]["name"];
	DownloadDir = Данные[0]["downloadDir"];
	HashString = Данные[0]["hashString"];
	PieceCount = Данные[0]["pieceCount"];
	DateCreated = ТоррентОбщегоНазначения.TimestampВДату(Данные[0]["dateCreated"]);
	Creator = Данные[0]["creator"];
	Comment = Данные[0]["comment"];
	StartDate = ТоррентОбщегоНазначения.TimestampВДату(Данные[0]["startDate"]);
	
	Файлы.Очистить();
	Для Каждого Файл Из Данные[0]["files"] Цикл
		НоваяСтрока = Файлы.Добавить();
		НоваяСтрока.name = Файл["name"];
		НоваяСтрока.length = ТоррентОбщегоНазначения.БайтыВЧитаемойФорме(Файл["length"]);
		НоваяСтрока.bytesCompleted = ТоррентОбщегоНазначения.БайтыВЧитаемойФорме(Файл["bytesCompleted"]);	
	КонецЦикла;
	MagnetLink = Данные[0]["magnetLink"];
	
	AddedDate = ТоррентОбщегоНазначения.TimestampВДату(Данные[0]["addedDate"]);
КонецПроцедуры

#КонецОбласти




