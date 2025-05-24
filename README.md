# scg-cli-modified

Na razie jedyna modyfikacja to dodanie liczby zwracanych węzłów w poleceniu crucial

1. scg-cli generate <Sciezka> - najpierw generuje się zawsze dla projektu pojedyncze grafy semantyczne, bez tego reszata nie dziala
2. scg-cli export -g CCN -o gdf <Sciezka> - export całego grafu do pliku .gdf 
3. scg-cli summary -g SCG <Sciezka> - szybkie podsumiwanie projektu
4. scg-cli crucial <Sciezka> -n k; k - ile bierzemy węzłów o najwyższych wartościach, raczej chcemy podawać all, żeby każdy embedding miał te wartości, a nie tylko wybrane
5. scg-cli partition n; podaje jak podzielić projekt na n partycji
6. Gephi - plik do otwierania plików .gdf - można użyć ale raczej bezużyteczny - nie na tym nie widać
