import 'package:extended_image/extended_image.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';
import 'package:oktoast/oktoast.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'example_route.dart';
import 'example_route_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final TuChongRepository listSourceRepository = TuChongRepository();
  MyApp() {
    clearDiskCachedImages(duration: Duration(days: 7));
    listSourceRepository.loadData().then((result) {
      if (listSourceRepository.length > 0)
        _imageTestUrls = listSourceRepository.map((f) => f.imageUrl).toList();
    });
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      title: 'ExtendedText',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [
        FFNavigatorObserver(routeChange: (name) {
          //you can track page here
          // print(name);
        }, showStatusBarChange: (bool showStatusBar) {
          if (showStatusBar) {
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
          } else {
            SystemChrome.setEnabledSystemUIOverlays([]);
          }
        })
      ],
      builder: (c, w) {
        ScreenUtil.init(width: 750, height: 1334, allowFontScaling: true);
        // ScreenUtil.instance =
        //     ScreenUtil(width: 750, height: 1334, allowFontScaling: true)
        //       ..init(c);
        if (!kIsWeb) {
          final data = MediaQuery.of(c);
          return MediaQuery(
            data: data.copyWith(textScaleFactor: 1.0),
            child: w,
          );
        }
        return w;
      },
      initialRoute: "fluttercandies://mainpage",
      onGenerateRoute: (RouteSettings settings) {
        var routeName = settings.name;
        //when refresh web, route will as following
        //   /
        //   /fluttercandies:
        //   /fluttercandies:/
        //   /fluttercandies://mainpage

        if (kIsWeb && routeName.startsWith('/')) {
          routeName = routeName.replaceFirst('/', '');
        }

        var routeResult =
            getRouteResult(name: routeName, arguments: settings.arguments);

        if (routeResult.showStatusBar != null ||
            routeResult.routeName != null) {
          settings = FFRouteSettings(
              arguments: settings.arguments,
              name: routeName,
              isInitialRoute: settings.isInitialRoute,
              routeName: routeResult.routeName,
              showStatusBar: routeResult.showStatusBar);
        }

        var page = routeResult.widget ??
            getRouteResult(
                    name: 'fluttercandies://mainpage',
                    arguments: settings.arguments)
                .widget;

        final platform = Theme.of(context).platform;
        switch (routeResult.pageRouteType) {
          case PageRouteType.material:
            return MaterialPageRoute(settings: settings, builder: (c) => page);
          case PageRouteType.cupertino:
            return CupertinoPageRoute(settings: settings, builder: (c) => page);
          case PageRouteType.transparent:
            return platform == TargetPlatform.iOS
                ? TransparentCupertinoPageRoute(
                    settings: settings, builder: (c) => page)
                : TransparentMaterialPageRoute(
                    settings: settings, builder: (c) => page);
//            return FFTransparentPageRoute(
//                settings: settings,
//                pageBuilder: (BuildContext context, Animation<double> animation,
//                        Animation<double> secondaryAnimation) =>
//                    page);
          default:
            return platform == TargetPlatform.iOS
                ? CupertinoPageRoute(settings: settings, builder: (c) => page)
                : MaterialPageRoute(settings: settings, builder: (c) => page);
        }
      },
    ));
  }
}

List<String> _imageTestUrls;
List<String> get imageTestUrls =>
    _imageTestUrls ??
    <String>["https://photo.tuchong.com/4870004/f/298584322.jpg"];

///save netwrok image to photo
Future<bool> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
  var data = await getNetworkImageData(url, useCache: useCache);
  var filePath = await ImagePickerSaver.saveFile(fileData: data);
  return filePath != null && filePath != "";
}
