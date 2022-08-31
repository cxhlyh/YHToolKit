//
//  YHForm_File_Cell_List_File_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/22.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//


import UIKit

// MARK: - 代理
@objc protocol YHForm_File_Cell_List_File_Cell_Delegate:NSObjectProtocol{
    ///文件点击
    @objc optional func YHForm_File_Cell_List_File_Cell_Delegate_Touch(index:Int);
    ///文件删除
    @objc optional func YHForm_File_Cell_List_File_Cell_Delegate_Remove(index:Int);
}

class YHForm_File_Cell_List_File_Cell: UICollectionViewCell {
    
    ///代理
    weak var delegate:YHForm_File_Cell_List_File_Cell_Delegate?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        //设置背景颜色
        self.contentView.backgroundColor = .white;
        //加载类型图片控件
        self.contentView.addSubview(type_ImageView);
        //加载名称
        self.contentView.addSubview(name_Label);
        //加载大小控件
        self.contentView.addSubview(size_Label);
        //加载删除按钮
        self.contentView.addSubview(remove_Button);
    }
    
    // MARK: - 类型图片控件
    lazy var type_ImageView:UIImageView = {
        let iv = UIImageView.init(frame: CGRect(x: 0, y: 0, width: Form_DefaultCellHeight, height: Form_DefaultCellHeight));
        iv.isUserInteractionEnabled = true;
        iv.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(type_ImageView_Touch)));
        return iv;
    }();
    
    // MARK: - 名称控件
    lazy var name_Label:UILabel = {
        let nl = UILabel.init(frame: CGRect(x: Form_DefaultCellHeight+Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2-Form_DefaultCellHeight-Form_CommonlyGap*2-Form_DefaultCellHeight/5*3, height: Form_DefaultCellHeight/2));
        nl.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 15));
        nl.textColor = Black_Text_Color;
        nl.numberOfLines = 0;
        nl.isUserInteractionEnabled = true;
        nl.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(type_ImageView_Touch)));
        return nl;
    }();
    
    // MARK: - 大小控件
    lazy var size_Label:UILabel = {
        let sl = UILabel.init(frame: CGRect(x: Form_DefaultCellHeight+Form_CommonlyGap, y: Form_DefaultCellHeight/2, width: APP_WIDTH-Form_CommonlyGap*2-Form_DefaultCellHeight-Form_CommonlyGap*2-Form_DefaultCellHeight/5*3, height: Form_DefaultCellHeight/2));
        sl.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 13));
        sl.textColor = Black_Text_Color;
        sl.isUserInteractionEnabled = true;
        sl.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(type_ImageView_Touch)));
        return sl;
    }();
    
    // MARK: - 删除按钮
    lazy var remove_Button:UIButton = {
        let button = UIButton.init(frame: CGRect(x: APP_WIDTH-Form_CommonlyGap*2-Form_DefaultCellHeight/5*3, y: 0, width: Form_DefaultCellHeight/5*3, height: Form_DefaultCellHeight));
        button.isHidden = true;
        button.setTitle("删\n除", for: .normal);
        button.titleLabel?.numberOfLines = 0;
        button.titleLabel?.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 13));
        button.setTitleColor(Main_Color, for: .normal);
        button.contentHorizontalAlignment = .right;
        button.layer.cornerRadius = Form_CommonlyGap/2;
        button.addTarget(self, action: #selector(remove_Button_Touch), for: .touchUpInside);
        return button;
    }();
    
    // MARK: - 数据模型
    lazy var model:YHForm_File_Cell.File_Model = {
        return YHForm_File_Cell.File_Model.init();
    }();
    
    // MARK: - 下标
    lazy var index:Int = {
        return 0;
    }();
    
    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_File_Cell.File_Model,row:Int){
        //赋值模型
        self.model = dataModel;
        //赋值下标
        self.index = row;
        //赋值图片
        //判断类型
        switch model.type {
        case .pdf://pdf
            type_ImageView.image = UIImage.init(named: "YHForm_PDF");
            break;
        case .word://word
            type_ImageView.image = UIImage.init(named: "YHForm_Word");
            break;
        case .excel://excel
            type_ImageView.image = UIImage.init(named: "YHForm_Excel");
            break;
        case .ppt://ppt
            type_ImageView.image = UIImage.init(named: "YHForm_PPT");
            break;
        }
        //加载名称
        name_Label.text = model.fileName;
        size_Label.text = model.fileSize;
        //判断是否展示删除按钮
        switch model.showType {
        case .look://仅查看
            remove_Button.isHidden = true;
            break;
        case .none://正常
            remove_Button.isHidden = false;
            break;
        }
    }
    
    // MARK: - 点击事件
    @objc func type_ImageView_Touch(){
        //点击代理事件
        delegate?.YHForm_File_Cell_List_File_Cell_Delegate_Touch?(index: self.index);
    }
    
    // MARK: - 删除点击事件
    @objc func remove_Button_Touch(){
        //删除点击代理事件
        delegate?.YHForm_File_Cell_List_File_Cell_Delegate_Remove?(index: self.index);
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
}
