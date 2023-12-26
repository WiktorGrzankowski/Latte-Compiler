Done:
    Frontend dla klas z dziedziczeniem metod i atrybutów napisany.

Do zastanowienia:
    Co z zastępowaniem metod? W tej chwili frontend to dopuszcza, ale można łatwo ograniczyć.

Todo:
    Cały backend obiektów.
    Od czego zacząć?
        - tak jak array jest structem, gdzie na pozycji [+0] jest len, a na [+8] jest wskaźnik na elementy,
        tak samo trzeba robić structy
        - 1. napisać metodę do alokacji na stercie dla struktur - gdzie zliczać rozmiar?
        - 2. state powinien pamiętać, co w strukturze ma jaki offset, np. struct
        ```
        class Dog {
            string name;
            int age;
            string breed;
        }
        ```
        jest zaalokowany i alloc zwraca `rax`. Wtedy pod `[rax]` mamy pointer do `name`.
        Pod `[rax+8]` mamy wartość `age`, a pod `[rax+16]` mamy pointer do `breed`.
        Podczas preprocessingu należy już dodać to do monady, np. strukturę
        Map Var (Map Var Integer) - Map nazwa_klasy (Map nazwa_atrybutu offset).
        W tym przypadku będzie
        ```
        Dog -> 
            name -> 0
            age -> 8
            breed -> 16
        ```
        - 3. ogarnąć dziedziczenie !!!
        Jeśli są klasy
        `
        class Animal {
            string name;
            int age;
        }
        class Dog {
            string breed;
        }
        `
        to `Animal` ma `name -> [+0]`, `age -> [+8]`.
        Idea: `Dog` przejmuje po animal `name -> [+0]`, `age -> [+8]` i dopisuje dalej swoje `breed -> [+16]`.
        Jak to zrobić? Najpierw trzeba przerobić `Animal`, zanim będzie można zabrać się za `Dog`.
        Mozna stworzyć graf zależności, przejść po nim BFSem. Parsowana klasa zawsze będzie miała wszystkich
        sąsiadów zparsowanych. Czyli nadklasa będzie zdefiniowana, a dopisywać offsety dla zmiennych będzie 
        można dalej.
        !!!!!!!!!! Important - to nie pozwala na nadpisywanie atrybutów oraz metod. !!!!!!!!!!!!!!!!!!!!!!!!
        O ile nadpisywanie atrybutów można rozwiązać tak, że sprawdzamy, czy elementu nie ma już w mapie
        (i wtedy go po prostu nadpisać pod starym offsetem), tak z metodami może być ciekawiej.
        ... więc w sumie pozwala to na dość łatwe nadpisywanie atrybutów.
        - 4. jak potem wykonać np `compExpr (EAttr pos e (Ident field))`?
        `e` wyliczy się do jakiegoś adresu... ale nie wiemy jaka to klasa, żeby podejrzeć offset dla `field`.
        Trzeba więc dodać do monady mapowanie `adres -> klasa` przy konstruktorze. 
        To się nieco utrudnia, kiedy mamy kolejne przypisania między instancjami klas oraz forEach może
        chcieć tworzyć nowe kopie obiektów.
        Dużo kminy...

