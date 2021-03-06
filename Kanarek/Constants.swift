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
        static let appStoreSubscription = "appStoreSubscription"
        static let reportCount = "reportCompletedCount"
        static let lastReviewVersion = "lastVersionPromptedForReview"
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
        static let lineMessageNibName = "LineMessageCell"
        static let lineMessageIdentifier = "LineMessageCell"
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
    REGULAMIN APLIKACJI CANARY

    ??? POSTANOWIENIA WST??PNE
    Canary to serwis umo??liwiaj??cy u??ytkownikom dzielenie si?? informacj?? odno??nie punktu kontroli biletowych w komunikacji miejskiej, dost??pny przez aplikacje mobiln??. W??a??cicielem Canary jest Krzysztof Jarosz.

    Canary dzia??a na zasadach okre??lonych w niniejszym Regulaminie. Niniejszy Regulamin okre??la og??lne zasady stanowi??ce prawne podstawy korzystania z aplikacji Canary. Ka??dy U??ytkownik zobowi??zany jest, z momentem podj??cia czynno??ci zmierzaj??cych do korzystania z Canary, do przestrzegania postanowie?? niniejszego Regulaminu.
    Przed rozpocz??ciem korzystania z Canary nale??y uwa??nie przeczyta?? poni??szy Regulamin.

    ??? DEFINICJE
    Canary????? serwis umo??liwiaj??cy u??ytkownikom dzielenie si?? informacj?? odno??nie kontroli biletowych w komunikacji miejskiej, dost??pny przez aplikacje mobilne (obecnie tylko iOS);
    Us??ugodawca????? Krzysztof Jarosz
    U??ytkownik????? ka??da osoba, kt??ra uko??czy??a 18 lat, korzystaj??ca w jakikolwiek spos??b z Canary;
    Punkt Kontroli????? punkt na mapie o kolorze czerwonym z otaczaj??cym go 200m czerwonym okr??giem, gdzie zosta??a zg??oszona kontrola, punkt kontroli zamienia si?? w punkt neutralny po 3 minutach od zg??oszenia.
    Punkt Neutralny ??? punkt na mapie o kolorze niebieskim, pokazuj?? lokalizacje przystanku oraz dost??pne numery lini.
    Regulamin????? niniejszy Regulamin.

    ??? ZASADY FUNKCJONOWANIA I KORZYSTANIA Z SERWISU
    Canary jest narz??dziem, umo??liwiaj??cym u??ytkownikom dzielenie si?? informacj?? odno??nie punkt??w kontroli biletowych. Informacja o punkcie kontroli prezentowana jest w formie:
    Informacji tekstowej (powiadomienia) zawieraj??cej nazw?? przystanku,  numer lini oraz jej kierunek
    Graficznej, pokazanej na mapie w postaci punkt??w kontroli i neutralnych
    Twoje prawa. Podanie danych u??ytkownika nie jest wymagane. Proces logowania oraz rejestracji wymaga jedynie podania ???adresu e-mail??? adres email, musi spe??nia?? wz??r - x@y.com , e-mial jest zapisany jako login i nie jest nigdzie wykorzystywany poza logowaniem do aplikacji, obecnie nie ma tak??e ??adnej opcji zmiany loginu lub has??a u??ytkownika.
    Jakie dane s?? przetwarzane i w jakim celu??. Dane o lokalizacji u??ytkownika s?? przetwarzane tylko w aplikacji , poniewa?? s?? one potrzebne w procesie zg??aszania punkt??w kontroli. Email jest u??ywany jako login i nie jest on w ??aden spos??b sprawdzany ani wykorzystywany do cel??w marketingowych.
    Odbiorcy danych??. Wszystkie dane przechowywane s?? na serwerach Google w naszej bazie danych, tak d??ugo jak d??ugo op??acany jest abonament.
    Korzystanie z Canary jest ca??kowicie darmowe przez pierwsze trzy miesi??ce (ka??dy kolejny miesi??c kosztuje 1.99PLN), przy czym u??ytkownik ma prawo do wykorzystania danych przedstawionych w aplikacji w celach informacyjnych i na w??asny u??ytek, tj. w szczeg??lno??ci nie mo??e ich wykorzystywa?? w celu prowadzenia dzia??alno??ci zarobkowej. Us??ugodawca zastrzega, i?? wszystkie informacje zawarte w Canary obj??te s?? prawem autorskim i podlegaj?? ochronie na zasadach okre??lonych w ustawie o prawie autorskim i prawach pokrewnych. Pobieranie, wykorzystywanie, dalsze rozpowszechnianie, przedrukowywanie, udost??pnianie w jakiejkolwiek formie (w tym formie elektronicznej), przetwarzanie w ca??o??ci lub w cz????ci, za wyj??tkiem zapoznawania si?? z informacjami przez pasa??er??w komunikacji miejskiej do ich u??ytku osobistego i innymi wypadkami dopuszczonymi w przepisach, wymaga zgody Us??ugodawcy.
    Korzystanie z Canary mo??e zosta?? rozpocz??te i zako??czone w dowolnym momencie, Us??ugodawca gwarantuje dost??pno???? tej opcji zgodnie z warunkami okre??lonymi w momencie zakupu.
    U??ytkownik zobowi??zany jest do korzystania z Canary w spos??b nie naruszaj??cy niniejszego regulaminu, obowi??zuj??cych przepis??w ani praw os??b trzecich. W szczeg??lno??ci zabronione jest dostarczanie do Canary tre??ci o charakterze bezprawnym.
    U??ytkownik korzystaj??cy z aplikacji Canary,  podczas korzystania z transportu publicznego, jest zobowi??zany posiada?? wa??ny bilet komunikacji miejskiej.

    ??? ODPOWIEDZIALNO????
    Us??ugodawca zobowi??zuje si?? do sta??ego i nieprzerwanego ??wiadczenia us??ugi, z zastrze??eniami wskazanymi w ust??pach poni??szych.
    Us??ugodawca informuje, i??:
    Nie gwarantuje pe??nej poprawno??ci i aktualno??ci danych zawartych w bazach danych i na mapach wykorzystywanych w Canary oraz przydatno??ci do konkretnych cel??w;
    dok??ada wszelkich stara?? dla zapewnienia nieprzerwanego funkcjonowania Canary, niemniej nie gwarantuje jego niezak????conej dost??pno??ci i dzia??ania.
    Us??ugodawca zastrzega sobie prawo dokonywania czynno??ci konserwacyjnych, naprawczych oraz zwi??zanych z modyfikacj?? i rozwojem funkcjonalno??ci Canary. W miar?? mo??liwo??ci Us??ugodawca wykonywa?? b??dzie te prace w godzinach nocnych tj. pomi??dzy godz. 24:00 a 6:00 rano. Us??ugodawca dok??ada wszelkich stara?? w celu powiadamiania U??ytkownik??w o planowanych czynno??ciach konserwacyjnych, naprawczych oraz zwi??zanych z modyfikacj?? i rozwojem funkcjonalno??ci.
    Us??ugodawca do??o??y wszelkich stara??, by aktualizowa?? na bie????co wszystkie zmiany w kursowaniu i rozk??adach ??rodk??w komunikacji miejskiej.
    Us??ugodawca nie jest??odpowiedzialny za informacje przekazywane przez u??ytkownik??w.
    Autorskie prawa maj??tkowe do element??w graficznych Canary, w tym do logo, a tak??e do uk??adu i kompozycji tych element??w, przys??uguj?? Us??ugodawcy. Zabronione jest wykorzystywanie przez U??ytkownik??w element??w graficznych oraz ich uk??adu i kompozycji a tak??e oznacze?? b??d??cych przedmiotem praw przys??uguj??cych Us??ugodawcy, za wyj??tkiem baner??w promuj??cych Canary oraz sytuacji wyra??nie wskazanych w Regulaminie lub za zgod?? Us??ugodawcy.
    U??ytkownik przyjmuje do wiadomo??ci, i?? wszelkie dzia??ania skutkuj??ce lub maj??ce na celu naruszenie warunk??w korzystania z Canary okre??lonych w niniejszym Regulaminie, stanowi?? naruszenie prawa oraz postanowie?? niniejszego Regulaminu.
    Ka??demu U??ytkownikowi przys??uguje prawo do z??o??enia reklamacji w sprawach zwi??zanych z funkcjonowaniem Canary.
    Reklamacje nale??y sk??ada?? drog?? elektroniczn?? na adres kanarekapp@gmail.com.
    Us??ugodawca rozpatrzy reklamacj?? w terminie 14 dni od dnia jej otrzymania.
    Odpowied?? na reklamacj?? zostanie przes??ana do U??ytkownika na adres podany przez U??ytkownika w reklamacji.
    Us??ugodawca zastrzega sobie prawo do wyd??u??enia terminu podanego w pkt 9 maksymalnie do 21 dni w przypadku, gdy rozpoznanie reklamacji wymaga wiadomo??ci specjalnych lub napotyka przeszkody z przyczyn niezale??nych od Us??ugodawcy (awarie sprz??tu, sieci internetowej itp.). O wyd??u??eniu takim U??ytkownik zostanie poinformowany, z podaniem przyczyny wyd??u??enia oraz podaniem nowego terminu rozpatrzenia reklamacji.

    ??? POSTANOWIENIA KO??COWE
    Us??ugodawca informuje, i?? specyfika funkcjonowania sieci internet powoduje, ??e wyst??puje w niej szereg mog??cych powodowa?? szkody zagro??e??, takich jak a w szczeg??lno??ci w??amania do systemu U??ytkownika, przej??cia hase?? przez osoby trzecie, zainfekowanie systemu U??ytkownika wirusami.
    Wszelkie uwagi, komentarze i pytania zwi??zane z Canary prosimy kierowa?? na adres: kanarekapp@gmail.com
    Wszelkie informacje o naruszeniach przez U??ytkownik??w postanowie?? niniejszego Regulaminu prosz?? kierowa?? na adres: kanarekapp@gmail.com
    Regulamin podlega prawu polskiemu.
    Je??eli kt??rekolwiek postanowienie Regulaminu zostanie uznane na mocy prawomocnego orzeczenia s??du za niewa??ne, pozosta??e postanowienia Regulaminu pozostaj?? w mocy.
    W sprawach nieuregulowanych w Regulaminie zastosowanie znajduj?? przepisy polskiego prawa.

    ??? ZMIANY REGULAMINU
    Us??ugodawca zastrzega sobie prawo zmiany niniejszego Regulaminu, w zakresie w jakim jest to dopuszczalne przez obowi??zuj??ce przepisy, w przypadku zaistnienia istotnych przyczyn zwi??zanych z technicznym b??d?? merytorycznym aspektem funkcjonowania Canary, w tym w szczeg??lno??ci w przypadku stosownych zmian w obowi??zuj??cych przepisach prawa. Zmiany Regulaminu b??d?? udost??pniane w Canary oraz komunikowane uprzednio U??ytkownikom w odpowiedni, umo??liwiaj??cy analiz?? wspomnianych zmian, spos??b. W przypadku niezaakceptowania zmian w Regulaminie, U??ytkownik powinien powstrzyma?? si?? od korzystania z Canary.
    """
    }
        
}
