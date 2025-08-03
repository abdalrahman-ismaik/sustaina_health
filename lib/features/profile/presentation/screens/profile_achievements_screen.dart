import 'package:flutter/material.dart';

class ProfileAchievementsScreen extends StatelessWidget {
  const ProfileAchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF141f18) : const Color(0xFFF8FBFA);
    final Color cardColor = isDark ? const Color(0xFF1e2f25) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF3c5d49) : const Color(0xFFD1E6D9);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0e1a13);
    final Color accentColor = isDark ? const Color(0xFF94e0b2) : const Color(0xFF51946c);
    final Color tileBg = isDark ? const Color(0xFF1e2f25) : const Color(0xFFE8F2EC);

    final List<_AchievementCategory> categories = <_AchievementCategory>[
      _AchievementCategory(
        icon: Icons.fitness_center,
        label: 'Exercise Milestones',
      ),
      _AchievementCategory(
        icon: Icons.restaurant,
        label: 'Nutrition Goals',
      ),
      _AchievementCategory(
        icon: Icons.nightlight_round,
        label: 'Sleep Consistency',
      ),
      _AchievementCategory(
        icon: Icons.park,
        label: 'Sustainability Impact',
      ),
    ];

    final List<String> badgeImages = <String>[
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBuS0i2VJHDvs_o-rC3_gYfhIb66_V9gHcqr_Db_IkZ51wHiUCwFio4HDxGt6cGyq-DxBD_bbXRoedMzTgNhVh0D5Q940MtUwiYmKZY3RIKwZt1IG4fJ1S-Kehs0Kh7WQ0cEOr1-Ovum6G4YOiGRnT1Ii7sV2K6qCqjWVgnP_Nkp4_oDSFxLYRMes9UQFvL79TGP2CrQfS-Nk8xNSVtFc0RX_06my4LJD5vmZ5a5XXwZw-TQOAiOjju6F45Ypo224Lawa122XLePLK2',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDdhBiDWUGUDtCRLuuBgTi9qaqo8A_z15Z36h3nEnd_Jc6Hif2g2NOR402Ai3-ptxAESLkkrCHT2EnJni9V3DkaJL7m_8dnI3BwIeNyt06HYtP7xu1EA8U9EIkkEASnlX9GSSQPHKh8lkR1ws52vBWdVFzU9LvndR9W9u7MPk7L2ew7IXx9J4EuikriVXo78Uygfy_l_64TzoSIsTskEPItUW3SQjE_KAqAeNY2Cf9wJpe8KHcXaNUJNDl2walZzLTdPmfZ8sR8JJxI',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAD_Mx2_NO1B8i37VyXvhWN72dD47JwtwNmrw_xxZce4m7jGmFifvL3PkvN3N_QbUQdJ54hwUwTS4NI5WbkzY0iUDAhNFsmctwtJqYJla8obUXW5i44u3-AjsAw9YfEPPavdUMUQXjptIaGBA2V92SKHv36nOtFu3uGPAdqslOsNqEygHTth5lsymsXHsoKF3hJBNTFCulb2eYn5LOvM0Q30C6KueOJnxuTtTpH9DYiUnkCm0bEzovoeI2Pa8GrUOmFwU9xVm8aBw7L',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBtFqRgnSJprykTrudn39uSpYBIYdUK_6mIg_zF0MLi43Xz0CmYwC9TG9NECZPrCU_2U4clpvwXK2kdUbJxfsoMdmPhF0EJDpMo8pTwm_zucp8O68DoJIq-U2J63jymE2Bag0ipb8mSeaicUZbQTgbAf7JkNThmsaHVam8NRSdezv3oZRdeH2enLVerK_BQrpbxZlCVlyYxePdUgQEoiAGda1Kq0pBV046bFtrrrSEGDpvWEyPIM9KtaqnnTpURaHxw8pl4gJdUJ505',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBOnXvOp-LOEQjGeHu70aoUPl0cbYgtn5V-IJdpqznhKewekHXFcU12bcsRVbK6QV2HuN7ZTL5ig6F7FDr6X5iTq0ZXno7gXeQlxtPsImBdwOHTlciK4lnzGy6XsnhBXp18ioJouP9TC45-bMiJF69GquQ4rlVlE3JoAB_u-AT5qD8ECv4ZxXm95eCzF54JrxuIvxdd8BwkvgEnhbDn_GAJhaT9CTdRoqof8fdqx6ezp2u84RKc07vthLEQTwb47GTOPFU_mh9hYJrr',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAHO3r305UR0BJxQ5z5c-7k0IN1mrbd96dVIo49StnNp_oDLhXlxnEsv1vm1XQI3dDcd-MTRh_T1_kWAAa0lWXBov4syx47O39RNGGY1KuvdFLCuEd4yfh6wsalKOUGV1vYRizNe4RAd2ZvGNwxqkzRaK3tWSAh8sBo74g6jJeEnQmFPoFkdQp7vdyVfETN7Py9TvBJih3phEy97zA5px0SLu9HkTELX4UbGfk05QdxfJbO4Av052V2-gBNCU4VOwO2VGVsIYPxD1Pc',
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Achievements',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.015,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Achievement Categories', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: categories,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Badge Collection', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: badgeImages.length,
                itemBuilder: (BuildContext context, int i) => GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Badge ${i + 1}: Achievement details (mock)'),
                        backgroundColor: cardColor,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: tileBg,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(badgeImages[i], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Tap on a badge to view achievement details and progress toward the next level.', style: TextStyle(color: textColor, fontSize: 14)),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _AchievementCategory extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AchievementCategory({required this.icon, required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF1e2f25) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF3c5d49) : const Color(0xFFD1E6D9);
    final Color textColor = isDark ? Colors.white : const Color(0xFF0e1a13);
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

 