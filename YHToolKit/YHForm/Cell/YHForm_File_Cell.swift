//
//  YHForm_File_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/22.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//


import UIKit
import QuickLook

// MARK: - 代理
@objc protocol YHForm_File_Cell_Delegate:NSObjectProtocol{
    ///文件发生变动
    @objc optional func YHForm_File_Cell_Delegate_Update(title:String);
}

class YHForm_File_Cell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,YHForm_File_Cell_List_Add_Cell_Delegate,YHForm_File_Cell_List_File_Cell_Delegate,UIDocumentPickerDelegate,QLPreviewControllerDataSource{

    // MARK: - 代理
    ///文件代理
    weak var delegate:YHForm_File_Cell_Delegate?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        //取消点击变色
        self.selectionStyle = .none;
        //加载编辑类型提示控件
        self.contentView.addSubview(editType_TipsImageView);
        //加载标题控件
        self.contentView.addSubview(title_Label);
        //加载列表
        self.contentView.addSubview(list_CollectionView);
        //加载底部提示控件
        self.contentView.addSubview(tips_ContentView);
        //加载附加视图
        self.contentView.addSubview(additionalView);
    }
    
    // MARK: - 编辑类型-提示控件
    lazy var editType_TipsImageView:UIImageView = {
        let imageView = UIImageView.init(frame: CGRect(x: Form_CommonlyGap/2, y: Form_DefaultCellHeight/2-Form_CommonlyGap/4, width: Form_CommonlyGap/2, height: Form_CommonlyGap/2));
        return imageView;
    }();
    
    // MARK: - 标题
    lazy var title_Label:UILabel = {
        let label = UILabel.init(frame: CGRect(x: Form_CommonlyGap, y: 0, width: 0, height: Form_DefaultCellHeight));
        label.numberOfLines = 0;
        return label;
    }();
    
    // MARK: - 列表视图
    lazy var list_CollectionView:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = Form_CommonlyGap;
        let collectionView = UICollectionView.init(frame: CGRect(x: Form_CommonlyGap, y: Form_DefaultCellHeight, width: APP_WIDTH-Form_CommonlyGap*2, height:0),collectionViewLayout:flowLayout);
        collectionView.backgroundColor = .white;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.register(YHForm_File_Cell_List_Add_Cell.classForCoder(), forCellWithReuseIdentifier: "YHForm_File_Cell_List_Add_Cell_ID");
        collectionView.register(YHForm_File_Cell_List_File_Cell.classForCoder(), forCellWithReuseIdentifier: "YHForm_File_Cell_List_File_Cell_ID");
        return collectionView;
    }();
  
    // MARK: - cell个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if model.showType == .none && model.editType != .prohibitComplete && model.data.count < model.maxFile{
            return model.data.count+1;
        }else{
            return model.data.count;
        }
    }
    
    // MARK: - cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: APP_WIDTH-Form_CommonlyGap*2, height: Form_DefaultCellHeight);
    }
    
    // MARK: - cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row >= model.data.count{
            //展示添加
            let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "YHForm_File_Cell_List_Add_Cell_ID", for: indexPath) as? YHForm_File_Cell_List_Add_Cell) ?? YHForm_File_Cell_List_Add_Cell.init();
            cell.delegate = self;
            return cell;
        }else{
            //正常展示
            let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "YHForm_File_Cell_List_File_Cell_ID", for: indexPath) as? YHForm_File_Cell_List_File_Cell) ?? YHForm_File_Cell_List_File_Cell.init();
            cell.update_UI(dataModel: model.data[indexPath.row],row: indexPath.row);
            cell.delegate = self;
            return cell;
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
    
    // MARK: - 附加视图
    lazy var additionalView:UIView = {
        let view = UIView.init(frame:CGRect(x: 0, y: 0, width: APP_WIDTH, height: 0));
        view.isHidden = true;
        return view;
    }();
    
    // MARK: - 数据模型
    lazy var model:YHForm_File_Model = {
        return YHForm_File_Model();
    }();

    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_File_Model){
        //赋值模型
        self.model = dataModel;
        //判断编辑类型
        YHForm.calculation_Cell_EditTypeTipsImageView_Style(showType: model.showType, editType: model.editType, imageView: self.editType_TipsImageView);
        //赋值富文本标题
        self.title_Label.attributedText = model.attTitle;
     
        //赋值控件坐标
        self.title_Label.frame = model.titleFrame;
        self.list_CollectionView.frame = model.contentFrame;
        //处理提示视图
        self.handleTipsView();
        //处理附加视图
        if model.additionalView.frame.size.height > 0{
            self.additionalView.isHidden = false;
            switch model.additionalViewPosition {
            case .titleBottom://位于标题下面
                self.additionalView.frame.origin.y = model.titleFrame.size.height+model.titleFrame.origin.y;
                break;
            }
            self.additionalView.frame.size.height = model.additionalView.frame.size.height;
            self.additionalView.subviews.forEach({$0.removeFromSuperview()});
            self.additionalView.addSubview(model.additionalView);
        }else{
            self.additionalView.isHidden = true;
        }
        //刷新列表
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
    
    // MARK: - 点击了文件
    func YHForm_File_Cell_List_File_Cell_Delegate_Touch(index: Int) {
        //关闭页面键盘
        UIFactory.shared.CurrentController().view.endEditing(true);
        let element = model.data[index];
        //判断类型
        switch element.source {
        case .local:
            load_QLController(index:index);
            break;
        case .network:
            if FileCache_Manager.shared.isFileExistence(filePath: CoreData_Manager.shared.readCacheComparison(urlPath: element.fileUrlString)){
                //已经缓存好了
                load_QLController(index:index);
            }else{
                //没有缓存 开始下载
                downFile(index: index);
            }
            break;
        }
    }
    
    // MARK: -  下载文件
    func downFile(index:Int){
        //重新下载
        let element = self.model.data[index];
        hud_only.show_Loading(view: UIFactory.shared.CurrentController().view);
        FileCache_Manager.shared.down_File(urlString: model.data[index].fileUrlString) {[weak self] isSuccess  in
            if isSuccess{
                //下载成功
                element.fileName = element.fileUrlString.components(separatedBy: "/").last ?? "未知名称";
                element.fileSize = FileCache_Manager.shared.read_FileData(filePath: CoreData_Manager.shared.readCacheComparison(urlPath: element.fileUrlString)).calculateSize();
            }else{
                //下载失败
                self?.model.data[index].fileName = "再次加载失败,点击重试";
            }
            //完成
            //通知UI刷新
            DispatchQueue.main.async {[weak self] in
                //隐藏提示框
                hud_only.hide();
                //刷新UI
                self?.list_CollectionView.reloadData();
            }
        }
    }
    
    // MARK: - 加载文件查看器
    func load_QLController(index:Int){
        //找到当前点击的元素
        let seletModel = model.data[index];
        //过滤出来可展示数据
        let canSeletModel = canShowModel();
        //找到在可选数据中的下标
        let itemIndex = canSeletModel.firstIndex(of: seletModel) ?? 0;
        //判断是否超出范围
        if itemIndex < canSeletModel.count{
            qlController.currentPreviewItemIndex = index;

        }
        //展示预览控制器
        UIFactory.shared.CurrentController().present(qlController, animated: true, completion: nil);
        qlController.reloadData();
    }
    
    // MARK: - 文件预览控制器
    lazy var qlController:QLPreviewController = {
        let ql = QLPreviewController.init();
        ql.dataSource = self;
        return ql;
    }();
    
    // MARK: - 可以展示的数据
    func canShowModel() ->[YHForm_File_Cell.File_Model]{
        return model.data.filter { element in
            if element.source == .local || (element.source == .network && FileCache_Manager.shared.isFileExistence(filePath: CoreData_Manager.shared.readCacheComparison(urlPath: element.fileUrlString))){
                return true;
            }else{
                return false;
            }
        }
    }
    
    // MARK: - 文件预览数量
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return canShowModel().count;
    }
    
    // MARK: - 文件资源
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let element = canShowModel()[index];
        var fileUrlString = element.fileUrlString;
        if element.source == .network{
            fileUrlString = CoreData_Manager.shared.readCacheComparison(urlPath: fileUrlString);
            if fileUrlString.count <= 0 {
                fileUrlString = element.fileUrlString;
            }
        }
        return (URL.init(fileURLWithPath: fileUrlString) as? QLPreviewItem) ?? (URL.init(string: "http://www.yizhongpm.com/none")! as QLPreviewItem);
    }
    
    // MARK: - 删除文件
    func YHForm_File_Cell_List_File_Cell_Delegate_Remove(index: Int) {
        //删除文件
        self.model.data.remove(at: index);
        //通知刷新
        delegate?.YHForm_File_Cell_Delegate_Update?(title: self.model.attTitle.string);
    }
    
    // MARK: - 添加文件
    func YHForm_File_Cell_List_Add_Cell_Delegate_Add() {
        //关闭页面键盘
        UIFactory.shared.CurrentController().view.endEditing(true);
        //支持类型
        var documentTypes = [String]();
        //加载类型
        for type in self.model.types {
            switch type {
            case .word://word文档
                if !documentTypes.contains("com.microsoft.word.doc"){
                    documentTypes.append("com.microsoft.word.doc");
                    documentTypes.append("org.openxmlformats.wordprocessingml.document");
                }
                break;
            case .pdf://pdf
                if !documentTypes.contains("com.adobe.pdf"){
                    documentTypes.append("com.adobe.pdf");
                }
                break;
            case .excel:
                if !documentTypes.contains("com.microsoft.excel.xls"){
                    documentTypes.append("com.microsoft.excel.xls");
                    documentTypes.append("org.openxmlformats.spreadsheetml.sheet");
                }
                break;
            case .ppt:
                if !documentTypes.contains("com.microsoft.powerpoint.ppt"){
                    documentTypes.append("com.microsoft.powerpoint.ppt");
                    documentTypes.append("org.openxmlformats.presentationml.presentation");
                }
                break;
            }

        }
        //文件控制器
        let document = UIDocumentPickerViewController.init(documentTypes: documentTypes, in: .open);
        document.allowsMultipleSelection = true;
        document.delegate = self;
        UIFactory.shared.CurrentController().present(document, animated: true, completion: nil);
    }
    
    // MARK: - 选择了文件
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        //最大数量限制
        if urls.count+self.model.data.count > self.model.maxFile{
            hud_only.show_Text_AutoDisappear(text: "本次选择超出了最大选择数量,请重新选择", view: UIFactory.shared.CurrentController().view);
            return;
        }
        for url in urls{
            let fileName = url.lastPathComponent;
            let fileModel = File_Model.init();
            fileModel.type = YHForm_File_Cell.DetermineFileFormat(fileName: fileName);
            fileModel.fileName = fileName;
            //获取文件安全访问权限
            let authozied = url.startAccessingSecurityScopedResource();
            if authozied{
                let fileCoordinator = NSFileCoordinator();
                fileCoordinator.coordinate(readingItemAt: url, options: [.withoutChanges], error: nil) { newUrl in
                    if let data = try? Data.init(contentsOf: newUrl, options: [.mappedIfSafe]){
                        //缓存数据
                        if newUrl.absoluteString.count >= 1{
                            fileModel.fileUrlString = newUrl.lastPathComponent;
                        }else{
                            fileModel.fileUrlString = DataHandle.LocalTimeStampString();
                        }
                        //写入文件 记录文件本地路径
                        fileModel.fileUrlString = FileCache_Manager.shared.write_FileData_Local(name: fileModel.fileUrlString, fileData: data);
                        //计算大小
                        fileModel.fileSize = data.calculateSize();
                    }
                }
            }
            //停止安全访问权限
            url.stopAccessingSecurityScopedResource()
            //添加此数据模型
            self.model.data.append(fileModel);
        }
        //刷新列表
        delegate?.YHForm_File_Cell_Delegate_Update?(title: self.model.attTitle.string);
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}



// MARK: - 拓展
extension YHForm_File_Cell{
    // MARK: - 文件类
    class File_Model:NSObject{
        ///类型 - 默认类为pdf
        var type = fileType.pdf;
        ///来源- 默认本地数据
        var source = dataSource.local;
        ///是否可以编辑 none:可编辑  look:仅查看
        var showType = YHForm_Base_Model.YHForm_Show_Type.none;
        ///文件网络路径字符
        var fileUrlString = "";
        ///文件名称
        var fileName = "";
        ///文件大小
        var fileSize = "";
    }
    
    // MARK: - 文件类型
    enum fileType {
        ///pdf格式
        case pdf;
        ///word格式
        case word;
        ///excel格式
        case excel;
        ///ppt格式
        case ppt;
    }
    
    // MARK: - 数据来源
    enum dataSource {
        ///本地
        case local;
        ///网络
        case network;
    }
    
    // MARK: - 判断文件格式
    class func DetermineFileFormat(fileName:String) ->fileType{
        //判断是否pdf
        if fileName.hasSuffix(".pdf"){
            return .pdf;
        }
        //判断是否word
        if fileName.hasSuffix(".doc") || fileName.hasSuffix(".docx"){
            return .word;
        }
        //判断是否ppt
        if fileName.hasSuffix(".ppt") || fileName.hasSuffix(".pptx"){
            return .ppt;
        }
        //判断是否excel
        if fileName.hasSuffix(".xls") || fileName.hasSuffix(".xlsx"){
            return .excel;
        }
        //不识别的默认word
        return .word;
    }
    

    
}
