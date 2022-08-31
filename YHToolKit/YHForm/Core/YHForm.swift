//
//  YHForm.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/9.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//

import UIKit
import Moya
import AVFoundation
import BRPickerView

// MARK: - 代理
@objc protocol YHForm_Delegate:NSObjectProtocol{
    ///选择框没有数据
    @objc optional func YHForm_Delegate_Select_WillShow_NoData(title:String,complete:((Bool)->())?);
    ///选择框选中或取消
    @objc optional func YHForm_Delegate_Select_Select(title:String);
    ///选择框不可选择的点击事件
    @objc optional func YHForm_Delegate_Select_Touch(title:String);
    ///单行输入框内容因输入发生变动事件
    @objc optional func YHForm_Delegate_TextField_Changed(title:String);
    ///单行输入框内容获取最新的正则校验不合规提示文本
    @objc optional func YHForm_Delegate_TextField_InputLimitUnqualifiedTipsAttString(title:String) ->NSMutableAttributedString?;
    ///图片视频选择内容发生变动事件-(删除｜添加)
    @objc optional func YHForm_Delegate_PictureVideo_Changed(title:String);
    ///图片视频选择内容发生变动事件-添加
    @objc optional func YHForm_Delegate_PictureVideo_Add_Changed(title:String);
    ///列表开始滑动事件
    @objc optional func YHForm_Delegate_ScrollViewWillBeginDragging(tableView:YHForm);
    ///列表滑动事件
    @objc optional func YHForm_Delegate_ScrollViewDidScroll(tableView:YHForm);
    
}

class YHForm: UITableView,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,YHForm_TextField_Cell_Delegate,YHForm_Select_Cell_Delegate,YHForm_TextView_Cell_Delegate,YHForm_PictureVideo_Cell_Delegate,YHForm_File_Cell_Delegate {

    ///代理
    weak var formDelegate:YHForm_Delegate?;
    ///是否允许手势穿透 - 默认禁止穿透
    var formSimultaneousGestureRecognition = false;
    
    // MARK: - 初始化表单对象
    class func initWithIdentifier(frame: CGRect,identifier:String) -> YHForm{
        //初始化表单列表
        let tableView = YHForm.init(frame: frame, style: .grouped);
        //赋值标识符
        tableView.identifier = identifier;
        tableView.register(YHForm_None_Cell.classForCoder(), forCellReuseIdentifier: "YHForm_None_Cell_ID_"+tableView.identifier);
        tableView.register(YHForm_HeaderView_Cell.classForCoder(), forHeaderFooterViewReuseIdentifier: "YHForm_HeaderView_Cell_ID_"+tableView.identifier);
        tableView.register(YHForm_FooterView_Cell.classForCoder(), forHeaderFooterViewReuseIdentifier: "YHForm_FooterView_Cell_ID_"+tableView.identifier);
        return tableView;
    }
    
    // MARK: - 默认cell标示符
    ///默认cell标示符
    lazy var identifier:String = {
        return "none";
    }();
    
    
    // MARK: - 重载列表初始化
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style);
        //设置代理
        self.delegate = self;
        self.dataSource = self;
    }
    
    // MARK: - 是否允许手势穿透
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return formSimultaneousGestureRecognition;
    }
    
    // MARK: - 列表刷新
    override func reloadData() {
        //计算所有控件坐标
        self.calculation_AllCellFrame(sectionModels: self.sectionModels);
        //刷新
        super.reloadData();
    }
    
    // MARK: - 分组cell头部视图高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sectionModels[section].sectionView == nil{
            if sectionModels[section].sectionAttTitle.length > 0{
                return Form_DefaultCellHeight;
            }else{
                if section == 0{
                    return MinLine_PX;
                }else{
                    //判断上一组的最后一个组件类型
                    switch sectionModels[section-1].elements.last?.formType {
                    case .textField://输入类型
                        if sectionModels[section-1].elements.last?.appoint_TextFieldModel().limitModel.bottomLimitTipsFrame.size.height ?? 0 > 0{
                            return 0.1;
                        }
                        if sectionModels[section-1].elements.last?.tipsFrame.size.height ?? 0 > 0 && sectionModels[section-1].elements.last?.bottom_TipsAttBackGroundColor == Grey_BackGround_Color{
                            return 0.1;
                        }
                        break;
                    case .tips://提示文本类型
                        if sectionModels[section-1].elements.last?.appoint_TipsModel().cellHeight ?? 0 > 0 && sectionModels[section-1].elements.last?.appoint_TipsModel().backGroundColor == Grey_BackGround_Color{
                            return 0.1;
                        }
                        break;
                    default:
                        if sectionModels[section-1].elements.last?.tipsFrame.size.height ?? 0 > 0 && sectionModels[section-1].elements.last?.bottom_TipsAttBackGroundColor == Grey_BackGround_Color{
                            return 0.1;
                        }
                        break;
                    }
                }
                return Form_CommonlyGap;
            }
        }else{
            return (sectionModels[section].sectionView ?? UIView.init()).frame.size.height;
        }
    }
    
    // MARK: - 分组cell底部视图高度
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return MinLine_PX;
    }
    
    // MARK: - 分组cell头部视图
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = (tableView.dequeueReusableHeaderFooterView(withIdentifier: "YHForm_HeaderView_Cell_ID_"+identifier) as? YHForm_HeaderView_Cell) ?? YHForm_HeaderView_Cell.init(reuseIdentifier: "YHForm_HeaderView_Cell_ID_"+identifier);
        view.update_UI(dataModel: sectionModels[section]);
        return view;
    }
    
    // MARK: - 分组cell底部视图
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = (tableView.dequeueReusableHeaderFooterView(withIdentifier: "YHForm_FooterView_Cell_ID_"+identifier) as? YHForm_FooterView_Cell) ?? YHForm_FooterView_Cell.init(reuseIdentifier: "YHForm_FooterView_Cell_ID_"+identifier);
        return view;
    }
    
    // MARK: - cell组数
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionModels.count;
    }
    
    // MARK: - 每组cell数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionModels[section].elements.count;
    }
    
    // MARK: - cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sectionModels[indexPath.section].elements[indexPath.row].cellHeight;
    }
    
    // MARK: - cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //根据表单类型展示相应Cell
        switch sectionModels[indexPath.section].elements[indexPath.row].formType {
        case .textField://单行输入类型
            let cell = ((tableView.dequeueReusableCell(withIdentifier: "YHForm_TextField_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row))) as? YHForm_TextField_Cell) ?? YHForm_TextField_Cell.init(style: .default, reuseIdentifier: "YHForm_TextField_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row));
            //设置代理
            cell.delegate = self;
            //更新Cell
            cell.update_UI(dataModel: sectionModels[indexPath.section].elements[indexPath.row].appoint_TextFieldModel());
            return cell;
        case .select://选择类型
            let cell = ((tableView.dequeueReusableCell(withIdentifier: "YHForm_Select_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row))) as? YHForm_Select_Cell) ?? YHForm_Select_Cell.init(style: .default, reuseIdentifier: "YHForm_Select_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row));
            cell.delegate = self;
            //更新Cell
            cell.update_UI(dataModel: sectionModels[indexPath.section].elements[indexPath.row].appoint_SelectModel());
            return cell;
        case .textView://多行输入类型
            let cell = ((tableView.dequeueReusableCell(withIdentifier: "YHForm_TextView_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row))) as? YHForm_TextView_Cell) ?? YHForm_TextView_Cell.init(style: .default, reuseIdentifier: "YHForm_TextView_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row));
            cell.delegate = self;
            //更新Cell
            cell.update_UI(dataModel: sectionModels[indexPath.section].elements[indexPath.row].appoint_TextViewModel());
            return cell;
        case .pictureVideo://图片视频类型
            let cell = ((tableView.dequeueReusableCell(withIdentifier: "YHForm_PictureVideo_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row))) as? YHForm_PictureVideo_Cell) ?? YHForm_PictureVideo_Cell.init(style: .default, reuseIdentifier: "YHForm_PictureVideo_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row));
            cell.delegate = self;
            //更新Cell
            cell.update_UI(dataModel: sectionModels[indexPath.section].elements[indexPath.row].appoint_PictureVideoModel());
            return cell;
        case .file://文件类型
            let cell = ((tableView.dequeueReusableCell(withIdentifier: "YHForm_File_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row))) as? YHForm_File_Cell) ?? YHForm_File_Cell.init(style: .default, reuseIdentifier: "YHForm_File_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row));
            cell.delegate = self;
            //更新Cell
            cell.update_UI(dataModel: sectionModels[indexPath.section].elements[indexPath.row].appoint_FileModel());
            return cell;
        case .imageJump://图片跳转类型
            let cell = ((tableView.dequeueReusableCell(withIdentifier: "YHForm_ImageJump_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row))) as? YHForm_ImageJump_Cell) ?? YHForm_ImageJump_Cell.init(style: .default, reuseIdentifier: "YHForm_ImageJump_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row));
            //更新Cell
            cell.update_UI(dataModel: sectionModels[indexPath.section].elements[indexPath.row].appoint_ImageJumpModel());
            return cell;
        case .directSelect://页面直接选择类型
            let cell = ((tableView.dequeueReusableCell(withIdentifier: "YHForm_DirectSelect_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row))) as? YHForm_DirectSelect_Cell) ?? YHForm_DirectSelect_Cell.init(style: .default, reuseIdentifier: "YHForm_DirectSelect_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row));
            //更新Cell
            cell.update_UI(dataModel: sectionModels[indexPath.section].elements[indexPath.row].appoint_DirectSelectModel());
            return cell;
        case .starRating://星级评分类型
            let cell = ((tableView.dequeueReusableCell(withIdentifier: "YHForm_StarRating_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row))) as? YHForm_StarRating_Cell) ?? YHForm_StarRating_Cell.init(style: .default, reuseIdentifier: "YHForm_StarRating_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row));
            //更新Cell
            cell.update_UI(dataModel: sectionModels[indexPath.section].elements[indexPath.row].appoint_StarRatingModel());
            return cell;
        case .tips://提示类型
            let cell = ((tableView.dequeueReusableCell(withIdentifier: "YHForm_Tips_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row))) as? YHForm_Tips_Cell) ?? YHForm_Tips_Cell.init(style: .default, reuseIdentifier: "YHForm_Tips_Cell_ID_"+self.identifier+String(indexPath.section)+String(indexPath.row));
            //更新Cell
            cell.update_UI(dataModel: sectionModels[indexPath.section].elements[indexPath.row].appoint_TipsModel());
            return cell;
        default://无类型
            let cell = (tableView.dequeueReusableCell(withIdentifier: "YHForm_None_Cell_ID_"+self.identifier, for: indexPath) as? YHForm_None_Cell) ?? YHForm_None_Cell.init();
            return cell;
        }
    }
    
    // MARK: - 列表开始滑动
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //发送代理
        self.formDelegate?.YHForm_Delegate_ScrollViewWillBeginDragging?(tableView: self);
    }
    
    // MARK: - 列表滑动事件
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //发送代理
        self.formDelegate?.YHForm_Delegate_ScrollViewDidScroll?(tableView: self);
    }
    
    // MARK: - 单行输入框代理-输入框需要进行正则校验并处理是否展示底部不合规提示
    func YHForm_TextField_Cell_Delegate_InputLimitResultChanged(title: String, idKey: String) {
        //计算此项最新坐标高度坐标等数据
        self.calculation_Frame_TextFieldModel(tfModel: self.seek_WithIDKey(idKey: idKey).appoint_TextFieldModel());
        //刷新高度
        self.performBatchUpdates(nil, completion: nil);
    }
    
    // MARK: - 单行输入框代理-输入框内容发生变化
    func YHForm_TextField_Cell_Delegate_Changed(title: String) {
        //发送代理通知
        self.formDelegate?.YHForm_Delegate_TextField_Changed?(title: title);
    }
    
    // MARK: - 单行输入框代理-输入框结束编辑
    func YHForm_TextField_Cell_Delegate_EndEditing(title: String) {
        
    }
    
    // MARK: - 多行输入框代理-输入框内容发生变化
    func YHForm_TextView_Cell_Delegate_Changed(title: String) {
      
    }
    
    // MARK: - 多行输入框代理-输入框结束编辑
    func YHForm_TextView_Cell_Delegate_EndEditing(title: String) {
        //刷新列表 - 需要改变组件大小
        self.reloadData();
    }
    
    // MARK: - 选择框不可选择的点击事件
    func YHForm_Select_Cell_Delegate_Touch(title: String) {
        //发送代理
        formDelegate?.YHForm_Delegate_Select_Touch?(title: title);
    }
    
    // MARK: - 选择框点击了确定
    func YHForm_Select_Cell_Delegate_Select(title: String) {
        //刷新列表 - 需要改变组件大小
        self.reloadData();
        //发送代理
        formDelegate?.YHForm_Delegate_Select_Select?(title: title);
    }
    
    // MARK: - 时间选择获取时间关联限制
    func YHForm_Select_Cell_Delegate_GetRelationTime(idKey: String) -> Date? {
        return (self.seek_WithIDKey(idKey: idKey).appoint_SelectModel().content ?? "").yh_ConvertDate();
    }
    
    
    // MARK: - 选择框将要出现却没有数据
    func YHForm_Select_Cell_Delegate_WillShow_NoData(title: String, complete: ((Bool) -> ())?) {
        //发送代理
        formDelegate?.YHForm_Delegate_Select_WillShow_NoData?(title: title, complete: complete);
    }
    
    // MARK: - 图片选择类型发生变更
    func YHForm_PictureVideo_Cell_Delegate_Update(title: String) {
        //刷新列表 - 需要改变组件大小
        self.reloadData();
        //发送代理
        formDelegate?.YHForm_Delegate_PictureVideo_Changed?(title: title);
    }
    
    // MARK: - 图片选择类型发生变更-来源-添加
    func YHForm_PictureVideo_Cell_Delegate_AddUpdate(title: String) {
        //发送代理
        formDelegate?.YHForm_Delegate_PictureVideo_Add_Changed?(title: title);
    }
    
    // MARK: - 文件类型发生变更
    func YHForm_File_Cell_Delegate_Update(title: String) {
        //刷新列表 - 需要改变组件大小
        self.reloadData();
    }
    
//**********************数据配置及处理************************//
    
    // MARK: - 表单配置模型
    lazy var sectionModels:[YHForm_Section_Model] = {
        return [YHForm_Section_Model]();
    }();
    
    
    // MARK: - 校验模型是否符合要求-全部
    ///校验模型是否符合要求-全部
    func validationModel_All()->(isCorrect:Bool,errorTips:String){
        //循环分组
        for sectionModel in sectionModels {
            //循环元素
            for element in sectionModel.elements {
                //判断元素类型
                switch element.formType {
                case .textField://单行输入类型
                    let result = validationModel_TextFieldModel(textFieldModel: element.appoint_TextFieldModel());
                    if result.isCorrect == false {
                        return result;
                    }
                    break;
                case .select://选择类型
                    let result = validationModel_SelectModel(selectModel: element.appoint_SelectModel());
                    if result.isCorrect == false {
                        return result;
                    }
                    break;
                case .textView://多行输入类型
                    let result = validationModel_TextViewModel(textViewModel: element.appoint_TextViewModel());
                    if result.isCorrect == false {
                        return result;
                    }
                    break;
                case .pictureVideo://视频图片类型
                    let result = validationModel_PictureVideoModel(pictureVideoModel: element.appoint_PictureVideoModel());
                    if result.isCorrect == false {
                        return result;
                    }
                    break;
                case .file://文件类型
                    let result = validationModel_FileModel(fileModel: element.appoint_FileModel());
                    if result.isCorrect == false {
                        return result;
                    }
                    break;
                case .imageJump://图片跳转类型(无需校验)
                    break;
                case .directSelect://页面直接选择类型
                    let result = validationModel_DirectSelectModel(dataModel: element.appoint_DirectSelectModel());
                    if result.isCorrect == false {
                        return result;
                    }
                    break;
                case .starRating://星级评分类型
                    let result = validationModel_StarRatingModel(dataModel: element.appoint_StarRatingModel())
                    if result.isCorrect == false {
                        return result;
                    }
                    break;
                case .tips://提示类型(无需校验)
                    break;
                case .none://默认类型
                    return (false,"此单据拥有未知类型组件,请联系技术部处理");
                }
            }
        }
        return (true,"校验通过");
    }
    
    
    // MARK: - 组合提交数据-全部
    ///组合提交数据-全部 返回值: 字典
    func combinedSubmissionData_All(sectionModels:[YHForm_Section_Model]) ->(params:[String:String],formDatas:[Moya.MultipartFormData]){
        var params = [String:String]();
        var formDatas = [Moya.MultipartFormData]();
        //循环分组
        for sectionModel in sectionModels {
            //循环元素
            for element in sectionModel.elements {
                //判断元素类型
                switch element.formType {
                case .textField://单行输入类型
                    params.merge(dict: combinedSubmissionData_TextFieldModel(textFieldModel: element.appoint_TextFieldModel()));
                    break;
                case .textView://多行输入类型
                    params.merge(dict: combinedSubmissionData_TextViewModel(textViewModel: element.appoint_TextViewModel()));
                    break;
                case .select://选择类型
                    params.merge(dict: combinedSubmissionData_SelectModel(selectModel: element.appoint_SelectModel()));
                    break;
                case .pictureVideo://视频图片类型
                    let result = combinedSubmissionData_PictureVideoModel(pictureVideoModel: element.appoint_PictureVideoModel());
                    params.merge(dict: result.params);
                    formDatas = formDatas+result.formDatas;
                    break;
                case .file://文件类型
                    let result = combinedSubmissionData_FileModel(fileModel: element.appoint_FileModel());
                    params.merge(dict: result.params);
                    formDatas = formDatas+result.formDatas;
                    break;
                case .directSelect://页面直接选择类型
                    params.merge(dict: combinedSubmissionData_DirectSelectModel(dataModel: element.appoint_DirectSelectModel()));
                    break;
                case .starRating://星级评分类型
                    params.merge(dict: combinedSubmissionData_StarRatingModel(dataModel: element.appoint_StarRatingModel()));
                    break;
                case .imageJump://图片跳转类型(无需提交)
                    break;
                case .tips://提示类型(无需提交)
                    break;
                case .none://默认类型
                    break;
                }
            }
        }
        return (params,formDatas);
    }
    
    // MARK: - 填充模型以展示数据
    ///填充模型以展示数据
    func fillingModel_All(sectionModels:[YHForm_Section_Model],json:[String:Any]){
        //循环分组
        for sectionModel in sectionModels {
            //循环元素
            for element in sectionModel.elements {
                //判断元素类型
                switch element.formType {
                case .textField://单行输入类型
                    fillingModel_TextFieldModel(textFieldModel: element.appoint_TextFieldModel(), json: json);
                    break;
                case .textView://多行输入类型
                    fillingModel_TextViewModel(textViewModel: element.appoint_TextViewModel(), json: json);
                    break;
                case .select://选择类型
                    fillingModel_SelectModel(selectModel: element.appoint_SelectModel(), json: json);
                    break;
                case .pictureVideo://视频图片类型
                    fillingModel_PictureVideoModel(pictureVideoModel: element.appoint_PictureVideoModel(), json: json);
                    break;
                case .file://文件类型
                    fillingModel_FileModel(fileModel: element.appoint_FileModel(), json: json);
                    break;
                case .directSelect://页面直接选择类型
                    fillingModel_DirectSelectModel(dataModel: element.appoint_DirectSelectModel(), json: json);
                    break;
                case .starRating://评分类型
                    fillingModel_StarRatingModel(dataModel: element.appoint_StarRatingModel(), json: json);
                    break;
                case .imageJump://图片跳转类型(无需填充数据)
                    break;
                case .tips://提示类型(无需填充数据)
                    break;
                case .none://默认类型
                    break;
                }
            }
        }
        //填充完成,刷新列表
        self.reloadData();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }

    deinit {
        //页面销毁的时候要取消尚未完成的视频压缩动作
        DataHandle.shared.cancelVideoCompressed();
    }
}


// MARK: - 拓展表单
extension YHForm{
    
    // MARK: - 处理表单是否可以编辑
    ///处理表单是否可以编辑
    func modify_ShowType(sections:[YHForm_Section_Model],showType:YHForm_Base_Model.YHForm_Show_Type){
        for section in sections{
            section.elements.forEach { element in
                element.showType = showType;
            }
        }
    }
    
    // MARK: - 刷新单行或多行表单
    ///刷新单行或多行表单
    func reload_WithIDKeys(idKeys:[String]){
        var indexPaths = [IndexPath]();
        for idKey in idKeys{
            var indexPathSection:Int = 0;
            for section in self.sectionModels{
                var indexPathRow:Int = 0;
                for element in section.elements{
                    if element.attTitle.string == idKey{
                        indexPaths.append(IndexPath.init(row: indexPathRow, section: indexPathSection));
                    }
                    indexPathRow = indexPathRow+1;
                }
                indexPathSection = indexPathSection+1;
            }
        }
        self.reloadRows(at: indexPaths, with: .automatic);
    }
    
    
    // MARK: - 根据IDKey找到表单项
    func seek_WithIDKey(idKey:String) ->YHForm_Base_Model{
        for section in sectionModels{
            for element in section.elements{
                if element.idKey == idKey{
                    return element;
                }
            }
        }
        return YHForm_Base_Model.init();
    }
    
    // MARK: - 根据标题找到表单项 注(谨慎使用,要确保在当前表单中标题唯一时使用) 建议使用seek_WithIDKey
    ///根据标题找到表单项 注(谨慎使用,要确保在当前表单中标题唯一时使用) 建议使用seek_WithIDKey
    func seek_WithTile(title:String)->YHForm_Base_Model{
        for section in sectionModels{
            for element in section.elements{
                if element.attTitle.string == title{
                    return element;
                }
            }
        }
        return YHForm_Base_Model.init();
    }
    
    // MARK: - 根据IDKey删除表单项
    ///根据IDKey删除表单项
    func remove_WithIDKey(idKey:String){
        sectionModels.forEach { section in
            section.elements.removeAll { element in
                return element.idKey == idKey;
            }
        }
    }
    
    // MARK: - 在IDKey后面插入元素
    ///在IDKey后面插入元素
    func InsertAfter_WithIDKey(idKey:String,elementModel:YHForm_Base_Model){
        //判断是否已经有这个元素
        if sectionModels.contains(where: { section in
            return section.elements.contains(where: { element in
                return element.idKey == elementModel.idKey;
            })
        }){
            return;
        }
        //插入元素
        sectionModels.forEach { section in
            for (index,element) in section.elements.enumerated(){
                if element.idKey == idKey{
                    section.elements.insert(elementModel, at: index+1);
                }
            }
        }
    }
    
    
    // MARK: - 在sectionModel第一位插入元素
    ///在sectionModel第一位插入元素
    func InsertFirst_WithSectionModel(sectionModel:YHForm_Section_Model,elementModel:YHForm_Base_Model){
        //判断是否已经有这个元素
        if sectionModel.elements.contains(where: { element in
            return element.idKey == elementModel.idKey;
        }){
            return;
        }
        //插入元素
        sectionModel.elements.insert(elementModel, at: 0);
    }
    
    // MARK: - 校验模型是否符合要求-单行输入类型
    ///校验模型是否符合要求-单行输入类型
    func validationModel_TextFieldModel(textFieldModel:YHForm_TextField_Model)->(isCorrect:Bool,errorTips:String){
        //判断必填状态下是否有值
        if textFieldModel.editType == .mustComplete && textFieldModel.content?.count ?? 0 <= 0 {
            //没有值
            return (false,textFieldModel.attTitle.string+" - 不能为空,请填写");
        }
        //校验是否符合正则
        var completeRegular = textFieldModel.limitModel.completeRegular;
        if completeRegular.count <= 0 {
            completeRegular = textFieldModel.limitModel.InputChangeRegular;
        }
        if completeRegular.count >= 1 && textFieldModel.content?.isMatch(completeRegular) ?? true == false{
            //不符合正则
            return (false,textFieldModel.attTitle.string+" - 内容格式不符合,请修改正确后再次提交");
        }
        return (true,"校验通过");
    }
    
    // MARK: - 校验模型是否符合要求-多行输入类型
    ///校验模型是否符合要求-多行输入类型
    func validationModel_TextViewModel(textViewModel:YHForm_TextView_Model)->(isCorrect:Bool,errorTips:String){
        //判断必填状态下是否有值
        if textViewModel.editType == .mustComplete && textViewModel.content?.count ?? 0 <= 0 {
            //没有值
            return (false,textViewModel.attTitle.string+" - 不能为空,请填写");
        }
        //校验是否符合正则
        var completeRegular = textViewModel.limitModel.completeRegular;
        if completeRegular.count <= 0 {
            completeRegular = textViewModel.limitModel.InputChangeRegular;
        }
        if completeRegular.count >= 1 && textViewModel.content?.isMatch(completeRegular) ?? true == false{
            //不符合正则
            return (false,textViewModel.attTitle.string+" - 内容格式不符合,请修改正确后再次提交");
        }
        return (true,"校验通过");
    }
    
    // MARK: - 校验模型是否符合要求-选择类型
    ///校验模型是否符合要求-选择类型
    func validationModel_SelectModel(selectModel:YHForm_Select_Model)->(isCorrect:Bool,errorTips:String){
        //判断必填状态下是否有值
        if selectModel.editType == .mustComplete && selectModel.contentID?.count ?? 0 <= 0 {
            //没有值
            return (false,selectModel.attTitle.string+" - 不能为空,请选择");
        }
        return (true,"校验通过");
    }
    
    // MARK: - 校验模型是否符合要求-图片视频类型
    ///校验模型是否符合要求-图片视频类型
    func validationModel_PictureVideoModel(pictureVideoModel:YHForm_PictureVideo_Model)->(isCorrect:Bool,errorTips:String){
        //判断必填和非必填状态下图片视频数量是否满足最低要求
        if (pictureVideoModel.editType == .mustComplete || pictureVideoModel.editType == .optionalComplete) && pictureVideoModel.showType == .none{
            if pictureVideoModel.minImage == 0{
                if pictureVideoModel.data.count <= 0 && pictureVideoModel.editType == .mustComplete{
                    return (false,pictureVideoModel.attTitle.string+" - 最少需要选择一个");
                }
            }else{
                if pictureVideoModel.data.count < pictureVideoModel.minImage{
                    return (false,pictureVideoModel.attTitle.string+" - 最少需要选择"+String(pictureVideoModel.minImage)+"个");
                }
            }
        }
        return (true,"校验通过");
    }
    
    // MARK: - 校验模型是否符合要求-文件类型
    ///校验模型是否符合要求-文件类型
    func validationModel_FileModel(fileModel:YHForm_File_Model)->(isCorrect:Bool,errorTips:String){
        //判断必填和非必填状态下图片视频数量是否满足最低要求
        if (fileModel.editType == .mustComplete || fileModel.editType == .optionalComplete) && fileModel.showType == .none{
            if fileModel.minFile == 0{
                if fileModel.data.count <= 0 && fileModel.editType == .mustComplete{
                    return (false,fileModel.attTitle.string+" - 最少需要选择一个文件");
                }
            }else{
                if fileModel.data.count < fileModel.minFile{
                    return (false,fileModel.attTitle.string+" - 最少需要选择"+String(fileModel.minFile)+"个文件");
                }
            }
        }
        return (true,"校验通过");
    }
    
    // MARK: - 校验模型是否符合要求-页面直接选择类型
    ///校验模型是否符合要求-页面直接选择类型
    func validationModel_DirectSelectModel(dataModel:YHForm_DirectSelect_Model)->(isCorrect:Bool,errorTips:String){
        //判断必填和非必填状态下图片视频数量是否满足最低要求
        if dataModel.editType == .mustComplete && dataModel.showType == .none{
            if dataModel.contentArray.count == 0{
                return (false,dataModel.attTitle.string+" - 请选择选项");
            }
        }
        return (true,"校验通过");
    }
    
    // MARK: - 校验模型是否符合要求-星级评分类型
    ///校验模型是否符合要求-星级评分类型
    func validationModel_StarRatingModel(dataModel:YHForm_StarRating_Model)->(isCorrect:Bool,errorTips:String){
        //判断必填和非必填状态下图片视频数量是否满足最低要求
        if dataModel.editType == .mustComplete && dataModel.showType == .none{
            if dataModel.content?.count ?? 0 <= 0{
                return (false,dataModel.attTitle.string+" - 此项尚未填写");
            }
        }
        return (true,"校验通过");
    }
    
    // MARK: - 组合提交数据-单行输入类型
    ///组合提交数据-单行输入类型
    func combinedSubmissionData_TextFieldModel(textFieldModel:YHForm_TextField_Model) ->[String:String]{
        var submitUrlKey = textFieldModel.submitUrlKey;
        //如果没有提交key，就使用回显key进行提交
        if submitUrlKey.count <= 0 {
            submitUrlKey = textFieldModel.showUrlKey;
        }
        if submitUrlKey.count <= 0{
            return [String:String]();
        }
        return [submitUrlKey:textFieldModel.content ?? ""];
    }
    
    // MARK: - 组合提交数据-多行输入类型
    ///组合提交数据-多行输入类型
    func combinedSubmissionData_TextViewModel(textViewModel:YHForm_TextView_Model) ->[String:String]{
        var submitUrlKey = textViewModel.submitUrlKey;
        //如果没有提交key，就使用回显key进行提交
        if submitUrlKey.count <= 0 {
            submitUrlKey = textViewModel.showUrlKey;
        }
        if submitUrlKey.count <= 0{
            return [String:String]();
        }
        return [submitUrlKey:textViewModel.content ?? ""];
    }
    
    // MARK: - 组合提交数据-选择类型
    ///组合提交数据-选择类型
    func combinedSubmissionData_SelectModel(selectModel:YHForm_Select_Model) ->[String:String]{
        var submitUrlKey = selectModel.submitUrlKey;
        //如果没有提交key，就使用回显key进行提交
        if submitUrlKey.count <= 0 {
            submitUrlKey = selectModel.showUrlKey;
        }
        if submitUrlKey.count <= 0{
            return [String:String]();
        }
        return [submitUrlKey:selectModel.contentID ?? ""];
    }
    
    // MARK: - 组合提交数据-图片视频类型
    ///组合提交数据-图片视频类型
    func combinedSubmissionData_PictureVideoModel(pictureVideoModel:YHForm_PictureVideo_Model) ->(params:[String:String],formDatas:[Moya.MultipartFormData]){
        var params = [String:String]();
        var formDatas = [Moya.MultipartFormData]();
        var imageUrlArray = [String]();
        //追加下标
        var index = 1;
        //提交key 优先使用提交key 如果没有提交key，就使用回显key
        var submitUrlKey = pictureVideoModel.submitUrlKey;
        if submitUrlKey.count <= 0 {
            submitUrlKey = pictureVideoModel.showUrlKey;
        }
        //循环图片视频数据
        for element in pictureVideoModel.data{
            //判断本地数据还是网络数据
            switch element.source {
            case .local://本地数据
                // MARK: - 判断类型
                switch element.type {
                case .picture://图片
                    let data = element.localImage?.jpegData(compressionQuality: 0.5) ?? Data.init();
                    let imageData = MultipartFormData.init(provider: .data(data), name: submitUrlKey, fileName: DataHandle.LocalTimeStampString()+String(index)+".jpg", mimeType: "image/jpg");
                    formDatas.append(imageData);
                    break;
                case .video://视频
                    let videoData = MultipartFormData.init(provider: MultipartFormData.FormDataProvider.file(element.videoUrl ?? URL.init(string: "http://www.yizhongpm.com/none")!), name: submitUrlKey, fileName: DataHandle.LocalTimeStampString()+String(index)+".mov", mimeType: "video/mov");
                    formDatas.append(videoData);
                    break;
                }
                index = index+1;
                break;
            case .network://网络数据 使用回显key
                switch element.type {
                case .picture://图片
                    imageUrlArray.append(element.imageUrlString);
                    break;
                case .video://视频
                    imageUrlArray.append(element.videoUrl?.absoluteString ?? "");
                    break;
                }
                break;
            }
        }
        //拼接网络图片
        if imageUrlArray.count >= 1{
            params[pictureVideoModel.showUrlKey] = imageUrlArray.joined(separator: ",");
        }
        return (params,formDatas);
    }
    
    // MARK: - 组合提交数据-文件类型
    ///组合提交数据-文件类型
    func combinedSubmissionData_FileModel(fileModel:YHForm_File_Model) ->(params:[String:String],formDatas:[Moya.MultipartFormData]){
        var params = [String:String]();
        var formDatas = [Moya.MultipartFormData]();
        var imageUrlArray = [String]();
        //追加下标
        var index = 1;
        //提交key 优先使用提交key 如果没有提交key，就使用回显key
        var submitUrlKey = fileModel.submitUrlKey;
        if submitUrlKey.count <= 0 {
            submitUrlKey = fileModel.showUrlKey;
        }
        //循环图片视频数据
        for element in fileModel.data{
            //判断本地数据还是网络数据
            switch element.source {
            case .local://本地数据
                //文件类型
                var fileType = "";
                // MARK: - 判断类型
                switch element.type {
                case .pdf:
                    fileType = "application/pdf";
                    break;
                case .word:
                    fileType = "application/msword";
                    break;
                case .excel:
                    fileType = "application/vnd.ms-excel";
                    break;
                case .ppt:
                    fileType = "application/vnd.ms-powerpoint";
                    break;
                }
                //记录文件
                let fileData = MultipartFormData.init(provider: MultipartFormData.FormDataProvider.file(URL.init(fileURLWithPath: element.fileUrlString)), name: submitUrlKey, fileName:  element.fileName, mimeType: fileType);
                formDatas.append(fileData);
                index = index+1;
                break;
            case .network://网络数据 使用回显key
                imageUrlArray.append(element.fileUrlString);
                break;
            }
        }
        //拼接网络文件路径
        if imageUrlArray.count >= 1{
            params[fileModel.showUrlKey] = imageUrlArray.joined(separator: ",");
        }
        return (params,formDatas);
    }
    
    // MARK: - 组合提交数据-页面直接选择类型
    ///组合提交数据-页面直接选择类型
    func combinedSubmissionData_DirectSelectModel(dataModel:YHForm_DirectSelect_Model) ->[String:String]{
        var submitUrlKey = dataModel.submitUrlKey;
        //如果没有提交key，就使用回显key进行提交
        if submitUrlKey.count <= 0 {
            submitUrlKey = dataModel.showUrlKey;
        }
        if submitUrlKey.count <= 0{
            return [String:String]();
        }
        return [submitUrlKey:dataModel.contentArray.joined(separator: ",")];
    }
    
    // MARK: - 组合提交数据-星级评分类型
    ///组合提交数据-星级评分类型
    func combinedSubmissionData_StarRatingModel(dataModel:YHForm_StarRating_Model) ->[String:String]{
        var submitUrlKey = dataModel.submitUrlKey;
        //如果没有提交key，就使用回显key进行提交
        if submitUrlKey.count <= 0 {
            submitUrlKey = dataModel.showUrlKey;
        }
        if submitUrlKey.count <= 0{
            return [String:String]();
        }
        return [submitUrlKey:dataModel.content ?? ""];
    }
    
    

    // MARK: - 填充模型-单行输入框类型模型
    ///填充模型-单行输入框类型模型
    func fillingModel_TextFieldModel(textFieldModel:YHForm_TextField_Model,json:[String:Any]){
        //判断回显key是否有值
        if textFieldModel.showUrlKey.count >= 1{
            textFieldModel.content = (json[textFieldModel.showUrlKey] as? String) ?? "";
        }
    }
    
    // MARK: - 填充模型-多行输入框类型模型
    ///填充模型-多行输入框类型模型
    func fillingModel_TextViewModel(textViewModel:YHForm_TextView_Model,json:[String:Any]){
        //判断回显key是否有值
        if textViewModel.showUrlKey.count >= 1{
            textViewModel.content = (json[textViewModel.showUrlKey] as? String) ?? "";
        }
    }
    
    // MARK: - 填充模型-选择类型
    ///填充模型-选择类型
    func fillingModel_SelectModel(selectModel:YHForm_Select_Model,json:[String:Any]){
        var submitUrlKey = selectModel.submitUrlKey;
        //如果没有提交key，就使用回显key进行提交
        if submitUrlKey.count <= 0 {
            submitUrlKey = selectModel.showUrlKey;
        }
        switch selectModel.data.selectType {
        case .none://正常选择
            //赋值ID
            //判断提交key是否有值
            if submitUrlKey.count >= 1{
                selectModel.contentID = (json[submitUrlKey] as? String) ?? "";
            }
            //直接赋值默认字段
            if selectModel.showUrlKey.count >= 1{
                selectModel.content = (json[selectModel.showUrlKey] as? String) ?? "";
            }
            //判断提交key和回显key是否一个
            if submitUrlKey == selectModel.showUrlKey && selectModel.data.appoint_None_Model().config.elements.count >= 1{
                //同一个 并且元素有本地数据 说明名称需要再次计算
                //计算id
                let idArray = selectModel.contentID?.components(separatedBy: ",") ?? [String]();
                let elementName = calculation_SeletModelName(idArray: idArray, elements: selectModel.data.appoint_None_Model().config.elements+selectModel.data.appoint_None_Model().config.supplementElements).joined(separator: ",");
                selectModel.content = elementName;
            }
            break;
        default://时间|地址|银行选择
            //判断回显key是否有值
            if selectModel.showUrlKey.count >= 1{
                selectModel.content = (json[selectModel.showUrlKey] as? String) ?? "";
            }
            //判断提交key是否有值
            if submitUrlKey.count >= 1{
                selectModel.contentID = (json[submitUrlKey] as? String) ?? "";
            }
            break;
        }
    }
    
    // MARK: - 计算选择元素名称
    func calculation_SeletModelName(idArray:[String],elements:[YHBottomSelect_Section_Model])->[String]{
        var nameArray = [String]();
        for element in elements{
            if idArray.contains(element.elementID){
                if element.selectType == .multipleSelect || element.selectType == .select{
                    element.isSelect = true;
                }
                nameArray.append(element.elementName);
            }
            if element.subElements.count >= 1{
                for item in element.subElements{
                    if idArray.contains(item.elementID){
                        if item.selectType == .multipleSelect || item.selectType == .select{
                            item.isSelect = true;
                        }
                        nameArray.append(item.elementName);
                    }
                }
            }
        }
        return nameArray;
    }
    
    // MARK: - 填充模型-图片视频类型
    ///填充模型-图片视频类型
    func fillingModel_PictureVideoModel(pictureVideoModel:YHForm_PictureVideo_Model,json:[String:Any]){
        if (json[pictureVideoModel.showUrlKey] as? String)?.count ?? 0 >= 1{
            //切割字段
            let urlArray = ((json[pictureVideoModel.showUrlKey] as? String) ?? "").components(separatedBy: ",");
            // MARK: - 视频格式-计算使用
            let videoFormats = [".MP4",".mp4",".AVI",".avi",".MOV",".mov",".WMV",".wmv",".RMVB",".rmvb",".MKV",".mkv",".M4V",".m4v"];
            for urlString in urlArray{
                let element = YHForm_PictureVideo_Cell.PictureVideo_Model.init();
                element.source = .network;
                //判断是否包含视频后缀
                if videoFormats.contains(where: { format in
                    return urlString.hasSuffix(format);
                }){
                    //视频
                    element.type = .video;
                    element.videoUrl = URL.init(string: urlString);
                    //异步获取网络视频
                    DispatchQueue.global().async {[weak self] in
                        //获取网络视频
                        let avAsset = AVURLAsset.init(url: URL.init(string: urlString) ?? URL.init(string: "http://www.yizhongpm.com/none")!);
                        //生成视频截图
                        let assetImg = AVAssetImageGenerator(asset: avAsset);
                        assetImg.appliesPreferredTrackTransform = true;
                        assetImg.apertureMode = .encodedPixels;
                        do{
                            let cgimgref = try assetImg.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 600), actualTime: nil);
                            element.localImage = UIImage.init(cgImage: cgimgref);
                        }catch{
                            element.localImage = UIImage.init(named: "public_Image_error_square");
                        }
                        DispatchQueue.main.async {
                            //刷新UI
                            self?.reloadData();
                        }
                    }
                }else{
                    //图片
                    element.type = .picture;
                    element.imageUrlString = urlString;
                }
                if pictureVideoModel.editType != .prohibitComplete && pictureVideoModel.showType == .none{
                    element.showType = .none;
                }else{
                    element.showType = .look;
                }
                pictureVideoModel.data.append(element);
            }
        }
    }
    
    // MARK: - 填充模型-文件类型
    ///填充模型-文件类型
    func fillingModel_FileModel(fileModel:YHForm_File_Model,json:[String:Any]){
        if (json[fileModel.showUrlKey] as? String)?.count ?? 0 >= 1{
            //切割字段
            let urlArray = ((json[fileModel.showUrlKey] as? String) ?? "").components(separatedBy: ",");
            //循环
            for urlString in urlArray{
                let element = YHForm_File_Cell.File_Model.init();
                element.source = .network;
                //判断文件类型
                element.type = YHForm_File_Cell.DetermineFileFormat(fileName: urlString);
                //赋值默认路径
                element.fileUrlString = urlString;
                //判断文件是否已经存在
                if !FileCache_Manager.shared.isFileExistence(filePath: CoreData_Manager.shared.readCacheComparison(urlPath: urlString)){
                    //不存在
                    //下载文件
                    print("路径: ",urlString)
                    FileCache_Manager.shared.down_File(urlString: urlString) { isSuccess  in
                        if isSuccess{
                            //下载成功
                            element.fileName = urlString.components(separatedBy: "/").last ?? "无名";
                            element.fileSize = FileCache_Manager.shared.read_FileData(filePath: CoreData_Manager.shared.readCacheComparison(urlPath: element.fileUrlString)).calculateSize();
                        }else{
                            //下载失败
                            element.fileName = "加载失败,点击重试";
                        }
                        //完成
                        //通知UI刷新
                        DispatchQueue.main.async {[weak self] in
                            //刷新UI
                            self?.reloadData();
                        }
                    }
                }else{
                    //存在
                    element.fileUrlString = urlString;
                    element.fileName = urlString.components(separatedBy: "/").last ?? "无名";
                    element.fileSize = FileCache_Manager.shared.read_FileData(filePath: CoreData_Manager.shared.readCacheComparison(urlPath: element.fileUrlString)).calculateSize();
                }
                //处理是否能编辑
                if fileModel.editType != .prohibitComplete && fileModel.showType == .none{
                    element.showType = .none;
                }else{
                    element.showType = .look;
                }
                fileModel.data.append(element);
            }
        }
    }
    
    // MARK: - 填充模型-页面直接选择类型
    ///填充模型-页面直接选择类型
    func fillingModel_DirectSelectModel(dataModel:YHForm_DirectSelect_Model,json:[String:Any]){
        //判断回显key是否有值
        if dataModel.showUrlKey.count >= 1{
            dataModel.contentArray = ((json[dataModel.showUrlKey] as? String) ?? "").components(separatedBy: ",");
        }
    }
    
    // MARK: - 填充模型-星级评分类型
    ///填充模型-星级评分类型
    func fillingModel_StarRatingModel(dataModel:YHForm_StarRating_Model,json:[String:Any]){
        //判断回显key是否有值
        if dataModel.showUrlKey.count >= 1{
            dataModel.content = (json[dataModel.showUrlKey] as? String) ?? "";
        }
    }
    
    
    // MARK: - 计算控件坐标-所有
    func calculation_AllCellFrame(sectionModels:[YHForm_Section_Model]){
        //循环分组
        for sectionModel in sectionModels{
            //循环元素
            for element in sectionModel.elements{
                //根据类型计算
                switch element.formType {
                case .textField://文本输入类
                    calculation_Frame_TextFieldModel(tfModel: element.appoint_TextFieldModel());
                    break;
                case .textView://多行文本输入类型
                    calculation_Frame_TextViewModel(tvModel: element.appoint_TextViewModel());
                    break;
                case .select://选择类型
                    calculation_Frame_SelectModel(selectModel: element.appoint_SelectModel());
                    break;
                case .pictureVideo://图片视频类
                    calculation_Frame_PictureVideoModel(pvModel: element.appoint_PictureVideoModel());
                    break;
                case .file://文件类型
                    calculation_Frame_FileModel(fileModel: element.appoint_FileModel());
                    break;
                case .imageJump://图片跳转类型
                    calculation_Frame_ImageJumpModel(imageJumpModel: element.appoint_ImageJumpModel());
                    break;
                case .directSelect://页面直接选择类型
                    calculation_Frame_DirectSelectModel(dataModel: element.appoint_DirectSelectModel());
                    break;
                case .starRating://星级评分类型
                    calculation_Frame_StarRatingModel(dataModel: element.appoint_StarRatingModel());
                    break;
                case .tips://提示类型
                    calculation_Frame_TipsModel(dataModel: element.appoint_TipsModel());
                    break;
                default:
                    break;
                }
            }
        }
    }
    
    // MARK: - 计算控件坐标-文本输入类
    func calculation_Frame_TextFieldModel(tfModel:YHForm_TextField_Model){
        //控件大小上限
        let maxSize = CGSize(width: APP_WIDTH-Form_CommonlyGap*2, height: 99999);
        //计算标题控件大小
        let titleSize = tfModel.attTitle.attText_Size(maxSize: maxSize);
        //标题控件坐标
        tfModel.titleFrame = CGRect(x: Form_CommonlyGap, y: 0, width: titleSize.width, height: ceil(Form_DefaultCellHeight));
        //内容控件坐标
        tfModel.contentFrame = CGRect(x:tfModel.titleFrame.size.width+tfModel.titleFrame.origin.x+Form_CommonlyGap , y: 0, width: APP_WIDTH-tfModel.titleFrame.size.width-tfModel.titleFrame.origin.x-Form_CommonlyGap*2, height: ceil(Form_DefaultCellHeight));
        //正常模式
        if tfModel.showType == .look || tfModel.editType == .prohibitComplete{
            //不可编辑
            var contentSize = (tfModel.content ?? "").text_Size(maxSize: maxSize, font: UIFont.systemFont(ofSize: Calculation_FontNumber(font: 16)));
            //处理是否需要换行
            if contentSize.width+Form_CommonlyGap*3+titleSize.width > APP_WIDTH{
                //处理最小高度
                contentSize.height = ceil(contentSize.height+Form_CommonlyGap);
                //需要换行
                tfModel.contentFrame = CGRect(x: Form_CommonlyGap, y: tfModel.titleFrame.size.height, width: APP_WIDTH-Form_CommonlyGap*2, height: contentSize.height);
            }
        }else{
            //可以编辑
            //判断内容控件是否需要换行
            if titleSize.width >= (APP_WIDTH-Form_CommonlyGap*2)/2{
                //重新赋值标题控件坐标宽度
                tfModel.titleFrame.size.width = APP_WIDTH-Form_CommonlyGap*2;
                //内容控件坐标
                tfModel.contentFrame = CGRect(x:Form_CommonlyGap , y: tfModel.titleFrame.size.height, width: maxSize.width, height: ceil(Form_DefaultCellHeight));
            }
        }
    
        //处理底部错误提示文本
        //获取最新的不合规提示
        tfModel.limitModel.bottomLimitTipsAtt = self.formDelegate?.YHForm_Delegate_TextField_InputLimitUnqualifiedTipsAttString?(title: tfModel.attTitle.string) ?? tfModel.limitModel.bottomLimitTipsAtt;
        //计算底部错误提示
        tfModel.limitModel.bottomLimitTipsFrame = CGRect(x: Form_CommonlyGap, y: tfModel.contentFrame.size.height+tfModel.contentFrame.origin.y, width: maxSize.width, height: 0);
        //判断是否可以展示底部错误提示
        if tfModel.showType == .none && tfModel.editType != .prohibitComplete && (tfModel.limitModel.completeRegular.count >= 1 || tfModel.limitModel.InputChangeRegular.count >= 1) && tfModel.limitModel.bottomLimitTipsAtt.length >= 1 && tfModel.content?.count ?? 0 >= 1{
            //判断是否满足正则
            var completeRegular = tfModel.limitModel.completeRegular;
            //如完整正则为空则使用输入正则
            if completeRegular.count <= 0 {
                completeRegular = tfModel.limitModel.InputChangeRegular;
            }
            //校验是否符合正则
            if tfModel.content?.isMatch(completeRegular) ?? true == false && completeRegular.count >= 1 && tfModel.content?.count ?? 0 >= 1{
                //不满足 需要展示底部错误提示文本
                let bottomLimitTipsSize = tfModel.limitModel.bottomLimitTipsAtt.attText_Size(maxSize: maxSize);
                tfModel.limitModel.bottomLimitTipsFrame.size = CGSize(width: maxSize.width, height: ceil(bottomLimitTipsSize.height+Form_CommonlyGap*2*0.9));
            }
        }
        
        
        //底部提示控件frame
        tfModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:tfModel.limitModel.bottomLimitTipsFrame.size.height+tfModel.limitModel.bottomLimitTipsFrame.origin.y , width:maxSize.width, height:0);
        //计算底部提示控件大小
        let tipsSize = tfModel.bottom_TipsAttContent.attText_Size(maxSize: maxSize);
        //判断是否需要记录底部提示控件frame
        if tipsSize.width > 0 {
            //底部提示控件frame
            tfModel.tipsFrame.size = CGSize(width: maxSize.width, height: ceil(tipsSize.height+Form_CommonlyGap*2*0.9));
        }
        
        //计算Cell总高度
        tfModel.cellHeight = tfModel.tipsFrame.size.height+tfModel.tipsFrame.origin.y;
    }
    
    // MARK: - 计算控件坐标-多行文本输入类
    func calculation_Frame_TextViewModel(tvModel:YHForm_TextView_Model){
        //控件大小上限
        let maxSize = CGSize(width: APP_WIDTH-Form_CommonlyGap*2, height: 99999);
        //标题坐标高度
        var titleHeight = tvModel.attTitle.attText_Size(maxSize: maxSize).height;
        //判断是否等于单行高度
        if titleHeight <= Form_StandardTextSingleLineHeight{
            titleHeight = Form_DefaultCellHeight;
        }else{
            titleHeight = titleHeight+Form_CommonlyGap*2*0.9;
        }
        //标题控件坐标
        tvModel.titleFrame = CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: titleHeight);
        //内容控件y
        var contentY = tvModel.titleFrame.size.height;
        //判断附加视图位置
        if tvModel.additionalViewPosition == .titleBottom{
            contentY = contentY+tvModel.additionalView.frame.size.height;
        }
        
        //内容控件坐标
        tvModel.contentFrame = CGRect(x:Form_CommonlyGap , y: contentY, width: APP_WIDTH-Form_CommonlyGap*2, height: Form_DefaultCellHeight*2);
        //计算内容高度
        let contentSize = tvModel.content?.text_Size(maxSize: maxSize, font: UIFont.systemFont(ofSize: Calculation_FontNumber(font: 15)));
        //判断内容控件是否需要扩大
        if contentSize?.height ?? 0 > Form_DefaultCellHeight*2{
            if contentSize?.height ?? 0 > Form_DefaultCellHeight*3{
                tvModel.contentFrame.size.height = Form_DefaultCellHeight*3;
            }else{
                tvModel.contentFrame.size.height = contentSize?.height ?? Form_DefaultCellHeight*2;
            }
        }
        //计算底部提示控件大小
        let tipsSize = tvModel.bottom_TipsAttContent.attText_Size(maxSize: maxSize);
        //判断是否需要记录底部提示控件frame
        if tipsSize.width > 0 {
            //底部提示控件frame
            tvModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:tvModel.contentFrame.size.height+tvModel.contentFrame.origin.y , width:maxSize.width, height:ceil(tipsSize.height+Form_CommonlyGap*2*0.9));
        }else{
            //底部提示控件frame
            tvModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:tvModel.contentFrame.size.height+tvModel.contentFrame.origin.y , width:maxSize.width, height:0);
        }
        //计算Cell总高度
        tvModel.cellHeight = tvModel.tipsFrame.size.height+tvModel.tipsFrame.origin.y;
    }
    
    
    // MARK: - 计算控件坐标-选择类
    func calculation_Frame_SelectModel(selectModel:YHForm_Select_Model){
        //控件大小上限
        let maxSize = CGSize(width: APP_WIDTH-Form_CommonlyGap*2, height: 99999);
        //计算标题控件大小
        let titleSize = selectModel.attTitle.attText_Size(maxSize: maxSize);
        //标题控件坐标
        selectModel.titleFrame = CGRect(x: Form_CommonlyGap, y: 0, width: titleSize.width, height: Form_DefaultCellHeight);
        //计算内容控件大小
        let contentSize = (selectModel.content ?? selectModel.contentTips).text_Size(maxSize: maxSize, font: UIFont.systemFont(ofSize: Calculation_FontNumber(font: 16)));
        //内容控件坐标
        selectModel.contentFrame = CGRect(x:selectModel.titleFrame.size.width+selectModel.titleFrame.origin.x+Form_CommonlyGap, y: 0, width: APP_WIDTH-selectModel.titleFrame.size.width-selectModel.titleFrame.origin.x-Form_CommonlyGap*2, height: Form_DefaultCellHeight);
        //判断内容控件是否需要换行
        if titleSize.width+contentSize.width+Form_CommonlyGap >= (APP_WIDTH-Form_CommonlyGap*2){
            //重新赋值标题控件坐标宽度
            selectModel.titleFrame.size.width = APP_WIDTH-Form_CommonlyGap*2;
            //计算内容控件高度是否满足最低要求
            var contentHeight = contentSize.height+Form_CommonlyGap/2;
            if contentHeight < Form_DefaultCellHeight {
                contentHeight = Form_DefaultCellHeight;
            }
            //重新赋值内容控件坐标
            selectModel.contentFrame = CGRect(x:Form_CommonlyGap , y: selectModel.titleFrame.size.height, width: maxSize.width, height: contentHeight);
        }
        
        //计算底部提示控件大小
        let tipsSize = selectModel.bottom_TipsAttContent.attText_Size(maxSize: maxSize);
        //判断是否需要记录底部提示控件frame
        if tipsSize.width > 0 {
            //底部提示控件frame
            selectModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:selectModel.contentFrame.size.height+selectModel.contentFrame.origin.y , width:maxSize.width, height:ceil(tipsSize.height+Form_CommonlyGap*2*0.9));
        }else{
            //底部提示控件frame
            selectModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:selectModel.contentFrame.size.height+selectModel.contentFrame.origin.y , width:maxSize.width, height:0);
        }
        //计算Cell总高度
        selectModel.cellHeight = selectModel.tipsFrame.size.height+selectModel.tipsFrame.origin.y;
    }
    
    // MARK: - 计算控件坐标-图片视频类
    func calculation_Frame_PictureVideoModel(pvModel:YHForm_PictureVideo_Model){
        //控件大小上限
        let maxSize = CGSize(width: APP_WIDTH-Form_CommonlyGap*2, height: 99999);
        //计算标题控件坐标
        var titleSize = pvModel.attTitle.attText_Size(maxSize: maxSize);
        if titleSize.width > 0{
            //Form_CommonlyGap为最小文字预留控件间距
            if titleSize.height+Form_CommonlyGap <= Form_DefaultCellHeight{
                titleSize.height = Form_DefaultCellHeight;
            }else{
                titleSize.height = titleSize.height+Form_CommonlyGap;
            }
        }else{
            titleSize.height = Form_DefaultCellHeight;
        }
        pvModel.titleFrame = CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: titleSize.height);
        //内容控件坐标
        var number = pvModel.data.count;
        if pvModel.showType == .none && pvModel.editType != .prohibitComplete && pvModel.data.count < pvModel.maxImage{
            number = number+1;
        }
        var lineNumber = number/4;
        if number%4 != 0{
            lineNumber = lineNumber+1;
        }
        //计算内容高度
        pvModel.contentFrame = CGRect(x:Form_CommonlyGap/2 , y: pvModel.titleFrame.size.height+pvModel.titleFrame.origin.y, width: APP_WIDTH-Form_CommonlyGap, height: (APP_WIDTH-Form_CommonlyGap)/4*CGFloat(lineNumber));
        if lineNumber >= 1{
            //补充底部间距
            pvModel.contentFrame.size.height = pvModel.contentFrame.size.height+Form_CommonlyGap/2;
        }
        //计算底部提示控件大小
        let tipsSize = pvModel.bottom_TipsAttContent.attText_Size(maxSize: maxSize);
        //判断是否需要记录底部提示控件frame
        if tipsSize.width > 0 {
            //底部提示控件frame
            pvModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:pvModel.contentFrame.size.height+pvModel.contentFrame.origin.y , width:maxSize.width, height:ceil(tipsSize.height+Form_CommonlyGap*2*0.9));
        }else{
            //底部提示控件frame
            pvModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:pvModel.contentFrame.size.height+pvModel.contentFrame.origin.y , width:maxSize.width, height:0);
        }
        //计算Cell总高度
        pvModel.cellHeight = pvModel.tipsFrame.size.height+pvModel.tipsFrame.origin.y;
    }
    
    // MARK: - 计算控件坐标-文件类
    func calculation_Frame_FileModel(fileModel:YHForm_File_Model){
        //控件大小上限
        let maxSize = CGSize(width: APP_WIDTH-Form_CommonlyGap*2, height: 99999);
        
        //标题控件坐标
        fileModel.titleFrame = CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: Form_DefaultCellHeight);
        
        //内容起始坐标
        var contentY = fileModel.titleFrame.size.height;
        //判断附加视图位置是否在标题下面
        if fileModel.additionalViewPosition == .titleBottom{
            contentY = contentY+fileModel.additionalView.frame.size.height;
        }
        //内容控件坐标
        var number = fileModel.data.count;
        if fileModel.showType == .none && fileModel.editType != .prohibitComplete && fileModel.data.count < fileModel.maxFile{
            number = number+1;
        }
        //计算内容高度
        fileModel.contentFrame = CGRect(x:Form_CommonlyGap , y: contentY, width: APP_WIDTH-Form_CommonlyGap*2, height: Form_DefaultCellHeight*CGFloat(number));
        //增加间隔
        if number >= 1{
            fileModel.contentFrame.size.height = fileModel.contentFrame.size.height+Form_CommonlyGap;
            if number >= 2{
                fileModel.contentFrame.size.height = fileModel.contentFrame.size.height+Form_CommonlyGap*CGFloat(number-1);
            }
        }
        //计算底部提示控件大小
        let tipsSize = fileModel.bottom_TipsAttContent.attText_Size(maxSize: maxSize);
        //判断是否需要记录底部提示控件frame
        if tipsSize.width > 0 {
            //底部提示控件frame
            fileModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:fileModel.contentFrame.size.height+fileModel.contentFrame.origin.y , width:maxSize.width, height:ceil(tipsSize.height+Form_CommonlyGap*2*0.9));
        }else{
            //底部提示控件frame
            fileModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:fileModel.contentFrame.size.height+fileModel.contentFrame.origin.y , width:maxSize.width, height:0);
        }
        //计算Cell总高度
        fileModel.cellHeight = fileModel.tipsFrame.size.height+fileModel.tipsFrame.origin.y;
    }
    
    // MARK: - 计算控件坐标-图片跳转类
    func calculation_Frame_ImageJumpModel(imageJumpModel:YHForm_ImageJump_Model){
        //标题控件坐标
        imageJumpModel.titleFrame = CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: Form_DefaultCellHeight);
        var imageJumpCount = imageJumpModel.images.count/4;
        if imageJumpModel.images.count%4 != 0{
            imageJumpCount = imageJumpCount+1;
        }
        //计算Cell总高度
        imageJumpModel.cellHeight = imageJumpModel.titleFrame.size.height+APP_WIDTH/4*CGFloat(imageJumpCount);
    }
    
    // MARK: - 计算控件坐标-页面直接选择类型
    func calculation_Frame_DirectSelectModel(dataModel:YHForm_DirectSelect_Model){
        //控件大小上限
        let maxSize = CGSize(width: APP_WIDTH-Form_CommonlyGap*2, height: 99999);
        //标题坐标高度
        var titleHeight = dataModel.attTitle.attText_Size(maxSize: maxSize).height;
        //判断是否等于单行高度
        if titleHeight <= Form_StandardTextSingleLineHeight{
            titleHeight = Form_DefaultCellHeight;
        }else{
            titleHeight = titleHeight+Form_CommonlyGap*2*0.9;
        }
        //标题控件坐标
        dataModel.titleFrame = CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: titleHeight);
        //内容控件y
        var contentY = dataModel.titleFrame.size.height;
        //判断附加视图位置
        if dataModel.additionalViewPosition == .titleBottom{
            contentY = contentY+dataModel.additionalView.frame.size.height;
        }
        //内容控件高度
        var contentHeight:CGFloat = 0;
        //垂直排列
        dataModel.data.forEach { elementModel in
            elementModel.elementHeight = (elementModel.elementName ?? "").text_Size(maxSize: CGSize(width: APP_WIDTH-Form_CommonlyGap*4.5, height: 999), font: UIFont.systemFont(ofSize: Calculation_FontNumber(font: 14))).height+Form_CommonlyGap;
            contentHeight = contentHeight+elementModel.elementHeight;
        }
        
        //补充底部间距
        if contentHeight > 0{
            contentHeight = contentHeight+Form_CommonlyGap/2;
        }
        
        //内容控件坐标
        dataModel.contentFrame = CGRect(x:Form_CommonlyGap , y: contentY, width: APP_WIDTH-Form_CommonlyGap*2, height: contentHeight);
        //计算底部提示控件大小
        let tipsSize = dataModel.bottom_TipsAttContent.attText_Size(maxSize: maxSize);
        //判断是否需要记录底部提示控件frame
        if tipsSize.width > 0 {
            //底部提示控件frame
            dataModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:dataModel.contentFrame.size.height+dataModel.contentFrame.origin.y , width:maxSize.width, height:ceil(tipsSize.height+Form_CommonlyGap*2*0.9));
        }else{
            //底部提示控件frame
            dataModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:dataModel.contentFrame.size.height+dataModel.contentFrame.origin.y , width:maxSize.width, height:0);
        }
        //计算Cell总高度
        dataModel.cellHeight = dataModel.tipsFrame.size.height+dataModel.tipsFrame.origin.y;
    }
    
    // MARK: - 计算控件坐标-星级评分类型
    func calculation_Frame_StarRatingModel(dataModel:YHForm_StarRating_Model){
        //控件大小上限
        let maxSize = CGSize(width: APP_WIDTH-Form_CommonlyGap*2, height: 99999);
        //标题坐标高度
        var titleHeight = dataModel.attTitle.attText_Size(maxSize: maxSize).height;
        //判断是否等于单行高度
        if titleHeight <= Form_StandardTextSingleLineHeight{
            titleHeight = Form_DefaultCellHeight;
        }else{
            titleHeight = titleHeight+Form_CommonlyGap*2*0.9;
        }
        //标题控件坐标
        dataModel.titleFrame = CGRect(x: Form_CommonlyGap, y: 0, width: APP_WIDTH-Form_CommonlyGap*2, height: titleHeight);
        //内容控件y
        var contentY = dataModel.titleFrame.size.height;
        //判断附加视图位置
        if dataModel.additionalViewPosition == .titleBottom{
            contentY = contentY+dataModel.additionalView.frame.size.height;
        }
        //内容控件坐标
        dataModel.contentFrame = CGRect(x:Form_CommonlyGap , y: contentY, width: APP_WIDTH-Form_CommonlyGap*2, height: Form_DefaultCellHeight);
        //计算底部提示控件大小
        let tipsSize = dataModel.bottom_TipsAttContent.attText_Size(maxSize: maxSize);
        //判断是否需要记录底部提示控件frame
        if tipsSize.width > 0 {
            //底部提示控件frame
            dataModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:dataModel.contentFrame.size.height+dataModel.contentFrame.origin.y , width:maxSize.width, height:ceil(tipsSize.height+Form_CommonlyGap*2*0.9));
        }else{
            //底部提示控件frame
            dataModel.tipsFrame = CGRect(x: Form_CommonlyGap, y:dataModel.contentFrame.size.height+dataModel.contentFrame.origin.y , width:maxSize.width, height:0);
        }
        //计算Cell总高度
        dataModel.cellHeight = dataModel.tipsFrame.size.height+dataModel.tipsFrame.origin.y;
    }
    
    // MARK: - 计算控件坐标-提示类型
    func calculation_Frame_TipsModel(dataModel:YHForm_Tips_Model){
        //控件大小上限
        let maxSize = CGSize(width: APP_WIDTH-Form_CommonlyGap*2, height: 99999);
        //判断是否强制占位
        if dataModel.forcedOccupancy{
            //计算Cell总高度
            dataModel.cellHeight = Form_CommonlyGap;
        }else{
            if dataModel.attTitle.length >= 1{
                //计算Cell总高度
                //计算文本高度
                let attSize = dataModel.attTitle.attText_Size(maxSize: maxSize);
                dataModel.cellHeight = ceil(attSize.height+Form_CommonlyGap*2*0.9);
            }else{
                dataModel.cellHeight = 0;
            }
        }
    }
    
    // MARK: - 根据cell的编辑类型计算出要展示的编辑类型提示控件样式
    class func calculation_Cell_EditTypeTipsImageView_Style(showType:YHForm_Base_Model.YHForm_Show_Type,editType:YHForm_Base_Model.YHForm_Edit_Type,imageView:UIImageView){
        //判断展示类型
        switch showType {
        case .none://正常类型
            //判断编辑类型
            switch editType {
            case .mustComplete://必填
                imageView.image = UIImage.init(named: "public_mustComplete");
                break;
            case .optionalComplete://选填
                imageView.image = UIImage.init(named: "public_mustComplete_no");
                break;
            case .prohibitComplete://不可填
                imageView.image = UIImage.init(named: "yh_Public_Clear");
                break;
            }
            break;
        case .look://查看类型
            imageView.image = UIImage.init(named: "yh_Public_Clear");
            break;
        }
    }
    
    // MARK: - 创建单行输入类型选项
    ///创建单行输入类型选项
    class func create_TextFiledModel(attTitle:NSMutableAttributedString,showUrlKey:String,submitUrlKey:String?,editType:YHForm_Base_Model.YHForm_Edit_Type,limitModel:YHForm_TextField_Cell.inputLimit_None_Model?,bottomLimitTipsAtt:NSMutableAttributedString? = nil,extensionType:YHForm_TextField_Model.ExtensionType? = nil,bottom_TipsAttBackGroundColor:UIColor? = nil,bottom_TipsAttContent:NSMutableAttributedString? = nil,idKey:String? = nil)->YHForm_TextField_Model{
        let tfModel = YHForm_TextField_Model.init();
        tfModel.attTitle = attTitle;
        tfModel.showUrlKey = showUrlKey;
        tfModel.submitUrlKey = submitUrlKey ?? "";
        tfModel.editType = editType;
        //记录底部提示文本背景颜色
        tfModel.bottom_TipsAttBackGroundColor = bottom_TipsAttBackGroundColor ?? tfModel.bottom_TipsAttBackGroundColor;
        //赋值底部提示文本
        tfModel.bottom_TipsAttContent = bottom_TipsAttContent ?? tfModel.bottom_TipsAttContent;
        //默认拓展类型为 无拓展
        tfModel.extensionType = extensionType ?? tfModel.extensionType;
        //赋值校验规则模型
        tfModel.limitModel = limitModel ?? tfModel.limitModel;
        //判断是否需要补充不合规提示文本
        tfModel.limitModel.bottomLimitTipsAtt = bottomLimitTipsAtt ?? (tfModel.attTitle.string+"不符合格式要求,请核对后修正").toAttText_ColorWithFont13(color: .red);
        //记录idkey
        tfModel.idKey = idKey ?? showUrlKey;
        return tfModel;
    }
    
    // MARK: - 创建选择类型选项
    ///创建选择类型选项
    class func create_SelectModel(attTitle:NSMutableAttributedString,showUrlKey:String,submitUrlKey:String?,editType:YHForm_Base_Model.YHForm_Edit_Type,elementsData:[[String:Any]],mandatoryDisplayTipsImage:Bool? = nil,bottom_TipsAttBackGroundColor:UIColor? = nil,idKey:String? = nil)->YHForm_Select_Model{
        let sModel = YHForm_Select_Model.init();
        sModel.attTitle = attTitle;
        sModel.showUrlKey = showUrlKey;
        sModel.submitUrlKey = submitUrlKey ?? "";
        sModel.editType = editType;
        sModel.data = YHForm_Select_Cell.SelectData_None_Model.init();
        sModel.data.appoint_None_Model().config.elements = YHBottomSelect_View.create_SingleChoice_Elements(elementsData: elementsData);
        sModel.mandatoryDisplayTipsImage = mandatoryDisplayTipsImage ?? sModel.mandatoryDisplayTipsImage;
        //记录底部提示文本背景颜色
        sModel.bottom_TipsAttBackGroundColor = bottom_TipsAttBackGroundColor ?? sModel.bottom_TipsAttBackGroundColor;
        //记录idkey
        sModel.idKey = idKey ?? showUrlKey;
        return sModel;
    }
    
    // MARK: - 创建时间选择类型选项
    ///创建时间选择类型选项
    class func create_TimeSelectModel(attTitle:NSMutableAttributedString,showUrlKey:String,submitUrlKey:String?,editType:YHForm_Base_Model.YHForm_Edit_Type,maxTime:Date?,minTime:Date?,timeFormat:BRDatePickerMode,isAddHMS:Bool? = nil,relationMaxTimeIDKey:String? = nil,relationMinTimeIDKey:String? = nil,bottom_TipsAttBackGroundColor:UIColor? = nil,idKey:String? = nil)->YHForm_Select_Model{
        let sModel = YHForm_Select_Model.init();
        sModel.attTitle = attTitle;
        sModel.showUrlKey = showUrlKey;
        sModel.submitUrlKey = submitUrlKey ?? "";
        sModel.editType = editType;
        sModel.data = YHForm_Select_Cell.SelectData_Time_Model.init();
        sModel.data.appoint_Time_Model().maxTime = maxTime;
        sModel.data.appoint_Time_Model().minTime = minTime;
        sModel.data.appoint_Time_Model().relationMaxTimeIDKey = relationMaxTimeIDKey ?? sModel.data.appoint_Time_Model().relationMaxTimeIDKey;
        sModel.data.appoint_Time_Model().relationMinTimeIDKey = relationMinTimeIDKey ?? sModel.data.appoint_Time_Model().relationMinTimeIDKey;
        sModel.data.appoint_Time_Model().timeFormat = timeFormat;
        sModel.data.appoint_Time_Model().isAddHMS = isAddHMS ?? sModel.data.appoint_Time_Model().isAddHMS;
        //记录底部提示文本背景颜色
        sModel.bottom_TipsAttBackGroundColor = bottom_TipsAttBackGroundColor ?? sModel.bottom_TipsAttBackGroundColor;
        //记录idkey
        sModel.idKey = idKey ?? showUrlKey;
        return sModel;
    }
    
    // MARK: - 创建地址选择类型选项
    ///创建地址选择类型选项
    class func create_AddresSelectModel(attTitle:NSMutableAttributedString,showUrlKey:String,submitUrlKey:String?,editType:YHForm_Base_Model.YHForm_Edit_Type,bottom_TipsAttBackGroundColor:UIColor? = nil,idKey:String? = nil)->YHForm_Select_Model{
        let sModel = YHForm_Select_Model.init();
        sModel.attTitle = attTitle;
        sModel.showUrlKey = showUrlKey;
        sModel.submitUrlKey = submitUrlKey ?? "";
        sModel.editType = editType;
        sModel.data = YHForm_Select_Cell.SelectData_Address_Model.init();
        //记录底部提示文本背景颜色
        sModel.bottom_TipsAttBackGroundColor = bottom_TipsAttBackGroundColor ?? sModel.bottom_TipsAttBackGroundColor;
        //记录idkey
        sModel.idKey = idKey ?? showUrlKey;
        return sModel;
    }
    
    // MARK: - 创建银行选择类型选项
    ///创建银行选择类型选项
    class func create_BankSelectModel(attTitle:NSMutableAttributedString,showUrlKey:String,submitUrlKey:String?,editType:YHForm_Base_Model.YHForm_Edit_Type,bottom_TipsAttBackGroundColor:UIColor? = nil,idKey:String? = nil)->YHForm_Select_Model{
        let sModel = YHForm_Select_Model.init();
        sModel.attTitle = attTitle;
        sModel.showUrlKey = showUrlKey;
        sModel.submitUrlKey = submitUrlKey ?? "";
        sModel.editType = editType;
        sModel.data = YHForm_Select_Cell.SelectData_Bank_Model.init();
        //记录底部提示文本背景颜色
        sModel.bottom_TipsAttBackGroundColor = bottom_TipsAttBackGroundColor ?? sModel.bottom_TipsAttBackGroundColor;
        //记录idkey
        sModel.idKey = idKey ?? showUrlKey;
        return sModel;
    }
    
    // MARK: - 创建多行输入类型选项
    ///创建多行输入类型选项
    class func create_TextViewModel(attTitle:NSMutableAttributedString,showUrlKey:String,submitUrlKey:String?,editType:YHForm_Base_Model.YHForm_Edit_Type,limitModel:YHForm_TextField_Cell.inputLimit_None_Model?,bottom_TipsAttBackGroundColor:UIColor? = nil,idKey:String? = nil)->YHForm_TextView_Model{
        let tfModel = YHForm_TextView_Model.init();
        tfModel.attTitle = attTitle;
        tfModel.showUrlKey = showUrlKey;
        tfModel.submitUrlKey = submitUrlKey ?? "";
        tfModel.editType = editType;
        tfModel.limitModel = limitModel ?? tfModel.limitModel;
        //记录底部提示文本背景颜色
        tfModel.bottom_TipsAttBackGroundColor = bottom_TipsAttBackGroundColor ?? tfModel.bottom_TipsAttBackGroundColor;
        //记录idkey
        tfModel.idKey = idKey ?? showUrlKey;
        return tfModel;
    }
    
    // MARK: - 创建附件
    ///创建附件
    class func create_FileModel(attTitle:NSMutableAttributedString,showUrlKey:String,submitUrlKey:String?,editType:YHForm_Base_Model.YHForm_Edit_Type,maxFile:Int,minFile:Int,types:[YHForm_File_Cell.fileType],bottom_TipsAttBackGroundColor:UIColor? = nil,idKey:String? = nil)->YHForm_File_Model{
        let fModel = YHForm_File_Model.init();
        fModel.attTitle = attTitle;
        fModel.showUrlKey = showUrlKey;
        fModel.submitUrlKey = submitUrlKey ?? "";
        fModel.editType = editType;
        fModel.maxFile = maxFile;
        fModel.minFile = minFile;
        fModel.types = types;
        //记录底部提示文本背景颜色
        fModel.bottom_TipsAttBackGroundColor = bottom_TipsAttBackGroundColor ?? fModel.bottom_TipsAttBackGroundColor;
        //记录idkey
        fModel.idKey = idKey ?? showUrlKey;
        return fModel;
    }
    
    // MARK: - 创建图片视频
    ///创建图片视频
    class func create_PictureVideoModel(attTitle:NSMutableAttributedString,showUrlKey:String,submitUrlKey:String?,editType:YHForm_Base_Model.YHForm_Edit_Type,maxImage:Int,minImage:Int,type:YHForm_PictureVideo_Model.dataType,isOriginal:Bool,bottom_TipsAttBackGroundColor:UIColor? = nil,idKey:String? = nil)->YHForm_PictureVideo_Model{
        let pvModel = YHForm_PictureVideo_Model.init();
        pvModel.attTitle = attTitle;
        pvModel.showUrlKey = showUrlKey;
        pvModel.submitUrlKey = submitUrlKey ?? "";
        pvModel.editType = editType;
        pvModel.maxImage = maxImage;
        pvModel.minImage = minImage;
        pvModel.type = type;
        pvModel.isOriginal = isOriginal;
        //记录底部提示文本背景颜色
        pvModel.bottom_TipsAttBackGroundColor = bottom_TipsAttBackGroundColor ?? pvModel.bottom_TipsAttBackGroundColor;
        //记录idkey
        pvModel.idKey = idKey ?? showUrlKey;
        return pvModel;
    }
    
    // MARK: - 创建页面直接选择类型
    ///创建页面直接选择类型
    class func create_DirectSelectModel(attTitle:NSMutableAttributedString,showUrlKey:String,submitUrlKey:String?,editType:YHForm_Base_Model.YHForm_Edit_Type,multipleSelection:Bool,data:[[String:String]],bottom_TipsAttBackGroundColor:UIColor? = nil,idKey:String? = nil)->YHForm_DirectSelect_Model{
        let dataModel = YHForm_DirectSelect_Model.init();
        dataModel.attTitle = attTitle;
        dataModel.showUrlKey = showUrlKey;
        dataModel.submitUrlKey = submitUrlKey ?? "";
        dataModel.editType = editType;
        dataModel.multipleSelection = multipleSelection;
        data.forEach { param in
            let elementModel = YHForm_DirectSelect_Model.YHForm_DirectSelect_Element_Model.init();
            elementModel.elementName = param["elementName"] ?? "";
            elementModel.elementID = param["elementID"] ?? "";
            elementModel.param = param["param"];
            dataModel.data.append(elementModel);
        }
        //记录底部提示文本背景颜色
        dataModel.bottom_TipsAttBackGroundColor = bottom_TipsAttBackGroundColor ?? dataModel.bottom_TipsAttBackGroundColor;
        //记录idkey
        dataModel.idKey = idKey ?? showUrlKey;
        return dataModel;
    }
    
    // MARK: - 创建星级评分类型
    ///创建星级评分类型
    class func create_StarRatingModel(attTitle:NSMutableAttributedString,showUrlKey:String,submitUrlKey:String?,editType:YHForm_Base_Model.YHForm_Edit_Type,maxRating:Int,bottom_TipsAttBackGroundColor:UIColor? = nil,idKey:String? = nil)->YHForm_StarRating_Model{
        let dataModel = YHForm_StarRating_Model.init();
        dataModel.attTitle = attTitle;
        dataModel.showUrlKey = showUrlKey;
        dataModel.submitUrlKey = submitUrlKey ?? "";
        dataModel.editType = editType;
        dataModel.maxRating = maxRating;
        //记录底部提示文本背景颜色
        dataModel.bottom_TipsAttBackGroundColor = bottom_TipsAttBackGroundColor ?? dataModel.bottom_TipsAttBackGroundColor;
        //记录idkey
        dataModel.idKey = idKey ?? showUrlKey;
        return dataModel;
    }
    
    // MARK: - 创建提示类型
    ///创建提示类型
    class func create_TipsModel(attTitle:NSMutableAttributedString?,forcedOccupancy:Bool? = nil,backGroundColor:UIColor? = nil,textAlignment:NSTextAlignment? = nil,idKey:String? = nil) ->YHForm_Tips_Model{
        let dataModel = YHForm_Tips_Model.init();
        dataModel.attTitle = attTitle ?? dataModel.attTitle;
        dataModel.forcedOccupancy = forcedOccupancy ?? dataModel.forcedOccupancy;
        dataModel.backGroundColor = backGroundColor ?? dataModel.backGroundColor;
        dataModel.idKey = idKey ?? "";
        dataModel.textAlignment = textAlignment ?? dataModel.textAlignment;
        return dataModel;
    }
    
}
