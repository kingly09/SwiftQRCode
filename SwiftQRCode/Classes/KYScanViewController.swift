//
//  KYScanViewController.swift
//  SwiftQRCode
//
//  Created by kingly on 09/05/2018.
//  Copyright © 2015年 kingly. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

public protocol KYScanViewControllerDelegate: class {
    func scanFinished(scanResult: KYScanResult, error: String?)
}

open class KYScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //返回扫码结果，也可以通过继承本控制器，改写该handleCodeResult方法即可
    open weak var scanResultDelegate: KYScanViewControllerDelegate?

    open var scanObj: KYScanWrapper?

    open var scanStyle: KYScanViewStyle? = KYScanViewStyle()

    open var qRScanView: KYScanView?

    //启动区域识别功能
    open var isOpenInterestRect = false

    //识别码的类型
    public var arrayCodeType: [AVMetadataObject.ObjectType]?

    //是否需要识别后的当前图像
    public  var isNeedCodeImage = false

    //相机启动提示文字
    public var readyString: String = "loading"

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)

    }

    open func setNeedCodeImage(needCodeImg: Bool) {
        isNeedCodeImage = needCodeImg
    }
    //设置框内识别
    open func setOpenInterestRect(isOpen: Bool) {
        isOpenInterestRect = isOpen
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override open func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        drawScanView()

        KYPermissions.authorizeCameraWith { (granted) in
            if granted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.startScan()
                })
            } else {
                self.requireUserConfirmation {
                    KYPermissions.jumpToSystemPrivacySetting()
                }
            }
        }
    }

    @objc open func startScan() {

        if (scanObj == nil) {
            var cropRect = CGRect.zero
            if isOpenInterestRect {
                cropRect = KYScanView.getScanRectWithPreView(preView: self.view, style: scanStyle! )
            }

            //指定识别几种码
            if arrayCodeType == nil {
                arrayCodeType = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.code128]
            }

            scanObj = try? KYScanWrapper(videoPreView: self.view, objType: arrayCodeType!, isCaptureImg: isNeedCodeImage, cropRect: cropRect, success: { [weak self] (arrayResult) -> Void in

                if let strongSelf = self {
                    //停止扫描动画
                    strongSelf.qRScanView?.stopScanAnimation()

                    strongSelf.handleCodeResult(arrayResult: arrayResult)
                }
            })
        }

        //结束相机等待提示
        qRScanView?.deviceStopReadying()

        //开始扫描动画
        qRScanView?.startScanAnimation()

        //相机运行
        scanObj?.start()
    }

    open func drawScanView() {
        if qRScanView == nil {
            qRScanView = KYScanView(frame: self.view.frame, vstyle: scanStyle! )
            self.view.addSubview(qRScanView!)
        }
        qRScanView?.deviceStartReadying(readyStr: readyString)

    }

    /**
     处理扫码结果，如果是继承本控制器的，可以重写该方法,作出相应地处理，或者设置delegate作出相应处理
     */
    open func handleCodeResult(arrayResult: [KYScanResult]) {
        if let delegate = scanResultDelegate {

            self.navigationController? .popViewController(animated: true)
            let result: KYScanResult = arrayResult[0]

            delegate.scanFinished(scanResult: result, error: nil)

        } else {

            for result: KYScanResult in arrayResult {
                print("%@", result.strScanned ?? "")
            }

            let result: KYScanResult = arrayResult[0]

            showMsg(title: result.strBarCodeType, message: result.strScanned)
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {

        NSObject.cancelPreviousPerformRequests(withTarget: self)

        qRScanView?.stopScanAnimation()

        scanObj?.stop()
    }

    open func openPhotoAlbum() {
        KYPermissions.authorizePhotoWith { [weak self] (_) in

            let picker = UIImagePickerController()

            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary

            picker.delegate = self

            picker.allowsEditing = true

            self?.present(picker, animated: true, completion: nil)
        }
    }

    // MARK: - ----相册选择图片识别二维码 （条形码没有找到系统方法）
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true, completion: nil)

        var image: UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage

        if (image == nil ) {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }

        if(image != nil) {
            let arrayResult = KYScanWrapper.recognizeQRImage(image: image!)
            if arrayResult.count > 0 {
                handleCodeResult(arrayResult: arrayResult)
                return
            }
        }

        showMsg(title: nil, message: NSLocalizedString("Identify failed", comment: "Identify failed"))
    }

    func showMsg(title: String?, message: String?) {

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default) { (_) in

            //                if let strongSelf = self
            //                {
            //                    strongSelf.startScan()
            //                }
        }

        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    deinit {
        //        print("KYScanViewController deinit")
    }

    private func requireUserConfirmation(when confirmed: @escaping () -> Void) {
        let alertController = UIAlertController(title: "去开启相机权限", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "好的", style: UIAlertActionStyle.default, handler: { (_) in
            confirmed()
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

}
