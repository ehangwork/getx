- [Route Management](#route-management)
  - [How to use](#how-to-use)
  - [Navigation without named routes](#navigation-without-named-routes)
    - [The trigger area of the iOS swipe-back gesture](#the-trigger-area-of-the-ios-swipe-back-gesture)
  - [Navigation with named routes](#navigation-with-named-routes)
    - [Send data to named Routes](#send-data-to-named-routes)
    - [Dynamic urls links](#dynamic-urls-links)
    - [Middleware](#middleware)
  - [Navigation without context](#navigation-without-context)
  - [Nested Navigation](#nested-navigation)
    - [The participatesInRootNavigator contract](#the-participatesinrootnavigator-contract)
    - [Pages inside an outlet get no automatic back button](#pages-inside-an-outlet-get-no-automatic-back-button)
    - [Top-level pages pushed from an outlet stay out of it](#top-level-pages-pushed-from-an-outlet-stay-out-of-it)
    - [The old nestedKey style no longer applies](#the-old-nestedkey-style-no-longer-applies)

# Route Management

This is the complete explanation of all there is to Getx when the matter is route management.

## How to use

Add this to your pubspec.yaml file:

```yaml
dependencies:
  get:
```

If you are going to use routes without context, or use the high-level Get APIs, you need to simply add "Get" before your MaterialApp, turning it into GetMaterialApp and enjoy!

```dart
GetMaterialApp( // Before: MaterialApp(
  home: MyHome(),
)
```

## Navigation without named routes

To navigate to a new screen:

```dart
Get.to(NextScreen());
```

To close routes, or anything you would normally close with Navigator.pop(context);

```dart
Get.back();
```

To go to the next screen and no option to go back to the previous screen (for use in SplashScreens, login screens and etc.)

```dart
Get.off(NextScreen());
```

To go to the next screen and cancel all previous routes (useful in shopping carts, polls, and tests)

```dart
Get.offAll(NextScreen());
```

To navigate to the next route, and receive or update data as soon as you return from it:

```dart
var data = await Get.to(Payment());
```

on other screen, send a data for previous route:

```dart
Get.back(result: 'success');
```

And use it:

ex:

```dart
if(data == 'success') madeAnything();
```

Don't you want to learn our syntax?
Just change the Navigator (uppercase) to navigator (lowercase), and you will have all the functions of the standard navigation, without having to use context
Example:

```dart

// Default Flutter navigator
Navigator.of(context).push(
  context,
  MaterialPageRoute(
    builder: (BuildContext context) {
      return HomePage();
    },
  ),
);

// Get using Flutter syntax without needing context
navigator.push(
  MaterialPageRoute(
    builder: (_) {
      return HomePage();
    },
  ),
);

// Get syntax (It is much better, but you have the right to disagree)
Get.to(HomePage());


```

### The trigger area of the iOS swipe-back gesture

On iOS the swipe-back gesture is on by default and its trigger area is **only a
strip along the leading edge** of the screen (24pt by default, widened by the
safe area on notched devices). Dragging anywhere else on the page does nothing.

Keep the strip narrow. The gesture layer is a **front sibling** of the page, so it
enters the gesture arena first on hit test, and ties go to whoever resolves first
— a touch inside the strip always beats a horizontal ListView, scrollable TabBar
or PageView underneath, leaving that component a dead zone. To widen the strip,
adjust it per page:

```dart
GetPage(
  name: '/detail',
  page: () => const DetailPage(),
  gestureWidth: (context) => 60, // strip width, defaults to 24
);
```

If the page already has a horizontal scroller and you still want swipe-back,
shrink the strip so it stays clear of it, or turn the gesture off for that page
with `popGesture: false`.

Sensitivity lives in the **release**, not in the strip, so it never fights those
scrollers:

- A flick of **0.5 screen widths per second** (roughly a fifth of the screen in
  half a second) commits the pop.
- Dragging **40%** of the screen and letting go commits it too — no need to go
  past the halfway mark.
- If neither is met, the page springs back.

## Navigation with named routes

- If you prefer to navigate by namedRoutes, Get also supports this.

To navigate to nextScreen

```dart
Get.toNamed("/NextScreen");
```

To navigate and remove the previous screen from the tree.

```dart
Get.offNamed("/NextScreen");
```

To navigate and remove all previous screens from the tree.

```dart
Get.offAllNamed("/NextScreen");
```

To define routes, use GetMaterialApp:

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

To handle navigation to non-defined routes (404 error), you can define an unknownRoute page in GetMaterialApp.

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

### Send data to named Routes

Just send what you want for arguments. Get accepts anything here, whether it is a String, a Map, a List, or even a class instance.

```dart
Get.toNamed("/NextScreen", arguments: 'Get is the best');
```

on your class or controller:

```dart
print(Get.arguments);
//print out: Get is the best
```

### Dynamic urls links

Get offer advanced dynamic urls just like on the Web. Web developers have probably already wanted this feature on Flutter, and most likely have seen a package promise this feature and deliver a totally different syntax than a URL would have on web, but Get also solves that.

```dart
Get.offAllNamed("/NextScreen?device=phone&id=354&name=Enzo");
```

on your controller/bloc/stateful/stateless class:

```dart
print(Get.parameters['id']);
// out: 354
print(Get.parameters['name']);
// out: Enzo
```

You can also receive NamedParameters with Get easily:

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
       //You can define a different page for routes with arguments, and another without arguments, but for that you must use the slash '/' on the route that will not receive arguments as above.
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

Send data on route name

```dart
Get.toNamed("/profile/34954");
```

On second screen take the data by parameter

```dart
print(Get.parameters['user']);
// out: 34954
```

or send multiple parameters like this

```dart
Get.toNamed("/profile/34954?flag=true&country=italy");
```
or
```dart
var parameters = <String, String>{"flag": "true","country": "italy",};
Get.toNamed("/profile/34954", parameters: parameters);
```

On second screen take the data by parameters as usually

```dart
print(Get.parameters['user']);
print(Get.parameters['flag']);
print(Get.parameters['country']);
// out: 34954 true italy
```



And now, all you need to do is use Get.toNamed() to navigate your named routes, without any context (you can call your routes directly from your BLoC or Controller class), and when your app is compiled to the web, your routes will appear in the url <3

### Middleware

If you want to listen Get events to trigger actions, you can to use routingCallback to it

```dart
GetMaterialApp(
  routingCallback: (routing) {
    if(routing.current == '/second'){
      openAds();
    }
  }
)
```

If you are not using GetMaterialApp, you can use the manual API to attach Middleware observer.

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

Create a MiddleWare class

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

Now, use Get on your code:

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

## Navigation without context

For all other Flutter overlay widgets, including cupertinos, you can use Get.overlayContext instead of context, and open it anywhere in your code.
For widgets that don't use Overlay, you can use Get.context.
These two contexts will work in 99% of cases to replace the context of your UI, except for cases where inheritedWidget is used without a navigation context.

## Nested Navigation

Get expresses nesting through the declarative route table: a shell page hangs its children off `children:`, and the shell's `page` holds a `GetRouterOutlet` that carries the nested Navigator.

```dart
GetMaterialApp(
  initialRoute: '/',
  getPages: [
    GetPage(
      name: '/',
      participatesInRootNavigator: true, // shells must be true, see below
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

To reach a child route from the shell, just use `Get.toNamed('/detail')` — no id needed.

### The participatesInRootNavigator contract

This contract must be followed. Under declarative routing every `GetPage` is rendered by **either** the root Navigator **or** a `GetRouterOutlet` above it, never both. `participatesInRootNavigator` is that switch:

- **Shell pages (the ones carrying `children`) set `participatesInRootNavigator: true`.** The shell has to stay in the root Navigator so nested routes have somewhere to attach.
- **Leaf pages omit it, or set `false`.** Leaves are rendered by the outlet.

The field has no dependable default: when nothing in the table declares it, the result depends on the current branch, and the anonymous pages synthesized by `Get.to` / `Get.off` / `Get.offAll` are always treated as `true`. Write the shell's `true` explicitly.

Setting `false` on a shell (or asking a shell to stay out of the root Navigator while still rendering an outlet) is self-contradictory — it means "the shell is not in the root Navigator" while the root Navigator has no page at all to render. The symptom is a blank screen after navigating from the shell to a leaf. There is deliberately no fallback here: putting the shell back in the root Navigator makes it fight the outlet it renders for the same GlobalKey and crash, which is worse than an empty screen.

### Pages inside an outlet get no automatic back button

An outlet is itself a single-page Navigator, so `Navigator.canPop` is always false there and an `AppBar` inside it **never** shows an automatic back button. Add your own:

```dart
AppBar(
  leading: Get.rootController.rootDelegate.canBack
      ? BackButton(onPressed: Get.back)
      : null,
  title: const Text('Detail'),
);
```

`Get.canBack()` does not exist in 5.0; use `Get.rootController.rootDelegate.canBack`.

### Top-level pages pushed from an outlet stay out of it

`Get.to` / `Get.off` / `Get.offAll` synthesize an anonymous top-level page, and those always stay in the root Navigator — otherwise they would land inside the outlet, be covered by the current page, and look like "it navigated but nothing happened". A page pushed out of the shell this way therefore gets the normal back transition and is popped by `Get.back()` as expected.

### The old nestedKey style no longer applies

`Get.nestedKey` now takes a **route path string** (`Get.nestedKey('/home')`), not a 4.x numeric id, and the parallel-stack style built on `Navigator(onGenerateRoute:)` is no longer the supported approach. Use the declarative `children:` + `GetRouterOutlet` shown above.
