---
layout: post
title: Rozproszone wejście/wyjście i mikrokontrolery w sterowaniu
author: Robert Paciorek
tags:
- bms
- elektronika
---

W publicznych repozytoriach git ([bitbucket](https://bitbucket.org/OpCode-eu-org/IOModules_modbus_stm32/), [github](https://github.com/opcode-eu-org-libs/IOModules_modbus_stm32)) opublikowałem projekt koncepcyjny rozproszonych modułów I/O, z komunikacją RS485/modbus opartych na mikrokontrolerze STM32. Wpis ten ma na celu przedstawienie historii tego projektu oraz motywów i tła jego powstania i rozwoju.

Aktualnie projekt ten nie jest produkcyjny. Bardziej stanowi zbiór koncepcji, idei oraz przykładowych rozwiązań układowych i opublikowany został głównie w celach edukacyjnych. Może być użyteczny przy tworzeniu takich rozwiązań, jednak przed zastosowaniem produkcyjnym wymagane są dodatkowe testy.


Krótka historia projektu
------------------------

Projekt został zapoczątkowany w 2016 roku w postaci projektu płytki typu "hat" dla Raspberry Pi, opartej o ATmega32A, dostarczającej wejścia analogowe do realizacji linii 3EOL. Dość szybko w trosce o „nie marnowanie” pozostałych wyprowadzeń mikrokontrolera na płytce pojawiły się wejścia/wyjścia innych typów. Doszło też do zmiany procesora na rodzinę STM32F103. Główne problemy cały czas skupiały się wokół kwestii konstrukcji „mechanicznej” rozwiązania:

* monolityczność kontra modularność
	* monolityczność wymaga sztywnego określenia ilość wejść/wyjść poszczególnych typów
	* modularność wprowadza dodatkową komplikację w konstrukcji mechanicznej i zwiększa rozmiary (m.in. z powodu że jeżeli ma być uniwersalnie to w każdy lub prawie każdy slot powinny mieścić się najwieksze moduły)
* wielkość ekspandera
	* duży moduł ekspandera oparty na mikrokontrolerze z dużą ilością GPIO (STM32F103VC), jeden na płytkę typu Orange / Banana / Raspberry Pi
	* „sieć” mniejszych modułów podłączonych do jednego mastera *Pi
* obudowa – montaż na szynę DIN, upchnięcie do typowej obudowy montowanej na DIN, obudowa dedykowana, ...

O ile kwestia „wielkości ekspandera” została rozwiązana dość szybko – wybór padł na sieć mniejszych modułów (STM32F103CxT, później STM32G030KxT) komunikujących się poprzez UART i Modbus RTU, to dwa pozostałe problemy są obecne do dnia dzisiejszego.

O starszych moich podejściach do tego typu systemów i ich ewolucji przeczytać można we [fragmencie](/files/Ewolucja_koncepcji_projektów_inteligentnego_domu.pdf) artykułu, który kiedyś znajdował się w serwisie *opcode*.

Współczesność projektu
----------------------

Zagadnienia modularności i obudowy doprowadziły do kompromisu widocznego w aktualnej wersji projektu:

* płytki bazowe zaprojektowane są z myślą o standardowej obudowie na szynę DIN o szerokości 8 modułów
* płytki bazowe nie są modularne – zawierają wklejone różne konfiguracje zestawów układów wejść / wyjść
* projektowanie schematów i PCB jest modularne – poszczególne układy wejść/wyjść stanowią osobne schematy i fragmenty PCB włączane do projektu płytki bazowej
* jedynym osobnym modułem jest płytka mikrokontrolera montowana „na kanapkę” do płytki bazowej

Efektem takiego podejścia jest pojawienie się kolejnego zagadnienia czyli ilości typów płytek bazowych (uniwersalności vs dedykowalności do poszczególnych zastosowań) i związanej z tym ilości kombinacji.

Projekt zawiera także liczne elementy konfiguracji poprzez ustawianie zworek, czy lutowanie. Widoczne jest to zwłaszcza w modułach wejść, których konfiguracja do żądanego typu wejścia realizowana może być poprzez:

1. przylutowanie odpowiednich elementów
2. nastawy potencjometrów (mocno ograniczony zakres konfiguracji)
3. zastosowanie podstawek precyzyjnych SIL / 1pin w które wtykane są odpowiednie elementy (rezystory, optoizolatory, etc) lub nawet płytki konfiguracyjne
	* wymagałoby stosowanie cieńszych pinów na płytkach
	* chyba że moduł dedykowany takiej płytce:
		1. płytka tylko z rezystorami przed transoptorem
			* zaczepienie do J1 (signal_INPUT), J2 (signal_GND)
			* R4 220 lub 0
		2. płytka zastępująca rezystory wejściowe, transoptor
			* zaczepienie do J1 (signal_INPUT), J2 (signal_GND), U1.3-U1.4 (to_ADC, GND)
		3. płytka zastępująca rezystory wejściowe, transoptor i rezystory podciągające]
			* zaczepienie do J1 (signal_INPUT), J2 (signal_GND), U1.3-U1.4 (to_ADC, GND), R6 (Vcc)
			* na bazowej opcjonalnie Z1, C1

Ponadto projekt nie wypracował rozwiązań zagadnień takich jak:

* stosowanie do wewnętrznej komunikacji modułów i mastera UART jako open drain 3.3V, czy RS485?
	* RS485 jest bardziej profesjonalny i odporny na zkłócenia
	* RS485 jest bardziej energochłonny i wymaga dodatkowych elementów
	* płytka mikrokontrolera przewiduje możliwość montażowego wyboru jednego z tych dwóch wariantów
* podpisywanie komunikacji UART/Modbus celem weryfikacji autentyczności nadawcy
	* istnieje wstępny schemat takiego rozwiązania (podpisy w rejestrach modbus)
	* nie rozwiązane zostały zagadnienia bezpiecznego przechowywania klucza w uC oraz wgrywania go do nich (zwłaszcza w kontekście aktualizacji oprogramowania po UART w systemie)
* bliskość uC (z obsługą modbus, czy nawet ethernet) do urządzenia (np. czujki PIR) vs grupowanie modułów wokół urządzenia obsługującego ethernet (*Pi)


Przyszłość projektu
-------------------

Aktualnie projekt trafił „na półkę” i nie jest aktywnie rozwijany. Głównymi powodami jest trudność w profesjonalnym, czy nawet pół-profesjonalnym zastosowaniu takiego amatorskiego projektu (certyfikaty kompatybilności elektromagnetycznej, CE, produkcja małoseryjna, wcześniejsze testy prototypów, ...) przy jednoczesnej dostępności na rynku wielu rozwiązań dostępnych z półki (rozproszone moduły IO z Modbus TCP, sterowniki PLC, rozwiązania oparte o Raspberry Pi). Powrotu do jego rozwoju można oczekiwać jedynie w przypadku potrzeby zastosowania jakiś jego elementów w zastosowaniu amatorskim. I raczej należy na niego patrzeć właśnie jako na taką bibliotekę koncepcji do użycia w innym projekcie niż na przyszły produkt.
