String intToMetricPrefix(int number) {
  if (number <= 1000) {
    return number.toString();
  } else {
    return (number / 1000).toStringAsPrecision(2) + 'k';
  }
}