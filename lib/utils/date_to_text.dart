import 'package:flutter/material.dart';

String dateToStr(DateTime date, Locale locale) {
  if (locale.languageCode != 'ru')
    return date.toIso8601String();
  date = date.toLocal();
  final now = DateTime.now();
  String str;
  final nearlyDay = date.year == now.year && date.month == now.month;
  final subDay = now.day - date.day;

  if (nearlyDay && subDay == 1) {
    // вчера
    str = 'вчера';
  } else if (nearlyDay && subDay == 0) {
    // сегодня
    str = 'сегодня';
  } else {
    const month = [
      'Января',
      'Февраля',
      'Марта',
      'Апреля',
      'Мая',
      'Июня',
      'Июля',
      'Августа',
      'Сентября',
      'Октября',
      'Ноября',
      'Декабря',
    ];
    str = "${date.day} ${month[date.month - 1]} ${date.year}";
  }
  str += ' в ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  return str;
}