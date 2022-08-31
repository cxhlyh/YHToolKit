//
//  YHForm_Tips_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2022/7/13.
//  Copyright © 2022 HeNanYiZhong. All rights reserved.
//


import UIKit

class YHForm_Tips_Cell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        //取消点击变色
        self.selectionStyle = .none;
        //加载内容文本
        self.contentView.addSubview(contentLabel);
    }
    
    // MARK: - 内容文本
    lazy var contentLabel:UILabel = {
        let label = UILabel.init(frame: CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: 0));
        label.isHidden = true;
        label.numberOfLines = 0;
        return label;
    }();
    
    // MARK: - 数据模型
    lazy var model:YHForm_Tips_Model = {
        return YHForm_Tips_Model();
    }();
    
    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_Tips_Model){
        //赋值模型
        self.model = dataModel;
        //设置背景颜色
        self.contentView.backgroundColor = self.model.backGroundColor;
        //判断是否强制占位
        if model.forcedOccupancy{
            contentLabel.isHidden = true;
        }else{
            contentLabel.isHidden = false;
            contentLabel.frame.size.height = model.cellHeight;
            contentLabel.textAlignment = model.textAlignment;
            contentLabel.attributedText = model.attTitle;
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
