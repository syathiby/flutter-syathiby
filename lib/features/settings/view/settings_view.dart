import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syathiby/core/utils/router/routes.dart';
import 'package:syathiby/features/auth/login/bloc/login_bloc.dart';
import 'package:syathiby/features/auth/login/bloc/login_event.dart';
import 'package:syathiby/features/auth/login/bloc/login_state.dart';
import 'package:syathiby/features/profile/bloc/profile_bloc.dart';
import 'package:syathiby/features/profile/bloc/profile_state.dart';
import 'package:syathiby/features/theme/bloc/theme_bloc.dart';
import 'package:syathiby/features/theme/bloc/theme_event.dart';
import 'package:syathiby/features/theme/bloc/theme_state.dart';
import 'package:syathiby/core/constants/app_constants.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/core/constants/supported_locales.dart';
import 'package:syathiby/generated/locale_keys.g.dart';
import 'package:syathiby/common/helpers/ui_helper.dart';
import 'package:syathiby/features/profile/widget/profile_photo_widget.dart';
import 'package:syathiby/features/settings/widget/list_section_widet.dart';
import 'package:syathiby/features/settings/widget/list_tile_widget.dart';
import 'package:syathiby/common/widgets/custom_scaffold.dart';
import 'package:syathiby/common/widgets/unauthenticated_user_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
part "settings_view_mixin.dart";

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with SettingsViewMixin {
  String _appVersion = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = "v${packageInfo.version}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final LoginBloc loginBloc = BlocProvider.of<LoginBloc>(context);
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, loginState) {
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            return BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, themeState) {
                return CustomScaffold(
                  onRefresh: () async {
                    await Future<void>.delayed(
                      const Duration(milliseconds: 1000),
                    );
                  },
                  title: LocaleKeys.settings,
                  children: [
                    profileState.user != null
                        ? Column(
                            children: [
                              ListSectionWidget(
                                hasLeading: false,
                                dividerMargin: 0,
                                children: [
                                  CupertinoListTile(
                                    onTap: () {
                                      context.push(Routes.profile.path);
                                    },
                                    padding: const EdgeInsets.all(10),
                                    backgroundColorActivated: themeState.isDark
                                        ? ColorConstants
                                            .darkBackgroundColorActivated
                                        : ColorConstants
                                            .lightBackgroundColorActivated,
                                    title: Text(
                                      "${profileState.user?.name}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Text(profileState.user!.email),
                                    leadingSize: UIHelper.deviceWidth * 0.12,
                                    leading: ProfilePhotoWidget(
                                        imageUrl: profileState.user!.photoUrl),
                                    trailing: Icon(
                                      CupertinoIcons.forward,
                                      color: themeState.isDark
                                          ? ColorConstants.darkSecondaryIcon
                                          : ColorConstants.lightSecondaryIcon,
                                    ),
                                  ),
                                  ListTileWidget(
                                    leadingIcon: CupertinoIcons.calendar_today,
                                    leadingColor: CupertinoColors.systemCyan,
                                    title:
                                        "${LocaleKeys.you_joined_on_prefix.tr()}${AppConstants.dateformat.format(profileState.user!.createdAt)}${LocaleKeys.you_joined_on_suffix.tr()} ($_appVersion)",
                                    titleTextStyle: TextStyle(
                                        color: themeState.isDark
                                            ? ColorConstants.darkInactive
                                            : ColorConstants.lightInactive),
                                  )
                                ],
                              ),
                            ],
                          )
                        : const UnauthenticatedUserWidget(),
                    ListSectionWidget(
                      children: [
                        ListTileWidget(
                          title: LocaleKeys.theme.tr(),
                          leadingIcon: CupertinoIcons.sun_min_fill,
                          leadingColor: CupertinoColors.systemBlue,
                          onTap: () => _showSelectThemeSheet(context),
                        ),
                        ListTileWidget(
                          title: LocaleKeys.language.tr(),
                          leadingIcon: CupertinoIcons.globe,
                          leadingColor: CupertinoColors.systemGreen,
                          onTap: () => _showSelectLanguageSheet(context),
                        ),
                      ],
                    ),
                    ListSectionWidget(
                      children: [
                        ListTileWidget(
                          title: LocaleKeys.logout.tr(),
                          leadingIcon: CupertinoIcons.square_arrow_left_fill,
                          leadingColor: CupertinoColors.systemRed,
                          onTap: () => _showLogOutDialog(context, loginBloc),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
