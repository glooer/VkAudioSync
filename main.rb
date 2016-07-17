require "./VK.rb"
require "open-uri" #for open url

# auth
# https://oauth.vk.com/authorize?client_id=4787098&display=page&redirect_uri=https://oauth.vk.com/blank.html &scope=audio,nohttps&response_type=token&v=5.52

THREAD_COUNT = 4; #количество потоков

ACCESS_TOKEN = "a4508400baba2a626049fc8cba0197e9a517b05f7bde5ec8bd5d933e991ed8456385b7e1209ca81412e12"
SECRET = "7aae67b0db223f0c0f"

OWNER_ID = 114095390

vk = VK.new ACCESS_TOKEN, SECRET

def download filename, uri
  File.open(filename, "wb") do |saved_file|
    saved_file.write open(uri, "rb").read
  end
end

Dir.mkdir("./data") if not File.exist?("./data")
Dir.mkdir("./data/#{OWNER_ID}") if not File.exist?("./data/#{OWNER_ID}")


music = vk.callMethod "audio.get", {:owner_id => OWNER_ID, :count => 6000} #пытаемся получить все записи.
  
if (musics = music["response"])
  musics_count = musics.shift
  work = Queue.new
  musics.each do |v|
    work << ["#{v["artist"]} - #{v["title"]}".gsub(/[^a-zа-яё\d\s\-\(\)\[\]\&\.\,\'\!\;\+\#]/i, ""), v["url"]]
  end
  all_count = work.length
  in_thread = 0
  workers = (0...THREAD_COUNT).map do 
    Thread.new do
      begin
        while x = work.pop(true)
          in_thread += 1
          name = x.first
          url = x.last
          if File::exist?("./data/#{OWNER_ID}/#{name}.mp3")
            #print "File \"#{name}\" exist\n"
          else
            #print "Download is \"#{name}.\"\n"
            download "./data/#{OWNER_ID}/#{name}.mp3", url
            
            #print "Download \"#{name}.\" completle!\n"
          end
          
          in_thread -= 1
          print "\r#{all_count - work.length - in_thread}/#{all_count} завершено"
        end
      rescue ThreadError(e)
        p e
      end
    end
  end
end

STDIN.getc