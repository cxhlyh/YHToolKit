//
//  YHForm_Extension_SelectAddress_ViewController.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2022/6/15.
//  Copyright © 2022 HeNanYiZhong. All rights reserved.
//

import UIKit
import BRPickerView


// MARK: - 代理
@objc protocol YHForm_Extension_SelectAddress_ViewController_Delegate:NSObjectProtocol{
    ///选择了数据
    @objc optional func YHForm_Extension_SelectAddress_ViewController_Delegate_Select(idKey:String,dataModel:YHForm_Extension_SelectAddress_ViewController.YHForm_Extension_SelectAddress_Model);
}

class YHForm_Extension_SelectAddress_ViewController: Base_ViewController, QMapViewDelegate,QMSSearchDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
    ///代理
    weak var delegate:YHForm_Extension_SelectAddress_ViewController_Delegate?;
    ///选择来源
    var idKey = "";
    ///是否已经选择了城市
    var isSelectCity = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //加载导航UI
        self.load_NavUI();
        //加载UI
        self.load_UI();
    }
    
    // MARK: - 加载导航UI
    func load_NavUI(){
        self.navigationItem.title = "选择地址";
        self.navigationItem.leftBarButtonItem = navBackBarButtonItem;
    }
    
    // MARK: - 导航返回
    lazy var navBackBarButtonItem:UIBarButtonItem = {
        let button :UIButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44));
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 10);
        button.setImage(UIImage.init(named: "public_nav_back"), for: .normal);
        button.addTarget(self, action: #selector(navgationBackAction), for: .touchUpInside);
        return UIBarButtonItem.init(customView: button);
    }();
    
    // MARK: - 导航返回按钮点击事件
    @objc func navgationBackAction(){
        if self.searchListTableView.isHidden{
            self.navigationController?.popViewController(animated: true);
        }else{
            self.searchTextField.resignFirstResponder();
            self.searchModels.removeAll();
            self.searchListTableView.reloadData();
            self.searchTextField.text = "";
            self.searchListTableView.isHidden = true;
        }
    }
    
    // MARK: - 加载UI
    func load_UI(){
        //拒绝了定位权限
        if self.getLocationPermission() == 1{
            hud_only.show_Text_AutoDisappear(text: "您未开启定位权限,请前往设置开启", view: self.view);
            DispatchQueue.main.asyncAfter(deadline: .now()+HUD_AfterDelay_Default) {[weak self] in
                self?.navigationController?.popViewController(animated: true);
            }
            return;
        }
        //加载搜索容器视图
        self.view.addSubview(searchContentView);
        //加载地图
        self.view.addSubview(QMap_View);
        //加载选择地址列表
        self.view.addSubview(locationListTableView);
        //加载搜索地址列表
        self.view.addSubview(searchListTableView);
    }
    
    // MARK: - 搜索容器视图
    lazy var searchContentView:UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: APP_WIDTH, height: Form_DefaultCellHeight*1.2));
        view.backgroundColor = .white;
        //加载搜索输入框
        view.addSubview(searchTextField);
        return view;
    }();
    
    // MARK: - 搜索输入框
    lazy var searchTextField:UITextField = {
        let tf = UITextField.init(frame: CGRect(x: Form_CommonlyGap, y: Form_DefaultCellHeight*0.2, width: APP_WIDTH-Form_CommonlyGap*2, height: Form_DefaultCellHeight*0.8));
        tf.layer.cornerRadius = tf.frame.size.height/2;
        tf.layer.masksToBounds = true;
        tf.backgroundColor = Grey_BackGround_Color;
        tf.placeholder = "请输入地址";
        tf.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 14));
        //左侧视图
        let leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: Form_DefaultCellHeight*2, height:Form_DefaultCellHeight*0.8));
        //加载选择城市按钮
        leftView.addSubview(searchCityLabel);
        //加载分割线
        leftView.addSubview(UIView.createLineView_Frame_Color(frame:CGRect(x: searchCityLabel.frame.size.width+searchCityLabel.frame.origin.x, y: leftView.frame.size.height/3, width: 1, height: leftView.frame.size.height/3*1), color: Grey_Text_Color));
        //加载搜索提示图片
        let remainingWidth = Form_DefaultCellHeight*0.7-1;
        let leftTipsImageView = UIImageView.init(frame: CGRect(x: searchCityLabel.frame.size.width+searchCityLabel.frame.origin.x+1+remainingWidth/2-leftView.frame.size.height/3/2, y:leftView.frame.size.height/3, width: leftView.frame.size.height/3, height: leftView.frame.size.height/3));
        leftTipsImageView.image = UIImage.init(named: "public_search");
        leftView.addSubview(leftTipsImageView);
        tf.leftView = leftView;
        tf.leftViewMode = .always;
        tf.delegate = self;
        tf.addTarget(self, action: #selector(searchTextField_Changed), for: .editingChanged);
        return tf;
    }();
    
    // MARK: - 输入框将要开始编辑
    func textFieldShouldBeginEditing(_ textField: UITextField) ->Bool{
        self.searchListTableView.isHidden = false;
        return true
    }
    
    // MARK: - 选择城市
    lazy var searchCityLabel:UILabel = {
        let label = UILabel.init(frame: CGRect(x: Form_DefaultCellHeight*0.1, y: 0, width: Form_DefaultCellHeight*1.2, height: Form_DefaultCellHeight*0.8));
        label.textColor = Grey_Text_Color;
        label.font = UIFont.systemFont(ofSize: Calculation_FontNumber(font: 12));
        label.text = "定位中";
        label.textAlignment = .center;
        label.isUserInteractionEnabled = true;
        label.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action:#selector(searchCityLabel_Touch)));
        return label;
    }();
    
    // MARK: - 选择城市
    @objc func searchCityLabel_Touch(){
        //关闭键盘
        self.searchTextField.resignFirstResponder();
        //展示搜索页面
        self.searchListTableView.isHidden = false;
        //选择城市
        BRAddressPickerView.showAddressPicker(with: .city, selectIndexs: nil, isAutoSelect: false) {[weak self] province, cityModel, _ in
            self?.isSelectCity = true;
            self?.searchCityLabel.text = cityModel?.name ?? "全国";
            if self?.searchTextField.text?.count ?? 0 >= 1{
                //搜索
                self?.searchRequest(content: self?.searchTextField.text ?? "");
            }
        }
    }
    
    
    
    // MARK: - 腾讯地图视图
    lazy var QMap_View:QMapView = {
        let map = QMapView.init(frame: CGRect(x: 0, y: Form_DefaultCellHeight*1.4, width: APP_WIDTH, height: APP_HEIGHT-NavigationBarAndStatusBarSafa_Height-SafaAreaBottom_Height-Form_DefaultCellHeight*1.4-Form_DefaultCellHeight*5));
        //设置代理
        map.delegate = self;
        //设置logo大小
        map.setLogoScale(0.7);
        //设置缩放比例
        map.setMinZoomLevel(4, maxZoomLevel: 20);
        //开启定位
        map.showsUserLocation = true;
        //禁止旋转
        map.isRotateEnabled = false;
        //设置定位模式为追踪用户的location更新
        map.setUserTrackingMode(.follow, animated: true);
        //加载定位图片
        location_ImageView.center.y = map.center.y-map.frame.origin.y-location_ImageView.frame.size.height/2;
        map.addSubview(location_ImageView);
        return map;
    }();
    
    // MARK: - 定位图片
    lazy var location_ImageView:UIImageView = {
        let iv = UIImageView.init(frame: CGRect(x: APP_WIDTH/2-Form_CommonlyGap, y: 0, width: Form_CommonlyGap*2, height: Form_CommonlyGap*2));
        iv.image = UIImage.init(named: "YHForm_Location");
        return iv;
    }();
    
    // MARK: - 地图结果模型
    lazy var locationModels:[YHForm_Extension_SelectAddress_Model] = {
        return [YHForm_Extension_SelectAddress_Model]();
    }();
    
    // MARK: - 搜索结果模型
    lazy var searchModels:[YHForm_Extension_SelectAddress_Model] = {
        return [YHForm_Extension_SelectAddress_Model]();
    }();
    
    // MARK: - 地图地址列表
    lazy var locationListTableView:UITableView = {
        let lt = UITableView.init(frame: CGRect(x: 0, y:APP_HEIGHT-NavigationBarAndStatusBarSafa_Height-SafaAreaBottom_Height-Form_DefaultCellHeight*5, width: APP_WIDTH, height: Form_DefaultCellHeight*5), style: .plain);
        lt.backgroundColor = Grey_BackGround_Color;
        lt.register(YHForm_Extension_SelectAddress_Cell.classForCoder(), forCellReuseIdentifier: "YHForm_Extension_SelectAddress_ViewController_Location_ID");
        lt.bounces = false;
        lt.delegate = self;
        lt.dataSource = self;
        return lt;
    }();
    
    // MARK: - 搜索地址列表
    lazy var searchListTableView:UITableView = {
        let lt = UITableView.init(frame: CGRect(x: 0, y:searchContentView.frame.origin.y+searchContentView.frame.size.height, width: APP_WIDTH, height: APP_HEIGHT-NavigationBarAndStatusBarSafa_Height-SafaAreaBottom_Height-(searchContentView.frame.origin.y+searchContentView.frame.size.height)), style: .plain);
        lt.backgroundColor = Grey_BackGround_Color;
        lt.register(YHForm_Extension_SelectAddress_Search_Cell.classForCoder(), forCellReuseIdentifier: "YHForm_Extension_SelectAddress_ViewController_Search_ID");
//        lt.bounces = false;
        lt.delegate = self;
        lt.dataSource = self;
        lt.isHidden = true;
        return lt;
    }();
    
    // MARK: - 搜索结果数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == locationListTableView{
            return locationModels.count;
        }else{
            return searchModels.count;
        }
    }
    
    // MARK: - cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == locationListTableView{
            return locationModels[indexPath.row].nameHeight+locationModels[indexPath.row].contentHeight+Form_CommonlyGap*2.5;
        }else{
            return searchModels[indexPath.row].nameHeight+searchModels[indexPath.row].contentHeight+Form_CommonlyGap*2.5;
        }
    }
    
    // MARK: - cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == locationListTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "YHForm_Extension_SelectAddress_ViewController_Location_ID", for: indexPath) as! YHForm_Extension_SelectAddress_Cell;
            cell.update_UI(dataModel: self.locationModels[indexPath.row]);
            return cell;
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "YHForm_Extension_SelectAddress_ViewController_Search_ID", for: indexPath) as! YHForm_Extension_SelectAddress_Search_Cell;
            cell.update_UI(dataModel: self.searchModels[indexPath.row]);
            return cell;
        }
    }
    
    // MARK: - cell点击事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == locationListTableView{
            self.delegate?.YHForm_Extension_SelectAddress_ViewController_Delegate_Select?(idKey:self.idKey,dataModel: locationModels[indexPath.row]);
            self.navigationController?.popViewController(animated: true);
        }else{
            self.delegate?.YHForm_Extension_SelectAddress_ViewController_Delegate_Select?(idKey:self.idKey,dataModel: searchModels[indexPath.row]);
            self.navigationController?.popViewController(animated: true);
        }
    }
   
    // MARK: - 输入框结束编辑
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchListTableView.isUserInteractionEnabled = false;
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {[weak self] in
            self?.searchListTableView.isUserInteractionEnabled = true;
        }
    }
    
    // MARK: - 搜索输入框监听
    @objc func searchTextField_Changed(){
        self.perform(#selector(searchRequest), with: self.searchTextField.text, afterDelay: 1.0);
    }
    
    // MARK: - 搜索周边
    @objc func searchRequest(content:String){
        if content == self.searchTextField.text{
            //无搜索内容
            if self.searchTextField.text?.count ?? 0 == 0 {
                self.searchModels.removeAll();
                self.searchListTableView.reloadData();
                return;
            }
            if isSelectCity == false{
                isSelectCity = true;
                self.searchCityLabel.text = "全国";
            }
            //过滤重复(城市&&内容)的搜索
            if (searchOption.boundary ?? "").contains(self.searchCityLabel.text ?? "") && searchOption.keyword == (self.searchTextField.text ?? ""){
                return;
            }
            //创建搜索请求
            searchOption = QMSPoiSearchOption.init();
            searchOption.page_size = 20;
            searchOption.keyword = self.searchTextField.text ?? "";
            searchOption.setBoundaryByRegionWithCityName(self.searchCityLabel.text ?? "全国", autoExtend: false);
            //开始搜索
            self.searchApi.search(with: searchOption);
        }
    }
    
    
    // MARK: - 搜索api
    lazy var searchApi:QMSSearcher = {
        let sa = QMSSearcher.init(delegate: self);
        return sa;
    }();

    // MARK: - 地图周边请求
    lazy var locationOption:QMSPoiSearchOption = {
        return QMSPoiSearchOption.init();
    }();
    
    // MARK: - 搜索请求
    lazy var searchOption:QMSPoiSearchOption = {
        return QMSPoiSearchOption.init();
    }();
    
    // MARK: - 搜索周边
    func searchPoi(){
        //创建搜索请求
        locationOption = QMSPoiSearchOption.init();
        locationOption.page_size = 20;
        locationOption.setBoundaryByNearbyWithCenter(self.QMap_View.convert(location_ImageView.center, toCoordinateFrom: QMap_View), radius: 500, autoExtend: true);
        //开始搜索
        self.searchApi.search(with: locationOption);
    }

    //MARK: - 页面销毁
    deinit{
        
    }
    
    
}

// MARK: - 拓展
extension YHForm_Extension_SelectAddress_ViewController{
    
    // MARK: - 周边搜索回调
    func search(with poiSearchOption: QMSPoiSearchOption, didReceive poiSearchResult: QMSPoiSearchResult) {
        //判断搜索回调来源
        if poiSearchOption == searchOption{
            //没有获取到信息
            if poiSearchResult.count <= 0{
                //清空上次搜索到的内容
                self.searchModels.removeAll();
                //刷新列表
                self.searchListTableView.reloadData();
                return;
            }
            //记录搜索结果
            self.searchModels.removeAll();
            poiSearchResult.dataArray.forEach { data in
                if let element = data as? QMSPoiData{
                    let elementModel = YHForm_Extension_SelectAddress_ViewController.YHForm_Extension_SelectAddress_Model.init();
                    elementModel.name = element.title;
                    elementModel.province = element.ad_info.province;
                    elementModel.city = element.ad_info.city;
                    elementModel.district = element.ad_info.district;
                    //地址里过滤省市县区
                    let city = (element.ad_info.province ?? "")+(element.ad_info.city ?? "")+(element.ad_info.district ?? "");
                    let address = (element.address ?? "").replacingOccurrences(of: city, with: "");
                    elementModel.address = address;
                    elementModel.longitude = String(Double(element.location.longitude));
                    elementModel.latitude = String(Double(element.location.latitude));
                    //计算距离
                    let distance = QMetersBetweenCoordinates(element.location, self.QMap_View.userLocation.location.coordinate);
                    var distanceString = "";
                    if distance >= 1000{
                        distanceString = (distance/1000).format_TwoDecimalPlaces_ToString()+"km";
                    }else{
                        distanceString = distance.format_TwoDecimalPlaces_ToString()+"m";
                    }
                    //计算距离文本宽度
                    elementModel.distance = distanceString;
                    //记录搜索内容
                    elementModel.searchName = self.searchTextField.text;
                    let distanceWidth = distanceString.text_Size(maxSize: CGSize(width: APP_WIDTH/2, height: 999), font: UIFont.systemFont(ofSize: Calculation_FontNumber(font: 12))).width;
                    elementModel.distanceWidth = distanceWidth;
                    //计算cell高度
                    let allAddress = (elementModel.province ?? "")+(elementModel.city ?? "")+(elementModel.district ?? "")+(elementModel.address ?? "");
                    let textMaxWidth = APP_WIDTH-Form_CommonlyGap*3-distanceWidth;
                    elementModel.nameHeight = (elementModel.name ?? "").text_Size(maxSize: CGSize(width: textMaxWidth, height: 999), font: UIFont.systemFont(ofSize: Calculation_FontNumber(font: 14))).height;
                    elementModel.contentHeight = allAddress.text_Size(maxSize: CGSize(width: APP_WIDTH-Form_CommonlyGap*2, height: 999), font: UIFont.systemFont(ofSize: Calculation_FontNumber(font: 12))).height;
                    self.searchModels.append(elementModel);
                }
            }
            //跳到第一条
            self.searchListTableView.contentOffset.y = 0;
            //刷新列表
            self.searchListTableView.reloadData();
        }else if poiSearchOption == locationOption{
            //没有获取到信息
            if poiSearchResult.count <= 0{
                return;
            }
            //记录搜索结果
            self.locationModels.removeAll();
            poiSearchResult.dataArray.forEach { data in
                if let element = data as? QMSPoiData{
                    let elementModel = YHForm_Extension_SelectAddress_Model.init();
                    elementModel.name = element.title;
                    elementModel.province = element.ad_info.province;
                    elementModel.city = element.ad_info.city;
                    elementModel.district = element.ad_info.district;
                    //地址里过滤省市县区
                    let city = (element.ad_info.province ?? "")+(element.ad_info.city ?? "")+(element.ad_info.district ?? "");
                    let address = (element.address ?? "").replacingOccurrences(of: city, with: "");
                    elementModel.address = address;
                    elementModel.longitude = String(Double(element.location.longitude));
                    elementModel.latitude = String(Double(element.location.latitude));
                    //计算cell高度
                    let allAddress = (elementModel.province ?? "")+(elementModel.city ?? "")+(elementModel.district ?? "")+(elementModel.address ?? "");
                    let textMaxWidth = APP_WIDTH-Form_CommonlyGap*3-Form_DefaultCellHeight/2;
                    elementModel.nameHeight = (elementModel.name ?? "").text_Size(maxSize: CGSize(width: textMaxWidth, height: 999), font: UIFont.systemFont(ofSize: Calculation_FontNumber(font: 14))).height;
                    elementModel.contentHeight = allAddress.text_Size(maxSize: CGSize(width: textMaxWidth, height: 999), font: UIFont.systemFont(ofSize: Calculation_FontNumber(font: 12))).height;
                    self.locationModels.append(elementModel);
                }
            }
            //跳到第一条
            self.locationListTableView.contentOffset.y = 0;
            //刷新列表
            self.locationListTableView.reloadData();
        }
    }
    
    // MARK: - 逆地理解析回调
    func search(with reverseGeoCodeSearchOption: QMSReverseGeoCodeSearchOption, didReceive reverseGeoCodeSearchResult: QMSReverseGeoCodeSearchResult) {
        if isSelectCity == false && (reverseGeoCodeSearchResult.ad_info.city ?? "").count >= 1{
            isSelectCity = true;
            searchCityLabel.text = reverseGeoCodeSearchResult.ad_info.city;
        }
    }
    
    //地图移动-首次定位也会执行
    func mapView(_ mapView: QMapView!, regionDidChangeAnimated animated: Bool, gesture bGesture: Bool) {
        //判断是否选择了城市
        if isSelectCity == false{
            //解析用户当前城市
            let revGeoOption = QMSReverseGeoCodeSearchOption.init();
            revGeoOption.setLocationWithCenter(self.QMap_View.userLocation.location.coordinate);
            self.searchApi.search(with: revGeoOption);
        }
        //搜索周边
        self.searchPoi();
    }
    
    // MARK: - 数据模型
    class YHForm_Extension_SelectAddress_Model:NSObject{
        ///搜索结果名称
        var name:String?;
        ///经度
        var longitude:String?;
        ///纬度
        var latitude:String?;
        ///地址
        var address:String?;
        ///省
        var province:String?;
        ///城市名称
        var city:String?;
        ///区域名称
        var district:String?;
        ///距离
        var distance:String?;
        ///输入框搜索名称
        var searchName:String?;
        ///name高度
        var nameHeight:CGFloat = 0;
        ///距离宽度
        var distanceWidth:CGFloat = 0;
        ///content高度
        var contentHeight:CGFloat = 0;
    }
    
    // MARK: - 获取定位权限
    func getLocationPermission() ->Int{
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined://尚未授权
            return 0;
        case .restricted,.denied://拒绝
            return 1;
        default://同意
            return 2;
        }
    }
    

    
}


// MARK: - 拓展
extension YHForm_Extension_SelectAddress_ViewController{
    
    // MARK: - 跳转外部地图app
    class func jumpMapApp(latitude:String,longitude:String,endAddress:String){
        let alert = UIAlertController.init(title: "选择跳转地图APP", message: nil, preferredStyle: .actionSheet);
        let cancel = UIAlertAction.init(title: "取消", style: .cancel) { _ in
            
        }
        let action1 = UIAlertAction.init(title: "高德地图", style: .default) { _ in
            jumpMapApp_GD(latitude: latitude, longitude: longitude, endAddress: endAddress);
        }
        let action2 = UIAlertAction.init(title: "百度地图", style: .default) { _ in
            jumpMapApp_Baidu(latitude: latitude, longitude: longitude, endAddress: endAddress);
        }
        alert.addAction(action1);
        alert.addAction(action2);
        alert.addAction(cancel);
        UIFactory.shared.CurrentController().present(alert, animated: true, completion: nil)
    }
    
    // MARK: - 跳转百度地图
    class func jumpMapApp_Baidu(latitude:String,longitude:String,endAddress:String){
        let locationString = latitude+","+longitude;
        let urlString = NSString.init(format: "baidumap://map/marker?location=%@&title=%@&content=%@&src=ios.baidu.yizhong_Internal&coord_type=gcj02", locationString,endAddress,"标注地址").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed);
        if let mapUrl = URL.init(string: urlString ?? ""){
            if UIApplication.shared.canOpenURL(URL.init(string: "baidumap://")!){
                UIApplication.shared.open(mapUrl, options: [:], completionHandler: nil);
            }else{
                hud_only.show_Text_AutoDisappear(text: "您还没有安装百度地图", view: UIFactory.shared.CurrentController().view);
            }
        }else{
            hud_only.show_Text_AutoDisappear(text: "暂时无法打开,请稍后再试", view: UIFactory.shared.CurrentController().view);
        }
    }
    
    // MARK: - 跳转高德地图
    class func jumpMapApp_GD(latitude:String,longitude:String,endAddress:String){
        let urlString = NSString.init(format: "iosamap://viewMap?sourceApplication=易众数据&poiname=%@&lat=%@&lon=%@&dev=0", endAddress,latitude,longitude).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed);
        if let mapUrl = URL.init(string: urlString ?? ""){
            if UIApplication.shared.canOpenURL(URL.init(string: "iosamap://")!){
                UIApplication.shared.open(mapUrl, options: [:], completionHandler: nil);
            }else{
                hud_only.show_Text_AutoDisappear(text: "您还没有安装高德地图", view: UIFactory.shared.CurrentController().view);
            }
        }else{
            hud_only.show_Text_AutoDisappear(text: "暂时无法打开,请稍后再试", view: UIFactory.shared.CurrentController().view);
        }
    }
  
}
