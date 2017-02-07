//
//  ViewController.swift
//  slack_push_test
//
//  Created by administrator on 2016/11/27.
//  Copyright © 2016年 administrator. All rights reserved.
//

import UIKit

//位置情報を利用したい時(ibeaconも使える)
import MapKit


class ViewController: UIViewController,CLLocationManagerDelegate {

    //ビーコン情報を取りまとめる部品
    var beacon: CLBeaconRegion!
    //GPSを操作する部品を用意する
    var locationManager: CLLocationManager!

    //ステータスラベル
    @IBOutlet weak var beaconLabel: UILabel!
    
    //webview
    @IBOutlet weak var webView: UIWebView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let url = "https://office-iot.sbb-sys.info/front"
        //iphone用にURLを翻訳
        let nsurl = URL(string: url)
        //上のURLのページをリクエストします
        let request = URLRequest(url: nsurl!)
        //そのURLのページをWebViewに表示してくれ
        self.webView.loadRequest(request)
        
        
        //初期化(実態を用意する)
        self.locationManager = CLLocationManager()
        //howaシステムビーコン
        //let uuidstring = "48534442-4C45-4144-80C0-180000000001"
        
        //arubaビーコン
        let uuidstring = "2816ABEF-FDD7-4363-946C-7B96A1FB57B0"

        let uuid = UUID(uuidString: uuidstring)
        self.beacon = CLBeaconRegion(proximityUUID: uuid!, identifier: "beacon")
        
        //ビーコンの領域に入った時と、出た時に通知をもらう。
        self.beacon.notifyOnEntry = true
        self.beacon.notifyOnExit = true
        
        //ユーザーの許可をとる
        self.locationManager.requestAlwaysAuthorization()
        
        //バックグラウンドでも一情報を取得する設定
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        //何メートルおきにとってきますか？
        self.locationManager.distanceFilter = 10
        
        //locationManagerと相談する準備その２
        self.locationManager.delegate = self
        
        //位置情報観測スタート
        self.locationManager.startUpdatingLocation()
        
        //beacon情報観測スタート
        self.locationManager.startMonitoring(for: self.beacon)

        
    }
    
    //beacon情報とってきたらどうする？
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        //ビーコン発見したらどうする？
        //ビーコンに信号を送ってもらう。
        self.locationManager.requestState(for: self.beacon)
    }
    
    //ビーコンの内だったらどうする？
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.beaconLabel.text = "今、ビーコンの中だよ"
        print("入った")
    }
    
    //ビーコンの外だったらどうする？
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.beaconLabel.text = "今、ビーコンの外だよ"
        print("出た")
    }
    
    //ビーコンの状態が決定したらどうする？
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion){
        
        // create the url-request
        let urlString = "https://hooks.slack.com/services/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"
        var request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        
        // set the method(HTTP-POST)
        request.httpMethod = "POST"
        // set the headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // ビーコン内（席にいる場合）set the request-body(JSON)
        var params1: [String: AnyObject] = [
            "channel"   : "place" as AnyObject,
            "username"  : "kaz-kojima" as AnyObject,
            "text"      : "【○】小島さんは今席にいます" as AnyObject,
            "icon_emoji": ":beginner:" as AnyObject
        ]
        
        // ビーコン外（席にいない場合）set the request-body(JSON)
        var params2: [String: AnyObject] = [
            "channel"   : "place" as AnyObject,
            "username"  : "kaz-kojima" as AnyObject,
            "text"      : "【✖︎】小島さんは今席にいません" as AnyObject,
            "icon_emoji": ":beginner:" as AnyObject
        ]
        
            if state == CLRegionState.inside {
            self.beaconLabel.text = "今、ビーコンの中だよ"
                //--------------------------------
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: params1, options: JSONSerialization.WritingOptions(rawValue: 0))
                } catch let parsingError as NSError {
                    print(parsingError.description)
                }
                
                // use NSURLSessionDataTask
                var task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) in
                    var result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print(result)
                })
                task.resume()
                //--------------------------------
            }
            else if state == CLRegionState.outside {
            self.beaconLabel.text = "今、ビーコンの外だよ"
                //--------------------------------
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: params2, options: JSONSerialization.WritingOptions(rawValue: 0))
                } catch let parsingError as NSError {
                    print(parsingError.description)
                }
                
                // use NSURLSessionDataTask
                var task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) in
                    var result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print(result)
                })
                task.resume()
                //--------------------------------
            }
            else {
            self.beaconLabel.text = "不明"
            }
        }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    

    @IBAction func pushButton(_ sender: Any) {
        // create the url-request
        let urlString = "https://hooks.slack.com/services/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"
        var request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        
        // set the method(HTTP-POST)
        request.httpMethod = "POST"
        // set the headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // set the request-body(JSON)
        var params: [String: AnyObject] = [
            "channel"   : "place" as AnyObject,
            "username"  : "kaz-kojima" as AnyObject,
            "text"      : "小島アプリのテスト送信" as AnyObject,
            "icon_emoji": ":beginner:" as AnyObject
        ]
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions(rawValue: 0))
        } catch let parsingError as NSError {
            print(parsingError.description)
        }
        
        // use NSURLSessionDataTask
        var task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) in
            var result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(result)
        })
        task.resume()
    }

}

