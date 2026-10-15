- [路由管理](#路由管理)
  - [如何使用](#如何使用)
  - [普通路由导航](#普通路由导航)
    - [iOS 侧滑返回的触发区域](#ios-侧滑返回的触发区域)
  - [别名路由导航](#别名路由导航)
    - [发送数据到别名路由](#发送数据到别名路由)
    - [动态网页链接](#动态网页链接)
    - [中间件](#中间件)
  - [免context导航](#免context导航)
  - [嵌套导航](#嵌套导航)
    - [participatesInRootNavigator 约定](#participatesinrootnavigator-约定)
    - [outlet 里的页没有自动返回键](#outlet-里的页没有自动返回键)
    - [从 outlet 页跳出去的顶层页不进 outlet](#从-outlet-页跳出去的顶层页不进-outlet)
    - [旧的 nestedKey 写法](#旧的-nestedkey-写法)

# 路由管理

这是关于Getx在路由管理方面的完整解释。

## 如何使用

将此添加到你的pubspec.yaml文件中。

```yaml
dependencies:
  get:
```

如果你要在没有context的情况下使用路由，或者使用高级的Get API，你只需要在你的MaterialApp前面加上 "Get"，就可以把它变成GetMaterialApp，享受吧!

```dart
GetMaterialApp( // Before: MaterialApp(
  home: MyHome(),
)
```

## 普通路由导航

导航到新的页面。

```dart
Get.to(NextScreen());
```

关闭路由，或任何你通常会用Navigator.pop(context)关闭的东西。

```dart
Get.back();
```

进入下一个页面，但没有返回上一个页面的选项（用于SplashScreens，登录页面等）。

```dart
Get.off(NextScreen());
```

进入下一个界面并取消之前的所有路由（在购物车、投票和测试中很有用）。

```dart
Get.offAll(NextScreen());
```

要导航到下一条路由，并在返回后立即接收或更新数据。

```dart
var data = await Get.to(Payment());
```

在另一个页面上，发送前一个路由的数据。

```dart
Get.back(result: 'success');
```

并使用它，例：

```dart
if(data == 'success') madeAnything();
```

你不想学习我们的语法吗？
只要把 Navigator（大写）改成 navigator（小写），你就可以拥有标准导航的所有功能，而不需要使用context，例如：

```dart

// 默认的Flutter导航
Navigator.of(context).push(
  context,
  MaterialPageRoute(
    builder: (BuildContext context) {
      return HomePage();
    },
  ),
);

// 使用Flutter语法获得，而不需要context。
navigator.push(
  MaterialPageRoute(
    builder: (_) {
      return HomePage();
    },
  ),
);

// get语法 (这要好得多)
Get.to(HomePage());


```

### iOS 侧滑返回的触发区域

iOS 上默认开启侧滑返回，触发区域**只在屏幕起始边缘一条带内**（默认 44pt；刘海屏按安全区加宽）—— 页面上其他位置横向拖动不会触发，横滑 ListView / 轮播 / 滑块也不会被抢走手势。

默认取 44pt 是 Apple HIG 的最小可点击区域，而不是 Flutter 原生的 20：手指落点是一块约 40pt 宽的接触面，20pt 只有半个指腹，单手握持时拇指弧线扫过边缘，差十几像素就完全没反应且毫无反馈。44pt 在 393pt 宽的手机上约占 11%，仍然是明确的边缘手势。

需要微调就按页覆盖：

```dart
GetPage(
  name: '/detail',
  page: () => const DetailPage(),
  gestureWidth: (context) => 60, // 触发带宽度，默认 44
);
```

单个路由想关掉侧滑就传 `popGesture: false`。注意侧滑是**边缘拖拽**：松手时拖过屏幕一半才会真正返回，拖不到一半会弹回原位。

## 别名路由导航

- 如果你喜欢用别名路由导航，Get也支持。

导航到下一个页面

```dart
Get.toNamed("/NextScreen");
```

浏览并删除前一个页面。

```dart
Get.offNamed("/NextScreen");
```

浏览并删除所有以前的页面。

```dart
Get.offAllNamed("/NextScreen");
```

要定义路由，使用GetMaterialApp。

```dart
void main() {
  runApp(
    GetMaterialApp(
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MyHomePage()),
        GetPage(name: '/second', page: () => Second()),
        GetPage(
          name: '/third',
          page: () => Third(),
          transition: Transition.zoom  
        ),
      ],
    )
  );
}
```

要处理到未定义路线的导航（404错误），可以在GetMaterialApp中定义unknownRoute页面。

```dart
void main() {
  runApp(
    GetMaterialApp(
      unknownRoute: GetPage(name: '/notfound', page: () => UnknownRoutePage()),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MyHomePage()),
        GetPage(name: '/second', page: () => Second()),
      ],
    )
  );
}
```

### 发送数据到别名路由

只要发送你想要的参数即可。Get在这里接受任何东西，无论是一个字符串，一个Map，一个List，甚至一个类的实例。

```dart
Get.toNamed("/NextScreen", arguments: 'Get is the best');
```

在你的类或控制器上：

```dart
print(Get.arguments);
//print out: Get is the best
```

### 动态网页链接

Get提供高级动态URL，就像在Web上一样。Web开发者可能已经在Flutter上想要这个功能了，Get也解决了这个问题。

```dart
Get.offAllNamed("/NextScreen?device=phone&id=354&name=Enzo");
```

在你的controller/bloc/stateful/stateless类上：

```dart
print(Get.parameters['id']);
// out: 354
print(Get.parameters['name']);
// out: Enzo
```

你也可以用Get轻松接收NamedParameters。

```dart
void main() {
  runApp(
    GetMaterialApp(
      initialRoute: '/',
      getPages: [
      GetPage(
        name: '/',
        page: () => MyHomePage(),
      ),
      GetPage(
        name: '/profile/',
        page: () => MyProfile(),
      ),
       //你可以为有参数的路由定义一个不同的页面，也可以为没有参数的路由定义一个不同的页面，但是你必须在不接收参数的路由上使用斜杠"/"，就像上面说的那样。
       GetPage(
        name: '/profile/:user',
        page: () => UserProfile(),
      ),
      GetPage(
        name: '/third',
        page: () => Third(),
        transition: Transition.cupertino  
      ),
     ],
    )
  );
}
```

发送别名路由数据

```dart
Get.toNamed("/second/34954");
```

在第二个页面上，通过参数获取数据

```dart
print(Get.parameters['user']);
// out: 34954
```

或像这样发送多个参数

```dart
Get.toNamed("/profile/34954?flag=true");
```

在第二个屏幕上，通常按参数获取数据

```dart
print(Get.parameters['user']);
print(Get.parameters['flag']);
// out: 34954 true
```


现在，你需要做的就是使用Get.toNamed()来导航你的别名路由，不需要任何context(你可以直接从你的BLoC或Controller类中调用你的路由)，当你的应用程序被编译到web时，你的路由将出现在URL中。

### 中间件

如果你想通过监听Get事件来触发动作，你可以使用routingCallback来实现。

```dart
GetMaterialApp(
  routingCallback: (routing) {
    if(routing.current == '/second'){
      openAds();
    }
  }
)
```

如果你没有使用GetMaterialApp，你可以使用手动API来附加Middleware观察器。

```dart
void main() {
  runApp(
    MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: "/",
      navigatorKey: Get.key,
      navigatorObservers: [
        GetObserver(MiddleWare.observer), // HERE !!!
      ],
    ),
  );
}
```

创建一个MiddleWare类

```dart
class MiddleWare {
  static observer(Routing routing) {
    if (routing.current == '/second') {
      print('second route called');
    } else if (routing.current =='/third'){
      print('last route called');
    }
  }
}
```

现在，在你的代码上使用Get：

```dart
class First extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Route'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Open route'),
          onPressed: () {
            Get.toNamed("/second");
          },
        ),
      ),
    );
  }
}

class Second extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Open route'),
          onPressed: () {
            Get.toNamed("/third");
          },
        ),
      ),
    );
  }
}

class Third extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Third Route"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
```

## 免context导航

对于所有其他的Flutter弹层小部件，包括cupertinos，你可以使用Get.overlayContext来代替context，并在你的代码中任何地方打开它。
对于不使用Overlay的小组件，你可以使用Get.context。
这两个context在99%的情况下都可以代替你的UIcontext，除了在没有导航context的情况下使用 inheritedWidget的情况。

## 嵌套导航

Get 用声明式路由表表达嵌套：壳页通过 `children:` 挂子路由，壳的 `page` 里放一个 `GetRouterOutlet` 来承载子路由的 Navigator。

```dart
GetMaterialApp(
  initialRoute: '/',
  getPages: [
    GetPage(
      name: '/',
      participatesInRootNavigator: true, // 壳页必须为 true，见下方约定
      page: () => Scaffold(
        appBar: AppBar(title: const Text('Shell')),
        body: GetRouterOutlet(initialRoute: '/menu', anchorRoute: '/'),
      ),
      children: [
        GetPage(name: '/menu', page: () => const MenuPage()),
        GetPage(name: '/detail', page: () => const DetailPage()),
      ],
    ),
  ],
);
```

在壳里跳子路由直接 `Get.toNamed('/detail')`，不需要带 id。

### participatesInRootNavigator 约定

这条约定必须遵守。声明式路由下，每个 `GetPage` 要么由**根 Navigator** 渲染，要么由它上方某个 `GetRouterOutlet` 渲染，二选一。`participatesInRootNavigator` 就是这个开关：

- **壳页（带 `children` 的那一层）写 `participatesInRootNavigator: true`**。壳要留在根 Navigator，子路由才有地方挂。
- **叶子页不要写，或写 `false`**。叶子由 outlet 渲染。

这个字段没有可依赖的默认值：全表都不写时结果取决于当前分支，而 `Get.to` / `Get.off` / `Get.offAll` 合成的匿名页一律按 `true` 处理。建议把壳页的 `true` 显式写出来。

壳页写成 `false`（或写 `false` 又想要壳渲染 outlet）是自相矛盾的配置 —— 意思是「壳不进根 Navigator」，而根 Navigator 没有任何页可渲染。症状是从壳跳到叶子页后整页空白。这里不做兜底：把壳塞回根 Navigator 会和它自己渲染的 outlet 抢同一个 GlobalKey 直接崩溃，比留空更糟。

### outlet 里的页没有自动返回键

outlet 自己就是一个只持有一页的 Navigator，`Navigator.canPop` 恒为 false，所以 outlet 里的页用 `AppBar` 时**不会**出现自动返回键。要自己加：

```dart
AppBar(
  leading: Get.rootController.rootDelegate.canBack
      ? BackButton(onPressed: Get.back)
      : null,
  title: const Text('Detail'),
);
```

`Get.canBack()` 在 5.0 里不存在，请用 `Get.rootController.rootDelegate.canBack`。

### 从 outlet 页跳出去的顶层页不进 outlet

`Get.to` / `Get.off` / `Get.offAll` 合成的是匿名顶层页，一律待在根 Navigator —— 否则会落进 outlet 被当前页盖住，看起来像「跳了但没反应」。所以从壳里跳出去的页既能走正常的返回动画，也能被 `Get.back()` 正常弹回。

### 旧的 nestedKey 写法

`Get.nestedKey` 现在接收的是**路由路径字符串**（`Get.nestedKey('/home')`），不再是 4.x 的数字 id；配合 `Navigator(onGenerateRoute:)` 的并行导航栈写法也不再适用，改用上面的声明式 `children:` + `GetRouterOutlet`。
