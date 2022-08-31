//
//  YHAPI.swift
//  YHToolKit
//
//  Created by YH on 2022/8/30.
//

import Foundation

// MARK: - 组件大小

///APP宽度
public let YHAPI_APPWidth = UIScreen.main.bounds.size.width;
///APP高度
public let YHAPI_APPHeight = UIScreen.main.bounds.size.height;

///最小分割线像素  需计算偏移量
public let YHAPI_MinLine_PX = 1/UIScreen.main.scale;

///导航栏高度
public let YHAPI_NavgationBarHeight:CGFloat = 44;
///状态栏高度
public let YHAPI_StatusBarHeight:CGFloat = 20;
///tabbar高度
public let YHAPI_TabBarHeight:CGFloat = 49;

///临时window 用于取出底部和顶部安全区域高度
let YHAPI_TemporaryWindow = UIWindow();
///头部安全区域高度
public let YHAPI_SafaAreaTopHeight:CGFloat = YHAPI_TemporaryWindow.safeAreaInsets.top-YHAPI_StatusBarHeight;
///底部安全区域高度
public let YHAPI_SafaAreaBottomHeight:CGFloat = YHAPI_TemporaryWindow.safeAreaInsets.bottom;


///导航栏+状态栏高度+头部安全区域
public let YHAPI_HeadTotalHeight = CGFloat(YHAPI_NavgationBarHeight+YHAPI_StatusBarHeight+YHAPI_SafaAreaTopHeight);
///tabBar+底部安全区域高度
public let YHAPI_FootTotalHeight = CGFloat(YHAPI_TabBarHeight+YHAPI_SafaAreaBottomHeight);

///常用间距
public let YHAPI_CommonlyGap:CGFloat = ceil((Bool(YHAPI_APPWidth <= 375.0) ? 16 : 20)*0.75);



// MARK: - 颜色

///黑色文字颜色
public let YHAPI_BlackTextColor = UIColor.init(hexString: "#333333");
