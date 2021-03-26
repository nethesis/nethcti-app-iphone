//
//  ContactSelection.h
//  linphone
//
//  Created by Administrator on 19/02/2021.
//

#ifndef ContactSelection_h
#define ContactSelection_h

typedef enum _ContactSections {
    ContactSections_None = 0, // first section is empty because we cannot set header for first section
    ContactSections_FirstName,
    ContactSections_LastName,
    ContactSections_Company,
    ContactSections_Sip,
    ContactSections_Number,
    ContactSections_WorkLocation,
    ContactSections_Workpob,
    ContactSections_WorkPostalCode,
    ContactSections_HomeLocation,
    ContactSections_Homepob,
    ContactSections_HomePostalCode,
    ContactSections_Email,
    ContactSections_Fax,
    // Nethesis fields.
    ContactSections_Title,
    ContactSections_Notes,
    ContactSections_OwnerId, // Not editable.
    ContactSections_Source, // Not editable.
    ContactSections_SpeeddialNum,
    ContactSections_Type, // Not editable.
    ContactSections_Url,
    ContactSections_MAX
} ContactSections;

#endif /* ContactSelection_h */
