//
//  ReplaysView.swift
//  qubic
//
//  Created by 4 on 8/4/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct ReplaysView: View {
    @State var mainButtonAction: () -> Void
    
    var body: some View {
        VStack {
            Button(action: mainButtonAction) {
                Text("replays")
            }
            .buttonStyle(MoreStyle())
            Spacer()
            List {
                Section(header: HStack {
                    Spacer()
                    Text("1 hour ago")
                        .font(.system(size: 16))
                        .offset(y: 5)
                        .padding(.all, 5)
                    Spacer()
                }
                    .background(Color.systemBackground)
                    .listRowInsets(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0))
                ) {
                    HStack {
                        HStack {
                            Text("W").fontWeight(.bold).padding(.trailing, -4)
                            Text("in 24")
                        }
                            .frame(width: 60, alignment: .leading)
                            .font(.system(size: 15))
                        Spacer()
                        ZStack {
                            Rectangle()
                                .foregroundColor(.blue)
                                .frame(width: 200, height: 32)
                                .cornerRadius(100)
                            Text("sup")
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Image(systemName: "person.badge.plus.fill")
                        .scaleEffect(1.3)
                            .padding(.trailing, 5)
                            .frame(width: 60, alignment: .trailing)
                        
                    }.frame(height: 40)
                    HStack {
                        HStack {
                            Text("W").fontWeight(.bold).padding(.trailing, -4)
                            Text("in 38")
                        }
                            .frame(width: 60, alignment: .leading)
                            .font(.system(size: 15))
                        Spacer()
                        ZStack {
                            Rectangle()
                                .foregroundColor(.red)
                                .frame(width: 200, height: 32)
                                .cornerRadius(100)
                            Text("number two")
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Image(systemName: "")
                            .scaleEffect(1.3)
                            .padding(.trailing, 5)
                            .frame(width: 60, alignment: .trailing)
                        
                    }.frame(height: 40)
                    HStack {
                        HStack {
                            Text("L").fontWeight(.bold).padding(.trailing, -4)
                            Text("in 16")
                        }
                            .frame(width: 60, alignment: .leading)
                            .font(.system(size: 15))
                        Spacer()
                        ZStack {
                            Rectangle()
                                .foregroundColor(.green)
                                .frame(width: 200, height: 32)
                                .cornerRadius(100)
                            Text("another one")
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Image(systemName: "")
                            .scaleEffect(1.3)
                            .padding(.trailing, 5)
                            .frame(width: 60, alignment: .trailing)
                        
                    }.frame(height: 40)
                }
                Section(header: HStack {
                    Spacer()
                    Text("2 days ago")
                        .font(.system(size: 16))
                        .offset(y: 5)
                        .padding(.all, 5)
                    Spacer()
                }
                    .background(Color.systemBackground)
                    .listRowInsets(EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0))
                ) {
                    HStack {
                        HStack {
                            Text("W").fontWeight(.bold).padding(.trailing, -4)
                            Text("in 6")
                        }
                            .frame(width: 60, alignment: .leading)
                            .font(.system(size: 15))
                        Spacer()
                        ZStack {
                            Rectangle()
                                .foregroundColor(.yellow)
                                .frame(width: 200, height: 32)
                                .cornerRadius(100)
                            Text("gave up")
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Image(systemName: "person.badge.plus.fill")
                        .scaleEffect(1.3)
                            .padding(.trailing, 5)
                            .frame(width: 60, alignment: .trailing)
                        
                    }.frame(height: 40)
                    HStack {
                        HStack {
                            Text("L").fontWeight(.bold).padding(.trailing, -4)
                            Text("in 19")
                        }
                            .frame(width: 60, alignment: .leading)
                            .font(.system(size: 15))
                        Spacer()
                        ZStack {
                            Rectangle()
                                .foregroundColor(.purple)
                                .frame(width: 200, height: 32)
                                .cornerRadius(100)
                            Text("this guy")
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Image(systemName: "")
                            .scaleEffect(1.3)
                            .padding(.trailing, 5)
                            .frame(width: 60, alignment: .trailing)
                        
                    }.frame(height: 40)
                    HStack {
                        HStack {
                            Text("D").fontWeight(.bold).padding(.trailing, -4)
                            Text("in 64")
                        }
                            .frame(width: 60, alignment: .leading)
                            .font(.system(size: 15))
                        Spacer()
                        ZStack {
                            Rectangle()
                                .foregroundColor(.blue)
                                .frame(width: 200, height: 32)
                                .cornerRadius(100)
                            Text("really good")
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Image(systemName: "person.badge.plus.fill")
                            .scaleEffect(1.3)
                            .padding(.trailing, 5)
                            .frame(width: 60, alignment: .trailing)
                        
                    }.frame(height: 40)
                }
            }
//            .modifier(KeepLowercase())
            Fill()
        }
        .background(Fill())
    }
}

//struct ListView: View {
//    var body: some View {
//        List {
//            Section(header: Text("header text")
//            ) {
//                Text("list text")
//            }.modifier(KeepLowercase())
//        }
//    }
//}

//struct KeepLowercase: ViewModifier {
//    var thing: Bool = false
//    @ViewBuilder
//    func body(content: Content) -> some View {
//        guard #available(iOS 14, *) else {
//            content.textCase(nil)
//        }
//        content
//    }
//}

struct ReplaysView_Previews: PreviewProvider {
    static var previews: some View {
        ReplaysView() {}
    }
}
