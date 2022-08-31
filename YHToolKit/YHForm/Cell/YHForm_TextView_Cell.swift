//
//  YHForm_TextView_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/21.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//


import UIKit

// MARK: - 代理
@objc protocol YHForm_TextView_Cell_Delegate:NSObjectProtocol{
    ///输入框内容发生变动
    @objc optional func YHForm_TextView_Cell_Delegate_Changed(title:String);
    ///输入框内容结束编辑
    @objc optional func YHForm_TextView_Cell_Delegate_EndEditing(title:String);
}

class YHForm_TextView_Cell: UITableViewCell,UITextViewDelegate {

    // MARK: - 输入框代理
    ///输入框代理
    weak var delegate:YHForm_TextView_Cell_Delegate?;
    
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
        //加载输入框
        self.contentView.addSubview(textView);
        //加载底部提示控件
        self.contentView.addSubview(tips_ContentView);
        //加载附加视图
        self.contentView.addSubview(additionalView);
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
    lazy var textView:UITextView = {
        let tv = UITextView.init(frame: CGRect(x: 0, y: 0, width: 0, height:Form_DefaultCellHeight));
        tv.backgroundColor = .white;
        tv.textColor = Black_Text_Color;
        tv.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 15));
        //关闭首字母大写
        tv.autocapitalizationType = .none;
        //关闭检查拼写
        tv.spellCheckingType = .no;
        //光标颜色
        tv.tintColor = Main_Color;
        //设置代理
        tv.delegate = self;
        return tv;
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
    
    // MARK: - 附加视图
    lazy var additionalView:UIView = {
        let view = UIView.init(frame:CGRect(x: 0, y: 0, width: APP_WIDTH, height: 0));
        view.isHidden = true;
        return view;
    }();
    
    // MARK: - 数据模型
    lazy var model:YHForm_TextView_Model = {
        return YHForm_TextView_Model();
    }();

    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_TextView_Model){
        //赋值模型
        self.model = dataModel;
        //判断编辑类型
        YHForm.calculation_Cell_EditTypeTipsImageView_Style(showType: model.showType, editType: model.editType, imageView: self.editType_TipsImageView);
        //判断是否展示输入框占位富文本
        if self.model.showType == .none && (self.model.editType == .mustComplete || self.model.editType == .optionalComplete){
            //只有正常模式下-必填非必填-状态下展示
            //赋值输入框占位富文本
            self.textView.attributedPlaceholder = model.attPlaceholder;
        }else{
            //赋值输入框占位富文本为空
            self.textView.attributedPlaceholder = "".toAttText_Grey();
        }
        //赋值富文本标题
        self.title_Label.attributedText = model.attTitle;
        //赋值输入框内容
        self.textView.text = model.content ?? "";
        //赋值控件坐标
        self.title_Label.frame = model.titleFrame;
        self.textView.frame = model.contentFrame;
        //处理提示视图
        self.handleTipsView();
        //处理附加视图
        if model.additionalView.frame.size.height > 0{
            self.additionalView.isHidden = false;
            switch model.additionalViewPosition {
            case .titleBottom://位于标题下面
                self.additionalView.frame.origin.y = model.titleFrame.size.height+model.titleFrame.origin.y;
                break;
            }
            self.additionalView.frame.size.height = model.additionalView.frame.size.height;
            self.additionalView.subviews.forEach({$0.removeFromSuperview()});
            self.additionalView.addSubview(model.additionalView);
        }else{
            self.additionalView.isHidden = true;
        }
        //处理限制
        handle_Limit();
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
    
    
    // MARK: - 输入框正在输入
    func textViewDidChange(_ textView: UITextView) {
        //判断是否满足正则
        if textView.text?.isMatch(self.model.limitModel.InputChangeRegular) ?? true == false && self.model.limitModel.InputChangeRegular.count >= 1{
            //不满足
            //清除所输入的内容，还原为上一次输入的记录
            self.textView.text = model.content;
            hud_only.show_Text_AutoDisappear(text: model.attTitle.string+self.model.limitModel.InputChangeRegular_Tips, view: UIFactory.shared.CurrentController().view);
            return;
        }
        //记录所输入的内容
        self.model.content = self.textView.text;
        //通知代理
        self.delegate?.YHForm_TextView_Cell_Delegate_Changed?(title: self.model.attTitle.string);
    }
    
    // MARK: - 输入框结束编辑
    func textViewDidEndEditing(_ textView: UITextView) {
        //判断是否满足正则
        var completeRegular = self.model.limitModel.completeRegular;
        //如何完整正则为空则使用输入正则
        if completeRegular.count <= 0 {
            completeRegular = self.model.limitModel.InputChangeRegular;
        }
        //校验是否符合正则
        if textView.text?.isMatch(completeRegular) ?? true == false && completeRegular.count >= 1{
            //不满足
            hud_only.show_Text_AutoDisappear(text: model.attTitle.string+self.model.limitModel.completeRegular_Tips, view: UIFactory.shared.CurrentController().view);
        }
        //通知代理
        self.delegate?.YHForm_TextView_Cell_Delegate_EndEditing?(title: self.model.attTitle.string);
    }
    
    // MARK: - 是否允许编辑
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
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
    
    // MARK: - 处理限制
    func handle_Limit(){
        //处理全类型限制
        if self.model.limitModel.isAutocorrection{
            //取消自动纠错
            self.textView.autocorrectionType = .default;
        }else{
            //默认自动纠错
            self.textView.autocorrectionType = .no;
        }
        //处理键盘类型
        textView.keyboardType = self.model.limitModel.keyboardType;
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
