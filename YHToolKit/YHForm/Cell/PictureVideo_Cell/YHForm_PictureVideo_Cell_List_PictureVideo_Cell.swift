//
//  YHForm_PictureVideo_Cell_List_PictureVideo_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/21.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//

import UIKit

// MARK: - 代理
@objc protocol YHForm_PictureVideo_Cell_List_PictureVideo_Cell_Delegate:NSObjectProtocol{
    ///图片视频点击
    @objc optional func YHForm_PictureVideo_Cell_List_PictureVideo_Cell_Delegate_Touch(index:Int);
    ///图片视频删除
    @objc optional func YHForm_PictureVideo_Cell_List_PictureVideo_Cell_Delegate_Remove(index:Int);
}

class YHForm_PictureVideo_Cell_List_PictureVideo_Cell: UICollectionViewCell {
    
    ///代理
    weak var delegate:YHForm_PictureVideo_Cell_List_PictureVideo_Cell_Delegate?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        //设置背景颜色
        self.contentView.backgroundColor = .white;
        //加载图片控件
        self.contentView.addSubview(imageView);
        //加载类型控件
        imageView.addSubview(type_ImageView);
        //加载蒙版控件
        imageView.addSubview(mask_ImageView);
        //加载删除按钮
        self.contentView.addSubview(remove_Button);
    }
    
    // MARK: - 图片控件
    lazy var imageView:UIImageView = {
        let iv = UIImageView.init(frame: CGRect(x: Form_CommonlyGap/2, y: Form_CommonlyGap/2, width: (APP_WIDTH-Form_CommonlyGap)/4-Form_CommonlyGap, height: (APP_WIDTH-Form_CommonlyGap)/4-Form_CommonlyGap));
        iv.isUserInteractionEnabled = true;
        iv.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(imageView_Touch)));
        return iv;
    }();
    
    // MARK: - 类型控件
    lazy var type_ImageView:UIImageView = {
        let iv = UIImageView.init(frame: CGRect(x:Form_CommonlyGap*1.1, y: Form_CommonlyGap*1.1, width: imageView.frame.size.width-Form_CommonlyGap*2.2, height: imageView.frame.size.width-Form_CommonlyGap*2.2));
        iv.isUserInteractionEnabled = true;
        iv.image = UIImage.init(named: "public_Video");
        iv.isHidden = true;
        return iv;
    }();
    
    // MARK: - 蒙版控件
    lazy var mask_ImageView:UIImageView = {
        let iv = UIImageView.init(frame: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.width));
        iv.isUserInteractionEnabled = true;
        iv.image = UIImage.init(named: "public_imageUpLoad_newWorkTips");
        iv.isHidden = true;
        return iv;
    }();
    
    // MARK: - 删除按钮
    lazy var remove_Button:UIButton = {
        let button = UIButton.init(frame: CGRect(x: Form_CommonlyGap+imageView.frame.size.width-Form_CommonlyGap*1.5, y: 0, width: Form_CommonlyGap*1.5, height: Form_CommonlyGap*1.5));
        button.setImage(UIImage.init(named: "public_imageUpLoad_remove"), for: .normal);
        button.isHidden = true;
        button.addTarget(self, action: #selector(remove_Button_Touch), for: .touchUpInside)
        return button;
    }();
    
    // MARK: - 数据模型
    lazy var model:YHForm_PictureVideo_Cell.PictureVideo_Model = {
        return YHForm_PictureVideo_Cell.PictureVideo_Model.init();
    }();
    
    // MARK: - 下标
    lazy var index:Int = {
        return 0;
    }();
    
    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_PictureVideo_Cell.PictureVideo_Model,row:Int){
        //赋值模型
        self.model = dataModel;
        //赋值下标
        self.index = row;
        //赋值图片
        //判断类型
        switch model.type {
        case .video://视频
            imageView.image = model.localImage ?? UIImage.init(named: "public_ImageLoading");
            imageView.setCornerImage();
            type_ImageView.isHidden = false;
            if model.source == .network{
                mask_ImageView.isHidden = false;
            }else{
                mask_ImageView.isHidden = true;
            }
            break;
        case .picture://图片
            switch model.source {
            case .network://网络数据
                imageView.setImageUrlWithPlaceholderImage_CornerImage(model.imageUrlString, "public_ImageLoading");
                mask_ImageView.isHidden = false;
                type_ImageView.isHidden = true;
                break;
            case .local://本地数据
                imageView.image = model.localImage ?? UIImage.init(named: "public_ImageLoading");
                imageView.setCornerImage();
                mask_ImageView.isHidden = true;
                type_ImageView.isHidden = true;
                break;
            }
            break;
        }
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
    @objc func imageView_Touch(){
        //点击代理事件
        delegate?.YHForm_PictureVideo_Cell_List_PictureVideo_Cell_Delegate_Touch?(index: self.index);
    }
    
    // MARK: - 删除点击事件
    @objc func remove_Button_Touch(){
        //删除点击代理事件
        delegate?.YHForm_PictureVideo_Cell_List_PictureVideo_Cell_Delegate_Remove?(index: self.index);
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
}
