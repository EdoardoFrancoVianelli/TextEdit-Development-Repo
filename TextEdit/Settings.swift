//
//  Settings.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/18/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation
import LocalAuthentication

class Settings
{
    private var Attributes = Dictionary<String, String>()
    private var AttributeOptions = Dictionary<String, [String]>()
    private var SettingsAttributeNames = [(String, [String])]()
    private var Element = ""

    var SettingCount : Int
    {
        get
        {
            return self.Attributes.count
        }
    }

    private func InitializeSettingsAttributeNames()
    {
        var HumanReadables = ["File Sorting", "File Format", "Ask before deleting a file or folder", "File Searching Options"]
        var SettingsOptions : [[String]] = [
            ["Name, Ascending", "Name, Descending", "Date Created, Ascending", "Date Created, Descending", "Size, Ascending", "Size, Descending", "Date Modified, Ascending", "Date Modified, Descending"].sort({ $0 < $1 } ),
            ["txt", "rtf"],
            ["Yes", "No"],["Case Insensitive", "Case Sensitive"]
        ]

        let Context = LAContext()
        let Error = NSErrorPointer()

        if Context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: Error)
        {
            //print("Adding")
            HumanReadables.append("Use Touch ID")
            SettingsOptions.append(["Yes", "No"])
        }
        else
        {
            //print("Nah son")
        }

        for i in 0..<HumanReadables.count
        {
            let HumanReadableNameLeft = HumanReadables[i]
            let OptionsForSetting = SettingsOptions[i]
            self.SettingsAttributeNames.append((HumanReadableNameLeft, OptionsForSetting))
        }
    }

    func InitializeDifferentSettingOptions()
    {
        for SettingsNameTuple in self.SettingsAttributeNames
        {
            self.AttributeOptions[SettingsNameTuple.0] = SettingsNameTuple.1
        }
    }

    func InitializeDefaultAttributes()
    {
        for SettingsNameTuple in self.SettingsAttributeNames
        {
            let AllOptions = SettingsNameTuple.1
            if let First = AllOptions.first
            {
                self.Attributes[SettingsNameTuple.0] = First
            }
        }
    }

    init()
    {
        self.InitializeSettingsAttributeNames()
        self.InitializeDifferentSettingOptions()
        self.InitializeDefaultAttributes()
        self.SetSettingNames()
        self.LoadSettings()
    }

    func SettingsFileExists() -> Bool
    {
        return NSData(contentsOfFile: SettingsFilePath()) != nil
    }

    func LoadSettings()
    {
        if self.SettingsFileExists()
        {
            //print("File exists")
            self.GetCurrentSettings()
        }
        else
        {
            //print("file does not exist")
            self.WriteSettingsToFile()
        }
    }
    
    func SettingsFilePath() -> String
    {
        return GetDocumentsDirectory() + "/Settings.plist"
    }

    func GetCurrentSettings()
    {
        let CurrentSettings = NSDictionary(contentsOfFile: SettingsFilePath())
        Attributes = CurrentSettings as! Dictionary<String, String>
    }

    func WriteSettingsToFile()
    {
        (Attributes as NSDictionary).writeToFile(SettingsFilePath(), atomically: true)
    }

    func GetSettingForAttribute(name : String) -> String?
    {
        
        return self.Attributes[name]
    }

    func SetSettingForAttribute(name : String, value: String)
    {
        if let _ = self.Attributes[name]
        {
            self.Attributes[name] = value
        }
    }

    func OptionsForSettingName(name : String) -> [String]?
    {
        return self.AttributeOptions[name]
    }

    //MARK: Setting Names

    private var _settingNames = [String]()

    func SetSettingNames()
    {
        for (SettingName, _) in self.SettingsAttributeNames
        {
            self._settingNames.append(SettingName)
        }

        self._settingNames.sortInPlace({ $0 < $1 })
    }

    var AlphabeticalSettingNames : [String]
    {
        get
        {
            return self._settingNames
        }
    }
}























