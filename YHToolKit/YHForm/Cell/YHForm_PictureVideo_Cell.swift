//
//  YHForm_PictureVideo_Cell.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2021/12/21.
//  Copyright © 2021 HeNanYiZhong. All rights reserved.
//

import UIKit
import TZImagePickerController
import Photos
import MBProgressHUD
import SKPhotoBrowser
import AVKit


// MARK: - 代理
@objc protocol YHForm_PictureVideo_Cell_Delegate:NSObjectProtocol{
    ///图片视频发生变动
    @objc optional func YHForm_PictureVideo_Cell_Delegate_Update(title:String);
    ///图片视频因添加发生变动
    @objc optional func YHForm_PictureVideo_Cell_Delegate_AddUpdate(title:String);
}

class YHForm_PictureVideo_Cell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,YHForm_PictureVideo_Cell_List_Add_Cell_Delegate,YHForm_PictureVideo_Cell_List_PictureVideo_Cell_Delegate,TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    // MARK: - 代理
    ///图片视频代理
    weak var delegate:YHForm_PictureVideo_Cell_Delegate?;
    
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
        flowLayout.minimumLineSpacing = 0;
        let collectionView = UICollectionView.init(frame: CGRect(x: Form_CommonlyGap/2, y: Form_DefaultCellHeight, width: APP_WIDTH-Form_CommonlyGap, height:0),collectionViewLayout:flowLayout);
        collectionView.backgroundColor = .white;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.register(YHForm_PictureVideo_Cell_List_PictureVideo_Cell.classForCoder(), forCellWithReuseIdentifier: "YHForm_PictureVideo_Cell_List_PictureVideo_Cell_ID");
        collectionView.register(YHForm_PictureVideo_Cell_List_Add_Cell.classForCoder(), forCellWithReuseIdentifier: "YHForm_PictureVideo_Cell_List_Add_Cell_ID");
        return collectionView;
    }();
  
    // MARK: - cell个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if model.showType == .none && model.editType != .prohibitComplete && model.data.count < model.maxImage{
            return model.data.count+1;
        }else{
            return model.data.count;
        }
    }
    
    // MARK: - cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (APP_WIDTH-Form_CommonlyGap)/4, height: (APP_WIDTH-Form_CommonlyGap)/4);
    }
    
    // MARK: - cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row >= model.data.count{
            //展示添加
            let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "YHForm_PictureVideo_Cell_List_Add_Cell_ID", for: indexPath) as? YHForm_PictureVideo_Cell_List_Add_Cell) ?? YHForm_PictureVideo_Cell_List_Add_Cell.init();
            cell.delegate = self;
            return cell;
        }else{
            //正常展示
            let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "YHForm_PictureVideo_Cell_List_PictureVideo_Cell_ID", for: indexPath) as? YHForm_PictureVideo_Cell_List_PictureVideo_Cell) ?? YHForm_PictureVideo_Cell_List_PictureVideo_Cell.init();
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
    
    // MARK: - 数据模型
    lazy var model:YHForm_PictureVideo_Model = {
        return YHForm_PictureVideo_Model();
    }();

    // MARK: - 更新UI
    func update_UI(dataModel:YHForm_PictureVideo_Model){
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
        
        //处理是否能编辑
        self.model.data.forEach { element in
            if self.model.showType == .none && self.model.editType != .prohibitComplete{
                element.showType = .none;
            }else{
                element.showType = .look;
            }
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
    
    // MARK: - 图片视频点击
    func YHForm_PictureVideo_Cell_List_PictureVideo_Cell_Delegate_Touch(index: Int) {
        //关闭页面键盘
        UIFactory.shared.CurrentController().view.endEditing(true);
        if model.data[index].type == .video{
            //视频
            let player = AVPlayer.init(url: model.data[index].videoUrl ?? URL.init(string: "http://yizhongpm.com/none")!);
            let playerVC = AVPlayerViewController.init();
            playerVC.player = player;
            UIFactory.shared.CurrentController().present(playerVC, animated: true, completion: nil);
            player.play();
        }else{
            //图片
            var images = [SKPhoto]();
            var row = 0;
            var tpIndex = 0;
            var imageIndex = 0;
            for imageModel in model.data{
                if imageModel.type == .picture{
                    if imageModel.source == .local {
                        //本地图片
                        images.append(SKPhoto.photoWithImage(imageModel.localImage ?? UIImage.init(named: "yh_Public_Clear")!));
                    }else{
                        //网络图片
                        images.append(SKPhoto.photoWithImageURL(imageModel.imageUrlString));
                    }
                    if tpIndex == index{
                        imageIndex = row;
                    }
                    row = row+1;
                }
                tpIndex = tpIndex+1;
            }
            SKPhotoBrowserOptions.enableSingleTapDismiss = true;
            let browser = SKPhotoBrowser.init(photos: images, initialPageIndex: imageIndex);
            UIFactory.shared.CurrentController().present(browser, animated: true, completion: nil);
        }
    }
    
    // MARK: - 图片视频删除
    func YHForm_PictureVideo_Cell_List_PictureVideo_Cell_Delegate_Remove(index: Int) {
        //删除模型
        self.model.data.remove(at: index);
        //通知刷新列表
        delegate?.YHForm_PictureVideo_Cell_Delegate_Update?(title: self.model.attTitle.string);
    }
    
    // MARK: - 添加cell点击事件
    func YHForm_PictureVideo_Cell_List_Add_Cell_Delegate_Add() {
        //关闭页面键盘
        UIFactory.shared.CurrentController().view.endEditing(true);
        //判断最大限制
        if model.data.count >= model.maxImage {
            hud_only.show_Text_AutoDisappear(text: "您已选满"+String(model.data.count)+"个", view: UIFactory.shared.CurrentController().view);
            return;
        }
        
        //仅拍照
        if model.source == .photograph{
            //打开相机
            self.openCamera();
            return;
        }
        
        //未超出数量限制
        let picker = TZImagePickerController.init(maxImagesCount: model.maxImage-model.data.count, delegate: self);
        //判断类型
        switch model.type {
        case .picture://图片类型
            //禁止选择视频
            picker?.allowPickingVideo = false;
            break;
        case .video://视频类型
            //禁止选择图片
            picker?.allowPickingImage = false;
            //开启视频多选
            picker?.allowPickingMultipleVideo = true;
            break;
        case .blend://混合类型
            //开启视频多选
            picker?.allowPickingMultipleVideo = true;
            break;
        }
        
        //判断数据来源
        switch model.source {
        case .album://相册
            //禁止拍照
            picker?.allowTakePicture = false;
            picker?.allowTakeVideo = false;
            break;
        default:
            break;
        }
        
        //是否允许原图
        picker?.allowPickingOriginalPhoto = model.isOriginal;
        //展示选中序号
        picker?.showSelectedIndex = true;
        UIFactory.shared.CurrentController().present(picker ?? Base_ViewController.init(), animated: true, completion: nil);
    }
    
    // MARK: - 选择了图片
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        //PHAsset.sourceType 用来判断来源 是本地数据还是iCloud数据
        //PHAsset.mediaType 0未知 1图片 2视频 3音频
        //提示文本
        var tipsString = "图片处理工具加载中......";
        //加载提示框
        let mbphud = MBProgressHUD.showAdded(to: UIFactory.shared.CurrentController().view, animated: true);
        mbphud.bezelView.blurEffectStyle = .dark;
        mbphud.mode = .text;
        mbphud.label.numberOfLines = 0;
        mbphud.label.textColor = .white;
        mbphud.label.text = tipsString;
        //总数
        let total = assets.count;
        var index = 0;
        var fail = 0;
        //临时数据组
        var temporaryModels = [PictureVideo_Model]();
        let multiTask = DispatchGroup();
        let groupQueue = DispatchQueue(label: "YH_handlePictureVideo")
        //循环数据
        groupQueue.async {
            for asset in (assets as? [PHAsset]) ?? [PHAsset]() {
                multiTask.enter();
                switch asset.mediaType {
                case .image://图片类型
                    //判断是否压缩
                    if isSelectOriginalPhoto{
                        //用户选择了原图 并且 设置了用户可以选择原图 不压缩
                           TZImageManager.default().getOriginalPhoto(with: asset) { progress, error, _, _ in
                            tipsString = "第"+String(index+1)+"-读取原图中,进度: "+progress.format_TwoDecimalPlaces_ToString()+"%";
                            DispatchQueue.main.async {
                                mbphud.label.text = tipsString;
                            }
                        } newCompletion: { image, info, isDegraded in
                            //完成
                            if isDegraded == false{
                                let elementModel = PictureVideo_Model.init();
                                elementModel.localImage = image;
                                temporaryModels.append(elementModel);
                                //计算提示信息
                                tipsString = "处理中("+String(index+1)+"/"+String(total)+")";
                                if fail >= 1{
                                    tipsString = tipsString+",处理失败数("+String(fail)+")";
                                }
                                DispatchQueue.main.async {
                                    mbphud.label.text = tipsString;
                                }
                                index = index+1;
                                multiTask.leave();
                            }
                        }
                    }else{
                        //压缩
                        let elementModel = PictureVideo_Model.init();
                        elementModel.localImage = photos[index].yhImageCompress();
                        temporaryModels.append(elementModel);
                        index = index+1;
                        multiTask.leave();
                    }
                    break;
                case .video://视频类型
                    //解析
                    TZImageManager.default().getVideoWith(asset) { progress, error, _, _ in
                        tipsString = "第"+String(index+1)+"-读取视频中,进度: "+progress.format_TwoDecimalPlaces_ToString()+"%";
                        DispatchQueue.main.async {
                            mbphud.label.text = tipsString;
                        }
                    } completion: {[weak self] apItem, info in
                        //判断是否压缩视频 临时处理 依靠是否允许选择原图来处理是否压缩图片
                        if self?.model.isOriginal == false{
                            //不允许选择原图 必然压缩
                            tipsString = "第"+String(index+1)+"-压缩视频中......";
                            DispatchQueue.main.async {
                                mbphud.label.text = tipsString;
                            }
                            DataHandle.shared.localVideoCompressed(asset: apItem?.asset ?? AVAsset.init(url: URL.init(fileURLWithPath: "")), outNameString: nil) { status, progress,urlString in
                                switch status {
                                case .success:
                                    //压缩成功
                                    let elementModel = PictureVideo_Model.init();
                                    elementModel.type = .video;
                                    elementModel.localImage = photos[index];
                                    elementModel.videoUrl = URL.init(fileURLWithPath: urlString);
                                    temporaryModels.append(elementModel);
                                    index = index+1;
                                    multiTask.leave();
                                    break;
                                case .fail:
                                    //压缩失败
                                    let elementModel = PictureVideo_Model.init();
                                    elementModel.type = .video;
                                    elementModel.localImage = photos[index];
                                    elementModel.videoUrl = ((apItem?.asset as? AVURLAsset) ?? AVURLAsset.init(url: URL.init(string: "http://yizhongpm.com/none")!)).url;
                                    temporaryModels.append(elementModel);
                                    index = index+1;
                                    multiTask.leave();
                                    break;
                                case .compressing:
                                    tipsString = "第"+String(index+1)+"-压缩视频中-进度:"+String(progress)+"%";
                                    DispatchQueue.main.async {
                                        mbphud.label.text = tipsString;
                                    }
                                    break;
                                }
                            }
                        }else{
                            //不压缩
                            let elementModel = PictureVideo_Model.init();
                            elementModel.type = .video;
                            elementModel.localImage = photos[index];
                            elementModel.videoUrl = ((apItem?.asset as? AVURLAsset) ?? AVURLAsset.init(url: URL.init(string: "http://yizhongpm.com/none")!)).url;
                            temporaryModels.append(elementModel);
                            index = index+1;
                            multiTask.leave();
                        }
                    }
                    break;
                default://其它类型暂不支持
                    fail = fail+1;
                    tipsString = "处理中("+String(index+1)+"/"+String(total)+")";
                    if fail >= 1{
                        tipsString = tipsString+",处理失败数("+String(fail)+")";
                    }
                    DispatchQueue.main.async {
                        mbphud.label.text = tipsString;
                    }
                    index = index+1;
                    multiTask.leave();
                    break;
                }
                multiTask.wait();
            }
            //执行完毕
            multiTask.notify(queue: DispatchQueue.main) {[weak self] in
                //隐藏提示框
                mbphud.hide(animated: true);
                //组合数据模型
                self?.model.data.append(contentsOf: temporaryModels);
                //代理刷新
                self?.delegate?.YHForm_PictureVideo_Cell_Delegate_Update?(title: self?.model.attTitle.string ?? "");
                //代理通知添加变更
                self?.delegate?.YHForm_PictureVideo_Cell_Delegate_AddUpdate?(title: self?.model.attTitle.string ?? "")
            }
        }
        
    }
    
    // MARK: - 相机拍照完成
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {[weak self] in
            //处理数据
            self?.cameraComplete(info: info);
        }
    }
    
    //相机拍摄结束 处理数据
    func cameraComplete(info: [UIImagePickerController.InfoKey : Any]){
        //临时数据组
        var temporaryModels = [PictureVideo_Model]();
        //判断类型
        switch (info[.mediaType] as? String) ?? "" {
        case "public.image"://图片
            //原图
            let originalImage:UIImage = (info[.originalImage] as? UIImage) ?? UIImage.init();
            if model.isOriginal{
                //原图
                let elementModel = PictureVideo_Model.init();
                elementModel.localImage = originalImage;
                temporaryModels.append(elementModel);
            }else{
                let elementModel = PictureVideo_Model.init();
                elementModel.localImage = originalImage.yhImageCompress();
                temporaryModels.append(elementModel);
            }
            //组合数据模型
            self.model.data.append(contentsOf: temporaryModels);
            //代理刷新
            self.delegate?.YHForm_PictureVideo_Cell_Delegate_Update?(title: self.model.attTitle.string);
            self.delegate?.YHForm_PictureVideo_Cell_Delegate_AddUpdate?(title: self.model.attTitle.string);
            break;
        case "public.movie"://视频
            if let videoUrl = info[.mediaURL] as? URL{
                let elementModel = PictureVideo_Model.init();
                elementModel.type = .video;
                let avAsset = AVAsset.init(url: videoUrl);
                //生成视频截图
                let assetImg = AVAssetImageGenerator(asset: avAsset);
                assetImg.appliesPreferredTrackTransform = true;
                assetImg.apertureMode = .encodedPixels;
                do{
                    let cgimgref = try assetImg.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 600), actualTime: nil);
                    elementModel.localImage = UIImage.init(cgImage: cgimgref).yhImageCompress();
                }catch{
                    elementModel.localImage = UIImage.init(named: "public_Image_error_square");
                }
                
                //判断是否需要压缩视频
                if self.model.isOriginal == false{
                    //压缩
                    //加载提示框
                    let mbphud = MBProgressHUD.showAdded(to: UIFactory.shared.CurrentController().view, animated: true);
                    mbphud.bezelView.blurEffectStyle = .dark;
                    mbphud.mode = .text;
                    mbphud.label.numberOfLines = 0;
                    mbphud.label.textColor = .white;
                    mbphud.label.text = "压缩视频中......";
                    DispatchQueue.main.async {
                        DataHandle.shared.localVideoCompressed(asset: avAsset, outNameString: nil) {[weak self] status, progress,urlString in
                                switch status {
                                case .success:
                                    //隐藏提示框
                                    mbphud.hide(animated: true);
                                    //压缩成功
                                    elementModel.videoUrl = URL.init(fileURLWithPath: urlString);
                                    temporaryModels.append(elementModel);
                                    //组合数据模型
                                    self?.model.data.append(contentsOf: temporaryModels);
                                    //代理刷新
                                    self?.delegate?.YHForm_PictureVideo_Cell_Delegate_Update?(title: self?.model.attTitle.string ?? "");
                                    self?.delegate?.YHForm_PictureVideo_Cell_Delegate_AddUpdate?(title: self?.model.attTitle.string ?? "");
                                    break;
                                case .fail:
                                    //隐藏提示框
                                    mbphud.hide(animated: true);
                                    //压缩失败
                                    elementModel.videoUrl = videoUrl;
                                    temporaryModels.append(elementModel);
                                    //组合数据模型
                                    self?.model.data.append(contentsOf: temporaryModels);
                                    //代理刷新
                                    self?.delegate?.YHForm_PictureVideo_Cell_Delegate_Update?(title: self?.model.attTitle.string ?? "");
                                    self?.delegate?.YHForm_PictureVideo_Cell_Delegate_AddUpdate?(title: self?.model.attTitle.string ?? "");
                                    break;
                                case .compressing:
                                    mbphud.label.text = "压缩视频中-进度:"+String(progress)+"%";
                                    break;
                                }
                        }
                    }
                }else{
                    //不压缩
                    elementModel.videoUrl = videoUrl;
                    temporaryModels.append(elementModel);
                    //组合数据模型
                    self.model.data.append(contentsOf: temporaryModels);
                    //代理刷新
                    self.delegate?.YHForm_PictureVideo_Cell_Delegate_Update?(title: self.model.attTitle.string);
                    self.delegate?.YHForm_PictureVideo_Cell_Delegate_AddUpdate?(title: self.model.attTitle.string);
                }
            }else{
                hud_only.show_Text_AutoDisappear(text: "没有获取到视频", view: UIFactory.shared.CurrentController().view);
            }
            break;
        default:
            hud_only.show_Text_AutoDisappear(text: "暂不支持所选类型", view: UIFactory.shared.CurrentController().view);
            break;
        }
        
    }
    

    
    //打开相机
    func openCamera(){
        //判断权限
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video);
        //相机拒绝｜不可用
        if authStatus == .denied || authStatus == .restricted{
            hud_only.show_Text_AutoDisappear(text: "请前往设置中开启相机权限", view: UIFactory.shared.CurrentController().view);
            return;
        }
        //相机未授权
        if authStatus == .notDetermined{
            AVCaptureDevice.requestAccess(for: .video) {[weak self] granted in
                if granted{
                    self?.openCamera();
                }
            }
            return;
        }
        //相册权限
        if PHPhotoLibrary.authorizationStatus() == .notDetermined{
            //尚未授权
            TZImageManager.default().requestAuthorization {[weak self] in
                self?.openCamera();
            }
            return;
        }
        //相册拒绝｜不可用
        if PHPhotoLibrary.authorizationStatus() == .restricted || PHPhotoLibrary.authorizationStatus() == .denied{
            hud_only.show_Text_AutoDisappear(text: "请前往设置中开启相册权限", view: UIFactory.shared.CurrentController().view);
            return;
        }
        //摄像头是否可用
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            hud_only.show_Text_AutoDisappear(text: "当前设备相机不可以", view: UIFactory.shared.CurrentController().view);
            return;
        }
        
        let imagePickerController = UIImagePickerController.init();
        imagePickerController.delegate = self;
        imagePickerController.sourceType = .camera;
        switch model.type {
        case .picture:
            imagePickerController.mediaTypes = ["public.image"];
            break;
        case .video:
            imagePickerController.mediaTypes = ["public.movie"];
            break;
        case .blend:
            imagePickerController.mediaTypes = ["public.image","public.movie"];
            break;
        }
        UIFactory.shared.CurrentController().present(imagePickerController, animated: true, completion: nil);
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}

// MARK: - 拓展
extension YHForm_PictureVideo_Cell{
    
    // MARK: - 图片视频类
    class PictureVideo_Model:NSObject{
        ///类型 - 默认类为图片
        var type = dataType.picture;
        ///来源- 默认本地数据
        var source = dataSource.local;
        ///是否可以编辑 none:可编辑  look:仅查看
        var showType = YHForm_Base_Model.YHForm_Show_Type.none;
        ///图片网络路径字符
        var imageUrlString = "";
        ///本地图片
        var localImage:UIImage?;
        ///视频路径 本地或者网络都使用路径
        var videoUrl:URL?;
    }
    
    // MARK: - 数据类型
    enum dataType {
        ///图片类
        case picture;
        ///视频类
        case video;
    }
    
    // MARK: - 数据来源
    enum dataSource {
        ///本地
        case local;
        ///网络
        case network;
    }
    
}
