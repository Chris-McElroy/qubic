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
    var switchBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            difficultyPicker
            Fill(5)
            boardPicker
            if view == .solve {
                GameView(getSolveBoard()) { self.switchBack() }
            }
            Fill(5)
        }
    }
    
    var difficultyPicker: some View {
        HStack {
            Text(getDCString())
            Image("pinkCube")
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
    
    var boardPicker: some View {
        Text(getDateString())
            .foregroundColor(.white)
            .frame(width: 160, height: 40)
            .background(Rectangle().foregroundColor(.purple))
            .cornerRadius(100)
    }
    
    func getDateString() -> String {
        let format = DateFormatter()
        format.dateStyle = .long
        return format.string(from: Date())
    }
    
    func getSolveBoard() -> [Int] {
        let day = Calendar.current.component(.day, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let year = Calendar.current.component(.year, from: Date())
        let total = allSolveBoards.count
        let offset = (year+month+day) % (total/31 + (total % 31 > day ? 1 : 0))
        return expandMoves(allSolveBoards[31*offset+day])
    }
    
    func getDCString() -> String {
        let lastDC = UserDefaults.standard.integer(forKey: LastDCKey)
        let streak = UserDefaults.standard.integer(forKey: DCStreakKey)
        updateBadge(now: lastDC < Date().getInt())
        if streak == 0 { return "" }
        if lastDC >= Date().getInt()-1 { return "\(streak) day streak" }
        UserDefaults.standard.setValue(0, forKey: DCStreakKey) // streak out of date, reset
        return ""
    }
    
    func updateBadge(now: Bool) {
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
