//
//  YHForm_StarRating_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2022/6/23.
//  Copyright © 2022 HeNanYiZhong. All rights reserved.
//

import UIKit

class YHForm_StarRating_Cell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

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
        self.contentView.addSubview(list_CollectionView);
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
    
    // MARK: - 列表视图
    lazy var list_CollectionView:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = Form_CommonlyGap/2;
        flowLayout.scrollDirection = .horizontal;
        let collectionView = UICollectionView.init(frame: CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height:Form_DefaultCellHeight*0.5),collectionViewLayout:flowLayout);
        collectionView.backgroundColor = .white;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsHorizontalScrollIndicator = false;
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.register(YHForm_StarRating_Cell_Element_Cell.classForCoder(), forCellWithReuseIdentifier: "YHForm_StarRating_Cell_Element_Cell_ID");
        return collectionView;
    }();
  
    // MARK: - cell个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.maxRating;
    }
    
    // MARK: - cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Form_DefaultCellHeight*0.5, height: Form_DefaultCellHeight*0.5);
    }
    
    // MARK: - cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "YHForm_StarRating_Cell_Element_Cell_ID", for: indexPath) as? YHForm_StarRating_Cell_Element_Cell) ?? YHForm_StarRating_Cell_Element_Cell.init();
        cell.update_UI(isSelect: (Int(model.content ?? "0") ?? 0) >= indexPath.row+1);
        return cell;
    }
    
    // MARK: - cell点击事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if model.showType == .none && (model.editType == .mustComplete || model.editType == .optionalComplete){
            self.model.content = String(indexPath.row+1);
            self.list_CollectionView.reloadData();
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
    lazy var model:YHForm_StarRating_Model = {
        return YHForm_StarRating_Model();
    }();
    
    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_StarRating_Model){
        //赋值模型
        self.model = dataModel;
        //判断编辑类型
        YHForm.calculation_Cell_EditTypeTipsImageView_Style(showType: model.showType, editType: model.editType, imageView: self.editType_TipsImageView);
        //赋值富文本标题
        self.title_Label.attributedText = model.attTitle;
        //赋值控件坐标
        self.title_Label.frame = model.titleFrame;
        self.list_CollectionView.frame.origin.y = model.contentFrame.origin.y+Form_DefaultCellHeight*0.1;
        //处理提示视图
        self.handleTipsView();
        self.list_CollectionView.reloadData();
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
extension YHForm_StarRating_Cell{
    
    class YHForm_StarRating_Cell_Element_Cell:UICollectionViewCell{
        
        override init(frame: CGRect) {
            super.init(frame: frame);
            //加载内容图片
            self.contentView.addSubview(contentImageView);
        }
        
        // MARK: - 内容图片
        lazy var contentImageView:UIImageView = {
            let iv = UIImageView.init(frame: CGRect(x: 0, y: 0, width: Form_DefaultCellHeight*0.5, height: Form_DefaultCellHeight*0.5));
            return iv;
        }();
        
        // MARK: - 更新UI
        func update_UI(isSelect:Bool){
            if isSelect{
                contentImageView.image = UIImage.init(named: "YHForm_StarRating_True");
            }else{
                contentImageView.image = UIImage.init(named: "YHForm_StarRating_False");
            }
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder);
        }
    }
    
}

