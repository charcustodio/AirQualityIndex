//
//  ContentView.swift
//  aqi
//
//  Created by aoi on 8/31/20.
//  Copyright © 2020 kc_cc. All rights reserved.
//


import Foundation
import SwiftUI
import Combine
import CoreLocation

//var aqi_date = set_datetimeFormat("YYYY-MM-DD")
//var aqi_time = set_datetimeFormat("h:mm a zzz")
//var aqi_url = set_urlFormat(aqi_date)

var aqi_partmatt = "2.5pm"

struct Response : Decodable {
    let data : [Data]
}

struct Data : Decodable {
    
    var locality: String?
    var region: String?
    var country_code: String?
    /*
    var locality: String {
        get { return _locality ?? "" }
        set { _locality = "" }
    }
    var region: String {
        get { return _region ?? "" }
        set { _region = "" }
    }
    var country_code: String {
        get { return _country_code ?? "" }
        set { _country_code = "USA" }
    }

    private var _locality: String?
    private var _region: String?
    private var _country_code: String?
    private enum CodingKeys: String, CodingKey {
        case _locality = "locality" , _region = "region", _country_code = "country_code"
    }*/
}


struct AQI_Response: Decodable {
//    let status : String?
    let data : AQI_Data?
}


 struct AQI_Data: Decodable {
    var current: Current?
}

struct Current: Decodable { // or Decodable
    let pollution: Pollution?
}

struct Pollution: Decodable { // or Decodable
    var ts: String?
    var aqius: Int?
    var mainus: String?
    /*
    var ts: String {
        get { return _ts ?? "" }
        set { _ts = "" }
    }
    var aqius: Int {
        get { return _aqius ?? 0 }
        set { _aqius = 0 }
    }
    var mainus: String {
        get { return _mainus ?? "" }
        set { _mainus = "" }
    }
    private var _ts: String?
    private var _aqius: Int?
    private var _mainus: String?
    private enum CodingKeys: String, CodingKey {
        case _ts = "ts" , _aqius = "aqius", _mainus = "mainus"
    }*/
}

/*

func set_datetimeFormat(_ f : String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = f
    return dateFormatter.string(from: Date())
}

*/
class LocationFinder: NSObject, ObservableObject{
    @Published var userLatitude: Double = 0
    @Published var userLongitude: Double = 0
    
    private let locationManager = CLLocationManager()
    
    override init() {
      super.init()
      self.locationManager.delegate = self
      self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
      self.locationManager.requestWhenInUseAuthorization()
      self.locationManager.startUpdatingLocation()
    }
}

extension LocationFinder: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    userLatitude = location.coordinate.latitude
    userLongitude = location.coordinate.longitude

    //print(userLatitude,userLongitude)
  }
}

class AQI : ObservableObject {
    /*var didChange = PassthroughSubject<AQI, Never>()
    
    var aqi_city: String = "" {
        didSet {
            didChange.send(self)
        }
    }
    var aqi_state: String = "" {
        didSet {
            didChange.send(self)
        }
    }
    var aqi_country: String = "" {
        didSet {
            didChange.send(self)
        }
    }
    
    var aqi_num : String = "--" {
        didSet {
            didChange.send(self)
        }
    }*/
    
    @ObservedObject var lf = LocationFinder()
    @Published var aqi_status = ""
    @Published var aqi_city = ""
    @Published var aqi_state = ""
    @Published var aqi_country = "USA"
    @Published var aqi_num = "n/a"
    lazy var aqi_lat = ""//String(lf.$userLatitude)
    lazy var aqi_long = "" //String(lf.$userLongitude)
    
    /*var aqi_status = "Current Data is Unavailable" {
        didSet {
            didChange.send(self)
        }
    }
    var aqi_lat = "" {
        didSet {
            didChange.send(self)
        }
    }
    var aqi_long = "" {
        didSet {
            didChange.send(self)
        }
    }
    
    init() {
        self.set_AQIValues()
        aqi_lat = "\(lf.$userLatitude)"
        aqi_long = "\(lf.$userLongitude)"
    }*/
    
    func set_AQIstatus() {
        var curr_status:String
        let curr_value = Int(self.aqi_num) ?? -1
        
        if curr_value >= 0 && curr_value <= 50 {
            curr_status = "Good"
        } else if curr_value >= 51 && curr_value <= 100 {
            curr_status = "Moderate"
        } else if curr_value >= 101 && curr_value <= 150 {
            curr_status = "Unhealthy for Sensitive Groups"
        } else if curr_value >= 151 && curr_value <= 200 {
            curr_status = "Unhealthy"
        } else if curr_value >= 201 && curr_value <= 300 {
            curr_status = "Very Unhealthy"
        } else if curr_value >= 301 {
            curr_status = "Hazardous"
        } else {
            curr_status = "Current Data is Unavailable"
        }
        self.aqi_status = curr_status
        //return aqi_status
    }
    
    
    func set_AQIValues() {
        let geo_key = "bfd40e001aa71814fa60b27a881eac66"
        let api_key = "ad8d26df-ee66-4f50-9028-cfa92a51fbe1"
        //"1168fc42-ba11-4e81-b7ed-0da79028fd86"
        
        self.aqi_lat = String(lf.userLatitude)
        self.aqi_long = String(lf.userLongitude)
        //print(aqi_lat,aqi_long)
        
        let geo_url = "http://api.positionstack.com/v1/reverse?access_key=\(geo_key)&query=\(aqi_lat),\(aqi_long)&limit=1"
        
        print(geo_url)
        let geo_semaphore = DispatchSemaphore (value: 0)
        var geo_request = URLRequest(url: URL( string : geo_url)!, timeoutInterval : 10)
        geo_request.httpMethod = "GET"
        let geo_task = URLSession.shared.dataTask(with: geo_request) { data, response, error in
            
            guard let data = data else {
                return
            }
            
            do {
                let geo_string = String(data: data, encoding: .utf8)!
                let geo_res = geo_string.data(using: .utf8)!
                let geo_data = try JSONDecoder().decode(Response.self, from: geo_res)
                
                //DispatchQueue.main.async {
                let geo_city = geo_data.data[0].locality
                let geo_state = geo_data.data[0].region
                let geo_country = geo_data.data[0].country_code
                
                if let text = geo_city { self.aqi_city = String(text) }
                if let text = geo_state { self.aqi_state = String(text) }
                if let text = geo_country { self.aqi_country = String(text) }
                
                //self.aqi_city = String(geo_city)
                //self.aqi_state = String(geo_state)
                //self.aqi_country = String(geo_country)
                
                print(self.aqi_city,self.aqi_state,self.aqi_country)
                //}
            } catch {
                print(error.localizedDescription)
            }
            geo_semaphore.signal()
        }
        
        geo_task.resume()
        geo_semaphore.wait()
        
        
        print(self.aqi_city, self.aqi_state, self.aqi_country)
        
        let req_city = self.aqi_city.replacingOccurrences(of: " ", with: "%20")
        let req_state = self.aqi_state.replacingOccurrences(of: " ", with: "%20")
        let req_country = self.aqi_country.replacingOccurrences(of: " ", with: "%20")
        
        let api_url = "http://api.airvisual.com/v2/city?city=\(req_city)&state=\(req_state)&country=\(req_country)&key=\(api_key)"
        
        
        print(api_url)
        let semaphore = DispatchSemaphore (value: 0)
        var request = URLRequest(url: URL(string: api_url)! , timeoutInterval: 10)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }
            let res_string = String(data: data, encoding: .utf8)!
            let res = res_string.data(using: .utf8)!
            
            print(res_string)

            let res_data = try! JSONDecoder().decode(AQI_Response.self, from: res)
            //DispatchQueue.main.async {
            let res_val = res_data.data?.current?.pollution?.aqius
            
            if let text = res_val { self.aqi_num = String(text) }
            //}
            semaphore.signal()
            
        }
        
        task.resume()
        semaphore.wait()
        
        //print(self.aqi_num)
        set_AQIstatus()
    }
}



struct ContentView: View {
    
    @ObservedObject var lf = LocationFinder() // Change to @StateObject on Ios 14
    @ObservedObject var aqi_values = AQI() // Change to @StateObject on Ios 14
    @State var final_aqi = ""
    @State var final_city = ""
    @State var final_status = ""
    @State var AQI_ShowValues = false

    //@State var reloads = 0
        // List of Supported Cities
        // http://api.airvisual.com/v2/cities?state={{STATE_NAME}}&country={{COUNTRY_NAME}}&key={{YOUR_API_KEY}}
    
    
    var body: some View {
        return VStack {
            //Spacer()
            HStack(spacing:0) {
                Group{
                    Spacer().frame(width: 30, height: 0)
                    VStack(alignment: .leading ){
                        Group{
                            Spacer().frame(height: 100)
                            Text("Current Air Quality Index").foregroundColor(Color.init(UIColor.lightGray))
                            Spacer().frame(height: 10)
                            Text(aqi_values.aqi_city)
                        }
                        if self.final_aqi == "n/a" {
                        Group{
                            Spacer().frame(height: 50)
                            Text("2.5pm").foregroundColor(Color.init(UIColor.lightGray))
                            Text(aqi_values.aqi_num).font(.system(size: 60, weight: .regular)).foregroundColor(Color(aqi_values.aqi_status))
                            Text(aqi_values.aqi_status).foregroundColor(Color(aqi_values.aqi_status))
                            
                            }.hidden()
                            
                        } else {
                        Group{
                            Spacer().frame(height: 50)
                            Text("2.5pm").foregroundColor(Color.init(UIColor.lightGray))
                            Text(aqi_values.aqi_num).font(.system(size: 60, weight: .regular)).foregroundColor(Color(aqi_values.aqi_status))
                            Text(aqi_values.aqi_status).foregroundColor(Color(aqi_values.aqi_status))
                            
                            }
                        }
                        
                        //Text("Lat, Long:\(lf.userLatitude),\(lf.userLongitude)")
                        //Text("Reloads: \(reloads)")
                    }
                    Spacer()
                }

            }.padding(.leading, -10)
            
            Spacer()
            Group{
                VStack{
                    HStack {
                        Spacer()
                        Button(action: {self.set_values()}){
                            Text("Check Air Quality")
                            .frame( width: 200, height: 50)
                            .background(Color.init(UIColor.darkGray).opacity(0.5))
                            .cornerRadius(10)
                            //.opacity(0.25)
                            .foregroundColor(.white)
                            
                        }
                        Spacer()
                    }
                    Spacer().frame(height: 50)
                }
            }
            
        }.font(.system(size: 15, weight: .semibold)).foregroundColor(.white).background(Color.black).edgesIgnoringSafeArea(.all).onAppear {self.set_values()}

    }
    
    private func set_values() {
        aqi_values.set_AQIValues()
        self.final_aqi = aqi_values.aqi_num
        self.final_city = aqi_values.aqi_city
        self.final_status = aqi_values.aqi_status
        
        print(aqi_values.aqi_num,aqi_values.aqi_city,aqi_values.aqi_status)
        print(self.final_aqi,self.final_city,self.final_status)
    }

}



struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
    
}


