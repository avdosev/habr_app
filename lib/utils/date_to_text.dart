import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String dateToStr(DateTime date, Locale locale) {
  date = date.toLocal();
  final now = DateTime.now();
  if (locale.languageCode != 'ru') {
    String format = '';
    format += 'MMMM dd';
    if (now.year != date.year)
      format += ' yyyy';
    final dayDate = DateFormat(format).format(date);
    final time = DateFormat.Hm().format(date);
    return "$dayDate at $time";
  }
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