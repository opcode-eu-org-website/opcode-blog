from math import *

def binstr(x, bytes_length=2, byteorder='big', signed=True):
	return "".join([ format(i, '08b') for i in x.to_bytes(bytes_length, byteorder=byteorder, signed=signed) ])

def hexstr(x, bytes_length=2, byteorder='big', signed=True):
	if byteorder == "b":
		byteorder = "big"
	elif byteorder == "l":
		byteorder = "little"
	return x.to_bytes(bytes_length, byteorder=byteorder, signed=signed).hex()


def timeDelta(t1, t2=None, ret="days"):
	import time
	from datetime import datetime
	
	t1 = datetime.timestamp(datetime.fromisoformat(t1))
	if t2:
		t2 = datetime.timestamp(datetime.fromisoformat(t2))
	else:
		t2 = time.time()
	
	if ret == "days":
		return (t2-t1)/(60*60*24)
	else:
		return (t2-t1)

'''
1oz to g, wagę złota w uncjach podaje się w uncjach trojańskich jubilerskich.
żródło: https://pl.wikipedia.org/wiki/Uncja, sprawdzone też przez porównanie ceny 1oz i 1kg oraz w innych źródłach
'''
oz = 31.1034768
