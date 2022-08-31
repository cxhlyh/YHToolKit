//
//  YHTool.swift
//  YHToolKit
//
//  Created by 文亚恒 on 2022/8/30.
//

import UIKit

///工具类
public class YHTool: NSObject {
    ///单例
    static let shared = YHTool();
}

// MARK: - 拓展工具类
extension YHTool{
    
    ///时间戳转换Date格式
    func yh_getDateFromTimeStamp(time:String) ->Date {
        if time.isEmpty{
            return Date.init();
        }
        var timeString = time;
        //判断是否为毫秒
        if timeString.count == 13{
            timeString.removeLast(3);
        }
        let interval:TimeInterval = TimeInterval.init(String(timeString))!
        return Date(timeIntervalSince1970: interval)
    }
      
}
