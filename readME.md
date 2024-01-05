# Technologia
Kompilator jest napisany w języku Haskell z wykorzystaniem bibliotek zainstalowanych na maszynie students.

# Frontend
Obecnie projekt zawiera jedynie frontend kompilatora języka Latte. Zapewnia on wykrywanie błędów składniowych
oraz błędów statycznych w typach zmiennych oraz funkcji. Pozwali on w przyszłości backendowi założyć,
że kod jest poprawny.

# Sposób uruchomienia
Wykonanie `make` w folderze `.` tworzy plik wykonywalny `latc_x86_64` oraz `latc`.

Wykonanie `./latc_x86 foo/bar/baz.lat` spowoduje analizę syntaktyczną oraz type check podanego programu w języku Latte.
W przypadku udanej statycznej analizy kodu, program przetłumaczy program w języku `Latte` na język assemblera `x86_64`
tworząc z pliku `foo/bar/baz.lat` plik `foo/bar/baz.s` oraz od razu go skompiluje tworząc plik wykonywalny `foo/bar/baz`

# Sposób działania
Wypisuje `OK` oraz tworzy plik wykonywalny, jeśli statyczna analiza przebiegła pomyślnie, lub `ERROR` wraz ze stosowanym
opisem błędu w przeciwnym przypadku.

# If/While bez klamerek
Wyrażenie 
`
if (cond)
    stmt;
`
traktowany jest jako lukier syntaktyczny dla wyrażenia
`
if (cond) {
    stmt;
}
`
stąd dopuszczalne jest wyrażenie
`
if (cond) 
    int x;
`

# Null
Działa bez rzutowania, można go porównać z każdą klasą.

# Konflikty w gramatyce
Jedynie shift/reduce, wynikające z niejednoznaczności `if else` oraz podobieństwa 
inicjalizacji tablicy `new Expr [Expr]` do odwołania do elementu tablicy `Expr [Expr]`.


# Struktura katalogów
readME: opis działania
Makefile
    -> src :
            Main.hs - główna funkcja programu, czyta plik i wywołuje lexer oraz typechecker
            Frontend -> 
                        Core.hs - funkcje współdzielone przez pozostałe moduły frontendu
                        TypeChecker.hs - wykonuje analizę instrukcji i głównych definicji kodu, woła odpowienie metody z ExpChecker i ItemsChecker
                        ExpChecker.hs - wykonuje analizę wyrażeń
                        ItemsChecker.hs - wykonuje analizę deklaracji
            Backend ->
                    Core.hs - funkcje współdzielone i pomocnicze
                    Compiler.hs - wykonuje parsowanie instrukcji i głównych definicji kodu do kodu assemblera
                    ExpCompiler.hs - wykonuje parsowanie wyrażeń
                    ItemCompiler.hs - wykonuje parsowanie deklaracji
            -> Latte : pliki wygenerowane przez bnfc na podstawie gramatyki Instant.cf
    -> lib :
           runtime.c - funkcje pomocnicze w języku C, wykorzystywane przez programy w języku Latte
    -> Latte.cf - plik z gramatyką języka Latte
    -> Makefile - skrypt uruchamiany poleceniem `make` tworzący pliki wykonywalne `latc` oraz `latc_x86_64`. 
