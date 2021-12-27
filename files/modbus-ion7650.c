/**
 * Prosty program do odczytu wartości z urządzenia modbus TCP i wypisania ich
 * w formacie wejściowym dla zabbix_sender. Zawiera przykład tablicy rejestrów
 * dla ION7650. Program przeznaczony do uruchamiania ze skryptu przekazujacego
 * wyjście do zabbix_sender.
 * 
 * Copyright (c) 2016-2021 Robert Ryszard Paciorek <rrp@opcode.eu.org>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
**/

/// funkcje "biblioteczne"

#include <modbus/modbus-tcp.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>

#define HEX     0
#define INT16   1
#define BITMASK 3
#define INT32   11
#define FLOAT   12

printRaw(int type, uint16_t *data, int *dataIdx, int start) {
	int i = *dataIdx;
	int j;
	switch(type) {
		case INT16:
			printf("%d  %f\n", start + i, (float)(data[i]));
			*dataIdx = i + 1;
			break;
		case INT32:
			printf("%d  %f\n", start + i, (float)(MODBUS_GET_INT32_FROM_INT16(data, i)));
			*dataIdx = i + 2;
			break;
		case BITMASK:
			for (j=0; j<16; ++j)
				printf("%d [%d]  %d\n", start + i, j, (data[i] & (1<<j)) != 0);
			*dataIdx = i + 1;
			break;
		case FLOAT:
			printf("%d  %f\n", start + i, modbus_get_float_dcba(data+i));
			*dataIdx = i + 2;
			break;
		case HEX:
		default:
			printf("%d  0x%04x\n", start + i, data[i]);
			*dataIdx = i + 1;
			break;
	}
}

printDesc(int type, uint16_t *data, int *dataIdx, const char **desc, int *descIdx, float scale, const char *host, const char *surfix, const char *prefix) {
	int i = *dataIdx;
	int k = *descIdx;
	int j;
	switch(type) {
		case INT16:
			if (desc[k])
				printf("%s%s  %s%s  %f\n", host, surfix, prefix, desc[k], (float)(data[i]) * scale);
			*dataIdx = i + 1;
			*descIdx = k + 1;
			break;
		case INT32:
			if (desc[k])
				printf("%s%s  %s%s  %f\n", host, surfix, prefix, desc[k], (float)(MODBUS_GET_INT32_FROM_INT16(data, i)) * scale);
			*dataIdx = i + 2;
			*descIdx = k + 1;
			break;
		case BITMASK:
			for (j=0; j<16; ++j)
				if (desc[k+j])
					printf("%s%s  %s%s  %d\n", host, surfix, prefix, desc[k+j], (data[i] & (1<<j)) != 0);
			*dataIdx = i + 1;
			*descIdx = k + 16;
			break;
		case FLOAT:
			if (desc[k])
				printf("%s%s  %s%s  %f\n", host, surfix, prefix, desc[k], modbus_get_float_dcba(data+i) * scale);
			*dataIdx = i + 2;
			*descIdx = k + 1;
			break;
		case HEX:
		default:
			if (desc[k])
				printf("%s  %s%s  0x%04x\n", host, prefix, desc[k], data[i]);
			*dataIdx = i + 1;
			*descIdx = k + 1;
			break;
	}
}

/**
 * odczytuje i wypisuje zestaw rejestrow modbusowych pojedynczego typu
 *
 * @param start   numer pierwszego rejestru do odczytania
 * @param count   ilosc rejestrow do odczytania
 *                  jezeli pojedyncza wypisywana wartosc budowana jest na podstwie kilu rejestrow (np. typ FLOAT) to wiekszy od liczby wypisanych wartosci
 *                  jezeli pojedyncza wypisywana wartosc budowana jest na podstwie fragmentu rejestr (np. typ BITMASK) to mniejszy od liczby wypisanych wartosci
 * @param type    sposob interpretacji wartosci w rejestrach modbus
 * @param scale   wspolczynnik skalowania wartosci
 * @param desc    tablica z nazwami wartosci,
 *                  jezeli desc == NULL wypisywanie przy pomocy numerow rejestrow
 *                  jezeli desc[i] == NULL to wartosc numer i nie zostanie wypisana
 * @param host    nazwa hosta zabbixowego do wypisania w pierwszej kolumnie
 * @param surfix  surfix dodawany do nazwy hosta
 *                  przydatny gdy z jednego urzadzenia modbusowego wczytujemy dane do grupy hostow zabbixowych
 * @param prefix  prefix dodawany do nazwy rejestru (pobranej z desc[i])
 *                  przydatne gdy na jednym urzadzeniu modbusowym wystepuje powtarzalne grupy rejestrow (np. bramkowanie innych urzadzen)
 */
int read(modbus_t *mb, int start, int count, int type, float scale, const char **desc, const char *host, const char *surfix, const char *prefix) {
	uint16_t tab_reg[128];
	int i=0, j=0, k=0;

	if (modbus_read_registers(mb, start, count, tab_reg) == -1) {
	//if (modbus_read_input_registers(mb, start, count, tab_reg) == -1) {
		fprintf(stderr, "Read failed on %s: %s\n", host, modbus_strerror(errno));
		return -1;
	}

	if (!desc) {
		while (i<count) {
			printRaw(type, tab_reg, &i, start);
		}
	} else {
		while (i<count) {
			printDesc(type, tab_reg, &i, desc, &k, scale, host, surfix, prefix);
		}
	}
	return -2;
}

/**
 * odczytuje i wypisuje zestaw rejestrow modbusowych roznych typow
 *
 * @param start   numer pierwszego rejestru do odczytania
 * @param count   ilosc rejestrow do odczytania
 *                  jezeli pojedyncza wypisywana wartosc budowana jest na podstwie kilu rejestrow (np. typ FLOAT) to wiekszy od liczby wypisanych wartosci
 *                  jezeli pojedyncza wypisywana wartosc budowana jest na podstwie fragmentu rejestr (np. typ BITMASK) to mniejszy od liczby wypisanych wartosci
 * @param types   tablica typow wartosci
 *                  indeks zwiekszany o jeden z kazda wypisana wartoscia (uzyskana z jednego lub kilku rejestrow) lub grupa wartosci z pojedynczego rejestru
 * @param scales  tablica wspolczynnikow skalowania wartosci, indeksowana identycznie jak @a types
 * @param desc    tablica z nazwami wartosci,
 *                  jezeli desc == NULL wypisywanie przy pomocy numerow rejestrow
 *                  jezeli desc[i] == NULL to wartosc numer i nie zostanie wypisana
 * @param host    nazwa hosta zabbixowego do wypisania w pierwszej kolumnie
 * @param surfix  surfix dodawany do nazwy hosta
 *                  przydatny gdy z jednego urzadzenia modbusowego wczytujemy dane do grupy hostow zabbixowych
 * @param prefix  prefix dodawany do nazwy rejestru (pobranej z desc[i])
 *                  przydatne gdy na jednym urzadzeniu modbusowym wystepuje powtarzalne grupy rejestrow (np. bramkowanie innych urzadzen)
 */
int read2(modbus_t *mb, int start, int count, int *types, float *scales, const char **desc, const char *host, const char *surfix, const char *prefix) {
	uint16_t tab_reg[128];
	int i=0, j=0, k=0;

	if (modbus_read_registers(mb, start, count, tab_reg) == -1) {
	//if (modbus_read_input_registers(mb, start, count, tab_reg) == -1) {
		fprintf(stderr, "Read failed: %s\n", modbus_strerror(errno));
		return -1;
	}

	if (!desc) {
		while (i<count) {
			printRaw(types[j], tab_reg, &i, start);
			++j;
		}
	} else {
		while (i<count) {
			printDesc(types[j], tab_reg, &i, desc, &k, scales[j], host, surfix, prefix);
			++j;
		}
	}
	return -2;
}

modbus_t* begin(const char* host, const char* port, int addr) {
	modbus_t* mb = modbus_new_tcp_pi(host, port);
	if (mb == NULL) {
		fprintf(stderr, "Unable to allocate libmodbus context\n");
		exit(1);
	}

	if (addr > 0)
		modbus_set_slave(mb, addr);

	#ifdef DEBUG
	modbus_set_debug(mb, 1);
	#endif
	
	if (modbus_connect(mb) == -1) {
		fprintf(stderr, "Connection failed for %s: %s\n", host, modbus_strerror(errno));
		modbus_free(mb);
		exit(1);
	}

	return mb;
}

void end(modbus_t *mb) {
	modbus_close(mb);
	modbus_free(mb);
}


/// kod dedykowany danemu urządzeniu - uwzględniający tablicę rejestrów modbus
/// w tym przypadku analizatora ION7650

const char* prad[16] = {
	"prad.A", "prad.B", "prad.C" , NULL, NULL,
	"prad.avg", "prad.avg.mn", "prad.avg.mx", "prad.avg.mean",
	"freq", "freq.mn", "freq.mx", "freq.mean",
	"V.unbal", "I.unbal", "Phase.Rev"
};

const char* napiecie[12] = {
	"napiecie.AN", "napiecie.BN", "napiecie.CN", "napiecie.LN.avg", "napiecie.LN.avg.mx", NULL,
	"napiecie.AB", "napiecie.BC", "napiecie.CA", "napiecie.LL.avg", "napiecie.LL.avg.mx", "napiecie.LL.avg.mean"
};

const char* moc[15] = {
	"power.active.A", "power.active.B", "power.active.C", "power.active.tot", "power.active.tot.mx",
	"power.reactive.A", "power.reactive.B", "power.reactive.C", "power.reactive.tot", "power.reactive.tot.mx",
	"power.complex.A", "power.complex.B", "power.complex.C", "power.complex.tot", "power.complex.tot.mx"
};

const char* jakosc[16] = {
	"PF.A", "PF.B", "PF.C", "PF.tot",
	"THD.mx.V1", "THD.mx.V2", "THD.mx.V3", "THD.mx.I1", "THD.mx.I2", "THD.mx.I3",
	"KF.I1", "KF.I2", "KF.I3", "CF.I1", "CF.I2", "CF.I3"
};

int main(int argc, char *argv[]) {
	if (argc < 3) {
		printf("USAGE: %s name IPaddress\n", argv[0]);
		exit(2);
	}

	modbus_t *mb = begin(argv[2], "502", -1);

	read(mb, 149, 16, INT16, 0.1,  prad,     argv[1], "", "");
	read(mb, 165, 22, INT32, 1,    napiecie, argv[1], "", "");
	read(mb, 197, 30, INT32, 1,    moc,      argv[1], "", "");
	read(mb, 261, 16, INT16, 0.01, jakosc,   argv[1], "", "");

	end(mb);
}
