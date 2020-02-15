//
//  Simulator.swift
//  ControlRoom
//
//  Created by Paul Hudson on 12/02/2020.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

import Cocoa
import CoreServices

typealias Runtime = SimCtl.Runtime
typealias DeviceType = SimCtl.DeviceType

/// Stores one simulator and its identifier.
struct Simulator: Identifiable, Comparable, Hashable {
    enum Platform: CaseIterable {
        case iPhone
        case iPad
        case watch
        case tv

        var displayName: String {
            switch self {
            case .iPhone: return "iPhone"
            case .iPad: return "iPad"
            case .watch: return "Apple Watch"
            case .tv: return "Apple TV"
            }
        }
    }

    enum State {
        case unknown
        case creating
        case booting
        case booted
        case shuttingDown
        case shutdown

        init(deviceState: String?) {
            if deviceState == "Creating" {
                self = .creating
            } else if deviceState == "Booting" {
                self = .booting
            } else if deviceState == "Booted" {
                self = .booted
            } else if deviceState == "ShuttingDown" {
                self = .shuttingDown
            } else if deviceState == "Shutdown" {
                self = .shutdown
            } else {
                self = .unknown
            }
        }
    }

    /// The user-facing name for this simulator, e.g. iPhone 11 Pro Max.
    let name: String

    /// The internal identifier that represents this device.
    let udid: String

    /// Sends back the UDID for Identifiable.
    var id: String { udid }

    /// The uniform type identifier of the simulator device
    let typeIdentifier: TypeIdentifier

    /// The icon representing the simulator's device
    let image: NSImage

    /// The platform of the simulator
    let platform: Platform

    /// The information about the simulator OS
    let runtime: Runtime?

    /// The device type of the simulator
    let deviceType: DeviceType?

    /// The current state of the simulator
    let state: State

    init(name: String, udid: String, state: State, runtime: Runtime?, deviceType: DeviceType?) {
        self.name = name
        self.udid = udid
        self.state = state
        self.runtime = runtime
        self.deviceType = deviceType

        let typeIdentifier: TypeIdentifier
        if let model = deviceType?.modelTypeIdentifier {
            typeIdentifier = model
        } else if name.contains("iPad") {
            typeIdentifier = .defaultiPad
        } else if name.contains("Watch") {
            typeIdentifier = .defaultWatch
        } else if name.contains("TV") {
            typeIdentifier = .defaultTV
        } else {
            typeIdentifier = .defaultiPhone
        }

        self.typeIdentifier = typeIdentifier
        self.image = typeIdentifier.icon

        if typeIdentifier.conformsTo(.pad) {
            self.platform = .iPad
        } else if typeIdentifier.conformsTo(.watch) {
            self.platform = .watch
        } else if typeIdentifier.conformsTo(.tv) {
            self.platform = .tv
        } else {
            self.platform = .iPhone
        }
    }

    /// Sort simulators alphabetically.
    static func < (lhs: Simulator, rhs: Simulator) -> Bool {
        lhs.name < rhs.name
    }

    /// An example simulator for Xcode preview purposes
    static let example = Simulator(name: "iPhone 11 Pro max", udid: UUID().uuidString, state: .booted, runtime: .unknown, deviceType: nil)

    /// Users whichever simulator simctl feels like; if there's only one active it will be used,
    /// but if there's more than one simctl just picks one.
    static let `default` = Simulator(name: "Default", udid: "booted", state: .booted, runtime: nil, deviceType: nil)
}