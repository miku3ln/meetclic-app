import 'package:flutter/material.dart';
import 'package:meetclic/presentation/pages/profile-page/atoms/avatar_image.dart';

import 'package:meetclic/presentation/pages/profile-page/molecules/user-info-block.dart';
import 'package:meetclic/presentation/pages/profile-page/molecules/counter-info-item.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';
import 'package:meetclic/presentation/pages/profile-page/molecules/counter-reward-earned.dart';
import 'package:meetclic/presentation/widgets/atoms/title_widget.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final appLocalizations=  AppLocalizations.of(context);
    return Column(
      children:  [
        AvatarImage(size: 50),
        SizedBox(height: 12),

        UserInfoBlock(),
        SizedBox(height: 12),
        TitleWidget(
          title: 'Conexión',
          textAlign: TextAlign.left,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color:  theme.primaryColor,
        ),
        CounterInfoRow(
          items: [
            CounterInfoItem(
              count: 3,
              imageAsset: 'assets/pages/profile/business.png',
              label: appLocalizations.translate('profileDataTitle.business'),
              lineColor: theme.colorScheme.primary,
            ),
            CounterInfoItem(
              count: 6,
              imageAsset: 'assets/pages/profile/following.png',
              label: appLocalizations.translate('profileDataTitle.following'),
              lineColor: theme.colorScheme.primary,
            ),

            CounterInfoItem(
              count: 11,
              imageAsset: 'assets/pages/profile/followers.png',
              label: appLocalizations.translate('profileDataTitle.followers'),
              lineColor: theme.colorScheme.primary,
            ),
          ],
        ),
        SizedBox(height: 12),
        TitleWidget(
          title: appLocalizations.translate('gamingDataTitle.rewardsWonCount'),
          textAlign: TextAlign.left,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color:  theme.primaryColor,
        ),
        RewardsGrid(
          items: [
            CounterRewardEarned(
              count: 5699,
              imageAsset: 'assets/appbar/yapitas.png',
              label: 'Total XP',
              lineColor: Colors.yellow,
              onTap: () => print('Total XP tapped'),
            ),
            CounterRewardEarned(
              count: 120,
              imageAsset: 'assets/appbar/yapitas.png',
              label: 'Yapitas',
              lineColor: Colors.orange,
              onTap: () => print('Yapitas tapped'),
            ),
            CounterRewardEarned(
              count: 450,
              imageAsset: 'assets/appbar/yapitas-premium.png',
              label: 'Suma Yapitas',
              lineColor: Colors.purple,
              onTap: () => print('Suma Yapitas tapped'),
            ),
            CounterRewardEarned(
              count: 5,
              imageAsset: 'assets/appbar/trophy.png',
              label: 'Trofeos',
              lineColor: Colors.amber,
              onTap: () => print('Trofeos tapped'),
            ),
          ],
        ),
        SizedBox(height: 12),



      ],
    );
  }
}