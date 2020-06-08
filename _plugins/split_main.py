import obraz, math

@obraz.processor
def process_mainpage_list(site):
	pages     = site.get('pages', [])
	config    = site.get('mainpage', {})
	max_posts = config.get('maxposts', 9999)
	layout    = config.get('layout', 'index')
	
	# count not hidden posts and calculate number of index files
	posts_count = 0
	for p in site.get('posts', []):
		if not 'hidden' in p or not p['hidden']:
			posts_count += 1
	last_index  = math.ceil(posts_count/max_posts)-1
	
	# generate index files
	for i in range(0, last_index+1):
		if i == 0:
			prev_url = ""
			url = "index.html"
		else:
			prev_url = url
			url = next_url
		
		if i < last_index:
			next_url = "index{i}.html".format(i=i+1)
		else:
			next_url = ""
		
		page = {
			'url': url,
			'layout': layout,
			'content': '',
			'start_post': i*max_posts,
			'end_post': (i+1)*max_posts,
			'prev_url': prev_url,
			'next_url': next_url,
		}
		pages.append(page)
