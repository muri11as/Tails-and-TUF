import web
import tuf.interposition
from tuf.interposition import urllib2_tuf as urllib2
		
urls = (
	'/(.*)', 'hello'
)
app = web.application(urls, globals())

class hello:
	def GET(self, name):
		user_data = web.input()
		return urllib2.urlopen(user_data.link)

if __name__ == "__main__":
	tuf.interposition.configure()
	app.run()