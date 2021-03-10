//
//  Constants.swift
//  Kanarek
//
//  Created by Chris Yarosh on 01/12/2020.
//

import Foundation

struct K {
    
    struct UserDefaults {
        static let cityName = "cityName"
        static let pushNotificationSubscription = "topicSubscription"
        static let email = "UserEmail"
        static let password = "UserPassword"
    }
    
    struct PushNotifications{
        static let poznanTopic = "push_notifications_poznan"
        static let warsawTopic = "push_notifications_warsaw"
    }
    
    struct Segues {
        static let toReportOne = "GoToReportOne"
        static let toReportTwo = "GoToReportTwo"
        static let toReportThree = "GoToReportThree"
        static let singInToMain = "SignInToMain"
        static let signUpToMain = "SignUpToMain"
        static let toTerms = "GoToTermsFromSettings"
        static let subscription = "GoToSubscription"
    }
    
    struct CustomCell {
        static let textNibName = "TextCell"
        static let textIdentifier = "TextCell"
        static let numberNibName = "NumberCell"
        static let numberIdentifier = "NumberCell"
    }
    
    struct FirebaseQuery {
        static let date: String = "date_modified"
        static let lat: String = "latitude"
        static let lon: String = "longitude"
        static let status: String = "status"
        static let type: String = "type"
        static let nightWork: String = "night_work"
        static let stopName: String = "stop_name"
        static let reportDetails: String = "report_details"
        static let lines: String = "lines"
        static let linesCollectionName = "_lines"
        static let stopsCollectionName = "_stops"
        static let lineNumber = "line_number"
        static let directions = "directions"
        static let historyCollectionName = "_history"
    }
    
    struct Regulamin {
        static let text = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris aliquam turpis id eros tincidunt laoreet. Pellentesque sit amet velit felis. Sed id leo sed ipsum mattis consectetur id eget sem. Vivamus consequat accumsan nisi non tempus. Pellentesque rutrum dolor ut aliquam hendrerit. Mauris cursus augue eu elit molestie suscipit. Sed sit amet vehicula orci, at ultricies eros. Mauris id vulputate velit. Ut vel pharetra enim. In blandit in dui sed facilisis. Integer maximus placerat est sed malesuada. Maecenas vitae ornare nisi, at volutpat lacus. Aliquam ultricies malesuada mi.
    
    Praesent rhoncus blandit leo porta rutrum. Sed cursus lacinia dui, a fringilla ex condimentum vel. Maecenas fermentum purus ligula, a fringilla felis vestibulum non. Maecenas quis nisl sed lorem venenatis commodo sit amet ac risus. Vivamus eu dictum est. Mauris nec dui egestas, commodo enim in, semper lacus. Maecenas vehicula diam et molestie lobortis. Donec fringilla vitae ipsum nec commodo. Suspendisse gravida congue laoreet. Morbi vitae ultrices metus. Proin elementum libero sed tortor feugiat imperdiet.

    Suspendisse sit amet rutrum diam. Donec dapibus nibh id felis vulputate, vel vestibulum leo posuere. Donec faucibus nunc massa, quis rhoncus ante ultrices nec. Nulla non purus in turpis venenatis rhoncus. Phasellus tristique ultricies neque. Interdum et malesuada fames ac ante ipsum primis in faucibus. Suspendisse quis rutrum ipsum. Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer eget convallis sem. Suspendisse quis eros eget est tincidunt dapibus in eu urna. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aliquam bibendum vitae lorem ac porta. Morbi cursus ligula blandit suscipit ornare.

    Ut sed sollicitudin metus, in feugiat magna. Ut malesuada lacinia ultricies. Pellentesque pulvinar elit nunc, vel ultrices nisi eleifend eu. Integer sed enim ac elit vulputate maximus. Fusce lacus ex, ultricies a efficitur id, lobortis quis erat. Mauris venenatis mollis nunc ut interdum. Mauris tincidunt suscipit velit eget suscipit. Nam ac porttitor ipsum, a finibus dui. Cras malesuada varius venenatis. Nullam lacus turpis, congue a aliquet et, scelerisque sed magna.

    Etiam sit amet pretium felis, vel dictum augue. Sed maximus pharetra nibh pharetra dictum. Proin felis dui, efficitur ut tempor sed, iaculis ut elit. Duis maximus finibus velit fermentum lacinia. Praesent mattis lorem eget mattis bibendum. Nulla tincidunt varius fringilla. Etiam at purus feugiat, rutrum libero sit amet, consectetur eros. Quisque nisl lacus, aliquam a ex et, aliquet mattis sapien. Sed eu pretium risus. Nulla et ipsum pretium, sagittis ipsum vel, tristique est. Sed at nunc egestas erat auctor bibendum. Proin imperdiet elit magna, ac suscipit tortor aliquam varius. Nulla laoreet dictum urna ac semper. Nam eu volutpat nunc.

    Pellentesque et auctor elit. Vestibulum sodales eget eros vitae interdum. Curabitur quis velit non lorem aliquet faucibus. Nullam non justo tellus. Curabitur iaculis enim sit amet justo cursus, efficitur pellentesque elit ultrices. Sed consequat ultricies justo, eu porta magna. Vivamus condimentum interdum mi ac ultricies. Nunc mattis dignissim neque id convallis. Nullam viverra gravida quam, in imperdiet nibh vulputate nec. Nunc arcu purus, posuere eu mauris vel, lobortis vulputate urna. Nullam aliquam volutpat massa vitae commodo. Sed ornare sed nisi a congue. Etiam auctor suscipit felis, vel pharetra arcu facilisis eget. In pulvinar massa nibh, at faucibus mauris fringilla sit amet. Pellentesque iaculis ex et odio faucibus, vel maximus justo mollis.

    Nulla aliquet, justo vitae porta mattis, libero tortor vehicula quam, a rutrum mi velit sed tellus. Mauris et justo vestibulum, laoreet libero sit amet, maximus ligula. Cras ante sapien, posuere in lobortis non, tincidunt eu nunc. Mauris a convallis tellus. Vestibulum dapibus orci vel lectus tincidunt convallis. Pellentesque vel ultricies nisl. Praesent vulputate, lectus sit amet tincidunt eleifend, eros elit sagittis purus, sit amet vehicula lacus tortor non urna. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam blandit rhoncus diam ut mattis. Curabitur id nisl tortor. Duis vel sem sit amet eros tempor ullamcorper. Curabitur non aliquet odio. Duis mattis ultrices nulla sit amet mattis. Ut scelerisque arcu quis elit vulputate, quis semper risus porttitor. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aliquam luctus, nulla at vestibulum dignissim, orci massa hendrerit ex, sit amet pretium dolor nunc consectetur quam.

    Fusce pulvinar mollis nisl, a posuere velit sodales sit amet. Nulla id accumsan nibh. Proin semper purus eget ipsum interdum, a vehicula urna porta. Aenean laoreet felis vitae tincidunt congue. Cras convallis fermentum est et mollis. Duis vitae nunc purus. Curabitur vehicula viverra nunc, ac viverra diam condimentum sit amet. Etiam in bibendum mauris. Mauris feugiat sed urna in tincidunt. Maecenas eu dui et est ultricies laoreet non sed nisl. Ut bibendum vulputate turpis, in sagittis enim congue sagittis.

    Cras vulputate odio vitae vulputate ultrices. Aliquam tempus iaculis ligula eu sollicitudin. Aenean rhoncus elit eget accumsan laoreet. Vivamus neque libero, molestie vitae nibh vel, aliquet viverra lacus. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aliquam mollis sodales aliquam. Sed consectetur dui a magna auctor convallis.

    Proin tellus mi, tristique in lacus vestibulum, aliquet tempor leo. Nunc euismod, purus nec molestie pretium, nisl ante pharetra nibh, vel varius lectus elit nec nisl. Donec iaculis dolor vel venenatis fermentum. Cras dignissim risus vel justo bibendum, ac semper ex accumsan. Proin et dignissim felis, eu faucibus neque. Quisque commodo erat a lorem ornare faucibus. Vivamus non convallis sapien. Fusce suscipit leo eu feugiat tempor. Ut tristique libero tortor, gravida rutrum nisl tristique ut. Integer lobortis volutpat tortor, vitae scelerisque tortor elementum pharetra. Sed sit amet malesuada justo. Vestibulum tempus, nisi luctus aliquam feugiat, ligula tellus sollicitudin turpis, et varius lectus metus eget est. Sed non lobortis felis.

    Praesent felis nibh, varius in sem vel, fringilla viverra justo. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Pellentesque velit mi, suscipit placerat pharetra vitae, dapibus ac metus. Vestibulum ut mi eros. Suspendisse elementum magna in pulvinar congue. Curabitur sagittis mi vitae fermentum lacinia. Praesent nec finibus justo, id semper justo. Sed aliquam eros sed erat scelerisque luctus. Maecenas cursus vestibulum orci id dictum. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aliquam egestas risus in semper pharetra. Nunc quis nunc eu lectus ultrices varius sit amet vitae ipsum.
    """
    }
        
}
