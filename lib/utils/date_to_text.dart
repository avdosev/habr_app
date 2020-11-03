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
  final currentDay = DateTime(now.year, now.month, now.day);
  final yesterday = currentDay.add(Duration(days: -1));

  if (date.isAfter(currentDay)) {
    // сегодня
    str = 'сегодня';
  } else if (date.isAfter(yesterday)) {
    // вчера
    str = 'вчера';
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