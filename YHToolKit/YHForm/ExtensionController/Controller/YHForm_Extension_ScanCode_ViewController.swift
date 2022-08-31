//
//  YHForm_Extension_ScanCode_ViewController.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2022/5/30.
//  Copyright © 2022 HeNanYiZhong. All rights reserved.
//


import UIKit
import AVFoundation
import TZImagePickerController
import Vision


// MARK: - 代理
@objc protocol YHForm_Extension_ScanCode_ViewController_Delegate:NSObjectProtocol{
    ///扫码结果
    @objc optional func YHForm_Extension_ScanCode_ViewController_Delegate_CodeResult(Result:String);
}

class YHForm_Extension_ScanCode_ViewController: UIViewController,TZImagePickerControllerDelegate{
    
    ///扫码结果代理
    weak var delegate:YHForm_Extension_ScanCode_ViewController_Delegate?;
    ///预览图层
    var scanPreviewLayer:AVCaptureVideoPreviewLayer!;
    ///输出捕捉
    var output:AVCaptureMetadataOutput!;
    ///输入捕捉
    var input:AVCaptureDeviceInput!;
    ///扫描会话
    var scanSession:AVCaptureSession?;
    ///扫码类型 默认混合都支持
    var scanCodeType = ScanCodeType.blend;
    ///是否当前处于一图多码选择中
    var isMultipleCodeSelect = false;
    ///是否正在打开相册
    var isShowPhotos = false;
    ///多码选择按钮数组
    var multipleCodeSelectButtonArray = [[String:Any]]();
    
    override func viewDidLoad(){
        super.viewDidLoad();
        //加载UI
        self.load_UI();
        //初始化扫描会话
        self.setupScanSession();
        //监听屏幕旋转
        NotificationCenter.default.addObserver(self, selector: #selector(receiverNotification), name: UIDevice.orientationDidChangeNotification, object: nil);
    }
    
    // MARK: - 加载UI
    func load_UI(){
        //加载返回按钮
        self.view.addSubview(navBackButton);
        //加载取消按钮
        self.view.addSubview(cancelSelectButton);
        //加载闪关灯按钮
        self.view.addSubview(flashLampButton);
        //加载相册按钮
        self.view.addSubview(albumButton);
        //加载扫描线
        self.view.addSubview(scanLine);
        //展示扫描UI
        self.showScanUI();
    }
    
    // MARK: - 返回按钮
    lazy var navBackButton:UIButton = {
        let button = UIButton.init(frame: CGRect(x: UIMargin_Float*0.75, y: NavigationBarAndStatusBarSafa_Height-NavgationBar_Height+UIMargin_Float*0.5, width: 40, height: 40));
        button.setImage(UIImage.init(named: "Public_Back_White"), for: .normal);
        button.addTarget(self, action: #selector(navBackButton_Touch), for: .touchUpInside);
        return button;
    }();
    
    // MARK: - 取消选择按钮
    lazy var cancelSelectButton:UIButton = {
        let button = UIButton.init(frame: CGRect(x: UIMargin_Float*0.75, y: NavigationBarAndStatusBarSafa_Height-NavgationBar_Height+UIMargin_Float*0.5, width: 50, height: 40));
        button.setTitle("取消", for: .normal);
        button.titleLabel?.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 14));
        button.addTarget(self, action: #selector(cancelSelectButton_Touch), for: .touchUpInside);
        button.isHidden = true;
        return button;
    }();
    
    
    
    // MARK: - 返回按钮点击事件
    @objc func navBackButton_Touch(){
        self.dismiss(animated: true, completion: nil);
    }
    
    // MARK: - 闪光灯按钮
    lazy var flashLampButton:UIButton = {
        let button = UIButton.init(frame: CGRect(x: APP_WIDTH/2-APP_WIDTH/14, y: APP_HEIGHT-SafaAreaBottom_Height-100, width: APP_WIDTH/7, height: APP_WIDTH/7));
        button.setImage(UIImage.init(named: "Public_FlashLamp_False"), for: .normal);
        button.setImage(UIImage.init(named: "Public_FlashLamp_True"), for: .selected);
        button.addTarget(self, action: #selector(flashLampButton_Touch), for: .touchUpInside);
        return button;
    }();
    
    // MARK: - 闪光灯按钮点击事件
    @objc func flashLampButton_Touch(){
        flashLampButton.isSelected = !flashLampButton.isSelected;
        self.setUpFlash(torchMode: flashLampButton.isSelected);
    }
    
    // MARK: - 相册按钮
    lazy var albumButton:UIButton = {
        let button = UIButton.init(frame: CGRect(x: APP_WIDTH-UIMargin_Float-APP_WIDTH/8, y: APP_HEIGHT-SafaAreaBottom_Height-90, width: APP_WIDTH/8, height: APP_WIDTH/8));
        button.setImage(UIImage.init(named: "Public_Album-White"), for: .normal);
        button.addTarget(self, action: #selector(albumButton_Touch), for: .touchUpInside);
        button.center.y = flashLampButton.center.y;
        return button;
    }();
    
    // MARK: - 相册按钮点击事件
    @objc func albumButton_Touch(){
        //停止扫描
        self.endScan();
        //设置相册打开状态
        self.isShowPhotos = true;
        //打开相册
        let pickerController = TZImagePickerController.init(maxImagesCount: 1, delegate: self);
        pickerController?.modalPresentationStyle = .fullScreen;
        pickerController?.allowPickingVideo = false;
        pickerController?.allowPreview = false;
        pickerController?.allowPickingOriginalPhoto = false;
        self.present(pickerController ?? Base_ViewController.init(), animated: true, completion: nil);
    }

    // MARK: - 选择了图片
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        if photos.count > 0{
            if let myCGImage = photos.first?.cgImage{
                let imageRequestHandle = VNImageRequestHandler(cgImage: myCGImage, options: [:]);
                let barcodeRequest = VNDetectBarcodesRequest();
                try? imageRequestHandle.perform([barcodeRequest]);
                let barCodeResults = barcodeRequest.results;
                if barCodeResults?.count ?? 0 > 0 {
                    var fistString = "";
                    barCodeResults?.forEach({ result in
                        if fistString.count <= 0{
                            switch scanCodeType {
                            case .barCode:
                                if result.symbology.rawValue != "VNBarcodeSymbologyQR"{
                                    fistString = result.payloadStringValue ?? "";
                                }
                                break;
                            case .QRCode:
                                if result.symbology.rawValue == "VNBarcodeSymbologyQR"{
                                    fistString = result.payloadStringValue ?? "";
                                }
                                break;
                            case .blend:
                                //扫码结果
                                fistString = result.payloadStringValue ?? "";
                                break;
                            }
                        }
                    })
                    //判断是否有值
                    if fistString.count >= 1{
                        //扫码结果
                        self.scanCodeResult(result: fistString);
                        return;
                    }
                }
            }
        }
        //开始扫描
        self.startScan();
        //修改相册打开状态
        self.isShowPhotos = false;
        hud_only.show_Text_AutoDisappear(text: "未获取到可识别图片", view: self.view);
    }
   
    // MARK: - 取消选择图片
    func tz_imagePickerControllerDidCancel(_ picker: TZImagePickerController!) {
        //开始扫描
        self.startScan();
        //修改相册打开状态
        self.isShowPhotos = false;
    }
    
    // MARK: - 扫描线
    lazy var scanLine:UIImageView = {
        let iv = UIImageView.init();
        iv.frame = CGRect(x: APP_WIDTH/5, y: APP_HEIGHT/5, width: APP_WIDTH/5*3, height: 2);
        iv.image = UIImage(named: "Public_Line_MainColor");
        return iv;
    }()
    
    // MARK: - 屏幕旋转通知
    @objc func receiverNotification() {
        //重新设置识别区域
        setLayerOrientationByDeviceOritation();
    }
    
    //初始化扫描会话
    func setupScanSession(){
        do{
            //设置捕捉设备为视频捕捉
            guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
                hud_only.show_Text_AutoDisappear(text: "摄像头不可用,请前往设置中开启此权限", view: self.view);
                DispatchQueue.main.asyncAfter(deadline: .now()+HUD_AfterDelay_Default) {[weak self] in
                    //销毁
                    self?.dismiss(animated: true, completion: nil);
                }
                return;
            }
            //设置设备输入
            input = try AVCaptureDeviceInput(device: device);
            //设置设备输出
            output = AVCaptureMetadataOutput();
            //设置输出代理
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main);
            //设置扫描会话
            let  scanSession = AVCaptureSession();
            //设置为高质量模式
            scanSession.canSetSessionPreset(.high);
            //添加输入
            if scanSession.canAddInput(input){
                scanSession.addInput(input)
            }
            //添加输出
            if scanSession.canAddOutput(output){
                scanSession.addOutput(output)
            }
            //设置扫描类型(二维码和条形码)
            switch scanCodeType {
            case .barCode:
                output.metadataObjectTypes = [.code128,.itf14,.ean13];
                break;
            case .QRCode:
                output.metadataObjectTypes = [.qr];
                break;
            case .blend:
                output.metadataObjectTypes = [.code128,.itf14,.ean13,.qr];
                break;
            }
            //预览图层
            let scanPreviewLayer = AVCaptureVideoPreviewLayer(session:scanSession);
            //设置预览图层填充方式
            scanPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
            //设置预览图片大小
            scanPreviewLayer.frame = view.layer.bounds;
            //赋值扫描类型
            self.scanPreviewLayer = scanPreviewLayer;
            //重新设置识别区域
            setLayerOrientationByDeviceOritation();
            //保存会话
            self.scanSession = scanSession;
        }catch{
            //摄像头不可用
            hud_only.show_Text_AutoDisappear(text: "摄像头不可用,请前往设置中开启此权限", view: self.view);
            DispatchQueue.main.asyncAfter(deadline: .now()+HUD_AfterDelay_Default) {[weak self] in
                //销毁
                self?.dismiss(animated: true, completion: nil);
            }
            return;
        }
    }
    
    // MARK: - 设置识别区域
    func setLayerOrientationByDeviceOritation() {
        //判断预览图层是否初始化完毕
        if(scanPreviewLayer == nil){
            return
        }
        //设置预览图片frame
        scanPreviewLayer.frame = view.layer.bounds
        //把预览图层放在最前面
        view.layer.insertSublayer(scanPreviewLayer, at: 0);
        //获取设备方向
        let screenOrientation = UIDevice.current.orientation;
        //根据设备方向设置预览图层方向
        if(screenOrientation == .portrait){
            scanPreviewLayer.connection?.videoOrientation = .portrait
        }else if(screenOrientation == .landscapeLeft){
            scanPreviewLayer.connection?.videoOrientation = .landscapeRight
        }else if(screenOrientation == .landscapeRight){
            scanPreviewLayer.connection?.videoOrientation = .landscapeLeft
        }else if(screenOrientation == .portraitUpsideDown){
            scanPreviewLayer.connection?.videoOrientation = .portraitUpsideDown
        }else{
            scanPreviewLayer.connection?.videoOrientation = .landscapeRight
        }
        //设置扫描区域
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: nil, using: {[weak self] (noti) in
            //设置识别区域 1为全部
            self?.output.rectOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
        })
    }

    //设备旋转后重新布局
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //重新设置识别区域
        setLayerOrientationByDeviceOritation();
    }
    
    //开始扫描
    func startScan(){
        //扫描指示线开始动画
        scanLine.layer.add(scanAnimation(), forKey: "scan");
        guard let scanSession = scanSession else { return }
        if !scanSession.isRunning{
            //扫描会话开始执行
            scanSession.startRunning();
        }
    }
    
    // MARK: - 结束扫描
    func endScan(){
        //停止扫描动画
        self.scanLine.layer.removeAllAnimations();
        //停止扫描会话
        self.scanSession!.stopRunning()
    }
    
    // MARK: - 扫描动画
    func scanAnimation() -> CABasicAnimation{
        //开始坐标
        let startPoint = CGPoint(x:scanLine.center.x,y:APP_HEIGHT/5);
        //结束坐标
        let endPoint = CGPoint(x:scanLine.center.x,y:APP_HEIGHT/5*4);
        //动画类型
        let translation = CABasicAnimation(keyPath: "position");
        translation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        translation.fromValue = NSValue(cgPoint: startPoint);
        translation.toValue = NSValue(cgPoint: endPoint);
        translation.duration = 3.0
        translation.repeatCount = MAXFLOAT
        translation.autoreverses = true
        return translation
    }
    
    
    // MARK: - 设置闪光灯
    func setUpFlash(torchMode:Bool){
        if !checkCameraPermission(){
            return;
        }
        try? input.device.lockForConfiguration()
        input.device.torchMode = torchMode ? AVCaptureDevice.TorchMode.on : AVCaptureDevice.TorchMode.off;
        input.device.unlockForConfiguration()
    }
    
    // MARK: - 获取到了扫码结果
    func scanCodeResult(result:String){
        //传递扫码结果
        self.delegate?.YHForm_Extension_ScanCode_ViewController_Delegate_CodeResult?(Result: result);
        //关闭页面
        self.dismiss(animated: true, completion: nil);
    }
    
    // MARK: - 展示扫描UI
    func showScanUI(){
        //展示返回按钮
        navBackButton.isHidden = false;
        //隐藏取消按钮
        cancelSelectButton.isHidden = true;
        //展示闪关灯按钮
        flashLampButton.isHidden = false;
        //展示相册按钮
        albumButton.isHidden = false;
        //展示扫描线
        scanLine.isHidden = false;
    }
    
    // MARK: - 展示选择UI
    func showSelectUI(){
        //隐藏返回按钮
        navBackButton.isHidden = true;
        //展示取消按钮
        cancelSelectButton.isHidden = false;
        //隐藏闪关灯按钮
        flashLampButton.isHidden = true;
        //隐藏相册按钮
        albumButton.isHidden = true;
        //隐藏扫描线
        scanLine.isHidden = true;
    }
    
    // MARK: - 取消选择按钮点击事件
    @objc func cancelSelectButton_Touch(){
        //隐藏所有选择按钮
        self.multipleCodeSelectButtonArray.forEach { dic in
            (dic["button"] as? UIButton)?.removeFromSuperview();
        }
        //清空选择按钮数组
        self.multipleCodeSelectButtonArray.removeAll();
        //取消选择状态
        self.isMultipleCodeSelect = false;
        //展示扫描UI
        self.showScanUI();
        //开始扫描
        self.startScan();
    }
    
    // MARK: - 展示多个二维码｜条形码让用户选择
    func showMultipleCodeSelect(codeObjects:[AVMetadataMachineReadableCodeObject]){
        var index = 1;
        //清空选择按钮数组
        self.multipleCodeSelectButtonArray.removeAll();
        codeObjects.forEach { element in
            if let frameObj = scanPreviewLayer.transformedMetadataObject(for: element){
                let button = self.createCodeSelectButton(index:index, frame: frameObj.bounds);
                self.multipleCodeSelectButtonArray.append(["index" : index,"button":button,"content":element.stringValue ?? ""]);
                self.view.addSubview(button);
                index = index+1;
            }
        }
    }
    
    // MARK: - 选择码点击事件
    @objc func codeSelectButton_Touch(button:UIButton){
        self.multipleCodeSelectButtonArray.forEach { dic in
            if dic["index"] as? Int == button.touch_Index{
                self.scanCodeResult(result: (dic["content"] as? String) ?? "");
            }
        }
    }
    
    // MARK: - 创建选择码按钮
    func createCodeSelectButton(index:Int,frame:CGRect) ->UIButton{
        let button = UIButton.init(frame:CGRect(x: frame.origin.x+frame.size.width/2-Form_DefaultCellHeight/2, y: frame.origin.y+frame.size.height/2-Form_DefaultCellHeight/2, width: Form_DefaultCellHeight, height: Form_DefaultCellHeight));
        button.touch_Index = index;
        button.setTitle(String(index), for: .normal);
        button.backgroundColor = UIColor.init(red: 255/255.0, green: 102/255.0, blue: 0/255.0, alpha: 0.5);
        button.layer.cornerRadius = button.frame.size.height/2;
        button.layer.masksToBounds = true;
        button.addTarget(self, action: #selector(codeSelectButton_Touch), for: .touchUpInside);
        return button;
    }
    
    // MARK: - 视图即将出现
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated);
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        //判断是否正在选择要识别的码
        if !isMultipleCodeSelect && !isShowPhotos{
            //开始扫描
            self.startScan();
        }
    }

    // MARK: 视图即将消失
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        //展示导航栏
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        //关闭闪光灯
        self.setUpFlash(torchMode: false);
    }
    
    
    //MARK: - 页面销毁
    deinit{
        ///移除通知
        NotificationCenter.default.removeObserver(self);
    }
    
}


//MARK: - 拓展
extension YHForm_Extension_ScanCode_ViewController:AVCaptureMetadataOutputObjectsDelegate{
    
    
    //捕捉扫描结果
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //结束扫描
        self.endScan();
        //扫描完成
        var codeObjs = [AVMetadataMachineReadableCodeObject]();
        metadataObjects.forEach { element in
            if let codeObj = element as? AVMetadataMachineReadableCodeObject{
                codeObjs.append(codeObj);
            }
        }
        //处理
        if codeObjs.count > 0 {
            if codeObjs.count == 1{
                //只有一个结果 传递扫码结果
                self.scanCodeResult(result: codeObjs.first?.stringValue ?? "");
            }else{
                //有多个结果
                self.isMultipleCodeSelect = true;
                //展示选择视图
                self.showSelectUI();
                //展示多个选择按钮让用户选择一个二维码
                self.showMultipleCodeSelect(codeObjects: codeObjs);
            }
        }else{
            //没有可识别结果
            hud_only.show_Text_AutoDisappear(text: "没有获取到支持类型的二维码或条形码", view: self.view);
            DispatchQueue.main.asyncAfter(deadline: .now()+HUD_AfterDelay_Default) {[weak self] in
                //重新扫描
                self?.startScan();
            }
        }
    }
    
    ///扫码类型
    enum ScanCodeType {
        ///条形码
        case barCode;
        ///二维码
        case QRCode;
        ///混合
        case blend;
    }
    
    ///判断相机权限
    func checkCameraPermission() -> Bool{
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authorizationStatus == .authorized{
            return true;
        }
        return false;
    }
    
}
