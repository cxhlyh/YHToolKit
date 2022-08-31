//
//  YHForm_DirectSelect_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2022/6/23.
//  Copyright © 2022 HeNanYiZhong. All rights reserved.
//

import UIKit
import AttributedLabel

class YHForm_DirectSelect_Cell: UITableViewCell,UITableViewDelegate,UITableViewDataSource {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        //取消点击变色
        self.selectionStyle = .none;
        //加载编辑类型提示控件
        self.contentView.addSubview(editType_TipsImageView);
        //加载标题
        self.contentView.addSubview(title_Label);
        //加载容器列表
        self.contentView.addSubview(contentListTableView);
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
        let label = UILabel.init(frame: CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: Form_DefaultCellHeight));
        label.numberOfLines = 0;
        return label;
    }();
    
    // MARK: - 容器视图
    lazy var contentListTableView:UITableView = {
        let view = UITableView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .plain);
        view.backgroundColor = .white;
        view.register(YHForm_DirectSelect_Cell_Element_Cell.classForCoder(), forCellReuseIdentifier: "YHForm_DirectSelect_Cell_Element_Cell_ID");
        view.delegate = self;
        view.dataSource = self;
        view.bounces = false;
        view.separatorStyle = .none;
        return view;
    }();
    
    // MARK: - cell数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.data.count;
    }
    
    // MARK: - cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return model.data[indexPath.row].elementHeight;
    }
    
    // MARK: - cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YHForm_DirectSelect_Cell_Element_Cell_ID", for: indexPath) as! YHForm_DirectSelect_Cell_Element_Cell;
        cell.update_UI(dataModel: model.data[indexPath.row], contentArray: model.contentArray);
        return cell;
    }
    
    // MARK: - cell点击事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if model.showType == .none && (model.editType == .mustComplete || model.editType == .optionalComplete){
            if model.contentArray.contains(model.data[indexPath.row].elementID ?? ""){
                model.contentArray.removeAll { elementID in
                    return elementID == model.data[indexPath.row].elementID ?? "";
                }
            }else{
                if model.multipleSelection == false{
                    //单选状态下删除所有选项
                    model.contentArray.removeAll();
                }
                model.contentArray.append(model.data[indexPath.row].elementID ?? "");
            }
            //刷新列表
            self.contentListTableView.reloadData();
        }
    }
    
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
    lazy var model:YHForm_DirectSelect_Model = {
        return YHForm_DirectSelect_Model();
    }();
    
    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_DirectSelect_Model){
        //赋值模型
        self.model = dataModel;
        //判断编辑类型
        YHForm.calculation_Cell_EditTypeTipsImageView_Style(showType: model.showType, editType: model.editType, imageView: self.editType_TipsImageView);
        //赋值富文本标题
        self.title_Label.attributedText = model.attTitle;
        //赋值控件坐标
        self.title_Label.frame = model.titleFrame;
        self.contentListTableView.frame = model.contentFrame;
        //处理提示视图
        self.handleTipsView();
        //刷新列表
        self.contentListTableView.reloadData();
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
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// MARK: - 拓展
extension YHForm_DirectSelect_Cell{
    
    //cell类
    class YHForm_DirectSelect_Cell_Element_Cell:UITableViewCell{
        
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier);
            //取消点击变色
            self.selectionStyle = .none;
            //加载选择提示图片
            self.contentView.addSubview(selectTipsImageView);
            //加载标题
            self.contentView.addSubview(titleLabel);
        }
        
        // MARK: - 选择提示图片
        lazy var selectTipsImageView:UIImageView = {
            let ivWidth = "标准宽度".text_Size(maxSize: CGSize(width: APP_WIDTH, height: 999), font: UIFont.systemFont(ofSize: Calculation_FontNumber(font: 14))).height;
            let iv = UIImageView.init(frame: CGRect(x: Form_CommonlyGap, y: Form_CommonlyGap/2, width: ivWidth, height: ivWidth));
            return iv;
        }();
        
        // MARK: - 标题
        lazy var titleLabel:AttributedLabel = {
            let label = AttributedLabel.init(frame: CGRect(x: Form_CommonlyGap*2.5, y: Form_CommonlyGap/2, width: APP_WIDTH-Form_CommonlyGap*4.5, height: 0));
            label.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 14));
            label.contentAlignment = .topLeft;
            label.numberOfLines = 0;
            label.textColor = Black_Text_Color;
            return label;
        }();
        
        // MARK: - 更新UI
        func update_UI(dataModel:YHForm_DirectSelect_Model.YHForm_DirectSelect_Element_Model,contentArray:[String]){
            if contentArray.contains(dataModel.elementID ?? ""){
                //选中
                selectTipsImageView.image = UIImage.init(named: "YHBottomSelect_Select_Square_True");
            }else{
                //未选中
                selectTipsImageView.image = UIImage.init(named: "YHBottomSelect_Select_Square_False");
            }
            //赋值标题
            titleLabel.text = dataModel.elementName ?? "";
            titleLabel.frame.size.height = dataModel.elementHeight-Form_CommonlyGap/2;
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder);
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)

            // Configure the view for the selected state
        }
    }
    
}
