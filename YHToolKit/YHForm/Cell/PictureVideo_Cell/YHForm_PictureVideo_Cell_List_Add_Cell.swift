//
//  YHForm_PictureVideo_Cell_List_Add_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/21.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//

import UIKit

// MARK: - 代理
@objc protocol YHForm_PictureVideo_Cell_List_Add_Cell_Delegate:NSObjectProtocol{
    ///图片视频发生变动
    @objc optional func YHForm_PictureVideo_Cell_List_Add_Cell_Delegate_Add();
}

class YHForm_PictureVideo_Cell_List_Add_Cell: UICollectionViewCell {
    
    ///代理
    weak var delegate:YHForm_PictureVideo_Cell_List_Add_Cell_Delegate?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        //加载添加按钮
        self.contentView.addSubview(add_Button);
    }
    
    // MARK: - 添加按钮
    lazy var add_Button:UIButton = {
        let button = UIButton.init(frame: CGRect(x: Form_CommonlyGap/2, y: Form_CommonlyGap/2, width: (APP_WIDTH-Form_CommonlyGap)/4-Form_CommonlyGap, height: (APP_WIDTH-Form_CommonlyGap)/4-Form_CommonlyGap));
        button.setImage(UIImage.init(named: "public_imageUpLoad_add"), for: .normal);
        button.addTarget(self, action: #selector(add_Button_Touch), for: .touchUpInside);
        return button;
    }();
    
    // MARK: - 添加按钮点击事件
    @objc func add_Button_Touch(){
        //代理
        delegate?.YHForm_PictureVideo_Cell_List_Add_Cell_Delegate_Add?();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
}
