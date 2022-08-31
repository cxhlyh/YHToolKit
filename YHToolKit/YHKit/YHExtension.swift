//
//  YHExtension.swift
//  YHToolKit
//
//  Created by 文亚恒 on 2022/8/30.
//

import UIKit
import Kingfisher

// MARK: - 拓展UIColor
public extension UIColor{
    
    ///用16进制颜色初始化UIColor
    convenience init(hexString:String?) {
        //颜色值字符串判断
        if hexString?.isEmpty ?? true || hexString?.count != 7 {
            //颜色字符串不满足转换条件
            self.init(red: 1, green: 1, blue: 1, alpha: 1);
        }else{
            //颜色字符串满足转换条件 开始处理
            //开始计算颜色字符串
            let hexString = hexString!.trimmingCharacters(in: .whitespacesAndNewlines)
            let scanner = Scanner(string: hexString)
            if hexString.hasPrefix("#") {
                scanner.scanLocation = 1
            }
            var color: UInt32 = 0
            scanner.scanHexInt32(&color)
            //计算Int类型的RGB
            let mask = 0x000000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask
            //计算RGB值
            let red   = CGFloat(r) / 255.0
            let green = CGFloat(g) / 255.0
            let blue  = CGFloat(b) / 255.0
            //初始化颜色
            self.init(red: red, green: green, blue: blue, alpha: 1)
        }
    }
    
    ///获取随机颜色
   class func yh_randomColor() ->UIColor{
        return UIColor.init(hexString: "#"+String(arc4random_uniform(9))+String(arc4random_uniform(9))+String(arc4random_uniform(9))+String(arc4random_uniform(9))+String(arc4random_uniform(9))+String(arc4random_uniform(9)));
    }
    
}


// MARK: - 拓展字体
public extension UIFont{

    ///字体类型 用于拓展创建字体使用
    enum yh_FontType {
        ///正常
        case normal;
        ///加粗
        case bold;
    }
    
    ///创建字体，字体大小自适配
    class func yh_init(size:CGFloat,type:yh_FontType = .normal) ->UIFont{
        //计算字体适配后的大小
        let fontSize = Bool(YHAPI_APPWidth <= 320) ? size-2 : Bool(YHAPI_APPWidth == 375.0) ? size : size+2;
        //创建字体
        switch type {
        case .normal:
            return UIFont.systemFont(ofSize: fontSize);
        case .bold:
            return UIFont.boldSystemFont(ofSize: fontSize);
        }
    }
    
}


// MARK: - 拓展富文本
public extension NSMutableAttributedString{
    
    ///获取第一个文字的颜色
    func yh_getFirstAttStringColor() ->UIColor?{
        var color:UIColor?;
        if self.length >= 1{
            self.enumerateAttribute(NSAttributedString.Key.foregroundColor, in: NSRange(location: 0, length: 1), options:NSAttributedString.EnumerationOptions(rawValue: 0)) { attValue, _, _ in
                color = attValue as? UIColor;
            }
        }
        return color;
    }
    
    ///计算富文本size
    func yh_getAttStringSize(maxSize:CGSize) ->CGSize{
        //遍历富文本属性
        self.enumerateAttribute(NSAttributedString.Key.font, in: NSRange(location: 0, length: self.length), options:NSAttributedString.EnumerationOptions(rawValue: 0)) {[weak self] attValue, _, _ in
            //如果没有字体，赋值默认字体
            if (attValue as? UIFont)?.pointSize ?? 0 <= 0 {
                self?.addAttribute(NSAttributedString.Key.font, value: UIFont.yh_init(size: 16), range: NSRange(location: 0, length: self?.length ?? 0));
            }
        }
        let size = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil).size
        return CGSize(width: ceil(size.width), height: ceil(size.height));
    }
}


// MARK: - 拓展String
public extension String{

    ///计算文本大小
    func yh_getStringSize(maxSize:CGSize,font:UIFont) ->CGSize{
        //文字
        let contentString:NSString = self as NSString;
        //计算出来的大小
        let stringSize = contentString.boundingRect(with: maxSize, options: [.usesFontLeading,.usesLineFragmentOrigin], attributes:  [NSAttributedString.Key.font : font], context: nil).size;
        return CGSize(width: ceil(stringSize.width), height: ceil(stringSize.height));
    }
    
    ///判断是否大于 用于版本号判断 要求格式一致 比如都是 1.1.1  对比  1.1.0
    func yh_isGreaterThan(content:String) ->Bool{
        //分割字符
        let leftArray = self.components(separatedBy: ".");
        let rightArray = content.components(separatedBy: ".");
        if rightArray.count >= 1 && leftArray.count >= 1 && leftArray.count == rightArray.count{
            for index in 0...rightArray.count-1 {
                let leftNumber = Int(leftArray[index]) ?? 0;
                let rightNumber = Int(rightArray[index]) ?? 0;
                if leftNumber > rightNumber{
                    return true;
                }else if rightNumber > leftNumber{
                    return false;
                }
            }
        }
        return false;
    }
    
    ///时间字符转换为date
    func yh_convertDate()->Date?{
        let dfmatter = DateFormatter()
        switch self.count {
        case 4:
            dfmatter.dateFormat="yyyy"
            return dfmatter.date(from: self);
        case 7:
            dfmatter.dateFormat="yyyy-MM"
            return dfmatter.date(from: self);
        case 10:
            dfmatter.dateFormat="yyyy-MM-dd"
            return dfmatter.date(from: self);
        case 13:
            dfmatter.dateFormat="yyyy-MM-dd HH"
            return dfmatter.date(from: self);
        case 16:
            dfmatter.dateFormat="yyyy-MM-dd HH:mm"
            return dfmatter.date(from: self);
        case 19:
            dfmatter.dateFormat="yyyy-MM-dd HH:mm:ss"
            return dfmatter.date(from: self);
        default:
            return nil;
        }
    }
    
    ///正则匹配
    func yh_isMatch(_ rules: String ) -> Bool {
        do {
            let regex = try NSRegularExpression.init(pattern: rules, options: NSRegularExpression.Options(rawValue: 0));
            let results = regex.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) as Array;
            return results.count > 0;
        }catch{
            return false;
        }
    }
    
    ///文本转富文本-赋值黑色样式 16号字体
    func yh_toAttText_Black() -> NSMutableAttributedString{
        return yh_toAttText_ColorAndFont(color: YHAPI_BlackTextColor, font: UIFont.yh_init(size: 16));
    }
    
    ///文本转富文本-指定颜色和字体
    func yh_toAttText_ColorAndFont(color:UIColor,font:UIFont) -> NSMutableAttributedString{
        return yh_toAttText(attrs: [NSAttributedString.Key.font : font,NSAttributedString.Key.foregroundColor:color]);
    }
    
    ///文本转富文本 attrs:文本样式
    func yh_toAttText(attrs:[NSAttributedString.Key : Any]) ->NSMutableAttributedString{
        let attString = NSMutableAttributedString.init(string: self);
        //需要转换的内容有值则赋值属性
        if self.count >= 1{
            attString.addAttributes(attrs, range: NSRange(location: 0, length: self.count));
        }
        return attString;
    }
    
    /// 字符串在该字符中的匹配范围
    func yh_exMatchStrNSRange(matchStr: String) -> [NSRange] {
        var selfStr = self as NSString;
        //辅助字符串
        var withStr = Array(repeating: "X", count: matchStr.count).joined(separator: "");
       
        if matchStr == withStr {
             //临时处理辅助字符串差错
            withStr = withStr.lowercased();
        }
        var allRange = [NSRange]();
        while selfStr.range(of: matchStr).location != NSNotFound {
            let range = selfStr.range(of: matchStr);
            allRange.append(range);
            selfStr = selfStr.replacingCharacters(in: range, with: withStr) as NSString;
        }
        return allRange
    }
    
    ///string转double 格式化最多保留两位
    func yh_formatToDouble()->Double{
        return Double(self)?.yh_format_KeepTwoDecimals() ?? 0;
    }
    
    ///字符转中文人民币
    func yh_formatToFormalRMM() -> String {
        guard let num = Double(self) else {
            return ""
        }
        let format = NumberFormatter()
        format.locale = Locale(identifier: "zh_CN")
        format.numberStyle = .spellOut
        format.minimumIntegerDigits = 1
        format.minimumFractionDigits = 0
        format.maximumFractionDigits = 2
        let text = format.string(from: NSNumber(value: num)) ?? ""
        let sept = self.components(separatedBy: ".")
        let decimals: Double? = sept.count == 2 ? Double("0." + sept.last!) : nil
        return self.yh_formatToRMM(text: text, isInt: decimals == nil || decimals! < 0.01);
    }
    
    ///字符串替换为大写人民币字符串
    func yh_formatToRMM(text: String, isInt: Bool) -> String {
        let formattedString = text.replacingOccurrences(of: "一", with: "壹").replacingOccurrences(of: "二", with: "贰").replacingOccurrences(of: "三", with: "叁").replacingOccurrences(of: "四", with: "肆").replacingOccurrences(of: "五", with: "伍").replacingOccurrences(of: "六", with: "陆").replacingOccurrences(of: "七", with: "柒").replacingOccurrences(of: "八", with: "捌").replacingOccurrences(of: "九", with: "玖").replacingOccurrences(of: "十", with: "拾").replacingOccurrences(of: "百", with: "佰").replacingOccurrences(of: "千", with: "仟").replacingOccurrences(of: "〇", with: "零");
        let sept = formattedString.components(separatedBy: "点")
        var intStr = sept[0]
        if sept.count > 0 && isInt {
            // 整数处理
            return intStr.appending("元")
        } else {
            // 小数处理
            let decStr = sept[1]
            intStr = intStr.appending("元").appending("\(decStr.first!)角")
            if decStr.count > 1 {
                intStr = intStr.appending("\(decStr[decStr.index(decStr.startIndex, offsetBy: 1)])分")
            } else {
                intStr = intStr.appending("零分")
            }
            return intStr
        }
    }
}


// MARK: - 拓展字典
public extension Dictionary {
    
    ///拼接字典
    mutating func yh_merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

// MARK: - 拓展UIView
public extension UIView{
    ///点击下标
    private static var yh_IndexKey = true;
    ///自己记录的组件下标 默认0
    var yh_Index: Int {
        get {
            (objc_getAssociatedObject(self, &Self.yh_IndexKey) as? Int) ?? 0;
        }
        set {
            objc_setAssociatedObject(self, &Self.yh_IndexKey, newValue, .OBJC_ASSOCIATION_ASSIGN);
        }
    }
    
    ///生成分割线
    static func yh_createLineViewWithFrameAndColor(frame:CGRect,color: UIColor)-> UIView{
        let view = UIView.init(frame: frame);
        view.backgroundColor = color;
        return view;
    }

}

// MARK: - 拓展UIImage
public extension UIImage{

    ///根据颜色生成图片
    static func yh_createImageWithColor(color: UIColor)-> UIImage{
        let rect = CGRect.init(x: 0.0, y: 0.0, width: YHAPI_MinLine_PX, height: YHAPI_MinLine_PX)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return (image ?? UIImage.init(named: "yh_Public_Clear"))!;
    }
    
    ///添加水印 named 图片  frame水印坐标
    func yh_addWatermarkWithImage(named:String,frame:CGRect)-> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1);
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height));
        let waterAImage = UIImage.init(named: named);
        waterAImage?.draw(in: frame);
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? self;
        UIGraphicsEndImageContext();
        return newImage;
    }
    
}



// MARK: - 拓展UIImageView
public extension UIImageView{
    
    ///绘制圆角
    func yh_setCornerImageView(cornerRadius:CGFloat){
        self.layer.masksToBounds = true;
        self.layer.cornerRadius = cornerRadius;
    }
    
    /// - Parameters:加载网络图片
    ///   - urlString: 图片路径
    ///   - placeholder: 占位图
    ///   - isThumbnail: 是否缩略 ，(把图片缩放到控件大小)
    ///   - cornerRadius: 圆角
    ///   - complete: 加载完成回调
    func yh_setImageWithUrl(urlString:String,placeholder:String? = nil,isThumbnail:Bool = false,cornerRadius:CGFloat = 0,indicatorType:IndicatorType = .none,complete:((Bool)->())? = nil){
        let url = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "");
        //判断路径是否有值
        if url?.absoluteString.count ?? 0 > 0{
            //网络过程中的加载动画
            self.kf.indicatorType = indicatorType;
            //配置选项
            var options:[KingfisherOptionsInfoItem]?;
            if isThumbnail{
                //缩略图
                options = [.processor(DownsamplingImageProcessor(size: self.bounds.size)),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage];
                
            }
            //占位图
            var placeholderImage:UIImage?;
            if placeholder?.count ?? 0 > 0{
                placeholderImage = UIImage.init(named: placeholder ?? "");
            }
            //请求图片
            self.kf.setImage(with: url, placeholder: placeholderImage, options: options, progressBlock: nil) {[weak self] result in
                switch result{
                case .success(_):
                    //圆角
                    if cornerRadius > 0{
                        self?.yh_setCornerImageView(cornerRadius: cornerRadius)
                    }
                    //成功
                    complete?(true);
                    break;
                default:
                    //失败
                    complete?(false);
                    break
                }
            }
        }else{
            //取值失败，直接打回
            complete?(false);
        }
    }
    
}

// MARK: - 拓展Double
public extension Double{
    
    ///格式化double 最多保留两位小数
    func yh_format_KeepTwoDecimals()->Double{
        let format = pow(10.0, Double(2));
        return (self*format).rounded()/format;
    }
    
    ///double转string 强制保留两位小数
    func yh_format_KeepTwoDecimalToString()->String{
        //判断自己是否为非数字
        if self.isNaN {
            return "0.00";
        }else{
            return String(format: "%.2f", self.yh_format_KeepTwoDecimals());
        }
    }
    
    ///double转string 删除末尾的空数字
    func yh_format_RemoveNullNumbersToString()->String{
        var format = self.yh_format_KeepTwoDecimalToString();
        for _ in 0...2 {
            if (format.last == "0" || format.last == ".") && format.contains("."){
                format.removeLast();
            }
        }
        return format;
    }
    
}


// MARK: - 拓展Date
public extension Date{
    
    ///比较时间-是否大于
    func yh_greaterThan(date:Date) -> Bool{
        return self.compare(date) == .orderedDescending;
    }
    
    ///转换为本地东八区时间
    func yh_convertToLocalDate() -> Date {
        let zone = NSTimeZone.system;
        let interval = zone.secondsFromGMT(for: self);
        let localDate = self.addingTimeInterval(TimeInterval(interval));
        return localDate;
    }

    ///当前时间增加 day天数
    func yh_nowDataIncrease(day:Int)-> Date{
        let nowDate:TimeInterval = self.timeIntervalSince1970;
        let nowDataInt =  Int(round(nowDate))*1000;
        let incDate = day*60*60*24*1000;
        return YHTool.shared.yh_getDateFromTimeStamp(time: String(nowDataInt+incDate));
    }
    
    ///当前时间减少 day天数
    func yh_nowDataReduce(day:Int)-> Date{
        let nowDate:TimeInterval = self.timeIntervalSince1970;
        let nowDataInt =  Int(round(nowDate))*1000;
        let reduceDate = day*60*60*24*1000;
        return YHTool.shared.yh_getDateFromTimeStamp(time: String(nowDataInt-reduceDate));
    }
    
    ///2015年01-01
    static func yh_2015()->Date{
        return Date.init(timeIntervalSince1970: 1420041600);
    }
    
    ///1920年01-01
    static func yh_1920()->Date{
        return Date.init(timeIntervalSince1970: -1577923200);
    }
    
}

// MARK: - 拓展data
public extension Data{
   
    ///计算大小
    func yh_calculateSize()->String{
        var fileSize = self.count/1000;
        var suffix = "KB";
        //判断是否超出了KB
        if fileSize > 1000 {
            fileSize = fileSize/1000;
            suffix = "MB";
            if fileSize > 1000{
                fileSize = fileSize/1000;
                suffix = "GB";
            }
        }
        return String(fileSize)+suffix;
    }
    
}

