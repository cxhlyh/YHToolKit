//
//  YHForm_Select_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/15.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//

import UIKit
import BRPickerView

// MARK: - 代理
@objc protocol YHForm_Select_Cell_Delegate:NSObjectProtocol{
    ///选择框点击了确定
    @objc optional func YHForm_Select_Cell_Delegate_Select(title:String);
    ///选择框不可选择的点击事件
    @objc optional func YHForm_Select_Cell_Delegate_Touch(title:String);
    ///选择框将没有数据
    @objc optional func YHForm_Select_Cell_Delegate_WillShow_NoData(title:String,complete:((Bool)->())?);
    ///选择框获取时间关联限制
    @objc optional func YHForm_Select_Cell_Delegate_GetRelationTime(idKey:String) ->Date?;
}

class YHForm_Select_Cell: UITableViewCell, YHBottomSelect_View_Delegate,Public_FWPopupView_Manager_Delegate {

    ///代理
    weak var delegate:YHForm_Select_Cell_Delegate?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        //取消点击变色
        self.selectionStyle = .none;
        //加载背景视图点击事件
        self.contentView.isUserInteractionEnabled = true;
        self.contentView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(contentView_Touch)));
        //加载编辑类型提示控件
        self.contentView.addSubview(editType_TipsImageView);
        //加载标题控件
        self.contentView.addSubview(title_Label);
        //加载选择按钮
        self.contentView.addSubview(select_Button);
        //加载选择提示控件
        self.contentView.addSubview(selectTips_ImageView);
        //加载底部提示控件
        self.contentView.addSubview(tips_ContentView);
    }
    
    // MARK: - 编辑类型-提示控件
    lazy var editType_TipsImageView:UIImageView = {
        let imageView = UIImageView.init(frame: CGRect(x: Form_CommonlyGap/2, y: Form_DefaultCellHeight/2-Form_CommonlyGap/4, width: Form_CommonlyGap/2, height: Form_CommonlyGap/2));
        return imageView;
    }();
    
    // MARK: - 标题
    lazy var title_Label:UILabel = {
        let label = UILabel.init(frame: CGRect(x: Form_CommonlyGap, y: 0, width: 0, height: Form_DefaultCellHeight));
        label.numberOfLines = 0;
        return label;
    }();
    
    // MARK: - 选择按钮
    lazy var select_Button:UIButton = {
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: 0, height:Form_DefaultCellHeight));
        button.contentHorizontalAlignment = .right;
        button.setTitleColor(Black_Text_Color, for: .normal);
        button.titleLabel?.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 16));
        button.titleLabel?.numberOfLines = 0;
        button.addTarget(self, action: #selector(select_Button_Touch), for: .touchUpInside);
        return button;
    }();
    
    // MARK: - 选择提示
    lazy var selectTips_ImageView:UIImageView = {
        let imageView = UIImageView.init(frame: CGRect(x: APP_WIDTH-Form_CommonlyGap, y: Form_DefaultCellHeight/2-Form_CommonlyGap/2, width: Form_CommonlyGap, height: Form_CommonlyGap));
        return imageView;
    }();
    

    // MARK: - 底部提示控件容器视图
    lazy var tips_ContentView:UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: APP_WIDTH, height: 0));
        //加载底部提示控件
        view.addSubview(tips_Label);
        //默认隐藏
        view.isHidden = true;
        return view;
    }();
    
    // MARK: - 底部提示控件
    lazy var tips_Label:UILabel = {
        let label = UILabel.init(frame: CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: 0));
        label.numberOfLines = 0;
        return label;
    }();
    
    // MARK: - 数据模型
    lazy var model:YHForm_Select_Model = {
        return YHForm_Select_Model();
    }();
    
    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_Select_Model){
        //赋值模型
        self.model = dataModel;
        //判断编辑类型
        YHForm.calculation_Cell_EditTypeTipsImageView_Style(showType: model.showType, editType: model.editType, imageView: self.editType_TipsImageView);
        //判断是否展示选择按钮提示文本
        if self.model.showType == .none && (self.model.editType == .mustComplete || self.model.editType == .optionalComplete){
            //编辑
            if self.model.content?.count ?? 0 <= 0 && self.model.contentID?.count ?? 0 <= 0{
                //选择内容和选择id都为空-状态下展示
                //赋值选择按钮提示文本
                self.select_Button.setTitle(model.contentTips, for: .normal);
                //设置选择按钮字体颜色
                self.select_Button.setTitleColor(Grey_Text_Color, for: .normal);
                //赋值选择提示控件样式图片
                self.selectTips_ImageView.image = UIImage.init(named: "YHForm_SelectTips_Grey");
            }else{
                //赋值选择按钮提示文本
                self.select_Button.setTitle(model.content ?? "", for: .normal);
                //设置选择按钮字体颜色
                self.handleContentColor();
//                self.select_Button.setTitleColor(Black_Text_Color, for: .normal);
                //赋值选择提示控件样式图片
                self.selectTips_ImageView.image = UIImage.init(named: "YHForm_SelectTips_Black");
            }
        }else{
            //查看
            //赋值选择按钮提示文本
            self.select_Button.setTitle(model.content ?? "", for: .normal);
            //设置选择按钮字体颜色
            self.handleContentColor();
//            self.select_Button.setTitleColor(Black_Text_Color, for: .normal);
            //判断是否强制展示右侧提示箭头
            if model.mandatoryDisplayTipsImage{
                //赋值选择提示控件样式图片
                self.selectTips_ImageView.image = UIImage.init(named: "YHForm_SelectTips_Black");
            }else{
                //赋值选择提示控件样式图片
                self.selectTips_ImageView.image = UIImage.init(named: "yh_Public_Clear");
            }
        }
        
        //赋值富文本标题
        self.title_Label.attributedText = model.attTitle;
        //赋值控件坐标
        self.title_Label.frame = model.titleFrame;
        self.select_Button.frame = model.contentFrame;
        //处理提示视图
        self.handleTipsView();
        self.selectTips_ImageView.frame.origin.y = self.select_Button.frame.origin.y+self.select_Button.frame.size.height/2-Form_CommonlyGap/2;
    }
    
    // MARK: - 处理内容文本颜色
    func handleContentColor(){
        switch model.data.selectType {
        case .none://选项选择
            //寻找颜色 判断选择元素中是否包含此元素ID
            if self.model.data.appoint_None_Model().config.elements.contains(where: { selectSectionModel in
                //先判断组一级是否有此元素
                if selectSectionModel.elementID == self.model.contentID && selectSectionModel.elementName == self.model.content{
                    //设置字体颜色
                    self.select_Button.setTitleColor(selectSectionModel.elementColor, for: .normal);
                    return true;
                }else{
                    //判断组内是否有此元素
                    return selectSectionModel.subElements.contains { selectElementModel in
                        if selectElementModel.elementID == self.model.contentID && selectElementModel.elementName == self.model.content{
                            //设置字体颜色
                            self.select_Button.setTitleColor(selectElementModel.elementColor, for: .normal);
                            return true;
                        }
                        return false;
                    }
                }
            }) == false{
                //没有找到项目 设置为默认黑色
                self.select_Button.setTitleColor(Black_Text_Color, for: .normal);
            }
            break;
        default://时间选择 地址选择 银行选择
            //设置选择按钮字体颜色
            self.select_Button.setTitleColor(Black_Text_Color, for: .normal);
            break;
        }
    }
    
    // MARK: - 处理提示视图
    func handleTipsView(){
        //赋值提示文本内容
        self.tips_Label.attributedText = model.bottom_TipsAttContent;
        //赋值坐标
        self.tips_ContentView.frame.origin.y = self.model.tipsFrame.origin.y;
        self.tips_ContentView.frame.size.height = self.model.tipsFrame.size.height;
        self.tips_Label.frame.size.height = self.model.tipsFrame.size.height;
        //赋值背景颜色
        self.tips_ContentView.backgroundColor = self.model.bottom_TipsAttBackGroundColor;
        //处理是否展示
        if model.tipsFrame.size.height > 0 {
            //展示
            self.tips_ContentView.isHidden = false;
        }else{
            //隐藏
            self.tips_ContentView.isHidden = true;
        }
    }
    
    // MARK: - 选择按钮点击事件
    @objc func select_Button_Touch(){
        //关闭页面键盘
        UIFactory.shared.CurrentController().view.endEditing(true);
        //判断是否可以编辑
        if (self.model.editType == .optionalComplete || self.model.editType == .mustComplete) && self.model.showType == .none{
            //判断类型
            switch model.data.selectType {
            case .none://正常类型
                select_None();
                break;
            case .time://时间选择类型
                select_Time()
                break;
            case .address://地址选择类型
                select_Address();
                break;
            case .bank://银行选择
                select_Bank();
                break;
            }
        }else{
            delegate?.YHForm_Select_Cell_Delegate_Touch?(title: self.model.attTitle.string);
        }
    }
    
    // MARK: - 背景视图点击事件
    @objc func contentView_Touch(){
        //关闭页面键盘
        UIFactory.shared.CurrentController().view.endEditing(true);
        //判断是否可以编辑
        if (self.model.editType == .optionalComplete || self.model.editType == .mustComplete) && self.model.showType == .none{
            
        }else{
            delegate?.YHForm_Select_Cell_Delegate_Touch?(title: self.model.attTitle.string);
        }
    }
    
    // MARK: - 银行选择类型
    func select_Bank(){
        //创建银行选择器配置模型
        let fwConfigModel = FW_BottomSelect_Config_Model();
        fwConfigModel.tool_title = "选择银行";
        fwConfigModel.tableView_title = "银行列表";
        fwConfigModel.isShowSelectView = true;
        fwConfigModel.select_Title = "选择银行";
        fwConfigModel.Select_UrlApi = .public_bankList_url;
        fwConfigModel.search_UrlApi = .public_bankList_subBranch_url(["":""]);
        Public_FWPopupView_Manager.shared.delegate = self;
        Public_FWPopupView_Manager.shared.Public_FWPopupView_Manager_Load_BottomSelectView(config: fwConfigModel);
    }
    
    // MARK: - 底部选择器代理---选择了元素
    func Public_FWPopupView_Manager_Delegate_Select_Element(element: public_BottomSelect_Model, index: Int) {
        if index == -999 {
            //选择项不可用 需要根据数据查询
        }else{
            //赋值模型
            self.model.content = element.element_ID;
            self.model.contentID = element.element_ID;
            //代理事件
            self.delegate?.YHForm_Select_Cell_Delegate_Select?(title: self.model.attTitle.string);
        }
    }
    
    
    // MARK: - 地址选择类型
    func select_Address(){
        BRAddressPickerView.showAddressPicker(withSelectIndexs: nil) {[weak self] (province, city, area) in
            let provinceString = (province?.name ?? "未知省")+"-";
            let cityString = (city?.name ?? "未知市")+"-";
            let areaString = (area?.name ?? "未知区县");
            //赋值模型
            self?.model.content = provinceString+cityString+areaString;
            self?.model.contentID = provinceString+cityString+areaString;
            //代理事件
            self?.delegate?.YHForm_Select_Cell_Delegate_Select?(title: self?.model.attTitle.string ?? "");
        }
    }
    
    // MARK: - 时间选择类型
    func select_Time(){
        var maxTime = self.model.data.appoint_Time_Model().maxTime ?? Date.init();
        var minTime = self.model.data.appoint_Time_Model().minTime ?? Date.init();
        //判断时间限制是否合规
        if minTime > maxTime{
            hud_only.show_Text_AutoDisappear(text: "当前可选择的最大时间小于最小时间,请联系技术部", view: UIFactory.shared.CurrentController().view);
            return;
        }
        //获取最大关联时间限制
        if self.model.data.appoint_Time_Model().relationMaxTimeIDKey.count >= 1{
            //需要获取关联时间限制
            let relationMaxTime = self.delegate?.YHForm_Select_Cell_Delegate_GetRelationTime?(idKey: self.model.data.appoint_Time_Model().relationMaxTimeIDKey) ?? maxTime;
            //获取到的关联时间限制不可大于本身的最大时间限制
            if relationMaxTime <= maxTime{
                maxTime = relationMaxTime;
            }
        }
        //获取最小关联时间限制
        if self.model.data.appoint_Time_Model().relationMinTimeIDKey.count >= 1{
            let relationMinTime = self.delegate?.YHForm_Select_Cell_Delegate_GetRelationTime?(idKey: self.model.data.appoint_Time_Model().relationMinTimeIDKey) ?? minTime;
            if relationMinTime >= minTime{
                minTime = relationMinTime;
            }
        }
        //弹出选择时间
        BRDatePickerView.showDatePicker(with: self.model.data.appoint_Time_Model().timeFormat, title: "选择"+self.model.attTitle.string, selectValue: nil, minDate: minTime, maxDate: maxTime, isAutoSelect: false) {[weak self] _, dateString in
            self?.selectTime_Confirm(timeString: dateString ?? "");
        }
    }
    
    // MARK: - 时间选择完成
    func selectTime_Confirm(timeString:String){
        var newTime = timeString;
        //计算是否补全
        if self.model.data.appoint_Time_Model().isAddHMS && self.model.data.appoint_Time_Model().timeFormat != .YMDHMS{
            switch self.model.data.appoint_Time_Model().timeFormat {
            case .YMD:
                newTime = newTime+" 23:59:59";
                break;
            case .YMDH:
                newTime = newTime+":59:59";
                break;
            case .YMDHM:
                newTime = newTime+":59";
                break;
            default:
                break;
            }
        }
        //赋值
        self.model.content = newTime;
        self.model.contentID = newTime;
        //代理事件
        self.delegate?.YHForm_Select_Cell_Delegate_Select?(title: self.model.attTitle.string);
    }
    
    // MARK: - 正常选择事件
    func select_None(){
        //判断是否需要赋值默认标题
        if self.model.data.appoint_None_Model().config.attTitle.string.count <= 0{
            self.model.data.appoint_None_Model().config.attTitle = ("选择"+self.model.attTitle.string).toAttText(attrs: [NSAttributedString.Key.foregroundColor : Black_Text_Color,NSAttributedString.Key.font:UIFont.systemFont(ofSize: Calculation_FontNumber(font: 15))]);
        }
        //判断状态
        switch bottomSelectView.config.state {
        case .hide:
            //发送代理,选择框将要出现却没有数据
            if self.model.data.appoint_None_Model().config.elements.count <= 0{
                //没有数据
                delegate?.YHForm_Select_Cell_Delegate_WillShow_NoData?(title: self.model.attTitle.string, complete: {[weak self] isSuccess in
                    if isSuccess{
                        self?.bottomSelectView.config = self?.model.data.appoint_None_Model().config ?? YHBottomSelect_Config.init();
                        
                        self?.bottomSelectView.show(view: UIFactory.shared.CurrentController().view);
                    }
                })
            }else{
                bottomSelectView.config = model.data.appoint_None_Model().config;
                bottomSelectView.show(view: UIFactory.shared.CurrentController().view);
            }
            break;
        case .show:
            bottomSelectView.hide();
            break;
        default:
            break;
        }
    }
    
    // MARK: - 底部选择视图
    lazy var bottomSelectView:YHBottomSelect_View = {
        let view = YHBottomSelect_View.initWithConfig(config: self.model.data.appoint_None_Model().config);
        view.delegate = self;
        return view;
    }();
    
    // MARK: - 正常选择类型选择完成事件
    func YHBottomSelect_View_Delegate_Confirm() {
        //计算选中数据
        var nameArray = [String]();
        var idArray = [String]();
        var params = [Any]();
        for element in self.model.data.appoint_None_Model().config.selectedElements{
            nameArray.append(element.elementName);
            idArray.append(element.elementID);
            params.append(element.param as Any);
        }
        //赋值
        model.content = nameArray.joined(separator: ",");
        model.contentID = idArray.joined(separator: ",");
        model.param = params;
        //发送代理
        delegate?.YHForm_Select_Cell_Delegate_Select?(title: model.attTitle.string);
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// MARK: - 拓展
extension YHForm_Select_Cell{
    
    // MARK: -选择数据类型模型-正常
    class SelectData_None_Model: SelectData_Base_Model {
        ///选择视图配置信息
        var config =  YHBottomSelect_Config.init();
    }
    
    // MARK: -选择数据类型模型-时间
    class SelectData_Time_Model: SelectData_Base_Model {
        //初始化
        override init() {
            super.init();
            //赋值类型
            selectType = .time;
        }
        ///最大时间限制(秒) - 默认当前日期(赋值为空是为了每次弹出筛选视图获取到的都是当前最新的时间)
        var maxTime:Date?;
        ///最小时间限制(秒)
        var minTime:Date?;
        ///最大时间关联限制 关联IDKey
        var relationMaxTimeIDKey = "";
        ///最小时间关联限制 关联IDKey
        var relationMinTimeIDKey = "";
        ///时间格式-默认年月日
        var timeFormat = BRDatePickerMode.YMD;
        ///是否补全时分秒
        var isAddHMS = true;
    }
    
    // MARK: -选择数据类型模型-地址
    class SelectData_Address_Model: SelectData_Base_Model {
        //初始化
        override init() {
            super.init();
            //赋值类型
            selectType = .address;
        }
    }
    
    // MARK: - 选择数据类型模型-银行
    class SelectData_Bank_Model: SelectData_Base_Model {
        //初始化
        override init() {
            super.init();
            //赋值类型
            selectType = .bank;
        }
    }
    
    // MARK: - 选择数据类型-基类
    class SelectData_Base_Model:NSObject{
        ///选择类型 - 默认为正常类型
        var selectType = Select_Type.none;
    }
    
    // MARK: - 选择类型
    enum Select_Type {
        ///正常类型
        case none;
        ///时间类型
        case time;
        ///地址类型
        case address;
        ///银行选择
        case bank;
    }
    
}


// MARK: - 拓展选项数据基类
extension YHForm_Select_Cell.SelectData_Base_Model{
    // MARK: - 指定为正常选择类型
    ///指定为正常选择类型
    func appoint_None_Model() ->YHForm_Select_Cell.SelectData_None_Model{
        return (self as? YHForm_Select_Cell.SelectData_None_Model) ?? YHForm_Select_Cell.SelectData_None_Model.init();
    }
    
    // MARK: - 指定为时间选择类型
    ///指定为正常选择类型
    func appoint_Time_Model() ->YHForm_Select_Cell.SelectData_Time_Model{
        return (self as? YHForm_Select_Cell.SelectData_Time_Model) ?? YHForm_Select_Cell.SelectData_Time_Model.init();
    }
    
    // MARK: - 指定为地址选择类型
    ///指定为地址选择类型
    func appoint_Address_Model() ->YHForm_Select_Cell.SelectData_Address_Model{
        return (self as? YHForm_Select_Cell.SelectData_Address_Model) ?? YHForm_Select_Cell.SelectData_Address_Model.init();
    }
    
    // MARK: - 指定为银行选择类型
    ///指定为银行选择类型
    func appoint_Bank_Model() ->YHForm_Select_Cell.SelectData_Bank_Model{
        return (self as? YHForm_Select_Cell.SelectData_Bank_Model) ?? YHForm_Select_Cell.SelectData_Bank_Model.init();
    }
    
    // MARK: - 删除正常选择元素组
    ///删除正常选择元素组
    func remove_NoneModelElements(){
        //重置为初始状态
        self.appoint_None_Model().config.elements.forEach { sectionModel in
            sectionModel.isSelect = false;
            sectionModel.openStyle = .open;
            sectionModel.subElements.forEach { elementModel in
                elementModel.isSelect = false;
            }
        }
        self.appoint_None_Model().config.elements.removeAll();
        self.appoint_None_Model().config.selectedElements.removeAll();
        self.appoint_None_Model().config.filterElements.removeAll();
        self.appoint_None_Model().config.supplementElements.removeAll();
        self.appoint_None_Model().config.linkageElement = nil;
        self.appoint_None_Model().config.isSearch = false;
        self.appoint_None_Model().config.searchString = "";
    }
    
    
    
}

