//
//  KeyHelper.swift
//  qubic
//
//  Created by Chris McElroy on 4/1/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import Foundation

enum Key: String {
	case buildNumber = "buildNumber"
	case versionType = "versionType"
	case active = "active"
    case streak = "DCStreak"
    case lastDC = "LastDC"
    case badge = "qubic badge notification"
	case currentDaily = "currentDaily"
	case dailyHistory = "dailyHistory"
    case daily = "daily"
    case simple = "simple"
    case common = "common"
    case tricky = "tricky"
	case solveBoardsVersion = "solveBoardsVersion"
	case solvedBoards = "solvedBoards"
    case train = "train"
    case lastTrainMenu = "lastTrainMenu"
    case lastPlayMenu = "lastPlayMenu"
    case cubist = "cubist"
    case name = "name"
    case color = "color"
    case notification = "notifications"
    case premoves = "premoves"
    case spin = "spin"
    case arrowSide = "arrowSide"
    case uuid = "uuidKey"
    case messagesID = "messagesID"
    case email = "email"
    case feedback = "feedback"
	case moveChecker = "moveChecker"
	case confirmMoves = "confirmMoves"
	case speed = "speed"
	case offAtt = "offAtt"
	case defAtt = "defAtt"
	case depth = "depth"
	case randomness = "randomness"
    
    case myTurn = "myTurn"
    case myID = "myID"
    case opID = "opID"
    case hints = "hints"
    case timeLimit = "timeLimit"
    case state = "state"
	case mode = "mode"
    case myTimes  = "myTimes"
    case opTimes = "opTimes"
    case myMoves = "myMoves"
    case opMoves = "opMoves"
	case myMoveTimes = "myMoveTimes"
	case opMoveTimes = "opMoveTimes"
	case endTime = "endTime"
    case gameID = "gameID"
    case opGameID = "opGameID"
	case setupNum = "setupNum"
	case presetCount = "presetCount"
	
	case playedTutorial = "playedTutorial"
	case tipsShown = "tipsShown"
	case tipsOn = "tipsOn"
}

