//
//  YHForm_ImageJump_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2022/5/7.
//  Copyright © 2022 HeNanYiZhong. All rights reserved.
//

import UIKit

class YHForm_ImageJump_Cell: UITableViewCell {

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
        //加载容器视图
        self.contentView.addSubview(content_View);
    }
    
    // MARK: - 标题
    lazy var title_Label:UILabel = {
        let label = UILabel.init(frame: CGRect(x: UIMargin_Float, y: 0, width: APP_WIDTH-UIMargin_Float*2, height: Form_DefaultCellHeight));
        return label;
    }();
    
    // MARK: - 容器视图
    lazy var content_View:UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: Form_DefaultCellHeight, width: APP_WIDTH, height:APP_WIDTH/4));
        view.backgroundColor = .white;
        return view;
    }();
    
    // MARK: - 数据
    lazy var model:YHForm_ImageJump_Model = {
        return YHForm_ImageJump_Model();
    }();
    
    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_ImageJump_Model){
        //赋值模型
        self.model = dataModel;
        //赋值标题
        self.title_Label.attributedText = model.attTitle;
        //更新容器视图高度
        self.content_View.frame.size.height = model.cellHeight-Form_DefaultCellHeight;
        //清空所有元素
        for element in self.content_View.subviews{
            element.removeFromSuperview();
        }
        //创建元素
        switch model.images.count {
        case 0://空
            break;
        case 1://单个居中
            for element in model.images{
                self.content_View.addSubview(CreateElement(origin: CGPoint(x: APP_WIDTH/4*1.5, y: 0), imageName:element.imageName ?? "yh_Public_Clear", title: element.title ?? "未知类型", touchID: element.touchID));
            }
            break;
        case 2://两个居中
            var index = 1;
            for element in model.images{
                self.content_View.addSubview(CreateElement(origin: CGPoint(x: APP_WIDTH/4*CGFloat(index), y: 0), imageName:element.imageName ?? "yh_Public_Clear", title: element.title ?? "未知类型", touchID: element.touchID));
                index = index+1;
            }
            break;
        case 3://三个居中
            var index = 0;
            for element in model.images{
                self.content_View.addSubview(CreateElement(origin: CGPoint(x: APP_WIDTH/8+APP_WIDTH/4*CGFloat(index), y: 0), imageName:element.imageName ?? "yh_Public_Clear", title: element.title ?? "未知类型", touchID: element.touchID));
                index = index+1;
            }
            break;
        default://多个
            var index = 0;
            for element in model.images{
                self.content_View.addSubview(CreateElement(origin: CGPoint(x: APP_WIDTH/4*CGFloat(index%4), y: APP_WIDTH/4*CGFloat(index/4)), imageName:element.imageName ?? "yh_Public_Clear", title: element.title ?? "未知类型", touchID: element.touchID));
                index = index+1;
            }
            break;
        }
        
    }
    
    // MARK: - 元素点击事件
    @objc func elemetTouch(tap:UITapGestureRecognizer){
        //循环模型
        for item in self.model.images{
            //找到点击的那个类型
            if item.touchID == tap.view?.touch_Index ?? 0 {
                //判断是否有关联ID
                if self.model.relationId?.count ?? 0 <= 0 {
                    hud_only.show_Text_AutoDisappear(text: "没有获取到关联ID,无法跳转(注：如新增非事故车标书需要先暂存才可以提交图片)", view: UIFactory.shared.CurrentController().view);
                    return;
                }
                //判断需要跳转的页面
                if item.isPending {
                    //跳转到审核页面
                    let pending_Image_ViewController = Home_Pending_Image_ViewController.init();
                    pending_Image_ViewController.relationId = model.relationId ?? "";
                    pending_Image_ViewController.additionalParams = model.additionalParams;
                    UIFactory.shared.CurrentController().navigationController?.pushViewController(pending_Image_ViewController, animated: true);
                }else{
                    //创建图片上传模型并跳转
                    let imConfig = Public_ImageUpLoad_ConfigModel();
                    imConfig.relationId = self.model.relationId ?? "";
                    imConfig.jumpType = self.model.jumpType;
                    imConfig.nav_title = item.title ?? "图片上传";
                    imConfig.additionalParams = self.model.additionalParams;
                    for element in item.typeArray{
                        let imagesModel = Public_ImageUpLoad_Image_Array_Model.init();
                        imagesModel.title = element["title"];
                        imagesModel.type = element["type"];
                        if element["isCarWatermark"] == "1"{
                            imagesModel.isCarWatermark = true;
                        }else{
                            imagesModel.isCarWatermark = false;
                        }
                        imagesModel.relationId = self.model.relationId ?? "";
                        imConfig.images.append(imagesModel);
                    }
                    let imageUploadController = Home_Public_ImageUpload_ViewController.init();
                    imageUploadController.config = imConfig;
                    UIFactory.shared.CurrentController().navigationController?.pushViewController(imageUploadController, animated: true);
                }
                
            }
        }
    }
    
    // MARK: - 创建元素
    func CreateElement(origin:CGPoint,imageName:String,title:String,touchID:Int) -> UIView{
        let view = UIView.init(frame: CGRect(x: origin.x, y: origin.y, width: APP_WIDTH/4, height: APP_WIDTH/4));
        //图片
        let imageview = UIImageView.init(frame: CGRect(x: view.frame.size.width/7*1.5, y: 0, width: view.frame.size.width/7*4, height: view.frame.size.width/7*4));
        imageview.image = UIImage.init(named: imageName);
        imageview.touch_Index = touchID;
        imageview.isUserInteractionEnabled = true;
        imageview.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(elemetTouch)));
        view.addSubview(imageview);
        //底部标题
        let label = UILabel.init(frame: CGRect(x: 0, y:view.frame.size.width/5*3, width:view.frame.size.width, height: view.frame.size.width/5*1.5));
        label.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 14));
        label.textAlignment = .center;
        label.textColor = Black_Text_Color;
        label.text = title;
        label.numberOfLines = 0;
        label.adjustsFontSizeToFitWidth = true;
        view.addSubview(label);
        return view;
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
