#!/usr/bin/python3

import sys, json, subprocess

res = subprocess.run(
	'ffprobe -v error '
		'-show_entries stream_tags=language '
		'-show_entries stream_disposition=default,attached_pic '
		'-show_entries stream=codec_type,codec_name,color_space,pix_fmt,width,height,channels '
		'-of json '
		f' "{sys.argv[1]}"',
	stdout=subprocess.PIPE, shell=True, check=True
)

info = json.loads(res.stdout.decode())

def decorate(text, is_default):
	if is_default:
		return '\033[1;31m' + text + '*\033[0m, '
	else:
		return text + ", "

output = ''

for stream in info['streams']:
	if stream['codec_type'] == 'video':
		if stream['disposition']['attached_pic'] == 1:
			field = f'{stream["width"]}x{stream["height"]}@attached_pic'
		else:
			field = f'{stream["width"]}x{stream["height"]}@{stream["codec_name"]}'
			if "color_space" in stream:
				field += f'/{stream["color_space"]}'
			if "pix_fmt" in stream:
				field += f'/{stream["pix_fmt"]}'
		
	elif stream['codec_type'] == 'audio':
		field = "audio"
		try:
			field += stream['tags']['language'].upper()
		except:
			field += '???'
		if "channels" in stream:
			field += f'@{stream["channels"]}ch'
	
	elif stream['codec_type'] == 'subtitle':
		field = "sub"
		try:
			field += stream['tags']['language'].upper()
		except:
			field += '???'
	
	output += decorate( field, stream['disposition']['default'] == 1 )

print(f'\033[36m{sys.argv[1]}\033[0m:   ' + output[:-2])
