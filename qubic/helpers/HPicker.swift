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
    @State var dim: (CGFloat,CGFloat)
    @Binding var selected: [Int]
    var action: (Int, Int) -> Void
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent1: self)
    }
    
    func makeUIView(context: Context) -> some UIView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        picker.transform = CGAffineTransform(rotationAngle: -.pi/2)
        for (c,r) in selected.enumerated() {
            picker.selectRow(r, inComponent: c, animated: true)
        }
        return picker
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: HPicker
        
        init(parent1: HPicker) {
            parent = parent1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            (solveMode(is: "daily") && component == 0) ? 1 : parent.text[component].count
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            parent.text.count
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            if component+row == 0 { pickerView.subviews[1].alpha = 0 }
            var text = parent.text[component][row]
            let v = UIButton(type: .custom)
            if text.contains("\n") {
                v.setAttributedTitle(getFormattedText(from: text), for: .normal)
                v.titleLabel?.lineBreakMode = .byWordWrapping
                v.titleLabel?.textAlignment = .center
            } else {
                if solveMode(is: "daily") { text = row == 0 ? getDateText() : "" }
                v.setTitle(text, for: .normal)
                v.setTitleColor(.label, for: .normal)
                if shouldUnderline(component, row) { v.underline() }
            }
            v.transform = CGAffineTransform(rotationAngle: .pi/2)
            return v
        }
        
        func getFormattedText(from string: String) -> NSMutableAttributedString {
            let loc = NSString(string: string).range(of: "\n").location
            let text = NSMutableAttributedString.init(string: string)
            text.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                                     NSAttributedString.Key.foregroundColor: UIColor.gray],
                                    range: NSRange(location: loc, length: string.count-loc))
            return text
        }
        
        func getDateText() -> String {
            let format = DateFormatter()
            format.dateStyle = .short
            return format.string(from: Date())
        }
        
        func solveMode(is s: String) -> Bool {
            if parent.selected.count == 2 && parent.text.count == 2 {
                return parent.text[1][parent.selected[1]].contains(s)
            }
            return false
        }
        
        func trainMode() -> Bool {
            parent.text.count == 3 ? parent.text[2][0].contains("beginner") : false
        }
        
        func shouldUnderline(_ c: Int, _ r: Int) -> Bool {
            if c == 0 {
                if solveMode(is: "daily") {
                    return Date().getInt() == UserDefaults.standard.integer(forKey: lastDCKey)
                } else if solveMode(is: "tricky") {
                    return (UserDefaults.standard.array(forKey: trickyKey)?[r] as? Int ?? 0) == 1
                }
            } else if c == 2 && trainMode() {
                if r == 0 {
                    return UserDefaults.standard.integer(forKey: beginnerKey) == 1
                } else {
                    return UserDefaults.standard.integer(forKey: defenderKey) == 1
                }
            }
            return false
        }
        
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            parent.dim.0
        }
        
        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            parent.dim.1
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.selected[component] = row
            parent.action(row, component)
            if parent.text[component][0].contains("\n") {
                pickerView.selectRow(0, inComponent: 0, animated: true)
                pickerView.reloadComponent(0)
            }
        }
        
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
