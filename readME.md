# Technologia
Kompilator jest napisany w języku Haskell z wykorzystaniem bibliotek zainstalowanych na maszynie students.

# Frontend
Obecnie projekt zawiera jedynie frontend kompilatora języka Latte. Zapewnia on wykrywanie błędów składniowych
oraz błędów statycznych w typach zmiennych oraz funkcji. Pozwali on w przyszłości backendowi założyć,
że kod jest poprawny.

# Sposób uruchomienia
Wykonanie `make` w folderze `.` tworzy plik wykonywalny `latc_x86`.

Wykonanie `./latc_x86 foo/bar/baz.lat` spowoduje analizę syntaktyczną oraz type check podanego programu w języku Latte.

# Sposób działania
Frontend wypisuje `OK`, jeśli statyczna analiza przebiegła pomyślnie, lub `ERROR` wraz ze stosowanym
opisem błędu, w przeciwnym przyadku.

# Null
Działa bez rzutowania, można go porównać z każdą klasą.

# Konflikty w gramatyce
Jedynie shift/reduce, wynikające z niejednoznaczności `if else` oraz podobieństwa 
inicjalizacji tablicy `new Expr [Expr]` do odwołania do elementu tablicy `Expr [Expr]`.

# Struktura katalogów
readME: opis działania
Makefile
    -> src : Main.hs - główna funkcja programu, czyta plik i wywołuje lexer oraz typechecker
             Core.hs - funkcje współdzielone przez pozostałe moduły frontendu
             TypeChecker.hs - wykonuje analizę instrukcji i głównych definicji kodu, woła odpowienie metody z ExpChecker i ItemsChecker
             ExpChecker.hs - wykonuje analizę wyrażeń
             ItemsChecker.hs - wykonuje analizę deklaracji
            -> Latte : pliki wygenerowane przez bnfc na podstawie gramatyki Instant.cf
