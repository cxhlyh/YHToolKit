//
//  YHForm_TextField_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/10.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//

import UIKit
import AttributedLabel

// MARK: - 代理
@objc protocol YHForm_TextField_Cell_Delegate:NSObjectProtocol{
    ///输入框内容发生变动
    @objc optional func YHForm_TextField_Cell_Delegate_Changed(title:String);
    ///输入框内容结束编辑
    @objc optional func YHForm_TextField_Cell_Delegate_EndEditing(title:String);
    ///输入框内容发生变动导致输入校验结果变更
    @objc optional func YHForm_TextField_Cell_Delegate_InputLimitResultChanged(title:String,idKey:String);
}

class YHForm_TextField_Cell: UITableViewCell,UITextFieldDelegate,YHForm_Extension_ScanCode_ViewController_Delegate{

    // MARK: - 输入框代理
    ///输入框代理
    weak var delegate:YHForm_TextField_Cell_Delegate?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        //取消点击变色
        self.selectionStyle = .none;
        //加载编辑类型提示控件
        self.contentView.addSubview(editType_TipsImageView);
        //加载标题控件
        self.contentView.addSubview(title_Label);
        //加载内容展示框
        self.contentView.addSubview(contentLabel);
        //加载输入框
        self.contentView.addSubview(textField);
        //加载底部提示控件
        self.contentView.addSubview(tips_ContentView);
        //加载输入不合规提示控件
        self.contentView.addSubview(inputLimitUnqualifiedTipsView);
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
    
    // MARK: - 输入框
    lazy var textField:UITextField = {
        let tf = UITextField.init(frame: CGRect(x: 0, y: 0, width: 0, height:Form_DefaultCellHeight));
        tf.backgroundColor = .white;
        tf.textColor = Black_Text_Color;
        tf.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 16));
        tf.textAlignment = .right;
        //编辑时开启清空按钮
        tf.clearButtonMode = .whileEditing;
        //关闭首字母大写
        tf.autocapitalizationType = .none;
        //关闭检查拼写
        tf.spellCheckingType = .no;
        //光标颜色
        tf.tintColor = Main_Color;
        //设置代理
        tf.delegate = self;
        //设置监听
        tf.addTarget(self, action: #selector(textField_Changed), for: .editingChanged);
        //设置右侧容器永不展示
        tf.rightViewMode = .never;
        return tf;
    }();
    
    
    // MARK: - 内容展示文本
    lazy var contentLabel:AttributedLabel = {
        let label = AttributedLabel.init(frame: CGRect(x: 0, y: 0, width: 0, height:Form_DefaultCellHeight));
        label.backgroundColor = .white;
        label.textColor = Black_Text_Color;
        label.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 16));
        label.isHidden = true;
        label.isUserInteractionEnabled = true;
        label.numberOfLines = 0;
        label.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(contentLabel_Touch)));
        return label;
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
    
    // MARK: - 输入校验不合规提示视图
    lazy var inputLimitUnqualifiedTipsView:UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: APP_WIDTH, height: 0));
        view.backgroundColor = Grey_BackGround_Color;
        view.layer.masksToBounds = true;
        //加载文本视图
        view.addSubview(inputLimitUnqualifiedTipsLabel);
        //加载分割线
        view.addSubview(inputLimitUnqualifiedTipsLineView);
        //默认隐藏
        view.isHidden = true;
        return view;
    }();
    
    // MARK: - 输入校验不合规提示文本
    lazy var inputLimitUnqualifiedTipsLabel:UILabel = {
        let label = UILabel.init(frame: CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: 0));
        label.numberOfLines = 0;
        return label;
    }();
    
    // MARK: - 输入校验不合规不合规分割线
    lazy var inputLimitUnqualifiedTipsLineView:UIView = {
        let view = UIView.init(frame: CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap, height: 1));
        view.isHidden = true;
        return view;
    }();
    
    // MARK: - 数据模型
    lazy var model:YHForm_TextField_Model = {
        return YHForm_TextField_Model();
    }();
    
    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_TextField_Model){
        //赋值模型
        self.model = dataModel;
        //判断编辑类型
        YHForm.calculation_Cell_EditTypeTipsImageView_Style(showType: model.showType, editType: model.editType, imageView: self.editType_TipsImageView);
        //判断是否展示输入框占位富文本
        if self.model.showType == .none && (self.model.editType == .mustComplete || self.model.editType == .optionalComplete){
            //只有正常模式下-必填非必填-状态下展示
            //赋值输入框占位富文本
            self.textField.attributedPlaceholder = model.attPlaceholder;
            self.textField.isHidden = false;
            self.contentLabel.isHidden = true;
        }else{
            //赋值输入框占位富文本为空
            self.textField.attributedPlaceholder = "".toAttText_Grey();
            self.textField.isHidden = true;
            self.contentLabel.isHidden = false;
            //处理对齐方式
            if model.contentFrame.origin.x <= Form_CommonlyGap+1{
                self.contentLabel.contentAlignment = .topRight;
            }else{
                self.contentLabel.contentAlignment = .right;
            }
        }
        //赋值富文本标题
        self.title_Label.attributedText = model.attTitle;
        //赋值输入框内容
        self.textField.text = model.content ?? "";
        //赋值内容展示框内容
        self.contentLabel.text = model.content ?? "";
        //赋值控件坐标
        self.title_Label.frame = model.titleFrame;
        self.textField.frame = model.contentFrame;
        self.contentLabel.frame = model.contentFrame;
        //处理提示和不合规视图
        self.handleTipsAndInputLimitUnqualifiedView(isAnimate: false);
        //处理拓展类型
        handle_ExtensionType();
        //处理限制
        handle_Limit();
    }
    
    // MARK: - 处理提示和不合规视图 isAnimate是否需要动画效果
    func handleTipsAndInputLimitUnqualifiedView(isAnimate:Bool){
        //本次更新不合规视图是否从展示到隐藏|隐藏到展示 需要动画效果
        var isInputLimitUnqualifiedAnimate = false;
        //处理不合规视图起始坐标
        inputLimitUnqualifiedTipsView.frame.origin.y = self.model.limitModel.bottomLimitTipsFrame.origin.y;
        //判断是否需要展示
        if model.limitModel.bottomLimitTipsFrame.size.height > 0{
            //判断展示之前是否有过隐藏
            if inputLimitUnqualifiedTipsView.isHidden == true && isAnimate{
                isInputLimitUnqualifiedAnimate = true;
            }
            //需要展示
            inputLimitUnqualifiedTipsView.isHidden = false;
            //赋值不合规文本高度
            inputLimitUnqualifiedTipsLabel.frame.size.height = self.model.limitModel.bottomLimitTipsFrame.size.height;
            //赋值不合规分割线坐标
            inputLimitUnqualifiedTipsLineView.frame.origin.y = self.model.limitModel.bottomLimitTipsFrame.size.height-inputLimitUnqualifiedTipsLineView.frame.size.height;
            //赋值不合规文本内容
            inputLimitUnqualifiedTipsLabel.attributedText = self.model.limitModel.bottomLimitTipsAtt;
        }else{
            //判断隐藏之前是否有过展示
            if inputLimitUnqualifiedTipsView.isHidden == false && isAnimate{
                isInputLimitUnqualifiedAnimate = true;
            }
            //不需要展示
            inputLimitUnqualifiedTipsView.isHidden = true;
        }
        
        
        //处理底部提示视图高度
        if isInputLimitUnqualifiedAnimate{
            UIView.animate(withDuration: 0.3) {
                //处理不合规视图高度
                self.inputLimitUnqualifiedTipsView.frame.size.height = self.model.limitModel.bottomLimitTipsFrame.size.height;
                //处理提示视图起始坐标
                self.tips_ContentView.frame.origin.y = self.model.tipsFrame.origin.y;
            }
        }else{
            //处理不合规视图高度
            inputLimitUnqualifiedTipsView.frame.size.height =  self.model.limitModel.bottomLimitTipsFrame.size.height;
            //处理提示视图起始坐标
            self.tips_ContentView.frame.origin.y = self.model.tipsFrame.origin.y;
        }
        self.tips_ContentView.frame.size.height = self.model.tipsFrame.size.height;
        //赋值背景颜色
        self.tips_ContentView.backgroundColor = self.model.bottom_TipsAttBackGroundColor;
        //处理是否展示
        if model.tipsFrame.size.height > 0 {
            //展示
            self.tips_ContentView.isHidden = false;
            //赋值底部提示文本高度
            self.tips_Label.frame.size.height = self.model.tipsFrame.size.height;
            //赋值底部提示文本内容
            self.tips_Label.attributedText = model.bottom_TipsAttContent;
            //判断是否需要隐藏不合规分割线
            if self.inputLimitUnqualifiedTipsView.isHidden{
                self.inputLimitUnqualifiedTipsLineView.isHidden = true;
            }else{
                self.inputLimitUnqualifiedTipsLineView.isHidden = false;
                self.inputLimitUnqualifiedTipsLineView.backgroundColor = self.model.limitModel.bottomLimitTipsAtt.yh_GetAttFirstStringColor() ?? UIColor.red;
            }
        }else{
            //隐藏
            self.tips_ContentView.isHidden = true;
            //隐藏不合规分割线
            self.inputLimitUnqualifiedTipsLineView.isHidden = true;
        }
        
    }
    
    
    // MARK: - 点击完成按钮
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //收起键盘
        textField.resignFirstResponder();
        return true;
    }
    
    
    // MARK: - 输入框正在输入
    @objc func textField_Changed(){
        //判断是否满足正则
        if textField.text?.isMatch(self.model.limitModel.InputChangeRegular) ?? true == false && self.model.limitModel.InputChangeRegular.count >= 1 && textField.text?.count ?? 0 >= 1{
            //不满足
            //处理当前输入框内是否已经有不满足输入正则的数据 如果有就清除掉
            if model.content?.isMatch(self.model.limitModel.InputChangeRegular) ?? true == false{
                //现有内容已经有不合规数据
                if textField.text?.count ?? 0 > 0 {
                    //本次输入后未清空
                    self.textField.text = "";
                    hud_only.show_Text_AutoDisappear(text: model.attTitle.string+"内有不符合格式要求的内容,现已全部清空。", view: UIFactory.shared.CurrentController().view);
                }
            }else{
                //清除所输入的内容，还原为上一次输入的记录
                self.textField.text = model.content;
                hud_only.show_Text_AutoDisappear(text: model.attTitle.string+self.model.limitModel.InputChangeRegular_Tips, view: UIFactory.shared.CurrentController().view);
                return;
            }
        }
        //记录所输入的内容
        self.model.content = self.textField.text;
        //通知代理
        self.delegate?.YHForm_TextField_Cell_Delegate_Changed?(title: self.model.attTitle.string);
        
        //处理正则校验结果变更通知
        //判断是否需要正则校验
        if self.model.limitModel.completeRegular.count >= 1 || self.model.limitModel.InputChangeRegular.count >= 1{
            //发送代理通知
            self.delegate?.YHForm_TextField_Cell_Delegate_InputLimitResultChanged?(title: self.model.attTitle.string,idKey: self.model.idKey);
            //处理提示和不合规视图
            self.handleTipsAndInputLimitUnqualifiedView(isAnimate: true);
        }
    }
    
    // MARK: - 输入框结束编辑
    func textFieldDidEndEditing(_ textField: UITextField) {
        //判断正则校验
        if completeRegularVerificationResults() == false{
            //不满足
//            hud_only.show_Text_AutoDisappear(text: model.attTitle.string+self.model.limitModel.completeRegular_Tips, view: UIFactory.shared.CurrentController().view);
        }
        //通知代理
        self.delegate?.YHForm_TextField_Cell_Delegate_EndEditing?(title: self.model.attTitle.string);
    }
    
    // MARK: - 完整正则校验结果
    func completeRegularVerificationResults() ->Bool{
        //判断是否满足正则
        var completeRegular = self.model.limitModel.completeRegular;
        //如完整正则为空则使用输入正则
        if completeRegular.count <= 0 {
            completeRegular = self.model.limitModel.InputChangeRegular;
        }
        //校验是否符合正则
        if textField.text?.isMatch(completeRegular) ?? true == false && completeRegular.count >= 1 && textField.text?.count ?? 0 >= 1{
            //不满足
            return false;
        }
        return true;
    }
    

    
    // MARK: - 是否允许编辑
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.model.showType == .none && (self.model.editType == .optionalComplete || self.model.editType == .mustComplete) {
            //可以编辑
            return true;
        }
        //禁止编辑的时候复制文本
        if self.model.content?.count ?? 0 >= 1{
            UIPasteboard.general.string = self.model.content ?? "";
            if UIPasteboard.general.string == self.model.content{
                //提示复制成功
                hud_only.show_Text_AutoDisappear(text: "复制成功", view: UIFactory.shared.CurrentController().view);
            }
        }
        return false;
    }
   
    // MARK: - 内容展示框点击事件
    @objc func contentLabel_Touch(){
        //复制文本
        if self.model.content?.count ?? 0 >= 1{
            UIPasteboard.general.string = self.model.content ?? "";
            if UIPasteboard.general.string == self.model.content{
                //提示复制成功
                hud_only.show_Text_AutoDisappear(text: "复制成功", view: UIFactory.shared.CurrentController().view);
            }
        }
    }
    
    // MARK: - 处理限制
    func handle_Limit(){
        //处理全类型限制
        if self.model.limitModel.isAutocorrection{
            //取消自动纠错
            self.textField.autocorrectionType = .default;
        }else{
            //默认自动纠错
            self.textField.autocorrectionType = .no;
        }
        //处理键盘类型
        textField.keyboardType = self.model.limitModel.keyboardType;
    }
    
    
    // MARK: - 处理拓展类型
    func handle_ExtensionType(){
        if self.model.showType == .none && (self.model.editType == .optionalComplete || self.model.editType == .mustComplete) {
            //可以编辑
            switch model.extensionType {
            case .none://无
                self.textField.rightViewMode = .never;
                break;
            case .scanCode://扫码
                self.textField.rightView = scanCodeView;
                self.textField.rightViewMode = .always;
                break;
            }
        }else{
            //隐藏右侧拓展视图
            self.textField.rightViewMode = .never;
        }
    }
    
    // MARK: - 扫码视图
    lazy var scanCodeView:UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: Form_CommonlyGap+Form_DefaultCellHeight/2, height: Form_DefaultCellHeight));
        let imageView = UIImageView.init(frame: CGRect(x: Form_CommonlyGap, y: Form_DefaultCellHeight/4, width: Form_DefaultCellHeight/2, height: Form_DefaultCellHeight/2));
        imageView.image = UIImage.init(named: "YHForm_ScanCode");
        imageView.isUserInteractionEnabled = true;
        view.addSubview(imageView);
        view.isUserInteractionEnabled = true;
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(scanCodeView_Touch)));
        return view;
    }();
    
    // MARK: - 扫码点击事件
    @objc func scanCodeView_Touch(){
        let scanCodeController = YHForm_Extension_ScanCode_ViewController.init();
        scanCodeController.modalPresentationStyle = .fullScreen;
        scanCodeController.delegate = self;
        scanCodeController.scanCodeType = model.scanCodeType;
        UIFactory.shared.CurrentController().present(scanCodeController, animated: true, completion: nil);
    }
    
    // MARK: - 获取到的扫码结果
    func YHForm_Extension_ScanCode_ViewController_Delegate_CodeResult(Result: String) {
        if self.model.showType == .none && (self.model.editType == .optionalComplete || self.model.editType == .mustComplete) {
            //可以编辑
            switch model.extensionType {
            case .scanCode://扫码
                //填充数据
                self.textField.text = Result;
                //记录所扫描的内容
                self.model.content = self.textField.text;
                break;
            default ://其它
                break;
            }
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}

// MARK: - 拓展
extension YHForm_TextField_Cell{
    
    // MARK: - 输入限制模型
    class inputLimit_None_Model:NSObject{
        ///键盘类型（默认不限制）
        var keyboardType:UIKeyboardType = UIKeyboardType.default;
        ///是否允许自动联想
        var isAutocorrection = false;
        ///完整正则  ---- 注(正则主要作用于输入结束和提交参数的时候校验格式是否完整 --- 如果参数为空，则默认使用 InputChangeRegular);
        var completeRegular = "";
        /// 完整正则不匹配提示
        var completeRegular_Tips = " - 输入内容格式不符合最终要求,请仔细检查后改正";
        ///输入变动正则 ---- 输入的时候实时校验（注：主要用来校验输入的字符类型是否正确）
        var InputChangeRegular = "";
        /// 输入变动正则不匹配提示
        var InputChangeRegular_Tips = " - 本次输入内容不符合,请重新输入";
        ///底部输入完成后不符合正则提示文本
        var bottomLimitTipsAtt = "".toAttText_ColorWithFont13(color: .red);
        ///底部输入完成后不符合正则提示文本坐标
        var bottomLimitTipsFrame = CGRect.init();
    }
    
}


// MARK: - 拓展输入限制基础模型
extension YHForm_TextField_Cell.inputLimit_None_Model{
    
    // MARK: - 创建手机号校验类型模型
    ///创建手机号校验类型模型
    static func create_PhoneNumberLimitModel() ->YHForm_TextField_Cell.inputLimit_None_Model{
        let limitModel = YHForm_TextField_Cell.inputLimit_None_Model.init();
        limitModel.completeRegular = "^1[0-9]{10}$";
        limitModel.InputChangeRegular = "^[0-9]*$";
        limitModel.keyboardType = .numberPad;
        return limitModel;
    }
    
    // MARK: - 创建正负整数金额校验类型模型
    ///创建正负整数金额校验类型模型
    static func create_IntegerMoneyLimitModel() ->YHForm_TextField_Cell.inputLimit_None_Model{
        let limitModel = YHForm_TextField_Cell.inputLimit_None_Model.init();
        limitModel.completeRegular = "^(-?[1-9]{1}\\d*|0{1})$";
        limitModel.InputChangeRegular = "^(-|-?[1-9]{1}\\d*|0{1})$";
        limitModel.keyboardType = .numbersAndPunctuation;
        return limitModel;
    }
    
    // MARK: - 创建正整数金额校验类型模型
    ///创建正整数金额校验类型模型
    static func create_PositiveIntegerMoneyLimitModel() ->YHForm_TextField_Cell.inputLimit_None_Model{
        let limitModel = YHForm_TextField_Cell.inputLimit_None_Model.init();
        limitModel.completeRegular = "^[0-9]*$";
        limitModel.InputChangeRegular = "^[0-9]*$";
        limitModel.keyboardType = .numberPad;
        return limitModel;
    }
    
    // MARK: - 创建身份证号校验类型模型
    ///创建身份证号校验类型模型
    static func create_IDCardLimitModel() ->YHForm_TextField_Cell.inputLimit_None_Model{
        let limitModel = YHForm_TextField_Cell.inputLimit_None_Model.init();
        limitModel.completeRegular = "^\\d{17}(\\d|X|x)$";
        limitModel.InputChangeRegular = "^(\\d|x|X)*$";
        return limitModel;
    }
    
    // MARK: - 创建车架号校验类型模型
    ///创建车架号校验类型模型
    static func create_VINLimitModel() ->YHForm_TextField_Cell.inputLimit_None_Model{
        let limitModel = YHForm_TextField_Cell.inputLimit_None_Model.init();
        limitModel.completeRegular = "^[a-zA-Z0-9]{17}$";
        limitModel.InputChangeRegular = "^[a-zA-Z0-9]*$";
        return limitModel;
    }
   
}
