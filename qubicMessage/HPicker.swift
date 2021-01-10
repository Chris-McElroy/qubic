//
//  HPicker.swift
//  qubicMessage
//
//  Created by 4 on 1/9/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import UIKit
import CoreGraphics

class HPicker: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var content: [[Any]]
    var dim: (CGFloat,CGFloat)
    var selected: [Int]
    var action: (Int, Int) -> Void
    let picker = UIPickerView()
    
    init(content: [[Any]], dim: (CGFloat, CGFloat), selected: [Int], action: @escaping (Int, Int) -> Void) {
        self.content = content
        self.dim = dim
        self.selected = selected
        self.action = action
        super.init()
        
        picker.dataSource = self
        picker.delegate = self
        picker.transform = CGAffineTransform(rotationAngle: -.pi/2)
        for (c,r) in selected.enumerated() {
            picker.selectRow(r, inComponent: c, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(parent1: self)
//    }
    
    func updatePicker() {
//        guard let picker = UIView as? UIPickerView else { return }
        for c in 0..<content.count {
            for r in 0..<content[c].count {
                if let string = content[c][r] as? String {
                    if let label = picker.view(forRow: r, forComponent: c) as? UILabel {
                        if label.text != string {
                            picker.reloadComponent(c)
                            break
                        }
                    }
                }
            }
        }
        for (c,r) in selected.enumerated() {
            if picker.selectedRow(inComponent: c) != r {
                picker.selectRow(r, inComponent: c, animated: true)
            }
        }
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        content[component].count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        content.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if component+row == 0 { pickerView.subviews[1].alpha = 0 }
        guard let text = content[component][row] as? String else { return UIView() }
//            if let givenFunc = text as? () -> UIView { return givenFunc() }
//            guard let (text, done) = content as? (String, Bool) else { return UIView() }
        return getLabel(for: text, underline: false)
    }
    
    func getLabel(for text: String, underline: Bool) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.textColor = .label
        if underline { label.underline() }
        label.transform = CGAffineTransform(rotationAngle: .pi/2)
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        dim.0
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        dim.1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected[component] = row
        action(row, component)
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
