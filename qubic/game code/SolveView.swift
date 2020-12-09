//
//  SolveView.swift
//  qubic
//
//  Created by 4 on 7/26/20.
//  Copyright © 2020 XNO LLC. All rights reserved.
//

import SwiftUI

struct SolveView: View {
    @Binding var view: ViewStates
    @State var selected: [Int] = [0,0]
    var switchBack: () -> Void
    var mode: GameMode {
        switch selected[1] {
        case 1: return .tricky
        default: return .daily
        }
    }
    var board: Int { selected[0] }
    
    var body: some View {
        VStack(spacing: 0) {
            if view == .solve {
                GameView(mode: mode, boardNum: board) { self.switchBack() }
            } else {
                HPicker(text: getPickerText(), dim: (77, 40), selected: $selected)
                    .frame(height: 80)
                    .opacity(view == .solveMenu ? 1 : 0)
            }
        }
    }
    
//    var difficultyPicker: some View {
//        HStack {
//            Text(String(streak))
//            Image("pinkCube")
//                .resizable()
//                .frame(width: 40, height: 40)
//        }
//    }
    
//    var boardOptions: [UIView] { [UIName(text: getDateString(), color: .purple, action: nil), UIName(text: "hard board", color: .blue, action: nil)] }
    
//    var boardPicker: some View {
//        HPicker(text: (0...30).map { String($0) }).frame(height: 40)
//        Picker("boards", selection: $selected) {
//            Text("this2").font(.system(size: 100))
//                .frame(width: 40, height: 160, alignment: .center)
//                .rotationEffect(.degrees(90))
//            Text("this1")
//                .frame(width: 40, height: 160, alignment: .center)
//                .rotationEffect(.degrees(90))
//            HStack {
//                Spacer(minLength: nameButtonWidth*(1-selected))
//                Name(text: getDateString(), color: .purple) { select(0) }
//                Name(text: "hard board", color: .blue) { select(1) }
//                Spacer(minLength: nameButtonWidth*selected)
//            }.frame(alignment: .center)
//        }.pickerStyle(InlinePickerStyle())
//        .rotationEffect(.degrees(-90))
//        .frame(width: 300, height: 40)
//
//    }
//    
//    func select(_ n: Int) {
//        withAnimation(.easeInOut(duration: 0.3)) {
//            type = n
//        }
//    }
    
    func getPickerText() -> [[String]] {
        let streak = getStreakText()
        let tricky = getTrickyText()
        return [["1"],[streak,tricky]]
    }
    
    func getStreakText() -> String {
        let lastDC = UserDefaults.standard.integer(forKey: lastDCKey)
        updateBadge(now: lastDC < Date().getInt())
        let streak = UserDefaults.standard.integer(forKey: streakKey)
        return "daily\n\(streak)"
//        if lastDC >= Date().getInt() - 1 && streak > 0 {
//            streak = "streak: \(streak)"
//        } else {
//            streakText = ""
//            UserDefaults.standard.setValue(0, forKey: DCStreakKey)
//        }
    }
    
    func getTrickyText() -> String {
        let tricky = UserDefaults.standard.array(forKey: trickyKey) as? [Int] ?? [0]
        return "tricky\n\(tricky.sum())"
    }
    
    func updateBadge(now: Bool) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [badgeKey])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [badgeKey])
        UIApplication.shared.applicationIconBadgeNumber = now ? 1 : 0
        let content = UNMutableNotificationContent()
        content.badge = 1
        var tomorrow = DateComponents()
        tomorrow.hour = 0
        tomorrow.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: tomorrow, repeats: false)
        let request = UNNotificationRequest(identifier: badgeKey, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

struct SolveView_Previews: PreviewProvider {
    static var previews: some View {
        SolveView(view: .constant(.solveMenu)) {}
    }
}
