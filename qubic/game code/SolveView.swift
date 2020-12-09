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
    @State var streakText: String = ""
    @State var selected: [Int] = [0,0]
    @State var boardOptions: [String] = (1...35).map { String($0) }
    var switchBack: () -> Void
    
    let difficultyOptions = ["daily\n239","simple\n23","common\n23","tricky\n23"]
    
    var pickerText: [[String]] { [boardOptions,difficultyOptions,getDateString()] }
    
    var body: some View {
        VStack(spacing: 0) {
            if view == .solve {
                GameView(getSolveBoard(), dc: selected[0] == 0) {self.switchBack() }.onAppear { print(selected)}
            } else {
                VStack(spacing: 0) {
//                    Spacer()
                    HPicker(text: pickerText, width: 77, selected: $selected)
                        .frame(height: 90)
                        .onAppear { updateStreak() }
//                    difficultyPicker
//                    Fill(5)
//                    boardPicker
                }.opacity(view == .solveMenu ? 1 : 0)
            }
        }
    }
    
    var difficultyPicker: some View {
        HStack {
            Text(streakText)
            Image("pinkCube")
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
    
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
    
    func select(_ n: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selected[0] = Int(n)
        }
    }
    
    func getDateString() -> [String] {
        let format = DateFormatter()
        format.dateStyle = .short
        return [format.string(from: Date())]
    }
    
    func getSolveBoard() -> [Int] {
        if selected[0] == 0 {
            let day = Calendar.current.component(.day, from: Date())
            let month = Calendar.current.component(.month, from: Date())
            let year = Calendar.current.component(.year, from: Date())
            let total = allSolveBoards.count
            let offset = (year+month+day) % (total/31 + (total%31 > day ? 1 : 0))
            return expandMoves(allSolveBoards[31*offset + day])
        } else {
            return expandMoves(allSolveBoards[21])
        }
    }
    
    func updateStreak() {
        let lastDC = UserDefaults.standard.integer(forKey: LastDCKey)
        let streak = UserDefaults.standard.integer(forKey: DCStreakKey)
        updateBadge(now: lastDC < Date().getInt())
        if lastDC >= Date().getInt() - 1 && streak > 0 {
            streakText = "streak: \(streak)"
        } else {
            streakText = ""
            UserDefaults.standard.setValue(0, forKey: DCStreakKey)
        }
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
