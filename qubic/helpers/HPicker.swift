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
    @Binding var content: [[Any]]
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
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let picker = uiView as? UIPickerView else { return }
        picker.reloadAllComponents()
        for (c,r) in selected.enumerated() {
            if picker.selectedRow(inComponent: c) != r {
                picker.selectRow(r, inComponent: c, animated: true)
            }
        }
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: HPicker
        
        init(parent1: HPicker) {
            parent = parent1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.content[component].count
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            parent.content.count
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            if component+row == 0 { pickerView.subviews[1].alpha = 0 }
            
            let content = parent.content[component][row]
            if let givenFunc = content as? () -> UIView { return givenFunc() }
            if let (text, done) = content as? (String, Bool) { return getLabel(for: text, underline: done) }
			if let text = content as? String { return getLabel(for: text) }
			return UIView()
        }
        
        func getLabel(for text: String, underline: Bool = false) -> UILabel {
            let label = UILabel()
            label.text = text
            label.textAlignment = .center
            label.textColor = .label
            if underline { label.underline() }
            label.transform = CGAffineTransform(rotationAngle: .pi/2)
            return label
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
