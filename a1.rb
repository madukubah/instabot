require 'watir' # Crawler

browser = Watir::Browser.new :chrome
browser.goto 'https://www.instagram.com/accounts/login/?hl=id'
sleep(50)
