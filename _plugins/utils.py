import obraz, re, sys

doubleComment = re.compile("## .*?\n")

def charsToEntities(txt, full=False):
	entities  = [ ['&amp;','&'] ]
	entities += [ ['&lt;','<'], ['&gt;','>'] ]
	if full:
		entities += [ ['&quot;','"'], ['&apos;',"'"] ]
	for entity in entities:
		txt = txt.replace(entity[1], entity[0])
	return txt

def includeRaw(path):
	f = open(path)
	t = f.read()
	f.close()
	t = charsToEntities(t)
	t = doubleComment.sub("", t)
	return t

@obraz.processor
def prepareFunctions(site):
	site["xmlRegex"] = re.compile("<.*?>")
	site["includeRaw"] = includeRaw
