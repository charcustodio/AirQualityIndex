//
//  InputView.swift
//  aqi
//
//  Created by aoi on 9/1/20.
//  Copyright © 2020 kc_cc. All rights reserved.
//

import SwiftUI

struct InputView: View {
    @State private var new_zipcode = "94102" //curr_zipcode
    @State private var dig1 = ""
    @State private var dig2 = ""
    @State private var dig3 = ""
    @State private var dig4 = ""
    @State private var dig5 = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        
        NavigationView {
        Button(action: {
           self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Back").padding()
        }
        VStack (alignment: .center, spacing: 10){
            Group {
            Spacer()
            Text("Enter Your Zipcode").foregroundColor(.white)
            HStack {
                Spacer()
                Group {
                    TextField("9", text: $dig1)
                    TextField("4", text: $dig2)
                    TextField("1", text: $dig3)
                    TextField("2", text: $dig4)
                    TextField("2", text: $dig5)
                }.font(.system(size: 40, weight: .semibold)).keyboardType(.decimalPad).multilineTextAlignment(.center).frame(width: 60, height:80, alignment:.center).background(Color.gray).cornerRadius(5)
                Spacer()
            }
            Spacer()
            }
        }.font(.system(size: 15, weight: .semibold)).foregroundColor(.white).background(Color.black).edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
    }
}
