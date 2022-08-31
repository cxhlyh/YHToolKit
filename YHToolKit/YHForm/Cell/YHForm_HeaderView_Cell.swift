//
//  YHForm_HeaderView_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/9.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//

import UIKit

class YHForm_HeaderView_Cell: UITableViewHeaderFooterView {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier);
        //设置背景颜色
        self.contentView.backgroundColor = Grey_BackGround_Color;
        //加载分组视图容器视图
        self.contentView.addSubview(content_View);
        //加载标题控件
        self.contentView.addSubview(title_Label);
        
    }
    
    // MARK: - 标题控件
    lazy var title_Label:UILabel = {
        let label = UILabel.init(frame: CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: Form_DefaultCellHeight));
        label.numberOfLines = 0;
        label.isHidden = true;
        return label;
    }();
    
    // MARK: - 分组视图容器视图
    lazy var content_View:UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
        view.backgroundColor = Grey_BackGround_Color;
        view.isHidden = true;
        return view;
    }();
    
    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_Section_Model){
        //清理视图容器视图下所有子视图
        content_View.subviews.forEach({$0.removeFromSuperview()});
        //判断是否有视图
        if dataModel.sectionView == nil{
            //展示标题
            title_Label.isHidden = false;
            content_View.isHidden = true;
            //赋值标题
            title_Label.attributedText = dataModel.sectionAttTitle;
        }else{
            //展示视图
            title_Label.isHidden = true;
            content_View.isHidden = false;
            //赋值标题
            title_Label.attributedText = "".toAttText_Black();
            //修改容器视图高度
            content_View.frame.size.height = (dataModel.sectionView ?? UIView.init()).frame.size.height;
            content_View.frame.size.width = (dataModel.sectionView ?? UIView.init()).frame.size.width;
            //赋值视图
            content_View.addSubview(dataModel.sectionView ?? UIView.init());
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }

}
