import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DateService {
  static String monthAndYear(Timestamp timestamp) {
    //mes por extenso
    String month = timestamp.toDate().month.toString();
    String year = timestamp.toDate().year.toString();
    switch (month) {
      case '1':
        month = 'Janeiro';
        break;
      case '2':
        month = 'Fevereiro';
        break;
      case '3':
        month = 'Março';
        break;
      case '4':
        month = 'Abril';
        break;
      case '5':
        month = 'Maio';
        break;
      case '6':
        month = 'Junho';
        break;
      case '7':
        month = 'Julho';
        break;
      case '8':
        month = 'Agosto';
        break;
      case '9':
        month = 'Setembro';
        break;
      case '10':
        month = 'Outubro';
        break;
      case '11':
        month = 'Novembro';
        break;
      case '12':
        month = 'Dezembro';
        break;
    }
    return '$month $year';
  }

  static String timestampToDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    String day = date.day.toString();
    String month = date.month.toString();
    String year = date.year.toString();
    if (day.length == 1) {
      day = '0$day';
    }
    if (month.length == 1) {
      month = '0$month';
    }
    return '$day/$month/$year';
  }
}
