//
//  main.swift
//  settings
//
//  Created by Joseph Smith on 1/21/15.
//  Copyright (c) 2015 bjoli. All rights reserved.
//

import Foundation

let SUDO = "/usr/bin/sudo"
let NVRAM = "/usr/sbin/nvram"
// Boot your system in verbose mode
let VERBOSE_BOOT = [NVRAM, "boot-args=-v"]
// Disable the loud startup chime which indicates hardware self-check success
let DISABLE_STARTUP_CHIME = [NVRAM, "SystemAudioVolume=%80"]

func runSudoCommand(commandLine: [String], sudoPassword: String) {
    let task = NSTask()
    task.launchPath = SUDO
    task.arguments = ["-S"] + commandLine

    let output = NSPipe()
    task.standardError = output
    let input = NSPipe()
    task.standardInput = input

    if let passwordData = sudoPassword.dataUsingEncoding(NSASCIIStringEncoding) {
        task.launch()
        input.fileHandleForWriting.writeData(passwordData)
        input.fileHandleForWriting.closeFile()
    }

    task.waitUntilExit()
    let data = output.fileHandleForReading.readDataToEndOfFile()
    if let output: String? = NSString(data: data, encoding: NSUTF8StringEncoding) {
        println(output)
    }
}

func retrieveSudoPassword() -> String? {
    println("Please enter your sudo password")
    let fh = NSFileHandle.fileHandleWithStandardInput()
    let data = fh.availableData
    if let str = NSString(data: data, encoding: NSUTF8StringEncoding) {
        return str
    }
    return nil
}

if let sudoPassword = retrieveSudoPassword() {
    runSudoCommand(VERBOSE_BOOT, sudoPassword)
    runSudoCommand(DISABLE_STARTUP_CHIME, sudoPassword)
} else {
    println("Please enter a sudo password.")
}
