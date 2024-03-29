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
    let type: String
    let homeemail, workemail, homephone, workphone: String
    let cellphone, fax, title, company: String
    let notes, name, homestreet, homepob: String
    let homecity, homeprovince, homepostalcode, homecountry: String
    let workstreet, workpob, workcity, workprovince: String
    let workpostalcode, workcountry, url, rowExtension: String
    let speeddialNum: String
    let source: String
    
    init(raw: [String:Any]) {
        self.id = raw["id"] as! Int
        self.ownerID = raw["owner_id"] as? String ?? ""
        self.type = raw["type"] as? String ?? ""
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
        self.source = raw["source"] as? String ?? ""
    }
    
    /**
     Convert a Nethcti contact to a Linphone contact, mapping their fields.
     TODO: Map sip fields.
     */
    @objc public func toLinphoneContact() -> Contact {
        // Init a blank contact. CNContact is the iOS Contact.
        let contact = Contact.init(cnContact: CNContact.init())
        contact!.identifier = String(self.id)
        contact!.nethesis = true
        contact!.firstName = self.name
        contact!.addEmail(self.homeemail)
        contact!.addEmail(self.workemail)
        contact!.fax = self.fax
        contact!.addPhoneNumber(self.homephone)
        contact!.addPhoneNumber(self.workphone)
        contact!.addPhoneNumber(self.cellphone)
        contact!.addSipAddress(self.rowExtension)
        contact!.company = self.company
        contact!.homeLocationAddress = self.homestreet
        contact!.homeLocationCity = self.homecity
        contact!.homeLocationState = self.homeprovince
        contact!.homeLocationCountry = self.homecountry
        contact!.homePob = self.homepob
        contact!.homePostalCode = self.homepostalcode
        contact!.notes = self.notes
        contact!.ownerId = self.ownerID
        contact!.source = self.source
        contact!.speeddialNum = self.speeddialNum
        contact!.title = self.title
        contact!.type = self.type
        contact!.url = self.url
        contact!.workLocationAddress = self.workstreet
        contact!.workLocationCity = self.workcity
        contact!.workLocationState = self.workprovince
        contact!.workLocationCountry = self.workcountry
        contact!.workPob = self.workpob
        contact!.workPostalCode = self.workpostalcode
        contact!.displayName = self.name.isEmpty ? self.company : self.name;
        return contact!
    }
}
