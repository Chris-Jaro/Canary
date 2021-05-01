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

    POSTANOWIENIA WSTĘPNE
    Canary to serwis umożliwiający użytkownikom dzielenie się informacją odnośnie punktu kontroli biletowych w komunikacji miejskiej, dostępny przez aplikacje mobilną. Właścicielem Canary jest Krzysztof Jarosz.

    Canary działa na zasadach określonych w niniejszym Regulaminie. Niniejszy Regulamin określa ogólne zasady stanowiące prawne podstawy korzystania z aplikacji Canary. Każdy Użytkownik zobowiązany jest, z momentem podjęcia czynności zmierzających do korzystania z Canary, do przestrzegania postanowień niniejszego Regulaminu.
    Przed rozpoczęciem korzystania z Canary należy uważnie przeczytać poniższy Regulamin.

    DEFINICJE
        Canary – serwis umożliwiający użytkownikom dzielenie się informacją odnośnie kontroli biletowych w komunikacji miejskiej, dostępny przez aplikacje mobilne (obecnie tylko iOS);
        Usługodawca – Krzysztof Jarosz
        Użytkownik – każda osoba, która ukończyła 18 lat, korzystająca w jakikolwiek sposób z Canary;
        Punkt Kontroli – punkt na mapie o kolorze czerwonym z otaczającym go 200m czerwonym okręgiem, gdzie została zgłoszona kontrola, punkt kontroli zamienia się w punkt neutralny po 3 minutach od zgłoszenia.
        Punkt Neutralny — punkt na mapie o kolorze niebieskim, pokazuję lokalizacje przystanku oraz dostępne numery lini.
        Regulamin – niniejszy Regulamin.

    ZASADY FUNKCJONOWANIA I KORZYSTANIA Z SERWISU
    Canary jest narzędziem, umożliwiającym użytkownikom dzielenie się informacją odnośnie punktów kontroli biletowych. Informacja o punkcie kontroli prezentowana jest w formie:
    Informacji tekstowej (powiadomienia) zawierającej nazwę przystanku,  numer lini oraz jej kierunek
    Graficznej, pokazanej na mapie w postaci punktów kontroli i neutralnych
    Twoje prawa. Podanie danych użytkownika nie jest wymagane. Proces logowania oraz rejestracji wymaga jedynie podania “adresu e-mail” adres email, musi spełniać wzór - x@y.com , e-mial jest zapisany jako login i nie jest nigdzie wykorzystywany poza logowaniem do aplikacji, obecnie nie ma także żadnej opcji zmiany loginu lub hasła użytkownika.
    Jakie dane są przetwarzane i w jakim celu . Dane o lokalizacji użytkownika są przetwarzane tylko w aplikacji , ponieważ są one potrzebne w procesie zgłaszania punktów kontroli. Email jest używany jako login i nie jest on w żaden sposób sprawdzany ani wykorzystywany do celów marketingowych.
    Odbiorcy danych . Wszystkie dane przechowywane są na serwerach Google w naszej bazie danych, tak długo jak długo opłacany jest abonament.
    Korzystanie z Canary jest całkowicie darmowe przez pierwszy miesiąc (każdy kolejny miesiąc kosztuje 1.99PLN), przy czym użytkownik ma prawo do wykorzystania danych przedstawionych w aplikacji w celach informacyjnych i na własny użytek, tj. w szczególności nie może ich wykorzystywać w celu prowadzenia działalności zarobkowej. Usługodawca zastrzega, iż wszystkie informacje zawarte w Canary objęte są prawem autorskim i podlegają ochronie na zasadach określonych w ustawie o prawie autorskim i prawach pokrewnych. Pobieranie, wykorzystywanie, dalsze rozpowszechnianie, przedrukowywanie, udostępnianie w jakiejkolwiek formie (w tym formie elektronicznej), przetwarzanie w całości lub w części, za wyjątkiem zapoznawania się z informacjami przez pasażerów komunikacji miejskiej do ich użytku osobistego i innymi wypadkami dopuszczonymi w przepisach, wymaga zgody Usługodawcy.
    Korzystanie z Canary może zostać rozpoczęte i zakończone w dowolnym momencie, Usługodawca gwarantuje dostępność tej opcji zgodnie z warunkami określonymi w momencie zakupu.
    Użytkownik zobowiązany jest do korzystania z Canary w sposób nie naruszający niniejszego regulaminu, obowiązujących przepisуw ani praw osób trzecich. W szczególności zabronione jest dostarczanie do Canary treści o charakterze bezprawnym.
    Użytkownik korzystający z aplikacji Canary,  podczas korzystania z transportu publicznego, jest zobowiązany posiadać ważny bilet komunikacji miejskiej.

    ODPOWIEDZIALNOŚĆ
    Usługodawca zobowiązuje się do stałego i nieprzerwanego świadczenia usługi, z zastrzeżeniami wskazanymi w ustępach poniższych.
    Usługodawca informuje, iż:
    Nie gwarantuje pełnej poprawności i aktualności danych zawartych w bazach danych i na mapach wykorzystywanych w Canary oraz przydatności do konkretnych celów;
    dokłada wszelkich starań dla zapewnienia nieprzerwanego funkcjonowania Canary, niemniej nie gwarantuje jego niezakłóconej dostępności i działania.
    Usługodawca zastrzega sobie prawo dokonywania czynności konserwacyjnych, naprawczych oraz związanych z modyfikacją i rozwojem funkcjonalności Canary. W miarę możliwości Usługodawca wykonywać będzie te prace w godzinach nocnych tj. pomiędzy godz. 24:00 a 6:00 rano. Usługodawca dokłada wszelkich starań w celu powiadamiania Użytkownikуw o planowanych czynnościach konserwacyjnych, naprawczych oraz związanych z modyfikacją i rozwojem funkcjonalności.
    Usługodawca dołoży wszelkich starań, by aktualizować na bieżąco wszystkie zmiany w kursowaniu i rozkładach środków komunikacji miejskiej.
    Autorskie prawa majątkowe do elementуw graficznych Canary, w tym do logo, a także do układu i kompozycji tych elementów, przysługują Usługodawcy. Zabronione jest wykorzystywanie przez Użytkowników elementów graficznych oraz ich układu i kompozycji a także oznaczeń będących przedmiotem praw przysługujących Usługodawcy, za wyjątkiem banerów promujących Canary oraz sytuacji wyraźnie wskazanych w Regulaminie lub za zgodą Usługodawcy.
    Użytkownik przyjmuje do wiadomości, iż wszelkie działania skutkujące lub mające na celu naruszenie warunków korzystania z Canary określonych w niniejszym Regulaminie, stanowią naruszenie prawa oraz postanowień niniejszego Regulaminu.
    Każdemu Użytkownikowi przysługuje prawo do złożenia reklamacji w sprawach związanych z funkcjonowaniem Canary.
    Reklamacje należy składać drogą elektroniczną na adres kanarekapp@gmail.com.
    Usługodawca rozpatrzy reklamację w terminie 14 dni od dnia jej otrzymania.
    Odpowiedź na reklamację zostanie przesłana do Użytkownika na adres podany przez Użytkownika w reklamacji.
    Usługodawca zastrzega sobie prawo do wydłużenia terminu podanego w pkt 9 maksymalnie do 21 dni w przypadku, gdy rozpoznanie reklamacji wymaga wiadomości specjalnych lub napotyka przeszkody z przyczyn niezależnych od Usługodawcy (awarie sprzętu, sieci internetowej itp.). O wydłużeniu takim Użytkownik zostanie poinformowany, z podaniem przyczyny wydłużenia oraz podaniem nowego terminu rozpatrzenia reklamacji.

    POSTANOWIENIA KOŃCOWE
    Usługodawca informuje, iż specyfika funkcjonowania sieci internet powoduje, że występuje w niej szereg mogących powodować szkody zagrożeń, takich jak a w szczególności włamania do systemu Użytkownika, przejęcia haseł przez osoby trzecie, zainfekowanie systemu Użytkownika wirusami.
    Wszelkie uwagi, komentarze i pytania związane z Canary prosimy kierować na adres: kanarekapp@gmail.com
    Wszelkie informacje o naruszeniach przez Użytkowników postanowień niniejszego Regulaminu proszę kierować na adres: kanarekapp@gmail.com
    Regulamin podlega prawu polskiemu.
    Jeżeli którekolwiek postanowienie Regulaminu zostanie uznane na mocy prawomocnego orzeczenia sądu za nieważne, pozostałe postanowienia Regulaminu pozostają w mocy.
    W sprawach nieuregulowanych w Regulaminie zastosowanie znajdują przepisy polskiego prawa.

    ZMIANY REGULAMINU
    Usługodawca zastrzega sobie prawo zmiany niniejszego Regulaminu, w zakresie w jakim jest to dopuszczalne przez obowiązujące przepisy, w przypadku zaistnienia istotnych przyczyn związanych z technicznym bądź merytorycznym aspektem funkcjonowania Canary, w tym w szczególności w przypadku stosownych zmian w obowiązujących przepisach prawa. Zmiany Regulaminu będą udostępniane w Canary oraz komunikowane uprzednio Użytkownikom w odpowiedni, umożliwiający analizę wspomnianych zmian, sposób. W przypadku niezaakceptowania zmian w Regulaminie, Użytkownik powinien powstrzymać się od korzystania z Canary.
    """
    }
        
}
