require 'watir' # Crawler
require 'pry' # Ruby REPL
require 'rb-readline' # Ruby IRB
require 'awesome_print' # Console output
require 'watir-scroll'
require_relative 'credential' # Pulls in login credentials from credentials.rb
# require 'win32ole' #mouse controll
require 'mysql2' #database

client = Mysql2::Client.new(:host => "localhost", :username => "root", :password =>"", :database =>"jargram")


username = $username
password = $password
targetName = $targetName
minta_polbek = ["follow back dong :)", "folbek donk :)", "follow back", "ada nasi? :v"]   
follow_counter = 0
max_follow = 10
like_counter = 0
max_like = 20
start_scrolling = 0
scrolling_inc = 100
folbek_counter =0
max_folbek = 10

# initial
browser = Watir::Browser.new :chrome
browser.goto "https://www.instagram.com/accounts/login/"

# Navigate to Username and Password fields, inject info
ap "Logging in..."
browser.text_field(:name => "username").set "#{username}"
browser.text_field(:name => "password").set "#{password}"

# Click Login Button
browser.button(:class => ["sqdOP", "L3NKy", "y3zKF"] ).click
sleep(10)
# jika minta reactive
# browser.a(:class => '_3m3RQ _7XMpj').click
# sleep(20)
if browser.button(:class => ['aOOlW', 'HoLwm'] ).exists?
    browser.button(:class => ['aOOlW', 'HoLwm'] ).click
end

sleep(5)
# activity

loop do
    arr = Array.new 
    usersArr = Array.new 
    # follow yang ada di beranda
    targetIndex = rand(0 .. targetName.length-1)
  
    browser.scroll.to [0, 200]
    sleep(2);
    # like first
    while browser.span(:class => "glyphsSpriteHeart__outline__24__grey_9 u-__7").exists?
        browser.span(:class => "glyphsSpriteHeart__outline__24__grey_9 u-__7").click
        like_counter = like_counter+1
        sleep(3)
        break if like_counter >= max_like
    end
    sleep(3)
    # follow the target account
    browser.goto "https://www.instagram.com/#{ targetName[targetIndex] }"
    sleep(6)
    browser.link(:href => "/#{ targetName[targetIndex] }/followers/").click
    sleep(5)
    elem = browser.div(:class => "PZuss")
    ap elem
    index =-1
    loop do 
        while elem.div(class:"uu6c_").exists?
            index =index+1
            ap index
            if  browser.button(:class => ['sqdOP', 'L3NKy', 'y3zKF'  ] ).exists?
            else
                break
            end
            if elem.divs(class:"uu6c_")[index].button(:class => ['sqdOP', 'L3NKy', 'y3zKF'  ]).exists?
                browser.button(:class => ['sqdOP', 'L3NKy', 'y3zKF'  ]).click
                sleep(3)
                user =  browser.div(:class => "PZuss").divs(class: "d7ByH")[index].text.strip #dapat!!!!
                usersArr.push(user)
                follow_counter= follow_counter +1
            end
            break if follow_counter >= max_follow
            break if index >= 50
        end
        # browser.button(:class => ['sqdOP', 'L3NKy', 'y3zKF'  ]).click
        # sleep(3)
        elem.scroll.to :bottom
        sleep(2)

        break if follow_counter >= max_follow
        break if index >= 1000
    end  
    if usersArr.length > 0
        kuery = "INSERT INTO `following` (`id`, `username`, `visited`) VALUES "
        usersArr.each do |user|
            if /Verified/.match(user)
            else
                kuery =kuery + "(NULL , '#{user}', 0),"
            end
        end
        kuery = kuery[0 .. kuery.length-2]
        puts kuery
        ap usersArr
        ap usersArr.length
        client.query(kuery)
    end

    # minta folbek
    client.query("SELECT * FROM `following` where visited = 0").each do |user|
        browser.goto "https://www.instagram.com/#{user['username']}"
        sleep(3)
        if browser.div(class:"eLAPa").exists?
            browser.div(class:"eLAPa").click
            sleep(3)
            if browser.span(text:"glyphsSpriteHeart__outline__24__grey_9 u-__7").exists?
                browser.span(text:"glyphsSpriteHeart__outline__24__grey_9 u-__7").click 
            end
            sleep(4)
            if browser.textarea(class:"Ypffh").exists?
                browser.textarea(class:"Ypffh").set "#{minta_polbek[rand(0 .. minta_polbek.length-1)]}"
                browser.form(class:"X7cDz").submit
            end
            sleep(5)
        end
        a = [user['id'], user['visited']+1]
        arr.push(a)
        folbek_counter = folbek_counter  +1
        break if folbek_counter >= max_folbek
    end
    arr.each do |b|
        kuery = "UPDATE `following` SET `visited` = #{b[1]} WHERE `following`.`id` = #{b[0]}" 
        client.query(kuery)
    end
    ap arr

    # # the last
    sleep( 120 )
    # browser.goto "https://www.instagram.com/"

    # reinitialize
    folbek_counter =0
    follow_counter = 0
    like_counter = 0
    start_scrolling = 0

end

# menuju ke taarget komment
# browser.goto "#{target}"
sleep(300)