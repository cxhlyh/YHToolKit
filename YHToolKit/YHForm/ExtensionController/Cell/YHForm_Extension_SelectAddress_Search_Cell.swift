//
//  YHForm_Extension_SelectAddress_Search_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2022/6/16.
//  Copyright © 2022 HeNanYiZhong. All rights reserved.
//


import UIKit
import AttributedLabel

class YHForm_Extension_SelectAddress_Search_Cell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        //取消点击变色
        self.selectionStyle = .none;
        //加载标题
        self.contentView.addSubview(title_Label);
        //加载距离
        self.contentView.addSubview(distance_Label);
        //加载地址
        self.contentView.addSubview(address_Label);
    }
    
    // MARK: - 标题
    lazy var title_Label:UILabel = {
        let label = UILabel.init(frame: CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: 0));
        label.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 14));
        return label;
    }();
    
    // MARK: - 距离label
    lazy var distance_Label:UILabel = {
        let label = UILabel.init(frame: CGRect(x: Form_CommonlyGap, y: 0, width: 0, height: 0));
        label.textAlignment = .right;
        label.textColor = UIColor.init(hexString: "#666666");
        label.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 12));
        return label;
    }();
    
    // MARK: - 地址
    lazy var address_Label:UILabel = {
        let label = UILabel.init(frame: CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: 0));
        label.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 12));
        label.numberOfLines = 0;
        label.textColor = Grey_Text_Color;
        return label;
    }();
    
    // MARK: - 模型
    lazy var model:YHForm_Extension_SelectAddress_ViewController.YHForm_Extension_SelectAddress_Model = {
        return YHForm_Extension_SelectAddress_ViewController.YHForm_Extension_SelectAddress_Model();
    }();
    
    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_Extension_SelectAddress_ViewController.YHForm_Extension_SelectAddress_Model){
        //赋值模型
        self.model = dataModel;
        //赋值UI
        self.title_Label.frame.origin.y = Form_CommonlyGap;
        self.title_Label.frame.size.height = model.nameHeight;
        self.title_Label.frame.size.width = APP_WIDTH-Form_CommonlyGap*3-model.distanceWidth;
        
        self.distance_Label.frame.origin.y = Form_CommonlyGap;
        self.distance_Label.frame.size.height = model.nameHeight;
        self.distance_Label.frame.size.width = model.distanceWidth;
        self.distance_Label.frame.origin.x = APP_WIDTH-Form_CommonlyGap-model.distanceWidth;
        
        self.address_Label.frame.origin.y = Form_CommonlyGap*1.5+model.nameHeight;
        self.address_Label.frame.size.height = model.contentHeight;

        let nameMutableString = NSMutableAttributedString.init(string: self.model.name ?? "");
        for (i,char) in nameMutableString.string.enumerated(){
            if (model.searchName ?? "").contains(char){
                nameMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: Main_Color, range: NSRange(location: i, length: 1));
            }else{
                nameMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: Black_Text_Color, range: NSRange(location: i, length: 1));
            }
        }
        nameMutableString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: Calculation_FontNumber(font: 14)), range: NSRange(location: 0, length: nameMutableString.length));
        
        self.title_Label.attributedText = nameMutableString;
        self.distance_Label.text = self.model.distance ?? "";
        self.address_Label.text = (self.model.province ?? "")+(self.model.city ?? "")+(self.model.district ?? "")+(self.model.address ?? "");
    }
  
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
