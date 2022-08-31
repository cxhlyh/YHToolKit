//
//  YHForm_None_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/10.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//

import UIKit

class YHForm_None_Cell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        //取消点击变色
        self.selectionStyle = .none;
        //设置背景颜色
        self.contentView.backgroundColor = Random_Color();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
