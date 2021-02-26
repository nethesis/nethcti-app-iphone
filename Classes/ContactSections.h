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
    ContactSections_Sip,
    ContactSections_Number,
    ContactSections_Email,
    // Nethesis fields.
    ContactSections_Company,
    ContactSections_HomeLocation,
    ContactSections_Notes,
    ContactSections_OwnerId,
    ContactSections_Title,
    ContactSections_MAX
} ContactSections;

#endif /* ContactSelection_h */
