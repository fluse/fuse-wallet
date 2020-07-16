import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fusecash/generated/i18n.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fusecash/models/views/drawer.dart';
import 'package:fusecash/screens/backup/show_mnemonic.dart';
import 'package:fusecash/screens/cash_home/switch_commmunity.dart';
import 'package:fusecash/screens/cash_home/webview_page.dart';
import 'package:fusecash/screens/misc/settings.dart';
import 'package:fusecash/utils/forks.dart';
import 'package:fusecash/utils/format.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final assetIdController = TextEditingController(text: "");
  String userName = "";

  @override
  void initState() {
    super.initState();
  }

  Widget getListTile(String label, void Function() onTap,
      {String icon, Widget temp}) {
    return ListTile(
      contentPadding: EdgeInsets.only(top: 5, bottom: 5, left: 20),
      title: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/images/' '$icon',
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                        fontSize: 16, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
              temp != null
                  ? Positioned(
                      right: 0,
                      bottom: 0,
                      child: temp,
                    )
                  : SizedBox.shrink()
            ],
          )),
      onTap: onTap,
    );
  }

  List<Widget> pluginsItems(DrawerViewModel viewModel) {
    List<Widget> plugins = [];
    List depositPlugins = viewModel?.plugins?.getDepositPlugins();
    if (depositPlugins.isNotEmpty) {
      plugins.add(new Divider(
        color: Color(0xFFCBCBCB),
      ));
      plugins.add(ListTile(
        contentPadding: EdgeInsets.only(top: 5, bottom: 5, left: 20),
        title: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                'assets/images/top_up.svg',
                width: 20,
                height: 20,
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                I18n.of(context).top_up,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
        onTap: () {
          dynamic url = depositPlugins[0].generateUrl();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewPage(
                    pageArgs: WebViewPageArguments(url: url, title: 'Top up')),
                fullscreenDialog: true),
          );
          Segment.track(eventName: 'User clicked on top up');
        },
      ));
    }

    return plugins;
  }

  List<Widget> menuItem(DrawerViewModel viewModel) {
    if (isFork()) {
      return [
        getListTile(I18n.of(context).backup_wallet, () {
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => ShowMnemonic()));
        },
            icon: 'backup_icon.svg',
            temp: !viewModel.isBackup
                ? SvgPicture.asset(
                    'assets/images/back_up_icon.svg',
                    width: 17,
                    height: 17,
                  )
                : null),
        getListTile(I18n.of(context).settings, () {
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => SettingsScreen()));
        }, icon: 'settings_icon.svg'),
      ];
    } else {
      return [
        getListTile(I18n.of(context).switch_community, () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => SwitchCommunityScreen()));
        }, icon: 'switch_icon.svg'),
        getListTile(I18n.of(context).backup_wallet, () {
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => ShowMnemonic()));
        },
            icon: 'backup_icon.svg',
            temp: !viewModel.isBackup
                ? SvgPicture.asset(
                    'assets/images/back_up_icon.svg',
                    width: 17,
                    height: 17,
                  )
                : null),
        getListTile(I18n.of(context).settings, () {
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => SettingsScreen()));
        }, icon: 'settings_icon.svg'),
      ];
    }
  }

  Widget drawerHeader(DrawerViewModel viewModel) {
    return DrawerHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            onTap: () {
              print('click on account');
            },
            child: Padding(
                padding: EdgeInsets.only(top: 10, bottom: 15, left: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: new AssetImage('assets/images/anom.png'),
                      radius: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            (viewModel?.firstName() ?? ''),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 22,
                                fontWeight: FontWeight.normal),
                          ),
                          viewModel.walletAddress != null
                              ? Row(
                                  children: <Widget>[
                                    Text(
                                      formatAddress(viewModel.walletAddress),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                )
                              : SizedBox.shrink()
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          border: Border(bottom: BorderSide(color: Color(0xFFE8E8E8)))),
    );
  }

  @override
  Widget build(BuildContext _context) {
    return new StoreConnector<AppState, DrawerViewModel>(
        converter: DrawerViewModel.fromStore,
        builder: (_, viewModel) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.78,
            child: Drawer(
                child: Column(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    children: <Widget>[
                      drawerHeader(viewModel),
                      ...menuItem(viewModel),
                      ...pluginsItems(viewModel),
                    ],
                  ),
                )
              ],
            )),
          );
        });
  }
}
