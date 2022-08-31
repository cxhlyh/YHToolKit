//
//  YHExtensionGetData.swift
//  yizhong_Internal
//
//  Created by 文亚恒 on 2022/4/25.
//  Copyright © 2022 HeNanYiZhong. All rights reserved.
//

import UIKit

class YHForm_ExtensionGetData: NSObject {
    ///单例
    static let shared = YHForm_ExtensionGetData();
    
    
    // MARK: - 获取保险公司
    ///获取保险公司
    func getInsuranceCompany(complete: (([YHBottomSelect_Section_Model]) -> ())?){
        Public_InsurerList_Model.UrlTool_Request_List_ShowToast(urlApi: .public_insurer_list_url, HUDView: UIFactory.shared.CurrentController().view, hudType: .all) { dataModel in
            var elements = [YHBottomSelect_Section_Model]();
            for element in dataModel.data {
                let select = YHBottomSelect_Section_Model.init();
                select.elementName = element.name ?? "";
                select.elementID = element.id ?? "";
                elements.append(select);
            }
            complete?(elements);
        } failure: { _ in
            complete?([YHBottomSelect_Section_Model]());
        } networkError: { _ in
            complete?([YHBottomSelect_Section_Model]());
        };
    }
    
    
    // MARK: - 获取车辆停放机构
    ///获取车辆停放机构
    func getVehicleParkingMechanism(complete: (([YHBottomSelect_Section_Model]) -> ())?){
        Public_InputTableView_Select_URLData_Type_E_Model.UrlTool_Request_List_ShowToast(urlApi: .Public_Branch_List_Get_Url, HUDView: UIFactory.shared.CurrentController().view, hudType: .all) { dataModel in
            var elements = [YHBottomSelect_Section_Model]();
            for element in dataModel.data {
                let select = YHBottomSelect_Section_Model.init();
                select.elementName = element.name ?? "";
                select.elementID = element.id ?? "";
                elements.append(select);
            }
            complete?(elements);
        } failure: { _ in
            complete?([YHBottomSelect_Section_Model]());
        } networkError: { _ in
            complete?([YHBottomSelect_Section_Model]());
        };
    }
    
    // MARK: - 获取所有保全人员
    ///获取所有保全人员
    func getAllSecurityPersonnel(complete: (([YHBottomSelect_Section_Model]) -> ())?){
        User_PreservePersonnelInfo_Model.UrlTool_Request_List_ShowToast(urlApi: .Home_AllSecurityPersonnel_Get_Url, HUDView: UIFactory.shared.CurrentController().view, hudType: .all) { dataModel in
            var elements = [YHBottomSelect_Section_Model]();
            for element in dataModel.data {
                let select = YHBottomSelect_Section_Model.init();
                var roleName = element.roleName ?? "";
                if roleName.count >= 1 {
                    roleName = " ("+roleName+") ";
                }
                select.elementName = (element.userName ?? "")+roleName;
                select.elementID = element.userId ?? "";
                elements.append(select);
            }
            complete?(elements);
        } failure: { _ in
            complete?([YHBottomSelect_Section_Model]());
        } networkError: { _ in
            complete?([YHBottomSelect_Section_Model]());
        };
    }
    
    // MARK: - 获取部门
    ///获取部门
    func getDepartment(complete: (([YHBottomSelect_Section_Model]) -> ())?){
        Public_Department_Model.UrlTool_Request_List_ShowToast(urlApi: .Public_Department_List_Url, HUDView: UIFactory.shared.CurrentController().view, hudType: .all) { dataModel in
            var elements = [YHBottomSelect_Section_Model]();
            for element in dataModel.data {
                let select = YHBottomSelect_Section_Model.init();
                select.elementName = element.deptName ?? "";
                select.elementID = element.id ?? "";
                elements.append(select);
            }
            complete?(elements);
        } failure: { _ in
            complete?([YHBottomSelect_Section_Model]());
        } networkError: { _ in
            complete?([YHBottomSelect_Section_Model]());
        };
    }
    
    
    // MARK: - 获取仓库
    ///获取仓库
    func getWarehouse(complete: (([YHBottomSelect_Section_Model]) -> ())?){
        Public_InsurerList_Model.UrlTool_Request_List_ShowToast(urlApi: .Public_UserWarehouse_Get_Url, HUDView: UIFactory.shared.CurrentController().view, hudType: .all) { dataModel in
            var elements = [YHBottomSelect_Section_Model]();
            for element in dataModel.data {
                let select = YHBottomSelect_Section_Model.init();
                select.elementName = element.name ?? "";
                select.elementID = element.id ?? "";
                select.additionalAttName = (element.address ?? "").toAttText_Grey();
                select.param = element.toJSON();
                elements.append(select);
            }
            complete?(elements);
        } failure: { _ in
            complete?([YHBottomSelect_Section_Model]());
        } networkError: { _ in
            complete?([YHBottomSelect_Section_Model]());
        };
    }
    
    // MARK: - 获取拖车公司
    ///获取拖车公司
    func getTrailerCompany(complete: (([YHBottomSelect_Section_Model]) -> ())?){
        Public_InsurerList_Model.UrlTool_Request_List_ShowToast(urlApi: .Public_TrailerCompany_List_Get_Url, HUDView: UIFactory.shared.CurrentController().view, hudType: .all) { dataModel in
            var elements = [YHBottomSelect_Section_Model]();
            for element in dataModel.data {
                let select = YHBottomSelect_Section_Model.init();
                select.elementName = element.name ?? "";
                select.elementID = element.id ?? "";
                select.param = element.toJSON();
                elements.append(select);
            }
            complete?(elements);
        } failure: { _ in
            complete?([YHBottomSelect_Section_Model]());
        } networkError: { _ in
            complete?([YHBottomSelect_Section_Model]());
        };
    }
    
    
}

