import 'package:flutter_test/flutter_test.dart';

import 'package:employee_portal/core/constants/app_colors.dart';

void main() {
  test('theme colors match the requested Odoo dashboard palette', () {
    expect(AppColors.background.value, 0xFFF8F9FA);
    expect(AppColors.card.value, 0xFFFFFFFF);
    expect(AppColors.text.value, 0xFF2D3748);
  });
}
