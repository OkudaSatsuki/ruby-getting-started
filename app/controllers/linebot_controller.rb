class LinebotController < ApplicationController
    require "line/bot"  # gem "line-bot-api"
 
     # callbackアクションのCSRFトークン認証を無効
     protect_from_forgery :except => [:callback]
 
     def client
       @client ||= Line::Bot::Client.new { |config|
         config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
         config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
       }
     end
     
     def callback
       body = request.body.read
       @data = Datum.all #データベース内の全てのデータ
   
       signature = request.env["HTTP_X_LINE_SIGNATURE"]
       unless client.validate_signature(body, signature)
         error 400 do "Bad Request" end
       end
   
       events = client.parse_events_from(body)
   
       events.each { |event|
        case event
        when Line::Bot::Event::Message
            case event.type
            when Line::Bot::Event::MessageType::Text
               str = event.message["text"]
               
                #helpを表示させる
                case str
                when "help"
                   message1 = {
                       type: "text",
                       text: "ヘルプを表示します"
                   }
               #入力されたコードネームの構成音を探す
                else
                    @data.each do |code|
                        if code.name == str #入力されたコードネームと一致したら
                            #message1 = {
                            #    type: "text",
                            #    text: "#{code.first} #{code.third} #{code.fifth}"
                            #}
                            message1 = {
                                type: "image",
                                originalContentUrl: "https://www.dropbox.com/home?preview=C_V1.jpg",
                                previewImageUrl: "https://www.dropbox.com/home?preview=C_V1.jpg"
                            }
                        break
                        
                        else                #DB上になかったら
                            message1 = {
                            type: "text",
                            text: "Not found"
                        }
                        end
                    end
                end
                client.reply_message(event["replyToken"], message1)
                #client.reply_message(event["replyToken"], message2)
           when Line::Bot::Event::MessageType::Location
               message = {
                   type: "location",
                   title: "あなたはここにいますか？",
                   address: event.message["address"],
                   latitude: event.message["latitude"],
                   longitude: event.message["longitude"]
               }
               client.reply_message(event["replyToken"], message)
           end
        end
        }
   
       head :ok
    end
end
