import web
import tuf
import tuf.interposition
import tuf.log
from tuf.interposition import urllib2_tuf as urllib2
		
urls = (
	'/(.*)', 'hello'
)
app = web.application(urls, globals())

class hello:
	def GET(self, name):
		# tuf.log.add_console_handler()
		# try:
		# 	tuf.interposition.configure(filename="tuf.interposition.json")
		# except tuf.Error, error:
		# 	return 'TUF could not initialize due to an error: '+str(error)

		# url = 'http://www.bvestation.com/tuf'
		user_data = web.input()
		return urllib2.urlopen(user_data.link)

if __name__ == "__main__":
	app.run()