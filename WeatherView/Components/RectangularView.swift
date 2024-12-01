//
//  RectangularView.swift
//  wheather
//
//  Created by Pavel Playerz0redd on 29.09.24.
//

import SwiftUI

struct RectangularView: View {
    
    let upInfo: String
    let downInfo: String
    let comment: String
    let height: Float
    let width: Float
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundStyle(Color("rectColor"))
            .frame(width: CGFloat(width), height: CGFloat(height))
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading) {
                    Text(upInfo)
                        .font(.system(size: 16))
                        .foregroundStyle(Color .white)
                        .opacity(0.6)
                        .padding(.top, 5)
                    Text(downInfo)
                        .font(.system(size: 20))
                        .foregroundStyle(Color .white)
                        .bold()
                    Spacer()
                    Divider()
                        .padding(.trailing, 10)
                        .padding(.top, 10)
                    Text(comment)
                        .font(.system(size: 17))
                        .foregroundStyle(Color .white)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                }
                .padding(.leading, 10)
            }
    }
}

#Preview {
    RectangularView(upInfo: "", downInfo: "", comment: "", height: 100, width: 100)
}
