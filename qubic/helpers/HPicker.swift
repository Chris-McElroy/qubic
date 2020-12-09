//
//  File.swift
//  qubic
//
//  Created by 4 on 12/8/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI
import UIKit
import CoreGraphics

struct HPicker : UIViewRepresentable {
    
    @State var text: [[String]]
    @State var width: CGFloat
    @Binding var selected: [Int]
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent1: self)
    }
    
    func makeUIView(context: Context) -> some UIView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        picker.transform = CGAffineTransform(rotationAngle: -.pi/2)
        return picker
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: HPicker
        
        init(parent1: HPicker) {
            parent = parent1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//            print("woeif ", component, parent.text)
            if parent.selected[1] == 0 && component == 0 {
                return parent.text[2].count
            } else {
                return parent.text[component].count
            }
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            2
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            pickerView.subviews[1].alpha = 0
            if component == 1 {
                let v = UIButton()
                let text = parent.text[1][row]
                let loc = NSString(string: text).range(of: "\n").location
                let fancyText = NSMutableAttributedString.init(string: text)
                fancyText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                         NSAttributedString.Key.foregroundColor: UIColor.gray],
                                        range: NSRange(location: loc, length: text.count-loc))
                v.setAttributedTitle(fancyText, for: .normal)
                v.titleLabel?.lineBreakMode = .byWordWrapping
                v.titleLabel?.textAlignment = .center
                v.transform = CGAffineTransform(rotationAngle: .pi/2)
                return v
            } else {
                let c = pickerView.selectedRow(inComponent: 1) == 0 ? 2 : 0
                let text = row < parent.text[c].count ? parent.text[c][row] : ""
                let v = UIButton(type: .custom)
                v.setTitle(text, for: .normal)
                v.setTitleColor(.black, for: .normal)
                if (Int(text) ?? 5) < 4 { v.underline() }
                v.transform = CGAffineTransform(rotationAngle: .pi/2)
                return v
            }
        }
        
//        func getCube() -> UIView {
//            let image = UIImage(named: "blueCube")
//            let label = UIButton()
//            label.setImage(image, for: .normal)
//            label.transform = CGAffineTransform(rotationAngle: .pi/2)
//            label.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//            return label
//        }
//
//        func getName(text: String) -> UIView {
//            let v = UIButton(type: .custom)
//            v.setTitle(text, for: .normal)
//            v.setTitleColor(.black, for: .normal)
//            v.transform = CGAffineTransform(rotationAngle: .pi/2)
//            return v
//        }
        
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            parent.width
        }
        
        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            [30,45][component]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.selected[component] = row
            if component == 1 {
                pickerView.selectRow(0, inComponent: 0, animated: true)
                pickerView.reloadComponent(0)
            }
        }
        
    }
}
