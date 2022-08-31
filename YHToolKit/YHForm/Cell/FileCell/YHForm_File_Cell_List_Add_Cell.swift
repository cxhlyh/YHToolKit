//
//  YHForm_File_Cell_List_Add_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/22.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//


import UIKit

// MARK: - 代理
@objc protocol YHForm_File_Cell_List_Add_Cell_Delegate:NSObjectProtocol{
    ///文件发生变动
    @objc optional func YHForm_File_Cell_List_Add_Cell_Delegate_Add();
}

class YHForm_File_Cell_List_Add_Cell: UICollectionViewCell {
    
    ///代理
    weak var delegate:YHForm_File_Cell_List_Add_Cell_Delegate?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        //加载添加按钮
        self.contentView.addSubview(add_Button);
    }
    
    // MARK: - 添加按钮
    lazy var add_Button:UIButton = {
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: Form_DefaultCellHeight, height: Form_DefaultCellHeight));
        button.setImage(UIImage.init(named: "public_imageUpLoad_add"), for: .normal);
        button.addTarget(self, action: #selector(add_Button_Touch), for: .touchUpInside);
        return button;
    }();
    
    // MARK: - 添加按钮点击事件
    @objc func add_Button_Touch(){
        //代理
        delegate?.YHForm_File_Cell_List_Add_Cell_Delegate_Add?();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
}
