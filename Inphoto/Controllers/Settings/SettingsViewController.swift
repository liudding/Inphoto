//
//  SettingsViewController.swift
//  Jice
//
//  Created by liuding on 2018/8/15.
//  Copyright © 2018 fivebytes. All rights reserved.
//

import UIKit
import MessageUI
import Armchair

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {


    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        versionLabel.text = "version \(AppInfo.version!) (build \(AppInfo.buildVersion!))"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 2 { // 联系我们
            sendEmail()
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                Armchair.rateApp()
            } else if indexPath.row == 1 {
                share(sender: tableView.cellForRow(at: indexPath)!)
            }
        }

    }
    
    private func share(sender: UIView) {
        // TODO: 分享文字和链接
        let text = ""
        let url = NSURL(string: "www.baidu.com")!
        
        let items: [Any] = [text, url]
        
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.excludedActivityTypes = [
            .postToFacebook, .postToTwitter, .print, .assignToContact,
            .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .openInIBooks];
        presentActionSheet(vc, from: sender)
    }
    
    private func presentActionSheet(_ vc: UIActivityViewController, from view: UIView) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.popoverPresentationController?.sourceView = view
            vc.popoverPresentationController?.sourceRect = view.bounds
            vc.popoverPresentationController?.permittedArrowDirections = [.right, .left]
        }
        
        present(vc, animated: true, completion: nil)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        
        //设置邮件地址、主题及正文
        mailComposeVC.setToRecipients([Constant.contactEmail])
        mailComposeVC.setSubject("<邮件主题>")
        mailComposeVC.setMessageBody("<邮件正文>", isHTML: false)
        
//        let deviceName = UIDevice.current.name
        let systemVersion = UIDevice.current.systemVersion
        let deviceModel = UIDevice.current.model
        let deviceUUID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let version = AppInfo.version ?? ""

        let infos = """
                    系统版本：\(systemVersion)
                    设备型号：\(deviceModel)
                    UUID： \(deviceUUID)
                    应用版本： \(version)
                    """
        mailComposeVC.setMessageBody(infos, isHTML: false)
        
        return mailComposeVC
        
    }
    
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = configuredMailComposeViewController()
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    
    func showSendMailErrorAlert() {
        
        let alert = UIAlertController(title: "无法发送邮件", message: "您的设备尚未设置邮箱，请在“邮件”应用中设置后再尝试发送。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in })
        self.present(alert, animated: true)
        
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            break
        case .sent:
            print("发送成功")
        default:
            break
        }
//        self.dismiss(true, completion: nil)
        controller.dismiss(animated: true, completion: nil)
    }

   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension SettingsViewController {
    
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 4
//    }
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return [0, ][section]
//    }
}
