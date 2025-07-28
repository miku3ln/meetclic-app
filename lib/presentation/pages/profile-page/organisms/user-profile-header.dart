import 'package:flutter/material.dart';
import 'package:meetclic/presentation/pages/profile-page/atoms/avatar_image.dart';

import 'package:meetclic/presentation/pages/profile-page/molecules/user-info-block.dart';
import 'package:meetclic/presentation/pages/profile-page/molecules/counter-info-item.dart';
import 'package:meetclic/shared/localization/app_localizations.dart';
import 'package:meetclic/presentation/pages/profile-page/molecules/counter-reward-earned.dart';
import 'package:meetclic/presentation/widgets/atoms/title_widget.dart';
import '../../../../shared/providers_session.dart';
import 'package:meetclic/infrastructure/assets/app_images.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = Provider.of<SessionService>(
      context,
    ); // ✅ Reactivo: escucha cambios
    var userData = session.currentSession;
    final appLocalizations = AppLocalizations.of(context);
    return Column(
      children: [
        AvatarImage(size: 50),
        SizedBox(height: 12),
        UserInfoBlock(),
        SizedBox(height: 12),
        TitleWidget(
          title: 'Conexión',
          textAlign: TextAlign.left,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
        ),
        CounterInfoRow(
          items: [
            CounterInfoItem(
              count: 3,
              imageAsset: AppImages.pageLoginInit,
              label: appLocalizations.translate('profileDataTitle.business'),
              lineColor: theme.colorScheme.primary,
            ),
            CounterInfoItem(
              count: 6,
              imageAsset: AppImages.pageProfileFollowing,
              label: appLocalizations.translate('profileDataTitle.following'),
              lineColor: theme.colorScheme.primary,
            ),

            CounterInfoItem(
              count: 11,
              imageAsset:  AppImages.pageProfileFollowers,
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
          color: theme.primaryColor,
        ),
        RewardsGrid(
          items: [
            CounterRewardEarned(
              count: 5699,
              imageAsset:AppImages.coinTypeYapitas,
              label: 'Total XP',
              lineColor: Colors.yellow,
              onTap: () => print('Total XP tapped'),
            ),
            CounterRewardEarned(
              count: 120,
              imageAsset: AppImages.coinTypeYapitas,
              label: 'Yapitas',
              lineColor: Colors.orange,
              onTap: () => print('Yapitas tapped'),
            ),
            CounterRewardEarned(
              count: 450,
              imageAsset: AppImages.coinTypeYapitasPremium,
              label: 'Suma Yapitas',
              lineColor: Colors.purple,
              onTap: () => print('Suma Yapitas tapped'),
            ),
            CounterRewardEarned(
              count: 5,
              imageAsset: AppImages.rewardTypeTrophy,
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
