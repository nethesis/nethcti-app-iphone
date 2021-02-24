//
//  NethContact.swift
//  NethCTI
//
//  Created by Administrator on 21/04/2020.
//

import Foundation

// MARK: - NethContact
@objcMembers class NethContact: NSObject {
    let id: Int
    let ownerID: String
    let type: NethContactType
    let homeemail, workemail, homephone, workphone: String
    let cellphone, fax, title, company: String
    let notes, name, homestreet, homepob: String
    let homecity, homeprovince, homepostalcode, homecountry: String
    let workstreet, workpob, workcity, workprovince: String
    let workpostalcode, workcountry, url, rowExtension: String
    let speeddialNum: String
    let source: NethContactSource
    
    init(id: Int, ownerID: String, type: NethContactType, homeemail: String, workemail: String, homephone: String, workphone: String, cellphone: String, fax: String, title: String, company: String, notes: String, name: String, homestreet: String, homepob: String, homecity: String, homeprovince: String, homepostalcode: String, homecountry: String, workstreet: String, workpob: String, workcity: String, workprovince: String, workpostalcode: String, workcountry: String, url: String, rowExtension: String, speeddialNum: String, source: NethContactSource) {
        self.id = id
        self.ownerID = ownerID
        self.type = type
        self.homeemail = homeemail
        self.workemail = workemail
        self.homephone = homephone
        self.workphone = workphone
        self.cellphone = cellphone
        self.fax = fax
        self.title = title
        self.company = company
        self.notes = notes
        self.name = name
        self.homestreet = homestreet
        self.homepob = homepob
        self.homecity = homecity
        self.homeprovince = homeprovince
        self.homepostalcode = homepostalcode
        self.homecountry = homecountry
        self.workstreet = workstreet
        self.workpob = workpob
        self.workcity = workcity
        self.workprovince = workprovince
        self.workpostalcode = workpostalcode
        self.workcountry = workcountry
        self.url = url
        self.rowExtension = rowExtension
        self.speeddialNum = speeddialNum
        self.source = source
    }
    
    init(raw: [String:Any]) {
        self.id = raw["id"] as! Int
        self.ownerID = raw["owner_id"] as? String ?? ""
        if let type = raw["type"] as? String,
           let nethType = NethContactType(rawValue: type) {
            self.type = nethType
        } else { self.type = .typeExtension }
        self.homeemail = raw["homeemail"] as? String ?? ""
        self.workemail = raw["workemail"] as? String ?? ""
        self.homephone = raw["homephone"] as? String ?? ""
        self.workphone = raw["workphone"] as? String ?? ""
        self.cellphone = raw["cellphone"] as? String ?? ""
        self.fax = raw["fax"] as? String ?? ""
        self.title = raw["title"] as? String ?? ""
        if let company = raw["company"] as? String,
           company != "" {
            self.company = company
        } else {
            self.company = ""
        }
        self.notes = raw["notes"] as? String ?? ""
        self.name = raw["name"] as? String ?? ""
        self.homestreet = raw["homestreet"] as? String ?? ""
        self.homepob = raw["homepob"] as? String ?? ""
        self.homecity = raw["homecity"] as? String ?? ""
        self.homeprovince = raw["homeprovince"] as? String ?? ""
        self.homepostalcode = raw["homepostalcode"] as? String ?? ""
        self.homecountry = raw["homecountry"] as? String ?? ""
        self.workstreet = raw["workstreet"] as? String ?? ""
        self.workpob = raw["workpob"] as? String ?? ""
        self.workcity = raw["workcity"] as? String ?? ""
        self.workprovince = raw["workprovince"] as? String ?? ""
        self.workpostalcode = raw["workpostalcode"] as? String ?? ""
        self.workcountry = raw["workcountry"] as? String ?? ""
        self.url = raw["url"] as? String ?? ""
        self.rowExtension = raw["extension"] as? String ?? ""
        self.speeddialNum = raw["speeddial_num"] as? String ?? ""
        if let source = raw["source"] as? String,
           let nethSource = NethContactSource(rawValue: source) {
            self.source = nethSource
        } else { self.source = .centralized }
    }
    
    /**
     Convert a Nethcti contact to a Linphone contact, mapping their fields.
     TODO: Map sip fields.
     */
    @objc public func toLinphoneContact() -> Contact {
        // Init a blank contact. CNContact is the iOS Contact.
        let contact = Contact.init(cnContact: CNContact.init())
        contact!.nethesis = true
        contact!.firstName = self.name
        contact!.addEmail(self.homeemail)
        contact!.addEmail(self.workemail)
        contact!.addPhoneNumber(self.homephone)
        contact!.addPhoneNumber(self.workphone)
        contact!.addPhoneNumber(self.cellphone)
        contact!.addSipAddress(self.rowExtension)
        contact!.company = self.company
        contact!.notes = self.notes
        contact!.ownerId = self.ownerID
        contact!.title = self.title
        contact!.displayName = "\(self.name) - \(self.company)".trimmingCharacters(in: CharacterSet(arrayLiteral: " ", "-"))
        return contact!
    }
}
