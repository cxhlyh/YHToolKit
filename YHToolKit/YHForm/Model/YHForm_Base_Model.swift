//
//  YHForm_Base_Model.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/10.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//

import UIKit


// MARK: - 表单基础模型
///表单基础模型
class YHForm_Base_Model: NSObject {
    ///cell高度 默认基础高度
    var cellHeight = Form_DefaultCellHeight;
    ///表单类型
    var formType = YHForm_Model_Type.none;
    ///富文本标题
    var attTitle = "".toAttText_Black();
    ///回显urlKey
    var showUrlKey = "";
    ///提交urlKey 如果提交key没有值，默认取回显key进行提交
    var submitUrlKey = "";
    ///idkey 用于查找到这个组件 默认值为 showUrlKey内容
    var idKey = "";
    ///底部提示富文本内容
    var bottom_TipsAttContent = "".toAttText_Black();
    ///底部提示富文本背景颜色 默认灰色
    var bottom_TipsAttBackGroundColor = Grey_BackGround_Color;
    ///附加参数
    var param:Any?;
    ///展示类型-默认正常展示
    var showType = YHForm_Show_Type.none;
    ///编辑类型
    var editType = YHForm_Edit_Type.optionalComplete;
    ///附加视图
    var additionalView = UIView.init();
    ///附加视图层级位置等级 默认标题下面
    var additionalViewPosition = YHForm_AdditionalViewPosition_Type.titleBottom;
    ///标题控件坐标
    var titleFrame = CGRect.init();
    ///内容控件坐标
    var contentFrame = CGRect.init();
    ///提示控件坐标
    var tipsFrame = CGRect.init();
}

// MARK: - 表单分组模型
///表单分组模型
class YHForm_Section_Model: NSObject {
    ///分组标题
    var sectionAttTitle = "".toAttText_Black();
    ///分组视图
    var sectionView:UIView?;
    ///元素模型组
    var elements = [YHForm_Base_Model]();
}

// MARK: - 拓展表单基类
extension YHForm_Base_Model{
    // MARK: - 表单模型类型
    enum YHForm_Model_Type {
        ///无类型
        case none;
        ///单行输入框类型
        case textField;
        ///多行输入框类型
        case textView;
        ///选择类型
        case select;
        ///图片视频类型
        case pictureVideo;
        ///文件类型
        case file;
        ///图片跳转展示类
        case imageJump;
        ///页面直接选择类型
        case directSelect;
        ///星级评分类型
        case starRating;
        ///提示类型
        case tips;
    }

    // MARK: - 表单编辑类型
    enum YHForm_Edit_Type {
        ///必填
        case mustComplete;
        ///非必填
        case optionalComplete;
        ///不可填写
        case prohibitComplete;
    }

    // MARK: - 表单展示类型
    enum YHForm_Show_Type{
        ///正常类型
        case none;
        ///仅查看类型
        case look;
    }
    
    // MARK: - 表单附加视图位置类型
    enum YHForm_AdditionalViewPosition_Type{
        ///标题下面
        case titleBottom;
    }
    
    // MARK: - 指定为单行输入类型
    ///指定为单行输入类型
    func appoint_TextFieldModel() ->YHForm_TextField_Model{
        return (self as? YHForm_TextField_Model) ?? YHForm_TextField_Model.init();
    }
    
    // MARK: - 指定为选择类型
    ///指定为选择类型
    func appoint_SelectModel() ->YHForm_Select_Model{
        return (self as? YHForm_Select_Model) ?? YHForm_Select_Model.init();
    }
    
    // MARK: - 指定为多行输入类型
    ///指定为多行输入类型
    func appoint_TextViewModel() ->YHForm_TextView_Model{
        return (self as? YHForm_TextView_Model) ?? YHForm_TextView_Model.init();
    }
    
    // MARK: - 指定为图片视频类型
    ///指定为图片视频类型
    func appoint_PictureVideoModel() ->YHForm_PictureVideo_Model{
        return (self as? YHForm_PictureVideo_Model) ?? YHForm_PictureVideo_Model.init();
    }
    
    // MARK: - 指定为文件类型
    ///指定为文件类型
    func appoint_FileModel() ->YHForm_File_Model{
        return (self as? YHForm_File_Model) ?? YHForm_File_Model.init();
    }
    
    // MARK: - 指定为图片跳转类型
    ///指定为图片跳转类型
    func appoint_ImageJumpModel() ->YHForm_ImageJump_Model{
        return (self as? YHForm_ImageJump_Model) ?? YHForm_ImageJump_Model.init();
    }
    
    // MARK: - 指定为页面直接选择类型
    ///指定为页面直接选择类型
    func appoint_DirectSelectModel() ->YHForm_DirectSelect_Model{
        return (self as? YHForm_DirectSelect_Model) ?? YHForm_DirectSelect_Model.init();
    }
    
    // MARK: - 指定为星级评分类型
    ///指定为星级评分类型
    func appoint_StarRatingModel() ->YHForm_StarRating_Model{
        return (self as? YHForm_StarRating_Model) ?? YHForm_StarRating_Model.init();
    }
    
    // MARK: - 指定为提示类型
    ///指定为提示类型
    func appoint_TipsModel() ->YHForm_Tips_Model{
        return (self as? YHForm_Tips_Model) ?? YHForm_Tips_Model.init();
    }
    
    
    
}

//**********************具体表单模型****************************//

// MARK: - 表单-单行输入类型
class YHForm_TextField_Model:YHForm_Base_Model{
    //初始化
    override init() {
        super.init();
        //赋值类型
        formType = .textField;
    }
    ///提示富文本
    var attPlaceholder = "请输入".toAttText_Grey();
    ///输入文本
    var content:String?;
    ///输入限制
    var limitModel = YHForm_TextField_Cell.inputLimit_None_Model.init();

    ///拓展类型 默认无拓展
    var extensionType = ExtensionType.none;
    ///拓展-扫码类型
    var scanCodeType = YHForm_Extension_ScanCode_ViewController.ScanCodeType.blend;
}

// MARK: - 表单-选择类型
class YHForm_Select_Model:YHForm_Base_Model{
    //初始化
    override init() {
        super.init();
        //赋值类型
        formType = .select;
    }
    ///选择项名称
    var content:String?;
    ///选择项ID
    var contentID:String?;
    ///选择提示
    var contentTips = "请选择";
    ///是否在查看模式下强制展示右侧点击提示箭头
    var mandatoryDisplayTipsImage = false;
    ///选择项数据 - 默认为正常数据选择
    var data:YHForm_Select_Cell.SelectData_Base_Model = YHForm_Select_Cell.SelectData_None_Model.init();
}


// MARK: - 表单-多行输入类型
class YHForm_TextView_Model:YHForm_Base_Model{
    //初始化
    override init() {
        super.init();
        //赋值类型
        formType = .textView;
    }
    ///提示富文本
    var attPlaceholder = "请输入".toAttText_Grey();
    ///输入文本
    var content:String?;
    ///输入限制
    var limitModel = YHForm_TextField_Cell.inputLimit_None_Model.init();
}


// MARK: - 表单-图片视频类型
class YHForm_PictureVideo_Model:YHForm_Base_Model{
    //初始化
    override init() {
        super.init();
        //赋值类型
        formType = .pictureVideo;
    }
    ///图片视频数据
    var data = [YHForm_PictureVideo_Cell.PictureVideo_Model]();
    ///最大图片数量限制
    var maxImage:Int = 999;
    ///最小图片数量限制
    var minImage:Int = 0;
    ///数据类型 - 默认类型单图片
    var type = dataType.picture;
    ///数据来源 - 默认混合
    var source = dataSource.blend;
    ///是否允许选择原图 - 默认不允许选原图
    var isOriginal = false;
}

// MARK: - 表单-文件类型
class YHForm_File_Model:YHForm_Base_Model{
    //初始化
    override init() {
        super.init();
        //赋值类型
        formType = .file;
    }
    ///文件数据
    var data = [YHForm_File_Cell.File_Model]();
    ///最大文件数量限制
    var maxFile:Int = 999;
    ///最小文件数量限制
    var minFile:Int = 0;
    ///支持的文件类型组
    var types = [YHForm_File_Cell.fileType]();
}

// MARK: - 表单-图片跳转类型(注：此类型后续需要删除,目前只做兼容使用)
class YHForm_ImageJump_Model:YHForm_Base_Model{
    //初始化
    override init() {
        super.init();
        //赋值类型
        formType = .imageJump;
        //赋值默认编辑类型
        editType = .prohibitComplete;
    }
    ///关联ID
    var relationId:String?;
    ///附加参数字典
    var additionalParams = [String:String]();
    ///跳转图片详细模型
    var images = [Public_ImageJump_Model]();
    ///跳转类型 默认为查看模式
    var jumpType = Home_Public_ImageUpload_ViewController_JumpType.look;
}

// MARK: - 表单-页面直接选择类型
class YHForm_DirectSelect_Model:YHForm_Base_Model{
    //初始化
    override init() {
        super.init();
        //赋值类型
        formType = .directSelect;
    }
    ///选中项
    var contentArray = [String]();
    ///是否支持多选 - 默认单选
    var multipleSelection = false;
    ///数据源
    var data = [YHForm_DirectSelect_Element_Model]();
}

// MARK: - 表单-星级评分类型
class YHForm_StarRating_Model:YHForm_Base_Model{
    //初始化
    override init() {
        super.init();
        //赋值类型
        formType = .starRating;
    }
    ///评分等级
    var content:String?;
    ///最高等级
    var maxRating = 5;
}

// MARK: - 表单-提示类型
class YHForm_Tips_Model:YHForm_Base_Model{
    //初始化
    override init() {
        super.init();
        //赋值类型
        formType = .tips;
    }
    ///强制占位，不展示文本 高度为Form_CommonlyGap
    var forcedOccupancy = false;
    ///背景颜色
    var backGroundColor = Grey_BackGround_Color;
    ///对齐方式 默认左对齐
    var textAlignment = NSTextAlignment.left;

}

//*****************************拓展********************************//

// MARK: - 拓展表单图片视频类
extension YHForm_PictureVideo_Model{
    ///数据类型 - 主要作用于选择的时候过滤图片或视频，回显的时候不论类型都会回显
    enum dataType {
        ///单图片
        case picture;
        ///单视频
        case video;
        ///混合
        case blend;
    }
    
    ///数据来源 - 主要作用于选择的时候过滤是拍照还是选择相册
    enum dataSource {
        ///相册
        case album;
        ///拍照
        case photograph;
        ///混合
        case blend;
    }

}


// MARK: - 拓展表单文件类
extension YHForm_File_Model{
    ///文件类型 - 主要作用于选择的时候过滤不需要展示的类型
    enum fileType {
        ///pdf格式
        case pdf;
        ///word文档格式
        case word;
    }
}


// MARK: - 拓展单行输入类
extension YHForm_TextField_Model{
    
    ///拓展类型
    enum ExtensionType {
        ///无
        case none;
        ///扫码
        case scanCode;
    }
    
}


// MARK: - 拓展页面直接选择类
extension YHForm_DirectSelect_Model{
    
    // MARK: - 页面直接选择类-元素模型
    class YHForm_DirectSelect_Element_Model:NSObject{
        ///选择项名称
        var elementName:String?;
        ///选择项ID
        var elementID:String?;
        ///附加参数
        var param:Any?;
        ///选项高度
        var elementHeight:CGFloat = 0;
    }
    
}
