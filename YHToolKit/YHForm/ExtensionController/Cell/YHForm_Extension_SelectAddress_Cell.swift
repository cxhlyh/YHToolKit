//
//  YHForm_Extension_SelectAddress_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2022/6/15.
//  Copyright © 2022 HeNanYiZhong. All rights reserved.
//

import UIKit
import AttributedLabel

class YHForm_Extension_SelectAddress_Cell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        //取消点击变色
        self.selectionStyle = .none;
        //加载图片
        self.contentView.addSubview(addressImageView);
        //加载标题
        self.contentView.addSubview(title_Label);
        //加载地址
        self.contentView.addSubview(address_Label);
    }

    // MARK: - 图片
    lazy var addressImageView:UIImageView = {
        let iv = UIImageView.init(frame: CGRect(x: Form_CommonlyGap, y:0, width: Form_DefaultCellHeight/2, height: Form_DefaultCellHeight/2));
        iv.image = UIImage.init(named: "YHForm_Location_Black");
        return iv;
    }();
    
    // MARK: - 标题
    lazy var title_Label:UILabel = {
        let label = UILabel.init(frame: CGRect(x: Form_CommonlyGap*2+Form_DefaultCellHeight/2, y: 0, width: APP_WIDTH-Form_CommonlyGap*3-Form_DefaultCellHeight/2, height: 0));
        label.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 14));
        return label;
    }();
    
    // MARK: - 地址
    lazy var address_Label:UILabel = {
        let label = UILabel.init(frame: CGRect(x: Form_CommonlyGap*2+Form_DefaultCellHeight/2, y: 0, width: APP_WIDTH-Form_CommonlyGap*3-Form_DefaultCellHeight/2, height: 0));
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
        self.addressImageView.frame.origin.y = (model.nameHeight+model.contentHeight+Form_CommonlyGap*2.5)/2-Form_DefaultCellHeight/2/2;
        self.title_Label.frame.origin.y = Form_CommonlyGap;
        self.title_Label.frame.size.height = model.nameHeight;
        self.address_Label.frame.origin.y = Form_CommonlyGap*1.5+model.nameHeight;
        self.address_Label.frame.size.height = model.contentHeight;

        self.title_Label.text = self.model.name ?? "";
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
