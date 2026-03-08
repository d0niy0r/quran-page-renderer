import 'package:flutter/material.dart';

class TajweedColors {
  // API dan keluvchi uthmani_tajweed class nomlari
  static const Map<String, Color> classToColor = {
    // Ghunnah - yashil
    'ghunnah': Color(0xFF3CB371),
    // Ikhfa - ko'k-yashil
    'ikhafa': Color(0xFF00BCD4),
    'ikhafa_shafawi': Color(0xFF00ACC1),
    // Idgham - ko'k
    'idgham_ghunnah': Color(0xFF2196F3),
    'idgham_wo_ghunnah': Color(0xFF1976D2),
    'idgham_shafawi': Color(0xFF0D47A1),
    'idgham_mutajanisayn': Color(0xFF1565C0),
    'idgham_mutaqaribayn': Color(0xFF1565C0),
    // Iqlab - binafsha
    'iqlab': Color(0xFF9C27B0),
    // Qalqalah - to'q sariq
    'qalaqah': Color(0xFFFF5722),
    // Madd turlari - oltin/sariq
    'madda_normal': Color(0xFFFF9800),
    'madda_necessary': Color(0xFFE65100),
    'madda_obligatory': Color(0xFFF57C00),
    'madda_permissible': Color(0xFFFFB300),
    // Silent - kulrang
    'slnt': Color(0xFF9E9E9E),
    // Hamzat wasl - kulrang-ko'k
    'ham_wasl': Color(0xFF78909C),
    // Lam shamsiyyah - qorong'i kulrang
    'laam_shamsiyah': Color(0xFF546E7A),
  };

  static const Color defaultColor = Color(0xFF212121);

  static Color getColor(String? cssClass) {
    if (cssClass == null || cssClass.isEmpty) return defaultColor;
    return classToColor[cssClass] ?? defaultColor;
  }
}