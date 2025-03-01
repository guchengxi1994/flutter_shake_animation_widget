import 'package:flutter/material.dart';

/// 创建人： Created by zhaolong
/// 创建时间：Created by  on 2020/11/10.
///
/// 可关注公众号：我的大前端生涯   获取最新技术分享
/// 可关注网易云课堂：https://study.163.com/instructor/1021406098.htm
/// 可关注博客：https://blog.csdn.net/zl18603543572
/// 头条|西瓜视频： https://www.toutiao.com/c/user/token/MS4wLjABAAAAYMrKikomuQJ4d-cPaeBqtAK2cQY697Pv9xIyyDhtwIM/
///
///防开源中国自定义底部菜单
///   流式布局 Flow 圆形菜单
class BottomRoundFlowMenu extends StatefulWidget {
  ///菜单图标
  final List<Icon> iconList;

  ///菜单图标背景
  final List<Color>? iconBackgroundColorList;

  ///所有菜单项默认使用的底色
  final Color defaultBackgroundColor;

  ///点击事件回调
  final Function(int index)? clickCallBack;

  ///是否输出Log
  final bool isLog;

  const BottomRoundFlowMenu(
      {Key? key,
      required this.iconList,
      this.clickCallBack,
      this.isLog = false,
      this.defaultBackgroundColor = Colors.grey,
      this.iconBackgroundColorList})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MenuState createState() => _MenuState();
}

///   流式布局 Flow 圆形菜单 类似开源中国底部圆形菜单效果
class _MenuState extends State<BottomRoundFlowMenu>
    with SingleTickerProviderStateMixin {
  ///变化比率
  double _rad = 0.0;

  ///是否执行完动画，或者说是动画停止
  bool _closed = true;

  ///动画控制器
  late AnimationController _controller;

  ///用于控制变化速率
  late Animation<double> animation;

  ///用于保存显示出来的菜单效果Widget
  List<Widget> menuItemList = [];

  @override
  void initState() {
    super.initState();

    ///创建动画控制器
    ///执行时间为200毫秒
    _controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this)

      ///设置监听，每当动画执行时就会实时回调此方法
      ..addListener(() {
        setState(() {
          ///从0到1
          _rad = animation.value;
          if (widget.isLog) {
            debugPrint("$_rad ");
          }
        });
      })

      ///设置状态监听
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (widget.isLog) {
            debugPrint("正向执行完毕 ");
          }
          _closed = !_closed;
        } else if (status == AnimationStatus.dismissed) {
          if (widget.isLog) {
            debugPrint("反向执行完毕 ");
          }
          _closed = !_closed;
        }
      });

    ///变化值从 0.0-1.0
    ///Curves.easeInOutExpo 中间快两头慢
    animation = Tween(begin: 0.0, end: 1.0).animate(

        ///先快后慢
        CurveTween(curve: Curves.easeOutQuint).animate(_controller));

    ///构建菜单具体显示的Widget
    menuItemList = buildMenuData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody2();
  }

  //lib/code10/main_data1018.dart
  /// Flow 流式布局 构建菜单数据Widget
  List<Widget> buildMenuData() {
    List<Widget> childWidthList = [];

    ///为每个Icon添加一个点击事件与圆形背景
    for (int i = 0; i < widget.iconList.length; i++) {
      Color itemColor = widget.defaultBackgroundColor;
      //图标背景
      if (widget.iconBackgroundColorList != null &&
          i < widget.iconBackgroundColorList!.length) {
        itemColor = widget.iconBackgroundColorList![i];
      }

      ///每个菜单添加InkWell点击事件
      Widget itemContainer = InkWell(
        onTap: () {
          if (widget.clickCallBack != null) {
            widget.clickCallBack!(i);
          }

          ///打开或者关闭菜单
          colseOrOpen();

          ///点击菜单其他的操作
        },
        child: Container(
          ///圆形背景
          decoration: BoxDecoration(
              color: itemColor,
              borderRadius: const BorderRadius.all(Radius.circular(23))),
          alignment: Alignment.center,
          height: 44,
          width: 44,
          child: widget.iconList[i],
        ),
      );
      childWidthList.add(
        itemContainer,
      );
    }
    return childWidthList;
  }

  //lib/code10/main_data1018.dart
  ///页面的主体
  buildBody2() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: 0,
          child: Container(
            color: Color.fromARGB((_rad * 150).toInt(), 0, 0, 0),
          ),
        ),
        Flow(
          ///代理
          delegate: TestFlowDelegate(radiusRate: _rad),

          ///使用到的子Widget
          children: menuItemList,
        )
      ],
    );
  }

  ///控制菜单的打开或者关闭
  void colseOrOpen() {
    if (_closed) {
      _controller.reset();
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
}

//lib/code10/main_data1018.dart
///  流式布局 Flow 计算
class TestFlowDelegate extends FlowDelegate {
  ///半径变化的比率
  ///一般从0到1 菜单展开
  ///从1-0菜单关闭
  double radiusRate;

  TestFlowDelegate({this.radiusRate = 0});

  @override
  void paintChildren(FlowPaintingContext context) {
    calculWrapSpacingChild2(context);
  }

  //lib/code10/main_data1018.dart
  ///  流式布局 Flow 计算
  void calculWrapSpacingChild2(FlowPaintingContext context) {
    ///初始绘制位置为Flow布局的左上角
    double x = 0.0;
    double y = 0.0;

    //获取当前画布的最小边长，width与height谁小取谁
    double radius = context.size.shortestSide / 3 * 2;

    ///获取当前Flow的大小
    double flowWidth = context.size.width;
    double flowHeight = context.size.height;

    ///左右两个菜单的偏移量
    double dxflag = radius / 3 * radiusRate;

    ///默认将所有的子Widget绘制到左下角
    x = radius;
    y = radius;

    //计算每一个子widget的位置
    for (var i = 0; i < context.childCount - 1; i++) {
      ///获取第i个子Widget的大小
      Size? itemChildSize = context.getChildSize(i);
      if (itemChildSize == null) {
        return;
      }

      ///子child开始绘制的y中心点
      double normalHeight = flowHeight - itemChildSize.height * 2;

      ///子child开始绘制的x中心点
      double normalWidth = flowWidth - itemChildSize.width / 2;

      ///计算每个子Widget 的坐标
      if (i == 0) {
        x = normalWidth / 2 - dxflag;
        y = normalHeight - radius / 4.3 * radiusRate;
      } else if (i == 1) {
        x = normalWidth / 2;
        y = normalHeight - radius / 3 * radiusRate;
      } else {
        x = normalWidth / 2 + dxflag;
        y = normalHeight - radius / 4.3 * radiusRate;
      }

      ///在Flow中进行绘制
      context.paintChild(i, transform: Matrix4.translationValues(x, y, 0.0));
    }

    ///最后一个做为菜单选项
    int lastIndex = context.childCount - 1;
    Size? lastChildSize = context.getChildSize(lastIndex);
    if (lastChildSize == null) {
      return;
    }
    double lastx = (flowWidth - lastChildSize.width / 2) / 2;
    double lasty = flowHeight - lastChildSize.height * 2;

    ///绘制这个菜单在底部中心并旋转
    context.paintChild(lastIndex,

        ///先平移到底部
        transform: Matrix4.translationValues(lastx, lasty, 0.0)

          ///然后将旋转中心平移到子Widget的中心
          ..translate(lastChildSize.width / 2, lastChildSize.height / 2)

          ///合并旋转操作
          ..multiply(Matrix4.rotationZ(radiusRate * 0.8)

            ///再将旋转中心平移回去
            ..translate(-lastChildSize.width / 2, -lastChildSize.height / 2)));
//    context.paintChild(lastIndex,
//        transform: Matrix4Transform()
//            ///绕自身中心旋转
//            .rotateByCenterDegrees(radiusRate*45, lastChildSize)
//            ///平移到底部中心
//            .translate(x: lastx,y: lasty).matrix4);
  }

  @override
  bool shouldRepaint(FlowDelegate oldDelegate) {
    return oldDelegate != this;
  }

  //  是否需要重新布局。
  @override
  bool shouldRelayout(FlowDelegate oldDelegate) {
    return true;
  }
}
