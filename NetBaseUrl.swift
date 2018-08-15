//
//  NetBaseUrl.swift
//  Kongming_Swift
//
//  Created by chenXming on 2018/5/25.
//  Copyright © 2018年 bitauto. All rights reserved.
//

import Foundation
//MARK: - 反馈接口
//反馈提交
let   cmd_custInsertUserFeedback  = "cust/insertUserFeedback"
// 反馈 列表
let   cmd_custSelectUserFeedback  =  "cust/selectUserFeedback"
//图片上传 反馈
let   cmd_custImgUpdate           =  "cust/imgUpdate"

//MARK: - 内容营销
//栏目列表
let   cmd_contentDictList          =         "content/dictList"
//产品列表
let   cmd_contentUserProduct        =        "content/app/product"
//产品详情
let  cmd_contentProductInfo         =        "content/product/info"
//往期回顾 列表
let  cmd_contentProductHistoryList    =       "content/app/historyProduct"

//MARK: - 发票模块
//筛选条件
let   cmd_GetInvoiceMenu    = "GetInvoiceMenu"
//发票列表
let   cmd_GetInvoiceList     = "GetInvoiceList"
// 发票明细
let  cmd_GetInvoiceInfo     = "GetInvoiceInfo"
//合同信息
let  cmd_GetInvoiceContractInfo    = "GetInvoiceContractInfo"
//更新签收状态
let  cmd_SaveInvoiceStatus     = "SaveInvoiceStatus"
//上传回执信息
let  cmd_SaveInvoiceUrl      = "SaveInvoiceUrl"
//获取审批信息
let  cmd_GetInvoiceLog     = "GetInvoiceLog"







